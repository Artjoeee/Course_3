#pragma once
#include "afxdialogex.h"


// Диалоговое окно CCameraDialog

class CCameraDialog : public CDialogEx
{
	DECLARE_DYNAMIC(CCameraDialog)

public:
	CCameraDialog(CWnd* pParent = nullptr);   // стандартный конструктор
	virtual ~CCameraDialog();

// Данные диалогового окна
#ifdef AFX_DESIGN_TIME
	enum { IDD = IDD_CAMERADIALOG };
#endif

protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // поддержка DDX/DDV

	DECLARE_MESSAGE_MAP()
public:
	int m_r;
	int m_fi;
	int m_teta;
};
