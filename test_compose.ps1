Add-Type -AssemblyName System.Drawing

function Draw-Sticker([System.Drawing.Graphics]$g, [string]$imgPath, [float]$x, [float]$y, [float]$w, [float]$h, [float]$angle = 0) {
    if (-not (Test-Path $imgPath)) { return }
    $img = [System.Drawing.Image]::FromFile($imgPath)
    $state = $g.Save()
    
    $cx = $x + $w / 2
    $cy = $y + $h / 2
    $g.TranslateTransform($cx, $cy)
    if ($angle -ne 0) {
        $g.RotateTransform($angle)
    }
    
    # Draw drop shadow
    $shadowBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(90, 0, 0, 0))
    # We draw image with high quality
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    
    # Shadow offset
    $rect = [System.Drawing.RectangleF]::new(-$w / 2, -$h / 2, $w, $h)
    $g.DrawImage($img, $rect)
    
    $g.Restore($state)
    $img.Dispose()
}

function Draw-RoundedBox([System.Drawing.Graphics]$g, [System.Drawing.Brush]$brush, [System.Drawing.Pen]$pen, [System.Drawing.RectangleF]$rect, [float]$radius) {
    $path = [System.Drawing.Drawing2D.GraphicsPath]::new()
    $d = $radius * 2
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

# Canvas 1200 x 630
$bmp = [System.Drawing.Bitmap]::new(1200, 630, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

# 1. Background image
$bgPath = "C:\Users\aleja\.gemini\antigravity\brain\cc8cc15d-5c1d-4b14-93d0-54cd561c6a33\portada_bg_tampico_skyline_1792107773833.jpg"
if (Test-Path $bgPath) {
    $bgImg = [System.Drawing.Image]::FromFile($bgPath)
    $g.DrawImage($bgImg, 0, 0, 1200, 630)
    $bgImg.Dispose()
} else {
    $g.Clear([System.Drawing.Color]::FromArgb(10, 26, 46))
}

# 2. Left dark gradient vignette for readable typography
$vignetteRect = [System.Drawing.Rectangle]::new(0, 0, 720, 630)
$brushVignette = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
    $vignetteRect,
    [System.Drawing.Color]::FromArgb(235, 7, 19, 36),
    [System.Drawing.Color]::FromArgb(0, 7, 19, 36),
    0.0
)
$g.FillRectangle($brushVignette, $vignetteRect)
$brushVignette.Dispose()

# Top vignette for logo & title bar
$topVignetteRect = [System.Drawing.Rectangle]::new(0, 0, 1200, 240)
$brushTopVignette = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
    $topVignetteRect,
    [System.Drawing.Color]::FromArgb(180, 5, 15, 30),
    [System.Drawing.Color]::FromArgb(0, 5, 15, 30),
    90.0
)
$g.FillRectangle($brushTopVignette, $topVignetteRect)
$brushTopVignette.Dispose()

# 3. DRAW STICKERS (Background layer before text badges)
# UFO abducting lime (Top right)
Draw-Sticker $g "d:\AG\la garza aguachilera\sticker_ovni.png" 690 10 240 240 -6

# UFO comic speech bubble "¡Abducidos por el sabor!"
$ufoBadgeRect = [System.Drawing.RectangleF]::new(700, 190, 215, 38)
$brushUfoBadge = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(254, 240, 138))
$penUfoBadge = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(13, 34, 56), 3)
Draw-RoundedBox $g $brushUfoBadge $penUfoBadge $ufoBadgeRect 18
$fontUfo = [System.Drawing.Font]::new("Segoe UI Black", 12, [System.Drawing.FontStyle]::Bold)
$brushDark = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(13, 34, 56))
$sfCenter = [System.Drawing.StringFormat]::new()
$sfCenter.Alignment = [System.Drawing.StringAlignment]::Center
$sfCenter.LineAlignment = [System.Drawing.StringAlignment]::Center
$g.DrawString("🛸 ¡ABDUCIDOS POR EL SABOR!", $fontUfo, $brushDark, [float]807, [float]209, $sfCenter)

# Juancho crocodile (Right)
Draw-Sticker $g "d:\AG\la garza aguachilera\sticker_juancho.png" 910 180 280 280 4

# Juancho badge
$juanchoBadgeRect = [System.Drawing.RectangleF]::new(940, 435, 230, 36)
$brushJBadge = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(16, 185, 129))
$penJBadge = [System.Drawing.Pen]::new([System.Drawing.Color]::White, 3)
Draw-RoundedBox $g $brushJBadge $penJBadge $juanchoBadgeRect 18
$fontJ = [System.Drawing.Font]::new("Segoe UI Black", 11, [System.Drawing.FontStyle]::Bold)
$brushWhite = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)
$g.DrawString("🐊 JUANCHO • PLAYA MIRAMAR", $fontJ, $brushWhite, [float]1055, [float]453, $sfCenter)

# Food Hero (Center-Right)
Draw-Sticker $g "d:\AG\la garza aguachilera\sticker_comida.png" 490 200 400 400 -4

# Mapache de las escolleras (Bottom right, overlapping playfully)
Draw-Sticker $g "d:\AG\la garza aguachilera\sticker_mapache.png" 820 390 230 230 6

# Mapache badge
$mapacheBadgeRect = [System.Drawing.RectangleF]::new(830, 580, 210, 34)
$brushMBadge = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(249, 115, 22))
$penMBadge = [System.Drawing.Pen]::new([System.Drawing.Color]::White, 3)
Draw-RoundedBox $g $brushMBadge $penMBadge $mapacheBadgeRect 16
$fontM = [System.Drawing.Font]::new("Segoe UI Black", 10, [System.Drawing.FontStyle]::Bold)
$g.DrawString("🦝 MAPACHE DE LAS ESCOLLERAS", $fontM, $brushWhite, [float]935, [float]597, $sfCenter)

# 4. OFFICIAL LOGO BADGE (Top Left)
$logoPath = "d:\AG\la garza aguachilera\La garza aguachilera.jpeg"
$logoImg = [System.Drawing.Image]::FromFile($logoPath)
$logoX = 35
$logoY = 25
$logoSize = 160

# Circular shadow & white sticker border
$shadowRect = [System.Drawing.Rectangle]::new($logoX - 4, $logoY + 4, $logoSize + 8, $logoSize + 8)
$brushLogoShadow = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(100, 0, 0, 0))
$g.FillEllipse($brushLogoShadow, $shadowRect)

$borderRect = [System.Drawing.Rectangle]::new($logoX - 5, $logoY - 5, $logoSize + 10, $logoSize + 10)
$brushLogoBorder = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)
$g.FillEllipse($brushLogoBorder, $borderRect)

$penLogoGreen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(16, 185, 129), 5)
$g.DrawEllipse($penLogoGreen, $logoX, $logoY, $logoSize, $logoSize)

$clipPath = [System.Drawing.Drawing2D.GraphicsPath]::new()
$clipPath.AddEllipse($logoX, $logoY, $logoSize, $logoSize)
$g.SetClip($clipPath)
$g.DrawImage($logoImg, $logoX, $logoY, $logoSize, $logoSize)
$g.ResetClip()
$clipPath.Dispose()
$logoImg.Dispose()

# 5. BRAND HEADLINES & TYPOGRAPHY
$textX = 215

# Tagline pill
$tagPillRect = [System.Drawing.RectangleF]::new($textX, 28, 335, 28)
$brushTagBg = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(230, 2, 132, 199))
Draw-RoundedBox $g $brushTagBg $null $tagPillRect 14
$fontTag = [System.Drawing.Font]::new("Segoe UI Black", 9.5, [System.Drawing.FontStyle]::Bold)
$g.DrawString("⚡ BOTANA DE CULTO • TAMPICO & MADERO", $fontTag, $brushWhite, [float]($textX + 167), [float]42, $sfCenter)

# Main Title: LA GARZA AGUACHILERA
$fontTitle = [System.Drawing.Font]::new("Impact", 36, [System.Drawing.FontStyle]::Bold)
$penTextOutline = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(8, 20, 36), 6)
Draw-OutlinedText $g "LA GARZA AGUACHILERA" $fontTitle $brushWhite $penTextOutline $textX 58

# Subtitle: TOSTIAGUACHILE VERDE TRADICIONAL
$fontSub = [System.Drawing.Font]::new("Segoe UI Black", 21, [System.Drawing.FontStyle]::Bold)
$brushMint = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(52, 211, 153))
Draw-OutlinedText $g "TOSTIAGUACHILE VERDE TRADICIONAL" $fontSub $brushMint $penTextOutline $textX 115

# Price and Redondos Feature Tag
$pillPriceRect = [System.Drawing.RectangleF]::new($textX, 155, 340, 42)
$brushPriceBg = [System.Drawing.Drawing2D.LinearGradientBrush]::new($pillPriceRect, [System.Drawing.Color]::FromArgb(245, 158, 11), [System.Drawing.Color]::FromArgb(217, 119, 6), 0.0)
$penPriceBorder = [System.Drawing.Pen]::new([System.Drawing.Color]::White, 2.5)
Draw-RoundedBox $g $brushPriceBg $penPriceBorder $pillPriceRect 21
$fontPrice = [System.Drawing.Font]::new("Segoe UI Black", 16, [System.Drawing.FontStyle]::Bold)
$g.DrawString("`$150 MXN  •  TOSTITOS SALSA VERDE", $fontPrice, $brushWhite, [float]($textX + 170), [float]176, $sfCenter)

# 6. MANDATORY FRESHNESS STATEMENT CARD
$cardRect = [System.Drawing.RectangleF]::new(35, 215, 490, 115)
$brushCardBg = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(235, 11, 26, 44))
$penCardBorder = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(254, 240, 138), 2.5)
Draw-RoundedBox $g $brushCardBg $penCardBorder $cardRect 20

# Badge inside card: SELLO DE GARANTÍA
$sealRect = [System.Drawing.RectangleF]::new(50, 226, 210, 22)
$brushSeal = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(16, 185, 129))
Draw-RoundedBox $g $brushSeal $null $sealRect 11
$fontSeal = [System.Drawing.Font]::new("Segoe UI Black", 8.5, [System.Drawing.FontStyle]::Bold)
$g.DrawString("⭐ COMPROMISO DE FRESCURA", $fontSeal, $brushWhite, [float]155, [float]237, $sfCenter)

# Mandatory freshness text
$fontStmt1 = [System.Drawing.Font]::new("Segoe UI Black", 14.5, [System.Drawing.FontStyle]::Bold)
$fontStmt2 = [System.Drawing.Font]::new("Segoe UI Black", 14.5, [System.Drawing.FontStyle]::Bold)
$brushYellow = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(254, 240, 138))
$g.DrawString("«El producto es preparado frente a usted", $fontStmt1, $brushYellow, [float]280, [float]265, $sfCenter)
$g.DrawString("para corroborar su frescura»", $fontStmt2, $brushWhite, [float]280, [float]296, $sfCenter)

# 7. BULLETS & HIGHLIGHTS
$bulletBoxRect = [System.Drawing.RectangleF]::new(35, 345, 490, 75)
$brushBulletBg = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(190, 6, 16, 28))
Draw-RoundedBox $g $brushBulletBg $null $bulletBoxRect 16
$fontBullet = [System.Drawing.Font]::new("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$brushGray = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(226, 232, 240))
$brushLime = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(74, 222, 128))
$g.DrawString("✔ Camarón fresco del Golfo en corte mariposa", $fontBullet, $brushLime, [float]50, [float]354)
$g.DrawString("✔ Salsa verde serrano, pepino, cebolla y limón Colima", $fontBullet, $brushGray, [float]50, [float]376)
$g.DrawString("✔ Caldo servido al instante: ¡Cero tostitos remojados!", $fontBullet, $brushGray, [float]50, [float]398)

# 8. WHATSAPP & DELIVERY CTA
$waRect = [System.Drawing.RectangleF]::new(35, 435, 490, 90)
$brushWa = [System.Drawing.Drawing2D.LinearGradientBrush]::new($waRect, [System.Drawing.Color]::FromArgb(37, 211, 102), [System.Drawing.Color]::FromArgb(22, 163, 74), 0.0)
$penWa = [System.Drawing.Pen]::new([System.Drawing.Color]::White, 3)
Draw-RoundedBox $g $brushWa $penWa $waRect 28

$fontWaTitle = [System.Drawing.Font]::new("Segoe UI Black", 12.5, [System.Drawing.FontStyle]::Bold)
$fontWaNum = [System.Drawing.Font]::new("Impact", 28, [System.Drawing.FontStyle]::Bold)
$g.DrawString("PEDIDOS Y APARTADOS POR WHATSAPP", $fontWaTitle, $brushWhite, [float]280, [float]455, $sfCenter)
$g.DrawString("833 252 09 88", $fontWaNum, $brushWhite, [float]280, [float]494, $sfCenter)

# Delivery zone footer banner
$delivRect = [System.Drawing.RectangleF]::new(35, 540, 490, 42)
$brushDeliv = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(240, 2, 132, 199))
$penDeliv = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(125, 211, 252), 2)
Draw-RoundedBox $g $brushDeliv $penDeliv $delivRect 18
$fontDeliv = [System.Drawing.Font]::new("Segoe UI Black", 11.5, [System.Drawing.FontStyle]::Bold)
$g.DrawString("🛵 ENTREGAS FINES DE SEMANA EN TAMPICO Y MADERO", $fontDeliv, $brushWhite, [float]280, [float]561, $sfCenter)

# Save result
$testPath = "d:\AG\la garza aguachilera\flyer_portada_verde_test.png"
$bmp.Save($testPath, [System.Drawing.Imaging.ImageFormat]::Png)

$g.Dispose()
$bmp.Dispose()
Write-Host "Composed banner test saved to $testPath"
