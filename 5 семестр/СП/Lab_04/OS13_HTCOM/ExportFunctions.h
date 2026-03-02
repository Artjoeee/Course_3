#pragma once

extern HMODULE g_hModule;
extern const wchar_t* g_szFriendlyName;
extern const wchar_t* g_szVerIndProgID;
extern const wchar_t* g_szProgID;
extern long g_cComponents;
extern long g_cServerLocks;

STDAPI DllCanUnloadNow();

STDAPI DllGetClassObject(const CLSID& clsid, const IID& iid, void** ppv);

STDAPI DllRegisterServer();

STDAPI DllUnregisterServer();