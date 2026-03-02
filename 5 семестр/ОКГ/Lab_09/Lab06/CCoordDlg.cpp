// CCoordDlg.cpp: файл реализации
//
#include "stdafx.h"
#include "afxdialogex.h"
#include "CCoordDlg.h"
#include "resource.h"


IMPLEMENT_DYNAMIC(CCoordDlg, CDialogEx)

BEGIN_MESSAGE_MAP(CCoordDlg, CDialogEx)
END_MESSAGE_MAP()

CCoordDlg::CCoordDlg(CWnd* pParent)
    : CDialogEx(IDD_COORD_DLG, pParent),
    m_r(10), m_fi(45), m_th(45)
{
}

CCoordDlg::~CCoordDlg()
{
}

void CCoordDlg::DoDataExchange(CDataExchange* pDX)
{
    CDialogEx::DoDataExchange(pDX);

    DDX_Text(pDX, IDC_EDIT_R, m_r);
    DDV_MinMaxDouble(pDX, m_r, 1, 1000);

    DDX_Text(pDX, IDC_EDIT_FI, m_fi);
    DDV_MinMaxDouble(pDX, m_fi, -360, 360);

    DDX_Text(pDX, IDC_EDIT_TH, m_th);
    DDV_MinMaxDouble(pDX, m_th, 0, 180);
}