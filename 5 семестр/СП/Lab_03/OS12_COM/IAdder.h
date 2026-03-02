#pragma once

#include <objbase.h>
#include <Unknwn.h>

// {DCEEB2CB-AB59-45CD-9E18-F3BE57E21641}
static const GUID IID_IADDER =
{ 0xdceeb2cb, 0xab59, 0x45cd, { 0x9e, 0x18, 0xf3, 0xbe, 0x57, 0xe2, 0x16, 0x41 } };

__interface IAdder : IUnknown 
{
	virtual HRESULT __stdcall Add(const double, const double, double&) = 0;
	virtual HRESULT __stdcall Sub(const double, const double, double&) = 0;
};