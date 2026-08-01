# =============================================================================
#  ARMA EL PAQUETE QUE SE LE ENVIA A LA FAMILIA
# =============================================================================
#  Este script es SOLO PARA EL DESARROLLADOR, no para el hotel.
#
#  Compila el sistema, lo publica y arma la carpeta "Entrega" con todo lo que
#  hay que enviar: la aplicacion, los scripts de la base de datos, las
#  herramientas de respaldo y el instalador.
#
#  Se ejecuta con:   powershell -ExecutionPolicy Bypass -File EmpaquetarParaEntrega.ps1
# =============================================================================

$ErrorActionPreference = "Stop"

$raiz = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$entrega = Join-Path $raiz "Entrega"
$publicado = Join-Path $raiz "Publicado"

function Paso($texto) { Write-Host ""; Write-Host "  >> $texto" }

try {
    # --- 1. Localizar MSBuild ------------------------------------------------
    Paso "Buscando MSBuild"
    $vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
    if (-not (Test-Path $vswhere)) { throw "No se encontro vswhere. Hace falta Visual Studio." }
    $msbuild = & $vswhere -latest -requires Microsoft.Component.MSBuild -find "MSBuild\**\Bin\MSBuild.exe" | Select-Object -First 1
    if (-not $msbuild) { throw "No se encontro MSBuild." }
    Write-Host "     $msbuild"

    # --- 2. Compilar y publicar ---------------------------------------------
    Paso "Compilando y publicando la aplicacion (modo Release)"
    $proyecto = Join-Path $raiz "ProyectoHotel\ProyectoHotel.csproj"
    & $msbuild $proyecto /p:DeployOnBuild=true /p:PublishProfile=PublicarEnCarpeta `
               /p:Configuration=Release /nologo /v:minimal
    if ($LASTEXITCODE -ne 0) { throw "La compilacion fallo. Revise los errores de arriba." }

    # --- 3. Armar la carpeta de entrega -------------------------------------
    Paso "Armando la carpeta Entrega"
    if (Test-Path $entrega) { [System.IO.Directory]::Delete($entrega, $true) }
    New-Item -ItemType Directory -Path $entrega -Force | Out-Null

    # La aplicacion
    $destinoApp = Join-Path $entrega "Aplicacion"
    New-Item -ItemType Directory -Path $destinoApp -Force | Out-Null
    Copy-Item (Join-Path $publicado "*") $destinoApp -Recurse -Force

    # Los scripts de la base de datos
    $destinoBD = Join-Path $entrega "BaseDeDatos"
    New-Item -ItemType Directory -Path $destinoBD -Force | Out-Null
    Copy-Item (Join-Path $raiz "Utilidad\Sql Server\*.sql") $destinoBD -Force

    # Las herramientas de respaldo
    $destinoResp = Join-Path $entrega "Respaldo"
    New-Item -ItemType Directory -Path $destinoResp -Force | Out-Null
    Copy-Item (Join-Path $raiz "Utilidad\Respaldo\*") $destinoResp -Recurse -Force

    # El instalador, en la raiz del paquete
    Copy-Item (Join-Path $raiz "Instalador\InstalarSistema.bat") $entrega -Force
    Copy-Item (Join-Path $raiz "Instalador\instalar.ps1") $entrega -Force

    # El instructivo, si ya existe
    $instructivo = Join-Path $raiz "Instalador\LEEME-PRIMERO.txt"
    if (Test-Path $instructivo) { Copy-Item $instructivo $entrega -Force }

    # --- 4. Resumen ----------------------------------------------------------
    $tamano = [math]::Round(((Get-ChildItem $entrega -Recurse -File | Measure-Object Length -Sum).Sum / 1MB), 1)

    Write-Host ""
    Write-Host "  ========================================================="
    Write-Host "   PAQUETE LISTO"
    Write-Host "  ========================================================="
    Write-Host ""
    Write-Host "   Carpeta:  $entrega"
    Write-Host "   Tamano:   $tamano MB"
    Write-Host ""
    Write-Host "   Contenido:"
    Get-ChildItem $entrega | ForEach-Object {
        $tipo = if ($_.PSIsContainer) { "[carpeta]" } else { "[archivo]" }
        Write-Host ("     {0} {1}" -f $tipo, $_.Name)
    }
    Write-Host ""
    Write-Host "   Comprimir esta carpeta en un .zip y enviarla."
    Write-Host ""
    exit 0
}
catch {
    Write-Host ""
    Write-Host "   NO SE PUDO ARMAR EL PAQUETE:"
    Write-Host "   $($_.Exception.Message)"
    exit 1
}
