#pragma once

#include <objbase.h>
#include <Unknwn.h>

// {30F297A4-DB3F-44AE-AB96-AF42E4E59EFB}
static const GUID IID_IMULTIPLIER =
{ 0x30f297a4, 0xdb3f, 0x44ae, { 0xab, 0x96, 0xaf, 0x42, 0xe4, 0xe5, 0x9e, 0xfb } };

__interface IMultiplier : IUnknown 
{
	virtual HRESULT __stdcall Mul(const double, const double, double&) = 0;
	virtual HRESULT __stdcall Div(const double, const double, double&) = 0;
};