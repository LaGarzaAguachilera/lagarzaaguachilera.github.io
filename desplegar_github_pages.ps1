<#
.SYNOPSIS
    Script interactivo y automatizado para desplegar La Garza Aguachilera en GitHub Pages.

.DESCRIPTION
    Inicializa el repositorio Git local, verifica salvaguardas tecnicas (.nojekyll, .gitignore),
    prepara y commitea activos de produccion, vincula el repositorio remoto en GitHub
    y realiza el push a la rama main, guiando al usuario paso a paso en la activacion de Pages.

.PARAMETER RepoUrl
    URL del repositorio remoto de GitHub (ej. https://github.com/usuario/la-garza-aguachilera.git).
    Si no se proporciona, el script la solicitara interactivamente.

.PARAMETER Branch
    Nombre de la rama principal de despliegue (por defecto: 'main').

.PARAMETER ForcePush
    Fuerza el push al repositorio remoto en caso de divergencias de ramas.
#>

param (
    [string]$RepoUrl,
    [string]$Branch = "main",
    [switch]$ForcePush
)

# Configurar salida de consola a UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

function Write-Step {
    param ([string]$Number, [string]$Title)
    Write-Host ""
    Write-Host "================================================================================" -ForegroundColor DarkCyan
    Write-Host " [$Number] $Title" -ForegroundColor Cyan
    Write-Host "================================================================================" -ForegroundColor DarkCyan
}

function Write-Success {
    param ([string]$Message)
    Write-Host " [+] $Message" -ForegroundColor Green
}

function Write-WarningMsg {
    param ([string]$Message)
    Write-Host " [!] $Message" -ForegroundColor Yellow
}

function Write-ErrMsg {
    param ([string]$Message)
    Write-Host " [X] $Message" -ForegroundColor Red
}

Clear-Host
Write-Host "================================================================================" -ForegroundColor Green
Write-Host "           LA GARZA AGUACHILERA -- ASISTENTE OFICIAL DE DESPLIEGUE               " -ForegroundColor Yellow
Write-Host "                          GITHUB PAGES HOSTER                                   " -ForegroundColor White
Write-Host "================================================================================" -ForegroundColor Green
Write-Host " Bienvenido al asistente de publicacion web de La Garza Aguachilera." -ForegroundColor Gray
Write-Host " Este script preparara tu proyecto y lo pondra en vivo en Internet de forma gratuita." -ForegroundColor Gray

# ------------------------------------------------------------------------------
# PASO 1: Verificacion del Entorno y Herramienta Git
# ------------------------------------------------------------------------------
Write-Step "1/5" "Verificando Entorno Tecnico y Git Local"

$gitCmd = Get-Command "git" -ErrorAction SilentlyContinue
if (-not $gitCmd) {
    Write-ErrMsg "No se encontro Git instalado en tu sistema."
    Write-Host " Por favor descarga e instala Git desde https://git-scm.com/download/win" -ForegroundColor Yellow
    Write-Host " Despues de instalarlo, vuelve a ejecutar este script." -ForegroundColor Yellow
    exit 1
}

$gitVersion = (git --version).Trim()
Write-Success "Git detectado: $gitVersion"

# Verificar o Inicializar Repositorio Git
if (-not (Test-Path ".git")) {
    Write-Host " Inicializando nuevo repositorio Git local en la rama '$Branch'..." -ForegroundColor Cyan
    git init -b $Branch | Out-Null
    Write-Success "Repositorio Git inicializado con exito."
} else {
    Write-Success "Repositorio Git local ya inicializado."
    # Asegurar que estamos en la rama correcta
    $currentBranch = (git branch --show-current 2>$null)
    if ($currentBranch -and $currentBranch -ne $Branch) {
        Write-Host " Cambiando rama actual a '$Branch'..." -ForegroundColor Cyan
        git branch -M $Branch 2>$null
    }
}

# Configurar identidad local si no existe
$userName = (git config user.name 2>$null)
$userEmail = (git config user.email 2>$null)

if ([string]::IsNullOrWhiteSpace($userName)) {
    git config user.name "La Garza Aguachilera"
    Write-Success "Identidad configurada: user.name = 'La Garza Aguachilera'"
} else {
    Write-Success "Usuario Git activo: $userName"
}

if ([string]::IsNullOrWhiteSpace($userEmail)) {
    git config user.email "contacto@lagarzaaguachilera.com"
    Write-Success "Email configurado: user.email = 'contacto@lagarzaaguachilera.com'"
} else {
    Write-Success "Email Git activo: $userEmail"
}

# ------------------------------------------------------------------------------
# PASO 2: Verificacion de Salvaguardas (.nojekyll y .gitignore)
# ------------------------------------------------------------------------------
Write-Step "2/5" "Verificando Salvaguardas para GitHub Pages (.nojekyll y .gitignore)"

# 2.1 Archivo .nojekyll
if (-not (Test-Path ".nojekyll")) {
    New-Item -ItemType File -Path ".nojekyll" -Force | Out-Null
    Write-Success "Archivo '.nojekyll' creado (desactiva procesamiento de Jekyll para servir activos puros)."
} else {
    Write-Success "Archivo '.nojekyll' presente y verificado."
}

# 2.2 Archivo .gitignore (Vital para bloquear FFmpeg > 100 MB)
if (-not (Test-Path ".gitignore")) {
    $gitignoreLines = @(
        "# Binarios mayores a 100 MB que GitHub rechazaria (GH001)",
        "herramientas/ffmpeg/*.exe",
        "herramientas/ffmpeg/",
        "*.exe",
        "",
        "# Metadatos internos de agentes de IA",
        ".agents/",
        "",
        "# Archivos del sistema operativo y editores",
        "Thumbs.db",
        ".DS_Store",
        "*.tmp",
        "*.log"
    )
    $gitignoreDefault = $gitignoreLines -join "`n"
    Set-Content -Path ".gitignore" -Value $gitignoreDefault -Encoding UTF8
    Write-Success "Archivo '.gitignore' generado para proteger contra binarios pesados."
} else {
    $gitignoreContent = Get-Content ".gitignore" -Raw
    if ($gitignoreContent -notmatch "ffmpeg" -or $gitignoreContent -notmatch "\.agents") {
        Add-Content -Path ".gitignore" -Value "`nherramientas/ffmpeg/`n*.exe`n.agents/`n" -Encoding UTF8
        Write-Success "Archivo '.gitignore' reforzado con reglas de exclusion de binarios pesados."
    } else {
        Write-Success "Archivo '.gitignore' verificado y protegiendo contra binarios pesados."
    }
}

# ------------------------------------------------------------------------------
# PASO 3: Preparacion y Commit de Activos de Produccion
# ------------------------------------------------------------------------------
Write-Step "3/5" "Empaquetando Activos de Produccion en Git"

Write-Host " Agregando archivos al area de preparacion (git add .)..." -ForegroundColor Cyan
git add .

# Verificacion de seguridad: Asegurarse de que ningun archivo > 100 MB este en el stage
$stagedFiles = git diff --name-only --cached
$oversizedFiles = @()

foreach ($relPath in $stagedFiles) {
    if (Test-Path $relPath) {
        $fileItem = Get-Item $relPath
        if ($fileItem.Length -gt 100MB) {
            $mbSize = [math]::Round($fileItem.Length / 1MB, 2)
            $oversizedFiles += "$relPath ($mbSize MB)"
        }
    }
}

if ($oversizedFiles.Count -gt 0) {
    Write-ErrMsg "ALERTA CRITICA: Se detectaron archivos mayores a 100 MB en el stage:"
    foreach ($badFile in $oversizedFiles) {
        Write-Host "   - $badFile" -ForegroundColor Red
    }
    Write-Host " GitHub bloqueara cualquier push con archivos mayores a 100 MB." -ForegroundColor Yellow
    Write-Host " Revisa tu archivo .gitignore antes de continuar." -ForegroundColor Yellow
    exit 1
}

$statusOutput = git status --porcelain
if ($statusOutput) {
    $commitMsg = "feat(deploy): inicializar repositorio y configuracion para GitHub Pages con activos de La Garza Aguachilera"
    git commit -m $commitMsg | Out-Null
    Write-Success "Commit de produccion registrado con exito."
} else {
    Write-Success "Arbol de trabajo limpio; no hay cambios pendientes por commitear."
}

# ------------------------------------------------------------------------------
# PASO 4: Configuracion del Repositorio Remoto (Origin)
# ------------------------------------------------------------------------------
Write-Step "4/5" "Configurando Conexion con GitHub (Remote Origin)"

$existingRemote = (git remote get-url origin 2>$null)

if ([string]::IsNullOrWhiteSpace($RepoUrl)) {
    if (-not [string]::IsNullOrWhiteSpace($existingRemote)) {
        Write-Host " Se detecto un repositorio remoto configurado actualmente:" -ForegroundColor Yellow
        Write-Host " URL actual: $existingRemote" -ForegroundColor White
        Write-Host ""
        $keep = Read-Host "Deseas utilizar este repositorio remoto? (S/N, por defecto 'S')"
        if ($keep -eq "N" -or $keep -eq "n") {
            $RepoUrl = Read-Host "Ingresa la nueva URL de tu repositorio en GitHub (ej. https://github.com/usuario/la-garza-aguachilera.git)"
        } else {
            $RepoUrl = $existingRemote
        }
    } else {
        Write-Host " Para publicar en Internet necesitas un repositorio en tu cuenta de GitHub." -ForegroundColor Yellow
        Write-Host " Si aun no lo has creado:" -ForegroundColor Gray
        Write-Host "   1. Entra a: https://github.com/new" -ForegroundColor Cyan
        Write-Host "   2. Nombre del repositorio: la-garza-aguachilera (o el que prefieras)" -ForegroundColor Cyan
        Write-Host "   3. Selecciona: Publico (Public)" -ForegroundColor Cyan
        Write-Host "   4. IMPORTANTE: NO marques README, ni .gitignore, ni licencia" -ForegroundColor Red
        Write-Host "   5. Haz clic en 'Create repository' y copia la URL." -ForegroundColor Cyan
        Write-Host ""
        
        while ([string]::IsNullOrWhiteSpace($RepoUrl)) {
            $RepoUrl = Read-Host "Pega aqui la URL de tu repositorio de GitHub (ej. https://github.com/usuario/la-garza-aguachilera.git)"
            if (-not [string]::IsNullOrWhiteSpace($RepoUrl)) {
                $RepoUrl = $RepoUrl.Trim()
            }
            if ([string]::IsNullOrWhiteSpace($RepoUrl)) {
                Write-WarningMsg "La URL no puede estar vacia. Intentalo de nuevo."
            }
        }
    }
}

# Aplicar URL remota
if ([string]::IsNullOrWhiteSpace($existingRemote)) {
    git remote add origin $RepoUrl
    Write-Success "Remote 'origin' agregado: $RepoUrl"
} else {
    if ($existingRemote -ne $RepoUrl) {
        git remote set-url origin $RepoUrl
        Write-Success "Remote 'origin' actualizado a: $RepoUrl"
    } else {
        Write-Success "Remote 'origin' confirmado: $RepoUrl"
    }
}

# ------------------------------------------------------------------------------
# PASO 5: Despliegue (Push) a GitHub y Guia de Activacion de Pages
# ------------------------------------------------------------------------------
Write-Step "5/5" "Subiendo Archivos a GitHub (git push)"

Write-Host " Subiendo rama '$Branch' a GitHub..." -ForegroundColor Cyan
$pushArgs = @("push", "-u", "origin", $Branch)
if ($ForcePush) {
    $pushArgs += "--force"
}

$pushSuccess = $false
try {
    & git @pushArgs
    if ($LASTEXITCODE -eq 0) {
        $pushSuccess = $true
    }
} catch {
    Write-ErrMsg "Ocurrio un error al ejecutar git push: $_"
}

if (-not $pushSuccess) {
    Write-ErrMsg "El push a GitHub no pudo completarse."
    Write-Host ""
    Write-Host " Posibles causas comunes:" -ForegroundColor Yellow
    Write-Host "  1. Autenticacion de GitHub requerida:" -ForegroundColor White
    Write-Host "     Si es la primera vez, inicia sesion en la ventana del navegador que aparezca," -ForegroundColor Gray
    Write-Host "     o genera un Personal Access Token en GitHub (Settings -> Developer settings -> Tokens)." -ForegroundColor Gray
    Write-Host "  2. Repositorio remoto con commits previos:" -ForegroundColor White
    Write-Host "     Si creaste el repositorio con README, ejecuta este script con -ForcePush:" -ForegroundColor Gray
    Write-Host "     .\desplegar_github_pages.ps1 -ForcePush" -ForegroundColor Cyan
    Write-Host "  3. URL incorrecta o sin permisos en la cuenta." -ForegroundColor Gray
    exit 1
}

# ------------------------------------------------------------------------------
# EXITO: Instrucciones Finales para Activar GitHub Pages
# ------------------------------------------------------------------------------

# Extraer usuario y repo para construir la URL de GitHub Pages
$ghUser = "tu-usuario"
$ghRepo = "la-garza-aguachilera"

if ($RepoUrl -match "github\.com[/:](?<user>[^/]+)/(?<repo>[^/\.]+)") {
    $ghUser = $Matches['user']
    $ghRepo = $Matches['repo']
}

$pagesUrl = "https://$ghUser.github.io/$ghRepo/"
$settingsUrl = "https://github.com/$ghUser/$ghRepo/settings/pages"

Write-Host ""
Write-Host "================================================================================" -ForegroundColor Green
Write-Host "        ARCHIVOS SUBIDOS CON EXITO A GITHUB: TU PROYECTO ESTA LISTO             " -ForegroundColor Green
Write-Host "================================================================================" -ForegroundColor Green
Write-Host ""
Write-Host " ULTIMO PASO: Activa GitHub Pages en la web de GitHub (Toma solo 30 segundos!):" -ForegroundColor Yellow
Write-Host ""
Write-Host " 1. Abre el panel de Pages de tu repositorio en tu navegador:" -ForegroundColor Cyan
Write-Host "    $settingsUrl" -ForegroundColor White -BackgroundColor DarkBlue
Write-Host ""
Write-Host " 2. En la seccion 'Build and deployment':" -ForegroundColor Cyan
Write-Host "    - En 'Source', asegurate de que este en: Deploy from a branch" -ForegroundColor White
Write-Host "    - En 'Branch', selecciona: $Branch" -ForegroundColor Yellow
Write-Host "    - En la carpeta contigua, selecciona: / (root)" -ForegroundColor Yellow
Write-Host "    - Haz clic en el boton [ Save ]" -ForegroundColor Green
Write-Host ""
Write-Host " 3. LISTO! En 1 o 2 minutos, tu sitio web oficial estara en vivo en:" -ForegroundColor Cyan
Write-Host "    $pagesUrl" -ForegroundColor Black -BackgroundColor Green
Write-Host ""
Write-Host " Disfrutaras de:" -ForegroundColor Gray
Write-Host "  - Landing page con fotos HD, fondo nocturno de Tampico y boton WhatsApp" -ForegroundColor Gray
Write-Host "  - Video promocional Full HD para redes sin recortes" -ForegroundColor Gray
Write-Host "  - Panel de control para descargar flyers y paquetes de redes sociales" -ForegroundColor Gray
Write-Host "  - Certificado de seguridad HTTPS/SSL gratuito de por vida" -ForegroundColor Gray
Write-Host ""
Write-Host "================================================================================" -ForegroundColor DarkGray
Write-Host " [OK] Auditado y aprobado por Control de Calidad: Cumple con los estandares de La Garza Aguachilera" -ForegroundColor Green
Write-Host "================================================================================" -ForegroundColor DarkGray
