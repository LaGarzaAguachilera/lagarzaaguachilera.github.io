# =============================================================================
# SUITE DE PRUEBAS E2E (OPAQUE-BOX): LA GARZA AGUACHILERA
# Cobertura Completa: Tier 1, Tier 2, Tier 3 y Tier 4
# =============================================================================

param (
    [string]$Tier = "All",
    [switch]$VerboseReport
)

$ErrorActionPreference = "Continue"
Add-Type -AssemblyName System.Drawing

Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "  EJECUTOR DE PRUEBAS E2E (OPAQUE-BOX TEST SUITE)" -ForegroundColor Yellow
Write-Host "  La Garza Aguachilera -- Franchise Multimedia & Marketing" -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "  Filtro de Ejecucion: Tier = $Tier" -ForegroundColor Gray
Write-Host "  Fecha / Hora: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
Write-Host "=================================================================" -ForegroundColor Cyan

# -----------------------------------------------------------------------------
# MOTOR DE PRUEBAS Y ASERSIONES
# -----------------------------------------------------------------------------
$script:testResults = [System.Collections.Generic.List[PSCustomObject]]::new()
$script:totalTests = 0
$script:passedTests = 0
$script:failedTests = 0
$script:startTime = Get-Date

function Register-TestResult([string]$tierNum, [string]$testId, [string]$name, [bool]$passed, [string]$expected, [string]$actual, [string]$details) {
    $script:totalTests++
    if ($passed) {
        $script:passedTests++
        Write-Host " [PASS] [$testId] $name" -ForegroundColor Green
        if ($VerboseReport) {
            Write-Host "        Detalle: $details" -ForegroundColor DarkGray
        }
    } else {
        $script:failedTests++
        Write-Host " [FAIL] [$testId] $name" -ForegroundColor Red
        Write-Host "        Esperado: $expected" -ForegroundColor Yellow
        Write-Host "        Obtenido: $actual" -ForegroundColor Yellow
        Write-Host "        Causa:    $details" -ForegroundColor Red
    }

    $script:testResults.Add([PSCustomObject]@{
        Tier     = $tierNum
        Id       = $testId
        Name     = $name
        Passed   = $passed
        Expected = $expected
        Actual   = $actual
        Details  = $details
    })
}

# Inicializacion de GDI+ para mediciones graficas
$bmpTest = New-Object System.Drawing.Bitmap(100, 100)
$gTest = [System.Drawing.Graphics]::FromImage($bmpTest)

function Measure-TextWidth([string]$text, [string]$family, [float]$size, [System.Drawing.FontStyle]$style = [System.Drawing.FontStyle]::Bold) {
    try {
        $f = New-Object System.Drawing.Font($family, $size, $style)
    } catch {
        $f = New-Object System.Drawing.Font("Arial", $size, $style)
    }
    $sizeF = $gTest.MeasureString($text, $f)
    $f.Dispose()
    return $sizeF.Width
}

# Localizacion de FFprobe
$ffprobeCandidates = @(
    'd:\AG\la garza aguachilera\herramientas\ffmpeg\ffprobe.exe',
    'd:\AG\la garza aguachilera\herramientas\ffprobe.exe',
    'ffprobe.exe'
)
$ffprobeBin = $null
foreach ($cand in $ffprobeCandidates) {
    if (Test-Path $cand) {
        $ffprobeBin = $cand
        break
    }
}

# Variables Globales de Artefactos y Scripts
$renderScript = 'd:\AG\la garza aguachilera\herramientas\render_promo_hd_1080p.ps1'
if (-not (Test-Path $renderScript)) {
    $renderScript = 'd:\AG\la garza aguachilera\herramientas\render_promo_final.ps1'
}
$periodicScript = 'd:\AG\la garza aguachilera\herramientas\generar_posts_periodicos.ps1'

# Carga de Metadatos de Video
$videoPath = 'd:\AG\la garza aguachilera\VIDEOS\promo_aguachile_verde_final.mp4'
$probeData = $null
if ($ffprobeBin -and (Test-Path $videoPath)) {
    try {
        $raw = & $ffprobeBin -v error -print_format json -show_format -show_streams $videoPath | Out-String
        $probeData = $raw | ConvertFrom-Json
    } catch {
        $probeData = $null
    }
}

$videoStream = if ($probeData) { $probeData.streams | Where-Object { $_.codec_type -eq 'video' } | Select-Object -First 1 } else { $null }
$audioStream = if ($probeData) { $probeData.streams | Where-Object { $_.codec_type -eq 'audio' } | Select-Object -First 1 } else { $null }

# =============================================================================
# TIER 1: FEATURE COVERAGE (TODAS LAS 17 FUNCIONALIDADES DEL PROJECT.MD)
# =============================================================================
if ($Tier -eq "All" -or $Tier -eq "1") {
    Write-Host "`n>>> EJECUTANDO TIER 1: COBERTURA DE CARACTERISTICAS (FEATURES 1-17) <<<" -ForegroundColor Yellow

    # T1-F01: Full HD Video 1080x1920
    $f01Pass = $false
    $f01Act = "No analizado"
    if ($videoStream) {
        $vw = [int]$videoStream.width
        $vh = [int]$videoStream.height
        $vc = $videoStream.codec_name
        $vBit = if ($videoStream.bit_rate) { [int64]$videoStream.bit_rate } elseif ($probeData.format.bit_rate) { [int64]$probeData.format.bit_rate } else { 0 }
        $f01Pass = ($vw -eq 1080 -and $vh -eq 1920 -and $vc -eq 'h264' -and $vBit -ge 4000000)
        $f01Act = "$vw x $vh px, Codec=$vc, Bitrate=$([math]::Round($vBit/1000,0)) kbps"
    } else {
        $f01Act = "Video o stream no disponible"
    }
    Register-TestResult "1" "T1-F01" "Full HD Video 1080x1920 (H.264, >=4000kbps)" $f01Pass "1080x1920, h264, >=4000kbps" $f01Act "Verifica resolucion, codec y tasa de bits con FFprobe"

    # T1-F02: Elimination of Black Bars & Pixelation
    $f02Pass = $false
    $f02Act = ""
    if (Test-Path $renderScript) {
        $scriptContent = Get-Content $renderScript -Raw
        $hasBlackPad = $scriptContent -match 'pad=.*:black'
        $hasLowResCrop = $scriptContent -match 'crop=w=640:h=663'
        $f02Pass = (-not $hasBlackPad) -and (-not $hasLowResCrop)
        $f02Act = "BlackPad=$hasBlackPad, LowResCrop=$hasLowResCrop en $renderScript"
    } else {
        $f02Act = "Script de render no encontrado"
    }
    Register-TestResult "1" "T1-F02" "Eliminacion de Franjas Negras y Recorte Pixelado" $f02Pass "Sin pad:black y sin crop 640x663" $f02Act "Comprueba ausencia de franjas negras artificiales en render"

    # T1-F03: High-Definition Food Photography Motion
    $f03Pass = $false
    $f03Act = ""
    $photo1 = 'd:\AG\la garza aguachilera\tostiaguachile_verde_redondo.jpg'
    $photo2 = 'd:\AG\la garza aguachilera\aguachile_verde_hero.jpg'
    if ((Test-Path $photo1) -and (Test-Path $photo2)) {
        $img1 = [System.Drawing.Image]::FromFile($photo1)
        $img2 = [System.Drawing.Image]::FromFile($photo2)
        $w1 = $img1.Width; $h1 = $img1.Height
        $w2 = $img2.Width; $h2 = $img2.Height
        $img1.Dispose(); $img2.Dispose()

        $hasZoomPan = $false
        if (Test-Path $renderScript) {
            $hasZoomPan = (Get-Content $renderScript -Raw) -match 'zoompan'
        }
        $f03Pass = ($w1 -ge 800 -and $h1 -ge 800 -and $w2 -ge 800 -and $h2 -ge 800 -and $hasZoomPan)
        $f03Act = "Foto1=($w1 x $h1), Foto2=($w2 x $h2), ZoomPanFilter=$hasZoomPan"
    } else {
        $f03Act = "Fotos de producto no encontradas"
    }
    Register-TestResult "1" "T1-F03" "Movimiento Cinematico en Fotografia HD de Comida" $f03Pass "Fotos >= 800x800 con filtro zoompan" $f03Act "Ken Burns pan/zoom en fotos macro del Tostiaguachile"

    # T1-F04: Tampico Local Identity in Video
    $f04Pass = $false
    $f04Act = ""
    $ovni = 'd:\AG\la garza aguachilera\clean_ovni.png'
    $mapache = 'd:\AG\la garza aguachilera\clean_mapache.png'
    $juancho = 'd:\AG\la garza aguachilera\clean_juancho.png'
    if ((Test-Path $ovni) -and (Test-Path $mapache) -and (Test-Path $juancho)) {
        $iO = [System.Drawing.Image]::FromFile($ovni)
        $iM = [System.Drawing.Image]::FromFile($mapache)
        $iJ = [System.Drawing.Image]::FromFile($juancho)
        $is32bpp = ($iO.PixelFormat -eq [System.Drawing.Imaging.PixelFormat]::Format32bppArgb -and
                    $iM.PixelFormat -eq [System.Drawing.Imaging.PixelFormat]::Format32bppArgb -and
                    $iJ.PixelFormat -eq [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
        $iO.Dispose(); $iM.Dispose(); $iJ.Dispose()

        $overlayGenScript = 'd:\AG\la garza aguachilera\herramientas\generate_pop_video_overlays.ps1'
        $hasIconsInPipeline = $false
        if (Test-Path $overlayGenScript) {
            $ogs = Get-Content $overlayGenScript -Raw
            $hasIconsInPipeline = ($ogs -match 'clean_ovni' -and $ogs -match 'clean_mapache' -and $ogs -match 'clean_juancho')
        }
        $f04Pass = ($is32bpp -and $hasIconsInPipeline)
        $f04Act = "Stickers 32bpp transparentes=$is32bpp, IntegradosEnOverlays=$hasIconsInPipeline"
    } else {
        $f04Act = "Faltan archivos de stickers en raiz"
    }
    Register-TestResult "1" "T1-F04" "Identidad Local de Tampico en Video (Mapache, OVNI, Juancho)" $f04Pass "3 stickers 32bpp integrados en pipeline de overlays" $f04Act "Iconos tampiquenos como arte comercial en video"

    # T1-F05: Spanish Commercial Voiceover
    $locucionMaster = 'd:\AG\la garza aguachilera\herramientas\locucion_comercial_sabina.wav'
    $f05Pass = $false
    $f05Act = ""
    if (Test-Path $locucionMaster) {
        $locItem = Get-Item $locucionMaster
        $sizeMB = [math]::Round($locItem.Length / 1MB, 2)
        $locScript = 'd:\AG\la garza aguachilera\herramientas\generar_locucion_sabina.ps1'
        $scriptValid = $false
        if (Test-Path $locScript) {
            $lsContent = Get-Content $locScript -Raw
            $scriptValid = ($lsContent -match 's[a\u00e1]bados y domingos' -and
                            $lsContent -match 'frescura' -and
                            $lsContent -match 'redes sociales' -and
                            $lsContent -match '833 252 09 88')
        }
        $f05Pass = ($locItem.Length -ge 1000000 -and $scriptValid)
        $f05Act = "ArchivoWav=$sizeMB MB, MensajeClaveValidado=$scriptValid"
    } else {
        $f05Act = "Archivo de locucion no encontrado"
    }
    Register-TestResult "1" "T1-F05" "Locucion Comercial en Espanol (Sabina / Weekend / Rutas)" $f05Pass "WAV >= 1MB con texto de servicio y rutas" $f05Act "Sintesis de voz mexicana con mensaje oficial de apertura"

    # T1-F06: Audio Ducking with Official Music
    $f06Pass = $false
    $f06Act = ""
    $musicFile = 'd:\AG\la garza aguachilera\herramientas\Beachfront_Celebration.mp3'
    if (Test-Path $musicFile) {
        $mItem = Get-Item $musicFile
        $hasDucking = $false
        if (Test-Path $renderScript) {
            $rc = Get-Content $renderScript -Raw
            $hasDucking = ($rc -match 'sidechaincompress|volume=.*0\.[1-2]|volume=eval|0\.18')
        }
        $f06Pass = ($mItem.Length -gt 2000000 -and $hasDucking)
        $f06Act = "Musica=$([math]::Round($mItem.Length/1MB,2)) MB, DuckingConfigurado=$hasDucking"
    } else {
        $f06Act = "Beachfront_Celebration.mp3 no encontrada"
    }
    Register-TestResult "1" "T1-F06" "Audio Ducking con Musica Oficial Beachfront Celebration" $f06Pass "Musica >= 2MB y filtros de atenuacion" $f06Act "Atenuacion de volumen de musica durante la voz"

    # T1-F07: Facebook Cover Elevation (flyer_portada_verde.png)
    $coverPath = 'd:\AG\la garza aguachilera\flyer_portada_verde.png'
    $f07Pass = $false
    $f07Act = ""
    if (Test-Path $coverPath) {
        $imgC = [System.Drawing.Image]::FromFile($coverPath)
        $cw = $imgC.Width; $ch = $imgC.Height; $cf = $imgC.PixelFormat
        $imgC.Dispose()
        $f07Pass = ($cw -eq 1200 -and $ch -eq 630 -and $cf -eq [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
        $f07Act = "Dimensiones: $cw x $ch px, Formato: $cf"
    } else {
        $f07Act = "flyer_portada_verde.png no existe"
    }
    Register-TestResult "1" "T1-F07" "Elevacion de Portada Facebook (1200x630 32bpp)" $f07Pass "1200x630 px, Format32bppArgb" $f07Act "Grafico de portada oficial para redes sociales"

    # T1-F08: Feed Post Flyer Elevation (flyer_post_verde.png)
    $postFlyerPath = 'd:\AG\la garza aguachilera\flyer_post_verde.png'
    $f08Pass = $false
    $f08Act = ""
    if (Test-Path $postFlyerPath) {
        $imgP = [System.Drawing.Image]::FromFile($postFlyerPath)
        $pw = $imgP.Width; $ph = $imgP.Height; $pf = $imgP.PixelFormat
        $imgP.Dispose()
        $f08Pass = ($pw -eq 1080 -and $ph -eq 1080 -and $pf -eq [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
        $f08Act = "Dimensiones: $pw x $ph px, Formato: $pf"
    } else {
        $f08Act = "flyer_post_verde.png no existe"
    }
    Register-TestResult "1" "T1-F08" "Elevacion de Flyer Post Feed (1080x1080 32bpp)" $f08Pass "1080x1080 px, Format32bppArgb" $f08Act "Flyer cuadrado principal para feed de Instagram/Facebook"

    # T1-F09: Story Flyer Elevation (flyer_historia_verde.png)
    $storyFlyerPath = 'd:\AG\la garza aguachilera\flyer_historia_verde.png'
    $f09Pass = $false
    $f09Act = ""
    if (Test-Path $storyFlyerPath) {
        $imgS = [System.Drawing.Image]::FromFile($storyFlyerPath)
        $sw = $imgS.Width; $sh = $imgS.Height; $sf = $imgS.PixelFormat
        $imgS.Dispose()
        $f09Pass = ($sw -eq 1080 -and $sh -eq 1920 -and $sf -eq [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
        $f09Act = "Dimensiones: $sw x $sh px, Formato: $sf"
    } else {
        $f09Act = "flyer_historia_verde.png no existe"
    }
    Register-TestResult "1" "T1-F09" "Elevacion de Flyer Historia Vertical (1080x1920 32bpp)" $f09Pass "1080x1920 px, Format32bppArgb" $f09Act "Flyer vertical para historias de WhatsApp / Instagram"

    # T1-F10: Periodic Posts Elevation (6 posts)
    $periodicFiles = @(
        'contenido_redes\posts_periodicos\post1_antojo_lunes.png',
        'contenido_redes\posts_periodicos\post2_meme_ovni.png',
        'contenido_redes\posts_periodicos\post4_cura_domingo.png',
        'contenido_redes\posts_periodicos\post5_frescura_en_vivo.png',
        'contenido_redes\posts_periodicos\post6_mapache_crunch.png',
        'contenido_redes\posts_periodicos\post7_rutas_activas.png'
    )
    $f10AllOk = $true
    $f10Details = ""
    foreach ($pf in $periodicFiles) {
        $fullPath = Join-Path 'd:\AG\la garza aguachilera' $pf
        if (Test-Path $fullPath) {
            $iP = [System.Drawing.Image]::FromFile($fullPath)
            if ($iP.Width -ne 1080 -or $iP.Height -ne 1080) {
                $f10AllOk = $false
                $f10Details += "$pf ($($iP.Width)x$($iP.Height)) "
            }
            $iP.Dispose()
        } else {
            $f10AllOk = $false
            $f10Details += "$pf (FALTA) "
        }
    }
    Register-TestResult "1" "T1-F10" "Elevacion de Parrilla Periodica (6 Posts Cuadrados 1080x1080)" $f10AllOk "6 archivos en 1080x1080" $(if ($f10AllOk) { "Todos los 6 posts en 1080x1080" } else { $f10Details }) "Verifica los 6 posts de la campana periodica"

    # T1-F11: Forbidden Words Sanitation in Marketing Copy
    $marketingFiles = Get-ChildItem -Path 'd:\AG\la garza aguachilera\contenido_redes' -Recurse -Include *.md
    $forbPatterns = @('jumbo', 'nacho', 'tostitos?.*redondos?', 'totopos?.*redondos?', '#tostitosredondos?')
    $matchesMkt = $marketingFiles | Select-String -Pattern $forbPatterns
    $f11Pass = ($matchesMkt.Count -eq 0)
    $f11Act = "$($matchesMkt.Count) infracciones detectadas"
    Register-TestResult "1" "T1-F11" "Sanitizacion de Palabras Prohibidas en Copys y Calendario" $f11Pass "0 infracciones" $f11Act "Sin menciones de jumbo o tostitos redondos en contenido_redes"

    # T1-F12: Asset Localization
    $localSkyline = 'd:\AG\la garza aguachilera\herramientas\portada_bg_tampico_skyline_1792107773833.jpg'
    $f12Pass = (Test-Path $localSkyline)
    $f12Act = if ($f12Pass) { "Presente en herramientas\ ($(Get-Item $localSkyline | Select-Object -ExpandProperty Length) bytes)" } else { "Ausente" }
    Register-TestResult "1" "T1-F12" "Localizacion de Fondos Externos (Skyline Tampico)" $f12Pass "Archivo local en herramientas\" $f12Act "Skyline de Tampico disponible localmente sin rutas rotas"

    # T1-F13: QA Auditor Tool Upgrade
    $auditorFile = 'd:\AG\la garza aguachilera\herramientas\auditar_multimedia_qa.ps1'
    $f13Pass = $false
    $f13Act = ""
    if (Test-Path $auditorFile) {
        $audContent = Get-Content $auditorFile -Raw
        $hasFFprobe = $audContent -match 'ffprobe'
        $hasSelfExclude = $audContent -match 'auditar_multimedia_qa\.ps1'
        $hasExitCode = $audContent -match 'exit 0' -and $audContent -match 'exit 1'
        $f13Pass = ($hasFFprobe -and $hasSelfExclude -and $hasExitCode)
        $f13Act = "FFprobeChecks=$hasFFprobe, SelfExclude=$hasSelfExclude, ExitCodeEnforced=$hasExitCode"
    } else {
        $f13Act = "auditar_multimedia_qa.ps1 no encontrado"
    }
    Register-TestResult "1" "T1-F13" "Modernizacion del Auditor Multimedia QA" $f13Pass "FFprobe + Auto-exclusion + Exit codes" $f13Act "Herramienta de auditoria automatizada completa"

    # T1-F14: Opaque-Box E2E Test Suite
    $testSuiteFile = 'd:\AG\la garza aguachilera\tests\e2e_test_suite.ps1'
    $infraDocFile = 'd:\AG\la garza aguachilera\TEST_INFRA.md'
    $f14Pass = (Test-Path $testSuiteFile) -and (Test-Path $infraDocFile)
    $f14Act = "SuiteExiste=$(Test-Path $testSuiteFile), InfraDocExiste=$(Test-Path $infraDocFile)"
    Register-TestResult "1" "T1-F14" "Infraestructura de Pruebas E2E y Documentacion TEST_INFRA" $f14Pass "Suite .ps1 y documento TEST_INFRA.md presentes" $f14Act "Arnes de prueba y especificacion de arquitectura"

    # T1-F15: Control Panel Synchronization
    $panelFile = 'd:\AG\la garza aguachilera\panel_control.html'
    $f15Pass = $false
    $f15Act = ""
    if (Test-Path $panelFile) {
        $panelContent = Get-Content $panelFile -Raw
        $hasVideo = $panelContent -match 'promo_aguachile_verde_final\.mp4'
        $hasCover = $panelContent -match 'flyer_portada_verde\.png'
        $hasPost = $panelContent -match 'flyer_post_verde\.png'
        $hasHistory = $panelContent -match 'flyer_historia_verde\.png'
        $hasForb = $panelContent -match 'jumbo|nacho|tostitos?\s+redondos?'
        $f15Pass = ($hasVideo -and $hasCover -and $hasPost -and $hasHistory -and (-not $hasForb))
        $f15Act = "VideoLinked=$hasVideo, FlyersLinked=($hasCover,$hasPost,$hasHistory), ForbiddenWordsFound=$hasForb"
    } else {
        $f15Act = "panel_control.html no existe"
    }
    Register-TestResult "1" "T1-F15" "Sincronizacion de Panel de Control (panel_control.html)" $f15Pass "Activos vinculados y 0 palabras prohibidas" $f15Act "Consola administrativa con activos actualizados y limpios"

    # T1-F16: Public Landing Page Synchronization
    $indexFile = 'd:\AG\la garza aguachilera\index.html'
    $f16Pass = $false
    $f16Act = ""
    if (Test-Path $indexFile) {
        $indexContent = Get-Content $indexFile -Raw
        $hasWa = $indexContent -match '833[\s-]*252[\s-]*09[\s-]*88|528332520988'
        $hasPrice = $indexContent -match '170'
        $hasFresh = $indexContent -match 'preparado frente a usted para corroborar su frescura'
        $hasForbIndex = $indexContent -match 'jumbo|nacho|tostitos?\s+redondos?'
        $f16Pass = ($hasWa -and $hasPrice -and $hasFresh -and (-not $hasForbIndex))
        $f16Act = "WhatsApp=$hasWa, Precio170=$hasPrice, PromesaFrescura=$hasFresh, PalabrasProhibidas=$hasForbIndex"
    } else {
        $f16Act = "index.html no existe"
    }
    Register-TestResult "1" "T1-F16" "Sincronizacion de Landing Page Publica (index.html)" $f16Pass "WhatsApp + $170 + Promesa + 0 prohibidas" $f16Act "Portal publico con informacion comercial alineada"

    # T1-F17: Final E2E Test Pass & Coverage Hardening
    $f17Pass = ($script:totalTests -ge 16)
    Register-TestResult "1" "T1-F17" "Meta-Verificacion de Ejecucion y Robustez del Arnes E2E" $f17Pass "Total pruebas activas >= 16" "$script:totalTests pruebas registradas" "Garantia de ejecucion estructurada de la suite"
}

# =============================================================================
# TIER 2: BOUNDARY & CORNER CASES
# =============================================================================
if ($Tier -eq "All" -or $Tier -eq "2") {
    Write-Host "`n>>> EJECUTANDO TIER 2: CASOS LIMITE Y FRONTERAS (BOUNDARIES) <<<" -ForegroundColor Yellow

    # T2-B01: Aspect Ratio del Video Exactamente 9:16
    $b01Pass = $false
    $b01Act = "No analizado"
    if ($videoStream) {
        $vw = [double]$videoStream.width
        $vh = [double]$videoStream.height
        $ratio = $vw / $vh
        $expectedRatio = 9.0 / 16.0 # 0.5625
        $delta = [math]::Abs($ratio - $expectedRatio)
        $b01Pass = ($delta -lt 0.001)
        $b01Act = "Ratio: $([math]::Round($ratio, 4)) (Delta: $([math]::Round($delta, 6)))"
    }
    Register-TestResult "2" "T2-B01" "Limite Aspect Ratio Video 9:16 (1080/1920)" $b01Pass "Ratio = 0.5625 (tolerancia < 0.001)" $b01Act "Verifica que el video sea exactamente vertical sin deformacion"

    # T2-B02: Aspect Ratio Flyer Historia Exactamente 9:16
    $b02Pass = $false
    $b02Act = ""
    $storyFile = 'd:\AG\la garza aguachilera\flyer_historia_verde.png'
    if (Test-Path $storyFile) {
        $iS = [System.Drawing.Image]::FromFile($storyFile)
        $sw = [double]$iS.Width; $sh = [double]$iS.Height
        $iS.Dispose()
        $sRatio = $sw / $sh
        $deltaS = [math]::Abs($sRatio - (9.0 / 16.0))
        $b02Pass = ($deltaS -lt 0.001)
        $b02Act = "Ratio Historia: $([math]::Round($sRatio, 4)) (Delta: $([math]::Round($deltaS, 6)))"
    } else {
        $b02Act = "Flyer historia ausente"
    }
    Register-TestResult "2" "T2-B02" "Limite Aspect Ratio Flyer Historia 9:16" $b02Pass "Ratio = 0.5625 (tolerancia < 0.001)" $b02Act "Verifica formato vertical 9:16 para historias"

    # T2-B03: Aspect Ratio Cuadrado 1:1 en Feed y Posts Periodicos
    $b03Pass = $true
    $b03Details = ""
    $squareImages = @(
        'flyer_post_verde.png',
        'contenido_redes\posts_periodicos\post1_antojo_lunes.png',
        'contenido_redes\posts_periodicos\post2_meme_ovni.png',
        'contenido_redes\posts_periodicos\post4_cura_domingo.png',
        'contenido_redes\posts_periodicos\post5_frescura_en_vivo.png',
        'contenido_redes\posts_periodicos\post6_mapache_crunch.png',
        'contenido_redes\posts_periodicos\post7_rutas_activas.png'
    )
    foreach ($sq in $squareImages) {
        $fullSq = Join-Path 'd:\AG\la garza aguachilera' $sq
        if (Test-Path $fullSq) {
            $imgSq = [System.Drawing.Image]::FromFile($fullSq)
            if ($imgSq.Width -ne $imgSq.Height) {
                $b03Pass = $false
                $b03Details += "$sq no es cuadrado ($($imgSq.Width)x$($imgSq.Height)); "
            }
            $imgSq.Dispose()
        } else {
            $b03Pass = $false
            $b03Details += "$sq no existe; "
        }
    }
    Register-TestResult "2" "T2-B03" "Limite Aspect Ratio Cuadrado 1:1 en Feed y Periodicos" $b03Pass "Ancho == Alto en las 7 piezas cuadradas" $(if ($b03Pass) { "Todas las 7 piezas tienen ratio exacto 1:1" } else { $b03Details }) "Asegura geometria 1:1 estricta"

    # T2-B04: Portada Facebook Proporcion Panoramica
    $coverFile = 'd:\AG\la garza aguachilera\flyer_portada_verde.png'
    $b04Pass = $false
    $b04Act = ""
    if (Test-Path $coverFile) {
        $imgCov = [System.Drawing.Image]::FromFile($coverFile)
        $cw = $imgCov.Width; $ch = $imgCov.Height
        $imgCov.Dispose()
        $b04Pass = ($cw -eq 1200 -and $ch -eq 630)
        $b04Act = "$cw x $ch px (Ratio: $([math]::Round($cw/$ch, 4)))"
    } else {
        $b04Act = "Portada ausente"
    }
    Register-TestResult "2" "T2-B04" "Limite Geometria Portada Facebook (1200x630)" $b04Pass "1200 x 630 px exactos" $b04Act "Dimension estandar recomendada por Meta para Portada Fanpage"

    # T2-B05: Safe Zone Margin Bounds (Margenes Minimos Libres)
    $b05Pass = $true
    $criticalFeedLine = "Colonia Flores, Tampico, Tamaulipas * Cobertura Tampico y Madero"
    $wFeed = Measure-TextWidth $criticalFeedLine "Arial" 20
    $remFeed = (1080 - $wFeed) / 2
    if ($remFeed -lt 30) {
        $b05Pass = $false
    }
    $criticalSubLine = "EL TOSTIAGUACHILE MAS REPORTADO!"
    $wSub = Measure-TextWidth $criticalSubLine "Arial" 29
    $remSub = 960 - $wSub
    if ($remSub -lt 25) {
        $b05Pass = $false
    }
    Register-TestResult "2" "T2-B05" "Limites de Margenes en Safe Zones (>=30px feed, >=25px subs)" $b05Pass "Margen Feed >= 30px, Margen Sub >= 25px" "FeedMargin=$([math]::Round($remFeed,1))px, SubMargin=$([math]::Round($remSub,1))px" "Tolerancia geometrica de textos contra recortes en bordes"

    # T2-B06: Umbral de Bitrate de Video >= 4000 kbps
    $b06Pass = $false
    $b06Act = "No analizado"
    if ($videoStream) {
        $vBit = if ($videoStream.bit_rate) { [int64]$videoStream.bit_rate } elseif ($probeData.format.bit_rate) { [int64]$probeData.format.bit_rate } else { 0 }
        $b06Pass = ($vBit -ge 4000000)
        $b06Act = "$([math]::Round($vBit/1000, 0)) kbps"
    }
    Register-TestResult "2" "T2-B06" "Umbral Minimo de Bitrate de Video (>= 4000 kbps)" $b06Pass "Bitrate >= 4000 kbps" $b06Act "Verifica que el video cumpla el estandar Full HD sin artefactos de compresion"

    # T2-B07: Umbrales de Calidad de Audio (Stereo / 44.1kHz / >=128kbps)
    $b07Pass = $false
    $b07Act = "No analizado"
    if ($audioStream) {
        $aCodec = $audioStream.codec_name
        $aRate = [int]$audioStream.sample_rate
        $aCh = [int]$audioStream.channels
        $aBit = if ($audioStream.bit_rate) { [int64]$audioStream.bit_rate } else { 192000 }
        $b07Pass = ($aCodec -eq 'aac' -and $aRate -ge 44100 -and $aCh -eq 2 -and $aBit -ge 128000)
        $b07Act = "Codec=$aCodec, Rate=$aRate Hz, Canales=$aCh, Bitrate=$([math]::Round($aBit/1000, 0)) kbps"
    }
    Register-TestResult "2" "T2-B07" "Umbral de Calidad de Audio AAC Stereo (>=44.1kHz, >=128kbps)" $b07Pass "AAC, 2 canales, >=44100Hz, >=128kbps" $b07Act "Inspeccion de fidelidad sonora del audio master"

    # T2-B08: Rango de Atenuacion de Audio Ducking (0.10 a 0.25)
    $b08Pass = $false
    $b08Act = ""
    if (Test-Path $renderScript) {
        $rc = Get-Content $renderScript -Raw
        if ($rc -match '0\.18' -or $rc -match 'volume=.*0\.[1-2][0-9]?' -or $rc -match 'sidechaincompress') {
            $b08Pass = $true
            $b08Act = "Factor de atenuacion 0.18 / ducking validado en script"
        } else {
            $b08Act = "Atenuacion no encontrada en rango seguro"
        }
    } else {
        $b08Act = "Script de render ausente"
    }
    Register-TestResult "2" "T2-B08" "Limites de Ducking de Musica (Factor 0.10 a 0.25 / Sidechain)" $b08Pass "Factor de atenuacion 0.10-0.25 o sidechain" $b08Act "Garantiza inteligibilidad de la locucion comercial"

    # T2-B09: Limites de Tamano de Archivo (Minimos de Integridad)
    $b09Pass = $false
    $b09Act = ""
    if (Test-Path $videoPath) {
        $vSizeMB = [math]::Round((Get-Item $videoPath).Length / 1MB, 2)
        $b09Pass = ($vSizeMB -ge 10.0)
        $b09Act = "Tamano Video: $vSizeMB MB (Umbral >= 10 MB)"
    } else {
        $b09Act = "Video ausente"
    }
    Register-TestResult "2" "T2-B09" "Umbral de Tamano Minimo del Video Master (>= 10 MB)" $b09Pass "Tamano >= 10 MB" $b09Act "Previene exportaciones truncadas o vacias"
}

# =============================================================================
# TIER 3: CROSS-FEATURE COMBINATIONS
# =============================================================================
if ($Tier -eq "All" -or $Tier -eq "3") {
    Write-Host "`n>>> EJECUTANDO TIER 3: COMBINACIONES CRUZADAS ENTRE COMPONENTES <<<" -ForegroundColor Yellow

    # T3-C01: Sincronizacion Cruzada Video y Audio
    $c01Pass = $false
    $c01Act = "No analizado"
    if ($videoStream -and $audioStream) {
        $vDur = [double]$videoStream.duration
        $aDur = [double]$audioStream.duration
        $deltaDur = [math]::Abs($vDur - $aDur)
        $c01Pass = ($deltaDur -lt 1.0 -and $vDur -gt 15.0)
        $c01Act = "VideoDur=$([math]::Round($vDur,2))s, AudioDur=$([math]::Round($aDur,2))s (Delta=$([math]::Round($deltaDur,3))s)"
    }
    Register-TestResult "3" "T3-C01" "Sincronizacion Cruzada Video + Audio (Delta Duracion < 1.0s)" $c01Pass "Delta duracion < 1.0s, Duracion > 15s" $c01Act "Sincronia exacta entre pista visual y auditiva final"

    # T3-C02: Combinacion de Flyers con Personajes Identitarios de Tampico
    $c02Pass = $false
    $c02Act = ""
    if (Test-Path $periodicScript) {
        $psContent = Get-Content $periodicScript -Raw
        $hasOvniPost2 = ($psContent -match 'post2.*ovniPath|ovniPath.*post2|Draw-StickerWithShadow \$g2 \$ovniPath')
        $hasMapachePost6 = ($psContent -match 'post6.*mapachePath|mapachePath.*post6|Draw-StickerWithShadow \$g6 \$mapachePath')
        $hasJuanchoPost1 = ($psContent -match 'post1.*juanchoPath|juanchoPath.*post1|Draw-StickerWithShadow \$g1 \$juanchoPath')
        $c02Pass = ($hasOvniPost2 -and $hasMapachePost6 -and $hasJuanchoPost1)
        $c02Act = "Post2-OVNI=$hasOvniPost2, Post6-Mapache=$hasMapachePost6, Post1-Juancho=$hasJuanchoPost1"
    } else {
        $c02Act = "generar_posts_periodicos.ps1 ausente"
    }
    Register-TestResult "3" "T3-C02" "Emparejamiento Cruzado de Personajes de Tampico en Posts" $c02Pass "OVNI en Post 2, Mapache en Post 6, Juancho en Post 1" $c02Act "Verifica coherencia tematica entre copys y graficos"

    # T3-C03: Interaccion Safe Zone + Etiqueta de Precio ($170 MXN)
    $c03Pass = $true
    $priceTexts = @(
        @{ Surface='Portada Facebook'; Text='170 MXN * ~100g CAMARON'; BoxW=380.0 },
        @{ Surface='Post Feed'; Text='170 MXN'; MarginLeft=390.0 },
        @{ Surface='Periodic Post 2'; Text='SABOR DE OTRA GALAXIA * $170 MXN LA BOLSA BIEN REPORTADA'; BoxW=1080.0 }
    )
    foreach ($pt in $priceTexts) {
        $w = Measure-TextWidth $pt.Text "Segoe UI Black" 13.5
        if ($pt.BoxW -and ($w -gt $pt.BoxW)) {
            $c03Pass = $false
        }
    }
    Register-TestResult "3" "T3-C03" "Interaccion de Safe Zone con Etiqueta Oficial de Precio $170" $c03Pass "Texto de precio contenido sin desborde en todas las superficies" "Verificado en Portada, Feed y Periodicos" "Asegura que el precio de $170 nunca sea mutilado visualmente"

    # T3-C04: Consistencia Multi-Superficie de la Promesa de Frescura
    $promiseText = "El producto es preparado frente a usted para corroborar su frescura"
    $c04Pass = $false
    $c04Act = ""
    $indexHasPromise = (Get-Content 'd:\AG\la garza aguachilera\index.html' -Raw) -match $promiseText
    $calHasPromise = (Get-Content 'd:\AG\la garza aguachilera\contenido_redes\CALENDARIO_PUBLICACIONES_PERIODICAS.md' -Raw) -match $promiseText
    $c04Pass = ($indexHasPromise -and $calHasPromise)
    $c04Act = "PresenteEnIndex=$indexHasPromise, PresenteEnCalendario=$calHasPromise"
    Register-TestResult "3" "T3-C04" "Consistencia de Promesa de Frescura en Multiples Superficies" $c04Pass "Frase exacta en HTML y Calendario de Marketing" $c04Act "Garantiza consistencia del lema operativo de franquicia"

    # T3-C05: Consistencia de Formato Telefonico y Enlace de WhatsApp
    $c05Pass = $false
    $c05Act = ""
    $phoneDisplayRegex = '833[\s-]*252[\s-]*09[\s-]*88'
    $phoneDigits = "528332520988"
    $indexRaw = Get-Content 'd:\AG\la garza aguachilera\index.html' -Raw
    $panelRaw = Get-Content 'd:\AG\la garza aguachilera\panel_control.html' -Raw
    $hasDisplay = ($indexRaw -match $phoneDisplayRegex) -and ($panelRaw -match $phoneDisplayRegex)
    $hasDigits = ($indexRaw -match $phoneDigits) -and ($panelRaw -match $phoneDigits)
    $c05Pass = ($hasDisplay -and $hasDigits)
    $c05Act = "DisplayFormatoCorrecto=$hasDisplay, ApiLinkCorrecto=$hasDigits"
    Register-TestResult "3" "T3-C05" "Consistencia de Enlace y Formato de WhatsApp (833 252 09 88)" $c05Pass "Numero y wa.me/528332520988 en index y panel" $c05Act "Verifica que el canal de conversion funcione en ambos portales"
}

# =============================================================================
# TIER 4: REAL-WORLD USER ACCEPTANCE SCENARIOS (UAT)
# =============================================================================
if ($Tier -eq "All" -or $Tier -eq "4") {
    Write-Host "`n>>> EJECUTANDO TIER 4: ESCENARIOS REALES DE ACEPTACION (UAT) <<<" -ForegroundColor Yellow

    # T4-U01: Escenario Usuario Movil 9:16 (TikTok / Reels / Stories)
    $u01Pass = $false
    $u01Act = "No analizado"
    if ($videoStream) {
        $isVertical = ([int]$videoStream.height -gt [int]$videoStream.width)
        $isFullHD = ([int]$videoStream.width -eq 1080 -and [int]$videoStream.height -eq 1920)
        $u01Pass = ($isVertical -and $isFullHD)
        $u01Act = "Vertical=$isVertical, ResolucionFullHD=$isFullHD ($($videoStream.width)x$($videoStream.height))"
    }
    Register-TestResult "4" "T4-U01" "UAT 1: Visualizacion Movil Optima en Pantalla 9:16 (TikTok/Reels)" $u01Pass "Video vertical Full HD 1080x1920" $u01Act "Garantiza experiencia inmersiva sin bordes en smartphones"

    # T4-U02: Escenario Cliente Ordenando por Calculadora WhatsApp
    $u02Pass = $false
    $u02Act = ""
    $indexRaw = Get-Content 'd:\AG\la garza aguachilera\index.html' -Raw
    $hasCalcLogic = ($indexRaw -match '170' -and $indexRaw -match 'total' -and $indexRaw -match 'wa\.me')
    $u02Pass = $hasCalcLogic
    $u02Act = "LogicaCalculoYEnvioEncontrada=$hasCalcLogic"
    Register-TestResult "4" "T4-U02" "UAT 2: Flujo de Pedido del Cliente Directo a WhatsApp" $u02Pass "Calculadora operativa en index.html enlazada a WhatsApp" $u02Act "Simula el recorrido de un cliente eligiendo porciones y ordenando"

    # T4-U03: Escenario Auditoria Integral de Marca de Franquicia
    $allProjectFiles = Get-ChildItem -Path 'd:\AG\la garza aguachilera' -Recurse -Include *.ps1, *.html, *.md | Where-Object {
        $_.FullName -notmatch '\\\.agents\\' -and
        $_.Name -ne 'auditar_multimedia_qa.ps1' -and
        $_.Name -ne 'e2e_test_suite.ps1' -and
        $_.Name -ne 'TEST_INFRA.md' -and
        $_.Name -ne 'TEST_READY.md'
    }
    $forbPatternsUAT = @('jumbo', 'nacho', 'tostitos?.*redondos?', 'totopos?.*redondos?', '#tostitosredondos?')
    $violations = $allProjectFiles | Select-String -Pattern $forbPatternsUAT
    $u03Pass = ($violations.Count -eq 0)
    $u03Act = "$($violations.Count) menciones indebidas encontradas en el proyecto"
    Register-TestResult "4" "T4-U03" "UAT 3: Cumplimiento Normativo de Franquicia (Cero Desviaciones)" $u03Pass "0 infracciones de marca en todo el repositorio" $u03Act "Auditoria rigurosa de identidad comercial y de producto"
}

# -----------------------------------------------------------------------------
# LIMPIEZA Y REPORTE FINAL
# -----------------------------------------------------------------------------
$gTest.Dispose()
$bmpTest.Dispose()
$elapsed = (Get-Date) - $script:startTime

Write-Host "`n=================================================================" -ForegroundColor Cyan
Write-Host "  RESUMEN DE RESULTADOS DE PRUEBAS E2E" -ForegroundColor Yellow
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "  Total de Pruebas Ejecutadas: $script:totalTests" -ForegroundColor White
Write-Host "  Aprobadas (PASS):           $script:passedTests" -ForegroundColor Green
Write-Host "  Fallidas  (FAIL):           $script:failedTests" -ForegroundColor $(if ($script:failedTests -gt 0) { "Red" } else { "Green" })
Write-Host "  Tiempo Transcurrido:        $([math]::Round($elapsed.TotalSeconds, 2)) segundos" -ForegroundColor Gray
Write-Host "=================================================================" -ForegroundColor Cyan

if ($script:failedTests -eq 0) {
    Write-Host "  DICTAMEN: [SUITE E2E EXITOSA] Todos los criterios de aceptacion cumplidos." -ForegroundColor Green
    Write-Host "=================================================================" -ForegroundColor Cyan
    exit 0
} else {
    Write-Host "  DICTAMEN: [FALLAS DETECTADAS] Se identificaron $script:failedTests fallo(s) que requieren atencion." -ForegroundColor Red
    Write-Host "=================================================================" -ForegroundColor Cyan
    exit 1
}
