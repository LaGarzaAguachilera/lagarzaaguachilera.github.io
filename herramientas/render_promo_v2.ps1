$ffmpeg = "d:\AG\la garza aguachilera\herramientas\ffmpeg\ffmpeg.exe"
$video = "d:\AG\la garza aguachilera\VIDEOS\aguachile video 1.mp4"
$overlay = "d:\AG\la garza aguachilera\herramientas\branding_overlay.png"
$music = "d:\AG\la garza aguachilera\herramientas\tropical_music.mp3"
$output = "d:\AG\la garza aguachilera\VIDEOS\promo_aguachile_verde_final.mp4"

$filter = @"
[0:v]crop=w=640:h=687:x=70:y=350,scale=1080:1160:flags=lanczos,eq=contrast=1.16:brightness=0.03:saturation=1.35,unsharp=luma_msize_x=7:luma_msize_y=7:luma_amount=1.2:chroma_msize_x=7:chroma_msize_y=7:chroma_amount=0.5,pad=1080:1920:0:400:black[vbase];
[vbase][1:v]overlay=0:0[vbranded];
[vbranded]
drawtext=fontfile='C\\:/Windows/Fonts/arialbd.ttf':text='TOSTIAGUACHILES EN TAMPICO Y MADERO':fontsize=34:fontcolor=white:box=1:boxcolor=black@0.75:boxborderw=12:x=(w-text_w)/2:y=1450:enable='between(t,0,5.5)',
drawtext=fontfile='C\\:/Windows/Fonts/arialbd.ttf':text='CAMARON DEL GOLFO EN CORTE MARIPOSA':fontsize=34:fontcolor=white:box=1:boxcolor=black@0.75:boxborderw=12:x=(w-text_w)/2:y=1450:enable='between(t,5.5,11.5)',
drawtext=fontfile='C\\:/Windows/Fonts/arialbd.ttf':text='AUTENTICOS TOSTITOS SALSA VERDE CRUJIENTES':fontsize=33:fontcolor=white:box=1:boxcolor=black@0.75:boxborderw=12:x=(w-text_w)/2:y=1450:enable='between(t,11.5,17.5)',
drawtext=fontfile='C\\:/Windows/Fonts/arialbd.ttf':text='PREPARADO FRENTE A TI PARA CORROBORAR FRESCURA':fontsize=31:fontcolor=yellow:box=1:boxcolor=black@0.8:boxborderw=12:x=(w-text_w)/2:y=1450:enable='between(t,17.5,23)',
drawtext=fontfile='C\\:/Windows/Fonts/arialbd.ttf':text='PURA CALIDAD! PIDE AL 833 252 09 88 ($170)':fontsize=33:fontcolor=white:box=1:boxcolor=black@0.8:boxborderw=12:x=(w-text_w)/2:y=1450:enable='between(t,23,29.04)'[vout];
[2:a]volume=0.85,afade=t=in:ss=0:d=1,afade=t=out:st=27.5:d=1.5[aout]
"@

$filterClean = ($filter -replace "`r`n", " ") -replace "`n", " "

& $ffmpeg -i $video -i $overlay -i $music -filter_complex $filterClean -map "[vout]" -map "[aout]" -c:v libx264 -preset medium -crf 16 -pix_fmt yuv420p -c:a aac -b:a 192k -movflags +faststart -t 29.04 $output -y

Write-Host "RENDER COMPLETO CON EXITO:"
Get-Item $output | Select-Object Name, Length, LastWriteTime
