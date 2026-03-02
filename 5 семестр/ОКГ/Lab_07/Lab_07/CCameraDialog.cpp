#include "stdafx.h"
#include "afxdialogex.h"
#include "CCameraDialog.h"
#include "resource.h"


// Диалоговое окно CCameraDialog

IMPLEMENT_DYNAMIC(CCameraDialog, CDialogEx)

CCameraDialog::CCameraDialog(CWnd* pParent /*=nullptr*/)
	: CDialogEx(IDD_CAMERADIALOG, pParent)
	, m_r(0)
	, m_fi(0)
	, m_teta(0)
{

}

CCameraDialog::~CCameraDialog()
{
}

void CCameraDialog::DoDataExchange(CDataExchange* pDX)
{
	CDialogEx::DoDataExchange(pDX);
	DDX_Text(pDX, IDC_EDIT_R, m_r);
	DDX_Text(pDX, IDC_EDIT_FI, m_fi);
	DDX_Text(pDX, IDC_EDIT_TETA, m_teta);
}



BEGIN_MESSAGE_MAP(CCameraDialog, CDialogEx)
END_MESSAGE_MAP()


// Обработчики сообщений CCameraDialog
