# ==============================================================================
# GENERADOR DE OVERLAYS Y STICKERS DINÁMICOS HD (1080 x 1920)
# La Garza Aguachilera - Estilo Franquicia Comercial con Acabado Premium
# ==============================================================================
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

Add-Type -AssemblyName System.Drawing

$logoPath = "d:\AG\la garza aguachilera\La garza aguachilera.jpeg"
$logo = [System.Drawing.Image]::FromFile($logoPath)
$juancho = [System.Drawing.Image]::FromFile("d:\AG\la garza aguachilera\clean_juancho.png")
$ovni = [System.Drawing.Image]::FromFile("d:\AG\la garza aguachilera\clean_ovni.png")
$mapache = [System.Drawing.Image]::FromFile("d:\AG\la garza aguachilera\clean_mapache.png")

function MakeFont([string]$family, [float]$size, [System.Drawing.FontStyle]$style = [System.Drawing.FontStyle]::Regular) {
    return [System.Drawing.Font]::new($family, $size, $style)
}

function DrawRoundedRectangle([System.Drawing.Graphics]$g, [System.Drawing.Brush]$brush, [System.Drawing.Pen]$pen, [System.Drawing.Rectangle]$rect, [int]$radius) {
    $path = [System.Drawing.Drawing2D.GraphicsPath]::new()
    $r = $radius
    $path.AddArc($rect.X, $rect.Y, $r, $r, 180, 90)
    $path.AddArc($rect.Right - $r, $rect.Y, $r, $r, 270, 90)
    $path.AddArc($rect.Right - $r, $rect.Bottom - $r, $r, $r, 0, 90)
    $path.AddArc($rect.X, $rect.Bottom - $r, $r, $r, 90, 90)
    $path.CloseFigure()
    if ($brush) { $g.FillPath($brush, $path) }
    if ($pen) { $g.DrawPath($pen, $path) }
    $path.Dispose()
}

function DrawStickerText([System.Drawing.Graphics]$g, [string]$text, [System.Drawing.Font]$font, [System.Drawing.Brush]$fillBrush, [System.Drawing.Pen]$outlinePen, [float]$x, [float]$y, [System.Drawing.StringFormat]$sf) {
    $path = [System.Drawing.Drawing2D.GraphicsPath]::new()
    $path.AddString($text, $font.FontFamily, [int]$font.Style, $font.Size, [System.Drawing.PointF]::new($x, $y), $sf)
    if ($outlinePen) { $g.DrawPath($outlinePen, $path) }
    if ($fillBrush) { $g.FillPath($fillBrush, $path) }
    $path.Dispose()
}

function DrawImageWithShadow([System.Drawing.Graphics]$g, [System.Drawing.Image]$img, [int]$x, [int]$y, [int]$w, [int]$h, [int]$shadowOffset = 14, [float]$shadowAlpha = 0.45) {
    # Render soft drop shadow using GDI+ ColorMatrix
    $cm = New-Object System.Drawing.Imaging.ColorMatrix
    $cm.Matrix00 = 0.0
    $cm.Matrix11 = 0.0
    $cm.Matrix22 = 0.0
    $cm.Matrix33 = $shadowAlpha
    $ia = New-Object System.Drawing.Imaging.ImageAttributes
    $ia.SetColorMatrix($cm)
    $destShadow = [System.Drawing.Rectangle]::new($x + $shadowOffset, $y + [int]($shadowOffset * 1.15), $w, $h)
    $g.DrawImage($img, $destShadow, 0, 0, $img.Width, $img.Height, [System.Drawing.GraphicsUnit]::Pixel, $ia)
    $ia.Dispose()
    
    # Draw foreground crisp image
    $destImg = [System.Drawing.Rectangle]::new($x, $y, $w, $h)
    $g.DrawImage($img, $destImg, 0, 0, $img.Width, $img.Height, [System.Drawing.GraphicsUnit]::Pixel)
}

$sfCenter = [System.Drawing.StringFormat]::new()
$sfCenter.Alignment = [System.Drawing.StringAlignment]::Center
$sfCenter.LineAlignment = [System.Drawing.StringAlignment]::Center

# ==============================================================================
# A. MASTER FRAME: BRANDING POP OVERLAY (1080 x 1920)
# ==============================================================================
$bmpFrame = [System.Drawing.Bitmap]::new(1080, 1920)
$gFrame = [System.Drawing.Graphics]::FromImage($bmpFrame)
$gFrame.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$gFrame.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
$gFrame.Clear([System.Drawing.Color]::Transparent)

# --- HEADER (Y: 0 to 420) - Translucent Coastal Navy Vignette ---
$rectHeader = [System.Drawing.Rectangle]::new(0, 0, 1080, 420)
$brushHeader = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
    $rectHeader,
    [System.Drawing.Color]::FromArgb(238, 6, 17, 32),    # Elegant navy top
    [System.Drawing.Color]::FromArgb(195, 12, 38, 64),   # Translucent coastal navy bottom
    [System.Drawing.Drawing2D.LinearGradientMode]::Vertical
)
$gFrame.FillRectangle($brushHeader, $rectHeader)

# Top Bar Tag
$fontTag = MakeFont "Arial" 20 ([System.Drawing.FontStyle]::Bold)
$brushCyan = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(56, 189, 248))
$gFrame.DrawString("TAMPICO Y CIUDAD MADERO * SABOR COSTEÑO", $fontTag, $brushCyan, [float]540, [float]20, $sfCenter)

# Logo in Header (Circular die-cut)
$logoSize = 220
$logoX = (1080 - $logoSize) / 2
$logoY = 50
$pathLogo = [System.Drawing.Drawing2D.GraphicsPath]::new()
$pathLogo.AddEllipse([float]$logoX, [float]$logoY, [float]$logoSize, [float]$logoSize)
$gFrame.SetClip($pathLogo)
$gFrame.DrawImage($logo, [float]$logoX, [float]$logoY, [float]$logoSize, [float]$logoSize)
$gFrame.ResetClip()

# Gold & Neon Rings around logo
$penGoldRing = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(250, 204, 21), 5)
$penWhiteRing = [System.Drawing.Pen]::new([System.Drawing.Color]::White, 2)
$gFrame.DrawEllipse($penGoldRing, [float]$logoX, [float]$logoY, [float]$logoSize, [float]$logoSize)
$gFrame.DrawEllipse($penWhiteRing, [float]($logoX + 3), [float]($logoY + 3), [float]($logoSize - 6), [float]($logoSize - 6))

# Typography in Header
$fontHeaderTitle = MakeFont "Arial" 36 ([System.Drawing.FontStyle]::Bold)
$brushWhite = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)
$penBlackStroke = [System.Drawing.Pen]::new([System.Drawing.Color]::Black, 5)
$penBlackStroke.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
DrawStickerText $gFrame "LA GARZA AGUACHILERA" $fontHeaderTitle $brushWhite $penBlackStroke 540 295 $sfCenter

$fontHeaderSub = MakeFont "Arial" 22 ([System.Drawing.FontStyle]::Bold)
$brushMint = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(52, 211, 153))
$gFrame.DrawString("TOSTIAGUACHILE VERDE TRADICIONAL", $fontHeaderSub, $brushMint, [float]540, [float]348, $sfCenter)

# Header Bottom Neon Border
$rectNeonH = [System.Drawing.Rectangle]::new(0, 414, 1080, 6)
$brushNeonH = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
    $rectNeonH,
    [System.Drawing.Color]::FromArgb(0, 230, 153),
    [System.Drawing.Color]::FromArgb(250, 204, 21),
    [System.Drawing.Drawing2D.LinearGradientMode]::Horizontal
)
$gFrame.FillRectangle($brushNeonH, $rectNeonH)

# --- FOOTER (Y: 1540 to 1920) - Translucent Coastal Navy Footer ---
$rectFooter = [System.Drawing.Rectangle]::new(0, 1540, 1080, 380)
$brushFooter = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
    $rectFooter,
    [System.Drawing.Color]::FromArgb(195, 12, 38, 64),   # Translucent navy top
    [System.Drawing.Color]::FromArgb(242, 5, 14, 26),    # Deep navy bottom
    [System.Drawing.Drawing2D.LinearGradientMode]::Vertical
)
$gFrame.FillRectangle($brushFooter, $rectFooter)

# Footer Top Neon Line
$rectNeonF = [System.Drawing.Rectangle]::new(0, 1540, 1080, 6)
$gFrame.FillRectangle($brushNeonH, $rectNeonF)

# WhatsApp Button
$rectWa = [System.Drawing.Rectangle]::new(90, 1565, 900, 84)
$brushWa = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
    $rectWa,
    [System.Drawing.Color]::FromArgb(37, 211, 102),
    [System.Drawing.Color]::FromArgb(16, 160, 95),
    [System.Drawing.Drawing2D.LinearGradientMode]::Horizontal
)
$penWaBorder = [System.Drawing.Pen]::new([System.Drawing.Color]::White, 3)
DrawRoundedRectangle $gFrame $brushWa $penWaBorder $rectWa 42

$fontWa = MakeFont "Arial" 28 ([System.Drawing.FontStyle]::Bold)
DrawStickerText $gFrame "PEDIDOS WHATSAPP: 833 252 09 88" $fontWa $brushWhite $penBlackStroke 540 1605 $sfCenter

# Price & Chips Pill
$rectPricePill = [System.Drawing.Rectangle]::new(140, 1665, 800, 60)
$brushDarkPill = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(220, 8, 24, 42))
$penMintPill = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(52, 211, 153), 2)
DrawRoundedRectangle $gFrame $brushDarkPill $penMintPill $rectPricePill 30

$fontPriceText = MakeFont "Arial" 22 ([System.Drawing.FontStyle]::Bold)
$brushYellow = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(254, 240, 138))
$gFrame.DrawString("VERDE TRADICIONAL * `$150 MXN * ~100g CAMARON", $fontPriceText, $brushYellow, [float]540, [float]1695, $sfCenter)

# Freshness Statement
$rectFresh = [System.Drawing.Rectangle]::new(60, 1740, 960, 80)
$brushFreshBg = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(240, 6, 18, 32))
$penGoldFresh = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(250, 204, 21), 2)
DrawRoundedRectangle $gFrame $brushFreshBg $penGoldFresh $rectFresh 20

$fontFreshText1 = MakeFont "Arial" 20 ([System.Drawing.FontStyle]::Bold)
$fontFreshText2 = MakeFont "Arial" 18 ([System.Drawing.FontStyle]::Bold)
$gFrame.DrawString("El producto es preparado frente a usted", $fontFreshText1, $brushYellow, [float]540, [float]1762, $sfCenter)
$gFrame.DrawString("para corroborar su maxima frescura", $fontFreshText2, $brushWhite, [float]540, [float]1792, $sfCenter)

# Bottom Location Info - Weekend service & delivery routes
$fontFooterLoc = MakeFont "Arial" 18 ([System.Drawing.FontStyle]::Regular)
$brushGray = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(203, 213, 225))
$gFrame.DrawString("Entregas a domicilio fines de semana * Base: Col. Flores", $fontFooterLoc, $brushGray, [float]540, [float]1855, $sfCenter)

$bmpFrame.Save("d:\AG\la garza aguachilera\herramientas\branding_pop_overlay.png", [System.Drawing.Imaging.ImageFormat]::Png)
$gFrame.Dispose()
$bmpFrame.Dispose()
Write-Host "Branding POP Overlay generado!" -ForegroundColor Green

# ==============================================================================
# B. POP SCENE 1 (00:00 - 05.5s): HOOK CON OVNI DE MIRAMAR
# ==============================================================================
$bmpS1 = [System.Drawing.Bitmap]::new(1080, 1920)
$gS1 = [System.Drawing.Graphics]::FromImage($bmpS1)
$gS1.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$gS1.Clear([System.Drawing.Color]::Transparent)

# Draw OVNI sticker with shadow at top-right
DrawImageWithShadow $gS1 $ovni 700 430 360 360 14 0.40

# Speech Bubble / Sticker next to Ovni
$rectOvniBadge = [System.Drawing.Rectangle]::new(450, 450, 370, 65)
$brushOvniBadge = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(240, 14, 165, 233))
$penWhite = [System.Drawing.Pen]::new([System.Drawing.Color]::White, 3)
DrawRoundedRectangle $gS1 $brushOvniBadge $penWhite $rectOvniBadge 20
$fontBadge = MakeFont "Arial" 16 ([System.Drawing.FontStyle]::Bold)
$gS1.DrawString("SABOR DE OTRA GALAXIA!", $fontBadge, $brushWhite, [float]635, [float]482, $sfCenter)

# Hook Banner in Lower Video Area (Y: 1340 to 1480)
$rectHook = [System.Drawing.Rectangle]::new(60, 1340, 960, 140)
$brushHook = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(235, 225, 29, 72))
$penHook = [System.Drawing.Pen]::new([System.Drawing.Color]::White, 4)
DrawRoundedRectangle $gS1 $brushHook $penHook $rectHook 30

$fontHook1 = MakeFont "Arial" 29 ([System.Drawing.FontStyle]::Bold)
$fontHook2 = MakeFont "Arial" 24 ([System.Drawing.FontStyle]::Bold)
DrawStickerText $gS1 "EL TOSTIAGUACHILE MAS REPORTADO!" $fontHook1 $brushYellow $penBlackStroke 540 1385 $sfCenter
DrawStickerText $gS1 "¡Ya en servicio sabados y domingos!" $fontHook2 $brushWhite $penBlackStroke 540 1442 $sfCenter

$bmpS1.Save("d:\AG\la garza aguachilera\herramientas\pop_sub1.png", [System.Drawing.Imaging.ImageFormat]::Png)
$gS1.Dispose()
$bmpS1.Dispose()
Write-Host "Pop Scene 1 generado!" -ForegroundColor Green

# ==============================================================================
# C. POP SCENE 2 (05.5s - 11.5s): CAMARÓN MARIPOSA CON JUANCHO EL COCODRILO
# ==============================================================================
$bmpS2 = [System.Drawing.Bitmap]::new(1080, 1920)
$gS2 = [System.Drawing.Graphics]::FromImage($bmpS2)
$gS2.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$gS2.Clear([System.Drawing.Color]::Transparent)

# Draw Juancho sticker with shadow at bottom-left
DrawImageWithShadow $gS2 $juancho 30 1140 390 390 14 0.40

# Badge over Juancho
$rectJuanchoBadge = [System.Drawing.Rectangle]::new(45, 1130, 360, 55)
$brushJuanchoBadge = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(240, 16, 185, 129))
DrawRoundedRectangle $gS2 $brushJuanchoBadge $penWhite $rectJuanchoBadge 18
$fontJBadge = MakeFont "Arial" 17 ([System.Drawing.FontStyle]::Bold)
$gS2.DrawString("APROBADO POR JUANCHO", $fontJBadge, $brushWhite, [float]225, [float]1157, $sfCenter)

# Pop Banner at Right (Y: 1350 to 1480)
$rectS2Banner = [System.Drawing.Rectangle]::new(370, 1350, 660, 130)
$brushS2Banner = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(235, 12, 40, 68))
$penMint = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(52, 211, 153), 3)
DrawRoundedRectangle $gS2 $brushS2Banner $penMint $rectS2Banner 26

$fontS2Title = MakeFont "Arial" 24 ([System.Drawing.FontStyle]::Bold)
$fontS2Sub = MakeFont "Arial" 20 ([System.Drawing.FontStyle]::Bold)
DrawStickerText $gS2 "CAMARON FRESCO EN MARIPOSA" $fontS2Title $brushWhite $penBlackStroke 700 1390 $sfCenter
DrawStickerText $gS2 "Cebolla morada, pepino y serrano" $fontS2Sub $brushYellow $penBlackStroke 700 1440 $sfCenter

$bmpS2.Save("d:\AG\la garza aguachilera\herramientas\pop_sub2.png", [System.Drawing.Imaging.ImageFormat]::Png)
$gS2.Dispose()
$bmpS2.Dispose()
Write-Host "Pop Scene 2 generado!" -ForegroundColor Green

# ==============================================================================
# D. POP SCENE 3 (11.5s - 17.5s): TOSTITOS SALSA VERDE CON EL MAPACHE
# ==============================================================================
$bmpS3 = [System.Drawing.Bitmap]::new(1080, 1920)
$gS3 = [System.Drawing.Graphics]::FromImage($bmpS3)
$gS3.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$gS3.Clear([System.Drawing.Color]::Transparent)

# Draw Mapache sticker with shadow at bottom-right
DrawImageWithShadow $gS3 $mapache 680 1140 380 380 14 0.40

# Badge over Mapache
$rectMapacheBadge = [System.Drawing.Rectangle]::new(655, 1130, 385, 55)
$brushMapacheBadge = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(240, 245, 158, 11))
DrawRoundedRectangle $gS3 $brushMapacheBadge $penWhite $rectMapacheBadge 18
$fontMBadge = MakeFont "Arial" 16 ([System.Drawing.FontStyle]::Bold)
$gS3.DrawString("CRUNCH TOTAL ESCOLLERAS", $fontMBadge, $brushWhite, [float]847, [float]1157, $sfCenter)

# Pop Banner at Left (Y: 1350 to 1480)
$rectS3Banner = [System.Drawing.Rectangle]::new(50, 1350, 640, 130)
$brushS3Banner = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(235, 12, 40, 68))
DrawRoundedRectangle $gS3 $brushS3Banner $penMint $rectS3Banner 26

$fontS3Title = MakeFont "Arial" 23 ([System.Drawing.FontStyle]::Bold)
$fontS3Sub = MakeFont "Arial" 20 ([System.Drawing.FontStyle]::Bold)
DrawStickerText $gS3 "CON TOSTITOS SALSA VERDE" $fontS3Title $brushWhite $penBlackStroke 370 1390 $sfCenter
DrawStickerText $gS3 "Bien copeteados y con mucho limon" $fontS3Sub $brushYellow $penBlackStroke 370 1440 $sfCenter

$bmpS3.Save("d:\AG\la garza aguachilera\herramientas\pop_sub3.png", [System.Drawing.Imaging.ImageFormat]::Png)
$gS3.Dispose()
$bmpS3.Dispose()
Write-Host "Pop Scene 3 generado!" -ForegroundColor Green

# ==============================================================================
# E. POP SCENE 4 (17.5s - 23.0s): GARANTÍA SAGRADA DE FRESCURA EN VIVO
# ==============================================================================
$bmpS4 = [System.Drawing.Bitmap]::new(1080, 1920)
$gS4 = [System.Drawing.Graphics]::FromImage($bmpS4)
$gS4.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$gS4.Clear([System.Drawing.Color]::Transparent)

# Juancho on Left, Mapache on Right with shadows
DrawImageWithShadow $gS4 $juancho 30 1180 320 320 14 0.40
DrawImageWithShadow $gS4 $mapache 730 1180 320 320 14 0.40

# Central Pop Banner (Y: 1330 to 1490)
$rectS4Banner = [System.Drawing.Rectangle]::new(110, 1330, 860, 150)
$brushS4Banner = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(240, 6, 18, 34))
$penGoldS4 = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(250, 204, 21), 4)
DrawRoundedRectangle $gS4 $brushS4Banner $penGoldS4 $rectS4Banner 30

$fontS4Stamp = MakeFont "Arial" 18 ([System.Drawing.FontStyle]::Bold)
$fontS4Title = MakeFont "Arial" 27 ([System.Drawing.FontStyle]::Bold)
$fontS4Sub = MakeFont "Arial" 21 ([System.Drawing.FontStyle]::Bold)
$gS4.DrawString("GARANTIA DE CALIDAD LA GARZA", $fontS4Stamp, $brushCyan, [float]540, [float]1355, $sfCenter)
DrawStickerText $gS4 "EL PRODUCTO ES PREPARADO FRENTE A TI" $fontS4Title $brushYellow $penBlackStroke 540 1395 $sfCenter
DrawStickerText $gS4 "Rutas de entrega anunciadas en redes sociales" $fontS4Sub $brushWhite $penBlackStroke 540 1445 $sfCenter

$bmpS4.Save("d:\AG\la garza aguachilera\herramientas\pop_sub4.png", [System.Drawing.Imaging.ImageFormat]::Png)
$gS4.Dispose()
$bmpS4.Dispose()
Write-Host "Pop Scene 4 generado!" -ForegroundColor Green

# ==============================================================================
# F. POP SCENE 5 (23.0s - 29.04s): CLÍMAX DE VENTA & PRECIO
# ==============================================================================
$bmpS5 = [System.Drawing.Bitmap]::new(1080, 1920)
$gS5 = [System.Drawing.Graphics]::FromImage($bmpS5)
$gS5.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$gS5.Clear([System.Drawing.Color]::Transparent)

# Ovni with shadow at Top-Left
DrawImageWithShadow $gS5 $ovni 40 430 320 320 14 0.40

# Exploding Price Starburst / Badge on Right (X: 740, Y: 1170, Size: 280x280)
$rectPriceBadge = [System.Drawing.Rectangle]::new(740, 1170, 280, 160)
$brushPriceBadge = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(240, 225, 29, 72))
$penPriceBadge = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(250, 204, 21), 4)
DrawRoundedRectangle $gS5 $brushPriceBadge $penPriceBadge $rectPriceBadge 35
$fontBigPrice = MakeFont "Arial" 48 ([System.Drawing.FontStyle]::Bold)
$fontBigPriceSub = MakeFont "Arial" 20 ([System.Drawing.FontStyle]::Bold)
DrawStickerText $gS5 "`$150" $fontBigPrice $brushWhite $penBlackStroke 880 1225 $sfCenter
DrawStickerText $gS5 "MXN LA BOLSA" $fontBigPriceSub $brushYellow $penBlackStroke 880 1285 $sfCenter

# WhatsApp Call to Action Banner on Left (Y: 1340 to 1480)
$rectS5Banner = [System.Drawing.Rectangle]::new(50, 1340, 670, 140)
$brushS5Banner = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(240, 16, 140, 85))
$penWhiteS5 = [System.Drawing.Pen]::new([System.Drawing.Color]::White, 3)
DrawRoundedRectangle $gS5 $brushS5Banner $penWhiteS5 $rectS5Banner 30

$fontS5Title = MakeFont "Arial" 24 ([System.Drawing.FontStyle]::Bold)
$fontS5Phone = MakeFont "Arial" 36 ([System.Drawing.FontStyle]::Bold)
DrawStickerText $gS5 "APARTA TU BOLSA POR WHATSAPP" $fontS5Title $brushWhite $penBlackStroke 385 1380 $sfCenter
DrawStickerText $gS5 "833 252 09 88" $fontS5Phone $brushYellow $penBlackStroke 385 1438 $sfCenter

$bmpS5.Save("d:\AG\la garza aguachilera\herramientas\pop_sub5.png", [System.Drawing.Imaging.ImageFormat]::Png)
$gS5.Dispose()
$bmpS5.Dispose()
Write-Host "Pop Scene 5 generado!" -ForegroundColor Green

$logo.Dispose()
$juancho.Dispose()
$ovni.Dispose()
$mapache.Dispose()

Write-Host "`nTODOS LOS OVERLAYS POP Y STICKERS FUERON GENERADOS CON EXITO!" -ForegroundColor Cyan
