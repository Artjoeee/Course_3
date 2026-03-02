#include "pch.h"
#include "ExportFunctions.h"
#include "Registry.h"
#include "ClassFactory.h"

STDAPI DllCanUnloadNow()
{
	if ((g_cComponents == 0) && (g_cServerLocks == 0))
	{
		return S_OK;
	}
	else
	{
		return S_FALSE;
	}
}

STDAPI DllGetClassObject(const CLSID& clsid,
	const IID& iid,
	void** ppv)
{
	// Можно ли создать такой компонент?
	if (clsid != CLSID_ComponentHT)
	{
		return CLASS_E_CLASSNOTAVAILABLE;
	}
	// Создать фабрику класса
	ClassFactory* pFactory = new ClassFactory; // Счетчик ссылок устанавливается в конструкторе в 1
	if (pFactory == NULL)
	{
		return E_OUTOFMEMORY;
	}
	// Получить требуемый интерфейс
	HRESULT hr = pFactory->QueryInterface(iid, ppv);
	pFactory->Release();

	return hr;
}

STDAPI DllRegisterServer()
{
	return RegisterServer(g_hModule,
		CLSID_ComponentHT,
		g_szFriendlyName,
		g_szVerIndProgID,
		g_szProgID);
}

STDAPI DllUnregisterServer()
{
	return UnregisterServer(CLSID_ComponentHT,
		g_szVerIndProgID,
		g_szProgID);
}