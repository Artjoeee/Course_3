#include "tests.h"

using namespace std;
using namespace ht;
using namespace tests;

int main()
{
	HtHandle* ht = create(1000, 3, 10, 256, L"./files/HTspace.ht");

	if (ht)
	{
		cout << "-- Create: success\n" << endl;
	}
	else
	{
		throw "-- Create: error\n";
	}

	if (test1(ht))
	{
		cout << "-- Test 1: success\n" << endl;
	}
	else
	{
		cout << "-- Test 1: error\n" << endl;
	}

	if (test2(ht))
	{
		cout << "-- Test 2: success\n" << endl;
	}
	else
	{
		cout << "-- Test 2: error\n" << endl;
	}

	if (test3(ht))
	{
		cout << "-- Test 3: success\n" << endl;
	}
	else
	{
		cout << "-- Test 3: error\n" << endl;
	}

	if (test4(ht))
	{
		cout << "-- Test 4: success\n" << endl;
	}
	else
	{
		cout << "-- Test 4: error\n" << endl;
	}

	if (test5(ht))
	{
		cout << "-- Test 5: success\n" << endl;
	}
	else
	{
		cout << "-- Test 5: error\n" << endl;
	}

	if (ht != nullptr)
	{
		if (close(ht))
		{
			cout << "-- Close: success\n" << endl;
		}
		else
		{
			throw "-- Close: error\n";
		}
	}
}