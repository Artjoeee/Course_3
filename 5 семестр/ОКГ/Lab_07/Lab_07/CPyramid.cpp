#include "stdafx.h"
#include "CMatrix.h"
#include "LibGraph.h"
#include "CPyramid.h"

CPyramid::CPyramid()	// Пирамида по умолчанию
{//координаты вершин пирамиды в мировой системе координат
	_vertices.resize(4, 8);

	_vertices(0, 0) = 6;
	_vertices(0, 3) = 2;
	_vertices(2, 3) = 6;

	_vertices(1, 1) = -6;
	_vertices(1, 4) = -2;
	_vertices(2, 4) = 6;

	_vertices(0, 2) = -6;
	_vertices(0, 5) = -2;
	_vertices(2, 5) = 6;
}

void CPyramid::draw(CDC& dc, CMatrix& viewport, CRect& rectWindow)	// нарисовать пирамиду без невидимых граней
{
	// Переводим сферические координаты камеры в декартовы 
	CMatrix viewportCoords = sphericalToCartesian(viewport);

	// Находим матрицу перевода из МСК в видовую СК
	CMatrix converterWorldToView = getConverterWorldToView(viewport(0), viewport(1), viewport(2));

	// Находим координаты вертикалей в ВСК (вершины пирамиды, которые расположены на верхней грани (вершине) пирамиды)
	CMatrix verticesView = converterWorldToView * _vertices;

	CRectD rectView;
	getRect(verticesView, rectView);

	// Находим матрицу перевода из ВСК в оконную СК
	CMatrix converterWorldToWindow = getConverterWorldToWindow(rectView, rectWindow);

	CPoint vertices[6];
	CMatrix verticesCoords(3);
	verticesCoords(2) = 1;

	for (int i = 0; i < 6; i++)		// задание точек
	{
		verticesCoords(0) = verticesView(0, i);
		verticesCoords(1) = verticesView(1, i);

		verticesCoords = converterWorldToWindow * verticesCoords;
		vertices[i].x = (int)verticesCoords(0);
		vertices[i].y = (int)verticesCoords(1);
	}

	CPen brushEdge(PS_SOLID, 2, RGB(0, 0, 255)); 
	CPen* pOldPen = dc.SelectObject(&brushEdge);

	// Кисть для нижней грани
	CBrush brushBottom(RGB(255, 0, 0));
	CBrush* pOldBrush = dc.SelectObject(&brushBottom); 

	CMatrix R1(3), R2(3), normalOuter(3);
	double sm;

	for (int i = 0; i < 3; i++) // закрашивание граней
	{
		// Получаем вертикаль грани
		CMatrix VE = _vertices.getCol(i + 3, 0, 2);

		int k = i == 2 ? 0 : i + 1;

		// Получаем точки ребра у основания
		R1 = _vertices.getCol(i, 0, 2);
		R2 = _vertices.getCol(k, 0, 2);

		// Получаем длину ребра у основания
		CMatrix edgeBase = R2 - R1;

		// Получаем длину ребра вертикали
		CMatrix edgeVertex = VE - R1;

		// Находим внешний вектор нормали
		normalOuter = vectorProduct(edgeVertex, edgeBase);

		// Находим скалярное произведение
		sm = scalarProduct(normalOuter, viewportCoords);
														
		if (sm >= 0)
		{
			dc.MoveTo(vertices[i]);
			dc.LineTo(vertices[k]);
			dc.LineTo(vertices[k + 3]);
			dc.LineTo(vertices[i + 3]);
			dc.LineTo(vertices[i]);
		}
	}
	if (viewportCoords(2) < 0) 
	{
		dc.Polygon(vertices, 3);
	}
	else
	{
		CBrush brushTop(RGB(0, 255, 0));	// задаем в перо зеленого цвета для основания
		dc.SelectObject(brushTop);
		dc.Polygon(vertices + 3, 3);
	}
	dc.SelectObject(pOldPen);
	dc.SelectObject(pOldBrush);
}

void CPyramid::drawXray(CDC& dc, CMatrix& viewport, CRect& rectWindow)// берет 3D модель пирамиды, преобразует ее в 2D изображение, которое можно отобразить на экране
{//из мск в оск
	// Находим матрицу перевода из МСК в видовую СК
	CMatrix converterWorldToView = getConverterWorldToView(viewport(0), viewport(1), viewport(2));

	// Находим координаты вертикалей в ВСК
	CMatrix verticesView = converterWorldToView * _vertices;

	CRectD rectView;
	getRect(verticesView, rectView);

	// Находим матрицу перевода из ВСК в оконную СК
	CMatrix converterWorldToWindow = getConverterWorldToWindow(rectView, rectWindow);

	CPoint vertices[6];
	CMatrix verticesCoords(3);
	verticesCoords(2) = 1;

	for (int i = 0; i < 6; i++)		// задание точек
	{
		verticesCoords(0) = verticesView(0, i);
		verticesCoords(1) = verticesView(1, i);
		verticesCoords = converterWorldToWindow * verticesCoords;
		vertices[i].x = (int)verticesCoords(0);
		vertices[i].y = (int)verticesCoords(1);
	}

	CPen brushEdge(PS_SOLID, 2, RGB(0, 0, 255)); //задаем в перо синего цвета для краев(линий)
	CPen* pOldPen = dc.SelectObject(&brushEdge);

	dc.MoveTo(vertices[2]); // рисуем грани (устанавливаем кисть в точку)
	for (int i = 0; i < 3; i++)
	{
		dc.LineTo(vertices[i]);//(рисуем установленной кистью
	}
	dc.MoveTo(vertices[5]);
	for (int i = 3; i < 6; i++)
	{
		dc.LineTo(vertices[i]);
	}
	for (int i = 0; i < 3; i++)
	{
		dc.MoveTo(vertices[i]);
		dc.LineTo(vertices[i + 3]);
	}

	dc.SelectObject(pOldPen);
}

void CPyramid::getRect(CMatrix& Vert, CRectD& RectView)	// прямоугольник
{
	CMatrix V = Vert.getRow(0);

	double xMin = V.getMin();
	double xMax = V.getMax();

	V = Vert.getRow(1);

	double yMin = V.getMin();
	double yMax = V.getMax();

	RectView.setRectD(xMin, yMax, xMax, yMin);
}
// Вычисляет координаты прямоугольника, охватывающего проекцию 
// пирамиды на плоскость XY в ВИДОВОЙ системе координат
// Vert - координаты вершин (в столбцах)
// RectView - проекция - охватывающий прямоугольник