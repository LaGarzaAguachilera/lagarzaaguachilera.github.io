# ==============================================================================
# VERIFICACIÓN INTEGRAL DE ACTIVOS M1 - DISEÑADOR GRÁFICO SENIOR
# ==============================================================================

Add-Type -AssemblyName System.Drawing
$root = "d:\AG\la garza aguachilera"

Write-Host "=============================================================" -ForegroundColor Cyan
Write-Host "   AUDITORIA DE CONTROL DE CALIDAD Y ACTIVOS GRAFICOS M1" -ForegroundColor Yellow
Write-Host "=============================================================" -ForegroundColor Cyan

$totalTests = 0
$passedTests = 0

# 1. VERIFICACIÓN DE STICKERS TRANSPARENTES
Write-Host "`n1. STICKERS TRANSPARENTES (1024x1024 px, Format32bppArgb, Alpha 0 en esquinas):" -ForegroundColor Cyan
$stickers = @(
    "sticker_spooky_juancho_jason.png",
    "sticker_spooky_mapache_freddy.png",
    "sticker_spooky_ovni_muertos.png"
)

foreach ($s in $stickers) {
    $totalTests++
    $p = Join-Path $root $s
    if (Test-Path $p) {
        $bmp = [System.Drawing.Bitmap]::FromFile($p)
        $w = $bmp.Width
        $h = $bmp.Height
        $fmt = $bmp.PixelFormat.ToString()
        $cornerA = $bmp.GetPixel(0, 0).A
        $centerA = $bmp.GetPixel(512, 512).A
        $bmp.Dispose()

        $isOk = ($w -eq 1024 -and $h -eq 1024 -and $fmt -eq "Format32bppArgb" -and $cornerA -eq 0 -and $centerA -gt 0)
        if ($isOk) {
            $passedTests++
            Write-Host " [PASS] $s : ${w}x${h} | $fmt | Esquina Alpha=$cornerA | Centro Alpha=$centerA" -ForegroundColor Green
        } else {
            Write-Host " [FAIL] $s : ${w}x${h} | $fmt | Esquina Alpha=$cornerA | Centro Alpha=$centerA" -ForegroundColor Red
        }
    } else {
        Write-Host " [FAIL] Archivo ausente: $s" -ForegroundColor Red
    }
}

# 2. VERIFICACIÓN DE POSTERS FEED (1080x1080) Y STORY (1080x1920)
Write-Host "`n2. POSTERS FEED Y STORY EN posts_periodicos:" -ForegroundColor Cyan
$posts = @(
    @{ Name = "Arte 1 Feed";  File = "spooky_post01_juancho_resurreccion.png";       W = 1080; H = 1080 },
    @{ Name = "Arte 1 Story"; File = "spooky_post01_juancho_resurreccion_story.png"; W = 1080; H = 1920 },
    @{ Name = "Arte 2 Feed";  File = "spooky_post02_mapache_freddy_crunch.png";      W = 1080; H = 1080 },
    @{ Name = "Arte 2 Story"; File = "spooky_post02_mapache_freddy_crunch_story.png"; W = 1080; H = 1920 },
    @{ Name = "Arte 3 Feed";  File = "spooky_post03_ovni_ultratumba.png";            W = 1080; H = 1080 },
    @{ Name = "Arte 3 Story"; File = "spooky_post03_ovni_ultratumba_story.png";      W = 1080; H = 1920 },
    @{ Name = "Arte 4 Feed";  File = "spooky_post04_tridente_spooky_pack.png";       W = 1080; H = 1080 },
    @{ Name = "Arte 4 Story"; File = "spooky_post04_tridente_spooky_pack_story.png"; W = 1080; H = 1920 }
)

foreach ($item in $posts) {
    $totalTests++
    $p = Join-Path $root ("contenido_redes\posts_periodicos\" + $item.File)
    if (Test-Path $p) {
        $img = [System.Drawing.Image]::FromFile($p)
        $w = $img.Width
        $h = $img.Height
        $fmt = $img.PixelFormat.ToString()
        $img.Dispose()
        $kb = [math]::Round((Get-Item $p).Length / 1KB, 1)

        $isOk = ($w -eq $item.W -and $h -eq $item.H -and $fmt -eq "Format32bppArgb")
        if ($isOk) {
            $passedTests++
            Write-Host " [PASS] $($item.Name) ($($item.File)): ${w}x${h} | $fmt | ${kb} KB" -ForegroundColor Green
        } else {
            Write-Host " [FAIL] $($item.Name) ($($item.File)): ${w}x${h} (Esperado $($item.W)x$($item.H))" -ForegroundColor Red
        }
    } else {
        Write-Host " [FAIL] Falta archivo: $($item.File)" -ForegroundColor Red
    }
}

# 3. VERIFICACIÓN DE ESPEJO EN catalogo_mes\spooky
Write-Host "`n3. ESPEJO COMPLETO EN catalogo_mes\spooky:" -ForegroundColor Cyan
$spookyDir = Join-Path $root "contenido_redes\catalogo_mes\spooky"
$filesInSpooky = Get-ChildItem -Path $spookyDir
Write-Host " Total de archivos listos para empaque: $($filesInSpooky.Count)" -ForegroundColor Green
foreach ($f in $filesInSpooky) {
    Write-Host "   - $($f.Name) ($([math]::Round($f.Length/1KB, 1)) KB)" -ForegroundColor Gray
}

# 4. RESUMEN DE APROBACIÓN
Write-Host "`n=============================================================" -ForegroundColor Cyan
if ($totalTests -eq $passedTests) {
    Write-Host "  RESULTADO: 100% CONFORME ($passedTests de $totalTests pruebas superadas)" -ForegroundColor Green
    Write-Host "  ✅ Auditado y aprobado por Control de Calidad: Cumple con los estándares de La Garza Aguachilera" -ForegroundColor Green
} else {
    Write-Host "  RESULTADO: INCONFORME ($passedTests de $totalTests superadas)" -ForegroundColor Red
}
Write-Host "=============================================================" -ForegroundColor Cyan
