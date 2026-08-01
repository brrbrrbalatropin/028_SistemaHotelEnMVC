@echo off
REM ===========================================================================
REM  Devuelve la base de datos a como estaba en una copia anterior.
REM
REM  *** SOLO USAR EN CASO DE EMERGENCIA ***
REM  Todo lo registrado despues de esa copia se pierde.
REM ===========================================================================
title RESTAURAR la base de datos del hotel
echo.
echo   ATENCION
echo   Esta herramienta reemplaza la informacion actual del sistema
echo   por la de una copia anterior.
echo.
echo   Antes de continuar, cierre el sistema del hotel en el navegador.
echo.
pause

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0restaurar.ps1"

echo.
pause
