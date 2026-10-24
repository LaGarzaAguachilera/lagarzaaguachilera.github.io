# ==============================================================================
# LA GARZA AGUACHILERA — RENDERIZADOR MAESTRO DEL CATALOGO MENSUAL (16 PIEZAS)
# Archivo: herramientas\generar_catalogo_mes.ps1
# Genera 16 piezas en formato Feed (1080x1080) y Story (1080x1920)
# Cumple con estandares de franquicia pop comercial, Safe Zones y blindaje de marca.
# ==============================================================================
param(
    [ValidateRange(0, 4)]
    [int]$Week = 0,         # 0 = Todas las semanas (1 a 4)
    [ValidateRange(0, 16)]
    [int]$Piece = 0         # 0 = Todos los posts (1 a 16)
)

Add-Type -AssemblyName System.Drawing

$rootDir   = "d:\AG\la garza aguachilera"
$outPosts  = "$rootDir\contenido_redes\posts_periodicos"
$outMes    = "$rootDir\contenido_redes\catalogo_mes"

# Asegurar directorios destino
if (-not (Test-Path $outPosts)) { New-Item -ItemType Directory -Path $outPosts -Force | Out-Null }
if (-not (Test-Path $outMes))   { New-Item -ItemType Directory -Path $outMes -Force | Out-Null }
foreach ($w in 1..4) {
    $dirW = "$outMes\semana$w"
    if (-not (Test-Path $dirW)) { New-Item -ItemType Directory -Path $dirW -Force | Out-Null }
}

# Rutas de activos oficiales
$logoPath    = "$rootDir\La garza aguachilera.jpeg"
$foodRedondo = "$rootDir\tostiaguachile_verde_redondo.jpg"
$foodHero    = "$rootDir\aguachile_verde_hero.jpg"
$cleanComida = "$rootDir\clean_comida.png"
$juanchoPath = "$rootDir\clean_juancho.png"
$ovniPath    = "$rootDir\clean_ovni.png"
$mapachePath = "$rootDir\clean_mapache.png"
$skylinePath = "$rootDir\tampico_skyline_bg.jpg"
if (-not (Test-Path $skylinePath)) {
    $skylinePath = "$rootDir\herramientas\portada_bg_tampico_skyline_1792107773833.jpg"
}

# Constantes Unicode seguras para evitar cualquier mojibake en PowerShell
$uA = [char]0x00C1; $uE = [char]0x00C9; $uI = [char]0x00CD; $uO = [char]0x00D3; $uU = [char]0x00DA; $uN = [char]0x00D1
$lA = [char]0x00E1; $lE = [char]0x00E9; $lI = [char]0x00ED; $lO = [char]0x00F3; $lU = [char]0x00FA; $lN = [char]0x00F1
$iE = [char]0x00A1; $iQ = [char]0x00BF; $deg = [char]0x00B0; $bul = [char]0x2022; $star = [char]0x2605
$qL = [char]0x00AB; $qR = [char]0x00BB

# Formateadores de texto
$sfCenter = [System.Drawing.StringFormat]::new()
$sfCenter.Alignment = [System.Drawing.StringAlignment]::Center
$sfCenter.LineAlignment = [System.Drawing.StringAlignment]::Center

$sfLeft = [System.Drawing.StringFormat]::new()
$sfLeft.Alignment = [System.Drawing.StringAlignment]::Near
$sfLeft.LineAlignment = [System.Drawing.StringAlignment]::Center

# ==============================================================================
# MOTOR GRAFICO Y PRIMITIVAS POP DE ALTO IMPACTO
# ==============================================================================

function Draw-SkylineAtmosphere([System.Drawing.Graphics]$g, [System.Drawing.Rectangle]$destRect, [float]$alpha = 0.35) {
    if (-not (Test-Path $script:skylinePath)) { return }
    $skyImg = [System.Drawing.Image]::FromFile($script:skylinePath)
    $ia = [System.Drawing.Imaging.ImageAttributes]::new()
    $cm = [System.Drawing.Imaging.ColorMatrix]::new(@(
        @(1, 0, 0, 0, 0),
        @(0, 1, 0, 0, 0),
        @(0, 0, 1, 0, 0),
        @(0, 0, 0, $alpha, 0),
        @(0, 0, 0, 0, 1)
    ))
    $ia.SetColorMatrix($cm)
    $g.DrawImage($skyImg, $destRect, 0, 0, $skyImg.Width, $skyImg.Height, [System.Drawing.GraphicsUnit]::Pixel, $ia)
    $ia.Dispose()
    $skyImg.Dispose()
}

function Draw-SunburstRays([System.Drawing.Graphics]$g, [float]$cx, [float]$cy, [float]$radius, [int]$rays, [System.Drawing.Color]$rayColor) {
    $brushRay = [System.Drawing.SolidBrush]::new($rayColor)
    $step = 360.0 / ($rays * 2)
    for ($i = 0; $i -lt ($rays * 2); $i += 2) {
        $a1 = ($i * $step) * [math]::Pi / 180.0
        $a2 = (($i + 1) * $step) * [math]::Pi / 180.0
        $p1 = [System.Drawing.PointF]::new($cx, $cy)
        $p2 = [System.Drawing.PointF]::new($cx + $radius * [math]::Cos($a1), $cy + $radius * [math]::Sin($a1))
        $p3 = [System.Drawing.PointF]::new($cx + $radius * [math]::Cos($a2), $cy + $radius * [math]::Sin($a2))
        $g.FillPolygon($brushRay, @($p1, $p2, $p3))
    }
    $brushRay.Dispose()
}

function Draw-StickerWithShadow([System.Drawing.Graphics]$g, [string]$imgPath, [float]$x, [float]$y, [float]$w, [float]$h, [float]$angle = 0) {
    if (-not (Test-Path $imgPath)) { return }
    $img = [System.Drawing.Image]::FromFile($imgPath)
    $cx = $x + $w / 2.0
    $cy = $y + $h / 2.0

    # Tier 1: Soft Ambient Occlusion Bloom (radio amplio, alpha suave)
    $stateAmb = $g.Save()
    $g.TranslateTransform($cx + 14, $cy + 16)
    if ($angle -ne 0) { $g.RotateTransform($angle) }
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $cmAmb = [System.Drawing.Imaging.ColorMatrix]::new(@(
        @(0, 0, 0, 0, 0),
        @(0, 0, 0, 0, 0),
        @(0, 0, 0, 0, 0),
        @(0, 0, 0, 0.22, 0),
        @(0, 0, 0, 0, 1)
    ))
    $iaAmb = [System.Drawing.Imaging.ImageAttributes]::new()
    $iaAmb.SetColorMatrix($cmAmb)
    $ambW = $w * 1.04
    $ambH = $h * 1.04
    $g.DrawImage($img, [System.Drawing.Rectangle]::new([int](-$ambW/2), [int](-$ambH/2), [int]$ambW, [int]$ambH), 0, 0, $img.Width, $img.Height, [System.Drawing.GraphicsUnit]::Pixel, $iaAmb)
    $g.Restore($stateAmb)
    $iaAmb.Dispose()

    # Tier 2: Contact Drop Shadow (offset cerrado, alpha firme)
    $stateSh = $g.Save()
    $g.TranslateTransform($cx + 7, $cy + 9)
    if ($angle -ne 0) { $g.RotateTransform($angle) }
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $cm = [System.Drawing.Imaging.ColorMatrix]::new(@(
        @(0, 0, 0, 0, 0),
        @(0, 0, 0, 0, 0),
        @(0, 0, 0, 0, 0),
        @(0, 0, 0, 0.48, 0),
        @(0, 0, 0, 0, 1)
    ))
    $ia = [System.Drawing.Imaging.ImageAttributes]::new()
    $ia.SetColorMatrix($cm)
    $g.DrawImage($img, [System.Drawing.Rectangle]::new([int](-$w/2), [int](-$h/2), [int]$w, [int]$h), 0, 0, $img.Width, $img.Height, [System.Drawing.GraphicsUnit]::Pixel, $ia)
    $g.Restore($stateSh)
    $ia.Dispose()

    # Tier 3: Renderizado de Sticker en Alta Definicion
    $state = $g.Save()
    $g.TranslateTransform($cx, $cy)
    if ($angle -ne 0) { $g.RotateTransform($angle) }
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $rect = [System.Drawing.RectangleF]::new(-$w / 2.0, -$h / 2.0, $w, $h)
    $g.DrawImage($img, $rect)
    $g.Restore($state)
    $img.Dispose()
}

function Draw-RoundedBox([System.Drawing.Graphics]$g, [System.Drawing.Brush]$brush, [System.Drawing.Pen]$pen, [System.Drawing.RectangleF]$rect, [float]$radius, [bool]$hardShadow = $true) {
    $d = [math]::Min($radius * 2.0, [math]::Min($rect.Width, $rect.Height))
    if ($hardShadow) {
        # Sombra ambiental suave
        $shPath1 = [System.Drawing.Drawing2D.GraphicsPath]::new()
        $sx1 = $rect.X + 8
        $sy1 = $rect.Y + 9
        $shPath1.AddArc($sx1, $sy1, $d, $d, 180, 90)
        $shPath1.AddArc($sx1 + $rect.Width - $d, $sy1, $d, $d, 270, 90)
        $shPath1.AddArc($sx1 + $rect.Width - $d, $sy1 + $rect.Height - $d, $d, $d, 0, 90)
        $shPath1.AddArc($sx1, $sy1 + $rect.Height - $d, $d, $d, 90, 90)
        $shPath1.CloseFigure()
        $shBrush1 = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(65, 0, 0, 0))
        $g.FillPath($shBrush1, $shPath1)
        $shBrush1.Dispose()
        $shPath1.Dispose()

        # Sombra de contacto
        $shPath2 = [System.Drawing.Drawing2D.GraphicsPath]::new()
        $sx2 = $rect.X + 4
        $sy2 = $rect.Y + 5
        $shPath2.AddArc($sx2, $sy2, $d, $d, 180, 90)
        $shPath2.AddArc($sx2 + $rect.Width - $d, $sy2, $d, $d, 270, 90)
        $shPath2.AddArc($sx2 + $rect.Width - $d, $sy2 + $rect.Height - $d, $d, $d, 0, 90)
        $shPath2.AddArc($sx2, $sy2 + $rect.Height - $d, $d, $d, 90, 90)
        $shPath2.CloseFigure()
        $shBrush2 = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(125, 0, 0, 0))
        $g.FillPath($shBrush2, $shPath2)
        $shBrush2.Dispose()
        $shPath2.Dispose()
    }

    $path = [System.Drawing.Drawing2D.GraphicsPath]::new()
    $path.AddArc($rect.X, $rect.Y, $d, $d, 180, 90)
    $path.AddArc($rect.Right - $d, $rect.Y, $d, $d, 270, 90)
    $path.AddArc($rect.Right - $d, $rect.Bottom - $d, $d, $d, 0, 90)
    $path.AddArc($rect.X, $rect.Bottom - $d, $d, $d, 90, 90)
    $path.CloseFigure()
    if ($brush) { $g.FillPath($brush, $path) }
    if ($pen) { $g.DrawPath($pen, $path) }
    $path.Dispose()
}

function Draw-OutlinedText([System.Drawing.Graphics]$g, [string]$text, [System.Drawing.Font]$font, [System.Drawing.Brush]$fillBrush, [System.Drawing.Pen]$outlinePen, [float]$x, [float]$y, [System.Drawing.StringFormat]$sf = $null) {
    $path = [System.Drawing.Drawing2D.GraphicsPath]::new()
    $ff = $font.FontFamily
    $style = [int]$font.Style
    $emSize = $font.SizeInPoints * 96.0 / 72.0
    if ($sf) {
        $path.AddString($text, $ff, $style, $emSize, [System.Drawing.PointF]::new($x, $y), $sf)
    } else {
        $path.AddString($text, $ff, $style, $emSize, [System.Drawing.PointF]::new($x, $y), [System.Drawing.StringFormat]::GenericTypographic)
    }
    if ($outlinePen) { $g.DrawPath($outlinePen, $path) }
    if ($fillBrush) { $g.FillPath($fillBrush, $path) }
    $path.Dispose()
}

function Draw-OfficialLogoBadge([System.Drawing.Graphics]$g, [int]$x, [int]$y, [int]$size, [System.Drawing.Color]$ringColor) {
    if (-not (Test-Path $script:logoPath)) { return }
    $logoImg = [System.Drawing.Image]::FromFile($script:logoPath)

    # Ambient shadow
    $shBrush1 = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(70, 0, 0, 0))
    $g.FillEllipse($shBrush1, $x - 2, $y + 8, $size + 12, $size + 12)
    $shBrush1.Dispose()

    # Contact shadow
    $shBrush2 = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(150, 0, 0, 0))
    $g.FillEllipse($shBrush2, $x - 3, $y + 4, $size + 8, $size + 8)
    $shBrush2.Dispose()

    # White ring
    $wBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)
    $g.FillEllipse($wBrush, $x - 5, $y - 5, $size + 10, $size + 10)
    $wBrush.Dispose()

    # Clipped logo
    $clip = [System.Drawing.Drawing2D.GraphicsPath]::new()
    $clip.AddEllipse($x, $y, $size, $size)
    $g.SetClip($clip)
    $g.DrawImage($logoImg, $x, $y, $size, $size)
    $g.ResetClip()
    $clip.Dispose()

    # Accent ring
    $penRing = [System.Drawing.Pen]::new($ringColor, 5)
    $g.DrawEllipse($penRing, $x, $y, $size, $size)
    $penRing.Dispose()
    $logoImg.Dispose()
}

function Draw-FramedPhoto([System.Drawing.Graphics]$g, [string]$imgPath, [int]$x, [int]$y, [int]$w, [int]$h, [int]$radius, [System.Drawing.Color]$borderColor, [float]$cropW = 1.0) {
    if (-not (Test-Path $imgPath)) { return }
    $img = [System.Drawing.Image]::FromFile($imgPath)
    $d = $radius * 2.0

    # Ambient Soft Shadow
    $shPath1 = [System.Drawing.Drawing2D.GraphicsPath]::new()
    $shPath1.AddArc($x + 10, $y + 12, $d, $d, 180, 90)
    $shPath1.AddArc($x + 10 + $w - $d, $y + 12, $d, $d, 270, 90)
    $shPath1.AddArc($x + 10 + $w - $d, $y + 12 + $h - $d, $d, $d, 0, 90)
    $shPath1.AddArc($x + 10, $y + 12 + $h - $d, $d, $d, 90, 90)
    $shPath1.CloseFigure()
    $shBrush1 = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(65, 0, 0, 0))
    $g.FillPath($shBrush1, $shPath1)
    $shBrush1.Dispose()
    $shPath1.Dispose()

    # Contact Shadow
    $shPath2 = [System.Drawing.Drawing2D.GraphicsPath]::new()
    $shPath2.AddArc($x + 5, $y + 6, $d, $d, 180, 90)
    $shPath2.AddArc($x + 5 + $w - $d, $y + 6, $d, $d, 270, 90)
    $shPath2.AddArc($x + 5 + $w - $d, $y + 6 + $h - $d, $d, $d, 0, 90)
    $shPath2.AddArc($x + 5, $y + 6 + $h - $d, $d, $d, 90, 90)
    $shPath2.CloseFigure()
    $shBrush2 = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(130, 0, 0, 0))
    $g.FillPath($shBrush2, $shPath2)
    $shBrush2.Dispose()
    $shPath2.Dispose()

    # Photo Clip
    $clip = [System.Drawing.Drawing2D.GraphicsPath]::new()
    $clip.AddArc($x, $y, $d, $d, 180, 90)
    $clip.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
    $clip.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90)
    $clip.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
    $clip.CloseFigure()

    $g.SetClip($clip)
    $srcW = [int]($img.Width * $cropW)
    $destRect = [System.Drawing.Rectangle]::new($x, $y, $w, $h)
    $g.DrawImage($img, $destRect, 0, 0, $srcW, $img.Height, [System.Drawing.GraphicsUnit]::Pixel)
    $g.ResetClip()

    # Outer border rim
    $penB = [System.Drawing.Pen]::new($borderColor, 5)
    $g.DrawPath($penB, $clip)
    $penB.Dispose()
    $clip.Dispose()
    $img.Dispose()
}

function Draw-PricePillComponent([System.Drawing.Graphics]$g, [System.Drawing.RectangleF]$rect, [string]$extraText = "") {
    $bGrad = [System.Drawing.Drawing2D.LinearGradientBrush]::new($rect, [System.Drawing.Color]::FromArgb(249, 115, 22), [System.Drawing.Color]::FromArgb(234, 88, 12), 0.0)
    $penPill = [System.Drawing.Pen]::new([System.Drawing.Color]::White, 3.5)
    Draw-RoundedBox $g $bGrad $penPill $rect ($rect.Height / 2.0) $true
    $bGrad.Dispose()
    $penPill.Dispose()

    $fPrice = [System.Drawing.Font]::new("Segoe UI Black", 16.5, [System.Drawing.FontStyle]::Bold)
    $bWhite = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)
    $pDark = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(15, 23, 42), 4)
    $pDark.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round

    $displayStr = "$($script:star) `$170 MXN LA BOLSA $($script:bul) ~100g CAMAR$($script:uO)N"
    if ($extraText) { $displayStr += " $($script:bul) $extraText" }
    $displayStr += " $($script:star)"

    Draw-OutlinedText $g $displayStr $fPrice $bWhite $pDark ($rect.X + $rect.Width/2.0) ($rect.Y + $rect.Height/2.0) $script:sfCenter
    $fPrice.Dispose()
    $bWhite.Dispose()
    $pDark.Dispose()
}

function Draw-FreshnessCardComponent([System.Drawing.Graphics]$g, [System.Drawing.RectangleF]$rect) {
    $brushCard = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
        $rect,
        [System.Drawing.Color]::FromArgb(245, 10, 24, 42),
        [System.Drawing.Color]::FromArgb(248, 6, 16, 30),
        90.0
    )
    $penCard = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(254, 240, 138), 2.5)
    Draw-RoundedBox $g $brushCard $penCard $rect 20 $true
    $brushCard.Dispose()
    $penCard.Dispose()

    $fStmt = [System.Drawing.Font]::new("Segoe UI Black", 14.0, [System.Drawing.FontStyle]::Bold)
    $bYellow = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(254, 240, 138))
    $pDark = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(15, 23, 42), 4)
    $pDark.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round

    $stmt = "$($script:qL)El producto es preparado frente a usted para corroborar su frescura$($script:qR)"
    Draw-OutlinedText $g $stmt $fStmt $bYellow $pDark ($rect.X + $rect.Width/2.0) ($rect.Y + $rect.Height/2.0) $script:sfCenter
    $fStmt.Dispose()
    $bYellow.Dispose()
    $pDark.Dispose()
}

function Draw-WhatsAppButtonComponent([System.Drawing.Graphics]$g, [System.Drawing.RectangleF]$rect) {
    $bWa = [System.Drawing.Drawing2D.LinearGradientBrush]::new($rect, [System.Drawing.Color]::FromArgb(37, 211, 102), [System.Drawing.Color]::FromArgb(18, 140, 62), 90.0)
    $pWa = [System.Drawing.Pen]::new([System.Drawing.Color]::White, 3.5)
    Draw-RoundedBox $g $bWa $pWa $rect ($rect.Height / 2.0) $true
    $bWa.Dispose()
    $pWa.Dispose()

    $fWa = [System.Drawing.Font]::new("Segoe UI Black", 18.0, [System.Drawing.FontStyle]::Bold)
    $bWhite = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)
    $pDark = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(15, 23, 42), 4.5)
    $pDark.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round

    $waText = "PEDIDOS Y APARTADOS WHATSAPP: 833 252 09 88"
    Draw-OutlinedText $g $waText $fWa $bWhite $pDark ($rect.X + $rect.Width/2.0) ($rect.Y + $rect.Height/2.0) $script:sfCenter
    $fWa.Dispose()
    $bWhite.Dispose()
    $pDark.Dispose()
}

function Save-PostArtefacts([System.Drawing.Bitmap]$bmpFeed, [System.Drawing.Bitmap]$bmpStory, [string]$slug, [int]$week) {
    $feedFile = "$script:outPosts\$slug.png"
    $storyFile = "$script:outPosts\${slug}_story.png"
    $weekFeed = "$script:outMes\semana$week\$slug.png"
    $weekStory = "$script:outMes\semana$week\${slug}_story.png"

    $bmpFeed.Save($feedFile, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmpStory.Save($storyFile, [System.Drawing.Imaging.ImageFormat]::Png)

    Copy-Item $feedFile $weekFeed -Force
    Copy-Item $storyFile $weekStory -Force

    # Sincronizar archivo de copy TXT en la carpeta de la semana si existe
    $copySrc = "$script:outPosts\${slug}_copy.txt"
    if (Test-Path $copySrc) {
        Copy-Item $copySrc "$script:outMes\semana$week\${slug}_copy.txt" -Force
    }

    $sizeFeedKB = [math]::Round((Get-Item $feedFile).Length / 1024, 1)
    $sizeStoryKB = [math]::Round((Get-Item $storyFile).Length / 1024, 1)
    Write-Host " [OK] Sem $week -> $slug (Feed: ${sizeFeedKB} KB | Story: ${sizeStoryKB} KB)" -ForegroundColor Green
}

# ==============================================================================
# DEFINICION DETALLADA DE LAS 16 PIEZAS ESTRATEGICAS
# ==============================================================================

$catalogMeta = @(
    @{
        Id = 1; Week = 1; Slug = "post01_abduccion_miramar"
        Badge = "EXPEDIENTE SECRETO: PLAYA MIRAMAR"
        Headline = "$($iQ)PROTEGEN A TAMPICO O VIENEN POR EL AGUACHILE?"
        Subhead = "$($iE)ABDUCIDOS POR EL SABOR! $($bul) TOSTITOS SALSA VERDE"
        Color1 = [System.Drawing.Color]::FromArgb(59, 7, 100)      # Cosmic Violet
        Color2 = [System.Drawing.Color]::FromArgb(15, 23, 42)      # Night Navy
        AccentColor = [System.Drawing.Color]::FromArgb(163, 230, 53) # Neon Lime
        StickerPrimary = "ovni"; StickerSecondary = "comida"; StickerCorner = "mapache"
        FoodPhoto = ""; ExtraTag = "RECETA DE OTRA GALAXIA"
    },
    @{
        Id = 2; Week = 1; Slug = "post02_juancho_laguna"
        Badge = "SELLO REAL DE LA LAGUNA DEL CARPINTERO"
        Headline = "JUANCHO EL REY DE LA LAGUNA"
        Subhead = "$($iE)BIEN REPORTADO COMO DIOS MANDA! $($bul) 100% MARISCO FRESCO"
        Color1 = [System.Drawing.Color]::FromArgb(4, 120, 87)       # Emerald Jade
        Color2 = [System.Drawing.Color]::FromArgb(6, 78, 59)        # Deep Forest
        AccentColor = [System.Drawing.Color]::FromArgb(250, 204, 21) # Gold
        StickerPrimary = "juancho"; StickerSecondary = "comida"; StickerCorner = "logo"
        FoodPhoto = $foodHero; ExtraTag = "AUTORIDAD JAIBA"
    },
    @{
        Id = 3; Week = 1; Slug = "post03_mapache_escolleras"
        Badge = "OPERATIVO ESCOLLERAS DE MIRAMAR"
        Headline = "CUANDO TE DICEN QUE NO LES GUSTA EL AGUACHILE..."
        Subhead = "$($iE)HASTA EL MAPACHE SABE CU$($uA)L ES EL M$($uA)S REPORTADO!"
        Color1 = [System.Drawing.Color]::FromArgb(217, 119, 6)      # Amber Sand
        Color2 = [System.Drawing.Color]::FromArgb(120, 53, 15)      # Terracotta
        AccentColor = [System.Drawing.Color]::FromArgb(254, 240, 138) # Light Yellow
        StickerPrimary = "mapache"; StickerSecondary = "comida"; StickerCorner = "ovni"
        FoodPhoto = ""; ExtraTag = "CRUNCH COSTE$($uN)O"
    },
    @{
        Id = 4; Week = 1; Slug = "post04_tridente_jaibo"
        Badge = "DECRETO OFICIAL DE LA COSTA JAIBA"
        Headline = "EL ESCUADR$($uO)N JAIBO: TRES LEYENDAS"
        Subhead = "UN SOLO TOSTIAGUACHILE VERDE TRADICIONAL"
        Color1 = [System.Drawing.Color]::FromArgb(15, 23, 42)       # Midnight Navy
        Color2 = [System.Drawing.Color]::FromArgb(3, 105, 161)      # Oceanic Cyan
        AccentColor = [System.Drawing.Color]::FromArgb(250, 204, 21) # Golden Rays
        StickerPrimary = "trio"; StickerSecondary = "comida"; StickerCorner = "logo"
        FoodPhoto = ""; ExtraTag = "TRIDENTE REUNIDO"
    },
    @{
        Id = 5; Week = 2; Slug = "post05_ensamble_vivo"
        Badge = "PROTOCOLO DE CALIDAD TOTAL EN TU PUERTA"
        Headline = "$($iQ)POR QU$($uE) LO PREPARAMOS FRENTE A TI?"
        Subhead = "TRANSPARENCIA TOTAL: MARISCO FRESCO Y CRUNCH 100%"
        Color1 = [System.Drawing.Color]::FromArgb(2, 132, 199)      # Arctic Ice Cyan
        Color2 = [System.Drawing.Color]::FromArgb(15, 23, 42)       # Deep Slate
        AccentColor = [System.Drawing.Color]::FromArgb(52, 211, 153) # Mint
        StickerPrimary = "juancho"; StickerSecondary = "comida"; StickerCorner = ""
        FoodPhoto = $foodRedondo; ExtraTag = "CERO DUDAS"
    },
    @{
        Id = 6; Week = 2; Slug = "post06_cadena_frio"
        Badge = "CADENA DE FR$($uI)O CERTIFICADA: 0$($deg)C A 4$($deg)C"
        Headline = "HIELERAS T$($uE)RMICAS GRADO ALIMENTICIO"
        Subhead = "AFUERA 38$($deg)C... ADENTRO EL CAMAR$($uO)N A 2$($deg)C"
        Color1 = [System.Drawing.Color]::FromArgb(3, 105, 161)      # Polar Frost
        Color2 = [System.Drawing.Color]::FromArgb(8, 47, 73)        # Deep Ice Navy
        AccentColor = [System.Drawing.Color]::FromArgb(56, 189, 248) # Cyan Neon
        StickerPrimary = "comida"; StickerSecondary = "juancho"; StickerCorner = "logo"
        FoodPhoto = $foodRedondo; ExtraTag = "INOCUIDAD NOM-251"
    },
    @{
        Id = 7; Week = 2; Slug = "post07_camaron_mariposa"
        Badge = "DEL GOLFO DE M$($uE)XICO A TU PUERTA"
        Headline = "ANATOM$($uI)A DEL CAMAR$($uO)N MARIPOSA"
        Subhead = "~100g DE CAMAR$($uO)N LIMPIO EN CORTE MARIPOSA"
        Color1 = [System.Drawing.Color]::FromArgb(21, 128, 61)      # Lagoon Green
        Color2 = [System.Drawing.Color]::FromArgb(15, 23, 42)       # Dark Navy
        AccentColor = [System.Drawing.Color]::FromArgb(251, 113, 133) # Shrimp Coral
        StickerPrimary = "comida"; StickerSecondary = ""; StickerCorner = "logo"
        FoodPhoto = $foodHero; ExtraTag = "CERO RELLENOS"
    },
    @{
        Id = 8; Week = 2; Slug = "post08_secreto_crunch"
        Badge = "ENSAMBLE AL INSTANTE EN TU DOMICILIO"
        Headline = "TOSTITOS SALSA VERDE: 100% CRUJIENTES"
        Subhead = "$($iE)CERO TOTOPOS REMOJADOS O AGUADOS!"
        Color1 = [System.Drawing.Color]::FromArgb(22, 163, 74)      # Kelly Salsa Verde
        Color2 = [System.Drawing.Color]::FromArgb(6, 78, 59)        # Deep Pine
        AccentColor = [System.Drawing.Color]::FromArgb(253, 224, 71) # Sunflower Gold
        StickerPrimary = "comida"; StickerSecondary = "mapache"; StickerCorner = "logo"
        FoodPhoto = ""; ExtraTag = "CRUNCH INTACTO"
    },
    @{
        Id = 9; Week = 3; Slug = "post09_medicina_resaca"
        Badge = "DOMINGO DE RESURRECCI$($uO)N JAIBA"
        Headline = "$($iE)LA CURA SAGRADA DE LA CRUDA!"
        Subhead = "EL SUERO GASTRON$($uO)MICO DE LA CONURBADA"
        Color1 = [System.Drawing.Color]::FromArgb(185, 28, 28)      # Sunset Fire Red
        Color2 = [System.Drawing.Color]::FromArgb(69, 10, 10)       # Deep Crimson
        AccentColor = [System.Drawing.Color]::FromArgb(254, 240, 138) # Lemon Yellow
        StickerPrimary = "juancho"; StickerSecondary = "comida"; StickerCorner = ""
        FoodPhoto = $foodHero; ExtraTag = "REVIVE AL CA$($uI)DO"
    },
    @{
        Id = 10; Week = 3; Slug = "post10_asmr_tostitos"
        Badge = "EXPERIENCIA SENSORIAL JAIBA"
        Headline = "AUDIO EN TU CABEZA: $($iE)CRUNCH!"
        Subhead = "EL ASMR M$($uA)S DESEADO DE TAMPICO Y MADERO"
        Color1 = [System.Drawing.Color]::FromArgb(24, 24, 27)       # Studio Carbon
        Color2 = [System.Drawing.Color]::FromArgb(9, 9, 11)         # Jet Black
        AccentColor = [System.Drawing.Color]::FromArgb(34, 197, 94)  # Neon Green
        StickerPrimary = "mapache"; StickerSecondary = "comida"; StickerCorner = "logo"
        FoodPhoto = ""; ExtraTag = "SONIDO 100% REAL"
    },
    @{
        Id = 11; Week = 3; Slug = "post11_oro_verde"
        Badge = "ALQUIMIA COSTE$($uN)A ARTESANAL"
        Headline = "ORO VERDE ESMERALDA"
        Subhead = "CHILE SERRANO FRESCO + LIM$($uO)N COLIMA RECI$($uE)N EXPRIMIDO"
        Color1 = [System.Drawing.Color]::FromArgb(20, 83, 45)       # Forest Green
        Color2 = [System.Drawing.Color]::FromArgb(2, 44, 34)        # Deep Emerald
        AccentColor = [System.Drawing.Color]::FromArgb(234, 179, 8)  # Citrus Gold
        StickerPrimary = "ovni"; StickerSecondary = "comida"; StickerCorner = "logo"
        FoodPhoto = $foodHero; ExtraTag = "PICANTE POR NATURALEZA"
    },
    @{
        Id = 12; Week = 3; Slug = "post12_ritual_dominical"
        Badge = "PLAN DOMINICAL OFICIAL EN LA CONURBADA"
        Headline = "EL RITUAL DOMINICAL JAIBO"
        Subhead = "SOF$($uA), CLIMA ENCENDIDO Y TOSTIAGUACHILE A TU PUERTA"
        Color1 = [System.Drawing.Color]::FromArgb(13, 148, 136)     # Warm Lagoon Teal
        Color2 = [System.Drawing.Color]::FromArgb(19, 78, 74)       # Tropical Dark Cyan
        AccentColor = [System.Drawing.Color]::FromArgb(245, 158, 11) # Golden Amber
        StickerPrimary = "juancho"; StickerSecondary = "comida"; StickerCorner = "logo"
        FoodPhoto = $foodRedondo; ExtraTag = "CERO COCINA"
    },
    @{
        Id = 13; Week = 4; Slug = "post13_hieleras_cargadas"
        Badge = "OPERATIVO DE FIN DE SEMANA ACTIVO"
        Headline = "$($iE)HIELERAS CARGADAS Y EN RUTA!"
        Subhead = "COBERTURA TOTAL TAMPICO Y CIUDAD MADERO"
        Color1 = [System.Drawing.Color]::FromArgb(112, 26, 117)     # Night Magenta
        Color2 = [System.Drawing.Color]::FromArgb(15, 23, 42)       # Midnight Navy
        AccentColor = [System.Drawing.Color]::FromArgb(250, 204, 21) # Golden Neon
        StickerPrimary = "trio"; StickerSecondary = "comida"; StickerCorner = "logo"
        FoodPhoto = ""; ExtraTag = "SALIDA DESDE Tampico"
    },
    @{
        Id = 14; Week = 4; Slug = "post14_zonas_horarios"
        Badge = "GU$($uI)A OFICIAL DE REPARTO Y LOG$($uI)STICA"
        Headline = "ZONAS Y HORARIOS OFICIALES"
        Subhead = "S$($uA)BADOS Y DOMINGOS DE Servicio en Rutas Activas"
        Color1 = [System.Drawing.Color]::FromArgb(10, 37, 64)       # Deep Marine Navy
        Color2 = [System.Drawing.Color]::FromArgb(30, 58, 138)      # Royal Indigo
        AccentColor = [System.Drawing.Color]::FromArgb(16, 185, 129) # Mint Emerald
        StickerPrimary = "mapache"; StickerSecondary = "comida"; StickerCorner = "logo"
        FoodPhoto = $foodRedondo; ExtraTag = "RUTAS EN REDES"
    },
    @{
        Id = 15; Week = 4; Slug = "post15_alerta_cupos"
        Badge = "AVISO URGENTE PARA LA COMUNIDAD JAIBA"
        Headline = "$($iE)$($uU)LTIMOS CUPOS DE LA TARDE!"
        Subhead = "MARISCO FRESCO DEL D$($uI)A $($bul) CUANDO SE ACABA SE CERR$($uO)"
        Color1 = [System.Drawing.Color]::FromArgb(153, 27, 27)      # High-Alert Crimson
        Color2 = [System.Drawing.Color]::FromArgb(24, 24, 27)       # Studio Carbon
        AccentColor = [System.Drawing.Color]::FromArgb(253, 224, 71) # Gold Spark
        StickerPrimary = "ovni"; StickerSecondary = "comida"; StickerCorner = "logo"
        FoodPhoto = $foodHero; ExtraTag = "cupos limitados por pedido"
    },
    @{
        Id = 16; Week = 4; Slug = "post16_comunidad_jaiba"
        Badge = "GRACIAS TAMPICO Y CIUDAD MADERO"
        Headline = "EL TOSTIAGUACHILE M$($uA)S REPORTADO"
        Subhead = "ORGULLO Y COMUNIDAD 100% JAIBA $($bul) GRACIAS POR TU PREFERENCIA"
        Color1 = [System.Drawing.Color]::FromArgb(4, 120, 87)       # Royal Emerald
        Color2 = [System.Drawing.Color]::FromArgb(15, 23, 42)       # Midnight Blue
        AccentColor = [System.Drawing.Color]::FromArgb(250, 204, 21) # Gold Prestige
        StickerPrimary = "trio"; StickerSecondary = "comida"; StickerCorner = "logo"
        FoodPhoto = ""; ExtraTag = "FAMILIA LA GARZA"
    }
)

# ==============================================================================
# SUB-RUTINAS DE RENDERIZADO: FEED (1080x1080) Y STORY (1080x1920)
# ==============================================================================

function Render-FeedPiece($item) {
    $bmp = [System.Drawing.Bitmap]::new(1080, 1080, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
    $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality

    $canvasRect = [System.Drawing.Rectangle]::new(0, 0, 1080, 1080)
    $bgBrush = [System.Drawing.Drawing2D.LinearGradientBrush]::new($canvasRect, $item.Color1, $item.Color2, 45.0)
    $g.FillRectangle($bgBrush, $canvasRect)
    $bgBrush.Dispose()

    # Rayos o fondo skyline sutil para alta resolucion y textura comercial
    Draw-SunburstRays $g 540 500 780 18 ([System.Drawing.Color]::FromArgb(22, 255, 255, 255))
    Draw-SkylineAtmosphere $g ([System.Drawing.Rectangle]::new(0, 180, 1080, 520)) 0.28

    # 1. Header Badge Superior (Safe Zone Y=42)
    $badgeRect = [System.Drawing.RectangleF]::new(140, 40, 800, 38)
    $bBadge = [System.Drawing.Drawing2D.LinearGradientBrush]::new($badgeRect, [System.Drawing.Color]::FromArgb(235, 15, 23, 42), [System.Drawing.Color]::FromArgb(240, 2, 6, 23), 0.0)
    $pBadge = [System.Drawing.Pen]::new($item.AccentColor, 2.0)
    Draw-RoundedBox $g $bBadge $pBadge $badgeRect 19 $true
    $bBadge.Dispose(); $pBadge.Dispose()

    $fBadge = [System.Drawing.Font]::new("Segoe UI Black", 11.5, [System.Drawing.FontStyle]::Bold)
    $bWhite = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)
    $g.DrawString($item.Badge, $fBadge, $bWhite, [float]540, [float]59, $sfCenter)

    # 2. Titular Principal (Safe Zone Y=90, ancho controlado <= 980px)
    $fTitle = [System.Drawing.Font]::new("Segoe UI Black", 21.0, [System.Drawing.FontStyle]::Bold)
    $pDark = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(8, 15, 28), 7)
    $pDark.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
    Draw-OutlinedText $g $item.Headline $fTitle $bWhite $pDark 540 108 $sfCenter

    # 3. Subtitulo / Sello de Valor (Y=145)
    $fSub = [System.Drawing.Font]::new("Segoe UI Black", 12.5, [System.Drawing.FontStyle]::Bold)
    $bAccent = [System.Drawing.SolidBrush]::new($item.AccentColor)
    Draw-OutlinedText $g $item.Subhead $fSub $bAccent $pDark 540 148 $sfCenter
    $bAccent.Dispose()

    # 4. Arena Visual Central (Y=185 a Y=740)
    if ($item.FoodPhoto -and (Test-Path $item.FoodPhoto)) {
        # Composicion con fotografia gastronomica macro enmarcada + personajes
        Draw-FramedPhoto $g $item.FoodPhoto 70 200 480 430 24 $item.AccentColor 1.0
        Draw-StickerWithShadow $g $cleanComida 460 215 540 540 -3
        if ($item.StickerPrimary -eq "juancho") {
            Draw-StickerWithShadow $g $juanchoPath 50 440 280 280 4
        } elseif ($item.StickerPrimary -eq "mapache") {
            Draw-StickerWithShadow $g $mapachePath 50 440 270 270 5
        } elseif ($item.StickerPrimary -eq "ovni") {
            Draw-StickerWithShadow $g $ovniPath 740 180 260 260 -5
        }
    } else {
        # Composicion iconica pura con stickers y fondos vibrantes
        if ($item.StickerPrimary -eq "trio") {
            Draw-StickerWithShadow $g $ovniPath 390 175 300 300 0
            Draw-StickerWithShadow $g $juanchoPath 40 330 350 350 -6
            Draw-StickerWithShadow $g $mapachePath 690 330 350 350 6
            Draw-StickerWithShadow $g $cleanComida 270 280 540 540 0
        } elseif ($item.StickerPrimary -eq "ovni") {
            Draw-StickerWithShadow $g $ovniPath 640 180 340 340 4
            Draw-StickerWithShadow $g $cleanComida 190 230 550 550 -2
            Draw-StickerWithShadow $g $mapachePath 50 430 310 310 6
        } elseif ($item.StickerPrimary -eq "juancho") {
            Draw-StickerWithShadow $g $juanchoPath 60 280 380 380 -5
            Draw-StickerWithShadow $g $cleanComida 380 230 550 550 2
        } elseif ($item.StickerPrimary -eq "mapache") {
            Draw-StickerWithShadow $g $mapachePath 660 300 360 360 5
            Draw-StickerWithShadow $g $cleanComida 150 230 550 550 -2
            Draw-StickerWithShadow $g $ovniPath 70 190 260 260 -4
        } else {
            Draw-StickerWithShadow $g $cleanComida 265 220 550 550 0
            Draw-StickerWithShadow $g $mapachePath 60 410 320 320 -4
        }
    }

    # Badge Flotante del Producto
    $popPillRect = [System.Drawing.RectangleF]::new(340, 700, 400, 42)
    $bPop = [System.Drawing.Drawing2D.LinearGradientBrush]::new($popPillRect, [System.Drawing.Color]::FromArgb(240, 22, 163, 74), [System.Drawing.Color]::FromArgb(240, 21, 128, 61), 0.0)
    $pPop = [System.Drawing.Pen]::new([System.Drawing.Color]::White, 2.5)
    Draw-RoundedBox $g $bPop $pPop $popPillRect 21 $true
    $bPop.Dispose(); $pPop.Dispose()
    $fPop = [System.Drawing.Font]::new("Segoe UI Black", 12.0, [System.Drawing.FontStyle]::Bold)
    $g.DrawString("TOSTITOS SALSA VERDE", $fPop, $bWhite, [float]540, [float]721, $sfCenter)
    $fPop.Dispose()

    # Logo oficial en esquina si aplica
    if ($item.StickerCorner -eq "logo") {
        Draw-OfficialLogoBadge $g 930 45 105 ([System.Drawing.Color]::FromArgb(16, 185, 129))
    } elseif ($item.StickerCorner -eq "ovni") {
        Draw-StickerWithShadow $g $ovniPath 840 50 180 180 6
    }

    # 5. Price Pill Estandarizado $170 MXN (Y=760)
    Draw-PricePillComponent $g ([System.Drawing.RectangleF]::new(80, 760, 920, 60)) $item.ExtraTag

    # 6. Tarjeta de Frescura Obligatoria (Y=835)
    Draw-FreshnessCardComponent $g ([System.Drawing.RectangleF]::new(80, 835, 920, 56))

    # 7. Boton de Conversion WhatsApp 833 252 09 88 (Y=908)
    Draw-WhatsAppButtonComponent $g ([System.Drawing.RectangleF]::new(80, 908, 920, 64))

    # 8. Pie de Pagina de Operaciones y Ubicacion Oficial (Y=990 a 1035)
    $fFootA = [System.Drawing.Font]::new("Segoe UI Black", 12.0, [System.Drawing.FontStyle]::Bold)
    $bFootYellow = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(254, 240, 138))
    $footStrA = "ENTREGAS S$($uA)BADOS Y DOMINGOS (Rutas Activas) $($bul) RUTAS ANUNCIADAS EN REDES"
    $g.DrawString($footStrA, $fFootA, $bFootYellow, [float]540, [float]994, $sfCenter)
    $fFootA.Dispose(); $bFootYellow.Dispose()

    $fFootB = [System.Drawing.Font]::new("Segoe UI", 11.0, [System.Drawing.FontStyle]::Bold)
    $bFootGray = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(226, 232, 240))
    $footStrB = "Tampico y Ciudad Madero, Tamaulipas $($bul) Preventa y apartados abiertos toda la semana"
    $g.DrawString($footStrB, $fFootB, $bFootGray, [float]540, [float]1022, $sfCenter)
    $fFootB.Dispose(); $bFootGray.Dispose()

    # Limpieza de recursos GDI+
    $fTitle.Dispose(); $fSub.Dispose(); $fBadge.Dispose()
    $bWhite.Dispose(); $pDark.Dispose()
    $g.Dispose()

    return $bmp
}

function Render-StoryPiece($item) {
    $bmp = [System.Drawing.Bitmap]::new(1080, 1920, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
    $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality

    $canvasRect = [System.Drawing.Rectangle]::new(0, 0, 1080, 1920)
    $bgBrush = [System.Drawing.Drawing2D.LinearGradientBrush]::new($canvasRect, $item.Color1, $item.Color2, 90.0)
    $g.FillRectangle($bgBrush, $canvasRect)
    $bgBrush.Dispose()

    # Atmosfera intermedia Tampico
    Draw-SkylineAtmosphere $g ([System.Drawing.Rectangle]::new(0, 520, 1080, 680)) 0.32

    # 1. Header con Logo y Badge Superior (Safe Zone Y >= 125)
    Draw-OfficialLogoBadge $g 470 120 140 ([System.Drawing.Color]::FromArgb(16, 185, 129))

    # Badge de Horarios
    $tagPill = [System.Drawing.RectangleF]::new(190, 280, 700, 38)
    $bTag = [System.Drawing.Drawing2D.LinearGradientBrush]::new($tagPill, [System.Drawing.Color]::FromArgb(235, 15, 23, 42), [System.Drawing.Color]::FromArgb(240, 2, 6, 23), 0.0)
    $pTag = [System.Drawing.Pen]::new($item.AccentColor, 2.0)
    Draw-RoundedBox $g $bTag $pTag $tagPill 19 $true
    $bTag.Dispose(); $pTag.Dispose()
    $fTag = [System.Drawing.Font]::new("Segoe UI Black", 11.5, [System.Drawing.FontStyle]::Bold)
    $bWhite = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)
    $g.DrawString("TAMPICO Y CIUDAD MADERO $($bul) S$($uA)BADOS Y DOMINGOS", $fTag, $bWhite, [float]540, [float]299, $sfCenter)
    $fTag.Dispose()

    # Titulo de Marca Outlined
    $fBrand = [System.Drawing.Font]::new("Segoe UI Black", 30.0, [System.Drawing.FontStyle]::Bold)
    $pDark8 = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(4, 12, 22), 8)
    $pDark8.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
    Draw-OutlinedText $g "LA GARZA AGUACHILERA" $fBrand $bWhite $pDark8 540 345 $sfCenter
    $fBrand.Dispose()

    # Titulo del Tema
    $fTheme = [System.Drawing.Font]::new("Segoe UI Black", 19.0, [System.Drawing.FontStyle]::Bold)
    $bAccent = [System.Drawing.SolidBrush]::new($item.AccentColor)
    Draw-OutlinedText $g $item.Headline $fTheme $bAccent $pDark8 540 400 $sfCenter
    $fTheme.Dispose(); $bAccent.Dispose()

    # 2. Hero Central & Mascots en Formato Vertical (Y=460 a 1080)
    if ($item.FoodPhoto -and (Test-Path $item.FoodPhoto)) {
        Draw-FramedPhoto $g $item.FoodPhoto 140 460 800 480 28 $item.AccentColor 1.0
        Draw-StickerWithShadow $g $cleanComida 290 680 500 500 -2
        if ($item.StickerPrimary -eq "juancho") {
            Draw-StickerWithShadow $g $juanchoPath 40 820 320 320 -5
        } elseif ($item.StickerPrimary -eq "mapache") {
            Draw-StickerWithShadow $g $mapachePath 720 820 320 320 5
        } elseif ($item.StickerPrimary -eq "ovni") {
            Draw-StickerWithShadow $g $ovniPath 740 450 280 280 6
        }
    } else {
        Draw-StickerWithShadow $g $cleanComida 270 510 540 540 -2
        if ($item.StickerPrimary -eq "trio") {
            Draw-StickerWithShadow $g $ovniPath 730 460 290 290 6
            Draw-StickerWithShadow $g $juanchoPath 30 730 350 350 -5
            Draw-StickerWithShadow $g $mapachePath 710 820 340 340 5
        } elseif ($item.StickerPrimary -eq "ovni") {
            Draw-StickerWithShadow $g $ovniPath 720 460 310 310 6
            Draw-StickerWithShadow $g $mapachePath 40 810 330 330 -5
        } elseif ($item.StickerPrimary -eq "juancho") {
            Draw-StickerWithShadow $g $juanchoPath 40 680 370 370 -5
            Draw-StickerWithShadow $g $mapachePath 720 840 310 310 6
        } else {
            Draw-StickerWithShadow $g $mapachePath 710 740 340 340 5
            Draw-StickerWithShadow $g $juanchoPath 40 820 330 330 -5
        }
    }

    # Patch de la bolsa en Story
    $patchStoryRect = [System.Drawing.RectangleF]::new(340, 1025, 400, 48)
    $bPatch = [System.Drawing.Drawing2D.LinearGradientBrush]::new($patchStoryRect, [System.Drawing.Color]::FromArgb(16, 185, 129), [System.Drawing.Color]::FromArgb(4, 120, 87), 0.0)
    $pPatch = [System.Drawing.Pen]::new([System.Drawing.Color]::White, 3.0)
    Draw-RoundedBox $g $bPatch $pPatch $patchStoryRect 24 $true
    $bPatch.Dispose(); $pPatch.Dispose()
    $fPatch = [System.Drawing.Font]::new("Segoe UI Black", 14.0, [System.Drawing.FontStyle]::Bold)
    $g.DrawString("TOSTITOS SALSA VERDE", $fPatch, $bWhite, [float]540, [float]1049, $sfCenter)
    $fPatch.Dispose()

    # 3. Price Banner Estandarizado ($170 MXN) (Y=1095 a 1175)
    $priceStoryRect = [System.Drawing.RectangleF]::new(90, 1095, 900, 76)
    $bPriceS = [System.Drawing.Drawing2D.LinearGradientBrush]::new($priceStoryRect, [System.Drawing.Color]::FromArgb(249, 115, 22), [System.Drawing.Color]::FromArgb(234, 88, 12), 0.0)
    $pPriceS = [System.Drawing.Pen]::new([System.Drawing.Color]::White, 3.5)
    Draw-RoundedBox $g $bPriceS $pPriceS $priceStoryRect 38 $true
    $bPriceS.Dispose(); $pPriceS.Dispose()

    $fPriceS = [System.Drawing.Font]::new("Segoe UI Black", 21.0, [System.Drawing.FontStyle]::Bold)
    $priceStr = "$($script:star) `$170 MXN LA BOLSA $($script:bul) ~100g CAMAR$($script:uO)N $($script:star)"
    Draw-OutlinedText $g $priceStr $fPriceS $bWhite $pDark8 540 1133 $sfCenter
    $fPriceS.Dispose()

    # 4. Tarjeta de Frescura Obligatoria en Story (Y=1190 a 1345)
    $freshStoryRect = [System.Drawing.RectangleF]::new(90, 1190, 900, 150)
    $bFreshS = [System.Drawing.Drawing2D.LinearGradientBrush]::new($freshStoryRect, [System.Drawing.Color]::FromArgb(245, 10, 24, 42), [System.Drawing.Color]::FromArgb(248, 6, 16, 30), 90.0)
    $pFreshS = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(254, 240, 138), 3.0)
    Draw-RoundedBox $g $bFreshS $pFreshS $freshStoryRect 26 $true
    $bFreshS.Dispose(); $pFreshS.Dispose()

    $sealStoryRect = [System.Drawing.RectangleF]::new(290, 1205, 500, 30)
    $bSealS = [System.Drawing.Drawing2D.LinearGradientBrush]::new($sealStoryRect, [System.Drawing.Color]::FromArgb(16, 185, 129), [System.Drawing.Color]::FromArgb(5, 150, 105), 0.0)
    Draw-RoundedBox $g $bSealS $null $sealStoryRect 15 $false
    $bSealS.Dispose()
    $fSealS = [System.Drawing.Font]::new("Segoe UI Black", 10.5, [System.Drawing.FontStyle]::Bold)
    $g.DrawString("SELLO OFICIAL DE FRESCURA EN TU PUERTA (0$($deg)C - 4$($deg)C)", $fSealS, $bWhite, [float]540, [float]1220, $sfCenter)
    $fSealS.Dispose()

    $fFreshA = [System.Drawing.Font]::new("Segoe UI Black", 19.0, [System.Drawing.FontStyle]::Bold)
    $bYellow = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(254, 240, 138))
    $g.DrawString("$($script:qL)El producto es preparado frente a usted", $fFreshA, $bYellow, [float]540, [float]1262, $sfCenter)
    $g.DrawString("para corroborar su frescura$($script:qR)", $fFreshA, $bWhite, [float]540, [float]1302, $sfCenter)
    $fFreshA.Dispose()

    # 5. Caja de Atributos Gastronomicos (Y=1360 a 1495)
    $bulletRect = [System.Drawing.RectangleF]::new(90, 1360, 900, 140)
    $bBullet = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(220, 6, 16, 28))
    $pBullet = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(51, 65, 85), 2.0)
    Draw-RoundedBox $g $bBullet $pBullet $bulletRect 22 $true
    $bBullet.Dispose(); $pBullet.Dispose()

    $fBul = [System.Drawing.Font]::new("Segoe UI", 14.5, [System.Drawing.FontStyle]::Bold)
    $bLime = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(163, 230, 53))
    $bGray = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(226, 232, 240))
    $g.DrawString("$($script:bul) ~100g Camar$($script:lO)n fresco del Golfo en corte mariposa", $fBul, $bLime, [float]130, [float]1378)
    $g.DrawString("$($script:bul) Tostitos Salsa Verde (preparado al instante, $($script:iE)100% crujiente!)", $fBul, $bGray, [float]130, [float]1412)
    $g.DrawString("$($script:bul) Salsa verde artesanal con chile serrano y lim$($script:lO)n Colima", $fBul, $bGray, [float]130, [float]1446)
    $fBul.Dispose(); $bLime.Dispose(); $bGray.Dispose()

    # 6. Boton WhatsApp CTA Grande (Y=1518 a 1638)
    $waStoryRect = [System.Drawing.RectangleF]::new(90, 1518, 900, 120)
    $bWaS = [System.Drawing.Drawing2D.LinearGradientBrush]::new($waStoryRect, [System.Drawing.Color]::FromArgb(37, 211, 102), [System.Drawing.Color]::FromArgb(18, 140, 62), 90.0)
    $pWaS = [System.Drawing.Pen]::new([System.Drawing.Color]::White, 3.5)
    Draw-RoundedBox $g $bWaS $pWaS $waStoryRect 50 $true
    $bWaS.Dispose(); $pWaS.Dispose()

    $fWaA = [System.Drawing.Font]::new("Segoe UI Black", 16.0, [System.Drawing.FontStyle]::Bold)
    $fWaB = [System.Drawing.Font]::new("Segoe UI Black", 34.0, [System.Drawing.FontStyle]::Bold)
    Draw-OutlinedText $g "PEDIDOS Y APARTADOS POR WHATSAPP" $fWaA $bWhite $pDark8 540 1548 $sfCenter
    Draw-OutlinedText $g "833 252 09 88" $fWaB $bYellow $pDark8 540 1598 $sfCenter
    $fWaA.Dispose(); $fWaB.Dispose()

    # 7. Safe Footer (Y=1660 a 1705, seguro para TikTok/Stories)
    $fFootS1 = [System.Drawing.Font]::new("Segoe UI Black", 12.0, [System.Drawing.FontStyle]::Bold)
    $bYellowS = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(254, 240, 138))
    $g.DrawString("S$($uA)BADOS Y DOMINGOS (Rutas Activas) $($bul) RUTAS ANUNCIADAS EN REDES", $fFootS1, $bYellowS, [float]540, [float]1668, $sfCenter)
    $fFootS1.Dispose(); $bYellowS.Dispose()

    $fFootS2 = [System.Drawing.Font]::new("Segoe UI", 11.0, [System.Drawing.FontStyle]::Bold)
    $bGrayS = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(203, 213, 225))
    $g.DrawString("Tampico y Ciudad Madero, Tamaulipas $($bul) Cobertura Tampico y Ciudad Madero", $fFootS2, $bGrayS, [float]540, [float]1695, $sfCenter)
    $fFootS2.Dispose(); $bGrayS.Dispose()

    # Limpieza
    $bWhite.Dispose(); $bYellow.Dispose(); $pDark8.Dispose()
    $g.Dispose()

    return $bmp
}

# ==============================================================================
# BUCLE PRINCIPAL DE GENERACION Y VALIDACION
# ==============================================================================

Write-Host '=================================================================' -ForegroundColor Cyan
Write-Host '  LA GARZA AGUACHILERA -- GENERADOR DE CATALOGO MENSUAL (16 PIEZAS)' -ForegroundColor Yellow
Write-Host '  Estandar Comercial Pop Franquicia * Feed 1080x1080 y Story 1080x1920' -ForegroundColor Cyan
Write-Host '=================================================================' -ForegroundColor Cyan

$startTime = Get-Date
$renderedCount = 0

foreach ($item in $catalogMeta) {
    if ($Week -gt 0 -and $item.Week -ne $Week) { continue }
    if ($Piece -gt 0 -and $item.Id -ne $Piece) { continue }

    Write-Host "Renderizando Pieza $($item.Id)/16: $($item.Slug) (Semana $($item.Week))..." -ForegroundColor Cyan

    $bmpFeed = Render-FeedPiece $item
    $bmpStory = Render-StoryPiece $item

    Save-PostArtefacts $bmpFeed $bmpStory $item.Slug $item.Week

    $bmpFeed.Dispose()
    $bmpStory.Dispose()
    $renderedCount++
}

$elapsed = (Get-Date) - $startTime
Write-Host "`n=================================================================" -ForegroundColor Cyan
Write-Host "  PROCESO COMPLETADO: $renderedCount piezas procesadas en $([math]::Round($elapsed.TotalSeconds, 2)) segundos." -ForegroundColor Green
Write-Host "=================================================================" -ForegroundColor Cyan

# ==============================================================================
# AUDITORIA PROGRAMATICA POST-GENERACION
# ==============================================================================
Write-Host "`nEjecutando verificacion de integridad de archivos generados..." -ForegroundColor Yellow
$auditErrors = 0

foreach ($item in $catalogMeta) {
    if ($Week -gt 0 -and $item.Week -ne $Week) { continue }
    if ($Piece -gt 0 -and $item.Id -ne $Piece) { continue }

    $pathsToCheck = @(
        "$outPosts\$($item.Slug).png",
        "$outPosts\$($item.Slug)_story.png",
        "$outMes\semana$($item.Week)\$($item.Slug).png",
        "$outMes\semana$($item.Week)\$($item.Slug)_story.png"
    )

    foreach ($p in $pathsToCheck) {
        if (-not (Test-Path $p)) {
            Write-Host " [ERROR FATAL] Archivo ausente: $p" -ForegroundColor Red
            $auditErrors++
            continue
        }

        $fi = Get-Item $p
        if ($fi.Length -lt 500 * 1024) {
            Write-Host " [ERROR PESO] Archivo pesa $([math]::Round($fi.Length/1024, 1)) KB (< 500 KB requerido): $p" -ForegroundColor Red
            $auditErrors++
        }

        try {
            $img = [System.Drawing.Image]::FromFile($p)
            $isFeed = $p -notmatch '_story\.png$'
            $expW = 1080
            $expH = if ($isFeed) { 1080 } else { 1920 }

            if ($img.Width -ne $expW -or $img.Height -ne $expH) {
                Write-Host " [ERROR DIMENSION] $p -> $($img.Width)x$($img.Height) (Esperado: ${expW}x${expH})" -ForegroundColor Red
                $auditErrors++
            }
            if ($img.PixelFormat.ToString() -ne 'Format32bppArgb') {
                Write-Host " [ERROR FORMATO] $p -> $($img.PixelFormat) (Esperado: Format32bppArgb)" -ForegroundColor Red
                $auditErrors++
            }
            $img.Dispose()
        } catch {
            Write-Host (" [ERROR CORRUPCION] No se pudo cargar imagen " + $p + ": " + $_.Exception.Message) -ForegroundColor Red
            $auditErrors++
        }
    }
}

if ($auditErrors -eq 0) {
    Write-Host "`n>>> [VERIFICACION EXITOSA] Todas las imagenes cumplen con 1080p, 32bpp ARGB y peso >= 500 KB <<<" -ForegroundColor Green
    exit 0
} else {
    Write-Host "`n>>> [FALLO DE AUDITORIA] Se detectaron $auditErrors inconformidades <<<" -ForegroundColor Red
    exit 1
}
