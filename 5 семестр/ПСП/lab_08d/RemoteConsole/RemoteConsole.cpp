#include "stdafx.h"
string GetErrorMsgText(int code)
{
	string msgText;
	switch (code)
	{
	default: msgText = "***ERROR***";
		break;
	};
	return msgText;
}
string SetPipeError(string msgText, int code)
{
	return msgText + GetErrorMsgText(code);
};

int _tmain(int argc, _TCHAR* argv[])
{
	setlocale(LC_ALL, "Rus");
	SetConsoleTitle("Remote Console"); 

	try
	{
		printf(
			"Commands:\n"
			" 1 - Start\n"
			" 2 - Stop\n"
			" 3 - Exit\n"
			" 4 - Statistics\n"
			" 5 - Wait\n"
			" 6 - Shutdown\n"
			" OPEN_ACCEPT XXXX\n"
			" CLOSE_ACCEPT XXXX\n\n"
		);
		char ReadBuf[50] = "";
		char WriteBuf[50] = "";
		DWORD nBytesRead;
		DWORD nBytesWrite;

		int Code = 0;

		char serverName[256];
		char PipeName[512];


		cout << "Enter server name: ";
		cin >> serverName;
		sprintf(PipeName, "\\\\%s\\pipe\\cpipe", serverName);


		BOOL fSuccess;

		SECURITY_ATTRIBUTES SecurityAttributes;
		SECURITY_DESCRIPTOR SecurityDescriptor;

		fSuccess = InitializeSecurityDescriptor(
			&SecurityDescriptor,
			SECURITY_DESCRIPTOR_REVISION);

		if (!fSuccess) {
			throw new string("InitializeSecurityDescriptor(): Îøèáêà");
		}

		fSuccess = SetSecurityDescriptorDacl(
			&SecurityDescriptor,
			TRUE,
			NULL,
			FALSE);

		if (!fSuccess) {
			throw new string("SetSecurityDescriptorDacl(): Îøèáêà");
		}

		SecurityAttributes.nLength = sizeof(SecurityAttributes);
		SecurityAttributes.lpSecurityDescriptor = &SecurityDescriptor;
		SecurityAttributes.bInheritHandle = FALSE;

		HANDLE hNamedPipe = CreateFile(PipeName, GENERIC_READ | GENERIC_WRITE, 0, NULL, OPEN_EXISTING, 0, &SecurityAttributes);

		do
		{
			printf("Command: ");

			cin.ignore(cin.rdbuf()->in_avail());
			cin.getline(WriteBuf, sizeof(WriteBuf));

			if (strlen(WriteBuf) == 0)
				continue;

			// ===== ×ÈÑËÎÂÀß ÊÎÌÀÍÄÀ =====
			if (isdigit(WriteBuf[0]))
			{
				int Code = atoi(WriteBuf);

				if (Code >= 1 && Code <= 6)
				{
					sprintf(WriteBuf, "%d", Code - 1);
				}
				else
				{
					printf("Íåâåðíàÿ êîìàíäà\n\n");
					continue;
				}
			}

			if (!WriteFile(
				hNamedPipe,
				WriteBuf,
				(DWORD)strlen(WriteBuf) + 1,
				&nBytesWrite,
				NULL))
				throw "WriteFile error";

			if (ReadFile(hNamedPipe, ReadBuf, sizeof(ReadBuf), &nBytesRead, NULL))
				cout << ReadBuf << endl;
			else
				throw "ReadFile error";

		} while (strcmp(WriteBuf, "2") != 0 && strcmp(WriteBuf, "5") != 0);

	}
	catch (char* ErrorPipeText)
	{
		printf("%s", ErrorPipeText);
		cout << GetLastError() << endl;
	}
	system("pause");
	return 0;
}
