# =============================================================================
#  INSTALADOR DEL SISTEMA DEL HOTEL
# =============================================================================
#  Deja el sistema funcionando en este computador:
#    1. Activa el servidor web que ya viene incluido en Windows (IIS)
#    2. Copia el sistema a C:\SistemaHotel
#    3. Lo publica para que se abra desde el navegador
#    4. Crea un acceso directo en el Escritorio
#
#  Se ejecuta desde "InstalarSistema.bat" (clic derecho -> como administrador).
# =============================================================================

$NombreSitio   = "SistemaHotel"
$Puerto        = 8080
$CarpetaDestino = "C:\SistemaHotel"

$ErrorActionPreference = "Stop"
$carpetaPaquete = Split-Path -Parent $MyInvocation.MyCommand.Path
$origenApp = Join-Path $carpetaPaquete "Aplicacion"

function Titulo($texto) {
    Write-Host ""
    Write-Host "  ---------------------------------------------------------"
    Write-Host "   $texto"
    Write-Host "  ---------------------------------------------------------"
}

function Bien($texto) { Write-Host "   OK  - $texto" }
function Aviso($texto) { Write-Host "   !   - $texto" }

try {
    # --- Comprobaciones previas ---------------------------------------------
    $esAdmin = ([Security.Principal.WindowsPrincipal] `
                [Security.Principal.WindowsIdentity]::GetCurrent()
               ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    if (-not $esAdmin) {
        Write-Host ""
        Write-Host "   NO SE PUEDE CONTINUAR."
        Write-Host ""
        Write-Host "   Este instalador necesita permisos de administrador."
        Write-Host "   Cierre esta ventana, haga clic DERECHO sobre"
        Write-Host "   InstalarSistema.bat y elija 'Ejecutar como administrador'."
        exit 1
    }

    if (-not (Test-Path $origenApp)) {
        Write-Host ""
        Write-Host "   NO SE ENCONTRO la carpeta 'Aplicacion' junto a este instalador."
        Write-Host "   Asegurese de haber copiado la carpeta COMPLETA que le enviaron."
        exit 1
    }

    # --- Paso 1: activar IIS -------------------------------------------------
    Titulo "PASO 1 de 4: activando el servidor web de Windows"
    Write-Host "   (esto puede tardar varios minutos, es normal)"

    $componentes = @(
        "IIS-WebServerRole", "IIS-WebServer", "IIS-CommonHttpFeatures",
        "IIS-StaticContent", "IIS-DefaultDocument", "IIS-HttpErrors",
        "IIS-RequestFiltering", "IIS-Security",
        "IIS-ApplicationDevelopment", "IIS-NetFxExtensibility45",
        "IIS-ISAPIExtensions", "IIS-ISAPIFilter", "IIS-ASPNET45",
        "IIS-WebServerManagementTools", "IIS-ManagementConsole"
    )

    foreach ($c in $componentes) {
        $estado = Get-WindowsOptionalFeature -Online -FeatureName $c
        if ($estado.State -ne "Enabled") {
            Enable-WindowsOptionalFeature -Online -FeatureName $c -All -NoRestart | Out-Null
        }
    }
    Bien "servidor web activado"

    Import-Module WebAdministration

    # --- Paso 2: copiar los archivos ----------------------------------------
    Titulo "PASO 2 de 4: copiando el sistema a $CarpetaDestino"

    if (-not (Test-Path $CarpetaDestino)) {
        New-Item -ItemType Directory -Path $CarpetaDestino -Force | Out-Null
    }
    Copy-Item -Path (Join-Path $origenApp "*") -Destination $CarpetaDestino -Recurse -Force
    Bien "archivos copiados"

    # --- Paso 3: publicar el sitio ------------------------------------------
    Titulo "PASO 3 de 4: publicando el sistema"

    if (Test-Path "IIS:\Sites\$NombreSitio") {
        Remove-Website -Name $NombreSitio
    }
    if (Test-Path "IIS:\AppPools\$NombreSitio") {
        Remove-WebAppPool -Name $NombreSitio
    }

    New-WebAppPool -Name $NombreSitio | Out-Null
    Set-ItemProperty "IIS:\AppPools\$NombreSitio" -Name managedRuntimeVersion -Value "v4.0"
    Set-ItemProperty "IIS:\AppPools\$NombreSitio" -Name managedPipelineMode -Value "Integrated"
    Bien "grupo de aplicaciones creado"

    New-Website -Name $NombreSitio -PhysicalPath $CarpetaDestino `
                -ApplicationPool $NombreSitio -Port $Puerto | Out-Null
    Bien "sitio creado en el puerto $Puerto"

    # El sistema necesita poder escribir su archivo de errores en App_Data.
    $appData = Join-Path $CarpetaDestino "App_Data"
    if (-not (Test-Path $appData)) { New-Item -ItemType Directory -Path $appData -Force | Out-Null }
    icacls $appData /grant "IIS APPPOOL\${NombreSitio}:(OI)(CI)M" /T | Out-Null
    Bien "permisos de escritura otorgados"

    Start-Website -Name $NombreSitio
    Bien "sistema iniciado"

    # --- Paso 4: acceso directo ---------------------------------------------
    Titulo "PASO 4 de 4: creando el acceso directo"

    $escritorio = [Environment]::GetFolderPath("CommonDesktopDirectory")
    $atajo = Join-Path $escritorio "Sistema del Hotel.url"
    Set-Content -Path $atajo -Value "[InternetShortcut]`r`nURL=http://localhost:$Puerto/" -Encoding ASCII
    Bien "acceso directo creado en el Escritorio"

    # --- Resultado -----------------------------------------------------------
    Write-Host ""
    Write-Host "  ========================================================="
    Write-Host "   INSTALACION TERMINADA"
    Write-Host "  ========================================================="
    Write-Host ""
    Write-Host "   El sistema queda en:   http://localhost:$Puerto/"
    Write-Host "   Acceso directo:        'Sistema del Hotel' en el Escritorio"
    Write-Host ""
    Write-Host "   FALTA UN ULTIMO PASO IMPORTANTE:"
    Write-Host ""
    Write-Host "   Abrir SQL Server Management Studio y ejecutar el archivo"
    Write-Host "   005_PERMISOS_IIS.sql (esta en la carpeta BaseDeDatos)."
    Write-Host ""
    Write-Host "   Sin ese paso el sistema abre, pero no puede leer los datos."
    Write-Host ""
    exit 0
}
catch {
    Write-Host ""
    Write-Host "  ========================================================="
    Write-Host "   LA INSTALACION NO PUDO TERMINAR"
    Write-Host "  ========================================================="
    Write-Host ""
    Write-Host "   Detalle del problema:"
    Write-Host "   $($_.Exception.Message)"
    Write-Host ""
    Write-Host "   Tome una foto de esta ventana y enviela al administrador"
    Write-Host "   del sistema."
    exit 1
}
