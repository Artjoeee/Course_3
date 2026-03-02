#include "stdafx.h"
#include "Lab06.h"
#include "CCameraDlg.h"


IMPLEMENT_DYNAMIC(CCameraDlg, CDialog)

BEGIN_MESSAGE_MAP(CCameraDlg, CDialog)
END_MESSAGE_MAP()


CCameraDlg::CCameraDlg(CWnd* pParent /*=nullptr*/)
    : CDialog(IDD_CAMERA_DLG, pParent), m_r(50), m_fi(30), m_q(45)
{
}

CCameraDlg::~CCameraDlg()
{
}

void CCameraDlg::DoDataExchange(CDataExchange* pDX)
{
    CDialog::DoDataExchange(pDX);
    DDX_Text(pDX, IDC_EDIT_R, m_r);
    DDV_MinMaxInt(pDX, m_r, 1, 10000);    // пример: r > 0
    DDX_Text(pDX, IDC_EDIT_FI, m_fi);
    DDV_MinMaxInt(pDX, m_fi, 0, 360);
    DDX_Text(pDX, IDC_EDIT_Q, m_q);
    DDV_MinMaxInt(pDX, m_q, 0, 180);
}

BOOL CCameraDlg::OnInitDialog()
{
    CDialog::OnInitDialog();
    // можно здесь установить подсказки или ограничение символов:
    // GetDlgItem(IDC_EDIT_R)->SendMessage(EM_SETLIMITTEXT, 6);
    return TRUE;
}

void CCameraDlg::OnOK()
{
    if (!UpdateData(TRUE)) {
        // если DDX/DDV не прошёл — ничего не применяем
        return;
    }

    // Дополнительная ручная валидация (если нужно)
    if (m_r <= 0) {
        AfxMessageBox(L"r должен быть положительным числом.");
        return;
    }
    if (m_fi < 0 || m_fi > 360) {
        AfxMessageBox(L"fi должно быть в диапазоне 0..360.");
        return;
    }
    if (m_q < 0 || m_q > 180) {
        AfxMessageBox(L"q должно быть в диапазоне 0..180.");
        return;
    }

    CDialog::OnOK(); // закроет диалог с IDOK
}
