#pragma once
#include "Global.h"

DWORD WINAPI DispathServer(LPVOID pPrm)
{
    cout << "DispathServer started;\n" << endl;
    DWORD rc = 0;
    
    try
    {
        while (*((TalkersCmd*)pPrm) != Exit)
        {
            if (WaitForSingleObject(Event, 300) == WAIT_OBJECT_0)
            {
                if (Work > 0)
                {
                    Contact* client = NULL;
                    int libuf = 1;
                    char CallBuf[50] = "", SendError[50] = "ErrorInquiry";

                    EnterCriticalSection(&scListContact);

                    for (auto p = Contacts.begin(); p != Contacts.end(); ++p)
                    {
                        if (p->type == Contact::ACCEPT)
                        {
                            client = &(*p);
                            bool Check = false;
                            bool connectionClosed = false;

                            // Устанавливаем неблокирующий режим на время проверки
                            u_long mode = 1;
                            ioctlsocket(client->s, FIONBIO, &mode);

                            while (!Check && !connectionClosed)
                            {
                                if ((libuf = recv(client->s, CallBuf, sizeof(CallBuf), 0)) == SOCKET_ERROR)
                                {
                                    int lastError = WSAGetLastError();

                                    switch (lastError)
                                    {
                                    case WSAEWOULDBLOCK:
                                        SleepEx(50, TRUE);
                                        break;

                                    case WSAECONNRESET:
                                    case WSAECONNABORTED:
                                    case WSAENOTSOCK:
                                        cout << "DispatchServer: Client disconnected (error: " << lastError << ")" << endl;
                                        client->sthread = Contact::ABORT;
                                        connectionClosed = true;
                                        break;

                                    default:
                                        cout << "DispatchServer: Socket error " << lastError << ", marking as ABORT" << endl;
                                        client->sthread = Contact::ABORT;
                                        connectionClosed = true;
                                        break;
                                    }
                                }
                                else if (libuf == 0)
                                {
                                    cout << "DispatchServer: Client gracefully closed connection" << endl;
                                    client->sthread = Contact::ABORT;
                                    connectionClosed = true;
                                }
                                else
                                {
                                    // Данные получены
                                    CallBuf[libuf] = '\0';
                                    Check = true;
                                }
                            }

                            // Возвращаем блокирующий режим
                            mode = 0;
                            ioctlsocket(client->s, FIONBIO, &mode);

                            if (connectionClosed)
                            {
                                continue;
                            }

                            // Проверяем доступные DLL
                            bool dllFound = false;
                            int dllFunc = -1;
                            TCHAR dllName[256];

                            if (!vList.empty())
                            {
                                for (int i = 0; i < vList.size(); i++)
                                {
                                    if (GetModuleFileName(vList[i], dllName, 256) != 0)
                                    {
                                        // Здесь можно добавить проверку имени сервиса, если нужно
                                        dllFunc = i;
                                        dllFound = true;
                                        break;
                                    }
                                }
                            }

                            if (dllFound)
                            {
                                client->type = Contact::CONTACT;
                                strncpy_s(client->srvname, CallBuf, sizeof(client->srvname) - 1);

                                // Создаем таймер
                                client->htimer = CreateWaitableTimer(NULL, FALSE, NULL);
                                if (client->htimer)
                                {
                                    LARGE_INTEGER liDueTime;
                                    liDueTime.QuadPart = -1800000000LL;  // 3 минуты в 100-наносекундных интервалах


                                    if (!SetWaitableTimer(client->htimer, &liDueTime, 0, ASWTimer, client, FALSE))
                                    {
                                        cout << "DispatchServer: Failed to set timer" << endl;
                                        CloseHandle(client->htimer);
                                        client->htimer = NULL;
                                    }
                                }

                                // Отправляем подтверждение клиенту
                                if (send(client->s, CallBuf, strlen(CallBuf) + 1, 0) == SOCKET_ERROR)
                                {
                                    int sendError = WSAGetLastError();
                                    if (sendError != WSAECONNRESET && sendError != WSAECONNABORTED)
                                    {
                                        cout << "DispatchServer: Send error " << sendError << endl;
                                    }
                                    client->sthread = Contact::ABORT;
                                }
                                else
                                {
                                    HANDLE(*func)(char*, LPVOID) = (HANDLE(*)(char*, LPVOID))vArray[dllFunc];
                                    if (func)
                                    {
                                        client->hthread = func(CallBuf, client);
                                        if (!client->hthread)
                                        {
                                            cout << "DispatchServer: Failed to create thread from DLL" << endl;
                                            client->sthread = Contact::ABORT;
                                        }
                                    }
                                    else
                                    {
                                        cout << "DispatchServer: Invalid function pointer from DLL" << endl;
                                        client->sthread = Contact::ABORT;
                                    }
                                }
                            }
                            else
                            {
                                cout << "DispatchServer: No suitable DLL found for request: " << CallBuf << endl;

                                if (send(client->s, SendError, strlen(SendError) + 1, 0) == SOCKET_ERROR)
                                {
                                    int sendError = WSAGetLastError();
                                    if (sendError != WSAECONNRESET && sendError != WSAECONNABORTED)
                                    {
                                        cout << "DispatchServer: Error sending error message: " << sendError << endl;
                                    }
                                }

                                closesocket(client->s);
                                client->s = INVALID_SOCKET;
                                client->sthread = Contact::ABORT;

                                if (client->htimer)
                                {
                                    CancelWaitableTimer(client->htimer);
                                    CloseHandle(client->htimer);
                                    client->htimer = NULL;
                                }

                                InterlockedIncrement(&Fail);
                            }
                        }
                    }

                    LeaveCriticalSection(&scListContact);
                }

                SleepEx(0, TRUE);
            }

            SleepEx(50, TRUE);
        }
    }
    catch (const string& errorMsgText)
    {
        cout << "DispatchServer exception: " << errorMsgText << endl;
    }
    catch (...)
    {
        cout << "DispatchServer: Unknown exception occurred" << endl;
    }

    cout << "DispatchServer stopped;\n" << endl;
    ExitThread(rc);
}
