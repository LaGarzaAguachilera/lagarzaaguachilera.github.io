Add-Type -AssemblyName System.Drawing

$width = 1080
$height = 1920
$bmp = New-Object System.Drawing.Bitmap($width, $height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

# Clear fully transparent
$g.Clear([System.Drawing.Color]::Transparent)

# --- HEADER (Y: 0 to 400) ---
$headerHeight = 400
$headerRect = New-Object System.Drawing.Rectangle(0, 0, $width, $headerHeight)
$headerBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    $headerRect,
    [System.Drawing.Color]::FromArgb(255, 6, 18, 32),     # Deep Navy
    [System.Drawing.Color]::FromArgb(255, 12, 34, 56),    # Navy Accent
    [System.Drawing.Drawing2D.LinearGradientMode]::Vertical
)
$g.FillRectangle($headerBrush, $headerRect)

# Header border neon gradient line (Y: 395 to 400)
$neonBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    (New-Object System.Drawing.Rectangle(0, 395, $width, 5)),
    [System.Drawing.Color]::FromArgb(255, 0, 230, 153),   # Esmeralda aguachile
    [System.Drawing.Color]::FromArgb(255, 250, 204, 21),  # Dorado tampiqueño
    [System.Drawing.Drawing2D.LinearGradientMode]::Horizontal
)
$g.FillRectangle($neonBrush, 0, 395, $width, 5)

# Soft shadow below header into video
for ($i = 0; $i -lt 20; $i++) {
    $alpha = [int](150 * (1 - ($i / 20)))
    $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb($alpha, 0, 0, 0), 1)
    $g.DrawLine($pen, 0, 400 + $i, $width, 400 + $i)
    $pen.Dispose()
}

# Circular Logo in Header
$logoPath = "d:\AG\la garza aguachilera\La garza aguachilera.jpeg"
if (Test-Path $logoPath) {
    $origLogo = [System.Drawing.Image]::FromFile($logoPath)
    $logoSize = 230
    $logoX = [int](($width - $logoSize) / 2)
    $logoY = 25
    
    # Circle path
    $circlePath = New-Object System.Drawing.Drawing2D.GraphicsPath
    $circlePath.AddEllipse($logoX, $logoY, $logoSize, $logoSize)
    
    # Clip and draw logo
    $state = $g.Save()
    $g.SetClip($circlePath)
    $g.DrawImage($origLogo, $logoX, $logoY, $logoSize, $logoSize)
    $g.Restore($state)
    
    # Outer gold and inner white ring
    $borderPenGold = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 250, 204, 21), 4)
    $g.DrawEllipse($borderPenGold, $logoX, $logoY, $logoSize, $logoSize)
    $borderPenWhite = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(220, 255, 255, 255), 2)
    $g.DrawEllipse($borderPenWhite, $logoX + 2, $logoY + 2, $logoSize - 4, $logoSize - 4)
    
    $origLogo.Dispose()
}

# Header Typography
$fontTitle = New-Object System.Drawing.Font("Trebuchet MS", 29, [System.Drawing.FontStyle]::Bold)
$fontSub = New-Object System.Drawing.Font("Arial", 18, [System.Drawing.FontStyle]::Bold)
$whiteBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
$emeraldBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 0, 230, 153))

$stringFormatCenter = New-Object System.Drawing.StringFormat
$stringFormatCenter.Alignment = [System.Drawing.StringAlignment]::Center
$stringFormatCenter.LineAlignment = [System.Drawing.StringAlignment]::Center

$g.DrawString("LA GARZA AGUACHILERA", $fontTitle, $whiteBrush, ($width / 2), 295, $stringFormatCenter)
$g.DrawString("TOSTIAGUACHILES  *  TAMPICO & MADERO", $fontSub, $emeraldBrush, ($width / 2), 345, $stringFormatCenter)

# --- FOOTER (Y: 1560 to 1920) ---
$footerTop = 1560
$footerHeight = $height - $footerTop
$footerRect = New-Object System.Drawing.Rectangle(0, $footerTop, $width, $footerHeight)
$footerBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    $footerRect,
    [System.Drawing.Color]::FromArgb(255, 12, 34, 56),
    [System.Drawing.Color]::FromArgb(255, 5, 14, 24),
    [System.Drawing.Drawing2D.LinearGradientMode]::Vertical
)
$g.FillRectangle($footerBrush, $footerRect)

# Footer top border neon line
$neonFooterBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    (New-Object System.Drawing.Rectangle(0, $footerTop, $width, 5)),
    [System.Drawing.Color]::FromArgb(255, 250, 204, 21),
    [System.Drawing.Color]::FromArgb(255, 0, 230, 153),
    [System.Drawing.Drawing2D.LinearGradientMode]::Horizontal
)
$g.FillRectangle($neonFooterBrush, 0, $footerTop, $width, 5)

# Soft shadow above footer into video
for ($i = 0; $i -lt 20; $i++) {
    $alpha = [int](150 * (1 - ($i / 20)))
    $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb($alpha, 0, 0, 0), 1)
    $g.DrawLine($pen, 0, $footerTop - $i, $width, $footerTop - $i)
    $pen.Dispose()
}

# WhatsApp CTA Pill Box
$ctaRect = New-Object System.Drawing.Rectangle(90, 1595, 900, 86)
$ctaPath = New-Object System.Drawing.Drawing2D.GraphicsPath
$radius = 43
$ctaPath.AddArc($ctaRect.X, $ctaRect.Y, $radius, $radius, 180, 90)
$ctaPath.AddArc($ctaRect.Right - $radius, $ctaRect.Y, $radius, $radius, 270, 90)
$ctaPath.AddArc($ctaRect.Right - $radius, $ctaRect.Bottom - $radius, $radius, $radius, 0, 90)
$ctaPath.AddArc($ctaRect.X, $ctaRect.Bottom - $radius, $radius, $radius, 90, 90)
$ctaPath.CloseFigure()

$ctaBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    $ctaRect,
    [System.Drawing.Color]::FromArgb(255, 37, 211, 102),  # WhatsApp Green
    [System.Drawing.Color]::FromArgb(255, 16, 148, 102),  # Emerald Green
    [System.Drawing.Drawing2D.LinearGradientMode]::Horizontal
)
$g.FillPath($ctaBrush, $ctaPath)

$ctaPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 255, 255, 255), 3)
$g.DrawPath($ctaPen, $ctaPath)

$fontCTA = New-Object System.Drawing.Font("Trebuchet MS", 27, [System.Drawing.FontStyle]::Bold)
$g.DrawString("PEDIDOS WHATSAPP: 833 252 09 88", $fontCTA, $whiteBrush, ($width / 2), 1638, $stringFormatCenter)

# Product & Price Text
$fontPrice = New-Object System.Drawing.Font("Trebuchet MS", 34, [System.Drawing.FontStyle]::Bold)
$goldBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 254, 240, 138))
$g.DrawString("TOSTIAGUACHILE VERDE  *  `$150 MXN", $fontPrice, $goldBrush, ($width / 2), 1725, $stringFormatCenter)

# Subtitle / Details
$fontDetail = New-Object System.Drawing.Font("Arial", 20, [System.Drawing.FontStyle]::Bold)
$lightBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 241, 245, 249))
$g.DrawString("El producto es preparado frente a usted para corroborar su frescura", $fontDetail, $lightBrush, ($width / 2), 1785, $stringFormatCenter)

# Location Tag
$fontLoc = New-Object System.Drawing.Font("Trebuchet MS", 19, [System.Drawing.FontStyle]::Bold)
$tealBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 52, 211, 153))
$g.DrawString("Tampico y Ciudad Madero  *  Servicio a Domicilio", $fontLoc, $tealBrush, ($width / 2), 1840, $stringFormatCenter)

# Cleanup
$g.Dispose()
$outPath = "d:\AG\la garza aguachilera\herramientas\branding_overlay.png"
$bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Output "Perfect overlay generated at $outPath"

