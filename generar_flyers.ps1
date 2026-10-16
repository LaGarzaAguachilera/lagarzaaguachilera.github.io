Add-Type -AssemblyName System.Drawing

# ==============================================================================
# CASE-DISTINCT UNICODE SAFE CHARACTERS (PowerShell 5.1 Mojibake Immunity)
# ==============================================================================
$uA = [char]0x00C1; $uE = [char]0x00C9; $uI = [char]0x00CD; $uO = [char]0x00D3; $uU = [char]0x00DA; $uN = [char]0x00D1
$lA = [char]0x00E1; $lE = [char]0x00E9; $lI = [char]0x00ED; $lO = [char]0x00F3; $lU = [char]0x00FA; $lN = [char]0x00F1
$iE = [char]0x00A1; $iQ = [char]0x00BF; $deg = [char]0x00B0; $bul = [char]0x2022; $star = [char]0x2605
$qL = [char]0x00AB; $qR = [char]0x00BB

# Asset Paths
$rootDir     = "d:\AG\la garza aguachilera"
$logoPath    = "$rootDir\La garza aguachilera.jpeg"
$foodRedondo = "$rootDir\tostiaguachile_verde_redondo.jpg"
$foodHero    = "$rootDir\aguachile_verde_hero.jpg"
$cleanComida = "$rootDir\clean_comida.png"
$juanchoPath = "$rootDir\clean_juancho.png"
$ovniPath    = "$rootDir\clean_ovni.png"
$mapachePath = "$rootDir\clean_mapache.png"
$skylinePath = "$rootDir\herramientas\portada_bg_tampico_skyline_1792107773833.jpg"

# ==============================================================================
# HELPER FUNCTIONS: MULTI-LAYER SHADOWS & GLASSMORPHISM
# ==============================================================================
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
    
    # Tier 3: Crisp Sticker Element
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
        $sy1 = $rect.Y + 10
        $shPath1.AddArc($sx1, $sy1, $d, $d, 180, 90)
        $shPath1.AddArc($sx1 + $rect.Width - $d, $sy1, $d, $d, 270, 90)
        $shPath1.AddArc($sx1 + $rect.Width - $d, $sy1 + $rect.Height - $d, $d, $d, 0, 90)
        $shPath1.AddArc($sx1, $sy1 + $rect.Height - $d, $d, $d, 90, 90)
        $shPath1.CloseFigure()
        $shBrush1 = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(60, 0, 0, 0))
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
        $shBrush2 = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(120, 0, 0, 0))
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

    # White border ring
    $wBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)
    $g.FillEllipse($wBrush, $x - 5, $y - 5, $size + 10, $size + 10)
    $wBrush.Dispose()

    # Logo image clipped
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

# String formatters
$sfCenter = [System.Drawing.StringFormat]::new()
$sfCenter.Alignment = [System.Drawing.StringAlignment]::Center
$sfCenter.LineAlignment = [System.Drawing.StringAlignment]::Center

$sfLeft = [System.Drawing.StringFormat]::new()
$sfLeft.Alignment = [System.Drawing.StringAlignment]::Near
$sfLeft.LineAlignment = [System.Drawing.StringAlignment]::Center

# Global Brushes
$bWhite   = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)
$bYellow  = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(254, 240, 138))
$bLime    = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(163, 230, 53))
$bMint    = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(52, 211, 153))
$bCyan    = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(56, 189, 248))
$bNavyTxt = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(15, 23, 42))
$bGrayTxt = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(226, 232, 240))

# ==============================================================================
# 1. FLYER POST VERDE (1080 x 1080 px) - 1:1 CUADRADO FEED POST MASTER
# ==============================================================================
Write-Host "Iniciando renderizado de flyer_post_verde.png (1080x1080)..." -ForegroundColor Cyan
$bmpPost = [System.Drawing.Bitmap]::new(1080, 1080, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$gPost = [System.Drawing.Graphics]::FromImage($bmpPost)
$gPost.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$gPost.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$gPost.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$gPost.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

# Background Studio Gradient
$canvasRect = [System.Drawing.Rectangle]::new(0, 0, 1080, 1080)
$brushBgPost = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
    $canvasRect,
    [System.Drawing.Color]::FromArgb(10, 26, 48),
    [System.Drawing.Color]::FromArgb(4, 12, 22),
    45.0
)
$gPost.FillRectangle($brushBgPost, $canvasRect)
$brushBgPost.Dispose()

# Subtle skyline background tint (Puente Tampico)
if (Test-Path $skylinePath) {
    $skyImg = [System.Drawing.Image]::FromFile($skylinePath)
    $skyAttr = [System.Drawing.Imaging.ImageAttributes]::new()
    $cmSky = [System.Drawing.Imaging.ColorMatrix]::new(@(
        @(1, 0, 0, 0, 0),
        @(0, 1, 0, 0, 0),
        @(0, 0, 1, 0, 0),
        @(0, 0, 0, 0.28, 0),
        @(0, 0, 0, 0, 1)
    ))
    $skyAttr.SetColorMatrix($cmSky)
    $gPost.DrawImage($skyImg, [System.Drawing.Rectangle]::new(0, 120, 1080, 520), 0, 0, $skyImg.Width, $skyImg.Height, [System.Drawing.GraphicsUnit]::Pixel, $skyAttr)
    $skyAttr.Dispose()
    $skyImg.Dispose()
}

# Top Header: Logo + Brand Identity
Draw-OfficialLogoBadge $gPost 50 30 135 ([System.Drawing.Color]::FromArgb(16, 185, 129))

# Tagline Pill
$pillTagRect = [System.Drawing.RectangleF]::new(210, 32, 410, 30)
$brushTagBg = [System.Drawing.Drawing2D.LinearGradientBrush]::new($pillTagRect, [System.Drawing.Color]::FromArgb(240, 2, 132, 199), [System.Drawing.Color]::FromArgb(240, 14, 165, 233), 0.0)
$penTagBorder = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(186, 230, 253), 1.5)
Draw-RoundedBox $gPost $brushTagBg $penTagBorder $pillTagRect 15 $true
$penTagBorder.Dispose(); $brushTagBg.Dispose()
$fontTag = [System.Drawing.Font]::new("Segoe UI Black", 10, [System.Drawing.FontStyle]::Bold)
$gPost.DrawString("TAMPICO Y MADERO $bul S${uA}BADOS Y DOMINGOS", $fontTag, $bWhite, [float]415, [float]47, $sfCenter)

# Main Brand Title
$fontTitlePost = [System.Drawing.Font]::new("Segoe UI Black", 28, [System.Drawing.FontStyle]::Bold)
$penTitleOutline = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(4, 12, 22), 7)
$penTitleOutline.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
Draw-OutlinedText $gPost "LA GARZA AGUACHILERA" $fontTitlePost $bWhite $penTitleOutline 210 68

# Subtitle
$fontSubPost = [System.Drawing.Font]::new("Segoe UI Black", 18.5, [System.Drawing.FontStyle]::Bold)
Draw-OutlinedText $gPost "TOSTIAGUACHILE VERDE TRADICIONAL" $fontSubPost $bMint $penTitleOutline 210 120

# Top Right OVNI
Draw-StickerWithShadow $gPost $ovniPath 860 15 190 190 -8

# UFO Bubble
$ufoBubPost = [System.Drawing.RectangleF]::new(700, 140, 230, 34)
$bUfo = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(254, 240, 138))
$pUfo = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(13, 34, 56), 2)
Draw-RoundedBox $gPost $bUfo $pUfo $ufoBubPost 17 $true
$fontUfoPost = [System.Drawing.Font]::new("Segoe UI Black", 9.5, [System.Drawing.FontStyle]::Bold)
$gPost.DrawString("${iE}ABDUCIDOS POR EL SABOR!", $fontUfoPost, $bNavyTxt, [float]815, [float]157, $sfCenter)

# ==============================================================================
# HERO FOOD & TAMPICO CHARACTERS COMPOSITE
# ==============================================================================
# Food Centerpiece (Real food photography bag: clean_comida.png)
Draw-StickerWithShadow $gPost $cleanComida 330 170 430 430 -2

# Bag Official Patch: TOSTITOS SALSA VERDE
$stateBagPost = $gPost.Save()
$gPost.TranslateTransform(525, 485)
$gPost.RotateTransform(-2)
$bagPatchRectPost = [System.Drawing.RectangleF]::new(-100, -23, 200, 46)
$brushBagPatchPost = [System.Drawing.Drawing2D.LinearGradientBrush]::new($bagPatchRectPost, [System.Drawing.Color]::FromArgb(16, 185, 129), [System.Drawing.Color]::FromArgb(4, 120, 87), 0.0)
$penBagPatchPost = [System.Drawing.Pen]::new([System.Drawing.Color]::White, 3)
Draw-RoundedBox $gPost $brushBagPatchPost $penBagPatchPost $bagPatchRectPost 15 $true
$fontBagAPost = [System.Drawing.Font]::new("Impact", 16.5, [System.Drawing.FontStyle]::Bold)
$fontBagBPost = [System.Drawing.Font]::new("Segoe UI Black", 9, [System.Drawing.FontStyle]::Bold)
$gPost.DrawString("SALSA VERDE", $fontBagAPost, $bYellow, [float]0, [float]-7, $sfCenter)
$gPost.DrawString("TOSTITOS SALSA VERDE", $fontBagBPost, $bWhite, [float]0, [float]11, $sfCenter)
$gPost.Restore($stateBagPost)

# Crunch Foreground Sticker
$stateCrunchPost = $gPost.Save()
$gPost.TranslateTransform(350, 195)
$gPost.RotateTransform(-12)
$crunchRectPost = [System.Drawing.RectangleF]::new(-75, -20, 150, 40)
$brushCrunchPost = [System.Drawing.Drawing2D.LinearGradientBrush]::new($crunchRectPost, [System.Drawing.Color]::FromArgb(225, 29, 72), [System.Drawing.Color]::FromArgb(190, 18, 60), 90.0)
$penCrunchPost = [System.Drawing.Pen]::new([System.Drawing.Color]::White, 2.5)
Draw-RoundedBox $gPost $brushCrunchPost $penCrunchPost $crunchRectPost 15 $true
$fontC1 = [System.Drawing.Font]::new("Impact", 15, [System.Drawing.FontStyle]::Bold)
$fontC2 = [System.Drawing.Font]::new("Segoe UI Black", 8, [System.Drawing.FontStyle]::Bold)
$gPost.DrawString("${iE}CRUJIENTE!", $fontC1, $bYellow, [float]0, [float]-7, $sfCenter)
$gPost.DrawString("AL INSTANTE", $fontC2, $bWhite, [float]0, [float]8, $sfCenter)
$gPost.Restore($stateCrunchPost)

# Juancho el Cocodrilo (Left Flank)
Draw-StickerWithShadow $gPost $juanchoPath 40 250 310 310 -4
$juanchoPillPost = [System.Drawing.RectangleF]::new(45, 530, 270, 36)
$bJPill = [System.Drawing.Drawing2D.LinearGradientBrush]::new($juanchoPillPost, [System.Drawing.Color]::FromArgb(16, 185, 129), [System.Drawing.Color]::FromArgb(5, 150, 105), 0.0)
$pJPill = [System.Drawing.Pen]::new([System.Drawing.Color]::White, 2.5)
Draw-RoundedBox $gPost $bJPill $pJPill $juanchoPillPost 18 $true
$fontJPost = [System.Drawing.Font]::new("Segoe UI Black", 10.5, [System.Drawing.FontStyle]::Bold)
$gPost.DrawString("JUANCHO: ${iE}BIEN REPORTADO!", $fontJPost, $bWhite, [float]180, [float]548, $sfCenter)

# Mapache de las Escolleras (Right Flank)
Draw-StickerWithShadow $gPost $mapachePath 750 265 290 290 5
$mapPillPost = [System.Drawing.RectangleF]::new(760, 530, 275, 36)
$bMPill = [System.Drawing.Drawing2D.LinearGradientBrush]::new($mapPillPost, [System.Drawing.Color]::FromArgb(249, 115, 22), [System.Drawing.Color]::FromArgb(217, 119, 6), 0.0)
$pMPill = [System.Drawing.Pen]::new([System.Drawing.Color]::White, 2.5)
Draw-RoundedBox $gPost $bMPill $pMPill $mapPillPost 18 $true
$fontMPost = [System.Drawing.Font]::new("Segoe UI Black", 10, [System.Drawing.FontStyle]::Bold)
$gPost.DrawString("MAPACHE: ${iE}100% CRUJIENTE!", $fontMPost, $bWhite, [float]897, [float]548, $sfCenter)

# ==============================================================================
# COMMERCIAL VALUE CARDS & PRICING
# ==============================================================================
# High-Voltage Radiant Price Pill ($170 MXN)
$pricePillPost = [System.Drawing.RectangleF]::new(70, 595, 940, 58)
$bPricePost = [System.Drawing.Drawing2D.LinearGradientBrush]::new($pricePillPost, [System.Drawing.Color]::FromArgb(249, 115, 22), [System.Drawing.Color]::FromArgb(234, 88, 12), 0.0)
$pPricePost = [System.Drawing.Pen]::new([System.Drawing.Color]::White, 3)
Draw-RoundedBox $gPost $bPricePost $pPricePost $pricePillPost 24 $true
$fontPricePost = [System.Drawing.Font]::new("Segoe UI Black", 13.5, [System.Drawing.FontStyle]::Bold)
$priceStrPost = "$star `$170 MXN LA BOLSA $bul ~100g CAMAR${uO}N MARIPOSA $bul TOSTITOS SALSA VERDE $star"
$gPost.DrawString($priceStrPost, $fontPricePost, $bWhite, [float]540, [float]624, $sfCenter)

# Mandatory Freshness Guarantee Card (Frosted Glassmorphism Finish)
$cardFreshPost = [System.Drawing.RectangleF]::new(70, 672, 940, 130)
$brushCardPost = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
    $cardFreshPost,
    [System.Drawing.Color]::FromArgb(245, 10, 24, 42),
    [System.Drawing.Color]::FromArgb(248, 6, 16, 30),
    90.0
)
$pCardPost = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(254, 240, 138), 2.8)
Draw-RoundedBox $gPost $brushCardPost $pCardPost $cardFreshPost 24 $true

# Official Seal Header inside Card
$sealPillPost = [System.Drawing.RectangleF]::new(310, 684, 460, 26)
$bSealPost = [System.Drawing.Drawing2D.LinearGradientBrush]::new($sealPillPost, [System.Drawing.Color]::FromArgb(16, 185, 129), [System.Drawing.Color]::FromArgb(5, 150, 105), 0.0)
Draw-RoundedBox $gPost $bSealPost $null $sealPillPost 13 $false
$fontSealPost = [System.Drawing.Font]::new("Segoe UI Black", 9.5, [System.Drawing.FontStyle]::Bold)
$gPost.DrawString("SELLO OFICIAL DE FRESCURA EN TU PUERTA (0${deg}C - 4${deg}C)", $fontSealPost, $bWhite, [float]540, [float]697, $sfCenter)

# Mandatory Freshness Statement
$fontFreshStmtA = [System.Drawing.Font]::new("Segoe UI Black", 16.5, [System.Drawing.FontStyle]::Bold)
$fontFreshStmtB = [System.Drawing.Font]::new("Segoe UI Black", 16.5, [System.Drawing.FontStyle]::Bold)
$gPost.DrawString("${qL}El producto es preparado frente a usted", $fontFreshStmtA, $bYellow, [float]540, [float]734, $sfCenter)
$gPost.DrawString("para corroborar su frescura${qR}", $fontFreshStmtB, $bWhite, [float]540, [float]768, $sfCenter)

# Ingredients & Logistics Strip
$ingrRectPost = [System.Drawing.RectangleF]::new(70, 815, 940, 48)
$bIngrPost = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(215, 6, 16, 28))
$pIngrPost = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(51, 65, 85), 1.5)
Draw-RoundedBox $gPost $bIngrPost $pIngrPost $ingrRectPost 16 $true
$fontIngrPost = [System.Drawing.Font]::new("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$ingrStrPost = "CAMAR${uO}N FRESCO MARIPOSA $bul LIM${uO}N COLIMA $bul SERRANO $bul PEPINO $bul CEBOLLA MORADA"
$gPost.DrawString($ingrStrPost, $fontIngrPost, $bLime, [float]540, [float]839, $sfCenter)

# ==============================================================================
# WHATSAPP & DELIVERY CTA
# ==============================================================================
# Emerald 3D WhatsApp Button
$waRectPost = [System.Drawing.RectangleF]::new(90, 880, 900, 95)
$bWaPost = [System.Drawing.Drawing2D.LinearGradientBrush]::new($waRectPost, [System.Drawing.Color]::FromArgb(37, 211, 102), [System.Drawing.Color]::FromArgb(18, 140, 62), 90.0)
$pWaPost = [System.Drawing.Pen]::new([System.Drawing.Color]::White, 3)
Draw-RoundedBox $gPost $bWaPost $pWaPost $waRectPost 45 $true

$fWaTitlePost = [System.Drawing.Font]::new("Segoe UI Black", 14, [System.Drawing.FontStyle]::Bold)
$fWaPhonePost = [System.Drawing.Font]::new("Segoe UI Black", 28, [System.Drawing.FontStyle]::Bold)
$pWaPhoneOutline = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(10, 80, 36), 5)
$pWaPhoneOutline.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round

$gPost.DrawString("PEDIDOS Y APARTADOS POR WHATSAPP", $fWaTitlePost, $bWhite, [float]540, [float]904, $sfCenter)
Draw-OutlinedText $gPost "833 252 09 88" $fWaPhonePost $bWhite $pWaPhoneOutline 540 944 $sfCenter

# Bottom Delivery Footer
$fontFootPost = [System.Drawing.Font]::new("Segoe UI Black", 12, [System.Drawing.FontStyle]::Bold)
$footStrPost = "ENTREGAS FINES DE SEMANA (S${uA}BADOS Y DOMINGOS) $bul COBERTURA TAMPICO Y MADERO"
$gPost.DrawString($footStrPost, $fontFootPost, $bYellow, [float]540, [float]1005, $sfCenter)
$fontBasePost = [System.Drawing.Font]::new("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$gPost.DrawString("Colonia Flores, Tampico, Tamaulipas $bul Cupo limitado por tanda", $fontBasePost, $bGrayTxt, [float]540, [float]1032, $sfCenter)

# Save Master Feed Post
$postOut1 = "$rootDir\flyer_post_verde.png"
$postOut2 = "$rootDir\contenido_redes\imagenes\flyer_post_verde.png"
$bmpPost.Save($postOut1, [System.Drawing.Imaging.ImageFormat]::Png)
Copy-Item $postOut1 $postOut2 -Force
$gPost.Dispose(); $bmpPost.Dispose()
Write-Host "FLYER POST VERDE (1080x1080) GENERADO EXITOSAMENTE!" -ForegroundColor Green

# ==============================================================================
# 2. FLYER HISTORIA VERDE (1080 x 1920 px) - 9:16 VERTICAL STORIES MASTER
# ==============================================================================
Write-Host "Iniciando renderizado de flyer_historia_verde.png (1080x1920)..." -ForegroundColor Cyan
$bmpStory = [System.Drawing.Bitmap]::new(1080, 1920, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$gStory = [System.Drawing.Graphics]::FromImage($bmpStory)
$gStory.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$gStory.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$gStory.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$gStory.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

# Background Vertical Studio Gradient
$canvasStoryRect = [System.Drawing.Rectangle]::new(0, 0, 1080, 1920)
$brushBgStory = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
    $canvasStoryRect,
    [System.Drawing.Color]::FromArgb(6, 18, 34),
    [System.Drawing.Color]::FromArgb(3, 10, 18),
    90.0
)
$gStory.FillRectangle($brushBgStory, $canvasStoryRect)
$brushBgStory.Dispose()

# Mid-Layer Skyline Atmosphere
if (Test-Path $skylinePath) {
    $skyImg = [System.Drawing.Image]::FromFile($skylinePath)
    $skyAttr2 = [System.Drawing.Imaging.ImageAttributes]::new()
    $cmSky2 = [System.Drawing.Imaging.ColorMatrix]::new(@(
        @(1, 0, 0, 0, 0),
        @(0, 1, 0, 0, 0),
        @(0, 0, 1, 0, 0),
        @(0, 0, 0, 0.32, 0),
        @(0, 0, 0, 0, 1)
    ))
    $skyAttr2.SetColorMatrix($cmSky2)
    $gStory.DrawImage($skyImg, [System.Drawing.Rectangle]::new(0, 580, 1080, 680), 0, 0, $skyImg.Width, $skyImg.Height, [System.Drawing.GraphicsUnit]::Pixel, $skyAttr2)
    $skyAttr2.Dispose()
    $skyImg.Dispose()
}

# ==============================================================================
# HEADER SECTION (Safe Zone: Starts at Y=130)
# ==============================================================================
# Official Logo Badge
Draw-OfficialLogoBadge $gStory 465 125 150 ([System.Drawing.Color]::FromArgb(16, 185, 129))

# Tagline Pill
$pillStoryTag = [System.Drawing.RectangleF]::new(200, 295, 680, 36)
$bStoryTag = [System.Drawing.Drawing2D.LinearGradientBrush]::new($pillStoryTag, [System.Drawing.Color]::FromArgb(240, 2, 132, 199), [System.Drawing.Color]::FromArgb(240, 14, 165, 233), 0.0)
$pStoryTag = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(186, 230, 253), 1.8)
Draw-RoundedBox $gStory $bStoryTag $pStoryTag $pillStoryTag 18 $true
$fStoryTag = [System.Drawing.Font]::new("Segoe UI Black", 12, [System.Drawing.FontStyle]::Bold)
$gStory.DrawString("TAMPICO Y CIUDAD MADERO $bul S${uA}BADOS Y DOMINGOS", $fStoryTag, $bWhite, [float]540, [float]313, $sfCenter)

# Main Brand Title
$fontTitleStory = [System.Drawing.Font]::new("Segoe UI Black", 34, [System.Drawing.FontStyle]::Bold)
$penTitleOutlineStory = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(4, 12, 22), 8)
$penTitleOutlineStory.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
Draw-OutlinedText $gStory "LA GARZA AGUACHILERA" $fontTitleStory $bWhite $penTitleOutlineStory 540 345 $sfCenter

# Subtitle
$fontSubStory = [System.Drawing.Font]::new("Segoe UI Black", 23, [System.Drawing.FontStyle]::Bold)
Draw-OutlinedText $gStory "TOSTIAGUACHILE VERDE TRADICIONAL" $fontSubStory $bMint $penTitleOutlineStory 540 405 $sfCenter

# ==============================================================================
# HERO FOOD & TAMPICO CHARACTERS DYNAMIC COMPOSITION
# ==============================================================================
# Central Food Hero (Authentic open bag: clean_comida.png)
Draw-StickerWithShadow $gStory $cleanComida 265 470 550 550 -2

# Bag Official Patch: TOSTITOS SALSA VERDE
$stateBagStory = $gStory.Save()
$gStory.TranslateTransform(515, 875)
$gStory.RotateTransform(-2)
$bagPatchRectStory = [System.Drawing.RectangleF]::new(-120, -28, 240, 56)
$brushBagPatchStory = [System.Drawing.Drawing2D.LinearGradientBrush]::new($bagPatchRectStory, [System.Drawing.Color]::FromArgb(16, 185, 129), [System.Drawing.Color]::FromArgb(4, 120, 87), 0.0)
$penBagPatchStory = [System.Drawing.Pen]::new([System.Drawing.Color]::White, 3.5)
Draw-RoundedBox $gStory $brushBagPatchStory $penBagPatchStory $bagPatchRectStory 18 $true
$fontBagAStory = [System.Drawing.Font]::new("Impact", 19, [System.Drawing.FontStyle]::Bold)
$fontBagBStory = [System.Drawing.Font]::new("Segoe UI Black", 10.5, [System.Drawing.FontStyle]::Bold)
$gStory.DrawString("SALSA VERDE", $fontBagAStory, $bYellow, [float]0, [float]-9, $sfCenter)
$gStory.DrawString("TOSTITOS SALSA VERDE", $fontBagBStory, $bWhite, [float]0, [float]13, $sfCenter)
$gStory.Restore($stateBagStory)

# Crunch Foreground Badge
$stateCrunchStory = $gStory.Save()
$gStory.TranslateTransform(270, 510)
$gStory.RotateTransform(-12)
$crunchRectStory = [System.Drawing.RectangleF]::new(-90, -24, 180, 48)
$brushCrunchStory = [System.Drawing.Drawing2D.LinearGradientBrush]::new($crunchRectStory, [System.Drawing.Color]::FromArgb(225, 29, 72), [System.Drawing.Color]::FromArgb(190, 18, 60), 90.0)
$penCrunchStory = [System.Drawing.Pen]::new([System.Drawing.Color]::White, 3)
Draw-RoundedBox $gStory $brushCrunchStory $penCrunchStory $crunchRectStory 18 $true
$fontCS1 = [System.Drawing.Font]::new("Impact", 18, [System.Drawing.FontStyle]::Bold)
$fontCS2 = [System.Drawing.Font]::new("Segoe UI Black", 9.5, [System.Drawing.FontStyle]::Bold)
$gStory.DrawString("${iE}CRUJIENTE!", $fontCS1, $bYellow, [float]0, [float]-9, $sfCenter)
$gStory.DrawString("AL INSTANTE", $fontCS2, $bWhite, [float]0, [float]10, $sfCenter)
$gStory.Restore($stateCrunchStory)

# OVNI de Miramar (Top Right)
Draw-StickerWithShadow $gStory $ovniPath 740 445 280 280 6
$ufoBubStory = [System.Drawing.RectangleF]::new(725, 680, 275, 40)
$bUfoS = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(254, 240, 138))
$pUfoS = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(13, 34, 56), 2.5)
Draw-RoundedBox $gStory $bUfoS $pUfoS $ufoBubStory 20 $true
$fontUfoStory = [System.Drawing.Font]::new("Segoe UI Black", 10.5, [System.Drawing.FontStyle]::Bold)
$gStory.DrawString("${iE}ABDUCIDOS POR EL SABOR!", $fontUfoStory, $bNavyTxt, [float]862, [float]700, $sfCenter)

# Juancho el Cocodrilo (Left Flank)
Draw-StickerWithShadow $gStory $juanchoPath 30 670 340 340 -5
$juanchoPillStory = [System.Drawing.RectangleF]::new(35, 960, 280, 42)
$bJStory = [System.Drawing.Drawing2D.LinearGradientBrush]::new($juanchoPillStory, [System.Drawing.Color]::FromArgb(16, 185, 129), [System.Drawing.Color]::FromArgb(5, 150, 105), 0.0)
$pJStory = [System.Drawing.Pen]::new([System.Drawing.Color]::White, 2.5)
Draw-RoundedBox $gStory $bJStory $pJStory $juanchoPillStory 21 $true
$fontJStory = [System.Drawing.Font]::new("Segoe UI Black", 11, [System.Drawing.FontStyle]::Bold)
$gStory.DrawString("JUANCHO: ${iE}BIEN REPORTADO!", $fontJStory, $bWhite, [float]175, [float]981, $sfCenter)

# Mapache de las Escolleras (Right Flank)
Draw-StickerWithShadow $gStory $mapachePath 730 780 320 320 5
$mapPillStory = [System.Drawing.RectangleF]::new(740, 1045, 290, 42)
$bMStory = [System.Drawing.Drawing2D.LinearGradientBrush]::new($mapPillStory, [System.Drawing.Color]::FromArgb(249, 115, 22), [System.Drawing.Color]::FromArgb(217, 119, 6), 0.0)
$pMStory = [System.Drawing.Pen]::new([System.Drawing.Color]::White, 2.5)
Draw-RoundedBox $gStory $bMStory $pMStory $mapPillStory 21 $true
$fontMStory = [System.Drawing.Font]::new("Segoe UI Black", 10.5, [System.Drawing.FontStyle]::Bold)
$gStory.DrawString("MAPACHE: ${iE}100% CRUJIENTE!", $fontMStory, $bWhite, [float]885, [float]1066, $sfCenter)

# ==============================================================================
# COMMERCIAL VALUE CARDS & PRICING
# ==============================================================================
# High-Voltage Radiant Price Pill ($170 MXN)
$pricePillStory = [System.Drawing.RectangleF]::new(90, 1095, 900, 76)
$bPriceStory = [System.Drawing.Drawing2D.LinearGradientBrush]::new($pricePillStory, [System.Drawing.Color]::FromArgb(249, 115, 22), [System.Drawing.Color]::FromArgb(234, 88, 12), 0.0)
$pPriceStory = [System.Drawing.Pen]::new([System.Drawing.Color]::White, 3.5)
Draw-RoundedBox $gStory $bPriceStory $pPriceStory $pricePillStory 38 $true
$fontPriceStory = [System.Drawing.Font]::new("Segoe UI Black", 23, [System.Drawing.FontStyle]::Bold)
$priceStrStory = "$star `$170 MXN LA BOLSA $bul ~100g CAMAR${uO}N $star"
$gStory.DrawString($priceStrStory, $fontPriceStory, $bWhite, [float]540, [float]1133, $sfCenter)

# Mandatory Freshness Guarantee Card (Frosted Glassmorphism Finish)
$cardFreshStory = [System.Drawing.RectangleF]::new(90, 1190, 900, 160)
$brushCardStory = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
    $cardFreshStory,
    [System.Drawing.Color]::FromArgb(245, 10, 24, 42),
    [System.Drawing.Color]::FromArgb(248, 6, 16, 30),
    90.0
)
$pCardStory = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(254, 240, 138), 3)
Draw-RoundedBox $gStory $brushCardStory $pCardStory $cardFreshStory 28 $true

# Official Seal Header inside Card
$sealPillStory = [System.Drawing.RectangleF]::new(290, 1205, 500, 30)
$bSealStory = [System.Drawing.Drawing2D.LinearGradientBrush]::new($sealPillStory, [System.Drawing.Color]::FromArgb(16, 185, 129), [System.Drawing.Color]::FromArgb(5, 150, 105), 0.0)
Draw-RoundedBox $gStory $bSealStory $null $sealPillStory 15 $false
$fontSealStory = [System.Drawing.Font]::new("Segoe UI Black", 10.5, [System.Drawing.FontStyle]::Bold)
$gStory.DrawString("SELLO OFICIAL DE FRESCURA EN TU PUERTA (0${deg}C - 4${deg}C)", $fontSealStory, $bWhite, [float]540, [float]1220, $sfCenter)

# Mandatory Freshness Statement
$fontFreshStmtStoryA = [System.Drawing.Font]::new("Segoe UI Black", 20, [System.Drawing.FontStyle]::Bold)
$fontFreshStmtStoryB = [System.Drawing.Font]::new("Segoe UI Black", 20, [System.Drawing.FontStyle]::Bold)
$gStory.DrawString("${qL}El producto es preparado frente a usted", $fontFreshStmtStoryA, $bYellow, [float]540, [float]1265, $sfCenter)
$gStory.DrawString("para corroborar su frescura${qR}", $fontFreshStmtStoryB, $bWhite, [float]540, [float]1305, $sfCenter)

# Value Bullets Box
$bulletBoxStory = [System.Drawing.RectangleF]::new(90, 1368, 900, 140)
$bBulletStory = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(215, 6, 16, 28))
$pBulletStory = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(51, 65, 85), 2)
Draw-RoundedBox $gStory $bBulletStory $pBulletStory $bulletBoxStory 22 $true

$fBulletStory = [System.Drawing.Font]::new("Segoe UI", 14.5, [System.Drawing.FontStyle]::Bold)
$storyBul1 = "$bul ~100g Camar${lO}n fresco del Golfo en corte mariposa"
$storyBul2 = "$bul Tostitos Salsa Verde (preparado al instante, ${iE}100% crujiente!)"
$storyBul3 = "$bul Salsa verde serrano, pepino, cebolla morada y lim${lO}n Colima"
$gStory.DrawString($storyBul1, $fBulletStory, $bLime, [float]130, [float]1386)
$gStory.DrawString($storyBul2, $fBulletStory, $bGrayTxt, [float]130, [float]1420)
$gStory.DrawString($storyBul3, $fBulletStory, $bGrayTxt, [float]130, [float]1454)

# ==============================================================================
# WHATSAPP & DELIVERY CTA
# ==============================================================================
# Emerald 3D WhatsApp Button
$waRectStory = [System.Drawing.RectangleF]::new(90, 1530, 900, 120)
$bWaStory = [System.Drawing.Drawing2D.LinearGradientBrush]::new($waRectStory, [System.Drawing.Color]::FromArgb(37, 211, 102), [System.Drawing.Color]::FromArgb(18, 140, 62), 90.0)
$pWaStory = [System.Drawing.Pen]::new([System.Drawing.Color]::White, 3.5)
Draw-RoundedBox $gStory $bWaStory $pWaStory $waRectStory 50 $true

$fWaTitleStory = [System.Drawing.Font]::new("Segoe UI Black", 16, [System.Drawing.FontStyle]::Bold)
$fWaPhoneStory = [System.Drawing.Font]::new("Segoe UI Black", 36, [System.Drawing.FontStyle]::Bold)
$pWaPhoneOutlineStory = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(10, 80, 36), 6)
$pWaPhoneOutlineStory.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round

$gStory.DrawString("APARTA TU BOLSA POR WHATSAPP", $fWaTitleStory, $bWhite, [float]540, [float]1560, $sfCenter)
Draw-OutlinedText $gStory "833 252 09 88" $fWaPhoneStory $bWhite $pWaPhoneOutlineStory 540 1610 $sfCenter

# Bottom Subtext Pill
$delivPillStory = [System.Drawing.RectangleF]::new(120, 1675, 840, 48)
$bDelivPill = [System.Drawing.Drawing2D.LinearGradientBrush]::new($delivPillStory, [System.Drawing.Color]::FromArgb(240, 2, 132, 199), [System.Drawing.Color]::FromArgb(240, 3, 105, 161), 0.0)
$pDelivPill = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(125, 211, 252), 2)
Draw-RoundedBox $gStory $bDelivPill $pDelivPill $delivPillStory 22 $true
$fDelivStory = [System.Drawing.Font]::new("Segoe UI Black", 13, [System.Drawing.FontStyle]::Bold)
$gStory.DrawString("ENTREGAS S${uA}BADOS Y DOMINGOS $bul RUTAS ANUNCIADAS EN REDES SOCIALES", $fDelivStory, $bWhite, [float]540, [float]1699, $sfCenter)

# Bottom Safe Zone Subtext (Leaves >150px at bottom for Story UI)
$fBaseStory = [System.Drawing.Font]::new("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$gStory.DrawString("Colonia Flores, Tampico, Tamaulipas $bul Cobertura Tampico y Cd. Madero", $fBaseStory, $bYellow, [float]540, [float]1745, $sfCenter)

# Save Master Story Flyer
$storyOut1 = "$rootDir\flyer_historia_verde.png"
$storyOut2 = "$rootDir\contenido_redes\imagenes\flyer_historia_verde.png"
$bmpStory.Save($storyOut1, [System.Drawing.Imaging.ImageFormat]::Png)
Copy-Item $storyOut1 $storyOut2 -Force
$gStory.Dispose(); $bmpStory.Dispose()
Write-Host "FLYER HISTORIA VERDE (1080x1920) GENERADO EXITOSAMENTE!" -ForegroundColor Green

Write-Host "==========================================================================" -ForegroundColor Green
Write-Host " AMBOS FLYERS (FEED Y STORY) FUERON REESCRITOS Y RENDERIZADOS CON EXITO!" -ForegroundColor Yellow
Write-Host "==========================================================================" -ForegroundColor Green
