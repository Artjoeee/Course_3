#ifndef LIBPLANETS
#define LIBPLANETS 1
const double pi = 3.14159;

struct CSizeD
{
	double cx;
	double cy;
};
//-------------------------------------------------------------------------------
struct CRectD
{
	double left;
	double top;
	double right;
	double bottom;
	CRectD() { left = top = right = bottom = 0; };
	CRectD(double l, double t, double r, double b);
	void SetRectD(double l, double t, double r, double b);
	CSizeD SizeD();		// Возвращает размеры(ширина, высота) прямоугольника 
};
//-------------------------------------------------------------------------------

CMatrix CreateTranslate2D(double dx, double dy);
CMatrix CreateRotate2D(double fi);
CMatrix SpaceToWindow(CRectD& rs, CRect& rw);
void SetMyMode(CDC& dc, CRectD& RS, CRect& RW);

class CBlade
{
	// === СТАРЫЕ ПОЛЯ (можно удалить после тестирования) ===
	CRect MainPoint;
	CRect FirstTop;
	CRect SecondTop;
	CRect FirstBootom;
	CRect SecondBootom;
	CRect ThreeTop;
	CRect FourTop;
	CRect ThreeBootom;
	CRect FourBootom;
	CRect WayRotation;

	CMatrix FTCoords;
	CMatrix STCoords;
	CMatrix FBCoords;
	CMatrix SBCoords;
	CMatrix TTCoords;
	CMatrix FFTCoords;
	CMatrix TBCoords;
	CMatrix FFBCoords;

	double fiSB;
	double fiFB;
	double fiST;
	double fiFT;
	double fiTT;
	double fiFFT;
	double fiTB;
	double fiFFB;
	// === КОНЕЦ СТАРЫХ ПОЛЕЙ ===

	CRect RW;		   // Прямоугольник в окне
	CRectD RS;		   // Прямоугольник области в МСК
	double wPoint;		// угловая скорость
	double dt;		   // Интервал дискретизации, сек.

	// === НОВЫЕ ПОЛЯ (основной подход) ===
	int m_bladeCount;           // количество лопастей
	double m_angularSpeed;      // угловая скорость
	

	// Массивы для упрощенного управления лопастями
	double m_bladeAngles[8];    // Углы для всех 8 возможных лопастей
	CMatrix m_bladeCoords[8];   // Координаты для всех 8 лопастей

public:


	CBlade();

	// Основные методы
	void SetDT(double dtx) { dt = dtx; };
	void SetNewCoords();
	void GetRS(CRectD& RSX);
	CRect GetRW() { return RW; };
	void Draw(CDC& dc);

	// Методы для управления параметрами
	void SetBladeCount(int count);
	void SetAngularSpeed(double speed);
	void SetDirection(double direction);
	int GetBladeCount() const { return m_bladeCount; }

	double m_direction;         // направление вращения (1 или -1)
	double w1Point;

private:
	// Вспомогательные методы
	void RecalculateBlades(); // Пересчет геометрии лопастей
	void DrawSingleBlade(CMatrix& coords, double angle, CDC& dc, CBrush& bladeBrush);

	// === СТАРЫЕ МЕТОДЫ (можно удалить) ===
	void DrawTriangle(CMatrix FTCoords, CMatrix STCoords, CDC& dc, int xC, int yC, int zC);
	void DrawTriangularBlade(CMatrix& tipCoords, CDC& dc, CBrush& bladeBrush);
	void UpdateBladeCoords(CMatrix& coords, double angle, double RoV);
	void DrawSingleBladeDirect(int centerX, int centerY, double angle, CDC& dc);
	//void DrawSingleBlade(CMatrix& coords, double angle, CDC& dc, CBrush& bladeBrush);
	//void DrawSingleBlade(CMatrix& coords, double angle, CDC& dc); // Убрали параметр CBrush
};

#endif