@echo off
REM ===========================================================================
REM  INSTALADOR DEL SISTEMA DEL HOTEL
REM
REM  Abrir con clic DERECHO -> "Ejecutar como administrador"
REM ===========================================================================
title Instalador del Sistema del Hotel
echo.
echo   ===========================================================
echo    INSTALADOR DEL SISTEMA DEL HOTEL
echo   ===========================================================
echo.
echo   Este proceso puede tardar varios minutos.
echo   No cierre esta ventana hasta que diga que termino.
echo.
pause

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0instalar.ps1"

echo.
pause
