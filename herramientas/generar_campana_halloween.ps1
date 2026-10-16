# ==============================================================================
# LA GARZA AGUACHILERA — GENERADOR DE CAMPAÑA HALLOWEEN & DÍA DE MUERTOS
# Archivo: herramientas\generar_campana_halloween.ps1
# Genera 4 piezas estelares en formato Feed (1080x1080) y Story (1080x1920)
# Estética Pop-Comic Festive Spooky (Cero Gore/Sangre, Franquicia Alta Calidad)
# Cumple rigurosamente con Safe Zones:
# - Feed: Márgenes >= 70px en todos los lados
# - Story: Lienzo de contenido seguro entre Y: 250px y 1570px
# ==============================================================================

Add-Type -AssemblyName System.Drawing

$rootDir   = "d:\AG\la garza aguachilera"
$outPosts  = "$rootDir\contenido_redes\posts_periodicos"
$outSpooky = "$rootDir\contenido_redes\catalogo_mes\spooky"

# Asegurar directorios destino
foreach ($dir in @($outPosts, $outSpooky)) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}

# Rutas de activos oficiales y stickers
$logoPath      = "$rootDir\La garza aguachilera.jpeg"
$foodRedondo   = "$rootDir\tostiaguachile_verde_redondo.jpg"
$foodHero      = "$rootDir\aguachile_verde_hero.jpg"
$cleanComida   = "$rootDir\clean_comida.png"
$skylinePath   = "$rootDir\tampico_skyline_bg.jpg"
if (-not (Test-Path $skylinePath)) {
    $skylinePath = "$rootDir\herramientas\portada_bg_tampico_skyline_1792107773833.jpg"
}

# Stickers transparentes de temporada de las 3 mascotas
$stickerJuancho = "$rootDir\sticker_spooky_juancho_jason.png"
$stickerMapache = "$rootDir\sticker_spooky_mapache_freddy.png"
$stickerOvni    = "$rootDir\sticker_spooky_ovni_muertos.png"

# Caracteres Unicode seguros para Windows PowerShell 5.1
$uA = [char]0x00C1; $uE = [char]0x00C9; $uI = [char]0x00CD; $uO = [char]0x00D3; $uU = [char]0x00DA; $uN = [char]0x00D1
$lA = [char]0x00E1; $lE = [char]0x00E9; $lI = [char]0x00ED; $lO = [char]0x00F3; $lU = [char]0x00FA; $lN = [char]0x00F1
$iE = [char]0x00A1; $iQ = [char]0x00BF; $deg = [char]0x00B0; $bul = [char]0x2022; $star = [char]0x2605
$qL = [char]0x00AB; $qR = [char]0x00BB

# Formateadores de texto tipográfico
$sfCenter = [System.Drawing.StringFormat]::new()
$sfCenter.Alignment = [System.Drawing.StringAlignment]::Center
$sfCenter.LineAlignment = [System.Drawing.StringAlignment]::Center

$sfLeft = [System.Drawing.StringFormat]::new()
$sfLeft.Alignment = [System.Drawing.StringAlignment]::Near
$sfLeft.LineAlignment = [System.Drawing.StringAlignment]::Center

# ==============================================================================
# MOTOR GRAFICO Y PRIMITIVAS POP DE ALTO IMPACTO
# ==============================================================================

function Draw-SkylineAtmosphere([System.Drawing.Graphics]$g, [System.Drawing.Rectangle]$destRect, [float]$alpha = 0.28) {
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

function Draw-SpookySunburstRays([System.Drawing.Graphics]$g, [float]$cx, [float]$cy, [float]$radius, [int]$rays, [System.Drawing.Color]$rayColor) {
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

    # Tier 1: Soft Ambient Occlusion Bloom (sombra amplia de atmósfera)
    $stateAmb = $g.Save()
    $g.TranslateTransform($cx + 12, $cy + 15)
    if ($angle -ne 0) { $g.RotateTransform($angle) }
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $cmAmb = [System.Drawing.Imaging.ColorMatrix]::new(@(
        @(0, 0, 0, 0, 0),
        @(0, 0, 0, 0, 0),
        @(0, 0, 0, 0, 0),
        @(0, 0, 0, 0.28, 0),
        @(0, 0, 0, 0, 1)
    ))
    $iaAmb = [System.Drawing.Imaging.ImageAttributes]::new()
    $iaAmb.SetColorMatrix($cmAmb)
    $ambW = $w * 1.05
    $ambH = $h * 1.05
    $g.DrawImage($img, [System.Drawing.Rectangle]::new([int](-$ambW/2), [int](-$ambH/2), [int]$ambW, [int]$ambH), 0, 0, $img.Width, $img.Height, [System.Drawing.GraphicsUnit]::Pixel, $iaAmb)
    $g.Restore($stateAmb)
    $iaAmb.Dispose()

    # Tier 2: Crisp Contact Drop Shadow (sombra de contacto nítida)
    $stateSh = $g.Save()
    $g.TranslateTransform($cx + 6, $cy + 8)
    if ($angle -ne 0) { $g.RotateTransform($angle) }
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $cm = [System.Drawing.Imaging.ColorMatrix]::new(@(
        @(0, 0, 0, 0, 0),
        @(0, 0, 0, 0, 0),
        @(0, 0, 0, 0, 0),
        @(0, 0, 0, 0.55, 0),
        @(0, 0, 0, 0, 1)
    ))
    $ia = [System.Drawing.Imaging.ImageAttributes]::new()
    $ia.SetColorMatrix($cm)
    $g.DrawImage($img, [System.Drawing.Rectangle]::new([int](-$w/2), [int](-$h/2), [int]$w, [int]$h), 0, 0, $img.Width, $img.Height, [System.Drawing.GraphicsUnit]::Pixel, $ia)
    $g.Restore($stateSh)
    $ia.Dispose()

    # Tier 3: Renderizado nítido del Sticker en Alta Calidad
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
        $shBrush1 = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(75, 0, 0, 0))
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
        $shBrush2 = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(140, 0, 0, 0))
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
    $shBrush1 = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(80, 0, 0, 0))
    $g.FillEllipse($shBrush1, $x - 2, $y + 8, $size + 12, $size + 12)
    $shBrush1.Dispose()

    # Contact shadow
    $shBrush2 = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(160, 0, 0, 0))
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

function Draw-SpookyPricePill([System.Drawing.Graphics]$g, [System.Drawing.RectangleF]$rect, [string]$extraText = "") {
    # Gradiente temático Cempasúchil Fuego (#F97316 a #EA580C)
    $bGrad = [System.Drawing.Drawing2D.LinearGradientBrush]::new($rect, [System.Drawing.Color]::FromArgb(249, 115, 22), [System.Drawing.Color]::FromArgb(194, 65, 12), 0.0)
    $penPill = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(254, 240, 138), 3.0)
    Draw-RoundedBox $g $bGrad $penPill $rect ($rect.Height / 2.0) $true
    $bGrad.Dispose()
    $penPill.Dispose()

    $fPrice = [System.Drawing.Font]::new("Segoe UI Black", 16.0, [System.Drawing.FontStyle]::Bold)
    $bWhite = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)
    $pDark = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(15, 23, 42), 4)
    $pDark.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round

    $displayStr = "$($script:star) `$170 MXN LA BOLSA $($script:bul) ~100g CAMAR$($script:uO)N"
    if ($extraText) { $displayStr += " $($script:bul) $extraText" }
    $displayStr += " $($script:star)"

    Draw-OutlinedText $g $displayStr $fPrice $bWhite $pDark ($rect.X + $rect.Width/2.0) ($rect.Y + $rect.Height/2.0) $script:sfCenter
    $fPrice.Dispose(); $bWhite.Dispose(); $pDark.Dispose()
}

function Draw-SpookyFreshnessCard([System.Drawing.Graphics]$g, [System.Drawing.RectangleF]$rect) {
    # Tarjeta glassmorphism con marco morado/dorado
    $brushCard = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
        $rect,
        [System.Drawing.Color]::FromArgb(245, 19, 9, 38),
        [System.Drawing.Color]::FromArgb(250, 10, 4, 20),
        90.0
    )
    $penCard = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(250, 204, 21), 2.5)
    Draw-RoundedBox $g $brushCard $penCard $rect 20 $true
    $brushCard.Dispose()
    $penCard.Dispose()

    $fStmt = [System.Drawing.Font]::new("Segoe UI Black", 13.5, [System.Drawing.FontStyle]::Bold)
    $bYellow = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(254, 240, 138))
    $pDark = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(15, 23, 42), 4)
    $pDark.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round

    $stmt = "$($script:qL)El producto es preparado frente a usted para corroborar su frescura$($script:qR)"
    Draw-OutlinedText $g $stmt $fStmt $bYellow $pDark ($rect.X + $rect.Width/2.0) ($rect.Y + $rect.Height/2.0) $script:sfCenter
    $fStmt.Dispose(); $bYellow.Dispose(); $pDark.Dispose()
}

function Draw-SpookyWhatsAppButton([System.Drawing.Graphics]$g, [System.Drawing.RectangleF]$rect) {
    # Botón WhatsApp con gradiente verde vibrante y contorno blanco
    $bWa = [System.Drawing.Drawing2D.LinearGradientBrush]::new($rect, [System.Drawing.Color]::FromArgb(37, 211, 102), [System.Drawing.Color]::FromArgb(18, 140, 62), 90.0)
    $pWa = [System.Drawing.Pen]::new([System.Drawing.Color]::White, 3.5)
    Draw-RoundedBox $g $bWa $pWa $rect ($rect.Height / 2.0) $true
    $bWa.Dispose()
    $pWa.Dispose()

    $fWa = [System.Drawing.Font]::new("Segoe UI Black", 17.5, [System.Drawing.FontStyle]::Bold)
    $bWhite = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)
    $pDark = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(15, 23, 42), 4.5)
    $pDark.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round

    $waText = "PEDIDOS Y APARTADOS WHATSAPP: 833 252 09 88"
    Draw-OutlinedText $g $waText $fWa $bWhite $pDark ($rect.X + $rect.Width/2.0) ($rect.Y + $rect.Height/2.0) $script:sfCenter
    $fWa.Dispose(); $bWhite.Dispose(); $pDark.Dispose()
}

# ==============================================================================
# DEFINICION DE LOS 4 ARTES DE TEMPORADA
# ==============================================================================

$spookyCampaign = @(
    @{
        Id = 1
        Slug = "spooky_post01_juancho_resurreccion"
        Badge = "EDICI$($uO)N ESPECIAL HALLOWEEN $($bul) TAMPICO"
        Headline = "$($iE)RESURRECCI$($uO)N DE LA CRUDA!"
        Subhead = "NO ESTABAS MUERTO... $($iE)SOLO ESTABAS CRUDO!"
        Color1 = [System.Drawing.Color]::FromArgb(31, 16, 58)      # Deep Twilight Purple
        Color2 = [System.Drawing.Color]::FromArgb(11, 4, 26)       # Nocturnal Dark
        AccentColor = [System.Drawing.Color]::FromArgb(249, 115, 22) # Cempasúchil Orange
        StickerPrimary = "juancho_jason"
        StickerSecondary = "comida"
        ExtraTag = "LA CURA SAGRADA JAIBA"
    },
    @{
        Id = 2
        Slug = "spooky_post02_mapache_freddy_crunch"
        Badge = "PESADILLA EN LAS ESCOLLERAS"
        Headline = "$($iE)CRUNCH QUE DESPIERTA A CUALQUIERA!"
        Subhead = "GARRAS LISTAS PARA LOS TOSTITOS SALSA VERDE"
        Color1 = [System.Drawing.Color]::FromArgb(44, 10, 32)      # Nightmare Crimson Violet
        Color2 = [System.Drawing.Color]::FromArgb(15, 3, 14)       # Deep Black Velvet
        AccentColor = [System.Drawing.Color]::FromArgb(132, 204, 22) # Toxic Slime Lime
        StickerPrimary = "mapache_freddy"
        StickerSecondary = "comida"
        ExtraTag = "CRUNCH 100% INTACTO"
    },
    @{
        Id = 3
        Slug = "spooky_post03_ovni_ultratumba"
        Badge = "EXPEDIENTE ULTRATUMBA $($bul) PLAYA MIRAMAR"
        Headline = "ABDUCIDOS DE ULTRATUMBA"
        Subhead = "VIENEN POR EL LIM$($uO)N COLIMA Y CHILE SERRANO"
        Color1 = [System.Drawing.Color]::FromArgb(46, 8, 84)       # Mystic Cosmic Violet
        Color2 = [System.Drawing.Color]::FromArgb(10, 3, 20)       # Void Black
        AccentColor = [System.Drawing.Color]::FromArgb(251, 146, 60) # Cempasúchil Neon
        StickerPrimary = "ovni_muertos"
        StickerSecondary = "comida"
        ExtraTag = "SABOR DE OTRA DIMENSI$($uO)N"
    },
    @{
        Id = 4
        Slug = "spooky_post04_tridente_spooky_pack"
        Badge = "ESPECIAL HALLOWEEN Y D$($uI)A DE MUERTOS"
        Headline = "EL TRIDENTE SPOOKY COSTE$($uN)O"
        Subhead = "JUANCHO, MAPACHE Y OVNI $($bul) LA CURA SAGRADA"
        Color1 = [System.Drawing.Color]::FromArgb(26, 13, 44)      # Grand Spooky Festival
        Color2 = [System.Drawing.Color]::FromArgb(8, 4, 18)        # Midnight Shadow
        AccentColor = [System.Drawing.Color]::FromArgb(249, 115, 22) # Cempasúchil Gold
        StickerPrimary = "tridente_spooky"
        StickerSecondary = "comida"
        ExtraTag = "LAS 3 MASCOTAS DISFRAZADAS"
    }
)

# ==============================================================================
# RENDERIZADO: FEED (1080x1080) — MÁRGENES >= 70PX RIGUROSOS
# ==============================================================================

function Render-SpookyFeed($item) {
    $bmp = [System.Drawing.Bitmap]::new(1080, 1080, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
    $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality

    # Fondo degradado temático
    $canvasRect = [System.Drawing.Rectangle]::new(0, 0, 1080, 1080)
    $bgBrush = [System.Drawing.Drawing2D.LinearGradientBrush]::new($canvasRect, $item.Color1, $item.Color2, 45.0)
    $g.FillRectangle($bgBrush, $canvasRect)
    $bgBrush.Dispose()

    # Rayos cómicos y atmósfera skyline nocturno
    Draw-SpookySunburstRays $g 540 500 780 18 ([System.Drawing.Color]::FromArgb(24, 249, 115, 22))
    Draw-SkylineAtmosphere $g ([System.Drawing.Rectangle]::new(0, 170, 1080, 530)) 0.28

    # 1. Header Badge Superior (Safe Zone Y=70, Margen superior = 70px)
    $badgeRect = [System.Drawing.RectangleF]::new(140, 70, 800, 38)
    $bBadge = [System.Drawing.Drawing2D.LinearGradientBrush]::new($badgeRect, [System.Drawing.Color]::FromArgb(235, 20, 10, 38), [System.Drawing.Color]::FromArgb(240, 10, 4, 22), 0.0)
    $pBadge = [System.Drawing.Pen]::new($item.AccentColor, 2.2)
    Draw-RoundedBox $g $bBadge $pBadge $badgeRect 19 $true
    $bBadge.Dispose(); $pBadge.Dispose()

    $fBadge = [System.Drawing.Font]::new("Segoe UI Black", 11.5, [System.Drawing.FontStyle]::Bold)
    $bWhite = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)
    $g.DrawString($item.Badge, $fBadge, $bWhite, [float]540, [float]89, $sfCenter)

    # 2. Titular Principal (Y=120, Ancho controlado, márgenes laterales >= 70px)
    $fTitle = [System.Drawing.Font]::new("Segoe UI Black", 21.0, [System.Drawing.FontStyle]::Bold)
    $pDark = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(8, 4, 18), 7)
    $pDark.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
    Draw-OutlinedText $g $item.Headline $fTitle $bWhite $pDark 540 138 $sfCenter

    # 3. Subtítulo / Sello temático (Y=175)
    $fSub = [System.Drawing.Font]::new("Segoe UI Black", 12.0, [System.Drawing.FontStyle]::Bold)
    $bAccent = [System.Drawing.SolidBrush]::new($item.AccentColor)
    Draw-OutlinedText $g $item.Subhead $fSub $bAccent $pDark 540 178 $sfCenter
    $bAccent.Dispose()

    # 4. Arena Visual Central (Y=205 a Y=735)
    if ($item.StickerPrimary -eq "juancho_jason") {
        # Juancho Jason Zombie
        Draw-StickerWithShadow $g $stickerJuancho 60 215 480 480 -4
        Draw-StickerWithShadow $g $cleanComida 460 230 520 520 2
    } elseif ($item.StickerPrimary -eq "mapache_freddy") {
        # Mapache Freddy Krueger
        Draw-StickerWithShadow $g $stickerMapache 520 215 480 480 4
        Draw-StickerWithShadow $g $cleanComida 70 230 520 520 -2
    } elseif ($item.StickerPrimary -eq "ovni_muertos") {
        # OVNI del Más Allá
        Draw-StickerWithShadow $g $stickerOvni 520 195 490 490 3
        Draw-StickerWithShadow $g $cleanComida 70 240 520 520 -2
    } elseif ($item.StickerPrimary -eq "tridente_spooky") {
        # Tridente Spooky: Las 3 mascotas reunidas
        Draw-StickerWithShadow $g $stickerOvni 390 190 300 300 0
        Draw-StickerWithShadow $g $stickerJuancho 50 250 350 350 -5
        Draw-StickerWithShadow $g $stickerMapache 680 250 350 350 5
        Draw-StickerWithShadow $g $cleanComida 270 260 540 540 0
    }

    # Badge Flotante del Producto
    $popPillRect = [System.Drawing.RectangleF]::new(340, 695, 400, 40)
    $bPop = [System.Drawing.Drawing2D.LinearGradientBrush]::new($popPillRect, [System.Drawing.Color]::FromArgb(240, 22, 163, 74), [System.Drawing.Color]::FromArgb(240, 21, 128, 61), 0.0)
    $pPop = [System.Drawing.Pen]::new([System.Drawing.Color]::White, 2.5)
    Draw-RoundedBox $g $bPop $pPop $popPillRect 20 $true
    $bPop.Dispose(); $pPop.Dispose()
    $fPop = [System.Drawing.Font]::new("Segoe UI Black", 12.0, [System.Drawing.FontStyle]::Bold)
    $g.DrawString("TOSTITOS SALSA VERDE", $fPop, $bWhite, [float]540, [float]715, $sfCenter)
    $fPop.Dispose()

    # Logo oficial de marca en esquina superior derecha
    Draw-OfficialLogoBadge $g 935 55 95 ([System.Drawing.Color]::FromArgb(249, 115, 22))

    # 5. Price Pill Estandarizado $170 MXN (Y=755, X=80 a 1000, Margen lateral = 80px >= 70px)
    Draw-SpookyPricePill $g ([System.Drawing.RectangleF]::new(80, 755, 920, 58)) $item.ExtraTag

    # 6. Tarjeta de Frescura Obligatoria (Y=825)
    Draw-SpookyFreshnessCard $g ([System.Drawing.RectangleF]::new(80, 825, 920, 54))

    # 7. Botón de Conversión WhatsApp 833 252 09 88 (Y=892)
    Draw-SpookyWhatsAppButton $g ([System.Drawing.RectangleF]::new(80, 892, 920, 62))

    # 8. Pie de Página Seguro (Y=968 a 1010, termina antes de Y=1010px, margen inferior >= 70px)
    $fFootA = [System.Drawing.Font]::new("Segoe UI Black", 11.5, [System.Drawing.FontStyle]::Bold)
    $bFootYellow = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(254, 240, 138))
    $footStrA = "ENTREGAS S$($uA)BADOS Y DOMINGOS (1:00 PM - 5:00 PM) $($bul) RUTAS ANUNCIADAS EN REDES"
    $g.DrawString($footStrA, $fFootA, $bFootYellow, [float]540, [float]974, $sfCenter)
    $fFootA.Dispose(); $bFootYellow.Dispose()

    $fFootB = [System.Drawing.Font]::new("Segoe UI", 10.5, [System.Drawing.FontStyle]::Bold)
    $bFootGray = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(226, 232, 240))
    $footStrB = "Colonia Flores, Tampico, Tamaulipas $($bul) Preventa y apartados por WhatsApp"
    $g.DrawString($footStrB, $fFootB, $bFootGray, [float]540, [float]998, $sfCenter)
    $fFootB.Dispose(); $bFootGray.Dispose()

    # Limpieza
    $fTitle.Dispose(); $fSub.Dispose(); $fBadge.Dispose()
    $bWhite.Dispose(); $pDark.Dispose()
    $g.Dispose()

    return $bmp
}

# ==============================================================================
# RENDERIZADO: STORY (1080x1920) — SAFE ZONE ESTRICTA ENTRE Y: 250PX Y 1570PX
# ==============================================================================

function Render-SpookyStory($item) {
    $bmp = [System.Drawing.Bitmap]::new(1080, 1920, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
    $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality

    # Fondo temático vertical
    $canvasRect = [System.Drawing.Rectangle]::new(0, 0, 1080, 1920)
    $bgBrush = [System.Drawing.Drawing2D.LinearGradientBrush]::new($canvasRect, $item.Color1, $item.Color2, 90.0)
    $g.FillRectangle($bgBrush, $canvasRect)
    $bgBrush.Dispose()

    # Atmósfera central nocturna
    Draw-SkylineAtmosphere $g ([System.Drawing.Rectangle]::new(0, 480, 1080, 720)) 0.32

    # Logo decorativo superior en cabecera fuera de interferencias (Y=110 a 220)
    Draw-OfficialLogoBadge $g 480 115 120 ([System.Drawing.Color]::FromArgb(249, 115, 22))

    # ==========================================================================
    # COMIENZO DE LA SAFE ZONE ESTRICTA DE STORY (Y >= 250px)
    # ==========================================================================

    # 1. Badge de Temporada (Y=255 a 295)
    $tagPill = [System.Drawing.RectangleF]::new(160, 255, 760, 38)
    $bTag = [System.Drawing.Drawing2D.LinearGradientBrush]::new($tagPill, [System.Drawing.Color]::FromArgb(235, 20, 10, 38), [System.Drawing.Color]::FromArgb(240, 10, 4, 22), 0.0)
    $pTag = [System.Drawing.Pen]::new($item.AccentColor, 2.2)
    Draw-RoundedBox $g $bTag $pTag $tagPill 19 $true
    $bTag.Dispose(); $pTag.Dispose()

    $fTag = [System.Drawing.Font]::new("Segoe UI Black", 11.0, [System.Drawing.FontStyle]::Bold)
    $bWhite = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)
    $g.DrawString("ESPECIAL HALLOWEEN Y D$($uI)A DE MUERTOS $($bul) TAMPICO Y MADERO", $fTag, $bWhite, [float]540, [float]274, $sfCenter)
    $fTag.Dispose()

    # 2. Nombre de Marca Outlined (Y=310 a 350)
    $fBrand = [System.Drawing.Font]::new("Segoe UI Black", 26.0, [System.Drawing.FontStyle]::Bold)
    $pDark8 = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(8, 4, 18), 8)
    $pDark8.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
    Draw-OutlinedText $g "LA GARZA AGUACHILERA" $fBrand $bWhite $pDark8 540 330 $sfCenter
    $fBrand.Dispose()

    # 3. Titular de Temporada (Y=365 a 405)
    $fTheme = [System.Drawing.Font]::new("Segoe UI Black", 19.5, [System.Drawing.FontStyle]::Bold)
    $bAccent = [System.Drawing.SolidBrush]::new($item.AccentColor)
    Draw-OutlinedText $g $item.Headline $fTheme $bAccent $pDark8 540 385 $sfCenter
    $fTheme.Dispose(); $bAccent.Dispose()

    # 4. Subtítulo (Y=415 a 440)
    $fSubS = [System.Drawing.Font]::new("Segoe UI Black", 12.0, [System.Drawing.FontStyle]::Bold)
    $bYellow = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(254, 240, 138))
    Draw-OutlinedText $g $item.Subhead $fSubS $bYellow $pDark8 540 425 $sfCenter
    $fSubS.Dispose(); $bYellow.Dispose()

    # 5. Arena Visual Central (Y=455 a 975)
    if ($item.StickerPrimary -eq "juancho_jason") {
        Draw-StickerWithShadow $g $cleanComida 270 480 540 540 -2
        Draw-StickerWithShadow $g $stickerJuancho 50 630 420 420 -5
    } elseif ($item.StickerPrimary -eq "mapache_freddy") {
        Draw-StickerWithShadow $g $cleanComida 270 480 540 540 -2
        Draw-StickerWithShadow $g $stickerMapache 610 630 420 420 5
    } elseif ($item.StickerPrimary -eq "ovni_muertos") {
        Draw-StickerWithShadow $g $stickerOvni 570 455 450 450 4
        Draw-StickerWithShadow $g $cleanComida 110 540 540 540 -2
    } elseif ($item.StickerPrimary -eq "tridente_spooky") {
        Draw-StickerWithShadow $g $stickerOvni 690 445 320 320 5
        Draw-StickerWithShadow $g $cleanComida 270 510 540 540 -2
        Draw-StickerWithShadow $g $stickerJuancho 35 680 360 360 -5
        Draw-StickerWithShadow $g $stickerMapache 690 730 350 350 5
    }

    # Patch del producto Tostitos Salsa Verde (Y=965 a 1010)
    $patchStoryRect = [System.Drawing.RectangleF]::new(340, 965, 400, 44)
    $bPatch = [System.Drawing.Drawing2D.LinearGradientBrush]::new($patchStoryRect, [System.Drawing.Color]::FromArgb(16, 185, 129), [System.Drawing.Color]::FromArgb(4, 120, 87), 0.0)
    $pPatch = [System.Drawing.Pen]::new([System.Drawing.Color]::White, 3.0)
    Draw-RoundedBox $g $bPatch $pPatch $patchStoryRect 22 $true
    $bPatch.Dispose(); $pPatch.Dispose()
    $fPatch = [System.Drawing.Font]::new("Segoe UI Black", 13.5, [System.Drawing.FontStyle]::Bold)
    $g.DrawString("TOSTITOS SALSA VERDE", $fPatch, $bWhite, [float]540, [float]987, $sfCenter)
    $fPatch.Dispose()

    # 6. Price Banner Estandarizado ($170 MXN) (Y=1025 a 1095)
    $priceStoryRect = [System.Drawing.RectangleF]::new(90, 1025, 900, 68)
    $bPriceS = [System.Drawing.Drawing2D.LinearGradientBrush]::new($priceStoryRect, [System.Drawing.Color]::FromArgb(249, 115, 22), [System.Drawing.Color]::FromArgb(234, 88, 12), 0.0)
    $pPriceS = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(254, 240, 138), 3.0)
    Draw-RoundedBox $g $bPriceS $pPriceS $priceStoryRect 34 $true
    $bPriceS.Dispose(); $pPriceS.Dispose()

    $fPriceS = [System.Drawing.Font]::new("Segoe UI Black", 19.5, [System.Drawing.FontStyle]::Bold)
    $priceStr = "$($script:star) `$170 MXN LA BOLSA $($script:bul) ~100g CAMAR$($script:uO)N $($script:star)"
    Draw-OutlinedText $g $priceStr $fPriceS $bWhite $pDark8 540 1059 $sfCenter
    $fPriceS.Dispose()

    # 7. Tarjeta de Frescura Obligatoria en Story (Y=1110 a 1225)
    $freshStoryRect = [System.Drawing.RectangleF]::new(90, 1110, 900, 115)
    $bFreshS = [System.Drawing.Drawing2D.LinearGradientBrush]::new($freshStoryRect, [System.Drawing.Color]::FromArgb(245, 18, 9, 36), [System.Drawing.Color]::FromArgb(250, 9, 4, 18), 90.0)
    $pFreshS = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(254, 240, 138), 2.5)
    Draw-RoundedBox $g $bFreshS $pFreshS $freshStoryRect 22 $true
    $bFreshS.Dispose(); $pFreshS.Dispose()

    $fFreshA = [System.Drawing.Font]::new("Segoe UI Black", 17.0, [System.Drawing.FontStyle]::Bold)
    $bYellow = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(254, 240, 138))
    $g.DrawString("$($script:qL)El producto es preparado frente a usted", $fFreshA, $bYellow, [float]540, [float]1148, $sfCenter)
    $g.DrawString("para corroborar su frescura$($script:qR)", $fFreshA, $bWhite, [float]540, [float]1185, $sfCenter)
    $fFreshA.Dispose()

    # 8. Atributos Gastronómicos Spooky (Y=1240 a 1350)
    $bulletRect = [System.Drawing.RectangleF]::new(90, 1240, 900, 110)
    $bBullet = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(220, 14, 6, 28))
    $pBullet = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(249, 115, 22), 2.0)
    Draw-RoundedBox $g $bBullet $pBullet $bulletRect 20 $true
    $bBullet.Dispose(); $pBullet.Dispose()

    $fBul = [System.Drawing.Font]::new("Segoe UI", 13.5, [System.Drawing.FontStyle]::Bold)
    $bLime = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(163, 230, 53))
    $bGray = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(226, 232, 240))
    $g.DrawString("$($script:bul) ~100g Camar$($script:lO)n mariposa fresco con limón Colima y chile serrano", $fBul, $bLime, [float]125, [float]1258)
    $g.DrawString("$($script:bul) Tostitos Salsa Verde (crujientes, ensamble al instante)", $fBul, $bGray, [float]125, [float]1288)
    $g.DrawString("$($script:bul) $($item.ExtraTag) $($script:bul) $($script:iE)La cura sagrada de Tampico!", $fBul, $bGray, [float]125, [float]1318)
    $fBul.Dispose(); $bLime.Dispose(); $bGray.Dispose()

    # 9. Botón WhatsApp CTA Grande (Y=1365 a 1465)
    $waStoryRect = [System.Drawing.RectangleF]::new(90, 1365, 900, 100)
    $bWaS = [System.Drawing.Drawing2D.LinearGradientBrush]::new($waStoryRect, [System.Drawing.Color]::FromArgb(37, 211, 102), [System.Drawing.Color]::FromArgb(18, 140, 62), 90.0)
    $pWaS = [System.Drawing.Pen]::new([System.Drawing.Color]::White, 3.5)
    Draw-RoundedBox $g $bWaS $pWaS $waStoryRect 45 $true
    $bWaS.Dispose(); $pWaS.Dispose()

    $fWaA = [System.Drawing.Font]::new("Segoe UI Black", 14.5, [System.Drawing.FontStyle]::Bold)
    $fWaB = [System.Drawing.Font]::new("Segoe UI Black", 30.0, [System.Drawing.FontStyle]::Bold)
    Draw-OutlinedText $g "PEDIDOS Y APARTADOS POR WHATSAPP" $fWaA $bWhite $pDark8 540 1390 $sfCenter
    Draw-OutlinedText $g "833 252 09 88" $fWaB $bYellow $pDark8 540 1432 $sfCenter
    $fWaA.Dispose(); $fWaB.Dispose()

    # 10. Safe Footer (Y=1480 a 1530 — estrictamente antes de Y: 1570px)
    $fFootS1 = [System.Drawing.Font]::new("Segoe UI Black", 11.5, [System.Drawing.FontStyle]::Bold)
    $bYellowS = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(254, 240, 138))
    $g.DrawString("S$($uA)BADOS Y DOMINGOS (1:00 PM - 5:00 PM) $($bul) RUTAS ANUNCIADAS EN REDES", $fFootS1, $bYellowS, [float]540, [float]1488, $sfCenter)
    $fFootS1.Dispose(); $bYellowS.Dispose()

    $fFootS2 = [System.Drawing.Font]::new("Segoe UI", 10.5, [System.Drawing.FontStyle]::Bold)
    $bGrayS = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(203, 213, 225))
    $g.DrawString("Colonia Flores, Tampico, Tamaulipas $($bul) Cobertura Tampico y Ciudad Madero", $fFootS2, $bGrayS, [float]540, [float]1512, $sfCenter)
    $fFootS2.Dispose(); $bGrayS.Dispose()

    # ==========================================================================
    # FIN DE LA SAFE ZONE ESTRICTA DE STORY (Termina en Y=1530px <= 1570px)
    # ==========================================================================

    # Limpieza
    $bWhite.Dispose(); $bYellow.Dispose(); $pDark8.Dispose()
    $g.Dispose()

    return $bmp
}

# ==============================================================================
# GUARDADO MULTIPLATAFORMA Y ESPEJO EN CATALOGO SPOOKY
# ==============================================================================

function Save-SpookyArtPair([System.Drawing.Bitmap]$bmpFeed, [System.Drawing.Bitmap]$bmpStory, [string]$slug, [int]$id) {
    # Nombres descriptivos oficiales
    $feedFile1  = "$script:outPosts\$slug.png"
    $storyFile1 = "$script:outPosts\${slug}_story.png"
    $feedFile2  = "$script:outSpooky\$slug.png"
    $storyFile2 = "$script:outSpooky\${slug}_story.png"

    # Alias cortos para compatibilidad total con cualquier consumidor (spooky_post01.png)
    $aliasFeed1  = "$script:outPosts\spooky_post0$id.png"
    $aliasStory1 = "$script:outPosts\spooky_post0${id}_story.png"
    $aliasFeed2  = "$script:outSpooky\spooky_post0$id.png"
    $aliasStory2 = "$script:outSpooky\spooky_post0${id}_story.png"

    # Guardar Feed
    $bmpFeed.Save($feedFile1, [System.Drawing.Imaging.ImageFormat]::Png)
    Copy-Item $feedFile1 $feedFile2 -Force
    Copy-Item $feedFile1 $aliasFeed1 -Force
    Copy-Item $feedFile1 $aliasFeed2 -Force

    # Guardar Story
    $bmpStory.Save($storyFile1, [System.Drawing.Imaging.ImageFormat]::Png)
    Copy-Item $storyFile1 $storyFile2 -Force
    Copy-Item $storyFile1 $aliasStory1 -Force
    Copy-Item $storyFile1 $aliasStory2 -Force

    $kbFeed  = [math]::Round((Get-Item $feedFile1).Length / 1024, 1)
    $kbStory = [math]::Round((Get-Item $storyFile1).Length / 1024, 1)
    Write-Host " [OK] Arte ${id}: $slug (Feed: ${kbFeed} KB | Story: ${kbStory} KB)" -ForegroundColor Green
}

# ==============================================================================
# EJECUCIÓN PRINCIPAL
# ==============================================================================

Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "  LA GARZA AGUACHILERA -- CAMPAÑA HALLOWEEN & DÍA DE MUERTOS" -ForegroundColor Yellow
Write-Host "  Renderizador de 4 Artes en Feed (1080x1080) y Story (1080x1920)" -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan

$startTime = Get-Date

foreach ($item in $spookyCampaign) {
    Write-Host "`nGenerando Arte $($item.Id): $($item.Headline)..." -ForegroundColor Yellow
    $bmpF = Render-SpookyFeed $item
    $bmpS = Render-SpookyStory $item
    Save-SpookyArtPair $bmpF $bmpS $item.Slug $item.Id
    $bmpF.Dispose()
    $bmpS.Dispose()
}

$elapsed = [math]::Round(((Get-Date) - $startTime).TotalSeconds, 2)
Write-Host "`n=================================================================" -ForegroundColor Cyan
Write-Host "  Campaña Spooky generada con éxito en ${elapsed}s (8 archivos principales + 8 alias)" -ForegroundColor Green
Write-Host "  Destinos:" -ForegroundColor Cyan
Write-Host "  - $outPosts" -ForegroundColor Gray
Write-Host "  - $outSpooky" -ForegroundColor Gray
Write-Host "=================================================================" -ForegroundColor Cyan
