# Generador de subtitulos dinamicos
Add-Type -AssemblyName System.Drawing

function CreateSubtitleBanner([string]$path, [string]$line1, [string]$line2, [string]$colorHex1 = "#FFFFFF", [string]$colorHex2 = "#00E699") {
    $width = 1080
    $height = 1920
    $bmp = [System.Drawing.Bitmap]::new($width, $height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
    $g.Clear([System.Drawing.Color]::Transparent)

    # Pill Box at Y: 1380 to 1510 (height: 130)
    $boxRect = [System.Drawing.Rectangle]::new(60, 1380, 960, 130)
    $pathPill = [System.Drawing.Drawing2D.GraphicsPath]::new()
    $r = 30
    $pathPill.AddArc($boxRect.X, $boxRect.Y, $r, $r, 180, 90)
    $pathPill.AddArc($boxRect.Right - $r, $boxRect.Y, $r, $r, 270, 90)
    $pathPill.AddArc($boxRect.Right - $r, $boxRect.Bottom - $r, $r, $r, 0, 90)
    $pathPill.AddArc($boxRect.X, $boxRect.Bottom - $r, $r, $r, 90, 90)
    $pathPill.CloseFigure()

    # Translucent dark fill
    $brushFill = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(220, 8, 22, 38))
    $g.FillPath($brushFill, $pathPill)

    # Gold/Emerald Border
    $penBorder = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(255, 0, 230, 153), [float]3)
    $g.DrawPath($penBorder, $pathPill)

    # Text
    $font1 = [System.Drawing.Font]::new("Arial", [float]32, [System.Drawing.FontStyle]::Bold)
    $font2 = [System.Drawing.Font]::new("Arial", [float]26, [System.Drawing.FontStyle]::Bold)
    $c1 = [System.Drawing.ColorTranslator]::FromHtml($colorHex1)
    $c2 = [System.Drawing.ColorTranslator]::FromHtml($colorHex2)
    $b1 = [System.Drawing.SolidBrush]::new($c1)
    $b2 = [System.Drawing.SolidBrush]::new($c2)

    $sf = [System.Drawing.StringFormat]::new()
    $sf.Alignment = [System.Drawing.StringAlignment]::Center
    $sf.LineAlignment = [System.Drawing.StringAlignment]::Center

    $g.DrawString($line1, $font1, $b1, [float]540, [float]1420, $sf)
    $g.DrawString($line2, $font2, $b2, [float]540, [float]1472, $sf)

    $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
}

$tools = "d:\AG\la garza aguachilera\herramientas"
CreateSubtitleBanner "$tools\sub1.png" "¡EL TOSTIAGUACHILE MÁS REPORTADO!" "Sabor único costeño en Tampico y Madero" "#FFFFFF" "#34D399"
CreateSubtitleBanner "$tools\sub2.png" "CAMARÓN FRESCO EN CORTE MARIPOSA" "Cebolla morada, pepino y receta clásica artesanal" "#FFFFFF" "#00E699"
CreateSubtitleBanner "$tools\sub3.png" "AUTÉNTICOS TOSTITOS SALSA VERDE" "Bien copeteados, crujientes y con mucho limón" "#FFFFFF" "#FEF08A"
CreateSubtitleBanner "$tools\sub4.png" "EL PRODUCTO ES PREPARADO FRENTE A USTED" "Para corroborar su máxima frescura ✨" "#FEF08A" "#FFFFFF"
CreateSubtitleBanner "$tools\sub5.png" "★ ¡PURA CALIDAD EN CADA BOLSA! ★" "Pide el tuyo por WhatsApp: 833 252 09 88 (`$170 MXN)" "#00E699" "#FFFFFF"

Write-Host "5 SUBTITULOS GENERADOS CON EXITO EN PNG!"

