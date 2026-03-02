#include "pch.h"
#include <fstream>
#include <Windows.h>
#include <iostream>
#include <combaseapi.h>
#include "MathFactory.h"

using namespace std;

HMODULE hmodule;

// {EDBDA3B0-B55B-48DC-9BCB-D2AB6A75C834}
static const GUID CLSID_CA =
{ 0xedbda3b0, 0xb55b, 0x48dc, { 0x9b, 0xcb, 0xd2, 0xab, 0x6a, 0x75, 0xc8, 0x34 } };

const WCHAR* FNAME = L"OS12_COM.dll";
const WCHAR* VerInd = L"OS12_COM.1.0";
const WCHAR* ProgId = L"OS12_COM.1";

BOOL APIENTRY DllMain(
    HMODULE hModule,
    DWORD  ul_reason_for_call,
    LPVOID lpReserved
)
{
    switch (ul_reason_for_call)
    {
        case DLL_PROCESS_ATTACH:
            hmodule = hModule;
            break;
        case DLL_THREAD_ATTACH:
        case DLL_THREAD_DETACH:
        case DLL_PROCESS_DETACH:
            break;
    }

    return TRUE;
}

HRESULT __declspec(dllexport) DllInstall(bool b, PCWSTR s)
{
    return S_OK;
}

HRESULT __declspec(dllexport) DllRegisterServer() 
{
    return RegisterServer(hmodule, CLSID_CA, FNAME, VerInd, ProgId);
}

HRESULT __declspec(dllexport) DllUnregisterServer() 
{
    return UnregisterServer(CLSID_CA, VerInd, ProgId);
}

STDAPI DllCanUnloadNow()
{
    return S_OK;
}

STDAPI DllGetClassObject(const CLSID& clsid, const IID& iid, LPVOID* ppv) 
{
    HRESULT rc = E_UNEXPECTED;
    MathFactory* pF;

    if (clsid != CLSID_CA)
    {
        rc = CLASS_E_CLASSNOTAVAILABLE;
    }
    else if ((pF = new MathFactory()) == NULL)
    {
        rc = E_OUTOFMEMORY;
    }
    else 
    {
        rc = pF->QueryInterface(iid, ppv);
        pF->Release();
    }

    return rc;
}