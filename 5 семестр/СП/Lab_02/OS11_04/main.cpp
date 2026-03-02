#ifdef _WIN64
#pragma comment(lib, "../x64/debug/OS11_HTAPI.lib")
#else
#pragma comment(lib, "../debug/OS11_HTAPI.lib")
#endif

#include <string>
#include <sstream>
#include <ctime>
#include "../OS11_HTAPI/pch.h"
#include "../OS11_HTAPI/HT.h"

using namespace std;
using namespace ht;

string intToString(int number);
int charToInt(char* str);
string incrementPayload(char* str);

int main(int argc, char* argv[])
{
	setlocale(LC_ALL, "RU");

	try
	{
		srand(static_cast<unsigned>(time(NULL)));

		HtHandle* ht = open(L"HTspace.ht", true);

		if (ht)
		{
			cout << "-- Open: success" << endl;
		}
		else
		{
			throw "-- Open: error";
		}

		while (true) 
		{
			HANDLE ownerEvent = OpenEvent(SYNCHRONIZE, FALSE, L"HTspace.ht_OWNER");

			if (!ownerEvent)
			{
				cout << "Ошибка: OS11_START завершил работу.\n";
				break;
			}

			CloseHandle(ownerEvent);

			int numberKey = rand() % 50;

			string key = intToString(numberKey);
			cout << key << endl;

			Element* element = get(ht, new Element(key.c_str(), key.length() + 1));

			if (element)
			{
				cout << "-- Get: success" << endl;

				string newPayload = incrementPayload((char*)element->payload);

				if (update(ht, element, newPayload.c_str(), newPayload.length() + 1))
				{
					cout << "-- Update: success" << endl;
				}
				else
				{
					cout << "-- Update: error" << endl;
				}
			}
			else
			{
				cout << "-- Get: error" << endl;
			}

			Sleep(1000);
		}
	}
	catch (const char* msg)
	{
		cout << msg << endl;
	}
}

string intToString(int number)
{
	stringstream convert;
	convert << number;

	return convert.str();
}

int charToInt(char* str)
{
	stringstream convert;
	convert << str;

	int num;
	convert >> num;

	return num;
}

string incrementPayload(char* str)
{
	int oldNumberPayload = charToInt(str);
	int newNumberPayload = oldNumberPayload + 1;

	string newPayload = intToString(newNumberPayload);

	return newPayload;
}
