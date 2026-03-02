#ifdef _WIN64
#pragma comment(lib, "../x64/debug/OS11_HTAPI.lib")
#else
#pragma comment(lib, "../debug/OS11_HTAPI.lib")
#endif

#include "../OS11_HTAPI/pch.h"
#include "../OS11_HTAPI/HT.h"

using namespace std;
using namespace ht;

wchar_t* getWChar_t(const char* c);

int main(int argc, char* argv[])
{
	HtHandle* ht = nullptr;

	ht = create(atoi(argv[1]), atoi(argv[2]), atoi(argv[3]), atoi(argv[4]), getWChar_t(argv[5]));

	if (ht)
	{
		cout << "HT-Storage Created" << endl;
		wcout << "filename: " << ht->fileName << endl;
		cout << "secSnapshotInterval: " << ht->secSnapshotInterval << endl;
		cout << "capacity: " << ht->capacity << endl;
		cout << "maxKeyLength: " << ht->maxKeyLength << endl;
		cout << "maxPayloadLength: " << ht->maxPayloadLength << endl;

		close(ht);
	}
	else
	{
		cout << "-- Create: error" << endl;
	}
}

wchar_t* getWChar_t(const char* c)
{
	wchar_t* wc = new wchar_t[strlen(c) + 1];

	mbstowcs(wc, c, strlen(c) + 1);

	return wc;
}
