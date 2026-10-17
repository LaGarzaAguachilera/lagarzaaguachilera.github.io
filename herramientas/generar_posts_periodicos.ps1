Add-Type -AssemblyName System.Drawing

$rootDir = "d:\AG\la garza aguachilera"
$outDir1 = "d:\AG\la garza aguachilera\contenido_redes\posts_periodicos"
$outDir2 = "d:\AG\la garza aguachilera\contenido_redes\campana_periodica"

foreach ($d in @($outDir1, $outDir2)) {
    if (-not (Test-Path $d)) { New-Item -ItemType Directory -Path $d -Force | Out-Null }
}

$logoPath    = "$rootDir\La garza aguachilera.jpeg"
$foodRedondo = "$rootDir\tostiaguachile_verde_redondo.jpg"
$foodHero    = "$rootDir\aguachile_verde_hero.jpg"
$cleanComida = "$rootDir\clean_comida.png"
$juanchoPath = "$rootDir\clean_juancho.png"
$ovniPath    = "$rootDir\clean_ovni.png"
$mapachePath = "$rootDir\clean_mapache.png"
$skylinePath = "$rootDir\herramientas\portada_bg_tampico_skyline_1792107773833.jpg"

# Case-Distinct Unicode Safe Characters for PowerShell 5.1
$uA = [char]0x00C1; $uE = [char]0x00C9; $uI = [char]0x00CD; $uO = [char]0x00D3; $uU = [char]0x00DA; $uN = [char]0x00D1
$lA = [char]0x00E1; $lE = [char]0x00E9; $lI = [char]0x00ED; $lO = [char]0x00F3; $lU = [char]0x00FA; $lN = [char]0x00F1
$iE = [char]0x00A1; $iQ = [char]0x00BF; $deg = [char]0x00B0; $bul = [char]0x2022; $star = [char]0x2605

# ==============================================================================
# HELPER FUNCTIONS: NATIONAL FRANCHISE MULTI-LAYER ENGINE
# ==============================================================================
function Save-MultiPath([System.Drawing.Bitmap]$bmp, [string]$fileName) {
    $bmp.Save("$rootDir\$fileName", [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Save("$outDir1\$fileName", [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Save("$outDir2\$fileName", [System.Drawing.Imaging.ImageFormat]::Png)
}

function Draw-StickerWithShadow([System.Drawing.Graphics]$g, [string]$imgPath, [float]$x, [float]$y, [float]$w, [float]$h, [float]$angle = 0) {
    if (-not (Test-Path $imgPath)) { return }
    $img = [System.Drawing.Image]::FromFile($imgPath)
    $cx = $x + $w / 2.0
    $cy = $y + $h / 2.0

    # Tier 1: Soft Ambient Occlusion Bloom (larger spread, low alpha)
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

    # Tier 2: Crisp Contact Drop Shadow (tighter offset, higher alpha)
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

    # Tier 3: Crisp Sticker Render
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
        # Soft ambient shadow pass
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

        # Contact shadow pass
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

function Draw-Sunburst([System.Drawing.Graphics]$g, [float]$cx, [float]$cy, [float]$radius, [int]$rays, [System.Drawing.Color]$rayColor) {
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

function Draw-OfficialLogoBadge([System.Drawing.Graphics]$g, [int]$x, [int]$y, [int]$size, [System.Drawing.Color]$ringColor) {
    if (-not (Test-Path $logoPath)) { return }
    $logoImg = [System.Drawing.Image]::FromFile($logoPath)
    
    # Ambient shadow
    $shBrush1 = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(70, 0, 0, 0))
    $g.FillEllipse($shBrush1, $x - 2, $y + 8, $size + 12, $size + 12)
    $shBrush1.Dispose()

    # Contact shadow
    $shBrush2 = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(150, 0, 0, 0))
    $g.FillEllipse($shBrush2, $x - 3, $y + 4, $size + 8, $size + 8)
    $shBrush2.Dispose()

    $wBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)
    $g.FillEllipse($wBrush, $x - 5, $y - 5, $size + 10, $size + 10)
    $wBrush.Dispose()

    $clip = [System.Drawing.Drawing2D.GraphicsPath]::new()
    $clip.AddEllipse($x, $y, $size, $size)
    $g.SetClip($clip)
    $g.DrawImage($logoImg, $x, $y, $size, $size)
    $g.ResetClip()
    $clip.Dispose()

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

$sfCenter = [System.Drawing.StringFormat]::new()
$sfCenter.Alignment = [System.Drawing.StringAlignment]::Center
$sfCenter.LineAlignment = [System.Drawing.StringAlignment]::Center

$sfLeft = [System.Drawing.StringFormat]::new()
$sfLeft.Alignment = [System.Drawing.StringAlignment]::Near
$sfLeft.LineAlignment = [System.Drawing.StringAlignment]::Center

# Shared Brushes & Pens
$bWhite   = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)
$bYellow  = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(254, 240, 138))
$bGold    = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(250, 204, 21))
$bLime    = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(163, 230, 53))
$bMint    = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(52, 211, 153))
$bCyan    = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(56, 189, 248))
$bCoral   = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(251, 113, 133))
$bOrange  = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(249, 115, 22))
$bDark    = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(245, 9, 20, 34))
$bCream   = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(254, 252, 232))
$bNavyTxt = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(15, 23, 42))
$bWa      = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(22, 163, 74))

$pOutline8 = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(8, 15, 28), 8)
$pOutline8.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
$pOutline6 = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(8, 15, 28), 6)
$pOutline6.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
$pWhite4   = [System.Drawing.Pen]::new([System.Drawing.Color]::White, 4)
$pYellow3  = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(250, 204, 21), 3.5)
$pDark4    = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(15, 23, 42), 4)

# Fonts (Segoe UI Black & Segoe UI Bold carefully sized for 100% Safe Zones)
$fBlack28 = [System.Drawing.Font]::new("Segoe UI Black", 26.5, [System.Drawing.FontStyle]::Bold)
$fBlack26 = [System.Drawing.Font]::new("Segoe UI Black", 24.5, [System.Drawing.FontStyle]::Bold)
$fBlack24 = [System.Drawing.Font]::new("Segoe UI Black", 22.5, [System.Drawing.FontStyle]::Bold)
$fBlack22 = [System.Drawing.Font]::new("Segoe UI Black", 20.5, [System.Drawing.FontStyle]::Bold)
$fBlack20 = [System.Drawing.Font]::new("Segoe UI Black", 18.5, [System.Drawing.FontStyle]::Bold)
$fBlack18 = [System.Drawing.Font]::new("Segoe UI Black", 17.0, [System.Drawing.FontStyle]::Bold)
$fBlack16 = [System.Drawing.Font]::new("Segoe UI Black", 15.0, [System.Drawing.FontStyle]::Bold)
$fBlack14 = [System.Drawing.Font]::new("Segoe UI Black", 13.0, [System.Drawing.FontStyle]::Bold)
$fBlack13 = [System.Drawing.Font]::new("Segoe UI Black", 12.2, [System.Drawing.FontStyle]::Bold)
$fBlack12 = [System.Drawing.Font]::new("Segoe UI Black", 11.5, [System.Drawing.FontStyle]::Bold)
$fBold15  = [System.Drawing.Font]::new("Segoe UI", 15.0, [System.Drawing.FontStyle]::Bold)

$canvasRect = [System.Drawing.Rectangle]::new(0, 0, 1080, 1080)

# ==============================================================================
# POST 1 (DIA 1 - LUNES): PALETA "JUNGLA TROPICAL Y MANGO" (ESMERALDA / NARANJA POP)
# ==============================================================================
$bmp1 = [System.Drawing.Bitmap]::new(1080, 1080, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g1 = [System.Drawing.Graphics]::FromImage($bmp1)
$g1.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$g1.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g1.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$g1.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

$bg1 = [System.Drawing.Drawing2D.LinearGradientBrush]::new($canvasRect, [System.Drawing.Color]::FromArgb(4, 120, 87), [System.Drawing.Color]::FromArgb(6, 78, 59), 45.0)
$g1.FillRectangle($bg1, $canvasRect)
$bg1.Dispose()
Draw-Sunburst $g1 540 380 900 18 ([System.Drawing.Color]::FromArgb(30, 163, 230, 53))

# Top Studio Vignette
$vign1 = [System.Drawing.Drawing2D.LinearGradientBrush]::new([System.Drawing.Rectangle]::new(0, 0, 1080, 140), [System.Drawing.Color]::FromArgb(120, 4, 30, 20), [System.Drawing.Color]::FromArgb(0, 4, 30, 20), 90.0)
$g1.FillRectangle($vign1, 0, 0, 1080, 140)
$vign1.Dispose()

Draw-OfficialLogoBadge $g1 45 25 115 ([System.Drawing.Color]::FromArgb(250, 204, 21))
$pillTop1 = [System.Drawing.RectangleF]::new(180, 32, 845, 42)
$bMango = [System.Drawing.Drawing2D.LinearGradientBrush]::new($pillTop1, [System.Drawing.Color]::FromArgb(249, 115, 22), [System.Drawing.Color]::FromArgb(217, 119, 6), 0.0)
Draw-RoundedBox $g1 $bMango $pWhite4 $pillTop1 21 $true
$g1.DrawString("LUNES DE ANTOJO JAIBO $bul LA GARZA AGUACHILERA", $fBlack16, $bWhite, [float]602, [float]53, $sfCenter)

Draw-OutlinedText $g1 "${iE}EL VERDADERO SABOR COSTE${uN}O!" $fBlack26 $bYellow $pOutline8 602 108 $sfCenter
Draw-OutlinedText $g1 "TOSTIAGUACHILE VERDE TRADICIONAL" $fBlack20 $bWhite $pOutline6 602 152 $sfCenter

Draw-FramedPhoto $g1 $foodRedondo 55 195 555 440 28 ([System.Drawing.Color]::FromArgb(250, 204, 21)) 1.0

$priceBadge1 = [System.Drawing.RectangleF]::new(75, 565, 360, 52)
$bPriceBadge1 = [System.Drawing.Drawing2D.LinearGradientBrush]::new($priceBadge1, [System.Drawing.Color]::FromArgb(249, 115, 22), [System.Drawing.Color]::FromArgb(234, 88, 12), 0.0)
Draw-RoundedBox $g1 $bPriceBadge1 $pWhite4 $priceBadge1 24 $true
$g1.DrawString("$star `$150 MXN $bul ~100g CAMAR${uO}N $star", $fBlack14, $bWhite, [float]255, [float]591, $sfCenter)

Draw-StickerWithShadow $g1 $cleanComida 565 180 285 285 -5
Draw-StickerWithShadow $g1 $juanchoPath 715 320 330 330 4
Draw-StickerWithShadow $g1 $ovniPath 855 165 180 180 -8

$jBub1 = [System.Drawing.RectangleF]::new(665, 610, 360, 44)
Draw-RoundedBox $g1 $bYellow $pDark4 $jBub1 22 $true
$g1.DrawString("JUANCHO: ${iE}BIEN REPORTADO!", $fBlack14, $bNavyTxt, [float]845, [float]632, $sfCenter)

$specRect1 = [System.Drawing.RectangleF]::new(55, 675, 970, 62)
Draw-RoundedBox $g1 $bCream $pDark4 $specRect1 20 $true
$g1.DrawString("CON TOSTITOS SALSA VERDE $bul CAMAR${uO}N MARIPOSA $bul PICANTE POR NATURALEZA", $fBlack14, $bNavyTxt, [float]540, [float]706, $sfCenter)

$freshRect1 = [System.Drawing.RectangleF]::new(55, 755, 970, 115)
Draw-RoundedBox $g1 $bDark $pYellow3 $freshRect1 24 $true
$g1.DrawString("SELLO DE FRESCURA EN TU PUERTA (HIELERA 0${deg}C-4${deg}C Y MESA):", $fBlack14, $bLime, [float]540, [float]788, $sfCenter)
$g1.DrawString("El producto es preparado frente a usted para corroborar su frescura", $fBlack18, $bYellow, [float]540, [float]832, $sfCenter)

$waRect1 = [System.Drawing.RectangleF]::new(90, 892, 900, 92)
$bWaG1 = [System.Drawing.Drawing2D.LinearGradientBrush]::new($waRect1, [System.Drawing.Color]::FromArgb(249, 115, 22), [System.Drawing.Color]::FromArgb(217, 119, 6), 90.0)
Draw-RoundedBox $g1 $bWaG1 $pWhite4 $waRect1 45 $true
Draw-OutlinedText $g1 "APARTA TU BOLSA: 833 252 09 88" $fBlack24 $bWhite $pOutline6 540 938 $sfCenter

$g1.DrawString("Colonia Flores, Tampico, Tamaulipas $bul Cupo m${lA}x: 75 bolsas por tanda", $fBlack12, $bYellow, [float]540, [float]1030, $sfCenter)

Save-MultiPath $bmp1 "post1_antojo_lunes.png"
$g1.Dispose(); $bmp1.Dispose()
Write-Host "Post 1 (Jungla Tropical y Mango) generado!"

# ==============================================================================
# POST 2 (DIA 3 - MIERCOLES): PALETA "ABDUCCION GALACTICA MIRAMAR" (VIOLETA NEON / LIMA ACIDO)
# ==============================================================================
$bmp2 = [System.Drawing.Bitmap]::new(1080, 1080, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g2 = [System.Drawing.Graphics]::FromImage($bmp2)
$g2.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$g2.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g2.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$g2.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

$bg2 = [System.Drawing.Drawing2D.LinearGradientBrush]::new($canvasRect, [System.Drawing.Color]::FromArgb(59, 7, 100), [System.Drawing.Color]::FromArgb(17, 24, 39), 90.0)
$g2.FillRectangle($bg2, $canvasRect)
$bg2.Dispose()
Draw-Sunburst $g2 540 420 950 20 ([System.Drawing.Color]::FromArgb(25, 217, 70, 239))

$beamPts = @(
    [System.Drawing.PointF]::new(460, 260),
    [System.Drawing.PointF]::new(620, 260),
    [System.Drawing.PointF]::new(860, 680),
    [System.Drawing.PointF]::new(220, 680)
)
$bBeam = [System.Drawing.Drawing2D.LinearGradientBrush]::new([System.Drawing.PointF]::new(540, 260), [System.Drawing.PointF]::new(540, 680), [System.Drawing.Color]::FromArgb(160, 163, 230, 53), [System.Drawing.Color]::FromArgb(15, 163, 230, 53))
$g2.FillPolygon($bBeam, $beamPts)
$bBeam.Dispose()

Draw-OfficialLogoBadge $g2 45 25 115 ([System.Drawing.Color]::FromArgb(163, 230, 53))
$pillTop2 = [System.Drawing.RectangleF]::new(180, 30, 845, 42)
$bFuchsia = [System.Drawing.Drawing2D.LinearGradientBrush]::new($pillTop2, [System.Drawing.Color]::FromArgb(192, 38, 211), [System.Drawing.Color]::FromArgb(147, 22, 163), 0.0)
Draw-RoundedBox $g2 $bFuchsia $pWhite4 $pillTop2 21 $true
$g2.DrawString("EXPEDIENTE SECRETO $bul BASE ALIEN${uI}GENA DE PLAYA MIRAMAR", $fBlack14, $bWhite, [float]602, [float]51, $sfCenter)

Draw-OutlinedText $g2 "${iQ}PROTEGEN A TAMPICO DE HURACANES" $fBlack22 $bLime $pOutline8 602 105 $sfCenter
Draw-OutlinedText $g2 "O VIENEN POR EL TOSTIAGUACHILE?" $fBlack22 $bWhite $pOutline8 602 150 $sfCenter

Draw-StickerWithShadow $g2 $ovniPath 350 175 370 370 -4
Draw-StickerWithShadow $g2 $cleanComida 395 415 295 295 6
Draw-StickerWithShadow $g2 $mapachePath 65 375 275 275 -8
Draw-StickerWithShadow $g2 $juanchoPath 725 365 295 295 7

$ufoBub2 = [System.Drawing.RectangleF]::new(650, 215, 365, 46)
Draw-RoundedBox $g2 $bYellow $pDark4 $ufoBub2 22 $true
$g2.DrawString("${iE}ABDUCIDOS POR EL SABOR!", $fBlack14, $bNavyTxt, [float]832, [float]238, $sfCenter)

$mapBub2 = [System.Drawing.RectangleF]::new(55, 635, 340, 44)
$bOrangeG = [System.Drawing.Drawing2D.LinearGradientBrush]::new($mapBub2, [System.Drawing.Color]::FromArgb(249, 115, 22), [System.Drawing.Color]::FromArgb(217, 119, 6), 0.0)
Draw-RoundedBox $g2 $bOrangeG $pWhite4 $mapBub2 22 $true
$g2.DrawString("${iE}NO SE LLEVEN MI BOLSA!", $fBlack12, $bWhite, [float]225, [float]657, $sfCenter)

$cardRect2 = [System.Drawing.RectangleF]::new(55, 700, 970, 170)
$bPurpleDark = [System.Drawing.Drawing2D.LinearGradientBrush]::new($cardRect2, [System.Drawing.Color]::FromArgb(245, 30, 10, 60), [System.Drawing.Color]::FromArgb(248, 17, 24, 39), 90.0)
Draw-RoundedBox $g2 $bPurpleDark $pYellow3 $cardRect2 26 $true
$g2.DrawString("SABOR DE OTRA GALAXIA $bul `$150 MXN LA BOLSA BIEN REPORTADA", $fBlack18, $bLime, [float]540, [float]738, $sfCenter)
$g2.DrawString("~100g Camar${lO}n Mariposa $bul Con Tostitos Salsa Verde $bul Lim${lO}n y Serrano", $fBlack16, $bWhite, [float]540, [float]782, $sfCenter)
$g2.DrawString("El producto es preparado frente a usted para corroborar su frescura", $fBlack18, $bYellow, [float]540, [float]830, $sfCenter)

$waRect2 = [System.Drawing.RectangleF]::new(85, 892, 910, 92)
$bWaG2 = [System.Drawing.Drawing2D.LinearGradientBrush]::new($waRect2, [System.Drawing.Color]::FromArgb(37, 211, 102), [System.Drawing.Color]::FromArgb(18, 140, 62), 90.0)
Draw-RoundedBox $g2 $bWaG2 $pWhite4 $waRect2 45 $true
Draw-OutlinedText $g2 "APARTA ANTES DE LA ABDUCCI${uO}N: 833 252 09 88" $fBlack20 $bWhite $pOutline6 540 938 $sfCenter

$g2.DrawString("Tampico y Cd. Madero $bul M${lA}ximo 75 bolsas por tanda cada fin de semana", $fBlack12, $bLime, [float]540, [float]1030, $sfCenter)

Save-MultiPath $bmp2 "post2_meme_ovni.png"
$g2.Dispose(); $bmp2.Dispose()
Write-Host "Post 2 (Abduccion Galactica Violeta) generado!"

# ==============================================================================
# POST 4 (DIA 7 - DOMINGO): PALETA "ATARDECER EN MIRAMAR / FUEGO REVIVIDOR" (CORAL / NARANJA / ORO)
# ==============================================================================
$bmp4 = [System.Drawing.Bitmap]::new(1080, 1080, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g4 = [System.Drawing.Graphics]::FromImage($bmp4)
$g4.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$g4.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g4.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$g4.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

$bg4 = [System.Drawing.Drawing2D.LinearGradientBrush]::new($canvasRect, [System.Drawing.Color]::FromArgb(185, 28, 28), [System.Drawing.Color]::FromArgb(217, 119, 6), 90.0)
$g4.FillRectangle($bg4, $canvasRect)
$bg4.Dispose()
Draw-Sunburst $g4 540 360 950 16 ([System.Drawing.Color]::FromArgb(40, 254, 240, 138))

Draw-OfficialLogoBadge $g4 45 25 115 ([System.Drawing.Color]::FromArgb(254, 240, 138))
$pillTop4 = [System.Drawing.RectangleF]::new(180, 30, 845, 42)
$bCrimson = [System.Drawing.Drawing2D.LinearGradientBrush]::new($pillTop4, [System.Drawing.Color]::FromArgb(159, 18, 57), [System.Drawing.Color]::FromArgb(136, 19, 55), 0.0)
Draw-RoundedBox $g4 $bCrimson $pWhite4 $pillTop4 21 $true
$g4.DrawString("DOMINGO DE RESURRECCI${uO}N EN TAMPICO Y CIUDAD MADERO", $fBlack14, $bYellow, [float]602, [float]51, $sfCenter)

Draw-OutlinedText $g4 "${iE}LA CURA SAGRADA DE LA CRUDA!" $fBlack26 $bWhite $pOutline8 602 106 $sfCenter
Draw-OutlinedText $g4 "ACIDITO, PICOSITO Y BIEN CRUJIENTE" $fBlack20 $bYellow $pOutline6 602 152 $sfCenter

Draw-FramedPhoto $g4 $foodHero 55 195 585 430 28 ([System.Drawing.Color]::FromArgb(255, 255, 255)) 0.63
Draw-StickerWithShadow $g4 $cleanComida 605 180 310 310 5
Draw-StickerWithShadow $g4 $juanchoPath 745 360 290 290 -4
Draw-StickerWithShadow $g4 $mapachePath 55 445 225 225 6

$spicePill4 = [System.Drawing.RectangleF]::new(285, 575, 465, 50)
$bSpiceG = [System.Drawing.Drawing2D.LinearGradientBrush]::new($spicePill4, [System.Drawing.Color]::FromArgb(254, 240, 138), [System.Drawing.Color]::FromArgb(250, 204, 21), 0.0)
Draw-RoundedBox $g4 $bSpiceG $pDark4 $spicePill4 24 $true
$g4.DrawString("PICANTE POR NATURALEZA $bul `$150 MXN", $fBlack14, $bNavyTxt, [float]517, [float]600, $sfCenter)

$strip4 = [System.Drawing.RectangleF]::new(55, 655, 970, 62)
Draw-RoundedBox $g4 $bCream $pDark4 $strip4 20 $true
$g4.DrawString("LIM${uO}N RECI${uE}N EXPRIMIDO $bul CHILE SERRANO $bul ~100g CAMAR${uO}N $bul TOSTITOS SALSA VERDE", $fBlack12, $bNavyTxt, [float]540, [float]686, $sfCenter)

$freshRect4 = [System.Drawing.RectangleF]::new(55, 738, 970, 125)
$bDarkCard4 = [System.Drawing.Drawing2D.LinearGradientBrush]::new($freshRect4, [System.Drawing.Color]::FromArgb(245, 9, 20, 34), [System.Drawing.Color]::FromArgb(248, 4, 10, 18), 90.0)
Draw-RoundedBox $g4 $bDarkCard4 $pWhite4 $freshRect4 24 $true
$g4.DrawString("GARANT${uI}A DE FRESCURA EN DOMICILIO (CON MESA Y HIELERA 0${deg}C-4${deg}C):", $fBlack14, $bMint, [float]540, [float]774, $sfCenter)
$g4.DrawString("El producto es preparado frente a usted para corroborar su frescura", $fBlack18, $bYellow, [float]540, [float]822, $sfCenter)

$waRect4 = [System.Drawing.RectangleF]::new(85, 888, 910, 95)
$bWaG4 = [System.Drawing.Drawing2D.LinearGradientBrush]::new($waRect4, [System.Drawing.Color]::FromArgb(37, 211, 102), [System.Drawing.Color]::FromArgb(18, 140, 62), 90.0)
Draw-RoundedBox $g4 $bWaG4 $pWhite4 $waRect4 46 $true
Draw-OutlinedText $g4 "${iE}REVIVE HOY! PIDE AL: 833 252 09 88" $fBlack24 $bWhite $pOutline6 540 935 $sfCenter

$g4.DrawString("Entregas activas a${lU}n con lluvia (cargo extra seg${lU}n distancia) $bul Colonia Flores, Tampico, Tamaulipas", $fBlack12, $bWhite, [float]540, [float]1030, $sfCenter)

Save-MultiPath $bmp4 "post4_cura_domingo.png"
$g4.Dispose(); $bmp4.Dispose()
Write-Host "Post 4 (Atardecer Fuego Revividor) generado!"

# ==============================================================================
# POST 5 (DIA 9 - MARTES): PALETA "HIELO ARTICO Y CADENA DE FRIO 0C-4C" (CIAN GLACIAR / AZUL REY)
# ==============================================================================
$bmp5 = [System.Drawing.Bitmap]::new(1080, 1080, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g5 = [System.Drawing.Graphics]::FromImage($bmp5)
$g5.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$g5.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g5.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$g5.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

$bg5 = [System.Drawing.Drawing2D.LinearGradientBrush]::new($canvasRect, [System.Drawing.Color]::FromArgb(2, 132, 199), [System.Drawing.Color]::FromArgb(15, 23, 42), 90.0)
$g5.FillRectangle($bg5, $canvasRect)
$bg5.Dispose()
Draw-Sunburst $g5 540 500 950 20 ([System.Drawing.Color]::FromArgb(30, 186, 230, 253))

Draw-OfficialLogoBadge $g5 45 25 115 ([System.Drawing.Color]::FromArgb(56, 189, 248))
$pillTop5 = [System.Drawing.RectangleF]::new(180, 30, 845, 42)
$bSkyDark = [System.Drawing.Drawing2D.LinearGradientBrush]::new($pillTop5, [System.Drawing.Color]::FromArgb(7, 89, 133), [System.Drawing.Color]::FromArgb(3, 105, 161), 0.0)
Draw-RoundedBox $g5 $bSkyDark $pWhite4 $pillTop5 21 $true
$g5.DrawString("PROTOCOLO DE CALIDAD TOTAL $bul NOM-251 Y CADENA DE FR${uI}O", $fBlack14, $bYellow, [float]602, [float]51, $sfCenter)

Draw-OutlinedText $g5 "${iQ}POR QU${uE} PREPARAMOS TU AGUACHILE" $fBlack22 $bWhite $pOutline8 602 105 $sfCenter
Draw-OutlinedText $g5 "FRENTE A TI EN TU PUERTA?" $fBlack24 $bYellow $pOutline8 602 150 $sfCenter

function Draw-PopStep([System.Drawing.Graphics]$g, [int]$y, [string]$badge, [string]$title, [string]$desc, [System.Drawing.Color]$badgeCol) {
    $cardR = [System.Drawing.RectangleF]::new(50, $y, 670, 142)
    Draw-RoundedBox $g $bCream $pDark4 $cardR 22 $true
    $numR = [System.Drawing.RectangleF]::new(66, $y + 22, 96, 95)
    $bBadge = [System.Drawing.SolidBrush]::new($badgeCol)
    Draw-RoundedBox $g $bBadge $pDark4 $numR 20 $false
    $g.DrawString($badge, $fBlack20, $bWhite, [float]114, [float]($y + 70), $sfCenter)
    $g.DrawString($title, $fBlack13, $bNavyTxt, [float]178, [float]($y + 46), $sfLeft)
    $g.DrawString($desc, $fBold15, $bNavyTxt, [float]178, [float]($y + 92), $sfLeft)
    $bBadge.Dispose()
}

Draw-PopStep $g5 195 "0-4${deg}C" "HIELERA GIGANTE + 2 CUBETAS CON TERM${uO}METRO" "Grado alimenticio monitoreado para fr${lI}o extremo." ([System.Drawing.Color]::FromArgb(2, 132, 199))
Draw-PopStep $g5 358 "MESA" "MESA PLEGABLE Y ENSAMBLE EN VIVO" "Montamos tus ~100g de camar${lO}n frente a tus ojos." ([System.Drawing.Color]::FromArgb(16, 185, 129))
Draw-PopStep $g5 521 "100%" "TOSTITOS SALSA VERDE JAM${uA}S AGUADOS" "Crunch perfecto al instante + picante natural." ([System.Drawing.Color]::FromArgb(249, 115, 22))

Draw-StickerWithShadow $g5 $cleanComida 730 185 305 305 4
Draw-StickerWithShadow $g5 $juanchoPath 735 445 300 300 -5

$freshRect5 = [System.Drawing.RectangleF]::new(55, 695, 970, 155)
$bDarkCard5 = [System.Drawing.Drawing2D.LinearGradientBrush]::new($freshRect5, [System.Drawing.Color]::FromArgb(245, 9, 20, 34), [System.Drawing.Color]::FromArgb(248, 4, 10, 18), 90.0)
Draw-RoundedBox $g5 $bDarkCard5 $pYellow3 $freshRect5 26 $true
$g5.DrawString("$star NUESTRA PROMESA SAGRADA (`$150 MXN LA BOLSA) $star", $fBlack16, $bCyan, [float]540, [float]735, $sfCenter)
Draw-OutlinedText $g5 "El producto es preparado frente a usted" $fBlack20 $bYellow $pOutline6 540 780 $sfCenter
Draw-OutlinedText $g5 "para corroborar su frescura" $fBlack20 $bWhite $pOutline6 540 820 $sfCenter

$waRect5 = [System.Drawing.RectangleF]::new(85, 880, 910, 95)
$bWaG5 = [System.Drawing.Drawing2D.LinearGradientBrush]::new($waRect5, [System.Drawing.Color]::FromArgb(37, 211, 102), [System.Drawing.Color]::FromArgb(18, 140, 62), 90.0)
Draw-RoundedBox $g5 $bWaG5 $pWhite4 $waRect5 46 $true
Draw-OutlinedText $g5 "PREVENTA FIN DE SEMANA: 833 252 09 88" $fBlack22 $bWhite $pOutline6 540 927 $sfCenter

$g5.DrawString("Tampico y Cd. Madero $bul Colonia Flores, Tampico, Tamaulipas $bul 75 bolsas m${lA}x. por tanda", $fBlack12, $bYellow, [float]540, [float]1030, $sfCenter)

Save-MultiPath $bmp5 "post5_frescura_en_vivo.png"
$g5.Dispose(); $bmp5.Dispose()
Write-Host "Post 5 (Hielo Artico y Cadena de Frio) generado!"

# ==============================================================================
# POST 6 (DIA 11 - JUEVES): PALETA "ARENA DORADA Y ESCOLLERAS POP" (AMBAR / TERRACOTA / VERDE JUNGLA)
# ==============================================================================
$bmp6 = [System.Drawing.Bitmap]::new(1080, 1080, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g6 = [System.Drawing.Graphics]::FromImage($bmp6)
$g6.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$g6.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g6.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$g6.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

$bg6 = [System.Drawing.Drawing2D.LinearGradientBrush]::new($canvasRect, [System.Drawing.Color]::FromArgb(217, 119, 6), [System.Drawing.Color]::FromArgb(120, 53, 15), 45.0)
$g6.FillRectangle($bg6, $canvasRect)
$bg6.Dispose()
Draw-Sunburst $g6 540 410 950 18 ([System.Drawing.Color]::FromArgb(35, 254, 240, 138))

Draw-OfficialLogoBadge $g6 45 25 115 ([System.Drawing.Color]::FromArgb(16, 185, 129))
$pillTop6 = [System.Drawing.RectangleF]::new(180, 30, 845, 42)
$bJungle = [System.Drawing.Drawing2D.LinearGradientBrush]::new($pillTop6, [System.Drawing.Color]::FromArgb(6, 78, 59), [System.Drawing.Color]::FromArgb(4, 120, 87), 0.0)
Draw-RoundedBox $g6 $bJungle $pWhite4 $pillTop6 21 $true
$g6.DrawString("ESCOLLERAS DE PLAYA MIRAMAR $bul CATADORES OFICIALES", $fBlack14, $bYellow, [float]602, [float]51, $sfCenter)

Draw-OutlinedText $g6 "CUANDO DICEN QUE NO LES GUSTA" $fBlack22 $bWhite $pOutline8 602 105 $sfCenter
Draw-OutlinedText $g6 "EL AGUACHILE DE CAMAR${uO}N..." $fBlack24 $bYellow $pOutline8 602 150 $sfCenter

Draw-StickerWithShadow $g6 $mapachePath 85 190 450 450 -4
Draw-StickerWithShadow $g6 $cleanComida 535 225 425 425 5
Draw-StickerWithShadow $g6 $ovniPath 815 160 190 190 8

$mBadge6 = [System.Drawing.RectangleF]::new(85, 610, 445, 50)
Draw-RoundedBox $g6 $bJungle $pWhite4 $mBadge6 24 $true
$g6.DrawString("${iE}APROBADO POR LAS ESCOLLERAS!", $fBlack14, $bYellow, [float]307, [float]635, $sfCenter)

$cBadge6 = [System.Drawing.RectangleF]::new(560, 610, 455, 50)
$bRose = [System.Drawing.Drawing2D.LinearGradientBrush]::new($cBadge6, [System.Drawing.Color]::FromArgb(225, 29, 72), [System.Drawing.Color]::FromArgb(190, 18, 60), 0.0)
Draw-RoundedBox $g6 $bRose $pWhite4 $cBadge6 24 $true
$g6.DrawString("CON TOSTITOS SALSA VERDE $bul `$150 MXN", $fBlack14, $bWhite, [float]787, [float]635, $sfCenter)

$cardRect6 = [System.Drawing.RectangleF]::new(55, 685, 970, 175)
$bDarkCard6 = [System.Drawing.Drawing2D.LinearGradientBrush]::new($cardRect6, [System.Drawing.Color]::FromArgb(245, 6, 78, 59), [System.Drawing.Color]::FromArgb(248, 4, 30, 20), 90.0)
Draw-RoundedBox $g6 $bDarkCard6 $pYellow3 $cardRect6 26 $true
$g6.DrawString("${iE}HASTA EL MAPACHE SABE CU${uA}L ES EL M${uA}S REPORTADO!", $fBlack18, $bLime, [float]540, [float]723, $sfCenter)
$g6.DrawString("~100g Camar${lO}n Mariposa $bul Lim${lO}n Colima $bul Picante por Naturaleza", $fBlack16, $bWhite, [float]540, [float]768, $sfCenter)
$g6.DrawString("El producto es preparado frente a usted para corroborar su frescura", $fBlack18, $bYellow, [float]540, [float]818, $sfCenter)

$waRect6 = [System.Drawing.RectangleF]::new(85, 885, 910, 95)
$bWaG6 = [System.Drawing.Drawing2D.LinearGradientBrush]::new($waRect6, [System.Drawing.Color]::FromArgb(37, 211, 102), [System.Drawing.Color]::FromArgb(18, 140, 62), 90.0)
Draw-RoundedBox $g6 $bWaG6 $pWhite4 $waRect6 46 $true
Draw-OutlinedText $g6 "${iE}MA${uN}ANA CERRAMOS PREVENTA! 833 252 09 88" $fBlack20 $bWhite $pOutline6 540 932 $sfCenter

$g6.DrawString("Tampico y Cd. Madero $bul Edici${lO}n limitada a 75 bolsas por tanda", $fBlack12, $bCream, [float]540, [float]1030, $sfCenter)

Save-MultiPath $bmp6 "post6_mapache_crunch.png"
$g6.Dispose(); $bmp6.Dispose()
Write-Host "Post 6 (Arena Dorada y Escolleras Pop) generado!"

# ==============================================================================
# POST 7 (DIA 13 - SABADO): PALETA "NEON NOCTURNO PUENTE TAMPICO" (MAGENTA / FUCSIA / TURQUESA)
# ==============================================================================
$bmp7 = [System.Drawing.Bitmap]::new(1080, 1080, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g7 = [System.Drawing.Graphics]::FromImage($bmp7)
$g7.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$g7.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g7.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$g7.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

$bg7 = [System.Drawing.Drawing2D.LinearGradientBrush]::new($canvasRect, [System.Drawing.Color]::FromArgb(112, 26, 117), [System.Drawing.Color]::FromArgb(15, 23, 42), 90.0)
$g7.FillRectangle($bg7, $canvasRect)
$bg7.Dispose()

if (Test-Path $skylinePath) {
    $skyImg = [System.Drawing.Image]::FromFile($skylinePath)
    $g7.DrawImage($skyImg, 0, 0, 1080, 520)
    $skyImg.Dispose()
    $ov7 = [System.Drawing.Drawing2D.LinearGradientBrush]::new([System.Drawing.Rectangle]::new(0, 0, 1080, 530), [System.Drawing.Color]::FromArgb(140, 112, 26, 117), [System.Drawing.Color]::FromArgb(250, 15, 23, 42), 90.0)
    $g7.FillRectangle($ov7, 0, 0, 1080, 530)
    $ov7.Dispose()
}

Draw-OfficialLogoBadge $g7 45 25 115 ([System.Drawing.Color]::FromArgb(244, 63, 94))
$pillTop7 = [System.Drawing.RectangleF]::new(180, 30, 845, 42)
$bRoseTop = [System.Drawing.Drawing2D.LinearGradientBrush]::new($pillTop7, [System.Drawing.Color]::FromArgb(225, 29, 72), [System.Drawing.Color]::FromArgb(190, 18, 60), 0.0)
Draw-RoundedBox $g7 $bRoseTop $pWhite4 $pillTop7 21 $true
$g7.DrawString("S${uA}BADO Y DOMINGO EN RUTA $bul PUENTE TAMPICO A PLAYA MIRAMAR", $fBlack14, $bWhite, [float]602, [float]51, $sfCenter)

Draw-OutlinedText $g7 "${iE}HIELERAS CARGADAS Y EN RUTA!" $fBlack26 $bYellow $pOutline8 602 106 $sfCenter
Draw-OutlinedText $g7 "TAMPICO Y CIUDAD MADERO $bul `$150 MXN" $fBlack20 $bCyan $pOutline6 602 152 $sfCenter

Draw-StickerWithShadow $g7 $juanchoPath 35 190 270 270 -5
Draw-StickerWithShadow $g7 $ovniPath 285 170 245 245 4
Draw-StickerWithShadow $g7 $cleanComida 520 185 280 280 -3
Draw-StickerWithShadow $g7 $mapachePath 780 195 260 260 6

$routeCard7 = [System.Drawing.RectangleF]::new(55, 480, 970, 375)
$bDarkCard7 = [System.Drawing.Drawing2D.LinearGradientBrush]::new($routeCard7, [System.Drawing.Color]::FromArgb(245, 9, 20, 34), [System.Drawing.Color]::FromArgb(248, 15, 23, 42), 90.0)
Draw-RoundedBox $g7 $bDarkCard7 $pYellow3 $routeCard7 28 $true

$basePill7 = [System.Drawing.RectangleF]::new(140, 500, 800, 42)
$bFuchsiaPill = [System.Drawing.Drawing2D.LinearGradientBrush]::new($basePill7, [System.Drawing.Color]::FromArgb(192, 38, 211), [System.Drawing.Color]::FromArgb(147, 22, 163), 0.0)
Draw-RoundedBox $g7 $bFuchsiaPill $pWhite4 $basePill7 20 $false
$g7.DrawString("Base de salida: Colonia Flores, Tampico, Tamaulipas", $fBlack14, $bWhite, [float]540, [float]521, $sfCenter)

$g7.DrawString("ZONA 1 (5-10 min): Col. Flores, Altavista, Cascajal, Centro Tampico", $fBlack14, $bLime, [float]95, [float]575, $sfLeft)
$g7.DrawString("ZONA 2 (12-18 min): Petrolera, Universidad, Lomas del Chairel, Norte", $fBlack14, $bYellow, [float]95, [float]618, $sfLeft)
$g7.DrawString("ZONA 3 (15-22 min): Cd. Madero, Unidad Nacional, Ampliaci${lO}n, Miramar", $fBlack14, $bCyan, [float]95, [float]661, $sfLeft)

$logBar7 = [System.Drawing.RectangleF]::new(85, 700, 910, 44)
Draw-RoundedBox $g7 $bCream $pDark4 $logBar7 16 $false
$g7.DrawString("2 Cubetas 0${deg}C-4${deg}C + Mesa Plegable $bul En Lluvia: Env${lI}o Extra seg${lU}n Distancia", $fBlack12, $bNavyTxt, [float]540, [float]722, $sfCenter)

$g7.DrawString("El producto es preparado frente a usted para corroborar su frescura", $fBlack18, $bYellow, [float]540, [float]782, $sfCenter)
$g7.DrawString("~100g Camar${lO}n Mariposa $bul Con Tostitos Salsa Verde $bul Picante Natural $bul M${lA}x 75 Bolsas", $fBlack12, $bWhite, [float]540, [float]822, $sfCenter)

$waRect7 = [System.Drawing.RectangleF]::new(85, 882, 910, 98)
$bWaG7 = [System.Drawing.Drawing2D.LinearGradientBrush]::new($waRect7, [System.Drawing.Color]::FromArgb(37, 211, 102), [System.Drawing.Color]::FromArgb(18, 140, 62), 90.0)
Draw-RoundedBox $g7 $bWaG7 $pWhite4 $waRect7 48 $true
Draw-OutlinedText $g7 "ENGANCHA TU PEDIDO AL: 833 252 09 88" $fBlack22 $bWhite $pOutline6 540 931 $sfCenter

$g7.DrawString("La Garza Aguachilera $bul El Tostiaguachile m${lA}s reportado de la zona conurbada", $fBlack12, $bCyan, [float]540, [float]1030, $sfCenter)

Save-MultiPath $bmp7 "post7_rutas_activas.png"
$g7.Dispose(); $bmp7.Dispose()
Write-Host "Post 7 (Neon Nocturno Puente Tampico y Escuadron) generado!"

Write-Host "==========================================================================" -ForegroundColor Green
Write-Host " 6 POSTS PERIODICOS MULTI-PALETA POP RENDERIZADOS Y SINCRONIZADOS!" -ForegroundColor Yellow
Write-Host "==========================================================================" -ForegroundColor Green
