#pragma once
#include <iostream>
#include "Global.h"

using namespace std;

template <typename typed, size_t n>
int lenght(typed(&a)[n])
{
    int counter = 0;
    for (size_t q = 0; q < n; ++q)
        counter++;
    return counter;
}

DWORD WINAPI RandServer(LPVOID lParam)
{
    DWORD rc = 0;
    Contact* client = (Contact*)lParam;
    QueueUserAPC(ASStartMessage, client->hAcceptServer, (DWORD)client);

    try
    {
        client->sthread = Contact::WORK;
        int bytes = 1;
        char ibuf[50], obuf[50] = "Close: finish;", Rand[50] = "Rand";

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

                // ПРОВЕРКА КОМАНД ЗАВЕРШЕНИЯ
                if (ibuf[0] == '0' || !strcmp(ibuf, "exit"))
                {
                    cout << "RandServer: получена команда завершения: " << ibuf << endl;
                    break;
                }

                if (client->TimerOff != false)
                {
                    break;
                }

                // Генерация случайного числа
                srand((unsigned int)time(NULL));
                int RandNumber = rand() % 100000;  // Число от 0 до 99999
                sprintf(ibuf, "%s: %d", Rand, RandNumber);

                if ((send(client->s, ibuf, strlen(ibuf) + 1, NULL)) == SOCKET_ERROR)
                    throw SetErrorMsgText("Send:", WSAGetLastError());

                cout << "RandServer: отправлено число " << RandNumber
                    << " клиенту " << inet_ntoa(client->prms.sin_addr) << endl;
            }
            else if (bytes == 0)
            {
                // Соединение закрыто клиентом
                cout << "RandServer: соединение закрыто клиентом" << endl;
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

            cout << "RandServer: корректно завершен для клиента "
                << inet_ntoa(client->prms.sin_addr) << endl;
        }
    }
    catch (string errorMsgText)
    {
        std::cout << "RandServer ошибка: " << errorMsgText << std::endl;
        if (client->htimer != NULL) {
            CancelWaitableTimer(client->htimer);
        }
        client->sthread = Contact::ABORT;
    }

    ExitThread(rc);
}