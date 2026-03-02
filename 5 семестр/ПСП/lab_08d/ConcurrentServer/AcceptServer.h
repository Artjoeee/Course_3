#pragma once
#include "Global.h"


static void WaitClients()
{
	bool ListEmpty = false;
	while (!ListEmpty)
	{
		EnterCriticalSection(&scListContact);
		ListEmpty = Contacts.empty();
		LeaveCriticalSection(&scListContact);
		SleepEx(0, TRUE);
	}
}

bool AcceptCycle(int squirt, SOCKET* s)
{
	bool rc = false;
	Contact c(Contact::ACCEPT, "AcceptServer");
	c.hAcceptServer = hAcceptServer;


	if ((c.s = accept(*s, (sockaddr*)&c.prms, &c.lprms)) == INVALID_SOCKET)
	{
		if (WSAGetLastError() != WSAEWOULDBLOCK)
			throw  SetErrorMsgText("Accept:", WSAGetLastError());
	}
	else
	{
		rc = true;
		InterlockedIncrement(&Accept);
		InterlockedIncrement(&Work);
		EnterCriticalSection(&scListContact);
		Contacts.push_front(c);
		LeaveCriticalSection(&scListContact);
		SetEvent(Event);

	}
	return rc;
};

void CommandsCycle(TalkersCmd& cmd, SOCKET* s)  
{
	int squirt = 0;
	while (cmd != Exit)
	{
		switch (cmd)
		{
		case Start: 
			for (auto it = AcceptThreads.begin(); it != AcceptThreads.end(); ++it)
			{
				DynamicPort* dnp = it->second;
				dnp->acceptEnabled = true;
			}
			cmd = Getcommand;
			squirt = AS_SQUIRT;
			break;
		case Stop: 
			for (auto it = AcceptThreads.begin(); it != AcceptThreads.end(); ++it)
			{
				DynamicPort* dnp = it->second;
				dnp->acceptEnabled = false;
			}
			cmd = Getcommand;
			squirt = 0;
			break;
		case Wait: 
			WaitClients();
			cmd = Getcommand;
			squirt = AS_SQUIRT;
			break;
		case Shutdown:
			WaitClients();

			/*std::lock_guard<std::mutex> lock(AcceptThreadsMutex);

			for (auto it = AcceptThreads.begin(); it != AcceptThreads.end(); ++it)
			{
				int port = it->first;
				DynamicPort* dp = it->second;

				SetEvent(dp->hStopEvent);
				WaitForSingleObject(dp->hThread, INFINITE);
				closesocket(dp->listenSock);
				delete dp;
			}
			AcceptThreads.clear();*/

			cmd = Exit;
			break;
		};

		if (cmd != Exit && squirt > Work)
		{
			if (AcceptCycle(squirt, s)) 
			{
				cmd = Getcommand;
			}


			SleepEx(0, TRUE);
		}

	}
};

DWORD WINAPI AcceptServer(LPVOID pPrm)
{
	cout << "AcceptServer started\n" << endl;
	DWORD rc = 0; 
	SOCKET  ServerSocket;
	WSADATA wsaData;

	try
	{
		if (WSAStartup(MAKEWORD(2, 0), &wsaData) != 0)
			throw  SetErrorMsgText("Startup:", WSAGetLastError());

		if ((ServerSocket = socket(AF_INET, SOCK_STREAM, NULL)) == INVALID_SOCKET)
			throw  SetErrorMsgText("Socket:", WSAGetLastError());

		SOCKADDR_IN Server_IN;
		Server_IN.sin_family = AF_INET;
		Server_IN.sin_port = htons(port);
		Server_IN.sin_addr.s_addr = ADDR_ANY;
		if (bind(ServerSocket, (LPSOCKADDR)&Server_IN, sizeof(Server_IN)) == SOCKET_ERROR)
			throw  SetErrorMsgText("Bind:", WSAGetLastError());

		if (listen(ServerSocket, SOMAXCONN) == SOCKET_ERROR)
			throw  SetErrorMsgText("Listen:", WSAGetLastError());

		u_long nonblk;
		if (ioctlsocket(ServerSocket, FIONBIO, &(nonblk = 1)) == SOCKET_ERROR)
			throw SetErrorMsgText("Ioctlsocket:", WSAGetLastError());

		TalkersCmd* command = (TalkersCmd*)pPrm;

		CommandsCycle(*((TalkersCmd*)command), &ServerSocket);


		if (closesocket(ServerSocket) == SOCKET_ERROR)
			throw  SetErrorMsgText("Сlosesocket:", WSAGetLastError());

		if (WSACleanup() == SOCKET_ERROR)
			throw  SetErrorMsgText("Cleanup:", WSAGetLastError());
	}
	catch (string errorMsgText)
	{
		std::cout << errorMsgText << endl;
	}
	cout << "AcceptServer stoped;\n" << endl;

	ExitThread(rc);
}


DWORD WINAPI AcceptServerDynamic(LPVOID pPrm)
{
	DynamicPort* dp = (DynamicPort*)pPrm;
	SOCKET listenSock = dp->listenSock;
	DWORD rc = 0;

	try
	{
		u_long nonblk = 1;
		if (ioctlsocket(listenSock, FIONBIO, &nonblk) == SOCKET_ERROR)
			throw SetErrorMsgText("Ioctlsocket:", WSAGetLastError());

		std::cout << "AcceptServerDynamic started on port " << dp->port << std::endl;

		// Цикл обработки клиентов для этого порта
		while (WaitForSingleObject(dp->hStopEvent, 0) != WAIT_OBJECT_0)
		{
			if (cmd != Exit)
			{
				if (cmd == Wait || cmd == Stop)
				{
					SleepEx(10, TRUE);
					continue;
				}

				if (!dp->acceptEnabled)
				{
					SleepEx(10, TRUE);
					continue;
				}

				AcceptCycle(AS_SQUIRT, &listenSock);
				SleepEx(0, TRUE);
			}

			SleepEx(0, TRUE);
		}

		if (closesocket(listenSock) == SOCKET_ERROR)
			std::cout << "Error closing socket on port " << dp->port << std::endl;

		CloseHandle(dp->hStopEvent);

		std::cout << "AcceptServerDynamic stopped on port " << dp->port << std::endl;
	}
	catch (const std::string& err)
	{
		std::cout << "AcceptServerDynamic error: " << err << std::endl;
	}

	ExitThread(rc);
}




void OpenAcceptPort(int port)
{
	std::lock_guard<std::mutex> lock(AcceptThreadsMutex);

	if (AcceptThreads.count(port)) return;

	SOCKET sock = socket(AF_INET, SOCK_STREAM, 0);
	SOCKADDR_IN addr{};
	addr.sin_family = AF_INET;
	addr.sin_port = htons(port);
	addr.sin_addr.s_addr = INADDR_ANY;

	// Важно для повторного bind
	int opt = 1;
	setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, (char*)&opt, sizeof(opt));

	if (bind(sock, (sockaddr*)&addr, sizeof(addr)) == SOCKET_ERROR)
	{
		closesocket(sock);
		cout << "Bind failed\n";
		return;
	}

	listen(sock, SOMAXCONN);

	DynamicPort* dp = new DynamicPort;
	dp->port = port;
	dp->listenSock = sock;
	dp->hStopEvent = CreateEvent(NULL, TRUE, FALSE, NULL);
	dp->hThread = CreateThread(NULL, 0, AcceptServerDynamic, dp, 0, NULL);

	AcceptThreads[port] = dp;
}


void CloseAcceptPort(int port)
{
	std::lock_guard<std::mutex> lock(AcceptThreadsMutex);

	auto it = AcceptThreads.find(port);
	if (it == AcceptThreads.end()) return;

	DynamicPort* dp = it->second;

	SetEvent(dp->hStopEvent); // сигнал потоку завершиться
	WaitForSingleObject(dp->hThread, INFINITE);

	CloseHandle(dp->hThread);
	closesocket(dp->listenSock);
	delete dp;

	AcceptThreads.erase(it);
}