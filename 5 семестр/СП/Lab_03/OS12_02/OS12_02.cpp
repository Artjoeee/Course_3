#include <iostream>
#include <Unknwn.h>
#include "../OS12_COM/IAdder.h"
#include "../OS12_COM/IMultiplier.h"

using namespace std;

#define IERR(s) cout << "error: " << s << endl;
#define IRES(s,r) cout << s << r << endl;

IAdder* pIAdder = nullptr;
IMultiplier* pIMultiplier = nullptr;

// {EDBDA3B0-B55B-48DC-9BCB-D2AB6A75C834}
static const GUID CLSID_CA =
{ 0xedbda3b0, 0xb55b, 0x48dc, { 0x9b, 0xcb, 0xd2, 0xab, 0x6a, 0x75, 0xc8, 0x34 } };

int main()
{
	IUnknown* pIUnknown = NULL;

	CoInitialize(NULL);

	HRESULT hr0 = CoCreateInstance(CLSID_CA, NULL, CLSCTX_INPROC_SERVER, IID_IUnknown, (void**)&pIUnknown);

	if (SUCCEEDED(hr0))
	{
		cout << "CoCreateInstance succeeded" << endl;

		if (SUCCEEDED(pIUnknown->QueryInterface(IID_IADDER, (void**)&pIAdder)))
		{
			{
				double z = 0.0;

				if (!SUCCEEDED(pIAdder->Add(2.0, 3.0, z)))
				{
					IERR("IAdder::Add")
				}
				else
				{
					IRES("IAdder::Add = ", z)
				}
			}
			{
				double z = 0.0;

				if (!SUCCEEDED(pIAdder->Sub(2.0, 3.0, z)))
				{
					IERR("IAdder::Sub")
				}
				else
				{
					IRES("IAdder::Sub = ", z)
				}
			}
			if (SUCCEEDED(pIAdder->QueryInterface(IID_IMULTIPLIER, (void**)&pIMultiplier)))
			{
				{
					double z = 0.0;

					if (!SUCCEEDED(pIMultiplier->Mul(2.0, 3.0, z)))
					{
						IERR("IMultiplier::Mul")
					}
					else
					{
						IRES("Multiplier::Mul = ", z)
					}
				}
				{
					double z = 0.0;

					if (!SUCCEEDED(pIMultiplier->Div(2.0, 3.0, z)))
					{
						IERR("IMultiplier::Div")
					}
					else
					{
						IRES("IMultiplier::Div = ", z)
					}
				}
				if (SUCCEEDED(pIMultiplier->QueryInterface(IID_IADDER, (void**)&pIAdder)))
				{
					double z = 0.0;

					if (!SUCCEEDED(pIAdder->Add(2.0, 3.0, z)))
					{
						IERR("IAdder::Add")
					}
					else
					{
						IRES("IAdder::Add = ", z)
					}

					pIAdder->Release();
				}
				else
				{
					IERR("IMultiplier->IAdder")
				}

				pIMultiplier->Release();
			}
			else
			{
				IERR("IAdder->IMultiplier");
			}

			pIAdder->Release();
		}
		else
		{
			IERR("IAdder");
		}
	}
	else
	{
		cout << "CoCreateInstance error" << endl;
	}

	pIUnknown->Release();

	CoFreeUnusedLibraries();    

	return 0;
}
