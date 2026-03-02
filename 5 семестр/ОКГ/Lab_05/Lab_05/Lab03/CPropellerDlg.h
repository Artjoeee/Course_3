////////////#pragma once
////////////#include "afxdialogex.h"
////////////
////////////
////////////// Диалоговое окно CPropellerDlg
////////////
////////////class CPropellerDlg : public CDialogEx
////////////{
////////////	DECLARE_DYNAMIC(CPropellerDlg)
////////////
////////////public:
////////////	CPropellerDlg(CWnd* pParent = nullptr);   // стандартный конструктор
////////////	virtual ~CPropellerDlg();
////////////
////////////// Данные диалогового окна
////////////#ifdef AFX_DESIGN_TIME
////////////	enum { IDD = IDD_PROPELLER_DLG };
////////////#endif
////////////
////////////protected:
////////////	virtual void DoDataExchange(CDataExchange* pDX);    // поддержка DDX/DDV
////////////
////////////	DECLARE_MESSAGE_MAP()
////////////};
//////////#pragma once
//////////
//////////class CPropellerDlg : public CDialogEx
//////////{
//////////    DECLARE_DYNAMIC(CPropellerDlg)
//////////
//////////public:
//////////    CPropellerDlg(CWnd* pParent = nullptr);
//////////
//////////#ifdef AFX_DESIGN_TIME
//////////    enum { IDD = IDD_PROPELLER_DLG };
//////////#endif
//////////
//////////protected:
//////////    virtual void DoDataExchange(CDataExchange* pDX);
//////////
//////////public:
//////////    int m_bladeCount;
//////////    double m_speed;
//////////    int m_direction; // 0 = CW, 1 = CCW
//////////    afx_msg void OnBnClickedRadio1();
//////////    afx_msg void OnBnClickedOk();
//////////};
////////#pragma once
////////#include "afxdialogex.h"
////////
////////class CPropellerDlg : public CDialogEx
////////{
////////    DECLARE_DYNAMIC(CPropellerDlg)
////////
////////public:
////////    CPropellerDlg(CWnd* pParent = nullptr);
////////
////////#ifdef AFX_DESIGN_TIME
////////    enum { IDD = IDD_PROPELLER_DLG };
////////#endif
////////
////////protected:
////////    virtual void DoDataExchange(CDataExchange* pDX);
////////
////////    DECLARE_MESSAGE_MAP()
////////
////////public:
////////    // --- переменные модели ---
////////    int m_bladeCount;
////////    double m_speed;
////////    BOOL m_isClockwise;
////////
////////    // --- обработчики ---
////////    afx_msg void OnBnClickedOk();
////////};
//////
//////
//////#pragma once
//////#include "afxdialogex.h"
//////
//////class CPropellerDlg : public CDialogEx
//////{
//////    DECLARE_DYNAMIC(CPropellerDlg)
//////
//////public:
//////    CPropellerDlg(CWnd* pParent = nullptr);
//////
//////#ifdef AFX_DESIGN_TIME
//////    enum { IDD = IDD_PROPELLER_DLG };
//////#endif
//////
//////protected:
//////    virtual void DoDataExchange(CDataExchange* pDX);    // поддержка DDX/DDV
//////    DECLARE_MESSAGE_MAP()
//////
//////public:
//////    // --- переменные модели ---
//////    int m_bladeCount;
//////    double m_speed;
//////    BOOL m_isClockwise;
//////    HICON m_hIcon;
//////
//////    // --- обработчики ---
//////    afx_msg void OnBnClickedOk();
//////};
////
////#pragma once
////#include "afxdialogex.h"
////
////class CPropellerDlg : public CDialogEx
////{
////    //DECLARE_DYNAMIC(CPropellerDlg)
////
////public:
////    CPropellerDlg(CWnd* pParent = nullptr);
////
////#ifdef AFX_DESIGN_TIME
////    enum { IDD = IDD_PROPELLER_DLG };
////#endif
////
////protected:
////    virtual void DoDataExchange(CDataExchange* pDX);
////    DECLARE_MESSAGE_MAP()
////
////public:
////    // Переменные для хранения данных
////    int m_bladeCount;
////    double m_speed;
////    BOOL m_isClockwise;
////    int m_direction;
////
////    // Обработчики сообщений
////    virtual BOOL OnInitDialog();
////    afx_msg void OnBnClickedOk();
////    afx_msg void OnBnClickedRadioCw();    // ДОБАВЬТЕ ЭТО
////    afx_msg void OnBnClickedRadioCcw();   // ДОБАВЬТЕ ЭТО
////};
//
//#pragma once
//#include "afxdialogex.h"
//
//class CPropellerDlg : public CDialogEx
//{
//public:
//    CPropellerDlg(CWnd* pParent = nullptr);
//
//#ifdef AFX_DESIGN_TIME
//    enum { IDD = IDD_PROPELLER_DLG };
//#endif
//
//protected:
//    virtual void DoDataExchange(CDataExchange* pDX);
//    DECLARE_MESSAGE_MAP()
//
//public:
//    // --- переменные модели ---
//    int m_bladeCount;
//    double m_speed;
//    int m_direction; // 0 = CW, 1 = CCW
//
//    // --- обработчики ---
//    virtual BOOL OnInitDialog();
//    afx_msg void OnBnClickedOk();
//    afx_msg void OnBnClickedRadioCw();    // ДОБАВЬТЕ ЭТО
//    afx_msg void OnBnClickedRadioCcw();   // ДОБАВЬТЕ ЭТО
//};

class CPropellerDlg : public CDialogEx
{
public:
    CPropellerDlg(CWnd* pParent = nullptr);

#ifdef AFX_DESIGN_TIME
    enum { IDD = IDD_PROPELLER_DLG };
#endif

protected:
    virtual void DoDataExchange(CDataExchange* pDX);
    DECLARE_MESSAGE_MAP()

public:
    int m_bladeCount;
    double m_speed;
    int m_direction;

    virtual BOOL OnInitDialog();
    afx_msg void OnBnClickedOk();
    afx_msg void OnBnClickedRadioCw();
    afx_msg void OnBnClickedRadioCcw();
};
