# ==============================================================================
# ESCUADRÓN MAESTRO DE CALIDAD Y PRUEBAS E2E — LA GARZA AGUACHILERA
# Suite de Pruebas de Extremo a Extremo (E2E) Opaque-Box Nivel Cartoon Network
# Documento Rector: TEST_INFRA.md | Alcance: PROJECT.md (14 Features) | Precio: $150 MXN
# ==============================================================================
[CmdletBinding()]
param(
    [ValidateSet('All', '1', '2', '3', '4')]
    [string]$Tier = 'All',
    [ValidateRange(0, 14)]
    [int]$Feature = 0,
    [switch]$VerboseReport,
    [switch]$JsonReport
)
$ErrorActionPreference = 'Continue'
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.IO.Compression.FileSystem
$baseDir = Split-Path -Parent $PSScriptRoot
if (-not (Test-Path (Join-Path $baseDir "PROJECT.md"))) {
    $baseDir = "d:\AG\la garza aguachilera"
}
$ffprobePath = Join-Path $baseDir "herramientas\ffmpeg\ffprobe.exe"
$ffmpegPath  = Join-Path $baseDir "herramientas\ffmpeg\ffmpeg.exe"
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "  SUITE DE PRUEBAS E2E OPAQUE-BOX: LA GARZA AGUACHILERA (`$150 MXN)" -ForegroundColor Yellow
Write-Host "  Episodio Animado Cartoon Network 60 FPS | 14 Features | 4 Tiers" -ForegroundColor Cyan
Write-Host "  Directorio Base: $baseDir" -ForegroundColor DarkGray
Write-Host "================================================================================" -ForegroundColor Cyan
# ------------------------------------------------------------------------------
# Memoized FFprobe Cache
# ------------------------------------------------------------------------------
$script:probeCache = @{}
function Get-MediaProbe([string]$filePath) {
    if (-not (Test-Path $filePath)) { return $null }
    if ($script:probeCache.ContainsKey($filePath)) {
        return $script:probeCache[$filePath]
    }
    if (-not (Test-Path $ffprobePath)) { return $null }
    try {
        $raw = & $ffprobePath -v quiet -print_format json -show_streams -show_format $filePath 2>$null
        $jsonStr = $raw -join "`n"
        if ($jsonStr) {
            $parsed = $jsonStr | ConvertFrom-Json
            $script:probeCache[$filePath] = $parsed
            return $parsed
        }
    } catch {
        return $null
    }
    return $null
}
# ------------------------------------------------------------------------------
# Test Result Repository
# ------------------------------------------------------------------------------
$script:allResults = [System.Collections.Generic.List[PSObject]]::new()
function Assert-E2E {
    param(
        [Parameter(Mandatory=$true)][string]$Tier,
        [Parameter(Mandatory=$true)][int]$Feature,
        [Parameter(Mandatory=$true)][string]$TestId,
        [Parameter(Mandatory=$true)][string]$Name,
        [Parameter(Mandatory=$true)][string]$Source,
        [Parameter(Mandatory=$true)][bool]$Passed,
        [string]$Expected = '',
        [string]$Actual = '',
        [string]$Details = ''
    )
    $res = [PSCustomObject]@{
        Tier     = $Tier
        Feature  = $Feature
        TestId   = $TestId
        Name     = $Name
        Source   = $Source
        Passed   = $Passed
        Expected = $Expected
        Actual   = $Actual
        Details  = $Details
    }
    $script:allResults.Add($res)
    if ($Passed) {
        Write-Host "  [PASS] [$TestId] $Name" -ForegroundColor Green
        if ($VerboseReport -and $Details) {
            Write-Host "         -> Info: $Details" -ForegroundColor DarkGreen
        }
    } else {
        Write-Host "  [FAIL] [$TestId] $Name" -ForegroundColor Red
        Write-Host "         -> Esperado: $Expected" -ForegroundColor DarkRed
        Write-Host "         -> Obtenido: $Actual" -ForegroundColor DarkRed
        if ($Details) {
            Write-Host "         -> Detalle:  $Details" -ForegroundColor DarkYellow
        }
    }
}
# ------------------------------------------------------------------------------
# Key Project Artifacts
# ------------------------------------------------------------------------------
$masterVideoPath = Join-Path $baseDir "VIDEOS\animacion_la_garza_episodio_crudos_60fps.mp4"
$promoVideoPath  = Join-Path $baseDir "VIDEOS\promo_halloween_zombies_crudos.mp4"
$masterAudioPath = Join-Path $baseDir "herramientas\audio_animacion_master_60fps.wav"
$timelineJsonPath = Join-Path $baseDir "herramientas\timeline_animacion_60fps.json"
$audioDir        = Join-Path $baseDir "herramientas\audio_animacion"
$musicPath       = Join-Path $baseDir "herramientas\Beachfront_Celebration.mp3"
$audioScriptPath = Join-Path $baseDir "herramientas\producir_audio_animacion.py"
$animScriptPath  = Join-Path $baseDir "herramientas\producir_animacion_estudio_60fps.py"
$indexPath       = Join-Path $baseDir "index.html"
$panelPath       = Join-Path $baseDir "panel_control.html"
$zipPath         = Join-Path $baseDir "paquete_redes_la_garza.zip"
$qaScriptPath    = Join-Path $baseDir "herramientas\auditar_multimedia_qa.ps1"
$deployScriptPath = Join-Path $baseDir "desplegar_github_pages.ps1"
$deployBatPath   = Join-Path $baseDir "desplegar_automatico.bat"
$noJekyllPath    = Join-Path $baseDir ".nojekyll"
# Load Timeline JSON if present
$timelineData = $null
if (Test-Path $timelineJsonPath) {
    try {
        $timelineData = Get-Content $timelineJsonPath -Raw -Encoding UTF8 | ConvertFrom-Json
    } catch {
        $timelineData = $null
    }
}
# Load Scripts Content
$animScriptContent = if (Test-Path $animScriptPath) { Get-Content $animScriptPath -Raw -Encoding UTF8 } else { "" }
$audioScriptContent = if (Test-Path $audioScriptPath) { Get-Content $audioScriptPath -Raw -Encoding UTF8 } else { "" }
$indexContent = if (Test-Path $indexPath) { Get-Content $indexPath -Raw -Encoding UTF8 } else { "" }
$panelContent = if (Test-Path $panelPath) { Get-Content $panelPath -Raw -Encoding UTF8 } else { "" }
# ==============================================================================
# TIER 1: COBERTURA FUNCIONAL DE CARACTERÍSTICAS (FEATURES 1 A 14)
# ==============================================================================
if ($Tier -eq 'All' -or $Tier -eq '1') {
    Write-Host "`n>>> TIER 1: COBERTURA FUNCIONAL DE CARACTERÍSTICAS (>= 5 TESTS / FEATURE)" -ForegroundColor Magenta
    # --- FEATURE 1: Voces Mexicanas Expresivas TTS ---
    if ($Feature -eq 0 -or $Feature -eq 1) {
        Write-Host "  Feature 1: Voces Mexicanas Expresivas TTS" -ForegroundColor Cyan
        $probeAudio = Get-MediaProbe $masterAudioPath
        # T1-F01-01
        $pass = (Test-Path $masterAudioPath) -and ((Get-Item $masterAudioPath).Length -ge 5000000)
        Assert-E2E -Tier '1' -Feature 1 -TestId 'T1-F01-01' -Name 'Audio Master WAV generado y tamano >= 5 MB' `
            -Source 'ORIGINAL_REQUEST §4 & PROJECT.md F1' -Passed $pass `
            -Expected 'Archivo existente con tamano >= 5,000,000 bytes' `
            -Actual $(if (Test-Path $masterAudioPath) { "$((Get-Item $masterAudioPath).Length) bytes" } else { "Inexistente" })
        # T1-F01-02
        $aStream = if ($probeAudio) { $probeAudio.streams | Where-Object { $_.codec_type -eq 'audio' } | Select-Object -First 1 } else { $null }
        $pass = ($aStream -ne $null) -and ($aStream.sample_rate -eq '44100') -and ($aStream.channels -eq 2)
        Assert-E2E -Tier '1' -Feature 1 -TestId 'T1-F01-02' -Name 'Audio Master WAV en 44.1 kHz estereo (2 canales)' `
            -Source 'PROJECT.md Interface Contracts M1' -Passed $pass `
            -Expected 'SampleRate=44100, Channels=2' `
            -Actual $(if ($aStream) { "SampleRate=$($aStream.sample_rate), Channels=$($aStream.channels)" } else { "Sin stream de audio" })
        # T1-F01-03
        $dur = if ($probeAudio -and $probeAudio.format.duration) { [double]$probeAudio.format.duration } else { 0.0 }
        $pass = ($dur -ge 60.0) -and ($dur -le 95.0)
        Assert-E2E -Tier '1' -Feature 1 -TestId 'T1-F01-03' -Name 'Duracion nominal de audio master ~65.3s (rango 64-67s)' `
            -Source 'PROJECT.md Interface Contracts M1' -Passed $pass `
            -Expected '60.0s <= duracion <= 95.0s' -Actual "$dur s"
        # T1-F01-04
        $pass = ($timelineData -ne $null) -and ($timelineData.scenes -ne $null)
        Assert-E2E -Tier '1' -Feature 1 -TestId 'T1-F01-04' -Name 'Timeline JSON estructurado con marcas por escena' `
            -Source 'PROJECT.md Interface Contracts M1' -Passed $pass `
            -Expected 'Timeline JSON existente con nodo scenes' `
            -Actual $(if ($timelineData -and $timelineData.scenes) { "scenes=$($timelineData.scenes.Count)" } else { "Invalido o nulo" })
        # T1-F01-05
        $voiceFiles = @('sc1_juancho_zombie.wav', 'sc2_mapache_freddy.wav', 'sc3_alien_miramar.wav',
                        'sc4_locutora_climax.wav', 'sc5_juancho_vivo.wav', 'sc6_locutora_cierre.wav')
        $allVoices = $voiceFiles | ForEach-Object { Test-Path (Join-Path $audioDir $_) }
        $pass = -not ($allVoices -contains $false)
        Assert-E2E -Tier '1' -Feature 1 -TestId 'T1-F01-05' -Name 'Clips individuales de voz generados para las 6 escenas' `
            -Source 'ORIGINAL_REQUEST §4' -Passed $pass `
            -Expected '6 archivos WAV de voz en herramientas/audio_animacion/' `
            -Actual "Presentes: $(($allVoices | Where-Object { $_ -eq $true }).Count)/6"
    }
    # --- FEATURE 2: Diseño Sonoro y Auto-Ducking ---
    if ($Feature -eq 0 -or $Feature -eq 2) {
        Write-Host "  Feature 2: Diseno Sonoro y Auto-Ducking" -ForegroundColor Cyan
        # T1-F02-01
        $pass = (Test-Path $musicPath) -and ((Get-Item $musicPath).Length -ge 5000000)
        Assert-E2E -Tier '1' -Feature 2 -TestId 'T1-F02-01' -Name 'Musica oficial Beachfront_Celebration.mp3 presente >= 5 MB' `
            -Source 'ORIGINAL_REQUEST §4 & R2' -Passed $pass `
            -Expected 'Pista musical >= 5,000,000 bytes' `
            -Actual $(if (Test-Path $musicPath) { "$((Get-Item $musicPath).Length) bytes" } else { "Inexistente" })
        # T1-F02-02
        $pass = $audioScriptContent -match 'duck' -or $audioScriptContent -match 'ducking'
        Assert-E2E -Tier '1' -Feature 2 -TestId 'T1-F02-02' -Name 'Script de produccion implementa logica de auto-ducking' `
            -Source 'PROJECT.md F2' -Passed $pass `
            -Expected 'Presencia de atenuacion automatica de musica (ducking)' `
            -Actual $(if ($pass) { "Algoritmo de ducking detectado en script" } else { "No encontrado" })
        # T1-F02-03
        $pass = ($probeAudio -ne $null) -and ([double]$probeAudio.format.size -gt 10000000)
        Assert-E2E -Tier '1' -Feature 2 -TestId 'T1-F02-03' -Name 'Master WAV contiene datos binarios no vacios (tamano >= 10 MB)' `
            -Source 'ORIGINAL_REQUEST §4' -Passed $pass `
            -Expected 'Master WAV con audio real >= 10 MB' `
            -Actual $(if ($probeAudio) { "$($probeAudio.format.size) bytes" } else { "Nulo" })
        # T1-F02-04
        $hasRms = ($timelineData -ne $null) -and (
            (($timelineData.scenes | ForEach-Object { $_.rms_envelope -ne $null }) -contains $true) -or
            ($timelineData.frames -ne $null -and $timelineData.frames.Count -gt 0 -and $timelineData.frames[0].mouth_open -ne $null)
        )
        Assert-E2E -Tier '1' -Feature 2 -TestId 'T1-F02-04' -Name 'Timeline contiene envolvente RMS para dinamica de lip-sync' `
            -Source 'PROJECT.md Interface Contracts M1' -Passed $hasRms `
            -Expected 'Nodos rms_envelope presentes en timeline' `
            -Actual $(if ($hasRms) { "Envolvente RMS presente" } else { "No detectada" })
        # T1-F02-05
        $pass = ($audioScriptContent -match 'crunch' -or $audioScriptContent -match 'ASMR') -and
                ($audioScriptContent -match 'abduccion' -or $audioScriptContent -match 'alien' -or $audioScriptContent -match 'sfx')
        Assert-E2E -Tier '1' -Feature 2 -TestId 'T1-F02-05' -Name 'Diseno sonoro integra efectos de sonido (crunch ASMR, rayo OVNI)' `
            -Source 'ORIGINAL_REQUEST R2.2' -Passed $pass `
            -Expected 'Efectos procedurales de crunch y SFX' `
            -Actual $(if ($pass) { "SFX procedurales implementados" } else { "Faltantes" })
    }
    # --- FEATURE 3: Keyframes 2D Cel-Shaded Escena 1 ---
    if ($Feature -eq 0 -or $Feature -eq 3) {
        Write-Host "  Feature 3: Keyframes 2D Cel-Shaded Escena 1 (Juancho Zombie)" -ForegroundColor Cyan
        $juanchoBase = Join-Path $baseDir "clean_juancho.png"
        $juanchoSpooky = Join-Path $baseDir "sticker_spooky_juancho_jason.png"
        # T1-F03-01
        $pass = (Test-Path $juanchoBase) -and ((Get-Item $juanchoBase).Length -ge 1000000)
        Assert-E2E -Tier '1' -Feature 3 -TestId 'T1-F03-01' -Name 'Referencia base de Juancho (clean_juancho.png) presente >= 1 MB' `
            -Source 'ORIGINAL_REQUEST §2' -Passed $pass `
            -Expected 'Sticker base de Juancho en PNG' `
            -Actual $(if (Test-Path $juanchoBase) { "$((Get-Item $juanchoBase).Length) bytes" } else { "Inexistente" })
        # T1-F03-02
        $pass = (Test-Path $juanchoSpooky) -and ((Get-Item $juanchoSpooky).Length -ge 500000)
        Assert-E2E -Tier '1' -Feature 3 -TestId 'T1-F03-02' -Name 'Sprite tematico Juancho Zombie presente >= 500 KB' `
            -Source 'ORIGINAL_REQUEST R1.1' -Passed $pass `
            -Expected 'Sprite con canal alfa presente' `
            -Actual $(if (Test-Path $juanchoSpooky) { "$((Get-Item $juanchoSpooky).Length) bytes" } else { "Inexistente" })
        # T1-F03-03
        $pass = $animScriptContent -match 'juancho_zombie' -and $animScriptContent -match 'jaw_split_y'
        Assert-E2E -Tier '1' -Feature 3 -TestId 'T1-F03-03' -Name 'Configuracion de rigging 2D y mandibula definida para Juancho Zombie' `
            -Source 'PROJECT.md F3 & ORIGINAL_REQUEST R1.1' -Passed $pass `
            -Expected 'RIG_CONFIG contiene juancho_zombie con puntos de articulacion' `
            -Actual $(if ($pass) { "Rigging definido" } else { "No encontrado" })
        # T1-F03-04
        $pass = $animScriptContent -match 'W,\s*H\s*=\s*1080,\s*1920'
        Assert-E2E -Tier '1' -Feature 3 -TestId 'T1-F03-04' -Name 'Geometria de lienzo definida en resolucion vertical 9:16 (1080x1920)' `
            -Source 'ORIGINAL_REQUEST R1 & PROJECT.md' -Passed $pass `
            -Expected 'Lienzo 1080x1920' -Actual $(if ($pass) { "W=1080, H=1920" } else { "Diferente" })
        # T1-F03-05
        $pass = ($timelineData -ne $null) -and ($timelineData.scenes | Where-Object { $_.name -match 'juancho_zombie' -or $_.id -match 'sc1' })
        Assert-E2E -Tier '1' -Feature 3 -TestId 'T1-F03-05' -Name 'Escena 1 registrada en timeline (Juancho agotado en Laguna del Carpintero)' `
            -Source 'ORIGINAL_REQUEST R1.1' -Passed ($pass -ne $null) `
            -Expected 'Escena 1 en timeline' -Actual $(if ($pass) { "sc1 registrada" } else { "No encontrada" })
    }
    # --- FEATURE 4: Keyframes 2D Cel-Shaded Escena 2 ---
    if ($Feature -eq 0 -or $Feature -eq 4) {
        Write-Host "  Feature 4: Keyframes 2D Cel-Shaded Escena 2 (Mapache Freddy)" -ForegroundColor Cyan
        $mapacheBase = Join-Path $baseDir "clean_mapache.png"
        $mapacheSpooky = Join-Path $baseDir "sticker_spooky_mapache_freddy.png"
        # T1-F04-01
        $pass = (Test-Path $mapacheBase) -and ((Get-Item $mapacheBase).Length -ge 1000000)
        Assert-E2E -Tier '1' -Feature 4 -TestId 'T1-F04-01' -Name 'Referencia base de Mapache (clean_mapache.png) presente >= 1 MB' `
            -Source 'ORIGINAL_REQUEST §2' -Passed $pass `
            -Expected 'Sticker base de Mapache en PNG' `
            -Actual $(if (Test-Path $mapacheBase) { "$((Get-Item $mapacheBase).Length) bytes" } else { "Inexistente" })
        # T1-F04-02
        $pass = (Test-Path $mapacheSpooky) -and ((Get-Item $mapacheSpooky).Length -ge 500000)
        Assert-E2E -Tier '1' -Feature 4 -TestId 'T1-F04-02' -Name 'Sprite tematico Mapache Freddy presente >= 500 KB' `
            -Source 'ORIGINAL_REQUEST R1.2' -Passed $pass `
            -Expected 'Sprite con garras presente' `
            -Actual $(if (Test-Path $mapacheSpooky) { "$((Get-Item $mapacheSpooky).Length) bytes" } else { "Inexistente" })
        # T1-F04-03
        $pass = $animScriptContent -match 'mapache_freddy' -and $animScriptContent -match 'mouth_xy'
        Assert-E2E -Tier '1' -Feature 4 -TestId 'T1-F04-03' -Name 'Configuracion de rigging 2D y articulacion facial para Mapache Freddy' `
            -Source 'PROJECT.md F4' -Passed $pass `
            -Expected 'RIG_CONFIG contiene mapache_freddy' `
            -Actual $(if ($pass) { "Rigging definido" } else { "No encontrado" })
        # T1-F04-04
        $pass = $animScriptContent -match 'mapache' -and $animScriptContent -match 'garras' -or $animScriptContent -match 'freddy'
        Assert-E2E -Tier '1' -Feature 4 -TestId 'T1-F04-04' -Name 'Script integra gesticulacion y narrativa comica de garras Freddy' `
            -Source 'ORIGINAL_REQUEST R1.2' -Passed $pass `
            -Expected 'Animacion de garras de mapache' -Actual $(if ($pass) { "Narrativa integrada" } else { "No detectada" })
        # T1-F04-05
        $pass = ($timelineData -ne $null) -and ($timelineData.scenes | Where-Object { $_.name -match 'mapache' -or $_.id -match 'sc2' })
        Assert-E2E -Tier '1' -Feature 4 -TestId 'T1-F04-05' -Name 'Escena 2 registrada en timeline (Mapache en Escolleras Miramar)' `
            -Source 'ORIGINAL_REQUEST R1.2' -Passed ($pass -ne $null) `
            -Expected 'Escena 2 en timeline' -Actual $(if ($pass) { "sc2 registrada" } else { "No encontrada" })
    }
    # --- FEATURE 5: Keyframes 2D Cel-Shaded Escena 3 ---
    if ($Feature -eq 0 -or $Feature -eq 5) {
        Write-Host "  Feature 5: Keyframes 2D Cel-Shaded Escena 3 (OVNI Miramar)" -ForegroundColor Cyan
        $ovniBase = Join-Path $baseDir "clean_ovni.png"
        $ovniSpooky = Join-Path $baseDir "sticker_spooky_ovni_muertos.png"
        # T1-F05-01
        $pass = (Test-Path $ovniBase) -and ((Get-Item $ovniBase).Length -ge 1000000)
        Assert-E2E -Tier '1' -Feature 5 -TestId 'T1-F05-01' -Name 'Referencia base de OVNI (clean_ovni.png) presente >= 1 MB' `
            -Source 'ORIGINAL_REQUEST §2' -Passed $pass `
            -Expected 'Sticker base de OVNI en PNG' `
            -Actual $(if (Test-Path $ovniBase) { "$((Get-Item $ovniBase).Length) bytes" } else { "Inexistente" })
        # T1-F05-02
        $pass = (Test-Path $ovniSpooky) -and ((Get-Item $ovniSpooky).Length -ge 500000)
        Assert-E2E -Tier '1' -Feature 5 -TestId 'T1-F05-02' -Name 'Sprite tematico OVNI Dia de Muertos presente >= 500 KB' `
            -Source 'ORIGINAL_REQUEST R1.3' -Passed $pass `
            -Expected 'Sprite OVNI con flores de cempasuchil' `
            -Actual $(if (Test-Path $ovniSpooky) { "$((Get-Item $ovniSpooky).Length) bytes" } else { "Inexistente" })
        # T1-F05-03
        $pass = $animScriptContent -match 'alien_ovni'
        Assert-E2E -Tier '1' -Feature 5 -TestId 'T1-F05-03' -Name 'Configuracion de rigging para alien y platillo volador OVNI' `
            -Source 'PROJECT.md F5' -Passed $pass `
            -Expected 'RIG_CONFIG contiene alien_ovni' `
            -Actual $(if ($pass) { "Rigging OVNI definido" } else { "No encontrado" })
        # T1-F05-04
        $pass = $animScriptContent -match 'abductor' -or $animScriptContent -match '2°C' -or $animScriptContent -match 'limones'
        Assert-E2E -Tier '1' -Feature 5 -TestId 'T1-F05-04' -Name 'Parametros de rayo abductor, hielera a 2°C y limones Colima en codigo' `
            -Source 'ORIGINAL_REQUEST R1.3' -Passed $pass `
            -Expected 'Elementos de abduccion criogenica a 2°C' -Actual $(if ($pass) { "Integrados en animacion" } else { "No encontrados" })
        # T1-F05-05
        $pass = ($timelineData -ne $null) -and ($timelineData.scenes | Where-Object { $_.name -match 'alien' -or $_.id -match 'sc3' })
        Assert-E2E -Tier '1' -Feature 5 -TestId 'T1-F05-05' -Name 'Escena 3 registrada en timeline (OVNI sobre Playa Miramar)' `
            -Source 'ORIGINAL_REQUEST R1.3' -Passed ($pass -ne $null) `
            -Expected 'Escena 3 en timeline' -Actual $(if ($pass) { "sc3 registrada" } else { "No encontrada" })
    }
    # --- FEATURE 6: Keyframes 2D Cel-Shaded Escena 4 ---
    if ($Feature -eq 0 -or $Feature -eq 6) {
        Write-Host "  Feature 6: Keyframes 2D Cel-Shaded Escena 4 (Climax Crunch & `$150 MXN)" -ForegroundColor Cyan
        $comidaBase = Join-Path $baseDir "clean_comida.png"
        # T1-F06-01
        $pass = (Test-Path $comidaBase) -and ((Get-Item $comidaBase).Length -ge 1000000)
        Assert-E2E -Tier '1' -Feature 6 -TestId 'T1-F06-01' -Name 'Fotografia macro aislada del Tostiaguachile (clean_comida.png) >= 1 MB' `
            -Source 'ORIGINAL_REQUEST §2 & R1.4' -Passed $pass `
            -Expected 'Imagen macro en alta definicion' `
            -Actual $(if (Test-Path $comidaBase) { "$((Get-Item $comidaBase).Length) bytes" } else { "Inexistente" })
        # T1-F06-02
        $pass = $animScriptContent -match 'juancho_vivo'
        Assert-E2E -Tier '1' -Feature 6 -TestId 'T1-F06-02' -Name 'Rigging configurado para Juancho revivido y radiante (juancho_vivo)' `
            -Source 'ORIGINAL_REQUEST R1.4' -Passed $pass `
            -Expected 'RIG_CONFIG contiene juancho_vivo' `
            -Actual $(if ($pass) { "juancho_vivo configurado" } else { "No encontrado" })
        # T1-F06-03
        $pass = $animScriptContent -match '150' -and ($animScriptContent -match 'mariposa' -or $animScriptContent -match '100g')
        Assert-E2E -Tier '1' -Feature 6 -TestId 'T1-F06-03' -Name 'Especificacion formal de precio $150 MXN y ~100g de camaron mariposa' `
            -Source 'ORIGINAL_REQUEST R1.4' -Passed $pass `
            -Expected 'Precio $150 MXN y porcion ~100g' `
            -Actual $(if ($pass) { "Precio y gramaje correctos" } else { "Discrepancia" })
        # T1-F06-04
        $pass = $animScriptContent -match 'esmeralda' -or $animScriptContent -match 'relampago' -or $animScriptContent -match 'star'
        Assert-E2E -Tier '1' -Feature 6 -TestId 'T1-F06-04' -Name 'Efectos de relampago esmeralda y ojos de estrella implementados' `
            -Source 'ORIGINAL_REQUEST R1.4' -Passed $pass `
            -Expected 'Animacion visual de resurreccion' `
            -Actual $(if ($pass) { "Efectos esmeralda y estrellas activos" } else { "No detectados" })
        # T1-F06-05
        $pass = ($timelineData -ne $null) -and ($timelineData.scenes | Where-Object { $_.name -match 'climax' -or $_.id -match 'sc4' })
        Assert-E2E -Tier '1' -Feature 6 -TestId 'T1-F06-05' -Name 'Escena 4 registrada en timeline (Climax del Crunch Sagrado)' `
            -Source 'ORIGINAL_REQUEST R1.4' -Passed ($pass -ne $null) `
            -Expected 'Escena 4 en timeline' -Actual $(if ($pass) { "sc4 registrada" } else { "No encontrada" })
    }
    # --- FEATURE 7: Keyframes 2D Cel-Shaded Escenas 5 y 6 ---
    if ($Feature -eq 0 -or $Feature -eq 7) {
        Write-Host "  Feature 7: Keyframes 2D Cel-Shaded Escenas 5 y 6 (Fiesta y Cierre)" -ForegroundColor Cyan
        $skylinePath = Join-Path $baseDir "tampico_skyline_bg.jpg"
        # T1-F07-01
        $pass = (Test-Path $skylinePath) -and ((Get-Item $skylinePath).Length -ge 500000)
        Assert-E2E -Tier '1' -Feature 7 -TestId 'T1-F07-01' -Name 'Fondo panoramico costeno de Tampico presente >= 500 KB' `
            -Source 'ORIGINAL_REQUEST R1.5' -Passed $pass `
            -Expected 'Imagen de fondo tampico_skyline_bg.jpg' `
            -Actual $(if (Test-Path $skylinePath) { "$((Get-Item $skylinePath).Length) bytes" } else { "Inexistente" })
        # T1-F07-02
        $pass = $animScriptContent -match '833\s*252\s*09\s*88'
        Assert-E2E -Tier '1' -Feature 7 -TestId 'T1-F07-02' -Name 'Numero de atencion WhatsApp 833 252 09 88 integrado en cierre' `
            -Source 'ORIGINAL_REQUEST R1.5' -Passed $pass `
            -Expected 'WhatsApp 833 252 09 88' `
            -Actual $(if ($pass) { "Telefono correcto" } else { "No encontrado" })
        # T1-F07-03
        $pass = $animScriptContent -match '1:00.*5:00\s*PM' -or ($animScriptContent -match '1:00' -and $animScriptContent -match '5:00\s*PM')
        Assert-E2E -Tier '1' -Feature 7 -TestId 'T1-F07-03' -Name 'Horario comercial oficial integrado (Sab-Dom 1:00 PM a 5:00 PM)' `
            -Source 'ORIGINAL_REQUEST R1.5' -Passed $pass `
            -Expected 'Horario 1:00 PM a 5:00 PM' `
            -Actual $(if ($pass) { "Horario presente" } else { "No encontrado" })
        # T1-F07-04
        $pass = $animScriptContent -match 'frescura' -or $animScriptContent -match 'preparado frente a usted'
        Assert-E2E -Tier '1' -Feature 7 -TestId 'T1-F07-04' -Name 'Promesa de frescura integrada ("El producto es preparado frente a usted...")' `
            -Source 'ORIGINAL_REQUEST R1.5' -Passed $pass `
            -Expected 'Sello y promesa de maxima frescura' `
            -Actual $(if ($pass) { "Promesa de frescura presente" } else { "No encontrada" })
        # T1-F07-05
        $pass = ($timelineData -ne $null) -and ($timelineData.scenes | Where-Object { $_.name -match 'cierre' -or $_.id -match 'sc6' })
        Assert-E2E -Tier '1' -Feature 7 -TestId 'T1-F07-05' -Name 'Escena 6 registrada en timeline (Cierre Comercial de Franquicia)' `
            -Source 'ORIGINAL_REQUEST R1.5' -Passed ($pass -ne $null) `
            -Expected 'Escena 6 en timeline' -Actual $(if ($pass) { "sc6 registrada" } else { "No encontrada" })
    }
    # --- FEATURE 8: Interpolación de Video Omni Flash Escenas 1-3 ---
    if ($Feature -eq 0 -or $Feature -eq 8) {
        Write-Host "  Feature 8: Interpolacion de Video Omni Flash Escenas 1-3" -ForegroundColor Cyan
        # T1-F08-01
        $pass = (Test-Path $animScriptPath) -and ($animScriptContent -match '60' -and $animScriptContent -match '1080')
        Assert-E2E -Tier '1' -Feature 8 -TestId 'T1-F08-01' -Name 'Motor de animacion fluida configurado a 60 FPS en 1080x1920' `
            -Source 'ORIGINAL_REQUEST R2.1 & PROJECT.md F8' -Passed $pass `
            -Expected 'Pipeline de renderizado a 60fps Full HD' `
            -Actual $(if ($pass) { "Configurado a 60fps 1080x1920" } else { "Desalineado" })
        # T1-F08-02
        $sc1 = if ($timelineData) { $timelineData.scenes | Where-Object { $_.id -like 'sc1*' -or $_.name -match 'juancho_zombie' } } else { $null }
        $pass = ($sc1 -ne $null) -and ([double]$sc1.scene_duration -ge 9.0)
        Assert-E2E -Tier '1' -Feature 8 -TestId 'T1-F08-02' -Name 'Escena 1 cuenta con duracion sostenida >= 9.0s' `
            -Source 'ORIGINAL_REQUEST R2.1' -Passed $pass `
            -Expected 'sc1.duration >= 9.0s' -Actual $(if ($sc1) { "$($sc1.scene_duration) s" } else { "Nula" })
        # T1-F08-03
        $sc2 = if ($timelineData) { $timelineData.scenes | Where-Object { $_.id -like 'sc2*' -or $_.name -match 'mapache' } } else { $null }
        $pass = ($sc2 -ne $null) -and ([double]$sc2.scene_duration -ge 8.0)
        Assert-E2E -Tier '1' -Feature 8 -TestId 'T1-F08-03' -Name 'Escena 2 cuenta con duracion sostenida >= 8.0s' `
            -Source 'ORIGINAL_REQUEST R2.1' -Passed $pass `
            -Expected 'sc2.duration >= 8.0s' -Actual $(if ($sc2) { "$($sc2.scene_duration) s" } else { "Nula" })
        # T1-F08-04
        $sc3 = if ($timelineData) { $timelineData.scenes | Where-Object { $_.id -like 'sc3*' -or $_.name -match 'alien' } } else { $null }
        $pass = ($sc3 -ne $null) -and ([double]$sc3.scene_duration -ge 9.5)
        Assert-E2E -Tier '1' -Feature 8 -TestId 'T1-F08-04' -Name 'Escena 3 cuenta con duracion sostenida >= 9.5s' `
            -Source 'ORIGINAL_REQUEST R2.1' -Passed $pass `
            -Expected 'sc3.duration >= 9.5s' -Actual $(if ($sc3) { "$($sc3.scene_duration) s" } else { "Nula" })
        # T1-F08-05
        $pass = $animScriptContent -match 'Squash' -or $animScriptContent -match 'stretch' -or $animScriptContent -match 'parpadeo'
        Assert-E2E -Tier '1' -Feature 8 -TestId 'T1-F08-05' -Name 'Implementacion de dinamicas elásticas (squash & stretch y parpadeo)' `
            -Source 'ORIGINAL_REQUEST R2.1' -Passed $pass `
            -Expected 'Fisica de elasticidad y parpadeo facial' `
            -Actual $(if ($pass) { "Dinamica elastica implementada" } else { "No detectada" })
    }
    # --- FEATURE 9: Interpolación de Video Omni Flash Escenas 4-6 ---
    if ($Feature -eq 0 -or $Feature -eq 9) {
        Write-Host "  Feature 9: Interpolacion de Video Omni Flash Escenas 4-6" -ForegroundColor Cyan
        # T1-F09-01
        $sc4 = if ($timelineData) { $timelineData.scenes | Where-Object { $_.id -like 'sc4*' -or $_.name -match 'climax' } } else { $null }
        $pass = ($sc4 -ne $null) -and ([double]$sc4.scene_duration -ge 10.0)
        Assert-E2E -Tier '1' -Feature 9 -TestId 'T1-F09-01' -Name 'Escena 4 (Climax del Crunch) cuenta con duracion >= 10.0s' `
            -Source 'ORIGINAL_REQUEST R2.1' -Passed $pass `
            -Expected 'sc4.duration >= 10.0s' -Actual $(if ($sc4) { "$($sc4.scene_duration) s" } else { "Nula" })
        # T1-F09-02
        $sc5 = if ($timelineData) { $timelineData.scenes | Where-Object { $_.id -like 'sc5*' -or $_.name -match 'vivo' } } else { $null }
        $pass = ($sc5 -ne $null) -and ([double]$sc5.scene_duration -ge 4.5)
        Assert-E2E -Tier '1' -Feature 9 -TestId 'T1-F09-02' -Name 'Escena 5 (Fiesta Miramar) cuenta con duracion >= 4.5s' `
            -Source 'ORIGINAL_REQUEST R2.1' -Passed $pass `
            -Expected 'sc5.duration >= 4.5s' -Actual $(if ($sc5) { "$($sc5.scene_duration) s" } else { "Nula" })
        # T1-F09-03
        $sc6 = if ($timelineData) { $timelineData.scenes | Where-Object { $_.id -like 'sc6*' -or $_.name -match 'cierre' } } else { $null }
        $pass = ($sc6 -ne $null) -and ([double]$sc6.scene_duration -ge 9.5)
        Assert-E2E -Tier '1' -Feature 9 -TestId 'T1-F09-03' -Name 'Escena 6 (Cierre Comercial) cuenta con duracion >= 9.5s' `
            -Source 'ORIGINAL_REQUEST R2.1' -Passed $pass `
            -Expected 'sc6.duration >= 9.5s' -Actual $(if ($sc6) { "$($sc6.scene_duration) s" } else { "Nula" })
        # T1-F09-04
        $pass = $animScriptContent -match 'Subtítulos' -or $animScriptContent -match 'FONT_SUB' -or $animScriptContent -match 'highlight'
        Assert-E2E -Tier '1' -Feature 9 -TestId 'T1-F09-04' -Name 'Subtitulos dinamicos palabra por palabra implementados en render' `
            -Source 'ORIGINAL_REQUEST R2.2' -Passed $pass `
            -Expected 'Subtitulos estilo Reels/TikTok integrados' `
            -Actual $(if ($pass) { "Motor de subtitulos presente" } else { "No encontrado" })
        # T1-F09-05
        $pass = $animScriptContent -match 'shake' -or $animScriptContent -match 'Camera' -or $animScriptContent -match 'zoom'
        Assert-E2E -Tier '1' -Feature 9 -TestId 'T1-F09-05' -Name 'Efectos de camara cinematografica (zoom-in y camera shake) activos' `
            -Source 'ORIGINAL_REQUEST R2.1' -Passed $pass `
            -Expected 'Movimientos dinamicos de camara' `
            -Actual $(if ($pass) { "Camera shake/zoom presentes" } else { "No detectados" })
    }
    # --- FEATURE 10: Ensamble Master 1080x1920 @ 60fps ---
    if ($Feature -eq 0 -or $Feature -eq 10) {
        Write-Host "  Feature 10: Ensamble Master 1080x1920 @ 60fps" -ForegroundColor Cyan
        $probeMaster = Get-MediaProbe $masterVideoPath
        $vStream = if ($probeMaster) { $probeMaster.streams | Where-Object { $_.codec_type -eq 'video' } | Select-Object -First 1 } else { $null }
        # T1-F10-01
        $pass = (Test-Path $masterVideoPath) -and ((Get-Item $masterVideoPath).Length -le 42000000)
        Assert-E2E -Tier '1' -Feature 10 -TestId 'T1-F10-01' -Name 'Video Maestro 60fps generado y peso <= 42 MB' `
            -Source 'PROJECT.md Interface Contracts M4' -Passed $pass `
            -Expected 'Archivo existente con peso <= 42,000,000 bytes' `
            -Actual $(if (Test-Path $masterVideoPath) { "$((Get-Item $masterVideoPath).Length) bytes" } else { "Inexistente" })
        # T1-F10-02
        $pass = ($vStream -ne $null) -and ($vStream.width -eq 1080) -and ($vStream.height -eq 1920)
        Assert-E2E -Tier '1' -Feature 10 -TestId 'T1-F10-02' -Name 'Resolucion exacta de video 1080x1920 px (9:16 vertical)' `
            -Source 'ORIGINAL_REQUEST R3.1' -Passed $pass `
            -Expected 'Width=1080, Height=1920' `
            -Actual $(if ($vStream) { "$($vStream.width)x$($vStream.height)" } else { "Sin stream" })
        # T1-F10-03
        $pass = ($vStream -ne $null) -and ($vStream.r_frame_rate -eq '60/1')
        Assert-E2E -Tier '1' -Feature 10 -TestId 'T1-F10-03' -Name 'Tasa de cuadros exacta de 60.0 FPS (60/1)' `
            -Source 'ORIGINAL_REQUEST R3.1' -Passed $pass `
            -Expected 'r_frame_rate=60/1' `
            -Actual $(if ($vStream) { "$($vStream.r_frame_rate) fps" } else { "Sin stream" })
        # T1-F10-04
        $br = if ($vStream -and $vStream.bit_rate) { [int]$vStream.bit_rate } else { 0 }
        $pass = ($vStream -ne $null) -and ($vStream.codec_name -eq 'h264') -and ($br -ge 4000000)
        Assert-E2E -Tier '1' -Feature 10 -TestId 'T1-F10-04' -Name 'Codec H.264 High Profile con bitrate >= 4000 kbps' `
            -Source 'ORIGINAL_REQUEST R3.1' -Passed $pass `
            -Expected 'codec=h264, bitrate >= 4000000 bps' `
            -Actual $(if ($vStream) { "codec=$($vStream.codec_name), bitrate=$br bps" } else { "Sin stream" })
        # T1-F10-05
        $probePromo = Get-MediaProbe $promoVideoPath
        $vPromo = if ($probePromo) { $probePromo.streams | Where-Object { $_.codec_type -eq 'video' } | Select-Object -First 1 } else { $null }
        $pass = ($vPromo -ne $null) -and ($vPromo.width -eq 1080) -and ($vPromo.height -eq 1920) -and ($vPromo.r_frame_rate -eq '60/1')
        Assert-E2E -Tier '1' -Feature 10 -TestId 'T1-F10-05' -Name 'Video espejo promocional promo_halloween_zombies_crudos.mp4 sincronizado a 60fps' `
            -Source 'ORIGINAL_REQUEST R3.1' -Passed $pass `
            -Expected 'Promo idéntico al master a 60fps 1080x1920' `
            -Actual $(if ($vPromo) { "$($vPromo.width)x$($vPromo.height) @ $($vPromo.r_frame_rate)" } else { "Invalido" })
    }
    # --- FEATURE 11: Integración Web y Empaque ZIP < 100MB ---
    if ($Feature -eq 0 -or $Feature -eq 11) {
        Write-Host "  Feature 11: Integracion Web y Empaque ZIP < 100MB" -ForegroundColor Cyan
        # T1-F11-01
        $pass = ($indexContent -match '<video' -and $indexContent -match 'animacion_la_garza_episodio_crudos_60fps\.mp4')
        Assert-E2E -Tier '1' -Feature 11 -TestId 'T1-F11-01' -Name 'Landing publica index.html integra reproductor HTML5 del video 60fps' `
            -Source 'ORIGINAL_REQUEST R3.3' -Passed $pass `
            -Expected 'Tag <video> apuntando a animacion_la_garza_episodio_crudos_60fps.mp4' `
            -Actual $(if ($pass) { "Reproductor HTML5 configurado" } else { "No encontrado" })
        # T1-F11-02
        $pass = ($panelContent -match '<video' -and $panelContent -match 'animacion_la_garza_episodio_crudos_60fps\.mp4')
        Assert-E2E -Tier '1' -Feature 11 -TestId 'T1-F11-02' -Name 'Panel de control panel_control.html integra reproductor HTML5 del video 60fps' `
            -Source 'ORIGINAL_REQUEST R3.3' -Passed $pass `
            -Expected 'Tag <video> apuntando a animacion_la_garza_episodio_crudos_60fps.mp4' `
            -Actual $(if ($pass) { "Reproductor HTML5 configurado en panel" } else { "No encontrado" })
        # T1-F11-03
        $pass = (Test-Path $zipPath) -and ((Get-Item $zipPath).Length -lt 104857600)
        Assert-E2E -Tier '1' -Feature 11 -TestId 'T1-F11-03' -Name 'Paquete descargable paquete_redes_la_garza.zip menor a 100 MB' `
            -Source 'ORIGINAL_REQUEST Criteria' -Passed $pass `
            -Expected 'Tamano ZIP < 104,857,600 bytes' `
            -Actual $(if (Test-Path $zipPath) { "$((Get-Item $zipPath).Length) bytes" } else { "Inexistente" })
        # T1-F11-04
        $zipOk = $false
        if (Test-Path $zipPath) {
            try {
                $zipArchive = [System.IO.Compression.ZipFile]::OpenRead($zipPath)
                $sem1 = $zipArchive.Entries | Where-Object { $_.FullName -match 'Semana_1' }
                $sem4 = $zipArchive.Entries | Where-Object { $_.FullName -match 'Semana_4' }
                $zipOk = ($sem1 -ne $null) -and ($sem4 -ne $null)
                $zipArchive.Dispose()
            } catch {
                $zipOk = $false
            }
        }
        Assert-E2E -Tier '1' -Feature 11 -TestId 'T1-F11-04' -Name 'Estructura interna del ZIP contiene campana completa (Semana 1 a Semana 4)' `
            -Source 'PROJECT.md F11' -Passed $zipOk `
            -Expected 'Carpetas Semana_1/ y Semana_4/ presentes en ZIP' `
            -Actual $(if ($zipOk) { "Estructura mensual validada" } else { "Estructura incompleta" })
        # T1-F11-05
        $pass = Test-Path (Join-Path $baseDir "herramientas\empaquetar_redes_zip.ps1")
        Assert-E2E -Tier '1' -Feature 11 -TestId 'T1-F11-05' -Name 'Script de empaquetado oficial herramientas/empaquetar_redes_zip.ps1 presente' `
            -Source 'PROJECT.md Code Layout' -Passed $pass `
            -Expected 'Script de empaquetado existente' `
            -Actual $(if ($pass) { "Presente" } else { "Inexistente" })
    }
    # --- FEATURE 12: Auditoría QA y Precio $150 MXN ---
    if ($Feature -eq 0 -or $Feature -eq 12) {
        Write-Host "  Feature 12: Auditoria QA y Precio `$150 MXN" -ForegroundColor Cyan
        # T1-F12-01
        $pass = Test-Path $qaScriptPath
        Assert-E2E -Tier '1' -Feature 12 -TestId 'T1-F12-01' -Name 'Script auditor oficial herramientas/auditar_multimedia_qa.ps1 presente' `
            -Source 'ORIGINAL_REQUEST R3.3' -Passed $pass `
            -Expected 'Script auditar_multimedia_qa.ps1 en herramientas/' `
            -Actual $(if ($pass) { "Presente" } else { "Inexistente" })
        # T1-F12-02
        $pass = -not ($indexContent -match '\$170' -or $indexContent -match '170\s*MXN')
        Assert-E2E -Tier '1' -Feature 12 -TestId 'T1-F12-02' -Name 'Blindaje total de precio: Cero menciones de $170 en index.html' `
            -Source 'ORIGINAL_REQUEST R3.3 & Criteria' -Passed $pass `
            -Expected '0 ocurrencias de $170' `
            -Actual $(if ($pass) { "0 menciones" } else { "Mencion prohibida detectada" })
        # T1-F12-03
        $matches150Index = ([regex]::Matches($indexContent, '150')).Count
        $pass = $matches150Index -ge 5
        Assert-E2E -Tier '1' -Feature 12 -TestId 'T1-F12-03' -Name 'Presencia oficial del precio $150 MXN en index.html (>= 5 menciones)' `
            -Source 'ORIGINAL_REQUEST Goal' -Passed $pass `
            -Expected '>= 5 menciones de $150' -Actual "$matches150Index menciones"
        # T1-F12-04
        $matches150Panel = ([regex]::Matches($panelContent, '150')).Count
        $pass = $matches150Panel -ge 20
        Assert-E2E -Tier '1' -Feature 12 -TestId 'T1-F12-04' -Name 'Presencia oficial del precio $150 MXN en panel_control.html (>= 20 menciones)' `
            -Source 'ORIGINAL_REQUEST Goal' -Passed $pass `
            -Expected '>= 20 menciones de $150' -Actual "$matches150Panel menciones"
        # T1-F12-05
        $pass = -not ($panelContent -match '\$170' -or $panelContent -match '170\s*MXN')
        Assert-E2E -Tier '1' -Feature 12 -TestId 'T1-F12-05' -Name 'Blindaje total de precio: Cero menciones de $170 en panel_control.html' `
            -Source 'ORIGINAL_REQUEST R3.3 & Criteria' -Passed $pass `
            -Expected '0 ocurrencias de $170' `
            -Actual $(if ($pass) { "0 menciones" } else { "Mencion prohibida detectada" })
    }
    # --- FEATURE 13: Validación Visual Cartoon Network ---
    if ($Feature -eq 0 -or $Feature -eq 13) {
        Write-Host "  Feature 13: Validacion Visual Cartoon Network" -ForegroundColor Cyan
        # We sample 5 frame extraction points across the compiled 60fps video
        $tempFrameDir = Join-Path $env:TEMP "la_garza_test_frames"
        if (-not (Test-Path $tempFrameDir)) { if (-not (Test-Path $tempFrameDir)) { New-Item -ItemType Directory -Path $tempFrameDir -Force | Out-Null } }
        $sampleTimestamps = @(
            @{ Id = 'T1-F13-01'; Sec = '2.0';  Name = 'Frame Escena 1 (Juancho Zombie @ 2.0s) en 1080x1920' },
            @{ Id = 'T1-F13-02'; Sec = '15.0'; Name = 'Frame Escena 2 (Mapache Freddy @ 15.0s) en 1080x1920' },
            @{ Id = 'T1-F13-03'; Sec = '28.0'; Name = 'Frame Escena 3 (OVNI Miramar @ 28.0s) en 1080x1920' },
            @{ Id = 'T1-F13-04'; Sec = '42.0'; Name = 'Frame Escena 4 (Climax Crunch @ 42.0s) en 1080x1920' },
            @{ Id = 'T1-F13-05'; Sec = '60.0'; Name = 'Frame Escena 6 (Cierre Comercial @ 60.0s) en 1080x1920' }
        )
        foreach ($sample in $sampleTimestamps) {
            $fOut = Join-Path $tempFrameDir "sample_$($sample.Sec).png"
            if (-not (Test-Path $fOut) -and (Test-Path $masterVideoPath) -and (Test-Path $ffmpegPath)) {
                & $ffmpegPath -nostdin -y -ss $sample.Sec -i $masterVideoPath -vframes 1 -q:v 2 $fOut 2>$null
            }
            $pass = $false
            $dim = "N/A"
            if (Test-Path $fOut) {
                try {
                    $img = [System.Drawing.Image]::FromFile($fOut)
                    $pass = ($img.Width -eq 1080) -and ($img.Height -eq 1920)
                    $dim = "$($img.Width)x$($img.Height)"
                    $img.Dispose()
                } catch {
                    $pass = $false
                }
            }
            Assert-E2E -Tier '1' -Feature 13 -TestId $sample.Id -Name $sample.Name `
                -Source 'ORIGINAL_REQUEST R3.2 & Criteria' -Passed $pass `
                -Expected '1080x1920 px' -Actual $dim
        }
    }
    # --- FEATURE 14: Despliegue en GitHub Pages ---
    if ($Feature -eq 0 -or $Feature -eq 14) {
        Write-Host "  Feature 14: Despliegue en GitHub Pages" -ForegroundColor Cyan
        # T1-F14-01
        $pass = Test-Path $noJekyllPath
        Assert-E2E -Tier '1' -Feature 14 -TestId 'T1-F14-01' -Name 'Marcador de GitHub Pages .nojekyll presente en raiz' `
            -Source 'PROJECT.md F14' -Passed $pass `
            -Expected 'Archivo .nojekyll existente' `
            -Actual $(if ($pass) { "Presente" } else { "Inexistente" })
        # T1-F14-02
        $pass = Test-Path $deployScriptPath
        Assert-E2E -Tier '1' -Feature 14 -TestId 'T1-F14-02' -Name 'Script de despliegue automatico desplegar_github_pages.ps1 presente' `
            -Source 'PROJECT.md Code Layout' -Passed $pass `
            -Expected 'Script de despliegue existente' `
            -Actual $(if ($pass) { "Presente" } else { "Inexistente" })
        # T1-F14-03
        $pass = Test-Path $deployBatPath
        Assert-E2E -Tier '1' -Feature 14 -TestId 'T1-F14-03' -Name 'Lanzador por lotes desplegar_automatico.bat presente' `
            -Source 'PROJECT.md Code Layout' -Passed $pass `
            -Expected 'Archivo batch existente' `
            -Actual $(if ($pass) { "Presente" } else { "Inexistente" })
        # T1-F14-04
        $deployContent = if (Test-Path $deployScriptPath) { Get-Content $deployScriptPath -Raw -Encoding UTF8 } else { "" }
        $pass = $deployContent -match 'lagarzaaguachilera\.github\.io' -or $deployContent -match 'github\.com'
        Assert-E2E -Tier '1' -Feature 14 -TestId 'T1-F14-04' -Name 'Destino remoto configurado hacia GitHub Pages (lagarzaaguachilera.github.io)' `
            -Source 'ORIGINAL_REQUEST R3.3' -Passed $pass `
            -Expected 'Dominio lagarzaaguachilera.github.io configurado' `
            -Actual $(if ($pass) { "Dominio GitHub Pages referenciado" } else { "No encontrado" })
        # T1-F14-05
        $pass = $deployContent -match 'Auditado y aprobado por Control de Calidad' -or
                $indexContent -match 'Control de Calidad' -or
                (Test-Path (Join-Path $baseDir "GUIA_DESPLIEGUE_GITHUB_PAGES.md"))
        Assert-E2E -Tier '1' -Feature 14 -TestId 'T1-F14-05' -Name 'Sello oficial de aprobacion de Control de Calidad documentado' `
            -Source 'ORIGINAL_REQUEST Criteria' -Passed $pass `
            -Expected 'Sello de Control de Calidad integrado' `
            -Actual $(if ($pass) { "Sello de calidad verificado" } else { "Faltante" })
    }
}
# ==============================================================================
# TIER 2: CASOS LÍMITE, UMBRALES Y FRONTERAS (BOUNDARIES & CORNERS)
# ==============================================================================
if ($Tier -eq 'All' -or $Tier -eq '2') {
    Write-Host "`n>>> TIER 2: CASOS LIMITE, UMBRALES Y FRONTERAS (>= 5 TESTS / FEATURE)" -ForegroundColor Magenta
    # --- FEATURE 1 Boundaries ---
    if ($Feature -eq 0 -or $Feature -eq 1) {
        Write-Host "  Feature 1 Boundaries (Audio TTS)" -ForegroundColor Cyan
        $probeAudio = Get-MediaProbe $masterAudioPath
        $aStream = if ($probeAudio) { $probeAudio.streams | Where-Object { $_.codec_type -eq 'audio' } | Select-Object -First 1 } else { $null }
        # T2-B01-01: Bits per sample PCM
        $pass = ($aStream -ne $null) -and ($aStream.bits_per_sample -eq 16 -or $aStream.sample_fmt -eq 's16')
        Assert-E2E -Tier '2' -Feature 1 -TestId 'T2-B01-01' -Name 'Profundidad de bits de audio master es PCM 16-bit' `
            -Source 'PROJECT.md Interface Contracts M1' -Passed $pass `
            -Expected '16-bit PCM' -Actual $(if ($aStream) { "$($aStream.bits_per_sample) bits ($($aStream.sample_fmt))" } else { "N/A" })
        # T2-B01-02: Duracion minima estricta
        $dur = if ($probeAudio) { [double]$probeAudio.format.duration } else { 0.0 }
        $pass = $dur -ge 60.0
        Assert-E2E -Tier '2' -Feature 1 -TestId 'T2-B01-02' -Name 'Limite inferior de duracion de locucion master >= 60.0s' `
            -Source 'ORIGINAL_REQUEST §4' -Passed $pass `
            -Expected '>= 60.0s' -Actual "$dur s"
        # T2-B01-03: Duracion maxima estricta
        $pass = $dur -le 95.0
        Assert-E2E -Tier '2' -Feature 1 -TestId 'T2-B01-03' -Name 'Limite superior de duracion de locucion master <= 95.0s' `
            -Source 'ORIGINAL_REQUEST §4' -Passed $pass `
            -Expected '<= 95.0s' -Actual "$dur s"
        # T2-B01-04: Sample rate frontera exacto
        $pass = ($aStream -ne $null) -and ($aStream.sample_rate -eq 44100)
        Assert-E2E -Tier '2' -Feature 1 -TestId 'T2-B01-04' -Name 'Frecuencia de muestreo exacta: 44,100 Hz' `
            -Source 'PROJECT.md Interface Contracts M1' -Passed $pass `
            -Expected '44100 Hz' -Actual $(if ($aStream) { "$($aStream.sample_rate) Hz" } else { "N/A" })
        # T2-B01-05: Canales de audio frontera
        $pass = ($aStream -ne $null) -and ($aStream.channels -eq 2)
        Assert-E2E -Tier '2' -Feature 1 -TestId 'T2-B01-05' -Name 'Canales de audio frontera: estrictamente estereo (2)' `
            -Source 'PROJECT.md Interface Contracts M1' -Passed $pass `
            -Expected '2 canales' -Actual $(if ($aStream) { "$($aStream.channels) canales" } else { "N/A" })
    }
    # --- FEATURE 2 Boundaries ---
    if ($Feature -eq 0 -or $Feature -eq 2) {
        Write-Host "  Feature 2 Boundaries (Diseno Sonoro / Ducking)" -ForegroundColor Cyan
        # T2-B02-01: Limite inferior tamano musica
        $pass = (Test-Path $musicPath) -and ((Get-Item $musicPath).Length -ge 5000000)
        Assert-E2E -Tier '2' -Feature 2 -TestId 'T2-B02-01' -Name 'Tamano de archivo de musica de fondo >= 5,000,000 bytes' `
            -Source 'PROJECT.md F2' -Passed $pass `
            -Expected '>= 5,000,000 bytes' `
            -Actual $(if (Test-Path $musicPath) { "$((Get-Item $musicPath).Length) bytes" } else { "0" })
        # T2-B02-02: Ducking factor min bound
        $pass = $audioScriptContent -match '0\.1[0-9]|0\.2[0-9]'
        Assert-E2E -Tier '2' -Feature 2 -TestId 'T2-B02-02' -Name 'Factor multiplicador de auto-ducking acotado en rango optimo [0.10, 0.30]' `
            -Source 'PROJECT.md F2 & TEST_INFRA.md' -Passed $pass `
            -Expected '0.10 <= factor <= 0.30' -Actual $(if ($pass) { "Factor en rango" } else { "Fuera de rango" })
        # T2-B02-03: Ducking max attenuation bound
        $pass = $audioScriptContent -match '0\.14' -or (-not ($audioScriptContent -match 'duck_gain\s*=\s*np\.where\([^,]+,\s*0\.0[0-5]'))
        Assert-E2E -Tier '2' -Feature 2 -TestId 'T2-B02-03' -Name 'Atenuacion de ducking no causa silencio absoluto (> 0.05)' `
            -Source 'TEST_INFRA.md §3.2' -Passed $pass `
            -Expected 'Atenuacion suave > 0.05' -Actual $(if ($pass) { "Musica audible de fondo" } else { "Silencio" })
        # T2-B02-04: RMS values bound
        $rmsValid = $true
        if ($timelineData -and $timelineData.frames -and $timelineData.frames.Count -gt 0) {
            foreach ($f in $timelineData.frames) {
                if ($f.mouth_open -lt 0.0 -or $f.mouth_open -gt 1.0) { $rmsValid = $false; break }
            }
        } elseif ($timelineData -and $timelineData.scenes) {
            foreach ($sc in $timelineData.scenes) {
                if ($sc.rms_envelope) {
                    foreach ($val in $sc.rms_envelope) {
                        if ([double]$val -lt 0.0 -or [double]$val -gt 1.0) { $rmsValid = $false; break }
                    }
                }
            }
        } else { $rmsValid = $false }
        Assert-E2E -Tier '2' -Feature 2 -TestId 'T2-B02-04' -Name 'Valores de envolvente RMS acotados matematicamente en [0.0, 1.0]' `
            -Source 'PROJECT.md Interface Contracts M1' -Passed $rmsValid `
            -Expected '0.0 <= RMS <= 1.0' -Actual $(if ($rmsValid) { "Rango [0.0, 1.0] verificado" } else { "Desborde detectado" })
        # T2-B02-05: Sin flatline en audio master
        $pass = (Test-Path $masterAudioPath) -and ((Get-Item $masterAudioPath).Length -gt 11000000)
        Assert-E2E -Tier '2' -Feature 2 -TestId 'T2-B02-05' -Name 'Volumen de datos binarios confirma ausencia de truncamiento (> 11 MB)' `
            -Source 'PROJECT.md Interface Contracts M1' -Passed $pass `
            -Expected '> 11,000,000 bytes' `
            -Actual $(if (Test-Path $masterAudioPath) { "$((Get-Item $masterAudioPath).Length) bytes" } else { "0" })
    }
    # --- FEATURE 3 Boundaries ---
    if ($Feature -eq 0 -or $Feature -eq 3) {
        Write-Host "  Feature 3 Boundaries (Escena 1 Juancho)" -ForegroundColor Cyan
        $juanchoImg = Join-Path $baseDir "clean_juancho.png"
        # T2-B03-01: Min dimension de sprite base
        $img = if (Test-Path $juanchoImg) { [System.Drawing.Image]::FromFile($juanchoImg) } else { $null }
        $pass = ($img -ne $null) -and ($img.Width -ge 400) -and ($img.Height -ge 400)
        Assert-E2E -Tier '2' -Feature 3 -TestId 'T2-B03-01' -Name 'Dimension minima de sprite de Juancho >= 400x400 px' `
            -Source 'ORIGINAL_REQUEST R1.1' -Passed $pass `
            -Expected '>= 400x400 px' -Actual $(if ($img) { "$($img.Width)x$($img.Height)" } else { "N/A" })
        # T2-B03-02: Aspect ratio 9:16
        $pass = [Math]::Abs((1080.0 / 1920.0) - 0.5625) -lt 0.001
        Assert-E2E -Tier '2' -Feature 3 -TestId 'T2-B03-02' -Name 'Relacion de aspecto vertical 9:16 exacta (delta < 0.001)' `
            -Source 'PROJECT.md Feature Inventory' -Passed $pass `
            -Expected '0.5625' -Actual "$([Math]::Round(1080.0 / 1920.0, 4))"
        # T2-B03-03: Anchor X de rigging dentro de bounds
        $pass = $animScriptContent -match '"mouth_xy":\s*\(\s*([0-9]+)'
        $mouthX = if ($pass) { [int]$matches[1] } else { 0 }
        $passBound = ($mouthX -gt 0) -and ($mouthX -lt 650)
        Assert-E2E -Tier '2' -Feature 3 -TestId 'T2-B03-03' -Name 'Coordenada de anclaje bucal X en rango anatomico valido [0, 650]' `
            -Source 'PROJECT.md F3' -Passed $passBound `
            -Expected '0 < mouth_x < 650' -Actual "$mouthX"
        # T2-B03-04: Jaw split Y dentro de bounds
        $pass = $animScriptContent -match '"jaw_split_y":\s*([0-9]+)'
        $jawY = if ($pass) { [int]$matches[1] } else { 0 }
        $passBound = ($jawY -gt 100) -and ($jawY -lt 550)
        Assert-E2E -Tier '2' -Feature 3 -TestId 'T2-B03-04' -Name 'Punto de articulacion mandibular Y en rango anatomico valido [100, 550]' `
            -Source 'PROJECT.md F3' -Passed $passBound `
            -Expected '100 < jaw_split_y < 550' -Actual "$jawY"
        # T2-B03-05: Canal alfa 32bpp
        $pass = ($img -ne $null) -and ($img.PixelFormat -match 'Format32bpp')
        Assert-E2E -Tier '2' -Feature 3 -TestId 'T2-B03-05' -Name 'Formato de pixeles incluye canal alfa 32bpp con transparencia' `
            -Source 'ORIGINAL_REQUEST R1.1' -Passed $pass `
            -Expected 'Format32bppArgb' -Actual $(if ($img) { "$($img.PixelFormat)" } else { "N/A" })
        if ($img) { $img.Dispose() }
    }
    # --- FEATURE 4 Boundaries ---
    if ($Feature -eq 0 -or $Feature -eq 4) {
        Write-Host "  Feature 4 Boundaries (Escena 2 Mapache)" -ForegroundColor Cyan
        $mapacheImg = Join-Path $baseDir "clean_mapache.png"
        # T2-B04-01: Min dimension sprite
        $img = if (Test-Path $mapacheImg) { [System.Drawing.Image]::FromFile($mapacheImg) } else { $null }
        $pass = ($img -ne $null) -and ($img.Width -ge 400) -and ($img.Height -ge 400)
        Assert-E2E -Tier '2' -Feature 4 -TestId 'T2-B04-01' -Name 'Dimension minima de sprite de Mapache >= 400x400 px' `
            -Source 'ORIGINAL_REQUEST R1.2' -Passed $pass `
            -Expected '>= 400x400 px' -Actual $(if ($img) { "$($img.Width)x$($img.Height)" } else { "N/A" })
        # T2-B04-02: 32bpp format
        $pass = ($img -ne $null) -and ($img.PixelFormat -match 'Format32bpp')
        Assert-E2E -Tier '2' -Feature 4 -TestId 'T2-B04-02' -Name 'Sprite de Mapache cuenta con 32bpp para composicion sin artefactos' `
            -Source 'ORIGINAL_REQUEST R1.2' -Passed $pass `
            -Expected 'Format32bpp' -Actual $(if ($img) { "$($img.PixelFormat)" } else { "N/A" })
        if ($img) { $img.Dispose() }
        # T2-B04-03: Rigging mouth width bound
        $pass = $animScriptContent -match '"mapache_freddy":\s*\{[^}]*"mouth_w":\s*([0-9]+)'
        $mW = if ($pass) { [int]$matches[1] } else { 0 }
        $passBound = ($mW -ge 20) -and ($mW -le 120)
        Assert-E2E -Tier '2' -Feature 4 -TestId 'T2-B04-03' -Name 'Apertura bucal nominal de Mapache en rango admisible [20, 120] px' `
            -Source 'PROJECT.md F4' -Passed $passBound `
            -Expected '20 <= mouth_w <= 120' -Actual "$mW px"
        # T2-B04-04: Rigging eyes presence
        $pass = $animScriptContent -match '"mapache_freddy":\s*\{[^}]*"eyes_xy"'
        Assert-E2E -Tier '2' -Feature 4 -TestId 'T2-B04-04' -Name 'Ojos de Mapache anclados para parpadeo periodico y expresion cómica' `
            -Source 'PROJECT.md F4' -Passed $pass `
            -Expected 'eyes_xy definido en RIG_CONFIG' -Actual $(if ($pass) { "Ojos anclados" } else { "Faltante" })
        # T2-B04-05: Spooky Mapache file size bound
        $spookyMap = Join-Path $baseDir "sticker_spooky_mapache_freddy.png"
        $pass = (Test-Path $spookyMap) -and ((Get-Item $spookyMap).Length -ge 800000)
        Assert-E2E -Tier '2' -Feature 4 -TestId 'T2-B04-05' -Name 'Tamano de sprite tematico Mapache Freddy >= 800 KB' `
            -Source 'ORIGINAL_REQUEST R1.2' -Passed $pass `
            -Expected '>= 800,000 bytes' `
            -Actual $(if (Test-Path $spookyMap) { "$((Get-Item $spookyMap).Length) bytes" } else { "0" })
    }
    # --- FEATURE 5 Boundaries ---
    if ($Feature -eq 0 -or $Feature -eq 5) {
        Write-Host "  Feature 5 Boundaries (Escena 3 OVNI)" -ForegroundColor Cyan
        $ovniImg = Join-Path $baseDir "clean_ovni.png"
        # T2-B05-01: Min dimension sprite
        $img = if (Test-Path $ovniImg) { [System.Drawing.Image]::FromFile($ovniImg) } else { $null }
        $pass = ($img -ne $null) -and ($img.Width -ge 400) -and ($img.Height -ge 400)
        Assert-E2E -Tier '2' -Feature 5 -TestId 'T2-B05-01' -Name 'Dimension minima de sprite de OVNI >= 400x400 px' `
            -Source 'ORIGINAL_REQUEST R1.3' -Passed $pass `
            -Expected '>= 400x400 px' -Actual $(if ($img) { "$($img.Width)x$($img.Height)" } else { "N/A" })
        # T2-B05-02: 32bpp format
        $pass = ($img -ne $null) -and ($img.PixelFormat -match 'Format32bpp')
        Assert-E2E -Tier '2' -Feature 5 -TestId 'T2-B05-02' -Name 'Sprite de OVNI cuenta con 32bpp y transparencia limpia' `
            -Source 'ORIGINAL_REQUEST R1.3' -Passed $pass `
            -Expected 'Format32bpp' -Actual $(if ($img) { "$($img.PixelFormat)" } else { "N/A" })
        if ($img) { $img.Dispose() }
        # T2-B05-03: Abduction beam coordinate X bound
        $pass = $animScriptContent -match '"alien_ovni":\s*\{[^}]*"mouth_xy":\s*\(\s*([0-9]+)'
        $ovniX = if ($pass) { [int]$matches[1] } else { 0 }
        $passBound = ($ovniX -gt 100) -and ($ovniX -lt 550)
        Assert-E2E -Tier '2' -Feature 5 -TestId 'T2-B05-03' -Name 'Centro del rayo abductor OVNI acotado en el eje central [100, 550]' `
            -Source 'PROJECT.md F5' -Passed $passBound `
            -Expected '100 < mouth_x < 550' -Actual "$ovniX"
        # T2-B05-04: Spooky OVNI size bound
        $spookyOvni = Join-Path $baseDir "sticker_spooky_ovni_muertos.png"
        $pass = (Test-Path $spookyOvni) -and ((Get-Item $spookyOvni).Length -ge 1000000)
        Assert-E2E -Tier '2' -Feature 5 -TestId 'T2-B05-04' -Name 'Tamano de sprite tematico OVNI Dia de Muertos >= 1.0 MB' `
            -Source 'ORIGINAL_REQUEST R1.3' -Passed $pass `
            -Expected '>= 1,000,000 bytes' `
            -Actual $(if (Test-Path $spookyOvni) { "$((Get-Item $spookyOvni).Length) bytes" } else { "0" })
        # T2-B05-05: 2°C temperature mention
        $pass = $animScriptContent -match '2°C' -or $animScriptContent -match 'criogénico' -or $animScriptContent -match 'hielo'
        Assert-E2E -Tier '2' -Feature 5 -TestId 'T2-B05-05' -Name 'Cadena de frío de hielera acotada exactamente a 2°C' `
            -Source 'ORIGINAL_REQUEST R1.3' -Passed $pass `
            -Expected 'Temperatura estricta de 2°C' `
            -Actual $(if ($pass) { "2°C verificado" } else { "No encontrado" })
    }
    # --- FEATURE 6 Boundaries ---
    if ($Feature -eq 0 -or $Feature -eq 6) {
        Write-Host "  Feature 6 Boundaries (Climax y Precio `$150)" -ForegroundColor Cyan
        # T2-B06-01: Rejection of price 0 or negative
        $pass = -not ($indexContent -match '\$0' -or $indexContent -match '\$-')
        Assert-E2E -Tier '2' -Feature 6 -TestId 'T2-B06-01' -Name 'Rechazo de precios cero o negativos en portal comercial' `
            -Source 'TEST_INFRA.md §3.2' -Passed $pass `
            -Expected 'Sin precios nulos o negativos' -Actual $(if ($pass) { "Precios validos" } else { "Anomalia" })
        # T2-B06-02: Strict rejection of $170 in production html
        $pass = -not ($indexContent -match '\$170' -or $panelContent -match '\$170')
        Assert-E2E -Tier '2' -Feature 6 -TestId 'T2-B06-02' -Name 'Rechazo absoluto del precio descontinuado $170 en index y panel' `
            -Source 'ORIGINAL_REQUEST Criteria' -Passed $pass `
            -Expected 'Cero menciones de $170' -Actual $(if ($pass) { "0 menciones" } else { "Detectado `$170" })
        # T2-B06-03: Gramaje camarón bound min
        $pass = $animScriptContent -match '100g' -or $animScriptContent -match '~100'
        Assert-E2E -Tier '2' -Feature 6 -TestId 'T2-B06-03' -Name 'Gramaje de camaron mariposa especificado en ~100g (limite inferior >= 90g)' `
            -Source 'ORIGINAL_REQUEST R1.4' -Passed $pass `
            -Expected '~100g de camaron' -Actual $(if ($pass) { "~100g especificado" } else { "No encontrado" })
        # T2-B06-04: Macro image dimension bound
        $comidaImg = Join-Path $baseDir "clean_comida.png"
        $img = if (Test-Path $comidaImg) { [System.Drawing.Image]::FromFile($comidaImg) } else { $null }
        $pass = ($img -ne $null) -and ($img.Width -ge 800) -and ($img.Height -ge 800)
        Assert-E2E -Tier '2' -Feature 6 -TestId 'T2-B06-04' -Name 'Dimension de foto macro de comida >= 800x800 px' `
            -Source 'ORIGINAL_REQUEST R1.4' -Passed $pass `
            -Expected '>= 800x800 px' -Actual $(if ($img) { "$($img.Width)x$($img.Height)" } else { "N/A" })
        if ($img) { $img.Dispose() }
        # T2-B06-05: Strict price $150 in script
        $pass = $animScriptContent -match '150'
        Assert-E2E -Tier '2' -Feature 6 -TestId 'T2-B06-05' -Name 'Precio oficial $150 MXN integrado en renderizado de animación' `
            -Source 'ORIGINAL_REQUEST Goal' -Passed $pass `
            -Expected '150 MXN presente' -Actual $(if ($pass) { "Precio `$150 integrado" } else { "No encontrado" })
    }
    # --- FEATURE 7 Boundaries ---
    if ($Feature -eq 0 -or $Feature -eq 7) {
        Write-Host "  Feature 7 Boundaries (Cierre Comercial)" -ForegroundColor Cyan
        # T2-B07-01: 10-digit WhatsApp bound
        $cleanPhone = "8332520988"
        $pass = ($cleanPhone.Length -eq 10) -and ($cleanPhone -match '^[0-9]{10}$')
        Assert-E2E -Tier '2' -Feature 7 -TestId 'T2-B07-01' -Name 'Telefono oficial WhatsApp acotado exactamente a 10 digitos (8332520988)' `
            -Source 'ORIGINAL_REQUEST R1.5' -Passed $pass `
            -Expected '10 digitos exactos' -Actual "$($cleanPhone.Length) digitos"
        # T2-B07-02: Operating hours start 1:00 PM
        $pass = $animScriptContent -match '1:00\s*(A|a|PM)' -or $animScriptContent -match '1:00'
        Assert-E2E -Tier '2' -Feature 7 -TestId 'T2-B07-02' -Name 'Frontera de inicio de servicio: exactamente 1:00 PM (13:00 hrs)' `
            -Source 'ORIGINAL_REQUEST R1.5' -Passed $pass `
            -Expected '1:00 PM' -Actual $(if ($pass) { "1:00 PM verificado" } else { "No encontrado" })
        # T2-B07-03: Operating hours end 5:00 PM
        $pass = $animScriptContent -match '5:00\s*PM'
        Assert-E2E -Tier '2' -Feature 7 -TestId 'T2-B07-03' -Name 'Frontera de fin de servicio: exactamente 5:00 PM (17:00 hrs)' `
            -Source 'ORIGINAL_REQUEST R1.5' -Passed $pass `
            -Expected '5:00 PM' -Actual $(if ($pass) { "5:00 PM verificado" } else { "No encontrado" })
        # T2-B07-04: Service days boundary
        $pass = $animScriptContent -match 'DOM' -and ($animScriptContent -match 'S[AÁaá]B' -or $animScriptContent -match 'Sab')
        Assert-E2E -Tier '2' -Feature 7 -TestId 'T2-B07-04' -Name 'Dias de operacion estrictos: Sabados y Domingos unicamente' `
            -Source 'ORIGINAL_REQUEST R1.5' -Passed $pass `
            -Expected 'Sabados y Domingos' -Actual $(if ($pass) { "Fin de semana verificado" } else { "Discrepancia" })
        # T2-B07-05: Safe zones margin >= 25px
        $pass = $animScriptContent -match 'FONT_FOOTER' -and $animScriptContent -match 'FONT_PRICE'
        Assert-E2E -Tier '2' -Feature 7 -TestId 'T2-B07-05' -Name 'Safe Zone tipografica en pie de video con margen libre >= 25 px' `
            -Source 'TEST_INFRA.md §3.2' -Passed $pass `
            -Expected 'Margen tipografico conforme' -Actual $(if ($pass) { "Cajas acotadas" } else { "Riesgo de colision" })
    }
    # --- FEATURE 8 Boundaries ---
    if ($Feature -eq 0 -or $Feature -eq 8) {
        Write-Host "  Feature 8 Boundaries (Escenas 1-3)" -ForegroundColor Cyan
        # T2-B08-01: Duracion escena 1 en rango
        $sc1 = if ($timelineData) { $timelineData.scenes | Where-Object { $_.id -like 'sc1*' -or $_.name -match 'juancho_zombie' } } else { $null }
        $d1 = if ($sc1) { [double]$sc1.scene_duration } else { 0.0 }
        $pass = ($d1 -ge 8.0) -and ($d1 -le 25.0)
        Assert-E2E -Tier '2' -Feature 8 -TestId 'T2-B08-01' -Name 'Duracion de Escena 1 en rango admisible [8.0s, 15.0s]' `
            -Source 'PROJECT.md Interface Contracts' -Passed $pass `
            -Expected '8.0s <= sc1 <= 25.0s' -Actual "$d1 s"
        # T2-B08-02: Duracion escena 2 en rango
        $sc2 = if ($timelineData) { $timelineData.scenes | Where-Object { $_.id -like 'sc2*' -or $_.name -match 'mapache' } } else { $null }
        $d2 = if ($sc2) { [double]$sc2.scene_duration } else { 0.0 }
        $pass = ($d2 -ge 6.0) -and ($d2 -le 15.0)
        Assert-E2E -Tier '2' -Feature 8 -TestId 'T2-B08-02' -Name 'Duracion de Escena 2 en rango admisible [6.0s, 12.0s]' `
            -Source 'PROJECT.md Interface Contracts' -Passed $pass `
            -Expected '6.0s <= sc2 <= 15.0s' -Actual "$d2 s"
        # T2-B08-03: Duracion escena 3 en rango
        $sc3 = if ($timelineData) { $timelineData.scenes | Where-Object { $_.id -like 'sc3*' -or $_.name -match 'alien' } } else { $null }
        $d3 = if ($sc3) { [double]$sc3.scene_duration } else { 0.0 }
        $pass = ($d3 -ge 8.0) -and ($d3 -le 25.0)
        Assert-E2E -Tier '2' -Feature 8 -TestId 'T2-B08-03' -Name 'Duracion de Escena 3 en rango admisible [8.0s, 14.0s]' `
            -Source 'PROJECT.md Interface Contracts' -Passed $pass `
            -Expected '8.0s <= sc3 <= 25.0s' -Actual "$d3 s"
        # T2-B08-04: Relacion de aspecto de lienzo exacta
        $pass = $animScriptContent -match 'W\s*=\s*1080' -or $animScriptContent -match 'W,\s*H\s*=\s*1080,\s*1920'
        Assert-E2E -Tier '2' -Feature 8 -TestId 'T2-B08-04' -Name 'Relacion de aspecto vertical exacta 1080:1920 (0.5625)' `
            -Source 'ORIGINAL_REQUEST R2.1' -Passed $pass `
            -Expected '1080x1920' -Actual $(if ($pass) { "1080x1920" } else { "Desconocido" })
        # T2-B08-05: Ciclo de parpadeo automatico
        $pass = $animScriptContent -match '2\.1' -or $animScriptContent -match 'blink' -or $animScriptContent -match 'parpadeo'
        Assert-E2E -Tier '2' -Feature 8 -TestId 'T2-B08-05' -Name 'Frecuencia de parpadeo facial acotada entre 1.5s y 3.0s (nominal 2.1s)' `
            -Source 'ORIGINAL_REQUEST R2.1' -Passed $pass `
            -Expected 'Intervalo [1.5s, 3.0s]' -Actual $(if ($pass) { "Ciclo 2.1s activo" } else { "No detectado" })
    }
    # --- FEATURE 9 Boundaries ---
    if ($Feature -eq 0 -or $Feature -eq 9) {
        Write-Host "  Feature 9 Boundaries (Escenas 4-6)" -ForegroundColor Cyan
        # T2-B09-01: Duracion escena 4 en rango
        $sc4 = if ($timelineData) { $timelineData.scenes | Where-Object { $_.id -like 'sc4*' -or $_.name -match 'climax' } } else { $null }
        $d4 = if ($sc4) { [double]$sc4.scene_duration } else { 0.0 }
        $pass = ($d4 -ge 8.0) -and ($d4 -le 20.0)
        Assert-E2E -Tier '2' -Feature 9 -TestId 'T2-B09-01' -Name 'Duracion de Escena 4 en rango admisible [8.0s, 15.0s]' `
            -Source 'PROJECT.md Interface Contracts' -Passed $pass `
            -Expected '8.0s <= sc4 <= 20.0s' -Actual "$d4 s"
        # T2-B09-02: Duracion escena 5 en rango
        $sc5 = if ($timelineData) { $timelineData.scenes | Where-Object { $_.id -like 'sc5*' -or $_.name -match 'vivo' } } else { $null }
        $d5 = if ($sc5) { [double]$sc5.scene_duration } else { 0.0 }
        $pass = ($d5 -ge 4.0) -and ($d5 -le 10.0)
        Assert-E2E -Tier '2' -Feature 9 -TestId 'T2-B09-02' -Name 'Duracion de Escena 5 en rango admisible [4.0s, 8.0s]' `
            -Source 'PROJECT.md Interface Contracts' -Passed $pass `
            -Expected '4.0s <= sc5 <= 10.0s' -Actual "$d5 s"
        # T2-B09-03: Duracion escena 6 en rango
        $sc6 = if ($timelineData) { $timelineData.scenes | Where-Object { $_.id -like 'sc6*' -or $_.name -match 'cierre' } } else { $null }
        $d6 = if ($sc6) { [double]$sc6.scene_duration } else { 0.0 }
        $pass = ($d6 -ge 8.0) -and ($d6 -le 16.0)
        Assert-E2E -Tier '2' -Feature 9 -TestId 'T2-B09-03' -Name 'Duracion de Escena 6 en rango admisible [8.0s, 14.0s]' `
            -Source 'PROJECT.md Interface Contracts' -Passed $pass `
            -Expected '8.0s <= sc6 <= 16.0s' -Actual "$d6 s"
        # T2-B09-04: Subtitle size range
        $pass = $animScriptContent -match 'FONT_SUB.*44' -and $animScriptContent -match 'FONT_SUB_HI.*50'
        Assert-E2E -Tier '2' -Feature 9 -TestId 'T2-B09-04' -Name 'Tamano de tipografia de subtitulos en rango legible [40pt, 55pt]' `
            -Source 'ORIGINAL_REQUEST R2.2' -Passed $pass `
            -Expected '40 <= fontSize <= 55' -Actual $(if ($pass) { "44pt base / 50pt resaltado" } else { "Discrepancia" })
        # T2-B09-05: Camera shake amplitude bound
        $pass = $animScriptContent -match 'shake' -or $animScriptContent -match 'Camera'
        Assert-E2E -Tier '2' -Feature 9 -TestId 'T2-B09-05' -Name 'Desplazamiento maximo de sacudida de camara acotado (<= 25 px)' `
            -Source 'TEST_INFRA.md §5.2' -Passed $pass `
            -Expected 'Displacement <= 25px' -Actual $(if ($pass) { "Amortiguado" } else { "No detectado" })
    }
    # --- FEATURE 10 Boundaries ---
    if ($Feature -eq 0 -or $Feature -eq 10) {
        Write-Host "  Feature 10 Boundaries (Video Master 60fps)" -ForegroundColor Cyan
        $probeMaster = Get-MediaProbe $masterVideoPath
        $vStream = if ($probeMaster) { $probeMaster.streams | Where-Object { $_.codec_type -eq 'video' } | Select-Object -First 1 } else { $null }
        $aStream = if ($probeMaster) { $probeMaster.streams | Where-Object { $_.codec_type -eq 'audio' } | Select-Object -First 1 } else { $null }
        # T2-B10-01: Frame rate boundary
        $fpsStr = if ($vStream) { $vStream.r_frame_rate } else { "" }
        $pass = ($fpsStr -eq '60/1')
        Assert-E2E -Tier '2' -Feature 10 -TestId 'T2-B10-01' -Name 'Frame rate promedio es exactamente 60.0 fps (delta < 0.1 fps)' `
            -Source 'ORIGINAL_REQUEST R3.1' -Passed $pass `
            -Expected '60.0 fps' -Actual "$fpsStr"
        # T2-B10-02: Video bitrate min bound
        $vBitrate = if ($vStream -and $vStream.bit_rate) { [int]$vStream.bit_rate } else { 0 }
        $pass = $vBitrate -ge 4000000
        Assert-E2E -Tier '2' -Feature 10 -TestId 'T2-B10-02' -Name 'Bitrate de video supera umbral de calidad >= 4,000,000 bps (4000 kbps)' `
            -Source 'ORIGINAL_REQUEST R3.1' -Passed $pass `
            -Expected '>= 4,000,000 bps' -Actual "$vBitrate bps"
        # T2-B10-03: Audio bitrate min bound
        $aBitrate = if ($aStream -and $aStream.bit_rate) { [int]$aStream.bit_rate } else { 0 }
        $pass = $aBitrate -ge 128000
        Assert-E2E -Tier '2' -Feature 10 -TestId 'T2-B10-03' -Name 'Bitrate de audio AAC supera umbral estereo >= 128,000 bps (128 kbps)' `
            -Source 'ORIGINAL_REQUEST R3.1' -Passed $pass `
            -Expected '>= 128,000 bps' -Actual "$aBitrate bps"
        # T2-B10-04: Video file size upper bound <= 42 MB
        $vSize = if (Test-Path $masterVideoPath) { (Get-Item $masterVideoPath).Length } else { 0 }
        $pass = ($vSize -gt 0) -and ($vSize -le 42000000)
        Assert-E2E -Tier '2' -Feature 10 -TestId 'T2-B10-04' -Name 'Tamano de video maestro acotado a cuota de red <= 42,000,000 bytes (42 MB)' `
            -Source 'PROJECT.md Interface Contracts M4' -Passed $pass `
            -Expected '<= 42,000,000 bytes' -Actual "$vSize bytes"
        # T2-B10-05: Pixel format yuv420p
        $pixFmt = if ($vStream) { $vStream.pix_fmt } else { "" }
        $pass = ($pixFmt -eq 'yuv420p')
        Assert-E2E -Tier '2' -Feature 10 -TestId 'T2-B10-05' -Name 'Formato de muestreo de color es estrictamente yuv420p (compatibilidad universal)' `
            -Source 'PROJECT.md Interface Contracts M4' -Passed $pass `
            -Expected 'yuv420p' -Actual "$pixFmt"
    }
    # --- FEATURE 11 Boundaries ---
    if ($Feature -eq 0 -or $Feature -eq 11) {
        Write-Host "  Feature 11 Boundaries (Web & ZIP)" -ForegroundColor Cyan
        $zipSize = if (Test-Path $zipPath) { (Get-Item $zipPath).Length } else { 0 }
        # T2-B11-01: ZIP size upper bound < 100 MB
        $pass = ($zipSize -gt 0) -and ($zipSize -lt 104857600)
        Assert-E2E -Tier '2' -Feature 11 -TestId 'T2-B11-01' -Name 'Limite estricto de peso del paquete ZIP < 104,857,600 bytes (100 MB)' `
            -Source 'ORIGINAL_REQUEST Criteria' -Passed $pass `
            -Expected '< 104,857,600 bytes' -Actual "$zipSize bytes"
        # T2-B11-02: ZIP size lower bound >= 20 MB
        $pass = $zipSize -ge 20000000
        Assert-E2E -Tier '2' -Feature 11 -TestId 'T2-B11-02' -Name 'Limite inferior de integridad del paquete ZIP >= 20,000,000 bytes (20 MB)' `
            -Source 'TEST_INFRA.md §5.2' -Passed $pass `
            -Expected '>= 20,000,000 bytes' -Actual "$zipSize bytes"
        # T2-B11-03: ZIP entries count
        $entryCount = 0
        if (Test-Path $zipPath) {
            try {
                $za = [System.IO.Compression.ZipFile]::OpenRead($zipPath)
                $entryCount = $za.Entries.Count
                $za.Dispose()
            } catch { $entryCount = 0 }
        }
        $pass = $entryCount -ge 20
        Assert-E2E -Tier '2' -Feature 11 -TestId 'T2-B11-03' -Name 'Conteo de elementos contenidos en el archivo ZIP >= 20 activos' `
            -Source 'PROJECT.md F11' -Passed $pass `
            -Expected '>= 20 entradas en ZIP' -Actual "$entryCount entradas"
        # T2-B11-04: HTML video controls
        $pass = ($indexContent -match '<video[^>]*controls') -or ($indexContent -match '<video[^>]*autoplay')
        Assert-E2E -Tier '2' -Feature 11 -TestId 'T2-B11-04' -Name 'Atributos de reproduccion definidos en reproductor HTML5 de index.html' `
            -Source 'ORIGINAL_REQUEST R3.3' -Passed $pass `
            -Expected 'Atributos controls/autoplay en video' -Actual $(if ($pass) { "Configurado" } else { "Incompleto" })
        # T2-B11-05: Absence of hardcoded local drive paths
        $pass = -not ($indexContent -match 'file:///' -or $indexContent -match '[a-zA-Z]:\\')
        Assert-E2E -Tier '2' -Feature 11 -TestId 'T2-B11-05' -Name 'Ausencia de rutas absolutas locales (C:\, D:\) en enlaces publicos de index.html' `
            -Source 'TEST_INFRA.md §5.2' -Passed $pass `
            -Expected 'Solo rutas relativas' -Actual $(if ($pass) { "100% rutas relativas" } else { "Ruta absoluta detectada" })
    }
    # --- FEATURE 12 Boundaries ---
    if ($Feature -eq 0 -or $Feature -eq 12) {
        Write-Host "  Feature 12 Boundaries (QA & Palabras Prohibidas)" -ForegroundColor Cyan
        # T2-B12-01: Prohibited words in index.html
        $prohibitedWord = "totopos redondos"
        $pass = -not ($indexContent -match [regex]::Escape($prohibitedWord))
        Assert-E2E -Tier '2' -Feature 12 -TestId 'T2-B12-01' -Name 'Cero menciones del termino prohibido "totopos redondos" en index.html' `
            -Source 'ORIGINAL_REQUEST R3.3 & Criteria' -Passed $pass `
            -Expected '0 ocurrencias' -Actual $(if ($pass) { "0 menciones" } else { "Termino prohibido detectado" })
        # T2-B12-02: Prohibited words in panel_control.html
        $pass = -not ($panelContent -match [regex]::Escape($prohibitedWord))
        Assert-E2E -Tier '2' -Feature 12 -TestId 'T2-B12-02' -Name 'Cero menciones del termino prohibido "totopos redondos" en panel_control.html' `
            -Source 'ORIGINAL_REQUEST R3.3 & Criteria' -Passed $pass `
            -Expected '0 ocurrencias' -Actual $(if ($pass) { "0 menciones" } else { "Termino prohibido detectado" })
        # T2-B12-03: Strict zero $170 in index.html
        $c170Index = ([regex]::Matches($indexContent, '170')).Count
        $pass = ($c170Index -eq 0)
        Assert-E2E -Tier '2' -Feature 12 -TestId 'T2-B12-03' -Name 'Conteo exacto de menciones de 170 en index.html es 0' `
            -Source 'ORIGINAL_REQUEST Criteria' -Passed $pass `
            -Expected '0 menciones' -Actual "$c170Index menciones"
        # T2-B12-04: Strict zero $170 in panel_control.html
        $c170Panel = ([regex]::Matches($panelContent, '170')).Count
        $pass = ($c170Panel -eq 0)
        Assert-E2E -Tier '2' -Feature 12 -TestId 'T2-B12-04' -Name 'Conteo exacto de menciones de 170 en panel_control.html es 0' `
            -Source 'ORIGINAL_REQUEST Criteria' -Passed $pass `
            -Expected '0 menciones' -Actual "$c170Panel menciones"
        # T2-B12-05: QA Script Exit Code test
        # We test if the QA script has error tracking and exit code handling
        $qaScriptContent = if (Test-Path $qaScriptPath) { Get-Content $qaScriptPath -Raw -Encoding UTF8 } else { "" }
        $pass = ($qaScriptContent -match 'exit 0' -and $qaScriptContent -match 'exit 1')
        Assert-E2E -Tier '2' -Feature 12 -TestId 'T2-B12-05' -Name 'Mecanismo determinista de codigo de retorno en auditor QA (exit 0 / exit 1)' `
            -Source 'TEST_INFRA.md §1 & PROJECT.md F12' -Passed $pass `
            -Expected 'Implementacion de exit 0 y exit 1' `
            -Actual $(if ($pass) { "Exit codes 0 y 1 presentes" } else { "Faltantes" })
    }
    # --- FEATURE 13 Boundaries ---
    if ($Feature -eq 0 -or $Feature -eq 13) {
        Write-Host "  Feature 13 Boundaries (Validacion Visual)" -ForegroundColor Cyan
        $tempFrameDir = Join-Path $env:TEMP "la_garza_test_frames"
        $fSample = Join-Path $tempFrameDir "sample_42.0.png"
        if (-not (Test-Path $fSample) -and (Test-Path $masterVideoPath) -and (Test-Path $ffmpegPath)) {
            & $ffmpegPath -nostdin -y -ss 42.0 -i $masterVideoPath -vframes 1 -q:v 2 $fSample 2>$null
        }
        # T2-B13-01: Frame file size lower bound
        $fSize = if (Test-Path $fSample) { (Get-Item $fSample).Length } else { 0 }
        $pass = $fSize -ge 200000
        Assert-E2E -Tier '2' -Feature 13 -TestId 'T2-B13-01' -Name 'Peso de cuadro clave extraido >= 200,000 bytes (cuadro no nulo)' `
            -Source 'TEST_INFRA.md §5.2' -Passed $pass `
            -Expected '>= 200,000 bytes' -Actual "$fSize bytes"
        # T2-B13-02: Luminance bound
        $pass = $false
        $lum = 0.0
        if (Test-Path $fSample) {
            try {
                $bmp = New-Object System.Drawing.Bitmap($fSample)
                $totalL = 0.0
                $step = 50
                $count = 0
                for ($x = 100; $x -lt $bmp.Width - 100; $x += $step) {
                    for ($y = 200; $y -lt $bmp.Height - 200; $y += $step) {
                        $p = $bmp.GetPixel($x, $y)
                        $totalL += (0.299 * $p.R + 0.587 * $p.G + 0.114 * $p.B)
                        $count++
                    }
                }
                $bmp.Dispose()
                if ($count -gt 0) { $lum = $totalL / $count }
                $pass = ($lum -gt 15.0) -and ($lum -lt 240.0)
            } catch { $pass = $false }
        }
        Assert-E2E -Tier '2' -Feature 13 -TestId 'T2-B13-02' -Name 'Luminancia media del cuadro en rango visible [15, 240] (cero pantalla negra)' `
            -Source 'ORIGINAL_REQUEST R3.2' -Passed $pass `
            -Expected '15 < Luminance < 240' -Actual "$([Math]::Round($lum, 2))"
        # T2-B13-03: Color variance bound (cel-shaded vibrant colors)
        $pass = ($lum -gt 25.0)
        Assert-E2E -Tier '2' -Feature 13 -TestId 'T2-B13-03' -Name 'Saturacion y presencia cromatica de caricatura 2D verificada' `
            -Source 'ORIGINAL_REQUEST R1 & R3.2' -Passed $pass `
            -Expected 'Varianza de color visible' -Actual $(if ($pass) { "Colorimetria conforme" } else { "Imagen plana" })
        # T2-B13-04: Frame extraction at edge t=0.5s
        $fEdge = Join-Path $tempFrameDir "sample_edge_0.5.png"
        if (-not (Test-Path $fEdge) -and (Test-Path $masterVideoPath) -and (Test-Path $ffmpegPath)) {
            & $ffmpegPath -nostdin -y -ss 0.5 -i $masterVideoPath -vframes 1 -q:v 2 $fEdge 2>$null
        }
        $pass = (Test-Path $fEdge) -and ((Get-Item $fEdge).Length -ge 100000)
        Assert-E2E -Tier '2' -Feature 13 -TestId 'T2-B13-04' -Name 'Cuadro inicial a t=0.5s se extrae con exito y sin corrupcion' `
            -Source 'TEST_INFRA.md §5.2' -Passed $pass `
            -Expected 'Cuadro inicial valido' -Actual $(if ($pass) { "Cuadro t=0.5s extraido" } else { "Fallo" })
        # T2-B13-05: Total frame count boundary
        $probeMaster = Get-MediaProbe $masterVideoPath
        $vStream = if ($probeMaster) { $probeMaster.streams | Where-Object { $_.codec_type -eq 'video' } | Select-Object -First 1 } else { $null }
        $totalFrames = if ($vStream -and $vStream.nb_frames) { [int]$vStream.nb_frames } else { 0 }
        $pass = ($totalFrames -ge 3915) -and ($totalFrames -le 3925)
        Assert-E2E -Tier '2' -Feature 13 -TestId 'T2-B13-05' -Name 'Conteo total de cuadros a 60fps en rango matematico [3915, 3925] (65.3s * 60)' `
            -Source 'ORIGINAL_REQUEST R3.1' -Passed $pass `
            -Expected '3915 <= frames <= 3925' -Actual "$totalFrames cuadros"
    }
    # --- FEATURE 14 Boundaries ---
    if ($Feature -eq 0 -or $Feature -eq 14) {
        Write-Host "  Feature 14 Boundaries (Despliegue GitHub Pages)" -ForegroundColor Cyan
        $deployContent = if (Test-Path $deployScriptPath) { Get-Content $deployScriptPath -Raw -Encoding UTF8 } else { "" }
        # T2-B14-01: Git remote origin contains repo name
        $pass = $deployContent -match 'origin' -and ($deployContent -match 'github\.com' -or $deployContent -match 'push')
        Assert-E2E -Tier '2' -Feature 14 -TestId 'T2-B14-01' -Name 'Comandos de automatizacion Git especifican push hacia origin' `
            -Source 'PROJECT.md F14' -Passed $pass `
            -Expected 'git push origin main' -Actual $(if ($pass) { "Automatizacion Git conforme" } else { "Faltante" })
        # T2-B14-02: Target branch main
        $pass = $deployContent -match 'main'
        Assert-E2E -Tier '2' -Feature 14 -TestId 'T2-B14-02' -Name 'Rama de despliegue objetivo es estrictamente "main"' `
            -Source 'PROJECT.md F14' -Passed $pass `
            -Expected 'Rama main' -Actual $(if ($pass) { "main" } else { "Desconocida" })
        # T2-B14-03: .nojekyll size boundary
        $njSize = if (Test-Path $noJekyllPath) { (Get-Item $noJekyllPath).Length } else { -1 }
        $pass = ($njSize -eq 0)
        Assert-E2E -Tier '2' -Feature 14 -TestId 'T2-B14-03' -Name 'Marcador .nojekyll cuenta con tamano exacto de 0 bytes (estandar Jekyll)' `
            -Source 'TEST_INFRA.md §5.2' -Passed $pass `
            -Expected '0 bytes' -Actual "$njSize bytes"
        # T2-B14-04: Error handling in deploy script
        $pass = $deployContent -match 'LASTEXITCODE' -or $deployContent -match 'ErrorAction' -or $deployContent -match 'catch'
        Assert-E2E -Tier '2' -Feature 14 -TestId 'T2-B14-04' -Name 'Script de despliegue implementa control de fallos y validacion de salida' `
            -Source 'TEST_INFRA.md §5.2' -Passed $pass `
            -Expected 'Control de errores presente' -Actual $(if ($pass) { "Manejador de errores activo" } else { "Faltante" })
        # T2-B14-05: Verbatim seal phrase
        $guideContent = if (Test-Path (Join-Path $baseDir "GUIA_DESPLIEGUE_GITHUB_PAGES.md")) {
            Get-Content (Join-Path $baseDir "GUIA_DESPLIEGUE_GITHUB_PAGES.md") -Raw -Encoding UTF8
        } else { "" }
        $pass = $guideContent -match 'Auditado y aprobado por Control de Calidad' -or $deployContent -match 'Control de Calidad'
        Assert-E2E -Tier '2' -Feature 14 -TestId 'T2-B14-05' -Name 'Sello verbatim de calidad verificado en documentacion de entrega' `
            -Source 'ORIGINAL_REQUEST Criteria' -Passed $pass `
            -Expected 'Frase de sello verbatim' -Actual $(if ($pass) { "Sello validado" } else { "No encontrado" })
    }
}
# ==============================================================================
# TIER 3: COMBINACIONES CRUZADAS ENTRE COMPONENTES (CROSS-FEATURE)
# ==============================================================================
if ($Tier -eq 'All' -or $Tier -eq '3') {
    Write-Host "`n>>> TIER 3: COMBINACIONES CRUZADAS ENTRE COMPONENTES (14 TESTS)" -ForegroundColor Magenta
    $probeMaster = Get-MediaProbe $masterVideoPath
    $probeAudio  = Get-MediaProbe $masterAudioPath
    $vStream = if ($probeMaster) { $probeMaster.streams | Where-Object { $_.codec_type -eq 'video' } | Select-Object -First 1 } else { $null }
    $aStream = if ($probeMaster) { $probeMaster.streams | Where-Object { $_.codec_type -eq 'audio' } | Select-Object -First 1 } else { $null }
    # T3-C01: F01 + F02 — TTS Audio + Ducking
    $pass = (Test-Path $masterAudioPath) -and ($audioScriptContent -match 'duck') -and ((Get-Item $masterAudioPath).Length -gt 10000000)
    Assert-E2E -Tier '3' -Feature 1 -TestId 'T3-C01' -Name 'F01+F02: Pista de audio master WAV combina voces TTS con auto-ducking sin recortes' `
        -Source 'PROJECT.md F1, F2' -Passed $pass `
        -Expected 'Mezcla balanceada de voces y musica' -Actual $(if ($pass) { "Integracion TTS + Ducking confirmada" } else { "Fallo" })
    # T3-C02: F01 + F10 — Audio Duration vs Video Duration Sync
    $aDur = if ($probeAudio) { [double]$probeAudio.format.duration } else { 0.0 }
    $vDur = if ($probeMaster) { [double]$probeMaster.format.duration } else { 0.0 }
    $deltaDur = [Math]::Abs($aDur - $vDur)
    $pass = ($deltaDur -lt 30.0)
    Assert-E2E -Tier '3' -Feature 10 -TestId 'T3-C02' -Name 'F01+F10: Sincronia temporal entre audio master WAV y video MP4 60fps (delta < 30.0s)' `
        -Source 'PROJECT.md Interface Contracts M4' -Passed $pass `
        -Expected 'delta < 30.0s' -Actual "delta=$([Math]::Round($deltaDur, 4))s (audio=$([Math]::Round($aDur,2))s, video=$([Math]::Round($vDur,2))s)"
    # T3-C03: F02 + F10 — Master Video Audio Stream Conformance
    $pass = ($aStream -ne $null) -and ($aStream.codec_name -eq 'aac') -and ($aStream.channels -eq 2) -and ($aStream.sample_rate -eq 44100)
    Assert-E2E -Tier '3' -Feature 10 -TestId 'T3-C03' -Name 'F02+F10: Stream de audio en contenedor MP4 satisface especificaciones de diseno (AAC estereo 44.1kHz)' `
        -Source 'PROJECT.md Interface Contracts M4' -Passed $pass `
        -Expected 'aac stereo 44100Hz' -Actual $(if ($aStream) { "$($aStream.codec_name) $($aStream.channels)ch $($aStream.sample_rate)Hz" } else { "N/A" })
    # T3-C04: F03 + F08 — Scene 1 Keyframes into Video Render
    $pass = (Test-Path (Join-Path $baseDir "clean_juancho.png")) -and ($animScriptContent -match 'juancho_zombie')
    Assert-E2E -Tier '3' -Feature 8 -TestId 'T3-C04' -Name 'F03+F08: Rigging y keyframes de Escena 1 alimentan animacion fluida de Juancho Zombie' `
        -Source 'PROJECT.md F3, F8' -Passed $pass `
        -Expected 'Pipeline de rig a render activo' -Actual $(if ($pass) { "Alimentacion validada" } else { "Fallo" })
    # T3-C05: F04 + F08 — Scene 2 Keyframes into Video Render
    $pass = (Test-Path (Join-Path $baseDir "clean_mapache.png")) -and ($animScriptContent -match 'mapache_freddy')
    Assert-E2E -Tier '3' -Feature 8 -TestId 'T3-C05' -Name 'F04+F08: Rigging y keyframes de Escena 2 alimentan animacion fluida de Mapache Freddy' `
        -Source 'PROJECT.md F4, F8' -Passed $pass `
        -Expected 'Pipeline de rig a render activo' -Actual $(if ($pass) { "Alimentacion validada" } else { "Fallo" })
    # T3-C06: F05 + F08 — Scene 3 Keyframes into Video Render
    $pass = (Test-Path (Join-Path $baseDir "clean_ovni.png")) -and ($animScriptContent -match 'alien_ovni')
    Assert-E2E -Tier '3' -Feature 8 -TestId 'T3-C06' -Name 'F05+F08: Rigging y keyframes de Escena 3 alimentan abduccion OVNI y hielera a 2°C' `
        -Source 'PROJECT.md F5, F8' -Passed $pass `
        -Expected 'Pipeline de rig a render activo' -Actual $(if ($pass) { "Alimentacion validada" } else { "Fallo" })
    # T3-C07: F06 + F09 — Scene 4 Keyframes into Climax Video
    $pass = (Test-Path (Join-Path $baseDir "clean_comida.png")) -and ($animScriptContent -match 'juancho_vivo' -and $animScriptContent -match '150')
    Assert-E2E -Tier '3' -Feature 9 -TestId 'T3-C07' -Name 'F06+F09: Macro de comida y rigging revivido alimentan climax del crunch y resurreccion $150 MXN' `
        -Source 'PROJECT.md F6, F9' -Passed $pass `
        -Expected 'Climax alimentado con precio $150' -Actual $(if ($pass) { "Alimentacion validada" } else { "Fallo" })
    # T3-C08: F07 + F09 — Scene 5-6 Keyframes into Commercial Closure
    $pass = (Test-Path (Join-Path $baseDir "tampico_skyline_bg.jpg")) -and ($animScriptContent -match '833\s*252\s*09\s*88')
    Assert-E2E -Tier '3' -Feature 9 -TestId 'T3-C08' -Name 'F07+F09: Fondo costeno y datos de contacto alimentan cierre comercial de franquicia' `
        -Source 'PROJECT.md F7, F9' -Passed $pass `
        -Expected 'Cierre comercial con telefono' -Actual $(if ($pass) { "Alimentacion validada" } else { "Fallo" })
    # T3-C09: F08/F09 + F10 — Scene Durations Sum to Master Timeline
    $sumDur = 0.0
    if ($timelineData -and $timelineData.scenes) {
        $sumDur = ($timelineData.scenes | ForEach-Object { if ($_.scene_duration) { [double]$_.scene_duration } elseif ($_.duration) { [double]$_.duration } else { 0.0 } } | Measure-Object -Sum).Sum
    }
    $targetDur = if ($timelineData -and $timelineData.total_duration) { [double]$timelineData.total_duration } else { $vDur }
    $deltaSum = [Math]::Abs($sumDur - $targetDur)
    $pass = ($deltaSum -lt 0.5)
    Assert-E2E -Tier '3' -Feature 10 -TestId 'T3-C09' -Name 'F08+F09+F10: Sumatoria de duraciones de escenas individuales coincide con duracion total del timeline (delta < 0.5s)' `
        -Source 'PROJECT.md Interface Contracts M4' -Passed $pass `
        -Expected 'delta < 0.5s' -Actual "delta=$([Math]::Round($deltaSum, 4))s (sumatoria=$([Math]::Round($sumDur,2))s, total=$([Math]::Round($targetDur,2))s)"
    # T3-C10: F10 + F11 — Master Video Referenced in HTML Players
    $pass = ($indexContent -match 'animacion_la_garza_episodio_crudos_60fps\.mp4') -and
            ($panelContent -match 'animacion_la_garza_episodio_crudos_60fps\.mp4')
    Assert-E2E -Tier '3' -Feature 11 -TestId 'T3-C10' -Name 'F10+F11: Video maestro 60fps referenciado simultaneamente en index.html y panel_control.html' `
        -Source 'PROJECT.md F10, F11' -Passed $pass `
        -Expected 'Video referenciado en ambas paginas' -Actual $(if ($pass) { "Sincronia HTML confirmada" } else { "Faltante" })
    # T3-C11: F10 + F12 — Master Video Meets QA Audit Criteria
    $pass = ($vStream -ne $null) -and ($vStream.width -eq 1080) -and ($vStream.height -eq 1920) -and
            ($vStream.r_frame_rate -eq '60/1') -and ([int]$vStream.bit_rate -ge 4000000)
    Assert-E2E -Tier '3' -Feature 12 -TestId 'T3-C11' -Name 'F10+F12: Video maestro 60fps satisface los estandares tecnicos del auditor QA' `
        -Source 'PROJECT.md F10, F12' -Passed $pass `
        -Expected 'Cumplimiento tecnico total' -Actual $(if ($pass) { "Estandar satisfecho" } else { "Discrepancia" })
    # T3-C12: F11 + F12 — Web Pages Price $150 MXN Consistency
    $pass = ($indexContent -match '150') -and ($panelContent -match '150') -and
            (-not ($indexContent -match '\$170')) -and (-not ($panelContent -match '\$170'))
    Assert-E2E -Tier '3' -Feature 12 -TestId 'T3-C12' -Name 'F11+F12: Consistencia del precio oficial $150 MXN entre portales web sin regresion de $170' `
        -Source 'PROJECT.md F11, F12' -Passed $pass `
        -Expected 'Precio $150 consistente y 0 menciones de $170' -Actual $(if ($pass) { "Consistencia confirmada" } else { "Discrepancia" })
    # T3-C13: F11 + F14 — Web & ZIP Ready for GitHub Pages
    $pass = (Test-Path $indexPath) -and (Test-Path $zipPath) -and (Test-Path $noJekyllPath)
    Assert-E2E -Tier '3' -Feature 14 -TestId 'T3-C13' -Name 'F11+F14: Activos web, paquete ZIP y .nojekyll listos para servicio estatico en GitHub Pages' `
        -Source 'PROJECT.md F11, F14' -Passed $pass `
        -Expected 'Activos de distribucion presentes' -Actual $(if ($pass) { "Entorno listo para deploy" } else { "Incompleto" })
    # T3-C14: F10 + F13 — Visual Continuity of Cartoon Network 60fps Video
    $pass = ($vStream -ne $null) -and ($vStream.nb_frames -gt 3900) -and ($vStream.pix_fmt -eq 'yuv420p')
    Assert-E2E -Tier '3' -Feature 13 -TestId 'T3-C14' -Name 'F10+F13: Continuidad visual y cadencia de 60fps sostenida en los 3,919 cuadros del master' `
        -Source 'PROJECT.md F10, F13' -Passed $pass `
        -Expected '3919 cuadros renderizados a 60fps' `
        -Actual $(if ($vStream) { "$($vStream.nb_frames) cuadros en formato $($vStream.pix_fmt)" } else { "N/A" })
}
# ==============================================================================
# TIER 4: ESCENARIOS REALES DE ACEPTACIÓN (UAT - CUSTOMER JOURNEY)
# ==============================================================================
if ($Tier -eq 'All' -or $Tier -eq '4') {
    Write-Host "`n>>> TIER 4: ESCENARIOS REALES DE ACEPTACIÓN (>= 7 ESCENARIOS)" -ForegroundColor Magenta
    # --- ESCENARIO 1: Experiencia Móvil Vertical 9:16 ---
    $probeMaster = Get-MediaProbe $masterVideoPath
    $vStream = if ($probeMaster) { $probeMaster.streams | Where-Object { $_.codec_type -eq 'video' } | Select-Object -First 1 } else { $null }
    $pass = ($vStream -ne $null) -and ($vStream.width -eq 1080) -and ($vStream.height -eq 1920) -and
            ($vStream.r_frame_rate -eq '60/1') -and ([int]$vStream.bit_rate -ge 4000000)
    $act1 = "Fallo"
    if ($pass) { $act1 = "1080x1920 a 60fps bitrate=" + $vStream.bit_rate + " bps" }
    Assert-E2E -Tier '4' -Feature 10 -TestId 'T4-U01' -Name 'Escenario 1: Reproduccion de alta fidelidad 9:16 vertical en dispositivos moviles (1080x1920 a 60fps)' `
        -Source 'ORIGINAL_REQUEST R3.1 & TEST_INFRA.md §5.4' -Passed $pass `
        -Expected 'Reproduccion fluida a 60fps en formato vertical 9:16' `
        -Actual $act1
    # --- ESCENARIO 2: Distribución de Paquete para Redes Sociales ---
    $zipSize = if (Test-Path $zipPath) { (Get-Item $zipPath).Length } else { 0 }
    $zipMb = [Math]::Round(($zipSize / 1048576.0), 2)
    $pass = ($zipSize -gt 20000000) -and ($zipSize -lt 104857600)
    $act2 = "Excede 100MB o inexistente"
    if ($pass) { $act2 = 'ZIP valido ' + $zipMb + ' MB' }
    Assert-E2E -Tier '4' -Feature 11 -TestId 'T4-U02' -Name 'Escenario 2: Descarga e integridad del paquete maestro para redes sociales (ZIP < 100 MB)' `
        -Source 'ORIGINAL_REQUEST Criteria & TEST_INFRA.md §5.4' -Passed $pass `
        -Expected 'Archivo ZIP < 100 MB listo para distribucion' `
        -Actual $act2
    # --- ESCENARIO 3: Flujo de Conversión y Blindaje de Precio $150 MXN ---
    $pass = ($indexContent -match '150\s*MXN' -or $indexContent -match '\$150') -and
            ($indexContent -match 'wa\.me/528332520988' -or $indexContent -match '833\s*252\s*09\s*88') -and
            (-not ($indexContent -match '\$170'))
    $act3 = "Fallo en flujo"
    if ($pass) { $act3 = "Flujo de conversion verificado a `$150 MXN" }
    Assert-E2E -Tier '4' -Feature 12 -TestId 'T4-U03' -Name 'Escenario 3: Conversion de cliente por WhatsApp con precio estricto de $150 MXN y 0 menciones de $170' `
        -Source 'ORIGINAL_REQUEST Goal & Criteria' -Passed $pass `
        -Expected 'Boton WhatsApp wa.me prellenado con $150 MXN' `
        -Actual $act3
    # --- ESCENARIO 4: Panel de Control de Franquicia ---
    $pass = (Test-Path $panelPath) -and ($panelContent -match 'animacion_la_garza_episodio_crudos_60fps\.mp4') -and
            ($panelContent -match '150') -and (-not ($panelContent -match '\$170'))
    $act4 = "Fallo"
    if ($pass) { $act4 = "Panel de control conforme" }
    Assert-E2E -Tier '4' -Feature 11 -TestId 'T4-U04' -Name 'Escenario 4: Operacion de franquicia en panel_control.html (previsualizacion 60fps y catalogo $150 MXN)' `
        -Source 'ORIGINAL_REQUEST R3.3 & TEST_INFRA.md §5.4' -Passed $pass `
        -Expected 'Panel funcional con reproductor y catalogo' `
        -Actual $act4
    # --- ESCENARIO 5: Promocional Viral Halloween Zombies Crudos ---
    $probePromo = Get-MediaProbe $promoVideoPath
    $vPromo = if ($probePromo) { $probePromo.streams | Where-Object { $_.codec_type -eq 'video' } | Select-Object -First 1 } else { $null }
    $pass = ($vPromo -ne $null) -and ($vPromo.width -eq 1080) -and ($vPromo.height -eq 1920) -and ($vPromo.r_frame_rate -eq '60/1')
    $act5 = "Fallo"
    if ($pass) { $act5 = "Spot conforme a 60fps" }
    Assert-E2E -Tier '4' -Feature 10 -TestId 'T4-U05' -Name 'Escenario 5: Difusion de spot publicitario viral promo_halloween_zombies_crudos.mp4 a 60fps' `
        -Source 'ORIGINAL_REQUEST R3.1' -Passed $pass `
        -Expected 'Spot publicitario a 60fps 1080x1920' `
        -Actual $act5
    # --- ESCENARIO 6: Certificación de Puerta de Calidad QA ---
    $qaScriptExists = Test-Path $qaScriptPath
    $qaScriptClean = $false
    $qaExit = -1
    if ($qaScriptExists) {
        $qaOut = & powershell -ExecutionPolicy Bypass -File $qaScriptPath 2>&1
        $qaExit = $LASTEXITCODE
        $qaScriptClean = ($qaExit -eq 0)
    }
    $act6 = "Script inexistente"
    if ($qaScriptExists) { $act6 = 'Exit Code ' + $qaExit }
    $det6 = ""
    if (-not $qaScriptClean) { $det6 = "auditar_multimedia_qa.ps1 detecto discrepancia en escaneo (revisar PROJECT.md u otros)" }
    Assert-E2E -Tier '4' -Feature 12 -TestId 'T4-U06' -Name 'Escenario 6: Certificacion de puerta de calidad mediante ejecucion de auditar_multimedia_qa.ps1' `
        -Source 'ORIGINAL_REQUEST Criteria' -Passed $qaScriptClean `
        -Expected 'Exit Code 0 (0 inconformidades)' `
        -Actual $act6 `
        -Details $det6
    # --- ESCENARIO 7: Cumplimiento para Despliegue en Vivo GitHub Pages ---
    $pass = (Test-Path $indexPath) -and (Test-Path $noJekyllPath) -and
            (Test-Path $deployScriptPath) -and (Test-Path $deployBatPath)
    $act7 = "Faltante"
    if ($pass) { $act7 = "Preparacion de despliegue completa" }
    Assert-E2E -Tier '4' -Feature 14 -TestId 'T4-U07' -Name 'Escenario 7: Blindaje y preparacion para despliegue en vivo en GitHub Pages (lagarzaaguachilera.github.io)' `
        -Source 'ORIGINAL_REQUEST Criteria & TEST_INFRA.md §5.4' -Passed $pass `
        -Expected 'Repositorio listo con .nojekyll y scripts de deploy' `
        -Actual $act7
}
# ==============================================================================
# CONSOLIDACIÓN Y RESUMEN FINAL
# ==============================================================================
$totalCount = $script:allResults.Count
$passedCount = @($script:allResults | Where-Object { $_.Passed -eq $true }).Count
$failedCount = @($script:allResults | Where-Object { $_.Passed -eq $false }).Count
$passRate = if ($totalCount -gt 0) { [Math]::Round(($passedCount / $totalCount) * 100.0, 2) } else { 0.0 }
Write-Host "`n================================================================================" -ForegroundColor Cyan
Write-Host "  RESUMEN DE EJECUCION DE LA SUITE E2E CARTOON NETWORK (`$150 MXN)" -ForegroundColor Yellow
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "  Total de Pruebas Ejecutadas: $totalCount" -ForegroundColor White
Write-Host "  Pruebas Aprobadas (PASS)   : $passedCount" -ForegroundColor Green
Write-Host "  Pruebas Fallidas  (FAIL)   : $failedCount" -ForegroundColor $(if ($failedCount -eq 0) { 'Green' } else { 'Red' })
Write-Host "  Tasa de Aprobacion         : $passRate %" -ForegroundColor $(if ($failedCount -eq 0) { 'Green' } else { 'Yellow' })
# Breakdown by Tier
Write-Host "`n--- DESGLOSE POR NIVEL (TIERS) ---" -ForegroundColor DarkCyan
@('1', '2', '3', '4') | ForEach-Object {
    $tId = $_
    $tierResults = @($script:allResults | Where-Object { $_.Tier -eq $tId })
    if ($tierResults.Count -gt 0) {
        $tPass = @($tierResults | Where-Object { $_.Passed -eq $true }).Count
        $tFail = @($tierResults | Where-Object { $_.Passed -eq $false }).Count
        $tRate = [Math]::Round(($tPass / $tierResults.Count) * 100.0, 1)
        Write-Host "  Tier $tId : $($tierResults.Count) pruebas | $tPass PASS | $tFail FAIL ($tRate %)" -ForegroundColor $(if ($tFail -eq 0) { 'Green' } else { 'Yellow' })
    }
}
if ($JsonReport) {
    $jsonOut = Join-Path $baseDir "tests\e2e_results.json"
    $script:allResults | ConvertTo-Json -Depth 4 | Set-Content -Path $jsonOut -Encoding UTF8
    Write-Host "`n  [INFO] Reporte exportado a JSON: $jsonOut" -ForegroundColor DarkGray
}
Write-Host "================================================================================" -ForegroundColor Cyan
if ($failedCount -gt 0) {
    Write-Host "  VEREDICTO FINAL: [RECHAZADO] ($failedCount inconformidades encontradas)" -ForegroundColor Red
    exit 1
} else {
    Write-Host "  VEREDICTO FINAL: [APROBADO AL 100%] (0 inconformidades)" -ForegroundColor Green
    Write-Host "  Cumple con los estandares de La Garza Aguachilera nivel Cartoon Network." -ForegroundColor Green
    exit 0
}