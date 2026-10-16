# ==============================================================================
# PIPELINE DE RENDERIZADO SPOOKY FULL HD 1080x1920 (9:16)
# La Garza Aguachilera - Campaña Halloween & Día de Muertos
# Videoclip: "La Resurrección de la Cruda" (20.0s, H.264 High Profile, >= 4000 kbps)
# ==============================================================================
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$baseDir = "d:\AG\la garza aguachilera"
$ffmpeg  = "$baseDir\herramientas\ffmpeg\ffmpeg.exe"
$ffprobe = "$baseDir\herramientas\ffmpeg\ffprobe.exe"

$img1    = "$baseDir\tampico_skyline_bg.jpg"
$img2    = "$baseDir\tostiaguachile_verde_redondo.jpg"
$video   = "$baseDir\VIDEOS\aguachile video 1.mp4"
$img4    = "$baseDir\aguachile_verde_hero.jpg"

$overlay = "$baseDir\herramientas\spooky_branding_overlay.png"
$sub1    = "$baseDir\herramientas\spooky_sub1.png"
$sub2    = "$baseDir\herramientas\spooky_sub2.png"
$sub3    = "$baseDir\herramientas\spooky_sub3.png"
$sub4    = "$baseDir\herramientas\spooky_sub4.png"

$music   = "$baseDir\herramientas\Beachfront_Celebration.mp3"
$voice   = "$baseDir\herramientas\locucion_halloween_sabina.wav"
$zombie  = "$baseDir\herramientas\locucion_zombie_groan.wav"

$output  = "$baseDir\VIDEOS\promo_halloween_zombies_crudos.mp4"

Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host " INICIANDO PIPELINE DE RENDERIZADO SPOOKY FULL HD 1080x1920" -ForegroundColor Yellow
Write-Host " Master: VIDEOS\promo_halloween_zombies_crudos.mp4" -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan

# 1. Verificación estricta de insumos
$requiredInputs = @(
    $ffmpeg, $ffprobe, $img1, $img2, $video, $img4,
    $overlay, $sub1, $sub2, $sub3, $sub4,
    $music, $voice, $zombie
)

foreach ($item in $requiredInputs) {
    if (-not (Test-Path $item)) {
        Write-Error "Falta insumo crítico para renderizado: $item"
        exit 1
    }
}
Write-Host "Todos los insumos multimedia fueron validados exitosamente." -ForegroundColor Green

# 2. Filtergraph Cinematográfico de 20.0 segundos exactos (600 cuadros a 30.0 fps)
# - Acto 1 (0.0s - 3.5s, 105 f): Suspenso Cósmico nocturno con niebla y gemido zombi
# - Acto 2 (3.5s - 7.5s, 120 f): Estímulo del aroma sagrado, hielera a 2°C y Tostitos
# - Acto 3 (7.5s - 11.5s, 120 f): Clímax del Crunch hero shot camarón mariposa en tenedor
# - Acto 4 (11.5s - 20.0s, 255 f): Gran Remate de Franquicia, datos comerciales y WhatsApp
# - Audio: Mist drone + comic zombie groan + crunch ASMR + Beachfront Celebration ducked a 0.18 + Sabina SAPI
$filterGraph = @"
[0:v]scale=w=1440:h=2560:force_original_aspect_ratio=increase,crop=1440:2560,zoompan=z='min(zoom+0.0006,1.12)':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=105:s=1080x1920:fps=30,eq=contrast=1.15:brightness=-0.08:saturation=0.85,unsharp=5:5:0.8,setsar=1[sc1];
[1:v]scale=w=1440:h=2560:force_original_aspect_ratio=increase,crop=1440:2560,zoompan=z='1.14':x='(iw-iw/zoom)*(on/120)':y='ih*0.52-(ih/zoom/2)':d=120:s=1080x1920:fps=30,eq=contrast=1.12:brightness=0.02:saturation=1.25,unsharp=5:5:0.8,setsar=1[sc2];
[2:v]trim=start=23.0:end=27.0,setpts=PTS-STARTPTS,crop=w=640:h=1138:x=40:y=100,scale=1080:1920:flags=lanczos,eq=contrast=1.14:brightness=0.03:saturation=1.35,unsharp=5:5:1.0,setsar=1[sc3];
[3:v]scale=w=1500:h=2666:force_original_aspect_ratio=increase,crop=1500:2666,zoompan=z='1.16-0.0005*on':x='iw/2-(iw/zoom/2)':y='ih*0.46-(ih/zoom/2)':d=255:s=1080x1920:fps=30,eq=contrast=1.12:brightness=0.02:saturation=1.25,unsharp=5:5:0.8,setsar=1[sc4];
[sc1][sc2][sc3][sc4]concat=n=4:v=1:a=0[vbase];
[vbase][4:v]overlay=0:0[vb];
[vb][5:v]overlay=0:0:enable='between(t,0,3.5)'[vsub1];
[vsub1][6:v]overlay=0:0:enable='between(t,3.5,7.5)'[vsub2];
[vsub2][7:v]overlay=0:0:enable='between(t,7.5,11.5)'[vsub3];
[vsub3][8:v]overlay=0:0:enable='between(t,11.5,20.0)'[vfinal];
sine=f=55:r=44100:d=3.8,aformat=channel_layouts=stereo,afade=t=out:st=3.2:d=0.6,volume=0.30[asine];
anoisesrc=d=3.8:c=white:r=44100,aformat=channel_layouts=stereo,lowpass=f=260,afade=t=out:st=3.0:d=0.8,volume=0.20[anoise];
anoisesrc=d=0.35:c=white:r=44100,aformat=channel_layouts=stereo,highpass=f=2000,lowpass=f=7500,volume=2.2,adelay=3300|3300[acrunch];
[9:a]atrim=start=0:end=20.0,asetpts=PTS-STARTPTS,volume='if(lt(t,3.5),0.0,if(lt(t,3.8),0.85,if(lt(t,19.6),0.18,0.80)))':eval=frame,afade=t=in:st=3.5:d=0.3,afade=t=out:st=19.2:d=0.8[amusic];
[10:a]adelay=3500|3500,volume=1.20[asabina];
[11:a]adelay=400|400,volume=1.4[azombie];
[amusic][asine][anoise][azombie][acrunch][asabina]amix=inputs=6:duration=first:weights=1.0 1.0 1.0 1.0 1.0 1.0:normalize=0[aout]
"@

$cleanFilter = ($filterGraph -replace "`r`n", " ") -replace "`n", " "

Write-Host "Ejecutando codificación de video con FFmpeg Gyan Full Build..." -ForegroundColor Yellow
$sw = [System.Diagnostics.Stopwatch]::StartNew()

& $ffmpeg -i $img1 `
          -i $img2 `
          -i $video `
          -i $img4 `
          -i $overlay `
          -i $sub1 `
          -i $sub2 `
          -i $sub3 `
          -i $sub4 `
          -i $music `
          -i $voice `
          -i $zombie `
          -filter_complex $cleanFilter `
          -map "[vfinal]" `
          -map "[aout]" `
          -r 30 `
          -c:v libx264 `
          -profile:v high `
          -level 4.2 `
          -preset medium `
          -b:v 5200k `
          -minrate 4400k `
          -maxrate 6000k `
          -bufsize 9000k `
          -pix_fmt yuv420p `
          -c:a aac `
          -b:a 256k `
          -ar 44100 `
          -ac 2 `
          -t 20.0 `
          -movflags +faststart `
          $output `
          -y

$sw.Stop()

if (-not (Test-Path $output)) {
    Write-Error "Fallo la generación del video: $output"
    exit 1
}

$fileItem = Get-Item $output
$fileMB = [math]::Round($fileItem.Length / 1MB, 2)

Write-Host "`n=================================================================" -ForegroundColor Green
Write-Host " RENDERIZADO COMPLETADO EN $($sw.Elapsed.TotalSeconds.ToString('F2')) SEGUNDOS" -ForegroundColor Green
Write-Host " Archivo generado: $output ($fileMB MB)" -ForegroundColor Green
Write-Host "=================================================================" -ForegroundColor Green

# 3. Telemetría y Validación Técnica con FFprobe
Write-Host "`nTELEMETRÍA Y METADATOS TÉCNICOS OFICIALES (FFPROBE):" -ForegroundColor Cyan
& $ffprobe -v error `
           -show_entries format=filename,duration,size,bit_rate `
           -show_entries stream=codec_name,profile,width,height,r_frame_rate,bit_rate,sample_rate,channels `
           -of json $output
