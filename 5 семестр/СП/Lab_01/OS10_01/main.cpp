#include "HT.h"

using namespace std;
using namespace ht;

int main()
{
	HtHandle* ht = nullptr;

	try
	{
		ht = create(1000, 1, 20, 256, L"./files/HTspace.ht");

		if (ht)
		{
			cout << "-- Create: success" << endl;
		}	
		else 
		{
			throw "-- Create: error";
		}
			

		if (insert(ht, new Element("Key", 10, "Artem", 15)))
		{
			cout << "-- Insert: success" << endl;
		}
		else
		{
			throw "-- Insert: error";
		}

		Element* hte = get(ht, new Element("Key", 10));
		if (hte)
		{
			cout << "-- Get: success" << endl;
		}
		else
		{
			throw "-- Get: error";
		}

		print(hte);

		if (update(ht, hte, "Zhamoida", 20))
		{
			cout << "-- Update: success" << endl;
		}
		else
		{
			throw "-- Update: error";
		}

		if (snap(ht))
		{
			cout << "-- SnapSync: success" << endl;
		}
		else
		{
			throw "-- Snap: error";
		}

		hte = get(ht, new Element("Key", 10));
		if (hte)
		{
			cout << "-- Get: success" << endl;
		}
		else
		{
			throw "-- Get: error";
		}

		print(hte);

		SleepEx(3000, TRUE);

		if (remove(ht, hte))
		{
			cout << "-- Remove: success" << endl;
		}
		else
		{
			throw "-- Remove: error";
		}

		hte = get(ht, new Element("Key", 10));
		if (hte)
		{
			cout << "-- Get: success" << endl;
		}
		else
		{
			throw "-- Get: error";
		}
	}
	catch (const char* msg)
	{
		cout << msg << endl;

		if (ht != nullptr)
		{
			cout << getLastError(ht) << endl;
		}
	}

	try
	{
		if (ht != nullptr)
		{
			if (close(ht))
			{
				cout << "-- Close: success" << endl;
			}
			else
			{
				throw "-- Close: error";
			}
		}
	}
	catch (const char* msg)
	{
		cout << msg << endl;
	}

}