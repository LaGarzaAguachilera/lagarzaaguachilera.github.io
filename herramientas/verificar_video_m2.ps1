# ==============================================================================
# AUDITORÍA DE VERIFICACIÓN TÉCNICA - MILESTONE M2 (VIDEO Y AUDIO SPOOKY)
# La Garza Aguachilera - Campaña Halloween & Día de Muertos
# ==============================================================================
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$baseDir = "d:\AG\la garza aguachilera"
$ffprobe = "$baseDir\herramientas\ffmpeg\ffprobe.exe"
$videoPath = "$baseDir\VIDEOS\promo_halloween_zombies_crudos.mp4"
$sabinaWav = "$baseDir\herramientas\locucion_halloween_sabina.wav"
$zombieWav = "$baseDir\herramientas\locucion_zombie_groan.wav"

Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host " AUDITORIA DE CONTROL DE CALIDAD - MILESTONE M2 (VIDEO & AUDIO)" -ForegroundColor Yellow
Write-Host "=================================================================" -ForegroundColor Cyan

$passed = 0
$total = 0

function Assert-Test([string]$desc, [bool]$cond, [string]$detail) {
    $script:total++
    if ($cond) {
        $script:passed++
        Write-Host " [PASS] $desc : $detail" -ForegroundColor Green
    } else {
        Write-Host " [FAIL] $desc : $detail" -ForegroundColor Red
    }
}

# 1. Verificación de existencia del master de video
$vExists = Test-Path $videoPath
Assert-Test "Master de video existe" $vExists $videoPath

if ($vExists) {
    $vItem = Get-Item $videoPath
    $vSizeMB = [math]::Round($vItem.Length / 1MB, 2)
    Assert-Test "Tamaño de archivo dentro del presupuesto (8 MB - 11 MB)" ($vSizeMB -ge 8.0 -and $vSizeMB -le 11.0) "$vSizeMB MB"

    # FFprobe telemetría
    $jsonRaw = & $ffprobe -v error `
                          -show_entries format=filename,duration,size,bit_rate `
                          -show_entries stream=codec_name,profile,width,height,r_frame_rate,bit_rate,sample_rate,channels `
                          -of json $videoPath
    $data = $jsonRaw | ConvertFrom-Json
    $vStream = $data.streams | Where-Object { $_.codec_name -eq 'h264' } | Select-Object -First 1
    $aStream = $data.streams | Where-Object { $_.codec_name -eq 'aac' } | Select-Object -First 1
    $format = $data.format

    $dur = [double]$format.duration
    Assert-Test "Duración requerida (18.0s a 21.0s)" ($dur -ge 18.0 -and $dur -le 21.0) "$dur s"

    Assert-Test "Resolución Full HD (1080x1920 9:16 vertical)" ($vStream.width -eq 1080 -and $vStream.height -eq 1920) "$($vStream.width)x$($vStream.height)"
    Assert-Test "Codec de video H.264 High Profile" ($vStream.codec_name -eq 'h264' -and $vStream.profile -eq 'High') "$($vStream.codec_name) ($($vStream.profile))"
    
    $vBitrate = [int]$vStream.bit_rate
    $vBitrateKbps = [math]::Round($vBitrate / 1000, 1)
    Assert-Test "Bitrate de video >= 4000 kbps" ($vBitrate -ge 4000000) "$vBitrateKbps kbps"

    Assert-Test "Codec de audio AAC estéreo (2 canales)" ($aStream.codec_name -eq 'aac' -and $aStream.channels -eq 2) "$($aStream.codec_name) ($($aStream.channels) canales)"
    Assert-Test "Frecuencia de muestreo 44,100 Hz" ($aStream.sample_rate -eq 44100) "$($aStream.sample_rate) Hz"
}

# 2. Verificación de archivos de audio master
Assert-Test "Master de locución comercial Sabina existe" (Test-Path $sabinaWav) $sabinaWav
Assert-Test "Master de gemido zombi modulado existe" (Test-Path $zombieWav) $zombieWav

# 3. Verificación de overlays gráficos GDI+
$overlays = @(
    "$baseDir\herramientas\spooky_branding_overlay.png",
    "$baseDir\herramientas\spooky_sub1.png",
    "$baseDir\herramientas\spooky_sub2.png",
    "$baseDir\herramientas\spooky_sub3.png",
    "$baseDir\herramientas\spooky_sub4.png"
)
foreach ($ov in $overlays) {
    Assert-Test "Overlay presente" (Test-Path $ov) (Split-Path $ov -Leaf)
}

# 4. Verificación de scripts del pipeline
$scripts = @(
    "$baseDir\herramientas\generar_locucion_halloween.ps1",
    "$baseDir\herramientas\generate_spooky_video_overlays.ps1",
    "$baseDir\herramientas\render_promo_halloween.ps1"
)
foreach ($sc in $scripts) {
    Assert-Test "Script de pipeline presente" (Test-Path $sc) (Split-Path $sc -Leaf)
}

Write-Host "`n=================================================================" -ForegroundColor Cyan
Write-Host " RESULTADO: $passed de $total pruebas superadas" -ForegroundColor $(if ($passed -eq $total) { "Green" } else { "Red" })
if ($passed -eq $total) {
    Write-Host " ✅ Auditado y aprobado por Control de Calidad: Cumple con los estándares de La Garza Aguachilera" -ForegroundColor Green
}
Write-Host "=================================================================" -ForegroundColor Cyan

if ($passed -ne $total) {
    exit 1
}
