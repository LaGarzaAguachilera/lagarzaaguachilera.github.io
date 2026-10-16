# ==============================================================================
# PIPELINE DE RENDERIZADO HD 1080x1920 (9:16) - LA GARZA AGUACHILERA
# Video Promocional Oficial para Redes Sociales (TikTok / Instagram Stories)
# Especificaciones: 1080x1920, H.264 High Profile, >= 4000 kbps, AAC Stereo
# ==============================================================================
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$baseDir = "d:\AG\la garza aguachilera"
$ffmpeg = "$baseDir\herramientas\ffmpeg\ffmpeg.exe"
$ffprobe = "$baseDir\herramientas\ffmpeg\ffprobe.exe"

$img1    = "$baseDir\tostiaguachile_verde_redondo.jpg"
$img2    = "$baseDir\aguachile_verde_hero.jpg"
$video   = "$baseDir\VIDEOS\aguachile video 1.mp4"

$overlay = "$baseDir\herramientas\branding_pop_overlay.png"
$sub1    = "$baseDir\herramientas\pop_sub1.png"
$sub2    = "$baseDir\herramientas\pop_sub2.png"
$sub3    = "$baseDir\herramientas\pop_sub3.png"
$sub4    = "$baseDir\herramientas\pop_sub4.png"
$sub5    = "$baseDir\herramientas\pop_sub5.png"

$music   = "$baseDir\herramientas\Beachfront_Celebration.mp3"
$voice   = "$baseDir\herramientas\locucion_comercial_sabina.wav"

$output  = "$baseDir\VIDEOS\promo_aguachile_verde_final.mp4"

Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host " INICIANDO PIPELINE DE RENDERIZADO FULL HD 1080x1920 (FRANQUICIA)" -ForegroundColor Yellow
Write-Host "=================================================================" -ForegroundColor Cyan

# 1. Verificación de archivos requeridos
$requiredFiles = @(
    $ffmpeg, $ffprobe, $img1, $img2, $video,
    $overlay, $sub1, $sub2, $sub3, $sub4, $sub5,
    $music, $voice
)

foreach ($f in $requiredFiles) {
    if (-not (Test-Path $f)) {
        Write-Error "Archivo requerido no encontrado: $f"
        exit 1
    }
}
Write-Host "Todos los activos de entrada fueron verificados correctamente." -ForegroundColor Green

# 2. Construcción del Filtergraph Cinematográfico
# - Escena 1 (0.0s - 5.5s): Ken Burns zoom en fotografía de alta definición de Tostiaguachile Verde
# - Escena 2 (5.5s - 11.5s): Ken Burns macro glide en camarones mariposa y caldo serrano
# - Escena 3 (11.5s - 17.5s): Video en vivo de preparación artesanal en sartén
# - Escena 4 (17.5s - 23.0s): Video en vivo de salseo y garantía de frescura
# - Escena 5 (23.0s - 29.04s): Hero Shot clímax levantando el camarón con tenedor
# - Audio Ducking: Beachfront Celebration ducked a 0.18 (-15dB) durante voz, swell a 0.80 intro/outro
$filterGraph = @"
[0:v]split=3[img0a][img0b][img0c];
[1:v]split=2[img1a][img1b];
[img0a]scale=w=1440:h=2560:force_original_aspect_ratio=increase,crop=1440:2560,zoompan=z='min(zoom+0.0008,1.15)':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=165:s=1080x1920:fps=30,eq=contrast=1.08:saturation=1.20:brightness=0.02,unsharp=luma_msize_x=5:luma_msize_y=5:luma_amount=0.8,setsar=1[sc1];
[img1a]scale=w=1440:h=2560:force_original_aspect_ratio=increase,crop=1440:2560,zoompan=z='min(zoom+0.0007,1.14)':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=180:s=1080x1920:fps=30,eq=contrast=1.10:saturation=1.25:brightness=0.02,unsharp=luma_msize_x=5:luma_msize_y=5:luma_amount=0.8,setsar=1[sc2];
[img0b]scale=w=1600:h=2844:force_original_aspect_ratio=increase,crop=1600:2844,zoompan=z='1.18':x='(iw-iw/zoom)*(on/180)':y='ih*0.58-(ih/zoom/2)':d=180:s=1080x1920:fps=30,eq=contrast=1.10:saturation=1.24:brightness=0.02,unsharp=luma_msize_x=5:luma_msize_y=5:luma_amount=0.8,setsar=1[sc3];
[img1b]scale=w=1600:h=2844:force_original_aspect_ratio=increase,crop=1600:2844,zoompan=z='1.20-0.0006*on':x='iw/2-(iw/zoom/2)':y='ih*0.42-(ih/zoom/2)':d=165:s=1080x1920:fps=30,eq=contrast=1.12:saturation=1.26:brightness=0.02,unsharp=luma_msize_x=5:luma_msize_y=5:luma_amount=0.8,setsar=1[sc4];
[img0c]scale=w=1500:h=2666:force_original_aspect_ratio=increase,crop=1500:2666,zoompan=z='1.16-0.0007*on':x='iw/2-(iw/zoom/2)':y='ih*0.48-(ih/zoom/2)':d=182:s=1080x1920:fps=30,eq=contrast=1.10:saturation=1.22:brightness=0.02,unsharp=luma_msize_x=5:luma_msize_y=5:luma_amount=0.8,setsar=1[sc5];
[sc1][sc2][sc3][sc4][sc5]concat=n=5:v=1:a=0[vbase];
[vbase][3:v]overlay=0:0[vb];
[vb][4:v]overlay=0:0:enable='between(t,0,5.5)'[vsub1];
[vsub1][5:v]overlay=0:0:enable='between(t,5.5,11.5)'[vsub2];
[vsub2][6:v]overlay=0:0:enable='between(t,11.5,17.5)'[vsub3];
[vsub3][7:v]overlay=0:0:enable='between(t,17.5,23.0)'[vsub4];
[vsub4][8:v]overlay=0:0:enable='between(t,23.0,29.04)'[vfinal];
[9:a]volume='if(lt(t,1.0),0.80,if(lt(t,1.3),0.80-(0.80-0.18)*(t-1.0)/0.3,if(lt(t,27.4),0.18,if(lt(t,27.8),0.18+(0.80-0.18)*(t-27.4)/0.4,0.80))))':eval=frame,afade=t=in:ss=0:d=0.5,afade=t=out:st=28.0:d=1.04[amusic];
[10:a]adelay=1000|1000,volume=1.15[avocal];
[amusic][avocal]amix=inputs=2:duration=first:weights=1.0 1.0:normalize=0[aout]
"@

$cleanFilter = ($filterGraph -replace "`r`n", " ") -replace "`n", " "

Write-Host "Ejecutando renderizado FFmpeg..." -ForegroundColor Yellow
$sw = [System.Diagnostics.Stopwatch]::StartNew()

# Nota técnica fundamental: $img1 y $img2 se leen SIN '-loop 1' para que zoompan genere exactamente sus 'd' cuadros y concat proceda a las siguientes escenas
& $ffmpeg -i $img1 `
          -i $img2 `
          -i $video `
          -i $overlay `
          -i $sub1 `
          -i $sub2 `
          -i $sub3 `
          -i $sub4 `
          -i $sub5 `
          -i $music `
          -i $voice `
          -filter_complex $cleanFilter `
          -map "[vfinal]" `
          -map "[aout]" `
          -c:v libx264 `
          -profile:v high `
          -level 4.2 `
          -preset medium `
          -b:v 6000k `
          -minrate 4000k `
          -maxrate 9000k `
          -bufsize 12000k `
          -pix_fmt yuv420p `
          -c:a aac `
          -b:a 256k `
          -ar 44100 `
          -ac 2 `
          -t 29.04 `
          -movflags +faststart `
          $output `
          -y

$sw.Stop()

if (-not (Test-Path $output)) {
    Write-Error "El renderizado fallo. No se creo el archivo $output"
    exit 1
}

Write-Host "`n=================================================================" -ForegroundColor Green
Write-Host " RENDERIZADO COMPLETADO EN $($sw.Elapsed.TotalSeconds.ToString('F2')) SEGUNDOS" -ForegroundColor Green
Write-Host "=================================================================" -ForegroundColor Green

# 3. Telemetría y Validación Técnica con FFprobe
Write-Host "`nMETADATOS TECNICOS DEL MASTER DE VIDEO:" -ForegroundColor Cyan
& $ffprobe -v error `
           -show_entries format=filename,duration,size,bit_rate `
           -show_entries stream=codec_name,profile,width,height,r_frame_rate,bit_rate,sample_rate,channels `
           -of json $output
