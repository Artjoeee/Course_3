#pragma once
#include "Global.h"

DWORD WINAPI TimeServer(LPVOID lParam)
{
    DWORD rc = 0;
    Contact* client = (Contact*)lParam;
    QueueUserAPC(ASStartMessage, client->hAcceptServer, (DWORD)client);

    try
    {
        client->sthread = Contact::WORK;
        int bytes = 1;
        char ibuf[50], obuf[50] = "Close: finish;", Time[50] = "Time";

        while (client->TimerOff == false)
        {
            if ((bytes = recv(client->s, ibuf, sizeof(ibuf), NULL)) == SOCKET_ERROR)
            {
                switch (WSAGetLastError())
                {
                case WSAEWOULDBLOCK:
                    SleepEx(100, TRUE);
                    break;
                default:
                    throw SetErrorMsgText("Recv:", WSAGetLastError());
                }
            }
            else if (bytes > 0)
            {
                ibuf[bytes] = '\0';  //завершаем строку

                if (ibuf[0] == '0' || !strcmp(ibuf, "exit"))
                {
                    cout << "TimeServer: получена команда завершения: " << ibuf << endl;
                    break;
                }


                if (client->TimerOff != false)
                {
                    break;
                }

                // Получение и отправка времени
                SYSTEMTIME stt;
                GetLocalTime(&stt);
                sprintf(ibuf, "%s %d.%d.%d/%d:%02d:%02d",
                    Time,
                    stt.wDay, stt.wMonth, stt.wYear,
                    stt.wHour, stt.wMinute, stt.wSecond);

                if ((send(client->s, ibuf, strlen(ibuf) + 1, NULL)) == SOCKET_ERROR)
                    throw SetErrorMsgText("Send:", WSAGetLastError());

                cout << "TimeServer: отправлено время клиенту "
                    << inet_ntoa(client->prms.sin_addr) << endl;
            }
            else if (bytes == 0)
            {
                // Соединение закрыто клиентом
                cout << "TimeServer: соединение закрыто клиентом" << endl;
                break;
            }
        }

        if (client->TimerOff == false && client->sthread != Contact::ABORT)
        {
            if (client->htimer != NULL) {
                CancelWaitableTimer(client->htimer);
            }

            // Отправляем сообщение о завершении только если соединение еще открыто
            if (client->s != INVALID_SOCKET)
            {
                if ((send(client->s, obuf, strlen(obuf) + 1, NULL)) == SOCKET_ERROR)
                {
                    // Если ошибка отправки, но это не критично
                    int error = WSAGetLastError();
                    if (error != WSAECONNRESET && error != WSAECONNABORTED)
                        throw SetErrorMsgText("Send:", WSAGetLastError());
                }
            }

            client->sthread = Contact::FINISH;
            QueueUserAPC(ASFinishMessage, client->hAcceptServer, (DWORD)client);

            cout << "TimeServer: корректно завершен для клиента "
                << inet_ntoa(client->prms.sin_addr) << endl;
        }
    }
    catch (string errorMsgText)
    {
        std::cout << "TimeServer ошибка: " << errorMsgText << std::endl;
        if (client->htimer != NULL) {
            CancelWaitableTimer(client->htimer);
        }
        client->sthread = Contact::ABORT;
    }

    ExitThread(rc);
}