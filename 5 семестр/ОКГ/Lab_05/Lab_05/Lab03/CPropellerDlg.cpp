#include "stdafx.h"
#include "Lab05.h"
#include "CPropellerDlg.h"
#include "afxdialogex.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#endif

CPropellerDlg::CPropellerDlg(CWnd* pParent /*=nullptr*/)
    : CDialogEx(IDD_PROPELLER_DLG, pParent)
    , m_bladeCount(4)
    , m_speed(1.0)
    , m_direction(0)
{
}

void CPropellerDlg::DoDataExchange(CDataExchange* pDX)
{
    CDialogEx::DoDataExchange(pDX);
    DDX_Text(pDX, IDC_EDIT_BLADE_COUNT, m_bladeCount);
    DDX_Text(pDX, IDC_EDIT_SPEED, m_speed);
}


BEGIN_MESSAGE_MAP(CPropellerDlg, CDialogEx)
    ON_BN_CLICKED(IDOK, &CPropellerDlg::OnBnClickedOk)
    ON_BN_CLICKED(IDC_RADIO_CW, &CPropellerDlg::OnBnClickedRadioCw)
    ON_BN_CLICKED(IDC_RADIO_CCW, &CPropellerDlg::OnBnClickedRadioCcw)
END_MESSAGE_MAP()

void CPropellerDlg::OnBnClickedRadioCw()
{
    // При выборе CW снимаем выбор с CCW
    CheckDlgButton(IDC_RADIO_CCW, BST_UNCHECKED);
    m_direction = 0;
}

void CPropellerDlg::OnBnClickedRadioCcw()
{
    // При выборе CCW снимаем выбор с CW
    CheckDlgButton(IDC_RADIO_CW, BST_UNCHECKED);
    m_direction = 1;
}


BOOL CPropellerDlg::OnInitDialog()
{
    CDialogEx::OnInitDialog();

    // Устанавливаем по умолчанию
    CheckDlgButton(IDC_RADIO_CW, BST_CHECKED);
    CheckDlgButton(IDC_RADIO_CCW, BST_UNCHECKED);
    m_direction = 0;

    SetDlgItemInt(IDC_EDIT_BLADE_COUNT, m_bladeCount);
    SetDlgItemText(IDC_EDIT_SPEED, L"1");

    return TRUE;
}

void CPropellerDlg::OnBnClickedOk()
{
    if (!UpdateData(TRUE))
        return;

    // Валидация
    if (m_bladeCount <= 0) {
        MessageBox(L"Введите положительное количество лопастей.", L"Ошибка", MB_ICONERROR);
        return;
    }

    if (m_speed <= 0) {
        MessageBox(L"Введите положительную скорость вращения.", L"Ошибка", MB_ICONERROR);
        return;
    }

    CDialogEx::OnOK();
}