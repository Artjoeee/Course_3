#include "stdafx.h"

CRectD::CRectD(double l, double t, double r, double b)
{
	left = l;
	top = t;
	right = r;
	bottom = b;
}
//------------------------------------------------------------------------------
void CRectD::SetRectD(double l, double t, double r, double b)
{
	left = l;
	top = t;
	right = r;
	bottom = b;
}

//------------------------------------------------------------------------------
CSizeD CRectD::SizeD()
{
	CSizeD cz;
	cz.cx = fabs(right - left);	// Ширина прямоугольной области
	cz.cy = fabs(top - bottom);	// Высота прямоугольной области
	return cz;
}

//----------------------------------------------------------------------------

CMatrix CreateTranslate2D(double dx, double dy)
// Формирует матрицу для преобразования координат объекта при его смещении 
// на dx по оси X и на dy по оси Y в фиксированной системе координат
// --- ИЛИ ---
// Формирует матрицу для преобразования координат объекта при смещении начала
// системы координат на -dx оси X и на -dy по оси Y при фиксированном положении объекта 
{
	CMatrix TM(3, 3);
	TM(0, 0) = 1; TM(0, 2) = dx;
	TM(1, 1) = 1;  TM(1, 2) = dy;
	TM(2, 2) = 1;
	return TM;
}

//------------------------------------------------------------------------------------
CMatrix CreateRotate2D(double fi)
// Формирует матрицу для преобразования координат объекта при его повороте
// на угол fi (при fi>0 против часовой стрелки)в фиксированной системе координат
// --- ИЛИ ---
// Формирует матрицу для преобразования координат объекта при повороте начала
// системы координат на угол -fi при фиксированном положении объекта 
// fi - угол в градусах
{
	double fg = fmod(fi, 360.0);
	double ff = (fg / 180.0) * pi; // Перевод в радианы
	CMatrix RM(3, 3);
	RM(0, 0) = cos(ff); RM(0, 1) = -sin(ff);
	RM(1, 0) = sin(ff);  RM(1, 1) = cos(ff);
	RM(2, 2) = 1;
	return RM;
}


//------------------------------------------------------------------------------

CMatrix SpaceToWindow(CRectD& RS, CRect& RW)
// Возвращает матрицу пересчета координат из мировых в оконные
// RS - область в мировых координатах - double
// RW - область в оконных координатах - int
{
	CMatrix M(3, 3);
	CSize sz = RW.Size();	 // Размер области в ОКНЕ
	int dwx = sz.cx;	     // Ширина
	int dwy = sz.cy;	     // Высота
	CSizeD szd = RS.SizeD(); // Размер области в МИРОВЫХ координатах

	double dsx = szd.cx;    // Ширина в мировых координатах
	double dsy = szd.cy;    // Высота в мировых координатах

	double kx = (double)dwx / dsx;   // Масштаб по x
	double ky = (double)dwy / dsy;   // Масштаб по y

	M(0, 0) = kx;  M(0, 1) = 0;    M(0, 2) = (double)RW.left - kx * RS.left;
	M(1, 0) = 0;   M(1, 1) = -ky;  M(1, 2) = (double)RW.bottom + ky * RS.bottom;
	M(2, 0) = 0;   M(2, 1) = 0;    M(2, 2) = 1;
	return M;
}

//------------------------------------------------------------------------------

void SetMyMode(CDC& dc, CRectD& RS, CRect& RW)
{
// Устанавливает режим отображения MM_ANISOTROPIC и его параметры
// dc - ссылка на класс CDC MFC
// RS -  область в мировых координатах - int
// RW -	 Область в оконных координатах - int 
	double dsx = RS.right - RS.left;
	double dsy = RS.top - RS.bottom;
	double xsL = RS.left;
	double ysL = RS.bottom;

	int dwx = RW.right - RW.left;
	int dwy = RW.bottom - RW.top;
	int xwL = RW.left;
	int ywH = RW.bottom;

	dc.SetMapMode(MM_ANISOTROPIC);
	dc.SetWindowExt((int)dsx, (int)dsy);
	dc.SetViewportExt(dwx, -dwy);
	dc.SetWindowOrg((int)xsL, (int)ysL);
	dc.SetViewportOrg(xwL, ywH);
}

CBlade::CBlade()
{
	// Инициализация
	m_bladeCount = 4;
	m_angularSpeed = 8.0;
	m_direction = 1.0;

	double rS = 30;
	double RoE = 10 * rS;
	double d = RoE;
	RS.SetRectD(-d, d, d, -d);
	RW.SetRect(0, 0, 690, 640);

	// Центральный круг
	MainPoint.SetRect(-rS, rS, rS, -rS);
	WayRotation.SetRect(-RoE, RoE, RoE, -RoE);

	// Инициализируем массивы координат
	for (int i = 0; i < 8; i++) {
		m_bladeCoords[i].RedimMatrix(3);
	}

	wPoint = m_angularSpeed;
	dt = 0.1;

	// Инициализируем углы
	RecalculateBlades();
}

void CBlade::SetNewCoords()
{
	// НОРМАЛЬНАЯ логика
	for (int i = 0; i < m_bladeCount; i++) {
		m_bladeAngles[i] += wPoint / 1.8  * m_direction;
		m_bladeAngles[i] = fmod(m_bladeAngles[i], 360.0);
	}
}

// Вспомогательный метод для обновления координат одной лопасти
void CBlade::UpdateBladeCoords(CMatrix& coords, double angle, double RoV)
{
	double ff = (angle / 180.0) * pi; // Перевод в радианы
	double x = RoV * cos(ff);
	double y = RoV * sin(ff);

	coords(0) = x;
	coords(1) = y;
	coords(2) = 1;

	CMatrix P = CreateRotate2D(angle);
	coords = P * coords;
}

void CBlade::Draw(CDC& dc)
{
	CBrush MBrush, RedBrush, BlueBrush, * pOldBrush;
	CPen pen(PS_SOLID, 2, RGB(0, 0, 0)), * pOldPen;

	MBrush.CreateSolidBrush(RGB(0, 255, 0));
	RedBrush.CreateSolidBrush(RGB(255, 0, 0));
	BlueBrush.CreateSolidBrush(RGB(0, 0, 255));

	pOldPen = dc.SelectObject(&pen);

	// Рисуем треугольники
	for (int i = 0; i < m_bladeCount; i++) {
		if (i % 2 == 0) {
			pOldBrush = dc.SelectObject(&RedBrush);
			DrawSingleBlade(m_bladeCoords[i], m_bladeAngles[i], dc, RedBrush);
		}
		else {
			pOldBrush = dc.SelectObject(&BlueBrush);
			DrawSingleBlade(m_bladeCoords[i], m_bladeAngles[i], dc, BlueBrush);
		}
		dc.SelectObject(pOldBrush);
	}

	// Круг поверх
	pOldBrush = dc.SelectObject(&MBrush);
	dc.Ellipse(MainPoint);


	dc.SelectObject(pOldPen);
	dc.SelectObject(pOldBrush);
}

void CBlade::DrawSingleBlade(CMatrix& coords, double angle, CDC& dc, CBrush& bladeBrush)
{
	CPen* pOldPen = dc.SelectObject(&CPen(PS_SOLID, 1, RGB(0, 0, 0)));
	CBrush* pOldBrush = dc.SelectObject(&bladeBrush);

	double angleRad = (angle / 180.0) * pi;
	double dirX = cos(angleRad);
	double dirY = sin(angleRad);

	int centerX = (MainPoint.left + MainPoint.right) / 2;
	int centerY = (MainPoint.top + MainPoint.bottom) / 2;

	double innerRadius = 0.0;
	double outerRadius = 280.0;
	double width = 50.0;

	double perpX = -dirY;
	double perpY = dirX;

	POINT triangle[3];
	triangle[0] = { centerX, centerY };
	triangle[1] = { centerX + (int)(dirX * outerRadius + perpX * width),
					centerY + (int)(dirY * outerRadius + perpY * width) };
	triangle[2] = { centerX + (int)(dirX * outerRadius - perpX * width),
					centerY + (int)(dirY * outerRadius - perpY * width) };

	dc.Polygon(triangle, 3);

	dc.SelectObject(pOldBrush);
	dc.SelectObject(pOldPen);
}


void CBlade::DrawTriangularBlade(CMatrix& tipCoords, CDC& dc, CBrush& bladeBrush)
{
	CPen* pOldPen = dc.SelectObject(&CPen(PS_SOLID, 1, RGB(0, 0, 0)));
	CBrush* pOldBrush = dc.SelectObject(&bladeBrush);

	// Размеры треугольника лопасти
	double bladeLength = 80.0;  // Длина лопасти
	double bladeWidth = 20.0;   // Ширина основания лопасти

	// Точка конца лопасти (нормализованная)
	double tipX = tipCoords(0);
	double tipY = tipCoords(1);

	// Вычисляем направляющий вектор
	double length = sqrt(tipX * tipX + tipY * tipY);
	if (length > 0) {
		double dirX = tipX / length;
		double dirY = tipY / length;

		// Перпендикулярный вектор для ширины
		double perpX = -dirY;
		double perpY = dirX;

		// Три точки треугольника:
		// 1. Точка на окружности (начало лопасти)
		double innerRadius = 40.0; // Радиус, откуда начинается лопасть
		double startX = dirX * innerRadius;
		double startY = dirY * innerRadius;

		// 2. и 3. Точки основания треугольника (по бокам)
		double baseX1 = startX + perpX * bladeWidth / 2;
		double baseY1 = startY + perpY * bladeWidth / 2;

		double baseX2 = startX - perpX * bladeWidth / 2;
		double baseY2 = startY - perpY * bladeWidth / 2;

		// 4. Точка конца лопасти (нормализованная к нужной длине)
		double endX = dirX * bladeLength;
		double endY = dirY * bladeLength;

		// Рисуем заполненный треугольник
		POINT triangle[3];
		triangle[0] = { (int)baseX1, (int)baseY1 };
		triangle[1] = { (int)baseX2, (int)baseY2 };
		triangle[2] = { (int)endX, (int)endY };

		dc.Polygon(triangle, 3);
	}

	dc.SelectObject(pOldBrush);
	dc.SelectObject(pOldPen);
}
void CBlade::DrawTriangle(CMatrix FTCoords, CMatrix STCoords, CDC& dc, int xC, int yC, int zC)
{
	// Пустая реализация или вызов нового метода
}


void CBlade::GetRS(CRectD& RSX)
{
	RSX.left = RS.left;
	RSX.top = RS.top;
	RSX.right = RS.right;
	RSX.bottom = RS.bottom;
}
void CBlade::SetBladeCount(int count)
{
	if (count < 2) count = 2;
	if (count > 8) count = 8;
	m_bladeCount = count;
	RecalculateBlades();
}

void CBlade::SetAngularSpeed(double speed)
{
	m_angularSpeed = speed;
	wPoint = speed;
}

void CBlade::SetDirection(double direction)
{
	//CString msg;
	//msg.Format(L"=== SetDirection called: direction=%.1f ===", direction);
	//OutputDebugString(msg);

	m_direction = direction;

	// Принудительно устанавливаем скорость с учетом направления
	wPoint = abs(m_angularSpeed) * m_direction;

	//msg.Format(L"После установки: m_direction=%.1f, wPoint=%.2f", m_direction, wPoint);
	//OutputDebugString(msg);
}

void CBlade::RecalculateBlades()
{
	// Распределяем лопасти равномерно
	double angleStep = 360.0 / m_bladeCount;

	for (int i = 0; i < m_bladeCount; i++) {
		m_bladeAngles[i] = i * angleStep + 45.0; // Смещение 45 градусов
		m_bladeAngles[i] = fmod(m_bladeAngles[i], 360.0);
	}
}