#pragma warning(disable : 4996)

#include <iostream>
#include <windows.h>
#include <string>
#include <sstream>
#include <ctime>

#include "../OS13_HTCOM_LIB/pch.h"
#include "../OS13_HTCOM_LIB/OS13_HTCOM_LIB.h"

#ifdef _WIN64
#pragma comment(lib, "../x64/Debug/OS13_HTCOM_LIB.lib")
#else
#pragma comment(lib, "../Debug/OS13_HTCOM_LIB.lib")
#endif

using namespace std;

string intToString(int number);

int main(int argc, char* argv[])
{
	HANDLE hStopEvent = CreateEvent(NULL, TRUE, FALSE, L"Stop");

	setlocale(LC_ALL, "RU");

	try
	{
		srand(static_cast<unsigned>(time(NULL)));

		OS13_HTCOM_HANDEL h = OS13_HTCOM::Init();

		ht::HtHandle* ht = OS13_HTCOM::HT::open(h, L"HTspace.ht", true);

		if (ht)
			cout << "-- Open: success" << endl;
		else
			throw "-- Open: error";

		while (WaitForSingleObject(hStopEvent, 0) == WAIT_TIMEOUT) 
		{
			int numberKey = rand() % 50;
			string key = intToString(numberKey);
			cout << key << endl;

			ht::Element* element = OS13_HTCOM::Element::createInsertElement(h, key.c_str(), key.length() + 1, "0", 2);

			if (OS13_HTCOM::HT::insert(h, ht, element))
				cout << "-- Insert: success" << endl;
			else
				cout << "-- Insert: error" << endl;

			delete element;

			Sleep(1000);
		}

		OS13_HTCOM::HT::close(h, ht);

		OS13_HTCOM::Dispose(h);
	}
	catch (const char* e) { cout << e << endl; }
	catch (int e) { cout << "HRESULT: " << e << endl; }
}

string intToString(int number)
{
	stringstream convert;
	convert << number;

	return convert.str();
}