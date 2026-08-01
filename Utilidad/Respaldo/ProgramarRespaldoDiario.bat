@echo off
REM ===========================================================================
REM  Programa el respaldo AUTOMATICO de la base de datos, todos los dias.
REM
REM  ESTE ARCHIVO SE EJECUTA UNA SOLA VEZ, cuando se instala el sistema.
REM
REM  IMPORTANTE: hay que abrirlo con clic DERECHO -> "Ejecutar como
REM  administrador". Si se abre con doble clic normal, Windows no deja
REM  crear la tarea.
REM ===========================================================================
title Programar el respaldo diario
echo.
echo   Se creara una tarea de Windows llamada "RespaldoHotel"
echo   que hara una copia de la base de datos todos los dias a las 10:00 PM.
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0programar.ps1"

echo.
pause
