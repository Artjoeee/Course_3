#pragma once
#include "Global.h"

DWORD WINAPI ResponseServer(LPVOID pPrm)
{
    DWORD rc = 0;
    SOCKET ServerSocket = INVALID_SOCKET;
    WSADATA wsaData;
    cout << "ResponseServer started on port " << uport << ";\n" << endl;

    try
    {
        if (WSAStartup(MAKEWORD(2, 0), &wsaData) != 0)
            throw SetErrorMsgText("Startup:", WSAGetLastError());

        SOCKADDR_IN From = { AF_INET };
        int FromLen = sizeof(From);
        SOCKADDR_IN serv;
        serv.sin_family = AF_INET;
        serv.sin_port = htons(uport);
        serv.sin_addr.s_addr = INADDR_ANY;

        if ((ServerSocket = socket(AF_INET, SOCK_DGRAM, 0)) == INVALID_SOCKET)
            throw SetErrorMsgText("Socket:", WSAGetLastError());

        // Устанавливаем опцию broadcast
        int broadcast = 1;
        if (setsockopt(ServerSocket, SOL_SOCKET, SO_BROADCAST,
            (char*)&broadcast, sizeof(broadcast)) == SOCKET_ERROR)
            cout << "Warning: Cannot set broadcast option" << endl;

        // Устанавливаем неблокирующий режим
        u_long nonblk = 1;
        if (ioctlsocket(ServerSocket, FIONBIO, &nonblk) == SOCKET_ERROR)
            throw SetErrorMsgText("Ioctlsocket:", WSAGetLastError());

        if (bind(ServerSocket, (LPSOCKADDR)&serv, sizeof(serv)) == SOCKET_ERROR)
            throw SetErrorMsgText("Bind:", WSAGetLastError());

        cout << "ResponseServer: Waiting for broadcast messages...\n" << endl;

        volatile TalkersCmd* cmd = (volatile TalkersCmd*)pPrm;

        while (*cmd != Exit)
        {
            char ibuf[50] = { 0 };
            int bytesReceived = 0;

            // Сбрасываем структуру From перед каждым вызовом
            From.sin_family = AF_INET;
            FromLen = sizeof(From);

            bytesReceived = recvfrom(ServerSocket, ibuf, sizeof(ibuf) - 1, 0,
                (LPSOCKADDR)&From, &FromLen);

            if (bytesReceived == SOCKET_ERROR)
            {
                int lastError = WSAGetLastError();

                switch (lastError)
                {
                case WSAEWOULDBLOCK:
                    // Нет данных - обычная ситуация для неблокирующего сокета
                    SleepEx(10, TRUE);
                    break;

                case WSAECONNRESET:
                    // UDP может иногда получать эту ошибку, игнорируем её
                    // Это происходит, когда клиент не ожидает ответа или завершился
                    // Это не критично для UDP широковещательного сервера
                    // Просто продолжаем работу
                    break;

                case WSAECONNABORTED:
                    // Соединение прервано - тоже не критично для UDP
                    break;

                default:
                    // Другие ошибки логируем, но не завершаем работу
                    cout << "ResponseServer: Warning - recvfrom error "
                        << lastError << " (non-fatal)" << endl;
                    break;
                }
            }
            else if (bytesReceived > 0)
            {
                ibuf[bytesReceived] = '\0';  // Гарантируем нуль-терминацию

                // Логируем полученное сообщение
                cout << "ResponseServer: Received from "
                    << inet_ntoa(From.sin_addr)
                    << " message: \"" << ibuf << "\"" << endl;

                // Проверяем, соответствует ли сообщение нашему call sign
                if (strcmp(ibuf, ucall) == 0)
                {
                    cout << "ResponseServer: Sending response to "
                        << inet_ntoa(From.sin_addr) << endl;

                    // Отправляем ответ
                    int bytesSent = sendto(ServerSocket, ucall, strlen(ucall) + 1, 0,
                        (LPSOCKADDR)&From, FromLen);

                    if (bytesSent == SOCKET_ERROR)
                    {
                        int sendError = WSAGetLastError();


                        // Игнорируем ошибки отправки, связанные с недоступностью клиента
                        if (sendError != WSAECONNRESET &&
                            sendError != WSAECONNABORTED &&
                            sendError != WSAENETUNREACH &&
                            sendError != WSAEHOSTUNREACH)
                        {
                            // Логируем только серьезные ошибки
                            cout << "ResponseServer: Warning - sendto error "
                                << sendError << endl;
                        }
                    }
                    else
                    {
                        cout << "ResponseServer: Response sent\n" << endl;
                    }
                }
            }
            else if (bytesReceived == 0)
            {
                // Для UDP recvfrom редко возвращает 0, но обработаем на всякий случай
                // Это может означать датаграмму нулевой длины
            }

            // Небольшая пауза для снижения нагрузки на CPU
            SleepEx(1, TRUE);
        }

        // Корректное завершение
        cout << "ResponseServer: Shutting down..." << endl;

        if (ServerSocket != INVALID_SOCKET)
        {
            if (closesocket(ServerSocket) == SOCKET_ERROR)
            {
                cout << "ResponseServer: Warning - closesocket error "
                    << WSAGetLastError() << endl;
            }
            ServerSocket = INVALID_SOCKET;
        }

        if (WSACleanup() == SOCKET_ERROR)
        {
            cout << "ResponseServer: Warning - WSACleanup error "
                << WSAGetLastError() << endl;
        }
    }
    catch (const string& errorMsgText)
    {
        cout << "ResponseServer: Exception - " << errorMsgText << endl;
    }
    catch (...)
    {
        cout << "ResponseServer: Unknown exception occurred" << endl;
    }

    cout << "ResponseServer stopped;\n" << endl;
    ExitThread(rc);
}
