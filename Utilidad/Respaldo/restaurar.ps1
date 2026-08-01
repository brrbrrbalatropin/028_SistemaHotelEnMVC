# =============================================================================
#  RESTAURAR LA BASE DE DATOS DESDE UNA COPIA DE SEGURIDAD
# =============================================================================
#  ATENCION: esto BORRA la informacion actual del sistema y la reemplaza por
#  la de la copia. Todo lo registrado despues de esa copia se pierde.
#
#  Usar solo cuando la base de datos se daño o se perdio informacion.
#  Normalmente se ejecuta desde "RestaurarCopia.bat".
# =============================================================================

$Servidor = ".\SQLEXPRESS"
$Carpeta = "C:\RespaldosHotel"
$BaseDatos = "DB_HOTEL"

Write-Output ""
Write-Output "  COPIAS DISPONIBLES (de la mas reciente a la mas antigua):"
Write-Output ""

$copias = @([System.IO.Directory]::GetFiles($Carpeta, "*.bak") |
            Sort-Object { [System.IO.File]::GetLastWriteTime($_) } -Descending)

if ($copias.Count -eq 0) {
    Write-Output "  No hay ninguna copia en $Carpeta. No se puede restaurar."
    exit 1
}

for ($i = 0; $i -lt $copias.Count; $i++) {
    $f = $copias[$i]
    $fecha = [System.IO.File]::GetLastWriteTime($f).ToString("dd/MM/yyyy HH:mm")
    Write-Output ("   [{0}]  {1}   ({2})" -f ($i + 1), [System.IO.Path]::GetFileName($f), $fecha)
}

Write-Output ""
$opcion = Read-Host "  Escriba el numero de la copia a restaurar (o ENTER para cancelar)"

if ([string]::IsNullOrWhiteSpace($opcion)) {
    Write-Output "  Cancelado. No se cambio nada."
    exit 0
}

$indice = 0
if (-not [int]::TryParse($opcion, [ref]$indice) -or $indice -lt 1 -or $indice -gt $copias.Count) {
    Write-Output "  Opcion no valida. No se cambio nada."
    exit 1
}

$archivo = $copias[$indice - 1]

Write-Output ""
Write-Output "  ============================================================"
Write-Output "   SE VA A REEMPLAZAR TODA LA INFORMACION ACTUAL DEL SISTEMA"
Write-Output "   por la de la copia:"
Write-Output "   $([System.IO.Path]::GetFileName($archivo))"
Write-Output ""
Write-Output "   Todo lo que se haya registrado despues de esa fecha"
Write-Output "   SE VA A PERDER."
Write-Output "  ============================================================"
Write-Output ""
$confirmacion = Read-Host "  Escriba SI (en mayusculas) para continuar"

if ($confirmacion -cne "SI") {
    Write-Output "  Cancelado. No se cambio nada."
    exit 0
}

try {
    Write-Output ""
    Write-Output "  Restaurando, no cierre esta ventana..."

    $conexion = New-Object System.Data.SqlClient.SqlConnection(
        "Data Source=$Servidor;Initial Catalog=master;Integrated Security=True;TrustServerCertificate=True")
    $conexion.Open()

    # Se cierra cualquier conexion abierta al sistema para poder reemplazar la base.
    $cerrar = $conexion.CreateCommand()
    $cerrar.CommandTimeout = 120
    $cerrar.CommandText = "IF DB_ID('$BaseDatos') IS NOT NULL ALTER DATABASE [$BaseDatos] SET SINGLE_USER WITH ROLLBACK IMMEDIATE"
    $null = $cerrar.ExecuteNonQuery()

    $restaurar = $conexion.CreateCommand()
    $restaurar.CommandTimeout = 600
    $restaurar.CommandText = "RESTORE DATABASE [$BaseDatos] FROM DISK = @ruta WITH REPLACE"
    $null = $restaurar.Parameters.AddWithValue("@ruta", $archivo)
    $null = $restaurar.ExecuteNonQuery()

    $abrir = $conexion.CreateCommand()
    $abrir.CommandTimeout = 120
    $abrir.CommandText = "ALTER DATABASE [$BaseDatos] SET MULTI_USER"
    $null = $abrir.ExecuteNonQuery()

    $conexion.Close()

    Write-Output ""
    Write-Output "  LISTO. La informacion quedo restaurada."
    exit 0
}
catch {
    Write-Output ""
    Write-Output "  ERROR: no se pudo restaurar."
    Write-Output "  $($_.Exception.Message)"
    Write-Output ""
    Write-Output "  Avise al administrador del sistema ANTES de seguir usandolo."
    exit 1
}
