Add-Type -AssemblyName System.Drawing

# Case-Distinct Unicode Safe Characters for PowerShell 5.1 (Immune to Mojibake)
$uA = [char]0x00C1; $uE = [char]0x00C9; $uI = [char]0x00CD; $uO = [char]0x00D3; $uU = [char]0x00DA; $uN = [char]0x00D1
$lA = [char]0x00E1; $lE = [char]0x00E9; $lI = [char]0x00ED; $lO = [char]0x00F3; $lU = [char]0x00FA; $lN = [char]0x00F1
$iE = [char]0x00A1; $iQ = [char]0x00BF; $deg = [char]0x00B0; $bul = [char]0x2022; $star = [char]0x2605
$qL = [char]0x00AB; $qR = [char]0x00BB

# Multi-layer Ambient Occlusion + Contact Drop Shadow for Stickers
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
    
    if ($outlinePen) {
        $g.DrawPath($outlinePen, $path)
    }
    if ($fillBrush) {
        $g.FillPath($fillBrush, $path)
    }
    $path.Dispose()
}

# 1200 x 630 Canvas (Official Facebook Cover)
$bmp = [System.Drawing.Bitmap]::new(1200, 630, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

# ==============================================================================
# LAYER 1: BACKGROUND (Puente Tampico iluminado + Olas neón Playa Miramar)
# ==============================================================================
$bgPath = "d:\AG\la garza aguachilera\herramientas\portada_bg_tampico_skyline_1792107773833.jpg"
if (-not (Test-Path $bgPath)) {
    $bgPath = "$PSScriptRoot\herramientas\portada_bg_tampico_skyline_1792107773833.jpg"
}
if (Test-Path $bgPath) {
    $bgImg = [System.Drawing.Image]::FromFile($bgPath)
    $g.DrawImage($bgImg, 0, 0, 1200, 630)
    $bgImg.Dispose()
}

# Left Dark Studio Vignette (Width: 700px)
$vignetteRect = [System.Drawing.Rectangle]::new(0, 0, 700, 630)
$brushVignette = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
    $vignetteRect,
    [System.Drawing.Color]::FromArgb(248, 6, 17, 32),
    [System.Drawing.Color]::FromArgb(0, 6, 17, 32),
    0.0
)
$g.FillRectangle($brushVignette, $vignetteRect)
$brushVignette.Dispose()

# Top Vignette for Title
$topVignetteRect = [System.Drawing.Rectangle]::new(0, 0, 1200, 180)
$brushTopVignette = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
    $topVignetteRect,
    [System.Drawing.Color]::FromArgb(190, 4, 12, 24),
    [System.Drawing.Color]::FromArgb(0, 4, 12, 24),
    90.0
)
$g.FillRectangle($brushTopVignette, $topVignetteRect)
$brushTopVignette.Dispose()

# Subtle bottom studio tint for clean contrast
$botVignetteRect = [System.Drawing.Rectangle]::new(0, 520, 1200, 110)
$brushBotVignette = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
    $botVignetteRect,
    [System.Drawing.Color]::FromArgb(0, 4, 12, 24),
    [System.Drawing.Color]::FromArgb(160, 4, 12, 24),
    90.0
)
$g.FillRectangle($brushBotVignette, $botVignetteRect)
$brushBotVignette.Dispose()

# ==============================================================================
# LAYER 2: EASTER EGGS TAMPICO
# ==============================================================================
$sfCenter = [System.Drawing.StringFormat]::new()
$sfCenter.Alignment = [System.Drawing.StringAlignment]::Center
$sfCenter.LineAlignment = [System.Drawing.StringAlignment]::Center

$brushWhite  = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)
$brushYellow = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(254, 240, 138))
$brushDark   = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(13, 34, 56))

# 1. OVNI DE MIRAMAR (Abduciendo limón verde - Compact Panoramic Facebook Safe Zone)
Draw-StickerWithShadow $g "d:\AG\la garza aguachilera\clean_ovni.png" 685 102 150 150 -6

# UFO Comic Bubble (Glassmorphic border)
$ufoBadgeRect = [System.Drawing.RectangleF]::new(665, 222, 195, 26)
$brushUfoBadge = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(254, 240, 138))
$penUfoBadge = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(13, 34, 56), 2)
Draw-RoundedBox $g $brushUfoBadge $penUfoBadge $ufoBadgeRect 13 $true
$fontUfo = [System.Drawing.Font]::new("Segoe UI Black", 8.5, [System.Drawing.FontStyle]::Bold)
$g.DrawString("${iE}ABDUCIDOS POR EL SABOR!", $fontUfo, $brushDark, [float]762.5, [float]235, $sfCenter)

# 2. JUANCHO EL COCODRILO (Rey de la Laguna en Miramar con lentes y bermuda)
Draw-StickerWithShadow $g "d:\AG\la garza aguachilera\clean_juancho.png" 865 170 195 195 3

# Juancho badge (Placed cleanly above right, zero overlap with Mapache)
$juanchoBadgeRect = [System.Drawing.RectangleF]::new(860, 344, 200, 26)
$brushJBadge = [System.Drawing.Drawing2D.LinearGradientBrush]::new($juanchoBadgeRect, [System.Drawing.Color]::FromArgb(16, 185, 129), [System.Drawing.Color]::FromArgb(5, 150, 105), 0.0)
$penJBadge = [System.Drawing.Pen]::new([System.Drawing.Color]::White, 2)
Draw-RoundedBox $g $brushJBadge $penJBadge $juanchoBadgeRect 13 $true
$fontJ = [System.Drawing.Font]::new("Segoe UI Black", 8.5, [System.Drawing.FontStyle]::Bold)
$g.DrawString("JUANCHO $bul PLAYA MIRAMAR", $fontJ, $brushWhite, [float]960, [float]357, $sfCenter)

# 3. FOOD HERO (Tostiaguachile Verde Tradicional en bolsa abierta)
Draw-StickerWithShadow $g "d:\AG\la garza aguachilera\clean_comida.png" 555 240 275 275 -3

# Bag Brand Patch: SALSA VERDE • TOSTITOS SALSA VERDE
$stateBag = $g.Save()
$g.TranslateTransform(680, 442)
$g.RotateTransform(-3)
$bagPatchRect = [System.Drawing.RectangleF]::new(-76, -17, 152, 34)
$brushBagPatch = [System.Drawing.Drawing2D.LinearGradientBrush]::new($bagPatchRect, [System.Drawing.Color]::FromArgb(16, 185, 129), [System.Drawing.Color]::FromArgb(4, 120, 87), 0.0)
$penBagPatch = [System.Drawing.Pen]::new([System.Drawing.Color]::White, 2.2)
Draw-RoundedBox $g $brushBagPatch $penBagPatch $bagPatchRect 11 $true
$fontBagA = [System.Drawing.Font]::new("Impact", 12.5, [System.Drawing.FontStyle]::Bold)
$fontBagB = [System.Drawing.Font]::new("Segoe UI Black", 7.5, [System.Drawing.FontStyle]::Bold)
$g.DrawString("SALSA VERDE", $fontBagA, $brushYellow, [float]0, [float]-5, $sfCenter)
$g.DrawString("TOSTITOS SALSA VERDE", $fontBagB, $brushWhite, [float]0, [float]8, $sfCenter)
$g.Restore($stateBag)

# 4. MAPACHE DE LAS ESCOLLERAS (Comiendo su Tostito)
Draw-StickerWithShadow $g "d:\AG\la garza aguachilera\clean_mapache.png" 760 362 152 152 5

# Mapache badge
$mapacheBadgeRect = [System.Drawing.RectangleF]::new(740, 482, 195, 26)
$brushMBadge = [System.Drawing.Drawing2D.LinearGradientBrush]::new($mapacheBadgeRect, [System.Drawing.Color]::FromArgb(249, 115, 22), [System.Drawing.Color]::FromArgb(217, 119, 6), 0.0)
$penMBadge = [System.Drawing.Pen]::new([System.Drawing.Color]::White, 2)
Draw-RoundedBox $g $brushMBadge $penMBadge $mapacheBadgeRect 13 $true
$fontM = [System.Drawing.Font]::new("Segoe UI Black", 8, [System.Drawing.FontStyle]::Bold)
$g.DrawString("MAPACHE DE LAS ESCOLLERAS", $fontM, $brushWhite, [float]837.5, [float]495, $sfCenter)

# ==============================================================================
# LAYER 3: BRAND IDENTITY & OFFICIAL LOGO (Proportional Facebook Safe Zone)
# ==============================================================================
# Circular Official Logo Badge with multi-layer shadow and franchise ring
$logoPath = "d:\AG\la garza aguachilera\La garza aguachilera.jpeg"
$logoImg = [System.Drawing.Image]::FromFile($logoPath)
$logoX = 135
$logoY = 112
$logoSize = 102

# Tier 1 Ambient Logo Shadow
$shAmbLogo = [System.Drawing.Rectangle]::new($logoX - 2, $logoY + 5, $logoSize + 8, $logoSize + 8)
$brushLogoAmb = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(70, 0, 0, 0))
$g.FillEllipse($brushLogoAmb, $shAmbLogo)
$brushLogoAmb.Dispose()

# Tier 2 Contact Logo Shadow
$shadowRect = [System.Drawing.Rectangle]::new($logoX - 2, $logoY + 3, $logoSize + 6, $logoSize + 6)
$brushLogoShadow = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(150, 0, 0, 0))
$g.FillEllipse($brushLogoShadow, $shadowRect)
$brushLogoShadow.Dispose()

$borderRect = [System.Drawing.Rectangle]::new($logoX - 4, $logoY - 4, $logoSize + 8, $logoSize + 8)
$brushLogoBorder = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)
$g.FillEllipse($brushLogoBorder, $borderRect)
$brushLogoBorder.Dispose()

$penLogoGreen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(16, 185, 129), 3.5)
$g.DrawEllipse($penLogoGreen, $logoX, $logoY, $logoSize, $logoSize)
$penLogoGreen.Dispose()

$clipPath = [System.Drawing.Drawing2D.GraphicsPath]::new()
$clipPath.AddEllipse($logoX, $logoY, $logoSize, $logoSize)
$g.SetClip($clipPath)
$g.DrawImage($logoImg, $logoX, $logoY, $logoSize, $logoSize)
$g.ResetClip()
$clipPath.Dispose()
$logoImg.Dispose()

# ==============================================================================
# LAYER 4: BRAND HEADLINES & TYPOGRAPHY
# ==============================================================================
$textX = 250

# Tagline pill: TAMPICO Y MADERO • SÁBADOS Y DOMINGOS
$tagPillRect = [System.Drawing.RectangleF]::new($textX, 110, 295, 22)
$brushTagBg = [System.Drawing.Drawing2D.LinearGradientBrush]::new($tagPillRect, [System.Drawing.Color]::FromArgb(240, 2, 132, 199), [System.Drawing.Color]::FromArgb(240, 14, 165, 233), 0.0)
$penTagBorder = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(186, 230, 253), 1.5)
Draw-RoundedBox $g $brushTagBg $penTagBorder $tagPillRect 11 $true
$penTagBorder.Dispose()
$fontTag = [System.Drawing.Font]::new("Segoe UI Black", 8, [System.Drawing.FontStyle]::Bold)
$g.DrawString("TAMPICO Y MADERO $bul S${uA}BADOS Y DOMINGOS", $fontTag, $brushWhite, [float]($textX + 147.5), [float]121, $sfCenter)

# Main Title: LA GARZA AGUACHILERA
$fontTitle = [System.Drawing.Font]::new("Segoe UI Black", 19, [System.Drawing.FontStyle]::Bold)
$penTextOutline = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(5, 14, 26), 5)
$penTextOutline.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
Draw-OutlinedText $g "LA GARZA AGUACHILERA" $fontTitle $brushWhite $penTextOutline $textX 135

# Subtitle: TOSTIAGUACHILE VERDE TRADICIONAL
$fontSub = [System.Drawing.Font]::new("Segoe UI Black", 12.5, [System.Drawing.FontStyle]::Bold)
$brushMint = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(52, 211, 153))
Draw-OutlinedText $g "TOSTIAGUACHILE VERDE TRADICIONAL" $fontSub $brushMint $penTextOutline $textX 169

# High-Voltage Price Pill: ★ $170 MXN • ~100g CAMARÓN ★
$pillPriceRect = [System.Drawing.RectangleF]::new($textX, 196, 295, 30)
$brushPriceBg = [System.Drawing.Drawing2D.LinearGradientBrush]::new($pillPriceRect, [System.Drawing.Color]::FromArgb(249, 115, 22), [System.Drawing.Color]::FromArgb(234, 88, 12), 0.0)
$penPriceBorder = [System.Drawing.Pen]::new([System.Drawing.Color]::White, 2.2)
Draw-RoundedBox $g $brushPriceBg $penPriceBorder $pillPriceRect 14 $true
$fontPrice = [System.Drawing.Font]::new("Segoe UI Black", 10.5, [System.Drawing.FontStyle]::Bold)
$priceStr = "$star `$170 MXN $bul ~100g CAMAR${uO}N $star"
$g.DrawString($priceStr, $fontPrice, $brushWhite, [float]($textX + 147.5), [float]211, $sfCenter)

# ==============================================================================
# LAYER 5: MANDATORY FRESHNESS STATEMENT CARD (Frosted Glassmorphism Finish)
# ==============================================================================
$cardRect = [System.Drawing.RectangleF]::new(135, 236, 410, 84)
$brushCardBg = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
    $cardRect,
    [System.Drawing.Color]::FromArgb(244, 10, 24, 42),
    [System.Drawing.Color]::FromArgb(248, 6, 16, 30),
    90.0
)
$penCardBorder = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(254, 240, 138), 2)
Draw-RoundedBox $g $brushCardBg $penCardBorder $cardRect 15 $true

# Seal header inside card
$sealRect = [System.Drawing.RectangleF]::new(148, 243, 185, 18)
$brushSeal = [System.Drawing.Drawing2D.LinearGradientBrush]::new($sealRect, [System.Drawing.Color]::FromArgb(16, 185, 129), [System.Drawing.Color]::FromArgb(5, 150, 105), 0.0)
Draw-RoundedBox $g $brushSeal $null $sealRect 9 $false
$fontSeal = [System.Drawing.Font]::new("Segoe UI Black", 7.5, [System.Drawing.FontStyle]::Bold)
$g.DrawString("SELLO OFICIAL DE FRESCURA", $fontSeal, $brushWhite, [float]240.5, [float]252, $sfCenter)

# Mandatory freshness statement text (100% Unicode safe with « and »)
$fontStmt1 = [System.Drawing.Font]::new("Segoe UI Black", 12, [System.Drawing.FontStyle]::Bold)
$fontStmt2 = [System.Drawing.Font]::new("Segoe UI Black", 12, [System.Drawing.FontStyle]::Bold)
$fresh1 = "${qL}El producto es preparado frente a usted"
$fresh2 = "para corroborar su frescura${qR}"
$g.DrawString($fresh1, $fontStmt1, $brushYellow, [float]340, [float]274, $sfCenter)
$g.DrawString($fresh2, $fontStmt2, $brushWhite, [float]340, [float]298, $sfCenter)

# Bullets & Highlights Box (Glassmorphic dark card)
$bulletBoxRect = [System.Drawing.RectangleF]::new(135, 328, 410, 62)
$brushBulletBg = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(215, 6, 16, 28))
$penBulletBorder = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(51, 65, 85), 1.5)
Draw-RoundedBox $g $brushBulletBg $penBulletBorder $bulletBoxRect 13 $true
$penBulletBorder.Dispose()

$fontBullet = [System.Drawing.Font]::new("Segoe UI", 9.2, [System.Drawing.FontStyle]::Bold)
$brushGray = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(226, 232, 240))
$brushLime = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(74, 222, 128))

$bullet1 = "$bul Camar${lO}n fresco del Golfo en corte mariposa"
$bullet2 = "$bul Salsa verde serrano, pepino, cebolla y lim${lO}n Colima"
$bullet3 = "$bul Preparado al instante en tu puerta: ${iE}100% crujiente!"

$g.DrawString($bullet1, $fontBullet, $brushLime, [float]146, [float]334)
$g.DrawString($bullet2, $fontBullet, $brushGray, [float]146, [float]351)
$g.DrawString($bullet3, $fontBullet, $brushGray, [float]146, [float]368)

# ==============================================================================
# LAYER 6: WHATSAPP & DELIVERY CTA (Franchise 3D Pill)
# ==============================================================================
$waRect = [System.Drawing.RectangleF]::new(135, 398, 410, 68)
$brushWa = [System.Drawing.Drawing2D.LinearGradientBrush]::new($waRect, [System.Drawing.Color]::FromArgb(37, 211, 102), [System.Drawing.Color]::FromArgb(18, 140, 62), 90.0)
$penWa = [System.Drawing.Pen]::new([System.Drawing.Color]::White, 2.5)
Draw-RoundedBox $g $brushWa $penWa $waRect 20 $true

$fontWaTitle = [System.Drawing.Font]::new("Segoe UI Black", 10, [System.Drawing.FontStyle]::Bold)
$fontWaNum   = [System.Drawing.Font]::new("Segoe UI Black", 22, [System.Drawing.FontStyle]::Bold)
$penWaNumOutline = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(10, 80, 36), 4)
$penWaNumOutline.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round

$g.DrawString("PEDIDOS Y APARTADOS POR WHATSAPP", $fontWaTitle, $brushWhite, [float]340, [float]414, $sfCenter)
Draw-OutlinedText $g "833 252 09 88" $fontWaNum $brushWhite $penWaNumOutline 340 444 $sfCenter

# Delivery zone banner (Cyan Glassmorphism)
$delivRect = [System.Drawing.RectangleF]::new(135, 474, 410, 32)
$brushDeliv = [System.Drawing.Drawing2D.LinearGradientBrush]::new($delivRect, [System.Drawing.Color]::FromArgb(240, 2, 132, 199), [System.Drawing.Color]::FromArgb(240, 3, 105, 161), 0.0)
$penDeliv = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(125, 211, 252), 1.8)
Draw-RoundedBox $g $brushDeliv $penDeliv $delivRect 14 $true
$fontDeliv = [System.Drawing.Font]::new("Segoe UI Black", 9.2, [System.Drawing.FontStyle]::Bold)
$delivStr = "ENTREGAS FINES DE SEMANA EN TAMPICO Y MADERO"
$g.DrawString($delivStr, $fontDeliv, $brushWhite, [float]340, [float]490, $sfCenter)

# ==============================================================================
# LAYER 7: FOREGROUND CRUNCH STICKER (Drawn ON TOP of everything!)
# ==============================================================================
$stateCrunch = $g.Save()
$g.TranslateTransform(575, 252)
$g.RotateTransform(-12)

# Shadow
$crunchRect = [System.Drawing.RectangleF]::new(-64, -17, 128, 34)
$crunchShadow = [System.Drawing.RectangleF]::new(-60, -13, 128, 34)
$brushCShadow = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(140, 0, 0, 0))
Draw-RoundedBox $g $brushCShadow $null $crunchShadow 12 $false
$brushCShadow.Dispose()

$brushCrunch = [System.Drawing.Drawing2D.LinearGradientBrush]::new($crunchRect, [System.Drawing.Color]::FromArgb(225, 29, 72), [System.Drawing.Color]::FromArgb(190, 18, 60), 90.0)
$penCrunch = [System.Drawing.Pen]::new([System.Drawing.Color]::White, 2.2)
Draw-RoundedBox $g $brushCrunch $penCrunch $crunchRect 12 $false

$fontCrunch1 = [System.Drawing.Font]::new("Impact", 12, [System.Drawing.FontStyle]::Bold)
$fontCrunch2 = [System.Drawing.Font]::new("Segoe UI Black", 7, [System.Drawing.FontStyle]::Bold)
$g.DrawString("${iE}CRUJIENTE!", $fontCrunch1, $brushYellow, [float]0, [float]-6, $sfCenter)
$g.DrawString("AL INSTANTE", $fontCrunch2, $brushWhite, [float]0, [float]7, $sfCenter)
$g.Restore($stateCrunch)

# ==============================================================================
# SAVE MASTER OUTPUTS (Root & contenido_redes\imagenes)
# ==============================================================================
$finalPath1 = "d:\AG\la garza aguachilera\flyer_portada_verde.png"
$finalPath2 = "d:\AG\la garza aguachilera\contenido_redes\imagenes\flyer_portada_verde.png"

$bmp.Save($finalPath1, [System.Drawing.Imaging.ImageFormat]::Png)

$destDir = Split-Path $finalPath2 -Parent
if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
Copy-Item $finalPath1 $finalPath2 -Force

$g.Dispose()
$bmp.Dispose()
Write-Host "PORTADA FACEBOOK MASTER GENERADA Y GUARDADA CON EXITO (1200x630 px)!" -ForegroundColor Green
