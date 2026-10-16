Add-Type -AssemblyName System.Drawing

$src = [System.Drawing.Bitmap]::FromFile("d:\AG\la garza aguachilera\tostiaguachile_verde_redondo.jpg")
Write-Host "Width: $($src.Width), Height: $($src.Height)"

# Bag outline points approximation
# Left tip: (130, 470)
# Top left edge: (180, 370), (280, 290), (370, 230), (510, 200)
# Top edge: (620, 240), (740, 280), (840, 310)
# Top right tip: (1120, 480)
# Right edge: (990, 600), (880, 710)
# Bottom edge: (680, 810), (520, 800), (340, 770), (180, 680)
$src.Dispose()
