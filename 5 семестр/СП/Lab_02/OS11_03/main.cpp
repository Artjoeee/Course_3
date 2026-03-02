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

			Element* element = new Element(key.c_str(), key.length() + 1);

			if (Remove(ht, element))
			{
				cout << "-- Remove: success" << endl;
			}
			else
			{
				cout << "-- Remove: error" << endl;
			}

			delete element;

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
