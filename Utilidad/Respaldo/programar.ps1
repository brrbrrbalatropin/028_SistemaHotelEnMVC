# =============================================================================
#  PROGRAMA EL RESPALDO AUTOMATICO DIARIO
# =============================================================================
#  Se ejecuta UNA SOLA VEZ, el dia de la instalacion.
#  Normalmente se llama desde "ProgramarRespaldoDiario.bat".
# =============================================================================

$NombreTarea = "RespaldoHotel"
$Hora = "22:00"

$carpeta = Split-Path -Parent $MyInvocation.MyCommand.Path
$script = Join-Path $carpeta "respaldo.ps1"

try {
    if (-not (Test-Path $script)) {
        Write-Output "  ERROR: no se encontro el archivo respaldo.ps1 en esta carpeta."
        exit 1
    }

    $accion = New-ScheduledTaskAction -Execute "powershell.exe" `
        -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$script`""

    $disparador = New-ScheduledTaskTrigger -Daily -At $Hora

    # Estas tres opciones son las importantes:
    #   AllowStartIfOnBatteries    -> tambien respalda si el portatil esta sin cargador
    #   DontStopIfGoingOnBatteries -> no cancela la copia a mitad de camino
    #   StartWhenAvailable         -> si el computador estaba apagado a las 10 PM,
    #                                 hace la copia apenas se encienda
    $opciones = New-ScheduledTaskSettingsSet `
        -AllowStartIfOnBatteries `
        -DontStopIfGoingOnBatteries `
        -StartWhenAvailable `
        -ExecutionTimeLimit (New-TimeSpan -Hours 2)

    Register-ScheduledTask -TaskName $NombreTarea `
        -Action $accion `
        -Trigger $disparador `
        -Settings $opciones `
        -Description "Copia de seguridad diaria de la base de datos del hotel." `
        -Force | Out-Null

    Write-Output ""
    Write-Output "  LISTO. El respaldo automatico quedo programado para las $Hora de cada dia."
    Write-Output ""
    Write-Output "  - Tambien funciona si el computador esta sin cargador."
    Write-Output "  - Si el computador esta apagado a esa hora, la copia se hace"
    Write-Output "    apenas se vuelva a encender."
    exit 0
}
catch {
    Write-Output ""
    Write-Output "  NO SE PUDO PROGRAMAR: $($_.Exception.Message)"
    Write-Output ""
    Write-Output "  Causa mas probable: no se abrio como administrador."
    Write-Output "  Cierre esta ventana, haga clic DERECHO sobre"
    Write-Output "  ProgramarRespaldoDiario.bat y elija 'Ejecutar como administrador'."
    exit 1
}
