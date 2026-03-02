#pragma once
#include "Global.h"
#include <iostream>

using namespace std;

DWORD WINAPI EchoServer(LPVOID lParam)
{
    DWORD rc = 0;
    Contact* client = (Contact*)lParam;
    QueueUserAPC(ASStartMessage, client->hAcceptServer, (DWORD)client);

    try
    {
        client->sthread = Contact::WORK;
        int bytes = 1;
        char ibuf[50], obuf[50] = "Close: finish;";

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
                ibuf[bytes] = '\0';  // завершаем строку

                // Проверяем команды завершения
                if (ibuf[0] == '0' || !strcmp(ibuf, "exit"))
                {
                    cout << "EchoServer: получена команда завершения: " << ibuf << endl;
                    break;
                }

                if (client->TimerOff != false)
                {
                    break;
                }

                if ((send(client->s, ibuf, strlen(ibuf) + 1, NULL)) == SOCKET_ERROR)
                    throw SetErrorMsgText("Send:", WSAGetLastError());

                cout << "EchoServer: отправлен эхо клиенту "
                    << inet_ntoa(client->prms.sin_addr) << ": " << ibuf << endl;
            }
            else if (bytes == 0) 
            {
                // Соединение закрыто клиентом
                cout << "EchoServer: соединение закрыто клиентом" << endl;
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

            client->sthread = Contact::FINISH;  // FINISH
            QueueUserAPC(ASFinishMessage, client->hAcceptServer, (DWORD)client);

            cout << "EchoServer: корректно завершен для клиента "
                << inet_ntoa(client->prms.sin_addr) << endl;
        }
    }
    catch (string errorMsgText)
    {
        std::cout << "EchoServer ошибка: " << errorMsgText << std::endl;
        if (client->htimer != NULL) {
            CancelWaitableTimer(client->htimer);
        }
        client->sthread = Contact::ABORT;
    }

    ExitThread(rc);
}