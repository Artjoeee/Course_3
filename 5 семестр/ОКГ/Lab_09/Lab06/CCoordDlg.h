#pragma once
#include "afxdialogex.h"


// Диалоговое окно CCoordDlg

class CCoordDlg : public CDialogEx
{
	DECLARE_DYNAMIC(CCoordDlg)

public:
	CCoordDlg(CWnd* pParent = nullptr);   // стандартный конструктор
	virtual ~CCoordDlg();

// Данные диалогового окна
#ifdef AFX_DESIGN_TIME
	enum { IDD = IDD_COORD_DLG };
#endif

protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // поддержка DDX/DDV

	DECLARE_MESSAGE_MAP()
public:
	int m_r;
	int m_fi;
	int m_th;
};
