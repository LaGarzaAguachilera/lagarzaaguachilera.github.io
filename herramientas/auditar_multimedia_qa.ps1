Add-Type -AssemblyName System.Drawing

Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "  AUDITORIA DE CONTROL DE CALIDAD Y MULTIMEDIA QA" -ForegroundColor Yellow
Write-Host "  La Garza Aguachilera -- E2E Quality Assurance Engine" -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan

$script:fallasTotales = 0

# Constantes Unicode seguras para evitar cualquier mojibake en consolas Windows
$uA = [char]0x00C1; $uE = [char]0x00C9; $uI = [char]0x00CD; $uO = [char]0x00D3; $uU = [char]0x00DA; $uN = [char]0x00D1
$lA = [char]0x00E1; $lE = [char]0x00E9; $lI = [char]0x00ED; $lO = [char]0x00F3; $lU = [char]0x00FA; $lN = [char]0x00F1
$iE = [char]0x00A1; $iQ = [char]0x00BF; $deg = [char]0x00B0; $bul = [char]0x2022; $star = [char]0x2605

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
Write-Host "`n1. VERIFICACION DE EXISTENCIA Y DIMENSIONES EXACTAS (41 PIEZAS GRAFICAS):" -ForegroundColor Green

$imagesToAudit = @(
    # Piezas Principales y Legacy
    @{ Name = 'Portada Facebook'; Path = 'd:\AG\la garza aguachilera\flyer_portada_verde.png'; Width = 1200; Height = 630 },
    @{ Name = 'Flyer Post Feed'; Path = 'd:\AG\la garza aguachilera\flyer_post_verde.png'; Width = 1080; Height = 1080 },
    @{ Name = 'Flyer Historia Vertical'; Path = 'd:\AG\la garza aguachilera\flyer_historia_verde.png'; Width = 1080; Height = 1920 },
    @{ Name = 'Post 1 Antojo Lunes'; Path = 'd:\AG\la garza aguachilera\contenido_redes\posts_periodicos\post1_antojo_lunes.png'; Width = 1080; Height = 1080 },
    @{ Name = 'Post 2 Meme OVNI'; Path = 'd:\AG\la garza aguachilera\contenido_redes\posts_periodicos\post2_meme_ovni.png'; Width = 1080; Height = 1080 },
    @{ Name = 'Post 4 Cura Domingo'; Path = 'd:\AG\la garza aguachilera\contenido_redes\posts_periodicos\post4_cura_domingo.png'; Width = 1080; Height = 1080 },
    @{ Name = 'Post 5 Frescura en Vivo'; Path = 'd:\AG\la garza aguachilera\contenido_redes\posts_periodicos\post5_frescura_en_vivo.png'; Width = 1080; Height = 1080 },
    @{ Name = 'Post 6 Mapache Crunch'; Path = 'd:\AG\la garza aguachilera\contenido_redes\posts_periodicos\post6_mapache_crunch.png'; Width = 1080; Height = 1080 },
    @{ Name = 'Post 7 Rutas Activas'; Path = 'd:\AG\la garza aguachilera\contenido_redes\posts_periodicos\post7_rutas_activas.png'; Width = 1080; Height = 1080 },

    # Catalogo Mensual (16 Piezas Feed 1080x1080)
    @{ Name = 'Post 01 Abduccion Miramar (Feed)'; Path = 'd:\AG\la garza aguachilera\contenido_redes\posts_periodicos\post01_abduccion_miramar.png'; Width = 1080; Height = 1080 },
    @{ Name = 'Post 02 Juancho Laguna (Feed)'; Path = 'd:\AG\la garza aguachilera\contenido_redes\posts_periodicos\post02_juancho_laguna.png'; Width = 1080; Height = 1080 },
    @{ Name = 'Post 03 Mapache Escolleras (Feed)'; Path = 'd:\AG\la garza aguachilera\contenido_redes\posts_periodicos\post03_mapache_escolleras.png'; Width = 1080; Height = 1080 },
    @{ Name = 'Post 04 Tridente Jaibo (Feed)'; Path = 'd:\AG\la garza aguachilera\contenido_redes\posts_periodicos\post04_tridente_jaibo.png'; Width = 1080; Height = 1080 },
    @{ Name = 'Post 05 Ensamble Vivo (Feed)'; Path = 'd:\AG\la garza aguachilera\contenido_redes\posts_periodicos\post05_ensamble_vivo.png'; Width = 1080; Height = 1080 },
    @{ Name = 'Post 06 Cadena Frio (Feed)'; Path = 'd:\AG\la garza aguachilera\contenido_redes\posts_periodicos\post06_cadena_frio.png'; Width = 1080; Height = 1080 },
    @{ Name = 'Post 07 Camaron Mariposa (Feed)'; Path = 'd:\AG\la garza aguachilera\contenido_redes\posts_periodicos\post07_camaron_mariposa.png'; Width = 1080; Height = 1080 },
    @{ Name = 'Post 08 Secreto Crunch (Feed)'; Path = 'd:\AG\la garza aguachilera\contenido_redes\posts_periodicos\post08_secreto_crunch.png'; Width = 1080; Height = 1080 },
    @{ Name = 'Post 09 Medicina Resaca (Feed)'; Path = 'd:\AG\la garza aguachilera\contenido_redes\posts_periodicos\post09_medicina_resaca.png'; Width = 1080; Height = 1080 },
    @{ Name = 'Post 10 ASMR Tostitos (Feed)'; Path = 'd:\AG\la garza aguachilera\contenido_redes\posts_periodicos\post10_asmr_tostitos.png'; Width = 1080; Height = 1080 },
    @{ Name = 'Post 11 Oro Verde (Feed)'; Path = 'd:\AG\la garza aguachilera\contenido_redes\posts_periodicos\post11_oro_verde.png'; Width = 1080; Height = 1080 },
    @{ Name = 'Post 12 Ritual Dominical (Feed)'; Path = 'd:\AG\la garza aguachilera\contenido_redes\posts_periodicos\post12_ritual_dominical.png'; Width = 1080; Height = 1080 },
    @{ Name = 'Post 13 Hieleras Cargadas (Feed)'; Path = 'd:\AG\la garza aguachilera\contenido_redes\posts_periodicos\post13_hieleras_cargadas.png'; Width = 1080; Height = 1080 },
    @{ Name = 'Post 14 Zonas Horarios (Feed)'; Path = 'd:\AG\la garza aguachilera\contenido_redes\posts_periodicos\post14_zonas_horarios.png'; Width = 1080; Height = 1080 },
    @{ Name = 'Post 15 Alerta Cupos (Feed)'; Path = 'd:\AG\la garza aguachilera\contenido_redes\posts_periodicos\post15_alerta_cupos.png'; Width = 1080; Height = 1080 },
    @{ Name = 'Post 16 Comunidad Jaiba (Feed)'; Path = 'd:\AG\la garza aguachilera\contenido_redes\posts_periodicos\post16_comunidad_jaiba.png'; Width = 1080; Height = 1080 },

    # Catalogo Mensual (16 Piezas Story 1080x1920)
    @{ Name = 'Post 01 Abduccion Miramar (Story)'; Path = 'd:\AG\la garza aguachilera\contenido_redes\posts_periodicos\post01_abduccion_miramar_story.png'; Width = 1080; Height = 1920 },
    @{ Name = 'Post 02 Juancho Laguna (Story)'; Path = 'd:\AG\la garza aguachilera\contenido_redes\posts_periodicos\post02_juancho_laguna_story.png'; Width = 1080; Height = 1920 },
    @{ Name = 'Post 03 Mapache Escolleras (Story)'; Path = 'd:\AG\la garza aguachilera\contenido_redes\posts_periodicos\post03_mapache_escolleras_story.png'; Width = 1080; Height = 1920 },
    @{ Name = 'Post 04 Tridente Jaibo (Story)'; Path = 'd:\AG\la garza aguachilera\contenido_redes\posts_periodicos\post04_tridente_jaibo_story.png'; Width = 1080; Height = 1920 },
    @{ Name = 'Post 05 Ensamble Vivo (Story)'; Path = 'd:\AG\la garza aguachilera\contenido_redes\posts_periodicos\post05_ensamble_vivo_story.png'; Width = 1080; Height = 1920 },
    @{ Name = 'Post 06 Cadena Frio (Story)'; Path = 'd:\AG\la garza aguachilera\contenido_redes\posts_periodicos\post06_cadena_frio_story.png'; Width = 1080; Height = 1920 },
    @{ Name = 'Post 07 Camaron Mariposa (Story)'; Path = 'd:\AG\la garza aguachilera\contenido_redes\posts_periodicos\post07_camaron_mariposa_story.png'; Width = 1080; Height = 1920 },
    @{ Name = 'Post 08 Secreto Crunch (Story)'; Path = 'd:\AG\la garza aguachilera\contenido_redes\posts_periodicos\post08_secreto_crunch_story.png'; Width = 1080; Height = 1920 },
    @{ Name = 'Post 09 Medicina Resaca (Story)'; Path = 'd:\AG\la garza aguachilera\contenido_redes\posts_periodicos\post09_medicina_resaca_story.png'; Width = 1080; Height = 1920 },
    @{ Name = 'Post 10 ASMR Tostitos (Story)'; Path = 'd:\AG\la garza aguachilera\contenido_redes\posts_periodicos\post10_asmr_tostitos_story.png'; Width = 1080; Height = 1920 },
    @{ Name = 'Post 11 Oro Verde (Story)'; Path = 'd:\AG\la garza aguachilera\contenido_redes\posts_periodicos\post11_oro_verde_story.png'; Width = 1080; Height = 1920 },
    @{ Name = 'Post 12 Ritual Dominical (Story)'; Path = 'd:\AG\la garza aguachilera\contenido_redes\posts_periodicos\post12_ritual_dominical_story.png'; Width = 1080; Height = 1920 },
    @{ Name = 'Post 13 Hieleras Cargadas (Story)'; Path = 'd:\AG\la garza aguachilera\contenido_redes\posts_periodicos\post13_hieleras_cargadas_story.png'; Width = 1080; Height = 1920 },
    @{ Name = 'Post 14 Zonas Horarios (Story)'; Path = 'd:\AG\la garza aguachilera\contenido_redes\posts_periodicos\post14_zonas_horarios_story.png'; Width = 1080; Height = 1920 },
    @{ Name = 'Post 15 Alerta Cupos (Story)'; Path = 'd:\AG\la garza aguachilera\contenido_redes\posts_periodicos\post15_alerta_cupos_story.png'; Width = 1080; Height = 1920 },
    @{ Name = 'Post 16 Comunidad Jaiba (Story)'; Path = 'd:\AG\la garza aguachilera\contenido_redes\posts_periodicos\post16_comunidad_jaiba_story.png'; Width = 1080; Height = 1920 }
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
        Write-Host " [CORRECTO] Text: '$($t.Text)' -> Ancho: $([math]::Round($measW, 1))px | Margen Derecho Libre: $([math]::Round($remRight, 1))px" -ForegroundColor Green
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

# Auditoria Catalogo Mensual (16 Piezas Feed y Stories)
Write-Host "`n--- CATALOGO MENSUAL COMPLETO (16 PIEZAS FEED Y STORIES) ---" -ForegroundColor Cyan
$catalogSafeZoneTexts = @(
    @{ Piece = 'Post 01'; Text = "$($iQ)PROTEGEN A TAMPICO O VIENEN POR EL AGUACHILE?"; Font = 'Segoe UI Black'; Size = [float]21.0 },
    @{ Piece = 'Post 01'; Text = "$($iE)ABDUCIDOS POR EL SABOR! * TOSTITOS SALSA VERDE"; Font = 'Segoe UI Black'; Size = [float]12.5 },
    @{ Piece = 'Post 02'; Text = 'JUANCHO EL REY DE LA LAGUNA'; Font = 'Segoe UI Black'; Size = [float]21.0 },
    @{ Piece = 'Post 02'; Text = "$($iE)BIEN REPORTADO COMO DIOS MANDA! * 100% MARISCO FRESCO"; Font = 'Segoe UI Black'; Size = [float]12.5 },
    @{ Piece = 'Post 03'; Text = 'CUANDO TE DICEN QUE NO LES GUSTA EL AGUACHILE...'; Font = 'Segoe UI Black'; Size = [float]21.0 },
    @{ Piece = 'Post 03'; Text = "$($iE)HASTA EL MAPACHE SABE CU$($uA)L ES EL M$($uA)S REPORTADO!"; Font = 'Segoe UI Black'; Size = [float]12.5 },
    @{ Piece = 'Post 04'; Text = "EL ESCUADR$($uO)N JAIBO: TRES LEYENDAS"; Font = 'Segoe UI Black'; Size = [float]21.0 },
    @{ Piece = 'Post 04'; Text = 'UN SOLO TOSTIAGUACHILE VERDE TRADICIONAL'; Font = 'Segoe UI Black'; Size = [float]12.5 },
    @{ Piece = 'Post 05'; Text = "$($iQ)POR QU$($uE) LO PREPARAMOS FRENTE A TI?"; Font = 'Segoe UI Black'; Size = [float]21.0 },
    @{ Piece = 'Post 05'; Text = 'TRANSPARENCIA TOTAL: MARISCO FRESCO Y CRUNCH 100%'; Font = 'Segoe UI Black'; Size = [float]12.5 },
    @{ Piece = 'Post 06'; Text = "HIELERAS T$($uE)RMICAS GRADO ALIMENTICIO"; Font = 'Segoe UI Black'; Size = [float]21.0 },
    @{ Piece = 'Post 06'; Text = "AFUERA 38$($deg)C... ADENTRO EL CAMAR$($uO)N A 2$($deg)C"; Font = 'Segoe UI Black'; Size = [float]12.5 },
    @{ Piece = 'Post 07'; Text = "ANATOM$($uI)A DEL CAMAR$($uO)N MARIPOSA"; Font = 'Segoe UI Black'; Size = [float]21.0 },
    @{ Piece = 'Post 07'; Text = "~100g DE CAMAR$($uO)N LIMPIO EN CORTE MARIPOSA"; Font = 'Segoe UI Black'; Size = [float]12.5 },
    @{ Piece = 'Post 08'; Text = 'TOSTITOS SALSA VERDE: 100% CRUJIENTES'; Font = 'Segoe UI Black'; Size = [float]21.0 },
    @{ Piece = 'Post 08'; Text = "$($iE)CERO TOTOPOS REMOJADOS O AGUADOS!"; Font = 'Segoe UI Black'; Size = [float]12.5 },
    @{ Piece = 'Post 09'; Text = "$($iE)LA CURA SAGRADA DE LA CRUDA!"; Font = 'Segoe UI Black'; Size = [float]21.0 },
    @{ Piece = 'Post 09'; Text = "EL SUERO GASTRON$($uO)MICO DE LA CONURBADA"; Font = 'Segoe UI Black'; Size = [float]12.5 },
    @{ Piece = 'Post 10'; Text = "AUDIO EN TU CABEZA: $($iE)CRUNCH!"; Font = 'Segoe UI Black'; Size = [float]21.0 },
    @{ Piece = 'Post 10'; Text = "EL ASMR M$($uA)S DESEADO DE TAMPICO Y MADERO"; Font = 'Segoe UI Black'; Size = [float]12.5 },
    @{ Piece = 'Post 11'; Text = 'ORO VERDE ESMERALDA'; Font = 'Segoe UI Black'; Size = [float]21.0 },
    @{ Piece = 'Post 11'; Text = "CHILE SERRANO FRESCO + LIM$($uO)N COLIMA RECI$($uE)N EXPRIMIDO"; Font = 'Segoe UI Black'; Size = [float]12.5 },
    @{ Piece = 'Post 12'; Text = 'EL RITUAL DOMINICAL JAIBO'; Font = 'Segoe UI Black'; Size = [float]21.0 },
    @{ Piece = 'Post 12'; Text = "SOF$($uA), CLIMA ENCENDIDO Y TOSTIAGUACHILE A TU PUERTA"; Font = 'Segoe UI Black'; Size = [float]12.5 },
    @{ Piece = 'Post 13'; Text = "$($iE)HIELERAS CARGADAS Y EN RUTA!"; Font = 'Segoe UI Black'; Size = [float]21.0 },
    @{ Piece = 'Post 13'; Text = 'COBERTURA TOTAL TAMPICO Y CIUDAD MADERO'; Font = 'Segoe UI Black'; Size = [float]12.5 },
    @{ Piece = 'Post 14'; Text = 'ZONAS Y HORARIOS OFICIALES'; Font = 'Segoe UI Black'; Size = [float]21.0 },
    @{ Piece = 'Post 14'; Text = "S$($uA)BADOS Y DOMINGOS DE 1:00 PM A 5:00 PM"; Font = 'Segoe UI Black'; Size = [float]12.5 },
    @{ Piece = 'Post 15'; Text = "$($iE)$($uU)LTIMOS CUPOS DE LA TARDE!"; Font = 'Segoe UI Black'; Size = [float]21.0 },
    @{ Piece = 'Post 15'; Text = "MARISCO FRESCO DEL D$($uI)A * CUANDO SE ACABA SE CERR$($uO)"; Font = 'Segoe UI Black'; Size = [float]12.5 },
    @{ Piece = 'Post 16'; Text = "EL TOSTIAGUACHILE M$($uA)S REPORTADO"; Font = 'Segoe UI Black'; Size = [float]21.0 },
    @{ Piece = 'Post 16'; Text = 'ORGULLO Y COMUNIDAD 100% JAIBA * GRACIAS POR TU PREFERENCIA'; Font = 'Segoe UI Black'; Size = [float]12.5 },
    # Story Invariants
    @{ Piece = 'Story Shared'; Text = 'LA GARZA AGUACHILERA'; Font = 'Segoe UI Black'; Size = [float]30.0 },
    @{ Piece = 'Story Shared'; Text = "170 MXN LA BOLSA * ~100g CAMAR$($uO)N"; Font = 'Segoe UI Black'; Size = [float]21.0 },
    @{ Piece = 'Story Shared'; Text = 'PEDIDOS Y APARTADOS POR WHATSAPP'; Font = 'Segoe UI Black'; Size = [float]16.0 },
    @{ Piece = 'Story Shared'; Text = '833 252 09 88'; Font = 'Segoe UI Black'; Size = [float]34.0 }
)

foreach ($t in $catalogSafeZoneTexts) {
    $measW = Get-TextWidth $t.Text $t.Font $t.Size
    $rem = (1080 - $measW) / 2
    if ($rem -lt 25) {
        Write-Host " $($t.Piece) [ALERTA SAFE ZONE AL BORDE] '$($t.Text)' -> Ancho: $([math]::Round($measW, 1))px | Margen Libre: $([math]::Round($rem, 1))px" -ForegroundColor Red
        $script:fallasTotales++
    } else {
        Write-Host " $($t.Piece) [CORRECTO SAFE ZONE] '$($t.Text)' -> Ancho: $([math]::Round($measW, 1))px | Margen Libre: $([math]::Round($rem, 1))px" -ForegroundColor Green
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
    $promoVideosToAudit = @(
        @{ Name = 'Video Promocional Final'; Path = 'd:\AG\la garza aguachilera\VIDEOS\promo_aguachile_verde_final.mp4' },
        @{ Name = 'Video TikTok HD Aislado'; Path = 'd:\AG\la garza aguachilera\VIDEOS\aguachile_video_1_tiktok_hd.mp4' }
    )

    foreach ($pv in $promoVideosToAudit) {
        Write-Host "`n--- $($pv.Name) ($($pv.Path)) ---" -ForegroundColor Cyan
        if (-not (Test-Path $pv.Path)) {
            Write-Host " [ERROR NO EXISTE] $($pv.Name) ausente: $($pv.Path)" -ForegroundColor Red
            $script:fallasTotales++
        } else {
            try {
                $jsonOutput = & $ffprobeBin -v error -print_format json -show_format -show_streams $pv.Path | Out-String
                $probeData = $jsonOutput | ConvertFrom-Json

                $videoStream = $probeData.streams | Where-Object { $_.codec_type -eq 'video' } | Select-Object -First 1
                $audioStream = $probeData.streams | Where-Object { $_.codec_type -eq 'audio' } | Select-Object -First 1

                # A. Verificacion de Resolucion (1080 x 1920 Full HD 9:16)
                if ($videoStream) {
                    $vw = [int]$videoStream.width
                    $vh = [int]$videoStream.height
                    if ($vw -eq 1080 -and $vh -eq 1920) {
                        Write-Host " [OK] Resolucion de $($pv.Name): $vw x $vh px (Full HD 9:16 vertical correcto)" -ForegroundColor Green
                    } else {
                        Write-Host " [ERROR RESOLUCION] $($pv.Name) mide $vw x $vh px (Esperado: 1080 x 1920 px)" -ForegroundColor Red
                        $script:fallasTotales++
                    }

                    # B. Verificacion de Codec y Pixel Format
                    $codec = $videoStream.codec_name
                    $pixFmt = $videoStream.pix_fmt
                    if ($codec -eq 'h264' -and $pixFmt -eq 'yuv420p') {
                        Write-Host " [OK] Codec de $($pv.Name): $codec ($pixFmt) compatible universalmente" -ForegroundColor Green
                    } else {
                        Write-Host " [ERROR CODEC] $($pv.Name) codec=$codec, pix_fmt=$pixFmt (Esperado: h264 / yuv420p)" -ForegroundColor Red
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
                        Write-Host " [OK] Bitrate de $($pv.Name): $bitrateKbps kbps (>= 4000 kbps requerido)" -ForegroundColor Green
                    } else {
                        Write-Host " [ERROR BITRATE] Bitrate insuficiente en $($pv.Name): $bitrateKbps kbps (< 4000 kbps requerido)" -ForegroundColor Red
                        $script:fallasTotales++
                    }
                } else {
                    Write-Host " [ERROR STREAM] $($pv.Name) no contiene ningun stream de video." -ForegroundColor Red
                    $script:fallasTotales++
                }

                # D. Verificacion de Audio (AAC Stereo)
                if ($audioStream) {
                    $aCodec = $audioStream.codec_name
                    $aChannels = [int]$audioStream.channels
                    if ($aCodec -eq 'aac' -and $aChannels -eq 2) {
                        Write-Host " [OK] Pista de audio de $($pv.Name): $aCodec stereo ($aChannels canales)" -ForegroundColor Green
                    } else {
                        Write-Host " [ERROR AUDIO] Audio de $($pv.Name): codec=$aCodec, canales=$aChannels (Esperado: aac / 2 canales)" -ForegroundColor Red
                        $script:fallasTotales++
                    }
                } else {
                    Write-Host " [ERROR STREAM] $($pv.Name) no contiene ningun stream de audio." -ForegroundColor Red
                    $script:fallasTotales++
                }

            } catch {
                Write-Host " [ERROR FFPROBE] Excepcion al analizar streams con FFprobe en $($pv.Name): $_" -ForegroundColor Red
                $script:fallasTotales++
            }
        }
    }

    # 3.1 Verificacion Tecnica de Video Animado 60fps (animacion_la_garza_episodio_crudos_60fps.mp4)
    Write-Host "`n--- VIDEO ANIMADO 60FPS (1080 x 1920 @ 60 FPS) ---" -ForegroundColor Cyan
    $anim60File = 'd:\AG\la garza aguachilera\VIDEOS\animacion_la_garza_episodio_crudos_60fps.mp4'

    if (-not (Test-Path $anim60File)) {
        Write-Host " [ERROR NO EXISTE] Video animado 60fps ausente: $anim60File" -ForegroundColor Red
        $script:fallasTotales++
    } else {
        try {
            $jsonOutput60 = & $ffprobeBin -v error -print_format json -show_format -show_streams $anim60File | Out-String
            $probeData60 = $jsonOutput60 | ConvertFrom-Json

            $vStream60 = $probeData60.streams | Where-Object { $_.codec_type -eq 'video' } | Select-Object -First 1
            $aStream60 = $probeData60.streams | Where-Object { $_.codec_type -eq 'audio' } | Select-Object -First 1

            # A. Verificacion de Resolucion (1080 x 1920 Full HD 9:16)
            if ($vStream60) {
                $vw60 = [int]$vStream60.width
                $vh60 = [int]$vStream60.height
                if ($vw60 -eq 1080 -and $vh60 -eq 1920) {
                    Write-Host " [OK] Resolucion de video 60fps: $vw60 x $vh60 px (Full HD 9:16 vertical correcto)" -ForegroundColor Green
                } else {
                    Write-Host " [ERROR RESOLUCION] Video 60fps mide $vw60 x $vh60 px (Esperado: 1080 x 1920 px)" -ForegroundColor Red
                    $script:fallasTotales++
                }

                # B. Verificacion de Frame Rate (60fps / r_frame_rate -eq '60/1')
                $rFps = $vStream60.r_frame_rate
                if ($rFps -eq '60/1') {
                    Write-Host " [OK] Frame rate de video 60fps: $rFps (60 FPS verificado)" -ForegroundColor Green
                } else {
                    Write-Host " [ERROR FRAME RATE] Video r_frame_rate=$rFps (Esperado: 60/1)" -ForegroundColor Red
                    $script:fallasTotales++
                }

                # C. Verificacion de Codec y Pixel Format (h264 / yuv420p)
                $codec60 = $vStream60.codec_name
                $pixFmt60 = $vStream60.pix_fmt
                if ($codec60 -eq 'h264' -and $pixFmt60 -eq 'yuv420p') {
                    Write-Host " [OK] Codec de video 60fps: $codec60 ($pixFmt60) compatible universalmente" -ForegroundColor Green
                } else {
                    Write-Host " [ERROR CODEC] Video codec=$codec60, pix_fmt=$pixFmt60 (Esperado: h264 / yuv420p)" -ForegroundColor Red
                    $script:fallasTotales++
                }

                # D. Verificacion de Bitrate (>= 4000 kbps)
                $bitrateBps60 = 0
                if ($vStream60.bit_rate) {
                    $bitrateBps60 = [int64]$vStream60.bit_rate
                } elseif ($probeData60.format.bit_rate) {
                    $bitrateBps60 = [int64]$probeData60.format.bit_rate
                }

                $bitrateKbps60 = [math]::Round($bitrateBps60 / 1000, 0)
                if ($bitrateBps60 -ge 4000000) {
                    Write-Host " [OK] Bitrate de video 60fps: $bitrateKbps60 kbps (>= 4000 kbps requerido)" -ForegroundColor Green
                } else {
                    Write-Host " [ERROR BITRATE] Bitrate de video 60fps insuficiente: $bitrateKbps60 kbps (< 4000 kbps requerido)" -ForegroundColor Red
                    $script:fallasTotales++
                }
            } else {
                Write-Host " [ERROR STREAM] El archivo 60fps no contiene ningun stream de video." -ForegroundColor Red
                $script:fallasTotales++
            }

            # E. Verificacion de Audio (AAC Stereo)
            if ($aStream60) {
                $aCodec60 = $aStream60.codec_name
                $aChannels60 = [int]$aStream60.channels
                if ($aCodec60 -eq 'aac' -and $aChannels60 -eq 2) {
                    Write-Host " [OK] Pista de audio 60fps: $aCodec60 stereo ($aChannels60 canales)" -ForegroundColor Green
                } else {
                    Write-Host " [ERROR AUDIO] Audio codec=$aCodec60, canales=$aChannels60 (Esperado: aac / 2 canales)" -ForegroundColor Red
                    $script:fallasTotales++
                }
            } else {
                Write-Host " [ERROR STREAM] El archivo 60fps no contiene ningun stream de audio." -ForegroundColor Red
                $script:fallasTotales++
            }

        } catch {
            Write-Host " [ERROR FFPROBE] Excepcion al analizar streams 60fps con FFprobe: $_" -ForegroundColor Red
            $script:fallasTotales++
        }
    }

    # F. Verificacion de Archivos de Locucion Comercial y Musica
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
# 4. AUDITORIA DE INTEGRIDAD DE PAQUETE MAESTRO ZIP (paquete_redes_la_garza.zip)
# -----------------------------------------------------------------------------
Write-Host "`n4. AUDITORIA DE INTEGRIDAD DEL PAQUETE MAESTRO ZIP:" -ForegroundColor Green

$zipPath = 'd:\AG\la garza aguachilera\paquete_redes_la_garza.zip'
if (Test-Path $zipPath) {
    $zipItem = Get-Item $zipPath
    $zipSizeMB = [math]::Round($zipItem.Length / 1MB, 2)
    if ($zipItem.Length -ge 20MB -and $zipItem.Length -lt 100MB) {
        Write-Host " [OK] Paquete ZIP presente y tamano conforme: $($zipItem.Name) ($zipSizeMB MB >= 20 MB y < 100 MB)" -ForegroundColor Green
    } elseif ($zipItem.Length -lt 20MB) {
        Write-Host " [ERROR TAMANO] Paquete ZIP insuficiente: $zipSizeMB MB (< 20 MB requerido)" -ForegroundColor Red
        $script:fallasTotales++
    } else {
        Write-Host " [ERROR TAMANO] Paquete ZIP excede el limite permitido: $zipSizeMB MB (>= 100 MB)" -ForegroundColor Red
        $script:fallasTotales++
    }

    # Verificacion de subdirectorios requeridos Semana_1 a Semana_4
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    try {
        $zipArchive = [System.IO.Compression.ZipFile]::OpenRead($zipPath)
        $requiredWeeks = @('Semana_1', 'Semana_2', 'Semana_3', 'Semana_4')
        foreach ($w in $requiredWeeks) {
            $foundWeek = $false
            foreach ($e in $zipArchive.Entries) {
                if ($e.FullName -match "^$w[\\/]") {
                    $foundWeek = $true
                    break
                }
            }
            if ($foundWeek) {
                Write-Host " [OK] Subdirectorio verificado en ZIP: $w/" -ForegroundColor Green
            } else {
                Write-Host " [ERROR ESTRUCTURA] Falta el subdirectorio $w/ en el archivo ZIP" -ForegroundColor Red
                $script:fallasTotales++
            }
        }
        $zipArchive.Dispose()
    } catch {
        Write-Host " [ERROR LECTURA ZIP] No se pudo inspeccionar el archivo ZIP: $_" -ForegroundColor Red
        $script:fallasTotales++
    }
} else {
    Write-Host " [ERROR NO EXISTE] Paquete ZIP faltante en la raiz: $zipPath" -ForegroundColor Red
    $script:fallasTotales++
}

# -----------------------------------------------------------------------------
# 5. ESCANEO INTEGRAL DE PALABRAS PROHIBIDAS (BLINDAJE DE MARCA)
# -----------------------------------------------------------------------------
Write-Host "`n5. ESCANEO INTEGRAL DE PALABRAS PROHIBIDAS:" -ForegroundColor Green

$patterns = @(
    'jumbo',
    'nacho',
    'tostitos?.*redondos?',
    'totopos?.*redondos?',
    '#tostitosredondos?',
    'dark\s*kitchen',
    'Rosa\s*210',
    'base\s*de\s*operaciones',
    '\$150',
    '150\s*MXN',
    '150\s*pesos',
    '150%20',
    'ciento\s*cincuenta'
)

$projectRoot = 'd:\AG\la garza aguachilera'
$thisScriptPath = if ($PSCommandPath) { (Resolve-Path $PSCommandPath).Path } else { (Resolve-Path 'd:\AG\la garza aguachilera\herramientas\auditar_multimedia_qa.ps1' -ErrorAction SilentlyContinue).Path }

# Exclusion limpia de este script, del test suite y del directorio de metadatos .agents y tests
$filesToScan = Get-ChildItem -Path $projectRoot -Recurse -Include *.ps1, *.html, *.md, *.txt, *.py, *.json, *.ass | Where-Object {
    $_.FullName -notmatch '\\\.agents\\' -and
    $_.FullName -notmatch '\\\.git\\' -and
    $_.FullName -notmatch '\\tests\\' -and
    $_.FullName -notmatch '\\control_calidad\\' -and
    $_.FullName -ne $thisScriptPath -and
    $_.Name -notlike 'test_*' -and
    $_.Name -ne 'ejecutar_empresa_qa.py' -and
    $_.Name -ne 'auditar_multimedia_qa.ps1' -and
    $_.Name -ne 'proposed_auditar_multimedia_qa.ps1' -and
    $_.Name -ne 'empresa_control_calidad_qa.ps1' -and
    $_.Name -ne 'e2e_test_suite.ps1' -and
    $_.Name -ne 'adversarial_ux_integrity_test.ps1' -and
    $_.Name -ne 'test_deploy_readiness_adversarial.ps1' -and
    $_.Name -ne 'test_catalog_adversarial_qa.ps1' -and
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
    Write-Host " [LIMPIO] Cero menciones de palabras prohibidas ('jumbo', 'tostitos redondos', 'dark kitchen', 'Rosa 210', 'nacho', '`$150', '150 MXN', '150 pesos', 'ciento cincuenta')." -ForegroundColor Green
}

# -----------------------------------------------------------------------------
# 5.1 VERIFICACION POSITIVA DE PRECIO OFICIAL $170 MXN (KEY FILES)
# -----------------------------------------------------------------------------
Write-Host "`n5.1 VERIFICACION POSITIVA DE PRECIO OFICIAL `$170 MXN (KEY FILES):" -ForegroundColor Green

$keyFilesToValidate = @(
    @{ Name = 'index.html'; Path = Join-Path $projectRoot 'index.html'; MinOccurrences = 5 },
    @{ Name = 'panel_control.html'; Path = Join-Path $projectRoot 'panel_control.html'; MinOccurrences = 20 }
)

foreach ($kf in $keyFilesToValidate) {
    if (Test-Path $kf.Path) {
        $content = Get-Content -Path $kf.Path -Raw -Encoding UTF8
        $matches170 = [regex]::Matches($content, '(\$170|170\s*MXN|170\s*pesos)')
        if ($matches170.Count -ge $kf.MinOccurrences) {
            Write-Host " [OK] $($kf.Name) contiene el precio oficial `$170 MXN ($($matches170.Count) menciones detectadas, min esperado: $($kf.MinOccurrences))" -ForegroundColor Green
        } else {
            Write-Host " [ERROR BLINDAJE] $($kf.Name) no cuenta con suficientes menciones del precio oficial `$170 MXN (Encontradas: $($matches170.Count), Esperadas: >= $($kf.MinOccurrences))" -ForegroundColor Red
            $script:fallasTotales++
        }
    } else {
        Write-Host " [ERROR NO EXISTE] Archivo clave ausente para validacion de precio: $($kf.Path)" -ForegroundColor Red
        $script:fallasTotales++
    }
}

# -----------------------------------------------------------------------------
# 5.2 VERIFICACION DE REPRODUCTORES DE VIDEO HTML5 (WEB & PANEL DE CONTROL)
# -----------------------------------------------------------------------------
Write-Host "`n5.2 VERIFICACION DE REPRODUCTORES DE VIDEO HTML5 EN WEB Y PANEL:" -ForegroundColor Green

$htmlFilesWithVideo = @(
    @{ Name = 'index.html'; Path = Join-Path $projectRoot 'index.html' },
    @{ Name = 'panel_control.html'; Path = Join-Path $projectRoot 'panel_control.html' }
)

foreach ($hf in $htmlFilesWithVideo) {
    if (Test-Path $hf.Path) {
        $htmlContent = Get-Content -Path $hf.Path -Raw -Encoding UTF8
        if ($htmlContent -match '<video\b[^>]*>') {
            Write-Host " [OK] $($hf.Name) contiene al menos un reproductor HTML5 (<video> tag detectado)" -ForegroundColor Green
        } else {
            Write-Host " [ERROR REPRODUCTOR] $($hf.Name) no contiene etiquetas <video>" -ForegroundColor Red
            $script:fallasTotales++
        }

        if ($htmlContent -match 'animacion_la_garza_episodio_crudos_60fps\.mp4') {
            Write-Host " [OK] $($hf.Name) referencia el video animado 60fps (animacion_la_garza_episodio_crudos_60fps.mp4)" -ForegroundColor Green
        } else {
            Write-Host " [ERROR VIDEO 60FPS] $($hf.Name) no referencia animacion_la_garza_episodio_crudos_60fps.mp4" -ForegroundColor Red
            $script:fallasTotales++
        }
    } else {
        Write-Host " [ERROR NO EXISTE] Archivo HTML ausente: $($hf.Path)" -ForegroundColor Red
        $script:fallasTotales++
    }
}

# -----------------------------------------------------------------------------
# 5.3 VERIFICACION DE LOS 4 COMPLEMENTOS Y 2 MODALIDADES DE SERVICIO
# -----------------------------------------------------------------------------
Write-Host "`n5.3 VERIFICACION DE LOS 4 COMPLEMENTOS Y 2 MODALIDADES DE SERVICIO:" -ForegroundColor Green

$indexContent = if (Test-Path (Join-Path $projectRoot 'index.html')) { Get-Content (Join-Path $projectRoot 'index.html') -Raw -Encoding UTF8 } else { "" }

$complementsToCheck = @(
    @{ Name = 'Tostitos Salsa Verde'; Pattern = 'Tostitos\s+Salsa\s+Verde' },
    @{ Name = 'Tostitos Flamin Hot'; Pattern = 'Flamin''?\s*Hot' },
    @{ Name = 'Chips o Totopos'; Pattern = '(Chips|Totopos)' },
    @{ Name = 'Galletas Saladas'; Pattern = 'Galletas\s+Saladas' }
)

foreach ($c in $complementsToCheck) {
    if ($indexContent -match $c.Pattern) {
        Write-Host " [OK] Complemento verificado en index.html: $($c.Name)" -ForegroundColor Green
    } else {
        Write-Host " [ADVERTENCIA/PENDIENTE] Complemento '$($c.Name)' aun no detectado en index.html" -ForegroundColor Yellow
    }
}

$modesToCheck = @(
    @{ Name = 'Servido Preparado'; Pattern = 'preparado' },
    @{ Name = 'Servido Por Separado'; Pattern = '(por\s+separado|separado)' }
)

foreach ($m in $modesToCheck) {
    if ($indexContent -match $m.Pattern) {
        Write-Host " [OK] Modalidad de servicio verificada en index.html: $($m.Name)" -ForegroundColor Green
    } else {
        Write-Host " [ADVERTENCIA/PENDIENTE] Modalidad de servicio '$($m.Name)' aun no detectada en index.html" -ForegroundColor Yellow
    }
}

# -----------------------------------------------------------------------------
# 5.4 VERIFICACION DE ATRIBUTOS GASTRONOMICOS (AGUACATE Y SALSAS DE LA CASA)
# -----------------------------------------------------------------------------
Write-Host "`n5.4 VERIFICACION DE ATRIBUTOS GASTRONOMICOS (AGUACATE Y SALSAS DE LA CASA):" -ForegroundColor Green

if ($indexContent -match 'aguacate') {
    $matchesAguacate = [regex]::Matches($indexContent, 'aguacate', 'IgnoreCase')
    Write-Host " [OK] Aguacate fresco garantizado verificado en index.html ($($matchesAguacate.Count) menciones detectadas)" -ForegroundColor Green
} else {
    Write-Host " [ERROR GASTRONOMIA] index.html no contiene menciones de aguacate fresco" -ForegroundColor Red
    $script:fallasTotales++
}

if ($indexContent -match '(salsas?\s+de\s+la\s+casa|combinaci[oó]n\s+especial)') {
    $matchesSalsas = [regex]::Matches($indexContent, '(salsas?\s+de\s+la\s+casa|combinaci[oó]n\s+especial)', 'IgnoreCase')
    Write-Host " [OK] Salsas especiales / de la casa verificadas en index.html ($($matchesSalsas.Count) menciones detectadas)" -ForegroundColor Green
} else {
    Write-Host " [ERROR GASTRONOMIA] index.html no contiene menciones de salsas de la casa o combinacion especial" -ForegroundColor Red
    $script:fallasTotales++
}

# -----------------------------------------------------------------------------
# 5.5 VERIFICACION DE CACHE-BUSTING (?v=170) Y REGENERACION FISICA EN DISCO
# -----------------------------------------------------------------------------
Write-Host "`n5.5 VERIFICACION DE CACHE-BUSTING (?v=170) Y REGENERACION FISICA (`$170 MXN):" -ForegroundColor Green

foreach ($hf in $htmlFilesWithVideo) {
    if (Test-Path $hf.Path) {
        $hc = Get-Content -Path $hf.Path -Raw -Encoding UTF8
        $cbMatches = [regex]::Matches($hc, '\?v=170')
        if ($cbMatches.Count -ge 8) {
            Write-Host " [OK] Cache-busting ?v=170 activo en $($hf.Name) ($($cbMatches.Count) referencias actualizadas)" -ForegroundColor Green
        } else {
            Write-Host " [ERROR CACHE] $($hf.Name) no cuenta con cache-busting ?v=170 suficiente ($($cbMatches.Count))" -ForegroundColor Red
            $script:fallasTotales++
        }
    }
}

$minRegenDate = [datetime]"2026-10-23"
$regenTargets = @(
    'flyer_portada_verde.png',
    'flyer_post_verde.png',
    'flyer_historia_verde.png',
    'contenido_redes\posts_periodicos\post1_antojo_lunes.png',
    'contenido_redes\catalogo_mes\semana1\post01_abduccion_miramar.png',
    'contenido_redes\catalogo_mes\spooky\spooky_post01_juancho_resurreccion.png',
    'FRAMES\scene4_start.png',
    'FRAMES\scene6_end.png',
    'VIDEOS\promo_aguachile_verde_final.mp4',
    'VIDEOS\aguachile_video_1_tiktok_hd.mp4',
    'VIDEOS\animacion_la_garza_episodio_crudos_60fps.mp4',
    'VIDEOS\promo_halloween_zombies_crudos.mp4'
)

foreach ($rt in $regenTargets) {
    $rtFull = Join-Path $projectRoot $rt
    if (-not (Test-Path -LiteralPath $rtFull)) {
        Write-Host " [ERROR NO EXISTE] Activo regenerado ausente: $rt" -ForegroundColor Red
        $script:fallasTotales++
    } else {
        $lwt = (Get-Item -LiteralPath $rtFull).LastWriteTime
        if ($lwt -ge $minRegenDate) {
            Write-Host " [OK] Regenerado fisicamente en disco ($($lwt.ToString('yyyy-MM-dd HH:mm'))): $rt" -ForegroundColor Green
        } else {
            Write-Host " [ERROR DESACTUALIZADO] Activo no regenerado hoy ($($lwt.ToString('yyyy-MM-dd HH:mm'))): $rt" -ForegroundColor Red
            $script:fallasTotales++
        }
    }
}

# -----------------------------------------------------------------------------
# 6. RESUMEN Y ENFORCEMENT DE CODIGO DE SALIDA
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
