#pragma once

#ifdef _WIN64
#pragma comment(lib, "../x64/debug/OS10_HTAPI.lib")
#else
#pragma comment(lib, "../debug/OS10_HTAPI.lib")
#endif

#include "../OS10_HTAPI/pch.h"
#include "../OS10_HTAPI/HT.h"

using namespace ht;

namespace tests
{
	BOOL test1(HtHandle* htHandle);
	BOOL test2(HtHandle* htHandle);
	BOOL test3(HtHandle* htHandle);
	BOOL test4(HtHandle* htHandle);
	BOOL test5(HtHandle* htHandle);
}
