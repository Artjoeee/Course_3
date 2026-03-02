#include "CCoordDialog.h"
#include "CMatrix.h"
#include "resource.h"
#include <string>

CCoordDialog::CCoordDialog(CWnd* pParent /*=NULL*/)
    : CDialog(CCoordDialog::IDD, pParent)
    , m_pPoint(NULL)
    , m_bIsCamera(true) {
}

BEGIN_MESSAGE_MAP(CCoordDialog, CDialog)
    ON_BN_CLICKED(IDC_SET_BUTTON, &CCoordDialog::OnBnClickedSetButton)
END_MESSAGE_MAP()

void CCoordDialog::DoDataExchange(CDataExchange* pDX) {
    CDialog::DoDataExchange(pDX);
    DDX_Control(pDX, IDC_COMBO_TYPE, m_comboType);
    DDX_Control(pDX, IDC_RADIUS_EDIT, m_editRadius);
    DDX_Control(pDX, IDC_FI_EDIT, m_editFi);
    DDX_Control(pDX, IDC_THETA_EDIT, m_editTheta);
}

BOOL CCoordDialog::OnInitDialog() {
    CDialog::OnInitDialog();

    // Заполняем комбобокс
    m_comboType.AddString(L"Камера");
    m_comboType.AddString(L"Источник света");

    if (m_bIsCamera)
        m_comboType.SetCurSel(0);
    else
        m_comboType.SetCurSel(1);

    // Заполняем поля значениями
    if (m_pPoint && m_pPoint->rows() >= 3) {
        CString strRadius, strFi, strTheta;
        strRadius.Format(L"%.1f", (*m_pPoint)(0));
        strFi.Format(L"%.1f", (*m_pPoint)(1));
        strTheta.Format(L"%.1f", (*m_pPoint)(2));

        m_editRadius.SetWindowText(strRadius);
        m_editFi.SetWindowText(strFi);
        m_editTheta.SetWindowText(strTheta);
    }

    return TRUE;
}

void CCoordDialog::OnBnClickedSetButton() {
    if (!m_pPoint) return;

    // Получаем значения из полей ввода
    CString strRadius, strFi, strTheta;
    m_editRadius.GetWindowText(strRadius);
    m_editFi.GetWindowText(strFi);
    m_editTheta.GetWindowText(strTheta);

    // Проверяем и устанавливаем значения
    double r = _wtof(strRadius);
    double fi = _wtof(strFi);
    double theta = _wtof(strTheta);

    // Проверка валидности значений
    if (r <= 0) {
        MessageBox(L"Радиус должен быть больше 0", L"Ошибка", MB_OK | MB_ICONERROR);
        return;
    }

    // Нормализация углов
    fi = fmod(fi, 360.0);
    if (fi < 0) fi += 360.0;

    theta = fmod(theta, 180.0);
    if (theta < 0) theta = 0;
    if (theta > 180.0) theta = 180.0;

    // Устанавливаем значения в матрицу
    (*m_pPoint)(0) = r;
    (*m_pPoint)(1) = fi;
    (*m_pPoint)(2) = theta;

    EndDialog(IDOK);
}