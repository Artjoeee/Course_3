#ifdef _WIN64
#pragma comment(lib, "../x64/debug/OS10_HTAPI.lib")
#else
#pragma comment(lib, "../debug/OS10_HTAPI.lib")
#endif

#include "../OS10_HTAPI/pch.h"
#include "../OS10_HTAPI/HT.h"

using namespace std;
using namespace ht;

int main()
{
    HtHandle* ht1 = nullptr;
    HtHandle* ht2 = nullptr;

    try
    {
        cout << "HT1" << endl;

        ht1 = create(1000, 3, 10, 256, L"./files/HTspace1.ht");

        if (ht1)
        {
            cout << "-- Create: success (HT1)" << endl;
        }
        else
        {
            throw "-- Create: error (HT1)";
        }

        if (insert(ht1, new Element("Key1", 5, "Artem", 15)))
        {
            cout << "-- Insert: success (HT1)" << endl;
        }
        else
        {
            throw "-- Insert: error (HT1)";
        }

        Element* hte = get(ht1, new Element("Key1", 5));

        if (hte)
        {
            cout << "-- Get: success (HT1)" << endl;
            print(hte);
        }
        else
        {
            throw "-- Get: error (HT1)";
        }
    }
    catch (const char* msg)
    {
        cout << msg << endl;

        if (ht1 != nullptr)
        {
            cout << getLastError(ht1) << endl;
        }
    }

    try
    {
        cout << "\nHT2" << endl;

        ht2 = open(L"./files/HTspace1.ht", true);

        if (ht2)
        {
            cout << "-- Open: success (HT2)" << endl;
        }
        else
        {
            throw "-- Open: error (HT2)";
        }

        Element* hte = get(ht2, new Element("Key1", 5));

        if (hte)
        {
            cout << "-- Get: success (HT2)" << endl;
            print(hte);
        }
        else
        {
            throw "-- Get: error (HT2)";
        }
    }
    catch (const char* msg)
    {
        cout << msg << endl;

        if (ht2 != nullptr)
        {
            cout << getLastError(ht2) << endl;
        }
    }

    try
    {
        if (ht1 != nullptr)
        {
            if (close(ht1))
            {
                cout << "-- Close: success (HT1)" << endl;
            }
            else
            {
                throw "-- Close: error (HT1)";
            }
        }

        if (ht2 != nullptr)
        {
            if (close(ht2))
            {
                cout << "-- Close: success (HT2)" << endl;
            }
            else
            {
                throw "-- Close: error (HT2)";
            }
        }
    }
    catch (const char* msg)
    {
        cout << msg << endl;
    }
}
