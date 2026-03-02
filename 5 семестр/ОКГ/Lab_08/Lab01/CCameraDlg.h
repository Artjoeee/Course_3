#pragma once
#include "afxdialogex.h"


// Диалоговое окно CCameraDlg

class CCameraDlg : public CDialog
{
	DECLARE_DYNAMIC(CCameraDlg)

public:
	CCameraDlg(CWnd* pParent = nullptr);   // стандартный конструктор
	virtual ~CCameraDlg();

// Данные диалогового окна
#ifdef AFX_DESIGN_TIME
	enum { IDD = IDD_CAMERA_DLG };
#endif

protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // поддержка DDX/DDV

	DECLARE_MESSAGE_MAP()
public:
	int m_fi;
	int m_r;
	int m_q;

	virtual BOOL OnInitDialog() override;
	virtual void OnOK() override;
};
