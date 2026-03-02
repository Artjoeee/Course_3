#include "stdafx.h"
#include "CMatrix.h"
#include "LibGraph.h"
#include "CPyramid.h"
#include "Lab2.h"
#include "ChildView.h"
#include <fstream>
#include <string>
#include <iostream>
#include "CCameraDialog.h"

using namespace std;

#ifdef _DEBUG
#define new DEBUG_NEW
#endif

// CChildView

CChildView::CChildView()
{
    Mode = 0;
    Viewport.resize(3);
    SavedViewport.resize(3);
    DefaultViewport.resize(3);

    // Параметры по умолчанию
    DefaultViewport(0) = 10; // расстояние до камеры
    DefaultViewport(1) = 315;// угол по X
    DefaultViewport(2) = 45; // угол по Y

    // Изначально текущее положение совпадает с сохранённым
    Viewport = DefaultViewport;
    SavedViewport = DefaultViewport;
}

CChildView::~CChildView()
{
    // Деструктор класса CChildView
}

BEGIN_MESSAGE_MAP(CChildView, CWnd)
    ON_WM_PAINT()
    ON_COMMAND(ID_PYRAMID_DRAW, &CChildView::OnPyramidDrawxray)
    ON_COMMAND(ID_PYRAMID_DRAWXRAY, &CChildView::OnPyramidDraw)
    ON_WM_KEYDOWN()
    ON_WM_SIZE()
    ON_COMMAND(ID_32773, &CChildView::CurrentCameraPosition)
    ON_COMMAND(ID_32774, &CChildView::SetDefaultCameraPosition)
    ON_COMMAND(ID_CAMERA_SETDIALOG, &CChildView::SetCameraFromDialog)
END_MESSAGE_MAP()

// обработчики сообщений CChildView

BOOL CChildView::PreCreateWindow(CREATESTRUCT& cs)
{
    // Переопределяем стиль окна перед его созданием
    // Добавляем клиентскую границу и удаляем обычную границу
    if (!CWnd::PreCreateWindow(cs))
        return FALSE;

    cs.dwExStyle |= WS_EX_CLIENTEDGE;
    cs.style &= ~WS_BORDER;
    cs.lpszClass = AfxRegisterWndClass(CS_HREDRAW | CS_VREDRAW | CS_DBLCLKS,
        ::LoadCursor(NULL, IDC_ARROW), reinterpret_cast<HBRUSH>(COLOR_WINDOW + 1), NULL);

    return TRUE;
}

void CChildView::OnPaint()
{
    // Обработчик сообщения о перерисовке окна
    CPaintDC dc(this);

    if (Mode == 1)    // Прозрачная
    {
        Pyramid.draw(dc, Viewport, RectWindow);
    }
    if (Mode == 2)    // Непрозрачная
    {
        Pyramid.drawXray(dc, Viewport, RectWindow);
    }
}

void CChildView::OnPyramidDraw()
{
    // Обработчик команды "Отобразить пирамиду"
    // Устанавливаем параметры камеры
    Viewport(0) = 10;  // расстояние до камеры
    Viewport(1) = 315; // угол до линии обзора камеры по Х
    Viewport(2) = 45;  // угол до линии обзора до камеры по У

    // Устанавливаем режим отображения "Прозрачный"
    Mode = 1;
    Invalidate(); // Обновляем отображение
}

void CChildView::OnPyramidDrawxray()
{
    // Обработчик команды "Отобразить пирамиду рентгеновским способом"
    // Устанавливаем параметры камеры
    Viewport(0) = 10;  // расстояние до камеры
    Viewport(1) = 315; // угол до линии обзора камеры по Х
    Viewport(2) = 45;  // угол до линии обзора до камеры по У

    // Устанавливаем режим отображения "Непрозрачный"
    Mode = 2;
    Invalidate(); // Обновляем отображение
}

void CChildView::OnKeyDown(UINT nChar, UINT nRepCnt, UINT nFlags)
{
    // Обработчик события нажатия клавиши
    if ((Mode == 1) || (Mode == 2))
    {
        double d;
        switch (nChar)
        {
        case VK_UP:    // Стрелка вверх
            d = Viewport(2) - 5;
            if (d >= -180)
                Viewport(2) = d;
            else
                Viewport(2) = d + 360;
            break;

        case VK_DOWN:  // Стрелка вниз
            d = Viewport(2) + 5;
            if (d <= 180)
                Viewport(2) = d;
            else
                Viewport(2) = d - 360;
            break;

        case VK_LEFT:  // Стрелка влево
            d = Viewport(1) - 5;
            if (d >= -180)
                Viewport(1) = d;
            else
                Viewport(1) = d + 360;
            break;

        case VK_RIGHT: // Стрелка вправо
            d = Viewport(1) + 5;
            if (d <= 180)
                Viewport(1) = d;
            else
                Viewport(1) = d - 360;
            break;
        }
        Invalidate(); // Обновляем отображение
    }
    CWnd::OnKeyDown(nChar, nRepCnt, nFlags);
}

void CChildView::OnSize(UINT nType, int cx, int cy)// изменяет фигуру при изменении размеров окна
{
    CWnd::OnSize(nType, cx, cy);
    RectWindow.SetRect(100, 100, cx - 100, cy - 50);
}

void CChildView::SetDefaultCameraPosition()
{
    // Показываем камеру по умолчанию, но не перезаписываем сохранённые пользовательские настройки
    Viewport = DefaultViewport;
    Invalidate(); // Обновляем отображение
}

void CChildView::CurrentCameraPosition()
{
    //std::ifstream in("D:\\Desktop\\lab_07\\lab_07\\Lab5.2\\x64\\Debug\\camera.txt");

    //if (in.is_open())
    //{
    //    std::string line;
    //    int r, fi, teta;

    //    // Считываем значения из файла
    //    if (std::getline(in, line)) r = stoi(line); else r = SavedViewport(0);
    //    if (std::getline(in, line)) fi = stoi(line); else fi = SavedViewport(1);
    //    if (std::getline(in, line)) teta = stoi(line); else teta = SavedViewport(2);

    //    // Сохраняем как пользовательские параметры
    //    SavedViewport(0) = r;
    //    SavedViewport(1) = fi;
    //    SavedViewport(2) = teta;

    //    in.close();
    //}

    // Обновляем текущее отображение камеры
    Viewport = SavedViewport;
    Invalidate(); // Обновляем экран
}


void CChildView::SetCameraFromDialog()
{
    CCameraDialog dlg;
    dlg.m_r = SavedViewport(0);
    dlg.m_fi = SavedViewport(1);
    dlg.m_teta = SavedViewport(2);

    if (dlg.DoModal() == IDOK)
    {
        SavedViewport(0) = dlg.m_r;
        SavedViewport(1) = dlg.m_fi;
        SavedViewport(2) = dlg.m_teta;

        Viewport = SavedViewport; // показываем их
        Invalidate();
    }
}

