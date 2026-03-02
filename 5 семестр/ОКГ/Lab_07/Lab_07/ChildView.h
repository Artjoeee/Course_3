#pragma once

#include "CMatrix.h"
#include "LibGraph.h"
#include "CPyramid.h"

// окно CChildView

class CChildView : public CWnd
{
	// Создание
public:
	CChildView();

	// Атрибуты
public:
	CPyramid Pyramid;
	CRect RectWindow;
	CMatrix Viewport;           // текущие параметры камеры для отображения
	CMatrix SavedViewport;      // сохранённые пользовательские параметры (из диалога или файла)
	CMatrix DefaultViewport;    // параметры камеры по умолчанию
	int Mode;

	// Операции
public:

	// Переопределение
protected:
	virtual BOOL PreCreateWindow(CREATESTRUCT& cs);

	// Реализация
public:
	virtual ~CChildView();

	// Созданные функции схемы сообщений
protected:
	afx_msg void OnPaint();
	DECLARE_MESSAGE_MAP()
public:
	afx_msg void OnPyramidDraw();
	afx_msg void OnPyramidDrawxray();
	afx_msg void OnKeyDown(UINT nChar, UINT nRepCnt, UINT nFlags);
	afx_msg void OnSize(UINT nType, int cx, int cy);
	afx_msg void CurrentCameraPosition();
	afx_msg void SetDefaultCameraPosition();
	afx_msg void SetCameraFromDialog();
};