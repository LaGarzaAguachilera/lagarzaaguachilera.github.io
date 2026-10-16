Add-Type -AssemblyName System.Drawing

function Draw-StickerWithShadow([System.Drawing.Graphics]$g, [string]$imgPath, [float]$x, [float]$y, [float]$w, [float]$h, [float]$angle = 0) {
    if (-not (Test-Path $imgPath)) { return }
    $img = [System.Drawing.Image]::FromFile($imgPath)
    
    $cx = $x + $w / 2
    $cy = $y + $h / 2
    
    # Draw soft shadow first
    $stateSh = $g.Save()
    $g.TranslateTransform($cx + 6, $cy + 8)
    if ($angle -ne 0) { $g.RotateTransform($angle) }
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    
    $cm = [System.Drawing.Imaging.ColorMatrix]::new(@(
        @(0, 0, 0, 0, 0),
        @(0, 0, 0, 0, 0),
        @(0, 0, 0, 0, 0),
        @(0, 0, 0, 0.45, 0),
        @(0, 0, 0, 0, 1)
    ))
    $ia = [System.Drawing.Imaging.ImageAttributes]::new()
    $ia.SetColorMatrix($cm)
    $rect = [System.Drawing.RectangleF]::new(-$w / 2, -$h / 2, $w, $h)
    $g.DrawImage($img, [System.Drawing.Rectangle]::new(-$w/2, -$h/2, $w, $h), 0, 0, $img.Width, $img.Height, [System.Drawing.GraphicsUnit]::Pixel, $ia)
    $g.Restore($stateSh)
    $ia.Dispose()
    
    # Draw actual sticker
    $state = $g.Save()
    $g.TranslateTransform($cx, $cy)
    if ($angle -ne 0) { $g.RotateTransform($angle) }
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
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

# 1200 x 630 canvas
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
}

# 2. Gradient Vignette on Left (Width: 680px) to ensure perfect text readability
$vignetteRect = [System.Drawing.Rectangle]::new(0, 0, 680, 630)
$brushVignette = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
    $vignetteRect,
    [System.Drawing.Color]::FromArgb(242, 7, 18, 34),
    [System.Drawing.Color]::FromArgb(0, 7, 18, 34),
    0.0
)
$g.FillRectangle($brushVignette, $vignetteRect)
$brushVignette.Dispose()

# Top vignette for header bar
$topVignetteRect = [System.Drawing.Rectangle]::new(0, 0, 1200, 200)
$brushTopVignette = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
    $topVignetteRect,
    [System.Drawing.Color]::FromArgb(190, 5, 14, 28),
    [System.Drawing.Color]::FromArgb(0, 5, 14, 28),
    90.0
)
$g.FillRectangle($brushTopVignette, $topVignetteRect)
$brushTopVignette.Dispose()

# 3. EASTER EGGS STICKERS
# UFO abducting lime (Top-Right / Sky)
Draw-StickerWithShadow $g "d:\AG\la garza aguachilera\clean_ovni.png" 690 15 220 220 -6

# UFO Comic Bubble
$ufoBadgeRect = [System.Drawing.RectangleF]::new(695, 195, 215, 36)
$brushUfoBadge = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(254, 240, 138))
$penUfoBadge = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(13, 34, 56), 2.5)
Draw-RoundedBox $g $brushUfoBadge $penUfoBadge $ufoBadgeRect 18
$fontUfo = [System.Drawing.Font]::new("Segoe UI Black", 11.5, [System.Drawing.FontStyle]::Bold)
$brushDark = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(13, 34, 56))
$sfCenter = [System.Drawing.StringFormat]::new()
$sfCenter.Alignment = [System.Drawing.StringAlignment]::Center
$sfCenter.LineAlignment = [System.Drawing.StringAlignment]::Center
$g.DrawString("¡ABDUCIDOS POR EL SABOR!", $fontUfo, $brushDark, [float]802, [float]213, $sfCenter)

# Juancho crocodile (Right edge, well placed inside bounds)
Draw-StickerWithShadow $g "d:\AG\la garza aguachilera\clean_juancho.png" 910 175 270 270 3

# Juancho badge
$juanchoBadgeRect = [System.Drawing.RectangleF]::new(935, 415, 230, 36)
$brushJBadge = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(16, 185, 129))
$penJBadge = [System.Drawing.Pen]::new([System.Drawing.Color]::White, 2.5)
Draw-RoundedBox $g $brushJBadge $penJBadge $juanchoBadgeRect 18
$fontJ = [System.Drawing.Font]::new("Segoe UI Black", 11, [System.Drawing.FontStyle]::Bold)
$brushWhite = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)
$g.DrawString("JUANCHO • PLAYA MIRAMAR", $fontJ, $brushWhite, [float]1050, [float]433, $sfCenter)

# Food Hero (Center)
Draw-StickerWithShadow $g "d:\AG\la garza aguachilera\clean_comida.png" 470 200 390 390 -3

# Retouch the food bag text with authentic "SALSA VERDE" and "100% REDONDOS" badge!
$stateBag = $g.Save()
$g.TranslateTransform(635, 490)
$g.RotateTransform(-3)
$bagPatchRect = [System.Drawing.RectangleF]::new(-85, -20, 170, 42)
$brushBagPatch = [System.Drawing.Drawing2D.LinearGradientBrush]::new($bagPatchRect, [System.Drawing.Color]::FromArgb(220, 20, 60), [System.Drawing.Color]::FromArgb(180, 10, 40), 0.0)
$penBagPatch = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(254, 240, 138), 2)
Draw-RoundedBox $g $brushBagPatch $penBagPatch $bagPatchRect 14
$fontBagA = [System.Drawing.Font]::new("Impact", 15, [System.Drawing.FontStyle]::Bold)
$fontBagB = [System.Drawing.Font]::new("Segoe UI Black", 9, [System.Drawing.FontStyle]::Bold)
$brushYellow = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(254, 240, 138))
$g.DrawString("SALSA VERDE", $fontBagA, $brushYellow, [float]0, [float]-6, $sfCenter)
$g.DrawString("TOSTITOS SALSA VERDE", $fontBagB, $brushWhite, [float]0, [float]11, $sfCenter)
$g.Restore($stateBag)

# Floating Crunch Badge on top of dish
$stateCrunch = $g.Save()
$g.TranslateTransform(500, 230)
$g.RotateTransform(-12)
$crunchRect = [System.Drawing.RectangleF]::new(-75, -22, 150, 44)
$brushCrunch = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(249, 115, 22))
$penCrunch = [System.Drawing.Pen]::new([System.Drawing.Color]::White, 2.5)
Draw-RoundedBox $g $brushCrunch $penCrunch $crunchRect 15
$fontCrunch1 = [System.Drawing.Font]::new("Impact", 16, [System.Drawing.FontStyle]::Bold)
$fontCrunch2 = [System.Drawing.Font]::new("Segoe UI Black", 8.5, [System.Drawing.FontStyle]::Bold)
$g.DrawString("¡CRUJIENTE!", $fontCrunch1, $brushYellow, [float]0, [float]-8, $sfCenter)
$g.DrawString("NUNCA REMOJADOS", $fontCrunch2, $brushWhite, [float]0, [float]9, $sfCenter)
$g.Restore($stateCrunch)

# Mapache de las escolleras (Bottom right)
Draw-StickerWithShadow $g "d:\AG\la garza aguachilera\clean_mapache.png" 780 395 220 220 5

# Mapache badge
$mapacheBadgeRect = [System.Drawing.RectangleF]::new(785, 575, 215, 34)
$brushMBadge = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(249, 115, 22))
$penMBadge = [System.Drawing.Pen]::new([System.Drawing.Color]::White, 2.5)
Draw-RoundedBox $g $brushMBadge $penMBadge $mapacheBadgeRect 17
$fontM = [System.Drawing.Font]::new("Segoe UI Black", 10, [System.Drawing.FontStyle]::Bold)
$g.DrawString("MAPACHE DE LAS ESCOLLERAS", $fontM, $brushWhite, [float]892, [float]592, $sfCenter)

# 4. OFFICIAL LOGO BADGE (Top Left)
$logoPath = "d:\AG\la garza aguachilera\La garza aguachilera.jpeg"
$logoImg = [System.Drawing.Image]::FromFile($logoPath)
$logoX = 35
$logoY = 22
$logoSize = 160

# Circular shadow & white sticker border
$shadowRect = [System.Drawing.Rectangle]::new($logoX - 4, $logoY + 4, $logoSize + 8, $logoSize + 8)
$brushLogoShadow = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(120, 0, 0, 0))
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
$tagPillRect = [System.Drawing.RectangleF]::new($textX, 26, 320, 26)
$brushTagBg = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(240, 2, 132, 199))
Draw-RoundedBox $g $brushTagBg $null $tagPillRect 13
$fontTag = [System.Drawing.Font]::new("Segoe UI Black", 9.5, [System.Drawing.FontStyle]::Bold)
$g.DrawString("servicio exclusivo a domicilio • TAMPICO & MADERO", $fontTag, $brushWhite, [float]($textX + 160), [float]39, $sfCenter)

# Main Title: LA GARZA AGUACHILERA
$fontTitle = [System.Drawing.Font]::new("Segoe UI Black", 30, [System.Drawing.FontStyle]::Bold)
$penTextOutline = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(5, 14, 26), 6)
Draw-OutlinedText $g "LA GARZA AGUACHILERA" $fontTitle $brushWhite $penTextOutline $textX 56

# Subtitle: TOSTIAGUACHILE VERDE TRADICIONAL
$fontSub = [System.Drawing.Font]::new("Segoe UI Black", 19, [System.Drawing.FontStyle]::Bold)
$brushMint = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(52, 211, 153))
Draw-OutlinedText $g "TOSTIAGUACHILE VERDE TRADICIONAL" $fontSub $brushMint $penTextOutline $textX 106

# Price and Redondos Feature Tag
$pillPriceRect = [System.Drawing.RectangleF]::new($textX, 148, 330, 40)
$brushPriceBg = [System.Drawing.Drawing2D.LinearGradientBrush]::new($pillPriceRect, [System.Drawing.Color]::FromArgb(245, 158, 11), [System.Drawing.Color]::FromArgb(217, 119, 6), 0.0)
$penPriceBorder = [System.Drawing.Pen]::new([System.Drawing.Color]::White, 2.5)
Draw-RoundedBox $g $brushPriceBg $penPriceBorder $pillPriceRect 20
$fontPrice = [System.Drawing.Font]::new("Segoe UI Black", 15.5, [System.Drawing.FontStyle]::Bold)
$g.DrawString("`$170 MXN  •  TOSTITOS SALSA VERDE", $fontPrice, $brushWhite, [float]($textX + 165), [float]168, $sfCenter)

# 6. MANDATORY FRESHNESS STATEMENT CARD
$cardRect = [System.Drawing.RectangleF]::new(35, 204, 465, 118)
$brushCardBg = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(240, 10, 24, 42))
$penCardBorder = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(254, 240, 138), 2.5)
Draw-RoundedBox $g $brushCardBg $penCardBorder $cardRect 20

# Seal header inside card
$sealRect = [System.Drawing.RectangleF]::new(50, 214, 220, 22)
$brushSeal = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(16, 185, 129))
Draw-RoundedBox $g $brushSeal $null $sealRect 11
$fontSeal = [System.Drawing.Font]::new("Segoe UI Black", 8.5, [System.Drawing.FontStyle]::Bold)
$g.DrawString("SELLO OFICIAL DE FRESCURA", $fontSeal, $brushWhite, [float]160, [float]225, $sfCenter)

# Mandatory freshness text
$fontStmt1 = [System.Drawing.Font]::new("Segoe UI Black", 14.5, [System.Drawing.FontStyle]::Bold)
$fontStmt2 = [System.Drawing.Font]::new("Segoe UI Black", 14.5, [System.Drawing.FontStyle]::Bold)
$g.DrawString("«El producto es preparado frente a usted", $fontStmt1, $brushYellow, [float]267, [float]254, $sfCenter)
$g.DrawString("para corroborar su frescura»", $fontStmt2, $brushWhite, [float]267, [float]285, $sfCenter)

# 7. BULLETS & HIGHLIGHTS
$bulletBoxRect = [System.Drawing.RectangleF]::new(35, 334, 465, 78)
$brushBulletBg = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(200, 6, 16, 28))
Draw-RoundedBox $g $brushBulletBg $null $bulletBoxRect 16
$fontBullet = [System.Drawing.Font]::new("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$brushGray = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(226, 232, 240))
$brushLime = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(74, 222, 128))
$g.DrawString("• Camarón fresco del Golfo en corte mariposa", $fontBullet, $brushLime, [float]50, [float]344)
$g.DrawString("• Salsa verde serrano, pepino, cebolla y limón Colima", $fontBullet, $brushGray, [float]50, [float]366)
$g.DrawString("• preparado al instante en tu puerta: ¡Tostitos 100% crujientes!", $fontBullet, $brushGray, [float]50, [float]388)

# 8. WHATSAPP & DELIVERY CTA
$waRect = [System.Drawing.RectangleF]::new(35, 424, 465, 96)
$brushWa = [System.Drawing.Drawing2D.LinearGradientBrush]::new($waRect, [System.Drawing.Color]::FromArgb(37, 211, 102), [System.Drawing.Color]::FromArgb(22, 163, 74), 0.0)
$penWa = [System.Drawing.Pen]::new([System.Drawing.Color]::White, 3)
Draw-RoundedBox $g $brushWa $penWa $waRect 28

$fontWaTitle = [System.Drawing.Font]::new("Segoe UI Black", 13, [System.Drawing.FontStyle]::Bold)
$fontWaNum = [System.Drawing.Font]::new("Segoe UI Black", 30, [System.Drawing.FontStyle]::Bold)
$g.DrawString("PEDIDOS Y APARTADOS POR WHATSAPP", $fontWaTitle, $brushWhite, [float]267, [float]446, $sfCenter)
$g.DrawString("833 252 09 88", $fontWaNum, $brushWhite, [float]267, [float]487, $sfCenter)

# Delivery zone footer banner
$delivRect = [System.Drawing.RectangleF]::new(35, 532, 465, 42)
$brushDeliv = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(240, 2, 132, 199))
$penDeliv = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(125, 211, 252), 2)
Draw-RoundedBox $g $brushDeliv $penDeliv $delivRect 18
$fontDeliv = [System.Drawing.Font]::new("Segoe UI Black", 11.5, [System.Drawing.FontStyle]::Bold)
$g.DrawString("ENTREGAS FINES DE SEMANA EN TAMPICO Y MADERO", $fontDeliv, $brushWhite, [float]267, [float]553, $sfCenter)

# Save result
$testPath = "d:\AG\la garza aguachilera\flyer_portada_verde_v2.png"
$bmp.Save($testPath, [System.Drawing.Imaging.ImageFormat]::Png)

$g.Dispose()
$bmp.Dispose()
Write-Host "Composed banner v2 saved to $testPath"
