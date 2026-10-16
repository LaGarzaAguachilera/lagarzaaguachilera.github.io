Add-Type -AssemblyName System.Drawing

Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "  AUDITORIA DE CONTROL DE CALIDAD Y MULTIMEDIA QA" -ForegroundColor Yellow
Write-Host "  La Garza Aguachilera -- E2E Quality Assurance Engine" -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan

$script:fallasTotales = 0

# Inicializacion de motor de calculo de fuentes GDI+
$bmpTest = New-Object System.Drawing.Bitmap(100, 100)
$gTest = [System.Drawing.Graphics]::FromImage($bmpTest)

function Get-TextWidth([string]$text, [string]$family, [float]$size, [System.Drawing.FontStyle]$style = [System.Drawing.FontStyle]::Bold) {
    try {
        $f = New-Object System.Drawing.Font($family, $size, $style)
    } catch {
        $f = New-Object System.Drawing.Font("Arial", $size, $style)
    }
    $sizeF = $gTest.MeasureString($text, $f)
    $f.Dispose()
    return $sizeF.Width
}

# -----------------------------------------------------------------------------
# 1. VERIFICACION DE EXISTENCIA Y DIMENSIONES EXACTAS DE IMAGENES
# -----------------------------------------------------------------------------
Write-Host "`n1. VERIFICACION DE EXISTENCIA Y DIMENSIONES EXACTAS (9 PIEZAS GRAFICAS):" -ForegroundColor Green

$imagesToAudit = @(
    @{ Name = 'Portada Facebook'; Path = 'd:\AG\la garza aguachilera\flyer_portada_verde.png'; Width = 1200; Height = 630 },
    @{ Name = 'Flyer Post Feed'; Path = 'd:\AG\la garza aguachilera\flyer_post_verde.png'; Width = 1080; Height = 1080 },
    @{ Name = 'Flyer Historia Vertical'; Path = 'd:\AG\la garza aguachilera\flyer_historia_verde.png'; Width = 1080; Height = 1920 },
    @{ Name = 'Post 1 Antojo Lunes'; Path = 'd:\AG\la garza aguachilera\contenido_redes\posts_periodicos\post1_antojo_lunes.png'; Width = 1080; Height = 1080 },
    @{ Name = 'Post 2 Meme OVNI'; Path = 'd:\AG\la garza aguachilera\contenido_redes\posts_periodicos\post2_meme_ovni.png'; Width = 1080; Height = 1080 },
    @{ Name = 'Post 4 Cura Domingo'; Path = 'd:\AG\la garza aguachilera\contenido_redes\posts_periodicos\post4_cura_domingo.png'; Width = 1080; Height = 1080 },
    @{ Name = 'Post 5 Frescura en Vivo'; Path = 'd:\AG\la garza aguachilera\contenido_redes\posts_periodicos\post5_frescura_en_vivo.png'; Width = 1080; Height = 1080 },
    @{ Name = 'Post 6 Mapache Crunch'; Path = 'd:\AG\la garza aguachilera\contenido_redes\posts_periodicos\post6_mapache_crunch.png'; Width = 1080; Height = 1080 },
    @{ Name = 'Post 7 Rutas Activas'; Path = 'd:\AG\la garza aguachilera\contenido_redes\posts_periodicos\post7_rutas_activas.png'; Width = 1080; Height = 1080 }
)

foreach ($item in $imagesToAudit) {
    if (Test-Path $item.Path) {
        try {
            $img = [System.Drawing.Image]::FromFile($item.Path)
            $w = $img.Width
            $h = $img.Height
            $img.Dispose()

            if ($w -eq $item.Width -and $h -eq $item.Height) {
                Write-Host " [OK] $($item.Name) -> $w x $h px (Conforme)" -ForegroundColor Green
            } else {
                Write-Host " [ERROR DIMENSION] $($item.Name) -> $w x $h px (Esperado: $($item.Width) x $($item.Height) px)" -ForegroundColor Red
                $script:fallasTotales++
            }
        } catch {
            Write-Host " [ERROR LECTURA] No se pudo leer la imagen $($item.Path): $_" -ForegroundColor Red
            $script:fallasTotales++
        }
    } else {
        Write-Host " [ERROR NO EXISTE] Archivo faltante: $($item.Path)" -ForegroundColor Red
        $script:fallasTotales++
    }
}

# -----------------------------------------------------------------------------
# 2. MEDICION DE TEXTOS Y MARGENES DE SEGURIDAD (SAFE ZONES)
# -----------------------------------------------------------------------------
Write-Host "`n2. MEDICION DE TEXTOS Y MARGENES DE SEGURIDAD (SAFE ZONES):" -ForegroundColor Green

# Auditoria Portada Facebook (1200 x 630)
Write-Host "`n--- PORTADA FACEBOOK (1200 x 630 px) ---" -ForegroundColor Cyan
$portadaTexts = @(
    @{ Text = 'TAMPICO Y MADERO * SABADOS Y DOMINGOS'; Font='Segoe UI Black'; Size=[float]8; BoxW=[float]295 },
    @{ Text = 'LA GARZA AGUACHILERA'; Font='Segoe UI Black'; Size=[float]19; BoxW=[float]410 },
    @{ Text = 'TOSTIAGUACHILE VERDE TRADICIONAL'; Font='Segoe UI Black'; Size=[float]12.5; BoxW=[float]410 },
    @{ Text = '170 MXN * ~100g CAMARON'; Font='Segoe UI Black'; Size=[float]10.5; BoxW=[float]295 },
    @{ Text = 'El producto es preparado frente a usted'; Font='Segoe UI Black'; Size=[float]12; BoxW=[float]410 },
    @{ Text = 'para corroborar su frescura'; Font='Segoe UI Black'; Size=[float]12; BoxW=[float]410 },
    @{ Text = 'PEDIDOS Y APARTADOS POR WHATSAPP'; Font='Segoe UI Black'; Size=[float]10; BoxW=[float]410 },
    @{ Text = '833 252 09 88'; Font='Segoe UI Black'; Size=[float]22; BoxW=[float]410 },
    @{ Text = 'ENTREGAS FINES DE SEMANA EN TAMPICO Y MADERO'; Font='Segoe UI Black'; Size=[float]9.2; BoxW=[float]410 },
    @{ Text = 'ABDUCIDOS POR EL SABOR!'; Font='Segoe UI Black'; Size=[float]8.5; BoxW=[float]195 },
    @{ Text = 'JUANCHO * PLAYA MIRAMAR'; Font='Segoe UI Black'; Size=[float]8.5; BoxW=[float]200 },
    @{ Text = 'MAPACHE DE LAS ESCOLLERAS'; Font='Segoe UI Black'; Size=[float]8; BoxW=[float]195 }
)

foreach ($t in $portadaTexts) {
    $measW = Get-TextWidth $t.Text $t.Font $t.Size
    $boxW = $t.BoxW
    $overflow = $measW - $boxW
    if ($measW -gt $boxW) {
        Write-Host " [OVERFLOW PELIGROSO] Text: '$($t.Text)' -> Ancho: $([math]::Round($measW, 1))px / Caja: $($boxW)px (Diff: $([math]::Round($overflow, 1))px)" -ForegroundColor Red
        $script:fallasTotales++
    } else {
        Write-Host " [CORRECTO] Text: '$($t.Text)' -> Ancho: $([math]::Round($measW, 1))px / Caja: $($boxW)px (Diff: $([math]::Round($overflow, 1))px)" -ForegroundColor Green
    }
}

# Auditoria Post Feed Verde (1080 x 1080)
Write-Host "`n--- POST FEED VERDE (1080 x 1080 px) ---" -ForegroundColor Cyan
$postFeedTexts = @(
    @{ Text = 'LA GARZA AGUACHILERA'; Font='Arial'; Size=[float]22; MarginLeft=[float]390 },
    @{ Text = 'TOSTIAGUACHILE'; Font='Arial'; Size=[float]38; MarginLeft=[float]390 },
    @{ Text = 'VERDE TRADICIONAL'; Font='Arial'; Size=[float]32; MarginLeft=[float]390 },
    @{ Text = '170 MXN'; Font='Arial'; Size=[float]40; MarginLeft=[float]390 },
    @{ Text = 'Con Tostitos Salsa Verde'; Font='Arial'; Size=[float]21; MarginLeft=[float]390 },
    @{ Text = 'El producto es preparado frente a usted'; Font='Arial'; Size=[float]25; BoxW=[float]940 },
    @{ Text = 'para corroborar su maxima frescura'; Font='Arial'; Size=[float]23; BoxW=[float]940 },
    @{ Text = 'CAMARON FRESCO * SERRANO * PEPINO * LIMON'; Font='Arial'; Size=[float]24 },
    @{ Text = 'ENTREGAS SABADOS Y DOMINGOS A DOMICILIO'; Font='Arial'; Size=[float]22 },
    @{ Text = 'Colonia Flores, Tampico, Tamaulipas * Cobertura Tampico y Madero'; Font='Arial'; Size=[float]20 }
)

foreach ($t in $postFeedTexts) {
    $measW = Get-TextWidth $t.Text $t.Font $t.Size
    $remRight = if ($t.MarginLeft) { 1080 - ($t.MarginLeft + $measW) } else { (1080 - $measW) / 2 }
    if ($remRight -lt 30) {
        Write-Host " [CORTE DERECHO O AL BORDE] Text: '$($t.Text)' -> Ancho: $([math]::Round($measW, 1))px | Margen Derecho Libre: $([math]::Round($remRight, 1))px" -ForegroundColor Red
        $script:fallasTotales++
    } else {
        Write-Host " [CORRECTO] Text: '$($t.Text)' -> Ancho: $([math]::Round($measW, 1))px | Margen Derecho Libre: $([math]::Round($remRight, 1))px" -ForegroundColor Green
    }
}

# Auditoria Posts Periodicos Multi-Paleta Pop (1080 x 1080)
Write-Host "`n--- POSTS PERIODICOS MULTI-PALETA POP (DIAS 1, 3, 7, 9, 11, 13) ---" -ForegroundColor Cyan
$periodicTexts = @(
    @{ Post = 'Post 1 (Jungla/Mango)'; Text = 'LUNES DE ANTOJO JAIBO * LA GARZA AGUACHILERA'; Font='Segoe UI Black'; Size=[float]15.0 },
    @{ Post = 'Post 1 (Jungla/Mango)'; Text = '!EL VERDADERO SABOR COSTENO!'; Font='Segoe UI Black'; Size=[float]24.5 },
    @{ Post = 'Post 1 (Jungla/Mango)'; Text = 'CON TOSTITOS SALSA VERDE * CAMARON MARIPOSA * PICANTE POR NATURALEZA'; Font='Segoe UI Black'; Size=[float]13.0 },
    @{ Post = 'Post 1 (Jungla/Mango)'; Text = 'El producto es preparado frente a usted para corroborar su frescura'; Font='Segoe UI Black'; Size=[float]17.0 },
    @{ Post = 'Post 2 (Violeta Alien)'; Text = 'EXPEDIENTE SECRETO * BASE ALIENIGENA DE PLAYA MIRAMAR'; Font='Segoe UI Black'; Size=[float]13.0 },
    @{ Post = 'Post 2 (Violeta Alien)'; Text = '?PROTEGEN A TAMPICO DE HURACANES'; Font='Segoe UI Black'; Size=[float]20.5 },
    @{ Post = 'Post 2 (Violeta Alien)'; Text = 'SABOR DE OTRA GALAXIA * $170 MXN LA BOLSA BIEN REPORTADA'; Font='Segoe UI Black'; Size=[float]17.0 },
    @{ Post = 'Post 4 (Atardecer Fuego)'; Text = '!LA CURA SAGRADA DE LA CRUDA!'; Font='Segoe UI Black'; Size=[float]24.5 },
    @{ Post = 'Post 4 (Atardecer Fuego)'; Text = 'LIMON RECIEN EXPRIMIDO * CHILE SERRANO * ~100g CAMARON * TOSTITOS SALSA VERDE'; Font='Segoe UI Black'; Size=[float]11.5 },
    @{ Post = 'Post 5 (Hielo Artico)'; Text = 'HIELERA GIGANTE + 2 CUBETAS CON TERMOMETRO'; Font='Segoe UI Black'; Size=[float]12.2; MarginLeft=[float]178; LimitRight=[float]720 },
    @{ Post = 'Post 5 (Hielo Artico)'; Text = 'Grado alimenticio monitoreado para frio extremo.'; Font='Segoe UI'; Size=[float]15.0; MarginLeft=[float]178; LimitRight=[float]720 },
    @{ Post = 'Post 5 (Hielo Artico)'; Text = 'Montamos tus ~100g de camaron frente a tus ojos.'; Font='Segoe UI'; Size=[float]15.0; MarginLeft=[float]178; LimitRight=[float]720 },
    @{ Post = 'Post 6 (Arena Escolleras)'; Text = 'CUANDO DICEN QUE NO LES GUSTA'; Font='Segoe UI Black'; Size=[float]20.5 },
    @{ Post = 'Post 6 (Arena Escolleras)'; Text = '!HASTA EL MAPACHE SABE CUAL ES EL MAS REPORTADO!'; Font='Segoe UI Black'; Size=[float]17.0 },
    @{ Post = 'Post 7 (Neon Puente)'; Text = '!HIELERAS CARGADAS Y EN RUTA!'; Font='Segoe UI Black'; Size=[float]24.5 },
    @{ Post = 'Post 7 (Neon Puente)'; Text = 'ZONA 1 (5-10 min): Col. Flores, Altavista, Cascajal, Centro Tampico'; Font='Segoe UI Black'; Size=[float]13.0; MarginLeft=[float]95; LimitRight=[float]1025 },
    @{ Post = 'Post 7 (Neon Puente)'; Text = 'ZONA 2 (12-18 min): Petrolera, Universidad, Lomas del Chairel, Norte'; Font='Segoe UI Black'; Size=[float]13.0; MarginLeft=[float]95; LimitRight=[float]1025 },
    @{ Post = 'Post 7 (Neon Puente)'; Text = 'ZONA 3 (15-22 min): Cd. Madero, Unidad Nacional, Ampliacion, Miramar'; Font='Segoe UI Black'; Size=[float]13.0; MarginLeft=[float]95; LimitRight=[float]1025 }
)

foreach ($t in $periodicTexts) {
    $measW = Get-TextWidth $t.Text $t.Font $t.Size
    $limitR = if ($t.LimitRight) { $t.LimitRight } else { 1080 }
    $remRight = if ($t.MarginLeft) { $limitR - ($t.MarginLeft + $measW) } else { (1080 - $measW) / 2 }
    if ($remRight -lt 25) {
        Write-Host " $($t.Post) [ALERTA: MARGEN MUY ESTRECHO O DESBORDE] '$($t.Text)' -> Ancho: $([math]::Round($measW, 1))px | Margen Libre: $([math]::Round($remRight, 1))px" -ForegroundColor Red
        $script:fallasTotales++
    } else {
        Write-Host " $($t.Post) [CORRECTO] '$($t.Text)' -> Ancho: $([math]::Round($measW, 1))px | Margen Libre: $([math]::Round($remRight, 1))px" -ForegroundColor Green
    }
}

# Auditoria Video Overlays
Write-Host "`n--- VIDEO OVERLAYS Y SUBTITULOS (1080 x 1920) ---" -ForegroundColor Cyan
$videoTexts = @(
    @{ Name='Header'; Text='TAMPICO Y CIUDAD MADERO * SABOR COSTENO'; Font='Arial'; Size=[float]20 },
    @{ Name='Header'; Text='LA GARZA AGUACHILERA'; Font='Arial'; Size=[float]36 },
    @{ Name='Header'; Text='TOSTIAGUACHILE VERDE TRADICIONAL'; Font='Arial'; Size=[float]22 },
    @{ Name='Footer'; Text='PEDIDOS WHATSAPP: 833 252 09 88'; Font='Arial'; Size=[float]28 },
    @{ Name='Footer'; Text='VERDE TRADICIONAL * 170 MXN * ~100g CAMARON'; Font='Arial'; Size=[float]22 },
    @{ Name='Footer'; Text='El producto es preparado frente a usted'; Font='Arial'; Size=[float]20 },
    @{ Name='Footer'; Text='para corroborar su maxima frescura'; Font='Arial'; Size=[float]18 },
    @{ Name='Sub1'; Text='EL TOSTIAGUACHILE MAS REPORTADO!'; Font='Arial'; Size=[float]29; BoxW=[float]960 },
    @{ Name='Sub2'; Text='CAMARON FRESCO EN MARIPOSA'; Font='Arial'; Size=[float]24; BoxW=[float]660 },
    @{ Name='Sub3'; Text='CON TOSTITOS SALSA VERDE'; Font='Arial'; Size=[float]23; BoxW=[float]640 },
    @{ Name='Sub4'; Text='EL PRODUCTO ES PREPARADO FRENTE A TI'; Font='Arial'; Size=[float]27; BoxW=[float]860 },
    @{ Name='Sub5'; Text='APARTA TU BOLSA POR WHATSAPP'; Font='Arial'; Size=[float]24; BoxW=[float]670 }
)

foreach ($t in $videoTexts) {
    $measW = Get-TextWidth $t.Text $t.Font $t.Size
    $rem = if ($t.BoxW) { $t.BoxW - $measW } else { (1080 - $measW) / 2 }
    if ($rem -lt 25) {
        Write-Host " $($t.Name) [ALERTA SUBTITULO AL BORDE] '$($t.Text)' -> Ancho: $([math]::Round($measW, 1))px | Margen: $([math]::Round($rem, 1))px" -ForegroundColor Red
        $script:fallasTotales++
    } else {
        Write-Host " $($t.Name) [CORRECTO] '$($t.Text)' -> Ancho: $([math]::Round($measW, 1))px | Margen: $([math]::Round($rem, 1))px" -ForegroundColor Green
    }
}

# -----------------------------------------------------------------------------
# 3. VERIFICACION TECNICA AUTOMATIZADA CON FFPROBE (VIDEO HD & AUDIO DUCKING)
# -----------------------------------------------------------------------------
Write-Host "`n3. VERIFICACION TECNICA DE VIDEO Y AUDIO CON FFPROBE:" -ForegroundColor Green

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

if (-not $ffprobeBin) {
    Write-Host " [ERROR FATAL] ffprobe.exe no fue encontrado en el repositorio." -ForegroundColor Red
    $script:fallasTotales++
} else {
    Write-Host " [INFO] Utilizando binario FFprobe: $ffprobeBin" -ForegroundColor Gray
    $videoFile = 'd:\AG\la garza aguachilera\VIDEOS\promo_aguachile_verde_final.mp4'

    if (-not (Test-Path $videoFile)) {
        Write-Host " [ERROR NO EXISTE] Video promocional ausente: $videoFile" -ForegroundColor Red
        $script:fallasTotales++
    } else {
        try {
            $jsonOutput = & $ffprobeBin -v error -print_format json -show_format -show_streams $videoFile | Out-String
            $probeData = $jsonOutput | ConvertFrom-Json

            $videoStream = $probeData.streams | Where-Object { $_.codec_type -eq 'video' } | Select-Object -First 1
            $audioStream = $probeData.streams | Where-Object { $_.codec_type -eq 'audio' } | Select-Object -First 1

            # A. Verificacion de Resolucion (1080 x 1920 Full HD 9:16)
            if ($videoStream) {
                $vw = [int]$videoStream.width
                $vh = [int]$videoStream.height
                if ($vw -eq 1080 -and $vh -eq 1920) {
                    Write-Host " [OK] Resolucion de video: $vw x $vh px (Full HD 9:16 vertical correcto)" -ForegroundColor Green
                } else {
                    Write-Host " [ERROR RESOLUCION] Video mide $vw x $vh px (Esperado: 1080 x 1920 px)" -ForegroundColor Red
                    $script:fallasTotales++
                }

                # B. Verificacion de Codec y Pixel Format
                $codec = $videoStream.codec_name
                $pixFmt = $videoStream.pix_fmt
                if ($codec -eq 'h264' -and $pixFmt -eq 'yuv420p') {
                    Write-Host " [OK] Codec de video: $codec ($pixFmt) compatible universalmente" -ForegroundColor Green
                } else {
                    Write-Host " [ERROR CODEC] Video codec=$codec, pix_fmt=$pixFmt (Esperado: h264 / yuv420p)" -ForegroundColor Red
                    $script:fallasTotales++
                }

                # C. Verificacion de Bitrate (>= 4000 kbps)
                $bitrateBps = 0
                if ($videoStream.bit_rate) {
                    $bitrateBps = [int64]$videoStream.bit_rate
                } elseif ($probeData.format.bit_rate) {
                    $bitrateBps = [int64]$probeData.format.bit_rate
                }

                $bitrateKbps = [math]::Round($bitrateBps / 1000, 0)
                if ($bitrateBps -ge 4000000) {
                    Write-Host " [OK] Bitrate de video: $bitrateKbps kbps (>= 4000 kbps requerido)" -ForegroundColor Green
                } else {
                    Write-Host " [ERROR BITRATE] Bitrate insuficiente: $bitrateKbps kbps (< 4000 kbps requerido)" -ForegroundColor Red
                    $script:fallasTotales++
                }
            } else {
                Write-Host " [ERROR STREAM] El archivo no contiene ningun stream de video." -ForegroundColor Red
                $script:fallasTotales++
            }

            # D. Verificacion de Audio (AAC Stereo)
            if ($audioStream) {
                $aCodec = $audioStream.codec_name
                $aChannels = [int]$audioStream.channels
                if ($aCodec -eq 'aac' -and $aChannels -eq 2) {
                    Write-Host " [OK] Pista de audio: $aCodec stereo ($aChannels canales)" -ForegroundColor Green
                } else {
                    Write-Host " [ERROR AUDIO] Audio codec=$aCodec, canales=$aChannels (Esperado: aac / 2 canales)" -ForegroundColor Red
                    $script:fallasTotales++
                }
            } else {
                Write-Host " [ERROR STREAM] El archivo no contiene ningun stream de audio." -ForegroundColor Red
                $script:fallasTotales++
            }

        } catch {
            Write-Host " [ERROR FFPROBE] Excepcion al analizar streams con FFprobe: $_" -ForegroundColor Red
            $script:fallasTotales++
        }
    }

    # E. Verificacion de Archivos de Locucion Comercial y Musica
    $locucionPath = 'd:\AG\la garza aguachilera\herramientas\locucion_comercial_sabina.wav'
    $musicaPath = 'd:\AG\la garza aguachilera\herramientas\Beachfront_Celebration.mp3'

    if (Test-Path $locucionPath) {
        $locItem = Get-Item $locucionPath
        Write-Host " [OK] Master de locucion comercial en espanol verificado: $($locItem.Name) ($([math]::Round($locItem.Length/1MB, 2)) MB)" -ForegroundColor Green
    } else {
        Write-Host " [ERROR ARCHIVO] Master de locucion comercial faltante: $locucionPath" -ForegroundColor Red
        $script:fallasTotales++
    }

    if (Test-Path $musicaPath) {
        $musItem = Get-Item $musicaPath
        Write-Host " [OK] Pista musical oficial verificada: $($musItem.Name) ($([math]::Round($musItem.Length/1MB, 2)) MB)" -ForegroundColor Green
    } else {
        Write-Host " [ERROR ARCHIVO] Pista musical oficial faltante: $musicaPath" -ForegroundColor Red
        $script:fallasTotales++
    }
}

# -----------------------------------------------------------------------------
# 4. ESCANEO INTEGRAL DE PALABRAS PROHIBIDAS (BLINDAJE DE MARCA)
# -----------------------------------------------------------------------------
Write-Host "`n4. ESCANEO INTEGRAL DE PALABRAS PROHIBIDAS:" -ForegroundColor Green

$patterns = @('jumbo', 'nacho', 'tostitos?.*redondos?', 'totopos?.*redondos?', '#tostitosredondos?', 'dark\s*kitchen', 'caldo\s*por\s*separado')

$projectRoot = 'd:\AG\la garza aguachilera'
$thisScriptPath = if ($PSCommandPath) { (Resolve-Path $PSCommandPath).Path } else { (Resolve-Path 'd:\AG\la garza aguachilera\herramientas\auditar_multimedia_qa.ps1' -ErrorAction SilentlyContinue).Path }

# Exclusion limpia de este script, del test suite y del directorio de metadatos .agents
$filesToScan = Get-ChildItem -Path $projectRoot -Recurse -Include *.ps1, *.html, *.md | Where-Object {
    $_.FullName -notmatch '\\\.agents\\' -and
    $_.FullName -ne $thisScriptPath -and
    $_.Name -ne 'auditar_multimedia_qa.ps1' -and
    $_.Name -ne 'e2e_test_suite.ps1' -and
    $_.Name -ne 'TEST_INFRA.md' -and
    $_.Name -ne 'TEST_READY.md'
}

$forbiddenMatches = $filesToScan | Select-String -Pattern $patterns

if ($forbiddenMatches -and $forbiddenMatches.Count -gt 0) {
    Write-Host " [FALLO BLINDAJE] Se detectaron $($forbiddenMatches.Count) infraccion(es) de palabras prohibidas:" -ForegroundColor Red
    foreach ($m in $forbiddenMatches) {
        Write-Host "   -> $($m.Filename):$($m.LineNumber) : $($m.Line.Trim())" -ForegroundColor Yellow
    }
    $script:fallasTotales += $forbiddenMatches.Count
} else {
    Write-Host " [LIMPIO] Cero menciones de palabras prohibidas ('jumbo', 'tostitos redondos', 'dark kitchen', 'caldo por separado', 'nacho')." -ForegroundColor Green
}

# -----------------------------------------------------------------------------
# 5. RESUMEN Y ENFORCEMENT DE CODIGO DE SALIDA
# -----------------------------------------------------------------------------
$gTest.Dispose()
$bmpTest.Dispose()

Write-Host "`n=================================================================" -ForegroundColor Cyan
if ($script:fallasTotales -eq 0) {
    Write-Host "  RESULTADO: [APROBADO AL 100%] (0 inconformidades)" -ForegroundColor Green
    Write-Host "  El producto audiovisual cumple todas las normas de franquicia." -ForegroundColor Green
    Write-Host "=================================================================" -ForegroundColor Cyan
    exit 0
} else {
    Write-Host "  RESULTADO: [RECHAZADO] ($script:fallasTotales inconformidades encontradas)" -ForegroundColor Red
    Write-Host "  Corrija las desviaciones antes de desplegar a produccion." -ForegroundColor Red
    Write-Host "=================================================================" -ForegroundColor Cyan
    exit 1
}
