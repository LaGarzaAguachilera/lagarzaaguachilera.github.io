# ==============================================================================
# GENERADOR DE OVERLAYS Y STICKERS SPOOKY FULL HD (1080 x 1920)
# La Garza Aguachilera - Campana Halloween & Dia de Muertos
# "La Resurreccion de la Cruda" - GDI+ Drawing Engine
# ==============================================================================
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

Add-Type -AssemblyName System.Drawing

$baseDir = "d:\AG\la garza aguachilera"
$logoPath = "$baseDir\La garza aguachilera.jpeg"
$stickerJuancho = "$baseDir\sticker_spooky_juancho_jason.png"
$stickerMapache = "$baseDir\sticker_spooky_mapache_freddy.png"
$stickerOvni = "$baseDir\sticker_spooky_ovni_muertos.png"

Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host " GENERANDO OVERLAYS GRAFICOS SPOOKY FULL HD 1080x1920 (GDI+)" -ForegroundColor Yellow
Write-Host "=================================================================" -ForegroundColor Cyan

# Validar activos base
$assets = @($logoPath, $stickerJuancho, $stickerMapache, $stickerOvni)
foreach ($a in $assets) {
    if (-not (Test-Path $a)) {
        Write-Error "Activo indispensable no encontrado: $a"
        exit 1
    }
}

$logo = [System.Drawing.Image]::FromFile($logoPath)
$juancho = [System.Drawing.Image]::FromFile($stickerJuancho)
$mapache = [System.Drawing.Image]::FromFile($stickerMapache)
$ovni = [System.Drawing.Image]::FromFile($stickerOvni)

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

function DrawImageWithShadow([System.Drawing.Graphics]$g, [System.Drawing.Image]$img, [int]$x, [int]$y, [int]$w, [int]$h, [int]$shadowOffset = 16, [float]$shadowAlpha = 0.50) {
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
    
    $destImg = [System.Drawing.Rectangle]::new($x, $y, $w, $h)
    $g.DrawImage($img, $destImg, 0, 0, $img.Width, $img.Height, [System.Drawing.GraphicsUnit]::Pixel)
}

$sfCenter = [System.Drawing.StringFormat]::new()
$sfCenter.Alignment = [System.Drawing.StringAlignment]::Center
$sfCenter.LineAlignment = [System.Drawing.StringAlignment]::Center

$sfLeft = [System.Drawing.StringFormat]::new()
$sfLeft.Alignment = [System.Drawing.StringAlignment]::Near
$sfLeft.LineAlignment = [System.Drawing.StringAlignment]::Center

# ==============================================================================
# 1. MASTER BRANDING OVERLAY (spooky_branding_overlay.png - 1080 x 1920)
# ==============================================================================
Write-Host "1. Renderizando spooky_branding_overlay.png..." -ForegroundColor Cyan
$bmpMaster = [System.Drawing.Bitmap]::new(1080, 1920)
$gMaster = [System.Drawing.Graphics]::FromImage($bmpMaster)
$gMaster.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$gMaster.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
$gMaster.Clear([System.Drawing.Color]::Transparent)

# Header Vignette (Y: 0 to 240) - Deep Spooky Night Purple Gradient
$rectHead = [System.Drawing.Rectangle]::new(0, 0, 1080, 240)
$brushHead = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
    $rectHead,
    [System.Drawing.Color]::FromArgb(245, 18, 7, 36),
    [System.Drawing.Color]::FromArgb(160, 28, 10, 56),
    [System.Drawing.Drawing2D.LinearGradientMode]::Vertical
)
$gMaster.FillRectangle($brushHead, $rectHead)
$brushHead.Dispose()

# Top tagline
$fontTop = MakeFont "Segoe UI" 18 ([System.Drawing.FontStyle]::Bold)
$brushGold = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(251, 191, 36))
$gMaster.DrawString("TAMPICO Y CIUDAD MADERO * ESPECIAL HALLOWEEN & DIA DE MUERTOS", $fontTop, $brushGold, [float]540, [float]22, $sfCenter)

# Circular die-cut Logo
$logoSize = 150
$logoX = (1080 - $logoSize) / 2
$logoY = 50
$pathLogo = [System.Drawing.Drawing2D.GraphicsPath]::new()
$pathLogo.AddEllipse([float]$logoX, [float]$logoY, [float]$logoSize, [float]$logoSize)
$gMaster.SetClip($pathLogo)
$gMaster.DrawImage($logo, [float]$logoX, [float]$logoY, [float]$logoSize, [float]$logoSize)
$gMaster.ResetClip()
$pathLogo.Dispose()

# Logo Rings
$penOrangeRing = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(249, 115, 22), 4)
$penLimeRing = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(34, 197, 94), 2)
$gMaster.DrawEllipse($penOrangeRing, [float]$logoX, [float]$logoY, [float]$logoSize, [float]$logoSize)
$gMaster.DrawEllipse($penLimeRing, [float]($logoX - 4), [float]($logoY - 4), [float]($logoSize + 8), [float]($logoSize + 8))
$penOrangeRing.Dispose()
$penLimeRing.Dispose()

# Header Brand Text
$fontBrand = MakeFont "Segoe UI Black" 19 ([System.Drawing.FontStyle]::Bold)
$brushWhite = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)
$penOutlineDark = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(20, 5, 30), 4)
DrawStickerText $gMaster "LA GARZA AGUACHILERA" $fontBrand $brushWhite $penOutlineDark 540 216 $sfCenter

# Footer Vignette (Y: 1720 to 1920)
$rectFoot = [System.Drawing.Rectangle]::new(0, 1720, 1080, 200)
$brushFoot = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
    $rectFoot,
    [System.Drawing.Color]::FromArgb(140, 14, 5, 28),
    [System.Drawing.Color]::FromArgb(245, 10, 3, 20),
    [System.Drawing.Drawing2D.LinearGradientMode]::Vertical
)
$gMaster.FillRectangle($brushFoot, $rectFoot)
$brushFoot.Dispose()

$fontFootBrand = MakeFont "Segoe UI Black" 20 ([System.Drawing.FontStyle]::Bold)
$brushOrangeNeon = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(251, 146, 60))
DrawStickerText $gMaster "LA VERDADERA CURA DE LA CRUDA" $fontFootBrand $brushOrangeNeon $penOutlineDark 540 1780 $sfCenter

$fontFootLoc = MakeFont "Segoe UI" 17 ([System.Drawing.FontStyle]::Bold)
$brushLimeNeon = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(74, 222, 128))
$gMaster.DrawString("COLONIA FLORES, TAMPICO * PEDIDOS WHATSAPP: 833 252 09 88", $fontFootLoc, $brushLimeNeon, [float]540, [float]1840, $sfCenter)

$bmpMaster.Save("$baseDir\herramientas\spooky_branding_overlay.png", [System.Drawing.Imaging.ImageFormat]::Png)
$gMaster.Dispose()
$bmpMaster.Dispose()

# ==============================================================================
# 2. ESCENA 1: SUSPENSO ZOMBI COMICO (spooky_sub1.png - 0.0s a 3.5s)
# ==============================================================================
Write-Host "2. Renderizando spooky_sub1.png (Acto 1)..." -ForegroundColor Cyan
$bmpSub1 = [System.Drawing.Bitmap]::new(1080, 1920)
$gSub1 = [System.Drawing.Graphics]::FromImage($bmpSub1)
$gSub1.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$gSub1.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
$gSub1.Clear([System.Drawing.Color]::Transparent)

# Upper Spooky Badge (Y: 260)
$rectBadge1 = [System.Drawing.Rectangle]::new(90, 260, 900, 130)
$brushBadge1 = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(220, 26, 11, 48))
$penBadge1 = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(234, 88, 12), 4)
DrawRoundedRectangle $gSub1 $brushBadge1 $penBadge1 $rectBadge1 22

$fontBadgeTitle = MakeFont "Segoe UI Black" 34 ([System.Drawing.FontStyle]::Bold)
$fontBadgeSub = MakeFont "Segoe UI" 19 ([System.Drawing.FontStyle]::Bold)
$brushYellow = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(254, 240, 138))
DrawStickerText $gSub1 "!ZOMBIES EN TAMPICO! * NOCHE DE MUERTOS" $fontBadgeTitle $brushYellow $penOutlineDark 540 300 $sfCenter
$gSub1.DrawString("DOMINGO 11:00 AM * LAS ESCOLLERAS DE MIRAMAR", $fontBadgeSub, $brushWhite, [float]540, [float]352, $sfCenter)

# Center Comic Dramatic Card (Y: 960 to 1180)
$rectMid1 = [System.Drawing.Rectangle]::new(80, 960, 920, 210)
$brushMid1 = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(225, 18, 6, 34))
$penMid1 = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(251, 146, 60), 3)
DrawRoundedRectangle $gSub1 $brushMid1 $penMid1 $rectMid1 26

$fontMidBig = MakeFont "Segoe UI Black" 42 ([System.Drawing.FontStyle]::Bold)
$fontMidHuge = MakeFont "Segoe UI Black" 46 ([System.Drawing.FontStyle]::Bold)
DrawStickerText $gSub1 "!NO ESTABAN MUERTOS...!" $fontMidBig $brushWhite $penOutlineDark 540 1020 $sfCenter
DrawStickerText $gSub1 "!SOLO ESTABAN CRUDOS!" $fontMidHuge $brushYellow $penOutlineDark 540 1105 $sfCenter

# Mascot Stickers Creeping at Bottom (Y: 1220 to 1660)
DrawImageWithShadow $gSub1 $juancho 40 1230 380 380 14 0.55
DrawImageWithShadow $gSub1 $mapache 350 1240 380 380 14 0.55
DrawImageWithShadow $gSub1 $ovni 660 1210 380 380 14 0.55

# Comic sound badge
$rectGroan = [System.Drawing.Rectangle]::new(200, 1630, 680, 65)
$brushGroan = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(230, 74, 222, 128))
$penGroan = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(20, 5, 30), 2)
DrawRoundedRectangle $gSub1 $brushGroan $penGroan $rectGroan 18
$fontGroan = MakeFont "Segoe UI Black" 22 ([System.Drawing.FontStyle]::Bold)
$brushDark = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(20, 5, 30))
$gSub1.DrawString("* Crrrruuuudaaaa... !mariscoooo! *", $fontGroan, $brushDark, [float]540, [float]1662, $sfCenter)

$bmpSub1.Save("$baseDir\herramientas\spooky_sub1.png", [System.Drawing.Imaging.ImageFormat]::Png)
$gSub1.Dispose()
$bmpSub1.Dispose()

# ==============================================================================
# 3. ESCENA 2: EL ESTIMULO SAGRADO (spooky_sub2.png - 3.5s a 7.5s)
# ==============================================================================
Write-Host "3. Renderizando spooky_sub2.png (Acto 2)..." -ForegroundColor Cyan
$bmpSub2 = [System.Drawing.Bitmap]::new(1080, 1920)
$gSub2 = [System.Drawing.Graphics]::FromImage($bmpSub2)
$gSub2.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$gSub2.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
$gSub2.Clear([System.Drawing.Color]::Transparent)

# Upper Cold Stimulus Badge (Y: 260)
$rectBadge2 = [System.Drawing.Rectangle]::new(90, 260, 900, 130)
$brushBadge2 = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(220, 15, 23, 42))
$penBadge2 = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(56, 189, 248), 4)
DrawRoundedRectangle $gSub2 $brushBadge2 $penBadge2 $rectBadge2 22

$brushIceCyan = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(224, 242, 254))
DrawStickerText $gSub2 "HIELERA A 2 C * VAPOR HELADO" $fontBadgeTitle $brushIceCyan $penOutlineDark 540 300 $sfCenter
$gSub2.DrawString("!EL AROMA SAGRADO QUE DESPIERTA A LOS CAIDOS!", $fontBadgeSub, $brushLimeNeon, [float]540, [float]352, $sfCenter)

# Side Feature Card (X: 70, Y: 940, W: 520, H: 340)
$rectFeat = [System.Drawing.Rectangle]::new(70, 940, 520, 340)
$brushFeat = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(230, 18, 10, 36))
$penFeat = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(34, 197, 94), 3)
DrawRoundedRectangle $gSub2 $brushFeat $penFeat $rectFeat 24

$fontCardHead = MakeFont "Segoe UI Black" 26 ([System.Drawing.FontStyle]::Bold)
$fontCardBody = MakeFont "Segoe UI" 21 ([System.Drawing.FontStyle]::Bold)
DrawStickerText $gSub2 "TOSTISALSA VERDE" $fontCardHead $brushYellow $penOutlineDark 330 990 $sfCenter
$gSub2.DrawString("- Limon Colima exprimido al momento", $fontCardBody, $brushWhite, [float]100, [float]1055, $sfLeft)
$gSub2.DrawString("- Chile serrano fresco", $fontCardBody, $brushWhite, [float]100, [float]1115, $sfLeft)
$gSub2.DrawString("- Tostitos Salsa Verde crujientes", $fontCardBody, $brushLimeNeon, [float]100, [float]1175, $sfLeft)
$gSub2.DrawString("- Camaron en corte mariposa", $fontCardBody, $brushOrangeNeon, [float]100, [float]1235, $sfLeft)

# Mapache Freddy skewer sticker on the right (X: 580, Y: 880, W: 450, H: 450)
DrawImageWithShadow $gSub2 $mapache 580 880 450 450 16 0.55

# Lower crunch teaser banner (Y: 1380)
$rectCrunch = [System.Drawing.Rectangle]::new(80, 1380, 920, 120)
$brushCrunch = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(235, 234, 88, 12))
$penCrunch = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(254, 240, 138), 3)
DrawRoundedRectangle $gSub2 $brushCrunch $penCrunch $rectCrunch 24
$fontCrunch = MakeFont "Segoe UI Black" 38 ([System.Drawing.FontStyle]::Bold)
DrawStickerText $gSub2 "!GARRAS LISTAS PARA EL CRUNCH!" $fontCrunch $brushYellow $penOutlineDark 540 1440 $sfCenter

$bmpSub2.Save("$baseDir\herramientas\spooky_sub2.png", [System.Drawing.Imaging.ImageFormat]::Png)
$gSub2.Dispose()
$bmpSub2.Dispose()

# ==============================================================================
# 4. ESCENA 3: EL CLIMAX DEL CRUNCH (spooky_sub3.png - 7.5s a 11.5s)
# ==============================================================================
Write-Host "4. Renderizando spooky_sub3.png (Acto 3)..." -ForegroundColor Cyan
$bmpSub3 = [System.Drawing.Bitmap]::new(1080, 1920)
$gSub3 = [System.Drawing.Graphics]::FromImage($bmpSub3)
$gSub3.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$gSub3.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
$gSub3.Clear([System.Drawing.Color]::Transparent)

# Upper Hero Climax Badge (Y: 260)
$rectBadge3 = [System.Drawing.Rectangle]::new(90, 260, 900, 130)
$brushBadge3 = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(230, 30, 8, 48))
$penBadge3 = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(249, 115, 22), 4)
DrawRoundedRectangle $gSub3 $brushBadge3 $penBadge3 $rectBadge3 22

DrawStickerText $gSub3 "!EL CLIMAX DEL CRUNCH!" $fontBadgeTitle $brushYellow $penOutlineDark 540 300 $sfCenter
$gSub3.DrawString("CAMARON FRESCO EN CORTE MARIPOSA (~100g)", $fontBadgeSub, $brushWhite, [float]540, [float]352, $sfCenter)

# Floating Price Badge on Right (X: 770, Y: 410, W: 220, H: 220)
$rectPrice = [System.Drawing.Rectangle]::new(770, 410, 220, 220)
$brushPrice = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
    $rectPrice,
    [System.Drawing.Color]::FromArgb(251, 191, 36),
    [System.Drawing.Color]::FromArgb(234, 88, 12),
    [System.Drawing.Drawing2D.LinearGradientMode]::ForwardDiagonal
)
$penPriceRing = [System.Drawing.Pen]::new([System.Drawing.Color]::White, 4)
$gSub3.FillEllipse($brushPrice, $rectPrice)
$gSub3.DrawEllipse($penPriceRing, $rectPrice)
$brushPrice.Dispose()
$penPriceRing.Dispose()

$fontPriceSub = MakeFont "Segoe UI Black" 19 ([System.Drawing.FontStyle]::Bold)
$fontPriceNum = MakeFont "Segoe UI Black" 54 ([System.Drawing.FontStyle]::Bold)
DrawStickerText $gSub3 "SOLO" $fontPriceSub $brushWhite $penOutlineDark 880 455 $sfCenter
DrawStickerText $gSub3 "`$150" $fontPriceNum $brushWhite $penOutlineDark 880 520 $sfCenter
DrawStickerText $gSub3 "MXN" $fontPriceSub $brushWhite $penOutlineDark 880 585 $sfCenter

# Juancho Jason Sticker holding shrimp fork on Left (X: 30, Y: 940, W: 480, H: 480)
DrawImageWithShadow $gSub3 $juancho 30 940 480 480 18 0.55

# Quality Feature Pill on Right (X: 520, Y: 1040, W: 490, H: 220)
$rectPill = [System.Drawing.Rectangle]::new(520, 1040, 490, 220)
$brushPill = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(230, 20, 7, 40))
$penPill = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(251, 191, 36), 3)
DrawRoundedRectangle $gSub3 $brushPill $penPill $rectPill 24

$fontPillHead = MakeFont "Segoe UI Black" 24 ([System.Drawing.FontStyle]::Bold)
$fontPillSub = MakeFont "Segoe UI" 20 ([System.Drawing.FontStyle]::Bold)
DrawStickerText $gSub3 "PREPARADO FRENTE A TI" $fontPillHead $brushYellow $penOutlineDark 765 1090 $sfCenter
$gSub3.DrawString("- Camaron mariposa selecto", $fontPillSub, $brushWhite, [float]550, [float]1150, $sfLeft)
$gSub3.DrawString("- Maxima frescura garantizada", $fontPillSub, $brushLimeNeon, [float]550, [float]1200, $sfLeft)

# Lower Revival Celebration Banner (Y: 1380)
$rectRevival = [System.Drawing.Rectangle]::new(80, 1380, 920, 120)
$brushRevival = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(235, 34, 197, 94))
$penRevival = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(20, 5, 30), 3)
DrawRoundedRectangle $gSub3 $brushRevival $penRevival $rectRevival 24
$fontRevival = MakeFont "Segoe UI Black" 38 ([System.Drawing.FontStyle]::Bold)
DrawStickerText $gSub3 "!RECUPERARON LA ENERGIA JAIBA!" $fontRevival $brushYellow $penOutlineDark 540 1440 $sfCenter

$bmpSub3.Save("$baseDir\herramientas\spooky_sub3.png", [System.Drawing.Imaging.ImageFormat]::Png)
$gSub3.Dispose()
$bmpSub3.Dispose()

# ==============================================================================
# 5. ESCENA 4: EL GRAN REMATE COMERCIAL & WHATSAPP (spooky_sub4.png - 11.5s a 20.0s)
# ==============================================================================
Write-Host "5. Renderizando spooky_sub4.png (Acto 4 - Gran Remate)..." -ForegroundColor Cyan
$bmpSub4 = [System.Drawing.Bitmap]::new(1080, 1920)
$gSub4 = [System.Drawing.Graphics]::FromImage($bmpSub4)
$gSub4.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$gSub4.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
$gSub4.Clear([System.Drawing.Color]::Transparent)

# Upper Grand Card (Y: 250 to 450)
$rectGrand = [System.Drawing.Rectangle]::new(70, 250, 940, 200)
$brushGrand = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(235, 20, 7, 40))
$penGrand = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(249, 115, 22), 4)
DrawRoundedRectangle $gSub4 $brushGrand $penGrand $rectGrand 26

$fontGrandHead = MakeFont "Segoe UI Black" 33 ([System.Drawing.FontStyle]::Bold)
$fontGrandSub = MakeFont "Segoe UI Black" 26 ([System.Drawing.FontStyle]::Bold)
DrawStickerText $gSub4 "!LA VERDADERA CURA DE TAMPICO Y MADERO!" $fontGrandHead $brushYellow $penOutlineDark 540 305 $sfCenter
DrawStickerText $gSub4 "TOSTIAGUACHILE VERDE TRADICIONAL * `$150 MXN" $fontGrandSub $brushOrangeNeon $penOutlineDark 540 370 $sfCenter
$fontPortion = MakeFont "Segoe UI" 18 ([System.Drawing.FontStyle]::Bold)
$gSub4.DrawString("~100g camaron mariposa * Tostitos Salsa Verde * Picante natural", $fontPortion, $brushWhite, [float]540, [float]418, $sfCenter)

# Mascot Trio Celebrating in Center (Y: 880 to 1250)
DrawImageWithShadow $gSub4 $juancho 50 890 350 350 14 0.55
DrawImageWithShadow $gSub4 $mapache 365 900 350 350 14 0.55
DrawImageWithShadow $gSub4 $ovni 680 880 350 350 14 0.55

# Grand Commercial Card at Lower Third (X: 70, Y: 1260, W: 940, H: 400)
$rectComm = [System.Drawing.Rectangle]::new(70, 1260, 940, 400)
$brushComm = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(240, 14, 4, 28))
$penComm = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(251, 191, 36), 4)
DrawRoundedRectangle $gSub4 $brushComm $penComm $rectComm 28

# Schedule
$fontSchedule = MakeFont "Segoe UI Black" 27 ([System.Drawing.FontStyle]::Bold)
DrawStickerText $gSub4 "SABADOS Y DOMINGOS * 1:00 PM A 5:00 PM" $fontSchedule $brushYellow $penOutlineDark 540 1315 $sfCenter

# Freshness Promise
$fontPromise = MakeFont "Segoe UI" 19 ([System.Drawing.FontStyle]::Bold)
$gSub4.DrawString("El producto se prepara frente a ti para corroborar su frescura", $fontPromise, $brushWhite, [float]540, [float]1368, $sfCenter)

# WhatsApp CTA Box (X: 100, Y: 1410, W: 880, H: 220)
$rectWa = [System.Drawing.Rectangle]::new(100, 1410, 880, 220)
$brushWa = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(245, 22, 163, 74))
$penWa = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(254, 240, 138), 3)
DrawRoundedRectangle $gSub4 $brushWa $penWa $rectWa 22

$fontWaCall = MakeFont "Segoe UI Black" 27 ([System.Drawing.FontStyle]::Bold)
$fontWaNum = MakeFont "Segoe UI Black" 52 ([System.Drawing.FontStyle]::Bold)
$fontWaLoc = MakeFont "Segoe UI" 19 ([System.Drawing.FontStyle]::Bold)
DrawStickerText $gSub4 "!APARTA TU PEDIDO POR WHATSAPP!" $fontWaCall $brushWhite $penOutlineDark 540 1455 $sfCenter
DrawStickerText $gSub4 "WA: 833 252 09 88" $fontWaNum $brushYellow $penOutlineDark 540 1528 $sfCenter
$gSub4.DrawString("COLONIA FLORES, TAMPICO * !RUTAS ACTIVAS!", $fontWaLoc, $brushWhite, [float]540, [float]1595, $sfCenter)

$bmpSub4.Save("$baseDir\herramientas\spooky_sub4.png", [System.Drawing.Imaging.ImageFormat]::Png)
$gSub4.Dispose()
$bmpSub4.Dispose()

# Liberar imagenes base
$logo.Dispose()
$juancho.Dispose()
$mapache.Dispose()
$ovni.Dispose()

Write-Host "`nOverlays generados exitosamente en herramientas\:" -ForegroundColor Green
Get-ChildItem "$baseDir\herramientas\spooky_*.png" | Select-Object Name, Length, LastWriteTime
