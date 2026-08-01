# =============================================================================
#  RESPALDO AUTOMATICO DE LA BASE DE DATOS DEL HOTEL
# =============================================================================
#  Crea una copia de seguridad de DB_HOTEL en una carpeta del disco.
#  Normalmente NO se ejecuta a mano: lo llama el Programador de tareas de
#  Windows todos los dias. Para hacer una copia ahora mismo, usar
#  "RespaldarAhora.bat".
# =============================================================================

# --- Configuracion (lo unico que se puede necesitar cambiar) ------------------

# Nombre del servidor de SQL Server. Debe ser el mismo que aparece en el
# Web.config del sistema.
$Servidor = ".\SQLEXPRESS"

# Carpeta donde se guardan las copias.
$Carpeta = "C:\RespaldosHotel"

# Cuantos dias se conservan las copias viejas antes de borrarlas.
$DiasQueSeConservan = 30

# -----------------------------------------------------------------------------

$BaseDatos = "DB_HOTEL"
$fecha = Get-Date -Format "yyyy-MM-dd_HHmm"
$archivo = Join-Path $Carpeta "$BaseDatos`_$fecha.bak"
$bitacora = Join-Path $Carpeta "respaldos.log"

function Anotar($mensaje) {
    $linea = "[" + (Get-Date -Format "yyyy-MM-dd HH:mm:ss") + "] " + $mensaje
    Write-Output $linea
    try { Add-Content -Path $bitacora -Value $linea -Encoding UTF8 } catch { }
}

try {
    if (-not (Test-Path $Carpeta)) {
        New-Item -ItemType Directory -Path $Carpeta -Force | Out-Null
    }

    $conexion = New-Object System.Data.SqlClient.SqlConnection(
        "Data Source=$Servidor;Initial Catalog=master;Integrated Security=True;TrustServerCertificate=True")
    $conexion.Open()

    $comando = $conexion.CreateCommand()
    $comando.CommandTimeout = 600
    $comando.CommandText = "BACKUP DATABASE [$BaseDatos] TO DISK = @ruta WITH INIT, FORMAT, NAME = 'Respaldo del sistema de hotel'"
    $null = $comando.Parameters.AddWithValue("@ruta", $archivo)
    $null = $comando.ExecuteNonQuery()

    $conexion.Close()

    $tamano = [math]::Round((Get-Item $archivo).Length / 1MB, 2)
    Anotar "OK - copia creada: $archivo ($tamano MB)"

    # Borrar copias mas viejas que el limite configurado.
    $limite = (Get-Date).AddDays(-$DiasQueSeConservan)
    $viejas = Get-ChildItem -Path $Carpeta -Filter "*.bak" | Where-Object { $_.LastWriteTime -lt $limite }
    foreach ($v in $viejas) {
        [System.IO.File]::Delete($v.FullName)
        Anotar "Copia antigua eliminada: $($v.Name)"
    }

    exit 0
}
catch {
    Anotar "ERROR - NO SE PUDO CREAR LA COPIA: $($_.Exception.Message)"
    exit 1
}
