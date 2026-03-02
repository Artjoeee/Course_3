#pragma once
#include "Global.h"

DWORD WINAPI ConsolePipe(LPVOID pPrm)
{
    cout << "ConsolePipe started;\n" << endl;

    HANDLE hPipe = INVALID_HANDLE_VALUE;
    DWORD rc = 0;

    try
    {
        SECURITY_ATTRIBUTES SecurityAttributes;
        SECURITY_DESCRIPTOR SecurityDescriptor;

        InitializeSecurityDescriptor(
            &SecurityDescriptor,
            SECURITY_DESCRIPTOR_REVISION);

        SetSecurityDescriptorDacl(
            &SecurityDescriptor,
            TRUE,
            NULL,
            FALSE);

        SecurityAttributes.nLength = sizeof(SecurityAttributes);
        SecurityAttributes.lpSecurityDescriptor = &SecurityDescriptor;
        SecurityAttributes.bInheritHandle = FALSE;

        char rnpname[64];
        strcpy(rnpname, "\\\\.\\pipe\\");
        strcat(rnpname, npname);

        hPipe = CreateNamedPipe(
            rnpname,
            PIPE_ACCESS_DUPLEX,
            PIPE_TYPE_MESSAGE | PIPE_WAIT,
            1,
            512,
            512,
            INFINITE,
            &SecurityAttributes);

        if (hPipe == INVALID_HANDLE_VALUE)
            throw SetErrorMsgText("CreateNamedPipe:", GetLastError());

        /*HANDLE hStopEvent = CreateEvent(NULL, TRUE, FALSE, NULL);*/

        while (*((TalkersCmd*)pPrm) != Exit)
        {
            if (!ConnectNamedPipe(hPipe, NULL))
            {
                if (GetLastError() != ERROR_PIPE_CONNECTED)
                {
                    if (*((TalkersCmd*)pPrm) == Exit) break;
                    throw SetErrorMsgText("ConnectNamedPipe:", GetLastError());
                }
            }

            char ReadBuf[512] = {};
            char WriteBuf[512] = {};
            DWORD nBytesRead = 0, nBytesWritten = 0;

            while (*((TalkersCmd*)pPrm) != Exit)
            {
                DWORD bytesAvailable = 0;
                if (!PeekNamedPipe(hPipe, NULL, 0, NULL, &bytesAvailable, NULL))
                {
                    Sleep(50);
                    continue;
                }

                if (bytesAvailable == 0)
                {
                    if (*((TalkersCmd*)pPrm) == Exit) break;
                    Sleep(50);
                    continue;
                }

                if (!ReadFile(hPipe, ReadBuf, sizeof(ReadBuf) - 1, &nBytesRead, NULL))
                    break;

                if (nBytesRead == 0)
                    continue;

                ReadBuf[nBytesRead] = 0;
                memset(WriteBuf, 0, sizeof(WriteBuf));

                bool setServerCmd = false;
                TalkersCmd SetCommand;

                if (strncmp(ReadBuf, "OPEN_ACCEPT ", 12) == 0)
                {
                    int port = atoi(ReadBuf + 12);
                    OpenAcceptPort(port);
                    sprintf(WriteBuf, "OPEN_ACCEPT %d OK", port);
                }

                else if (strncmp(ReadBuf, "CLOSE_ACCEPT ", 13) == 0)
                {
                    int port = atoi(ReadBuf + 13);
                    CloseAcceptPort(port);
                    sprintf(WriteBuf, "CLOSE_ACCEPT %d OK", port);
                }

                else if (strlen(ReadBuf) == 1 && ReadBuf[0] >= '0' && ReadBuf[0] <= '8')
                {
                    int n = ReadBuf[0] - '0';
                    switch (n)
                    {
                    case 0:
                        SetCommand = Start;
                        setServerCmd = true;
                        sprintf(WriteBuf, "Start");
                        break;

                    case 1:
                        SetCommand = Stop;
                        setServerCmd = true;
                        sprintf(WriteBuf, "Stop");
                        break;

                    case 2:
                        SetCommand = Exit;
                        setServerCmd = true;
                        sprintf(WriteBuf, "Exit");
                        printf("ConsolePipe: Exit Server\n");
                        /*SetEvent(hStopEvent);*/
                        *((TalkersCmd*)pPrm) = Exit;
                        //ExitProcess(0);
                        break;

                    case 3:
                        sprintf(WriteBuf,
                            "\nAccept: %i\nFail: %i\nFinished: %i\nWork: %i\n",
                            Accept, Fail, Finished, Work);
                        break;

                    case 4:
                        SetCommand = Wait;
                        setServerCmd = true;
                        sprintf(WriteBuf, "Wait");
                        break;

                    case 5:
                        SetCommand = Shutdown;
                        setServerCmd = true;
                        sprintf(WriteBuf, "Shutdown");
                        /*SetEvent(hStopEvent);*/
                        *((TalkersCmd*)pPrm) = Exit;
                        break;

                    case 7:
                    {
                        if (!ReadFile(hPipe, ReadBuf, sizeof(ReadBuf) - 1, &nBytesRead, NULL))
                            break;

                        ReadBuf[nBytesRead] = 0;

                        HMODULE hMod = LoadLibrary(ReadBuf);
                        if (hMod)
                        {
                            vList.push_back(hMod);
                            sprintf(WriteBuf, "DLL Load OK");
                        }
                        else
                        {
                            sprintf(WriteBuf, "DLL Load ERROR");
                        }
                        break;
                    }

                    case 8:
                    {
                        if (!ReadFile(hPipe, ReadBuf, sizeof(ReadBuf) - 1, &nBytesRead, NULL))
                            break;

                        ReadBuf[nBytesRead] = 0;

                        bool found = false;
                        char dllName[256];

                        for (auto it = vList.begin(); it != vList.end(); ++it)
                        {
                            GetModuleFileName(*it, dllName, 256);
                            if (strstr(dllName, ReadBuf))
                            {
                                FreeLibrary(*it);
                                vList.erase(it);
                                sprintf(WriteBuf, "DLL Free OK");
                                found = true;
                                break;
                            }
                        }

                        if (!found)
                            sprintf(WriteBuf, "DLL Free ERROR");

                        break;
                    }
                    }
                }
                else
                {
                    sprintf(WriteBuf, "Unknown command");
                }

                if (setServerCmd)
                {
                    *((TalkersCmd*)pPrm) = SetCommand;
                    printf("ConsolePipe: command %s\n", WriteBuf);
                }

                if (!WriteFile(
                    hPipe,
                    WriteBuf,
                    (DWORD)strlen(WriteBuf) + 1,
                    &nBytesWritten,
                    NULL))
                {
                    throw string("ConsolePipe write error");
                }
            }

            DisconnectNamedPipe(hPipe);
        }

        CloseHandle(hPipe);
        cout << "ConsolePipe stopped;\n" << endl;
    }
    catch (string err)
    {
        cout << err << endl;
    }

    ExitThread(rc);
}
