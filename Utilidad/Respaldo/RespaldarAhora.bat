@echo off
REM ===========================================================================
REM  Hace una copia de seguridad de la base de datos EN ESTE MOMENTO.
REM  Se puede usar antes de hacer algo importante, o cuando se quiera.
REM  Basta con hacer doble clic.
REM ===========================================================================
title Respaldo de la base de datos del hotel
echo.
echo   Creando la copia de seguridad, espere un momento...
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0respaldo.ps1"

echo.
if %ERRORLEVEL% EQU 0 (
    echo   LISTO. La copia quedo guardada en la carpeta C:\RespaldosHotel
) else (
    echo   ATENCION: NO se pudo crear la copia.
    echo   Revise el archivo C:\RespaldosHotel\respaldos.log y avise al administrador.
)
echo.
pause
