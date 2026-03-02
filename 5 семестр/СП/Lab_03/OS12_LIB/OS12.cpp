#include "pch.h"
#include <Unknwn.h>
#include <stdexcept>
#include <iostream>
#include "../OS12_COM/IAdder.h"
#include "../OS12_COM/IMultiplier.h"

using namespace std;

static ULONG cObjects = 0;

#define IERR(s) cout << "error: " << s << endl;
#define IRES(s,r) cout << s << r << endl;

// {EDBDA3B0-B55B-48DC-9BCB-D2AB6A75C834}
static const GUID CLSID_CA =
{ 0xedbda3b0, 0xb55b, 0x48dc, { 0x9b, 0xcb, 0xd2, 0xab, 0x6a, 0x75, 0xc8, 0x34 } };

OS12LIB OS12::Init() 
{
	IUnknown* pIUnknown = nullptr;

	try 
	{
		if (cObjects == 0) 
		{
			if (FAILED(CoInitialize(NULL))) 
			{
				throw runtime_error("CoInitialize");
			}
		}

		if (FAILED(CoCreateInstance(CLSID_CA, NULL, CLSCTX_INPROC_SERVER, IID_IUnknown, (void**)&pIUnknown))) 
		{
			throw runtime_error("CreateInstance");
		}

		InterlockedIncrement(&cObjects);

		return pIUnknown;
	}
	catch (runtime_error error) 
	{
		IERR(error.what());
	}
}

double OS12::Adder::Add(OS12LIB h, double x, double y) 
{
	double z = 0.0;
	IAdder* pIAdder = nullptr;

	try 
	{
		if (FAILED(((IUnknown*)h)->QueryInterface(IID_IADDER, (void**)&pIAdder))) 
		{
			throw runtime_error("QueryInterface");
		}

		if (FAILED(pIAdder->Add(x, y, z)))
		{
			throw runtime_error("Add");
		}
	}
	catch (runtime_error error) 
	{
		IERR(error.what());
	}

	if (pIAdder != nullptr) 
	{
		pIAdder->Release();
	}

	return z;
}

double OS12::Adder::Sub(OS12LIB h, double x, double y) 
{
	double z = 0.0;
	IAdder* pIAdder = nullptr;

	try 
	{
		if (FAILED(((IUnknown*)h)->QueryInterface(IID_IADDER, (void**)&pIAdder))) 
		{
			throw runtime_error("QueryInterface");
		}

		if (FAILED(pIAdder->Sub(x, y, z)))
		{
			throw runtime_error("Sub");
		}

	}
	catch (runtime_error error) 
	{
		IERR(error.what());
	}

	if (pIAdder != nullptr) 
	{
		pIAdder->Release();
	}

	return z;
}

double OS12::Multiplier::Mul(OS12LIB h, double x, double y) 
{
	IMultiplier* pIMultiplier = nullptr;
	double z = 0.0;

	try 
	{
		if (FAILED(((IUnknown*)h)->QueryInterface(IID_IMULTIPLIER, (void**)&pIMultiplier))) 
		{
			throw runtime_error("QueryInterface");
		}

		if (FAILED(pIMultiplier->Mul(x, y, z)))
		{
			throw runtime_error("Mul");
		}

		pIMultiplier->Release();
	}
	catch (runtime_error error) 
	{
		IERR(error.what());
	}

	return z;
}

double OS12::Multiplier::Div(OS12LIB h, double x, double y) 
{
	try 
	{
		IMultiplier* pIMultiplier = nullptr;
		double z = 0.0;

		if (FAILED(((IUnknown*)h)->QueryInterface(IID_IMULTIPLIER, (void**)&pIMultiplier))) 
		{
			throw runtime_error("QueryInterface");
		}

		if (FAILED(pIMultiplier->Div(x, y, z)))
		{
			throw runtime_error("Div");
		}

		pIMultiplier->Release();

		return z;
	}
	catch (runtime_error error) 
	{
		IERR(error.what());
		return 0;
	}
}

void OS12::Dispose(OS12LIB h) 
{
	((IUnknown*)h)->Release();

	InterlockedDecrement(&cObjects);

	if (cObjects == 0)
	{
		CoFreeUnusedLibraries();
	}
}