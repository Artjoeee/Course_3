#pragma once
#include <afxwin.h>
#include <afxcmn.h>
#include "CMatrix.h"
#include "resource.h"

class CCoordDialog : public CDialog {
public:
    CCoordDialog(CWnd* pParent = NULL);
    virtual ~CCoordDialog() {}

    enum { IDD = IDD_COORD_DIALOG };

    CMatrix* m_pPoint;  // Указатель на матрицу координат (камера или свет)
    bool m_bIsCamera;   // true - камера, false - источник света

protected:
    virtual void DoDataExchange(CDataExchange* pDX);
    virtual BOOL OnInitDialog();

    DECLARE_MESSAGE_MAP()

public:
    afx_msg void OnBnClickedSetButton();

    CComboBox m_comboType;
    CEdit m_editRadius;
    CEdit m_editFi;
    CEdit m_editTheta;
};