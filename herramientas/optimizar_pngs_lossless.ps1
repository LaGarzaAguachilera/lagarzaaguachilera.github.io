# ==============================================================================
# OPTIMIZADOR LOSSLESS DE IMÁGENES PNG - LA GARZA AGUACHILERA
# Archivo: herramientas\optimizar_pngs_lossless.ps1
# Optimiza la compresión DEFLATE (Level 9 + Mixed Filtering) vía FFmpeg
# Conserva el 100% de la calidad visual, píxeles exactos y transparencia alfa
# ==============================================================================
$rootDir = "d:\AG\la garza aguachilera"
$ffmpeg = "$rootDir\herramientas\ffmpeg\ffmpeg.exe"

$folders = @(
    "$rootDir\contenido_redes\catalogo_mes\semana1",
    "$rootDir\contenido_redes\catalogo_mes\semana2",
    "$rootDir\contenido_redes\catalogo_mes\semana3",
    "$rootDir\contenido_redes\catalogo_mes\semana4",
    "$rootDir\contenido_redes\catalogo_mes\spooky",
    "$rootDir\contenido_redes\posts_periodicos"
)

$totalSaved = 0
$count = 0

Write-Host "Iniciando optimización lossless de PNGs..." -ForegroundColor Cyan

foreach ($dir in $folders) {
    if (-not (Test-Path $dir)) { continue }
    $pngs = Get-ChildItem -Path $dir -Filter "*.png"
    foreach ($file in $pngs) {
        $srcPath = $file.FullName
        $tempPath = "$($file.FullName).tmp.png"
        $origSize = $file.Length

        # Optimización con FFmpeg: compression_level 9 y predicción mixta
        & $ffmpeg -v error -i $srcPath -c:v png -compression_level 9 -pred mixed -y $tempPath

        if (Test-Path $tempPath) {
            $newSize = (Get-Item $tempPath).Length
            if ($newSize -lt $origSize) {
                $saved = $origSize - $newSize
                $totalSaved += $saved
                $count++
                Move-Item -LiteralPath $tempPath -Destination $srcPath -Force
                Write-Host " [OK] $($file.Name): -$([math]::Round($saved / 1KB, 1)) KB" -ForegroundColor Green
            } else {
                Remove-Item -LiteralPath $tempPath -Force
            }
        }
    }
}

$savedMB = [math]::Round($totalSaved / 1MB, 2)
Write-Host "`nOptimización completada: $count archivos optimizados, $savedMB MB ahorrados." -ForegroundColor Cyan
