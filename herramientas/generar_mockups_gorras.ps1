# ==============================================================================
# GENERADOR DE MOCKUPS OFICIALES DE GORRAS (CACHUCHAS) - LA GARZA AGUACHILERA
# Archivo: herramientas\generar_mockups_gorras.ps1
# Genera 6 modelos comerciales oficiales en alta definicion (1080 x 1080 px)
# ==============================================================================
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

Add-Type -AssemblyName System.Drawing

$rootDir = "d:\AG\la garza aguachilera"
$outDir  = "$rootDir\contenido_redes\merchandising\gorras"

if (-not (Test-Path $outDir)) {
    New-Item -ItemType Directory -Path $outDir -Force | Out-Null
}

$logoPath    = "$rootDir\La garza aguachilera.jpeg"
$juanchoPath = "$rootDir\clean_juancho.png"
$mapachePath = "$rootDir\clean_mapache.png"
$ovniPath    = "$rootDir\clean_ovni.png"

$logo    = [System.Drawing.Image]::FromFile($logoPath)
$juancho = if (Test-Path $juanchoPath) { [System.Drawing.Image]::FromFile($juanchoPath) } else { $null }
$mapache = if (Test-Path $mapachePath) { [System.Drawing.Image]::FromFile($mapachePath) } else { $null }
$ovni    = if (Test-Path $ovniPath)    { [System.Drawing.Image]::FromFile($ovniPath) } else { $null }

# Caracteres especiales seguros
$uO = [char]0x00D3
$bul = [char]0x2022

function MakeFont([string]$family, [float]$size, [System.Drawing.FontStyle]$style = [System.Drawing.FontStyle]::Regular) {
    return [System.Drawing.Font]::new($family, $size, $style)
}

$sfCenter = [System.Drawing.StringFormat]::new()
$sfCenter.Alignment = [System.Drawing.StringAlignment]::Center
$sfCenter.LineAlignment = [System.Drawing.StringAlignment]::Center

$sfLeft = [System.Drawing.StringFormat]::new()
$sfLeft.Alignment = [System.Drawing.StringAlignment]::Near
$sfLeft.LineAlignment = [System.Drawing.StringAlignment]::Center

function DrawRoundedRect([System.Drawing.Graphics]$g, [System.Drawing.Brush]$brush, [System.Drawing.Pen]$pen, [System.Drawing.Rectangle]$rect, [int]$radius) {
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

function DrawStudioBackdrop([System.Drawing.Graphics]$g, [string]$theme) {
    $rect = [System.Drawing.Rectangle]::new(0, 0, 1080, 1080)
    
    $cTop = [System.Drawing.Color]::FromArgb(15, 23, 42)
    $cBot = [System.Drawing.Color]::FromArgb(2, 6, 23)
    if ($theme -eq "pink") {
        $cTop = [System.Drawing.Color]::FromArgb(35, 18, 30)
        $cBot = [System.Drawing.Color]::FromArgb(15, 7, 18)
    } elseif ($theme -eq "pastel") {
        $cTop = [System.Drawing.Color]::FromArgb(28, 20, 38)
        $cBot = [System.Drawing.Color]::FromArgb(12, 8, 20)
    } elseif ($theme -eq "neon") {
        $cTop = [System.Drawing.Color]::FromArgb(10, 30, 35)
        $cBot = [System.Drawing.Color]::FromArgb(4, 15, 20)
    }

    $bgBrush = [System.Drawing.Drawing2D.LinearGradientBrush]::new($rect, $cTop, $cBot, [System.Drawing.Drawing2D.LinearGradientMode]::Vertical)
    $g.FillRectangle($bgBrush, $rect)
    $bgBrush.Dispose()

    # Spotlight circular suave
    $spotRect = [System.Drawing.Rectangle]::new(190, 150, 700, 700)
    $pathSpot = [System.Drawing.Drawing2D.GraphicsPath]::new()
    $pathSpot.AddEllipse($spotRect)
    $pbl = [System.Drawing.Drawing2D.PathGradientBrush]::new($pathSpot)
    $pbl.CenterColor = [System.Drawing.Color]::FromArgb(40, 255, 255, 255)
    $pbl.SurroundColors = @([System.Drawing.Color]::FromArgb(0, 255, 255, 255))
    $g.FillPath($pbl, $pathSpot)
    $pbl.Dispose()
    $pathSpot.Dispose()

    # Pedestal de estudio (Y: 700 a 840)
    $pedRect = [System.Drawing.Rectangle]::new(140, 700, 800, 140)
    $pedBrush = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
        $pedRect,
        [System.Drawing.Color]::FromArgb(45, 55, 72),
        [System.Drawing.Color]::FromArgb(15, 23, 42),
        [System.Drawing.Drawing2D.LinearGradientMode]::Vertical
    )
    $pedPen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(100, 148, 163, 184), 2)
    $g.FillEllipse($pedBrush, $pedRect)
    $g.DrawEllipse($pedPen, $pedRect)
    $pedBrush.Dispose()
    $pedPen.Dispose()
}

function DrawCap3D(
    [System.Drawing.Graphics]$g,
    [System.Drawing.Color]$crownColor,
    [System.Drawing.Color]$crownDark,
    [System.Drawing.Color]$visorColor,
    [System.Drawing.Color]$visorEdge,
    [bool]$isTrucker,
    [string]$capStyle,
    [scriptblock]$drawPatchBlock
) {
    # 1. Sombra de contacto
    $shadowRect = [System.Drawing.Rectangle]::new(200, 670, 680, 80)
    $pathShadow = [System.Drawing.Drawing2D.GraphicsPath]::new()
    $pathShadow.AddEllipse($shadowRect)
    $pblShadow = [System.Drawing.Drawing2D.PathGradientBrush]::new($pathShadow)
    $pblShadow.CenterColor = [System.Drawing.Color]::FromArgb(180, 0, 0, 0)
    $pblShadow.SurroundColors = @([System.Drawing.Color]::FromArgb(0, 0, 0, 0))
    $g.FillPath($pblShadow, $pathShadow)
    $pblShadow.Dispose()
    $pathShadow.Dispose()

    # 2. Silueta de la Corona
    $crownPath = [System.Drawing.Drawing2D.GraphicsPath]::new()
    $crownPath.StartFigure()
    $crownPath.AddBezier(280, 560, 270, 340, 390, 250, 540, 240)
    $crownPath.AddBezier(540, 240, 690, 250, 810, 340, 800, 560)
    $crownPath.AddLine(800, 560, 280, 560)
    $crownPath.CloseFigure()

    $rectCrown = [System.Drawing.Rectangle]::new(270, 230, 540, 340)
    $brushCrown = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
        $rectCrown,
        $crownColor,
        $crownDark,
        [System.Drawing.Drawing2D.LinearGradientMode]::ForwardDiagonal
    )
    $g.FillPath($brushCrown, $crownPath)

    # 3. Malla Trucker si aplica
    if ($isTrucker) {
        $meshPath = [System.Drawing.Drawing2D.GraphicsPath]::new()
        $meshPath.StartFigure()
        $meshPath.AddBezier(280, 560, 270, 360, 350, 290, 420, 255)
        $meshPath.AddBezier(420, 255, 360, 360, 350, 460, 360, 560)
        $meshPath.CloseFigure()
        $meshPath.StartFigure()
        $meshPath.AddBezier(800, 560, 810, 360, 730, 290, 660, 255)
        $meshPath.AddBezier(660, 255, 720, 360, 730, 460, 720, 560)
        $meshPath.CloseFigure()

        $brushMesh = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
            $rectCrown,
            [System.Drawing.Color]::FromArgb(240, 255, 255, 255),
            [System.Drawing.Color]::FromArgb(180, 215, 225, 235),
            [System.Drawing.Drawing2D.LinearGradientMode]::Vertical
        )
        $g.FillPath($brushMesh, $meshPath)
        $brushMesh.Dispose()

        $penGrid = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(60, 100, 115, 130), 1)
        for ($x = 280; $x -le 410; $x += 10) {
            $g.DrawLine($penGrid, $x, 320, $x + 25, 560)
        }
        for ($x = 670; $x -le 800; $x += 10) {
            $g.DrawLine($penGrid, $x, 320, $x - 25, 560)
        }
        $penGrid.Dispose()
        $meshPath.Dispose()
    }

    # Costuras estructurales
    $penSeam = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(70, 0, 0, 0), 2)
    $g.DrawBezier($penSeam, 540, 240, 540, 320, 540, 440, 540, 560)
    $penSeam.Color = [System.Drawing.Color]::FromArgb(40, 255, 255, 255)
    $g.DrawBezier($penSeam, 541, 240, 541, 320, 541, 440, 541, 560)
    $penSeam.Dispose()

    # Ojales
    $penEyelet = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(120, 0, 0, 0), 2)
    $brushEyelet = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(180, 15, 23, 42))
    $g.FillEllipse($brushEyelet, 440, 330, 12, 12)
    $g.DrawEllipse($penEyelet, 440, 330, 12, 12)
    $g.FillEllipse($brushEyelet, 628, 330, 12, 12)
    $g.DrawEllipse($penEyelet, 628, 330, 12, 12)
    $penEyelet.Dispose()
    $brushEyelet.Dispose()

    # 4. Parche Frontal
    if ($drawPatchBlock) {
        & $drawPatchBlock $g
    }

    # 5. Visera
    $visorPath = [System.Drawing.Drawing2D.GraphicsPath]::new()
    if ($capStyle -eq "snapback") {
        $visorPath.StartFigure()
        $visorPath.AddBezier(260, 560, 300, 550, 780, 550, 820, 560)
        $visorPath.AddBezier(820, 560, 850, 670, 810, 680, 540, 680)
        $visorPath.AddBezier(540, 680, 270, 680, 230, 670, 260, 560)
        $visorPath.CloseFigure()
    } else {
        $visorPath.StartFigure()
        $visorPath.AddBezier(270, 555, 360, 535, 720, 535, 810, 555)
        $visorPath.AddBezier(810, 555, 840, 640, 760, 690, 540, 700)
        $visorPath.AddBezier(540, 700, 320, 690, 240, 640, 270, 555)
        $visorPath.CloseFigure()
    }

    $rectVisor = [System.Drawing.Rectangle]::new(240, 535, 600, 170)
    $brushVisor = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
        $rectVisor,
        $visorColor,
        $visorEdge,
        [System.Drawing.Drawing2D.LinearGradientMode]::Vertical
    )
    $g.FillPath($brushVisor, $visorPath)

    # Pespuntes de la visera
    $penStitch = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(90, 255, 255, 255), 1.5)
    $penStitch.DashStyle = [System.Drawing.Drawing2D.DashStyle]::Dash
    for ($offset = 12; $offset -le 48; $offset += 10) {
        $g.DrawBezier(
            $penStitch,
            270 + [int]($offset * 0.7), 570 + [int]($offset * 0.4),
            380, 620 + $offset,
            700, 620 + $offset,
            810 - [int]($offset * 0.7), 570 + [int]($offset * 0.4)
        )
    }
    $penStitch.Dispose()

    $penVisorEdge = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(150, 0, 0, 0), 2)
    $g.DrawPath($penVisorEdge, $visorPath)
    $penVisorEdge.Dispose()

    # 6. Boton superior
    $rectButton = [System.Drawing.Rectangle]::new(525, 228, 30, 22)
    $brushBtn = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
        $rectButton,
        $visorColor,
        $visorEdge,
        [System.Drawing.Drawing2D.LinearGradientMode]::Vertical
    )
    $penBtn = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(120, 0, 0, 0), 1.5)
    $g.FillEllipse($brushBtn, $rectButton)
    $g.DrawEllipse($penBtn, $rectButton)
    $brushBtn.Dispose()
    $penBtn.Dispose()

    $crownPath.Dispose()
    $brushCrown.Dispose()
    $visorPath.Dispose()
    $brushVisor.Dispose()
}

function DrawProductInfoCard(
    [System.Drawing.Graphics]$g,
    [string]$categoryBadge,
    [System.Drawing.Color]$badgeColor,
    [string]$productName,
    [string]$specMaterial,
    [string]$specAjuste,
    [string]$specBordado,
    [string]$paletteHex
) {
    # 1. Header (Y: 40 a 160)
    $rectTop = [System.Drawing.Rectangle]::new(40, 40, 1000, 110)
    $brushTop = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(235, 15, 23, 42))
    $penTop = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(70, 255, 255, 255), 1.5)
    DrawRoundedRect $g $brushTop $penTop $rectTop 20
    $brushTop.Dispose()
    $penTop.Dispose()

    $g.DrawImage($script:logo, 60, 52, 86, 86)

    $fontBrand = MakeFont "Segoe UI Black" 24 ([System.Drawing.FontStyle]::Bold)
    $fontSub   = MakeFont "Segoe UI" 14 ([System.Drawing.FontStyle]::Bold)
    $brushGold = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(251, 191, 36))
    $brushWhite = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)

    $g.DrawString("LA GARZA AGUACHILERA", $fontBrand, $brushGold, [float]165, [float]70, $script:sfLeft)
    $g.DrawString("MERCHANDISING OFICIAL $script:bul COLECCION TAMPICO Y MADERO", $fontSub, $brushWhite, [float]165, [float]110, $script:sfLeft)

    # Category Pill
    $rectCat = [System.Drawing.Rectangle]::new(700, 65, 320, 60)
    $brushCat = [System.Drawing.SolidBrush]::new($badgeColor)
    $penCat = [System.Drawing.Pen]::new([System.Drawing.Color]::White, 2)
    DrawRoundedRect $g $brushCat $penCat $rectCat 16
    $fontCat = MakeFont "Segoe UI Black" 15 ([System.Drawing.FontStyle]::Bold)
    $brushCatText = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(15, 23, 42))
    $g.DrawString($categoryBadge, $fontCat, $brushCatText, [float]860, [float]95, $script:sfCenter)

    $brushCat.Dispose()
    $penCat.Dispose()
    $fontCat.Dispose()
    $brushCatText.Dispose()

    # 2. Footer de Especificaciones (Y: 820 a 1040)
    $rectCard = [System.Drawing.Rectangle]::new(40, 820, 1000, 220)
    $brushCard = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(240, 15, 23, 42))
    $penCard = [System.Drawing.Pen]::new($badgeColor, 2.5)
    DrawRoundedRect $g $brushCard $penCard $rectCard 24

    $fontTitle = MakeFont "Segoe UI Black" 25 ([System.Drawing.FontStyle]::Bold)
    $g.DrawString($productName, $fontTitle, $brushGold, [float]540, [float]860, $script:sfCenter)

    $specs = @(
        @{ Label = "MATERIAL"; Val = $specMaterial; X = 70 },
        @{ Label = "AJUSTE";   Val = $specAjuste;   X = 390 },
        @{ Label = "BORDADO";  Val = $specBordado;  X = 710 }
    )

    $fontSpecLabel = MakeFont "Segoe UI Black" 13 ([System.Drawing.FontStyle]::Bold)
    $fontSpecVal   = MakeFont "Segoe UI" 14 ([System.Drawing.FontStyle]::Bold)
    $brushGray     = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(148, 163, 184))
    $brushLime     = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(34, 197, 94))

    foreach ($s in $specs) {
        $rSpec = [System.Drawing.Rectangle]::new($s.X, 905, 300, 70)
        $bSpec = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(160, 30, 41, 59))
        $pSpec = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(70, 255, 255, 255), 1)
        DrawRoundedRect $g $bSpec $pSpec $rSpec 12
        $g.DrawString($s.Label, $fontSpecLabel, $brushGray, [float]($s.X + 150), [float]925, $script:sfCenter)
        $g.DrawString($s.Val, $fontSpecVal, $brushWhite, [float]($s.X + 150), [float]952, $script:sfCenter)
        $bSpec.Dispose()
        $pSpec.Dispose()
    }

    $fontSeal = MakeFont "Segoe UI" 14 ([System.Drawing.FontStyle]::Bold)
    $footerText = "PALETA: $paletteHex  |  EDICION OFICIAL CERTIFICADA $script:bul Tampico y Ciudad Madero"
    $g.DrawString($footerText, $fontSeal, $brushLime, [float]540, [float]1008, $script:sfCenter)

    $brushCard.Dispose()
    $penCard.Dispose()
    $fontTitle.Dispose()
    $fontSpecLabel.Dispose()
    $fontSpecVal.Dispose()
    $brushGray.Dispose()
    $brushLime.Dispose()
    $fontSeal.Dispose()
    $fontBrand.Dispose()
    $fontSub.Dispose()
    $brushGold.Dispose()
    $brushWhite.Dispose()
}

Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host " RENDERIZANDO LAS 6 GORRAS OFICIALES (1080x1080 GDI+)" -ForegroundColor Yellow
Write-Host "=================================================================" -ForegroundColor Cyan

# ------------------------------------------------------------------------------
# 1. CABALLERO FORMAL TRUCKER
# ------------------------------------------------------------------------------
Write-Host "1. Renderizando Gorra 01: Caballero Formal Trucker..." -ForegroundColor Green
$bmp1 = [System.Drawing.Bitmap]::new(1080, 1080)
$g1   = [System.Drawing.Graphics]::FromImage($bmp1)
$g1.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g1.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

DrawStudioBackdrop $g1 "default"
DrawCap3D $g1 `
    ([System.Drawing.Color]::FromArgb(10, 25, 47)) `
    ([System.Drawing.Color]::FromArgb(2, 10, 25)) `
    ([System.Drawing.Color]::FromArgb(15, 30, 55)) `
    ([System.Drawing.Color]::FromArgb(5, 15, 30)) `
    $true "trucker" {
        param($g)
        $rectPatch = [System.Drawing.Rectangle]::new(440, 360, 200, 150)
        $brushPatch = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
            $rectPatch,
            [System.Drawing.Color]::FromArgb(15, 30, 60),
            [System.Drawing.Color]::FromArgb(5, 15, 35),
            [System.Drawing.Drawing2D.LinearGradientMode]::Vertical
        )
        $penGold = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(251, 191, 36), 3)
        DrawRoundedRect $g $brushPatch $penGold $rectPatch 16
        
        $g.DrawImage($script:logo, 490, 375, 100, 90)
        
        $fontP1 = MakeFont "Segoe UI Black" 11 ([System.Drawing.FontStyle]::Bold)
        $brushWhite = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)
        $g.DrawString("TAMPICO $script:bul MADERO", $fontP1, $brushWhite, [float]540, [float]485, $script:sfCenter)
        
        $brushPatch.Dispose()
        $penGold.Dispose()
        $fontP1.Dispose()
        $brushWhite.Dispose()
    }

DrawProductInfoCard $g1 `
    "CABALLERO FORMAL" `
    ([System.Drawing.Color]::FromArgb(56, 189, 248)) `
    "GORRA TRUCKER CABALLERO • AZUL MARINO / BLANCO" `
    "Algodon Twill + Malla Nylon" `
    "Snapback Ajustable 7P" `
    "Bordado Crest Alta Densidad" `
    "#0A192F (Navy) + #FFFFFF (White) + #FBBF24 (Gold)"

$bmp1.Save("$outDir\gorra_01_caballero_formal_trucker.png", [System.Drawing.Imaging.ImageFormat]::Png)
$g1.Dispose()
$bmp1.Dispose()

# ------------------------------------------------------------------------------
# 2. UNIVERSITARIA STREETWEAR
# ------------------------------------------------------------------------------
Write-Host "2. Renderizando Gorra 02: Universitaria Locochona..." -ForegroundColor Green
$bmp2 = [System.Drawing.Bitmap]::new(1080, 1080)
$g2   = [System.Drawing.Graphics]::FromImage($bmp2)
$g2.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g2.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

DrawStudioBackdrop $g2 "neon"
DrawCap3D $g2 `
    ([System.Drawing.Color]::FromArgb(6, 182, 212)) `
    ([System.Drawing.Color]::FromArgb(8, 145, 178)) `
    ([System.Drawing.Color]::FromArgb(234, 88, 12)) `
    ([System.Drawing.Color]::FromArgb(194, 65, 12)) `
    $false "streetwear" {
        param($g)
        $rectPatch = [System.Drawing.Rectangle]::new(420, 340, 240, 170)
        $brushPatch = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(240, 15, 23, 42))
        $penLime = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(132, 204, 22), 4)
        DrawRoundedRect $g $brushPatch $penLime $rectPatch 18

        if ($script:juancho) { $g.DrawImage($script:juancho, 430, 360, 100, 100) }
        if ($script:mapache) { $g.DrawImage($script:mapache, 545, 360, 100, 100) }

        $fontU1 = MakeFont "Segoe UI Black" 13 ([System.Drawing.FontStyle]::Bold)
        $brushYellow = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(254, 240, 138))
        $g.DrawString("AGUACHILE CLUB", $fontU1, $brushYellow, [float]540, [float]485, $script:sfCenter)

        $brushPatch.Dispose()
        $penLime.Dispose()
        $fontU1.Dispose()
        $brushYellow.Dispose()
    }

DrawProductInfoCard $g2 `
    "UNIVERSITARIA CHAVOS" `
    ([System.Drawing.Color]::FromArgb(132, 204, 22)) `
    "GORRA STREETWEAR RETRO • TURQUESA / CORAL NEON" `
    "Microfibra Ripstop + DryFit" `
    "Broche Hebilla Sport" `
    "Parche Pop Art Juancho & Raccoon" `
    "#06B6D4 (Aqua) + #EA580C (Orange) + #84CC16 (Lime)"

$bmp2.Save("$outDir\gorra_02_universitaria_streetwear.png", [System.Drawing.Imaging.ImageFormat]::Png)
$g2.Dispose()
$bmp2.Dispose()

# ------------------------------------------------------------------------------
# 3. DAMA TRUCKER ROSA PASTEL
# ------------------------------------------------------------------------------
Write-Host "3. Renderizando Gorra 03: Dama Trucker Rosa Pastel..." -ForegroundColor Green
$bmp3 = [System.Drawing.Bitmap]::new(1080, 1080)
$g3   = [System.Drawing.Graphics]::FromImage($bmp3)
$g3.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g3.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

DrawStudioBackdrop $g3 "pink"
DrawCap3D $g3 `
    ([System.Drawing.Color]::FromArgb(244, 114, 182)) `
    ([System.Drawing.Color]::FromArgb(219, 39, 119)) `
    ([System.Drawing.Color]::FromArgb(249, 168, 212)) `
    ([System.Drawing.Color]::FromArgb(219, 39, 119)) `
    $true "trucker" {
        param($g)
        $rectPatch = [System.Drawing.Rectangle]::new(440, 360, 200, 150)
        $brushPatch = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
            $rectPatch,
            [System.Drawing.Color]::FromArgb(253, 242, 248),
            [System.Drawing.Color]::FromArgb(251, 207, 232),
            [System.Drawing.Drawing2D.LinearGradientMode]::Vertical
        )
        $penRose = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(219, 39, 119), 3)
        DrawRoundedRect $g $brushPatch $penRose $rectPatch 24

        $g.DrawImage($script:logo, 490, 375, 100, 90)

        $fontD1 = MakeFont "Segoe UI Black" 11 ([System.Drawing.FontStyle]::Bold)
        $brushPinkDark = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(157, 23, 77))
        $g.DrawString("EDICION ROSA BLUSH", $fontD1, $brushPinkDark, [float]540, [float]485, $script:sfCenter)

        $brushPatch.Dispose()
        $penRose.Dispose()
        $fontD1.Dispose()
        $brushPinkDark.Dispose()
    }

DrawProductInfoCard $g3 `
    "DAMA TRUCKER CHIC" `
    ([System.Drawing.Color]::FromArgb(244, 114, 182)) `
    "GORRA TRUCKER DAMA • ROSA PASTEL BLUSH / BLANCO" `
    "Algodon Peinado + Malla Nieve" `
    "Snapback Rosa Suave 7P" `
    "Bordado Delicado Oro Rosa" `
    "#F472B6 (Blush) + #FFFFFF (White) + #BE185D (Rose)"

$bmp3.Save("$outDir\gorra_03_dama_trucker_rosa.png", [System.Drawing.Imaging.ImageFormat]::Png)
$g3.Dispose()
$bmp3.Dispose()

# ------------------------------------------------------------------------------
# 4. DAMA CHIC & AESTHETIC (DAD HAT LAVANDA)
# ------------------------------------------------------------------------------
Write-Host "4. Renderizando Gorra 04: Dama Chic Aesthetic..." -ForegroundColor Green
$bmp4 = [System.Drawing.Bitmap]::new(1080, 1080)
$g4   = [System.Drawing.Graphics]::FromImage($bmp4)
$g4.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g4.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

DrawStudioBackdrop $g4 "pastel"
DrawCap3D $g4 `
    ([System.Drawing.Color]::FromArgb(192, 132, 252)) `
    ([System.Drawing.Color]::FromArgb(147, 51, 234)) `
    ([System.Drawing.Color]::FromArgb(168, 85, 247)) `
    ([System.Drawing.Color]::FromArgb(126, 34, 206)) `
    $false "dad_hat" {
        param($g)
        $rectPatch = [System.Drawing.Rectangle]::new(450, 370, 180, 130)
        $brushPatch = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(250, 245, 255))
        $penGold = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(234, 179, 8), 2.5)
        DrawRoundedRect $g $brushPatch $penGold $rectPatch 18

        $g.DrawImage($script:logo, 495, 382, 90, 80)

        $fontD2 = MakeFont "Segoe UI" 10 ([System.Drawing.FontStyle]::Bold)
        $brushPurp = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(88, 28, 135))
        $g.DrawString("AESTHETIC COASTAL", $fontD2, $brushPurp, [float]540, [float]478, $script:sfCenter)

        $brushPatch.Dispose()
        $penGold.Dispose()
        $fontD2.Dispose()
        $brushPurp.Dispose()
    }

DrawProductInfoCard $g4 `
    "DAMA AESTHETIC" `
    ([System.Drawing.Color]::FromArgb(192, 132, 252)) `
    "DAD HAT DAMA CHIC • LAVANDA PASTEL / CLEAN AESTHETIC" `
    "100% Algodon Lavado Twill" `
    "Hebilla Metalica Laton Envejecido" `
    "Micro-Bordado Minimalista Blanco/Oro" `
    "#C084FC (Lavender) + #FAF5FF (Vanilla) + #EAB308 (Gold)"

$bmp4.Save("$outDir\gorra_04_dama_chic_aesthetic.png", [System.Drawing.Imaging.ImageFormat]::Png)
$g4.Dispose()
$bmp4.Dispose()

# ------------------------------------------------------------------------------
# 5. CHAVOS SNAPBACK URBANA
# ------------------------------------------------------------------------------
Write-Host "5. Renderizando Gorra 05: Chavos Snapback Urbana..." -ForegroundColor Green
$bmp5 = [System.Drawing.Bitmap]::new(1080, 1080)
$g5   = [System.Drawing.Graphics]::FromImage($bmp5)
$g5.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g5.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

DrawStudioBackdrop $g5 "default"
DrawCap3D $g5 `
    ([System.Drawing.Color]::FromArgb(18, 18, 24)) `
    ([System.Drawing.Color]::FromArgb(5, 5, 10)) `
    ([System.Drawing.Color]::FromArgb(28, 28, 38)) `
    ([System.Drawing.Color]::FromArgb(34, 197, 94)) `
    $false "snapback" {
        param($g)
        $rectPatch = [System.Drawing.Rectangle]::new(430, 350, 220, 160)
        $brushPatch = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(235, 10, 10, 16))
        $penNeon = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(34, 197, 94), 3.5)
        DrawRoundedRect $g $brushPatch $penNeon $rectPatch 18

        if ($script:ovni) { $g.DrawImage($script:ovni, 445, 365, 95, 95) }
        if ($script:mapache) { $g.DrawImage($script:mapache, 545, 370, 85, 85) }

        $fontS1 = MakeFont "Segoe UI Black" 12 ([System.Drawing.FontStyle]::Bold)
        $brushGreen = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(74, 222, 128))
        $g.DrawString("ABDUCIDOS MIRAMAR", $fontS1, $brushGreen, [float]540, [float]485, $script:sfCenter)

        $brushPatch.Dispose()
        $penNeon.Dispose()
        $fontS1.Dispose()
        $brushGreen.Dispose()
    }

DrawProductInfoCard $g5 `
    "CHAVOS URBAN SNAPBACK" `
    ([System.Drawing.Color]::FromArgb(34, 197, 94)) `
    "SNAPBACK URBANA POP ART • NEGRO MATE / VERDE NEON" `
    "Lana Acrilica Estructurada Premium" `
    "Snapback Flat-Brim Clasico" `
    "Bordado 3D Puff Alien & Raccoon" `
    "#121218 (Matte Black) + #22C55E (Neon Green) + #FBBF24 (Gold)"

$bmp5.Save("$outDir\gorra_05_chavos_snapback_urbana.png", [System.Drawing.Imaging.ImageFormat]::Png)
$g5.Dispose()
$bmp5.Dispose()

# ------------------------------------------------------------------------------
# 6. CHAVOS MIRAMAR COASTAL SURF
# ------------------------------------------------------------------------------
Write-Host "6. Renderizando Gorra 06: Chavos Coastal Surf..." -ForegroundColor Green
$bmp6 = [System.Drawing.Bitmap]::new(1080, 1080)
$g6   = [System.Drawing.Graphics]::FromImage($bmp6)
$g6.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g6.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

DrawStudioBackdrop $g6 "default"
DrawCap3D $g6 `
    ([System.Drawing.Color]::FromArgb(56, 115, 175)) `
    ([System.Drawing.Color]::FromArgb(30, 70, 115)) `
    ([System.Drawing.Color]::FromArgb(70, 130, 190)) `
    ([System.Drawing.Color]::FromArgb(25, 60, 100)) `
    $false "dad_hat" {
        param($g)
        $rectPatch = [System.Drawing.Rectangle]::new(455, 365, 170, 135)
        $brushLeather = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
            $rectPatch,
            [System.Drawing.Color]::FromArgb(217, 119, 6),
            [System.Drawing.Color]::FromArgb(180, 83, 9),
            [System.Drawing.Drawing2D.LinearGradientMode]::Vertical
        )
        $penStitchL = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(254, 243, 199), 2)
        $penStitchL.DashStyle = [System.Drawing.Drawing2D.DashStyle]::Dash
        DrawRoundedRect $g $brushLeather $penStitchL $rectPatch 20

        $g.DrawImage($script:logo, 495, 375, 90, 80)

        $fontL1 = MakeFont "Segoe UI Black" 10 ([System.Drawing.FontStyle]::Bold)
        $brushCream = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(254, 243, 199))
        $g.DrawString("MIRAMAR SURF CO.", $fontL1, $brushCream, [float]540, [float]475, $script:sfCenter)

        $brushLeather.Dispose()
        $penStitchL.Dispose()
        $fontL1.Dispose()
        $brushCream.Dispose()
    }

DrawProductInfoCard $g6 `
    "CHAVOS COASTAL SURF" `
    ([System.Drawing.Color]::FromArgb(217, 119, 6)) `
    "DAD CAP COASTAL SURF • DENIM DESLAVADO / CUERO TOSTADO" `
    "100% Algodon Canvas Vintage Washed" `
    "Correa Cuero con Hebilla Bronce" `
    "Parche Cuero Grabado a Fuego" `
    "#3873AF (Washed Denim) + #D97706 (Tan Leather) + #FEF3C7 (Sand)"

$bmp6.Save("$outDir\gorra_06_chavos_coastal_surf.png", [System.Drawing.Imaging.ImageFormat]::Png)
$g6.Dispose()
$bmp6.Dispose()

$logo.Dispose()
if ($juancho) { $juancho.Dispose() }
if ($mapache) { $mapache.Dispose() }
if ($ovni)    { $ovni.Dispose() }

Write-Host "`nColeccion de 6 gorras generada exitosamente en:" -ForegroundColor Green
Write-Host "$outDir" -ForegroundColor Cyan
Get-ChildItem "$outDir\*.png" | Select-Object Name, Length, LastWriteTime
