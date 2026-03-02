
// ChildView.cpp: реализация класса CChildView
//

#include "stdafx.h"
#include "framework.h"
#include "lab3.h"
#include "ChildView.h"
#include <math.h>
#define MARGIN_CYCLE 10

#ifdef _DEBUG
#define new DEBUG_NEW
#endif


// CChildView

CChildView::CChildView()
{
	Index = 0;
}

CChildView::~CChildView()
{
}


BEGIN_MESSAGE_MAP(CChildView, CWnd)
	ON_WM_PAINT()
	ON_WM_SIZE()
	ON_COMMAND(ID_TESTS_F1, &CChildView::OnTestsF1)
	ON_COMMAND(ID_TESTS_F2, &CChildView::OnTestsF2)
	ON_COMMAND(ID_TESTS_F3, &CChildView::OnTestsF3)
END_MESSAGE_MAP()



// Обработчики сообщений CChildView

BOOL CChildView::PreCreateWindow(CREATESTRUCT& cs) 
{
	if (!CWnd::PreCreateWindow(cs))
		return FALSE;

	cs.dwExStyle |= WS_EX_CLIENTEDGE;
	cs.style &= ~WS_BORDER;
	cs.lpszClass = AfxRegisterWndClass(CS_HREDRAW|CS_VREDRAW|CS_DBLCLKS, 
		::LoadCursor(nullptr, IDC_ARROW), reinterpret_cast<HBRUSH>(COLOR_WINDOW+1), nullptr);

	return TRUE;
}

void CChildView::OnPaint() 
{
	CPaintDC dc(this); // контекст устройства для рисования 
	/*dc.SetMapMode(MM_ANISOTROPIC);*/

	CRect rect;
	GetClientRect(&rect);
	CBrush brush(RGB(255, 255, 255)); // Белый фон
	dc.FillRect(&rect, &brush);

	if (Index == 1 || Index == 2)
	{
		Graph.Draw(dc, 1, 1);

        CPen penCircle(PS_SOLID, 1, RGB(0, 128, 0));
        CPen* pOldPen = dc.SelectObject(&penCircle);

        int xCenter = 0;
        int yCenter = 100;
        int r = 20; // радиус (10x10 пикселей окружность)
        dc.Ellipse(xCenter - r, yCenter - r, xCenter + r, yCenter + r);

        dc.SelectObject(pOldPen);
	}
	else if (Index == 3)
	{
		// Перерисовываем восьмиугольник
		OnTestsF3();
	}
}

void CChildView::OnSize(UINT nType, int cx, int cy)
{
	CWnd::OnSize(nType, cx, cy);

	// Обновляем область рисования при изменении размеров окна
	if (Index == 1 || Index == 2)
	{
		// Автоматически изменяем размер области рисования
		int margin = 50;
		RW.SetRect(margin, margin, cx - margin, cy - margin);
		Graph.SetWindowRect(RW);
	}

	Invalidate(); // Перерисовываем
}

double CChildView::MyF1(double x)
{
	double y = sin(x) / x;
	return y;
}



double CChildView::MyF2(double x)
{
	double y = sqrt(abs(x)) * sin(x);
	return y;
}


void CChildView::OnTestsF1()
{
    double xL = -3 * pi;
    double xH = -xL;
    double deltaX = pi / 36;
    int n = (xH - xL) / deltaX;
    X.RedimMatrix(n + 1);
    Y.RedimMatrix(n + 1);

    for (int i = 0; i <= n; i++) {
        X(i) = xL + i * deltaX;
        Y(i) = MyF1(X(i));
    }

    PenLine.Set(PS_SOLID, 1, RGB(255, 0, 0));
    PenAxis.Set(PS_SOLID, 2, RGB(0, 0, 255));

    GetClientRect(&RW);
    int margin = 50;
    RW.DeflateRect(margin, margin);

    Graph.SetParams(X, Y, RW);
    Graph.SetPenLine(PenLine);
    Graph.SetPenAxis(PenAxis);

    Index = 1;
    Invalidate();   // просим перерисовку окна (OnPaint)
}



void CChildView::OnTestsF2() {
	double xL = -4 * pi;
	double xH = -xL;
	double deltaX = pi / 36;
	int n = (xH - xL) / deltaX;
	X.RedimMatrix(n + 1);
	Y.RedimMatrix(n + 1);
	for (int i = 0; i <= n; i++) {
		X(i) = xL + i * deltaX;
		Y(i) = MyF2(X(i));
	}
	PenLine.Set(PS_DASHDOT, 3, RGB(255, 0, 0));
	PenAxis.Set(PS_SOLID, 2, RGB(0, 0, 0));
	GetClientRect(&RW);
	int margin = 50;
	RW.DeflateRect(margin, margin);
	Graph.SetParams(X, Y, RW);
	Graph.SetPenLine(PenLine);
	Graph.SetPenAxis(PenAxis);
	Index = 2;
	Invalidate();
}

void CChildView::OnTestsF3()
{
    Invalidate();
    Index = 3;
    CPaintDC dc(this);

    // === Настройка пера и шрифта ===
    CPen penFigure(PS_SOLID, 3, RGB(255, 0, 0));   // восьмиугольник
    CPen penCircle(PS_SOLID, 2, RGB(0, 0, 255));   // окружность
    CPen penAxes(PS_SOLID, 1, RGB(0, 0, 0));       // оси
    CPen penOrigin(PS_SOLID, 1, RGB(0, 128, 0));   // начало координат (точка 0,0)

    CFont font;
    font.CreatePointFont(90, _T("Arial"));
    CFont* pOldFont = dc.SelectObject(&font);

    // === Размеры клиентской области ===
    CRect rect;
    GetClientRect(&rect);

    // === Настройки системы координат ===
    const double worldRadius = 10.0;   // радиус окружности в мировых координатах
    const double margin = 50.0;
    const double centerX = rect.Width() / 2.0;
    const double centerY = rect.Height() / 2.0;

    // Масштаб: 1 единица мировой системы = сколько пикселей
    const double scale = (min(rect.Width(), rect.Height()) / 2.0 - margin) / worldRadius;

    auto WorldToScreenX = [&](double x) { return (int)(centerX + x * scale); };
    auto WorldToScreenY = [&](double y) { return (int)(centerY - y * scale); }; // ось Y направлена вверх

    // === Окружность радиуса 10 ===
    dc.SelectObject(&penCircle);
    int left = WorldToScreenX(-worldRadius);
    int top = WorldToScreenY(worldRadius);
    int right = WorldToScreenX(worldRadius);
    int bottom = WorldToScreenY(-worldRadius);
    dc.Ellipse(left, top, right, bottom);

    // === Восьмиугольник (вписан в окружность радиуса 10) ===
    dc.SelectObject(&penFigure);
    const int sides = 8;
    const double angleStep = 2 * 3.1415926535 / sides;
    const double startAngle = 3.1415926535 / 8; // для ровной ориентации

    POINT pts[9];
    for (int i = 0; i < sides; ++i)
    {
        double x = worldRadius * cos(startAngle + i * angleStep);
        double y = worldRadius * sin(startAngle + i * angleStep);
        pts[i].x = WorldToScreenX(x);
        pts[i].y = WorldToScreenY(y);
    }
    pts[sides] = pts[0]; // замыкаем

    dc.Polyline(pts, sides + 1);

    // === Оси координат ===
    dc.SelectObject(&penAxes);
    int xLeft = WorldToScreenX(-worldRadius * 1.2);
    int xRight = WorldToScreenX(worldRadius * 1.2);
    int yTop = WorldToScreenY(worldRadius * 1.2);
    int yBottom = WorldToScreenY(-worldRadius * 1.2);

    // Ось X
    dc.MoveTo(xLeft, (int)centerY);
    dc.LineTo(xRight, (int)centerY);
    // Ось Y
    dc.MoveTo((int)centerX, yBottom);
    dc.LineTo((int)centerX, yTop);

    // === Стрелки ===
    const int arrowSize = 8;
    // X
    dc.MoveTo(xRight, (int)centerY);
    dc.LineTo(xRight - arrowSize, (int)(centerY - 4));
    dc.MoveTo(xRight, (int)centerY);
    dc.LineTo(xRight - arrowSize, (int)(centerY + 4));
    // Y
    dc.MoveTo((int)centerX, yTop);
    dc.LineTo((int)(centerX - 4), yTop + arrowSize);
    dc.MoveTo((int)centerX, yTop);
    dc.LineTo((int)(centerX + 4), yTop + arrowSize);

    // === Подписи осей ===
    dc.TextOutW(xRight - 15, (int)centerY + 10, _T("X"));
    dc.TextOutW((int)centerX + 10, yTop + 5, _T("Y"));

    // === Деления на осях ===
    const double stepValue = 2.0; // шаг по координатам
    const int numDiv = (int)(worldRadius / stepValue);

    for (int i = -numDiv; i <= numDiv; ++i)
    {
        double value = i * stepValue;
        if (fabs(value) < 1e-6) continue; // пропускаем ноль, подпишем отдельно

        int x = WorldToScreenX(value);
        int y = WorldToScreenY(value);

        CString str;
        str.Format(_T("%.1f"), value);

        // деления на X
        dc.MoveTo(x, (int)(centerY - 4));
        dc.LineTo(x, (int)(centerY + 4));
        dc.TextOutW(x - 10, (int)(centerY + 8), str);

        // деления на Y
        dc.MoveTo((int)(centerX - 4), y);
        dc.LineTo((int)(centerX + 4), y);
        dc.TextOutW((int)(centerX + 6), y - 8, str);
    }

    // Подпись начала координат
    dc.TextOutW((int)(centerX + 6), (int)(centerY + 6), _T("0.0"));

    // === Точка (0,0) ===
    dc.SelectObject(&penOrigin);
    int r = 2; // радиус точки 5x5 пикселей
    dc.Ellipse(0 - r, 0 - r, 0 + r + 1, 0 + r + 1);

    dc.SelectObject(pOldFont);
}


