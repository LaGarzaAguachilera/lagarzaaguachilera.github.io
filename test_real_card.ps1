Add-Type -AssemblyName System.Drawing

$src = [System.Drawing.Image]::FromFile("d:\AG\la garza aguachilera\tostiaguachile_verde_redondo.jpg")
$bmpCard = [System.Drawing.Bitmap]::new(440, 360, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($bmpCard)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

# White rounded sticker frame
$path = [System.Drawing.Drawing2D.GraphicsPath]::new()
$rect = [System.Drawing.RectangleF]::new(10, 10, 420, 340)
$d = 40.0
$path.AddArc($rect.X, $rect.Y, $d, $d, 180, 90)
$path.AddArc($rect.Right - $d, $rect.Y, $d, $d, 270, 90)
$path.AddArc($rect.Right - $d, $rect.Bottom - $d, $d, $d, 0, 90)
$path.AddArc($rect.X, $rect.Bottom - $d, $d, $d, 90, 90)
$path.CloseFigure()

$g.SetClip($path)
# Draw cropped portion focusing on the open bag with shrimp and tostitos
$g.DrawImage($src, [System.Drawing.Rectangle]::new(-80, -60, 580, 440))
$g.ResetClip()

$penBorder = [System.Drawing.Pen]::new([System.Drawing.Color]::White, 12)
$g.DrawPath($penBorder, $path)

$penOuter = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(16, 185, 129), 4)
$g.DrawPath($penOuter, $path)

$bmpCard.Save("d:\AG\la garza aguachilera\card_real_food.png", [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$bmpCard.Dispose()
$src.Dispose()
Write-Host "Card real food created!"
