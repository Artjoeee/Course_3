#pragma once
#include "Global.h"
#include <WS2tcpip.h>

DWORD WINAPI GarbageCleaner(LPVOID pPrm)
{
    cout << "GarbageCleaner started;\n" << endl;
    DWORD rc = 0;

    try
    {
        volatile TalkersCmd* cmd = (volatile TalkersCmd*)pPrm;

        while (true)
        {
            // ПЕРВОЕ: проверяем команду Exit
            if (*cmd == Exit)
            {
                cout << "GarbageCleaner: Exit command detected! Starting emergency cleanup..." << endl;

                EnterCriticalSection(&scListContact);

                int clientCount = 0;

                for (auto& client : Contacts)
                {
                    clientCount++;

                    // Закрываем сокет
                    if (client.s != INVALID_SOCKET)
                    {
                        shutdown(client.s, SD_BOTH);
                        closesocket(client.s);
                        client.s = INVALID_SOCKET;
                    }

                    // Закрываем таймер
                    if (client.htimer != NULL)
                    {
                        CancelWaitableTimer(client.htimer);
                        CloseHandle(client.htimer);
                        client.htimer = NULL;
                    }

                    // Закрываем поток
                    if (client.hthread != NULL)
                    {
                        WaitForSingleObject(client.hthread, 100);
                        CloseHandle(client.hthread);
                        client.hthread = NULL;
                    }
                }

                // Очищаем список и статистику
                Contacts.clear();
                Work = 0;

                LeaveCriticalSection(&scListContact);

                cout << "GarbageCleaner: Emergency cleanup completed! Removed "
                    << clientCount << " clients." << endl;
                break;
            }

            // ВТОРОЕ: обычная очистка завершенных клиентов
            EnterCriticalSection(&scListContact);

            auto it = Contacts.begin();
            while (it != Contacts.end())
            {
                Contact& client = *it;
                bool shouldDelete = false;

                // Проверяем статусы, которые требуют удаления
                if (client.sthread == Contact::FINISH ||
                    client.sthread == Contact::TIMEOUT ||
                    client.sthread == Contact::ABORT ||
                    client.type == Contact::EMPTY)
                {
                    shouldDelete = true;
                }
                // Проверяем состояние сокета для активных клиентов
                else if (client.s != INVALID_SOCKET)
                {
                    // Быстрая проверка сокета
                    fd_set readSet;
                    FD_ZERO(&readSet);
                    FD_SET(client.s, &readSet);

                    timeval timeout;
                    timeout.tv_sec = 0;
                    timeout.tv_usec = 0;  // Немедленный возврат

                    int result = select(0, &readSet, NULL, NULL, &timeout);

                    if (result == SOCKET_ERROR)
                    {
                        // Ошибка сокета
                        client.sthread = Contact::ABORT;
                        shouldDelete = true;
                    }
                    else if (result > 0)
                    {
                        // Есть данные для чтения - проверяем, не закрыто ли соединение
                        char buffer[1];
                        int bytes = recv(client.s, buffer, sizeof(buffer), MSG_PEEK);


                        if (bytes == 0)
                        {
                            // Соединение закрыто
                            client.sthread = Contact::ABORT;
                            shouldDelete = true;
                        }
                        else if (bytes == SOCKET_ERROR)
                        {
                            int error = WSAGetLastError();
                            if (error == WSAECONNRESET || error == WSAECONNABORTED ||
                                error == WSAENOTCONN || error == WSAENOTSOCK)
                            {
                                client.sthread = Contact::ABORT;
                                shouldDelete = true;
                            }
                        }
                    }
                }

                if (shouldDelete)
                {
                    // Обновляем статистику
                    if (client.type == Contact::EMPTY)
                    {
                        InterlockedIncrement(&Fail);
                    }
                    else if (client.sthread == Contact::FINISH)
                    {
                        InterlockedIncrement(&Finished);
                    }
                    else if (client.sthread == Contact::TIMEOUT ||
                        client.sthread == Contact::ABORT)
                    {
                        InterlockedIncrement(&Fail);
                    }

                    // Освобождаем ресурсы
                    if (client.s != INVALID_SOCKET)
                    {
                        shutdown(client.s, SD_BOTH);
                        closesocket(client.s);
                        client.s = INVALID_SOCKET;
                    }

                    if (client.htimer != NULL)
                    {
                        CancelWaitableTimer(client.htimer);
                        CloseHandle(client.htimer);
                        client.htimer = NULL;
                    }

                    if (client.hthread != NULL)
                    {
                        WaitForSingleObject(client.hthread, 100);
                        CloseHandle(client.hthread);
                        client.hthread = NULL;
                    }

                    // Удаляем из списка
                    it = Contacts.erase(it);
                    InterlockedDecrement(&Work);
                }
                else
                {
                    ++it;
                }
            }

            LeaveCriticalSection(&scListContact);

            Sleep(500);  // Проверяем каждые 500 мс
        }
    }
    catch (const string& errorMsgText)
    {
        cout << "GarbageCleaner error: " << errorMsgText << endl;
    }
    catch (...)
    {
        cout << "GarbageCleaner: Unknown error occurred" << endl;
    }

    cout << "GarbageCleaner stopped;\n" << endl;
    ExitThread(rc);
}
