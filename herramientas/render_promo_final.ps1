$ffmpeg = "D:\AG\la garza aguachilera\herramientas\ffmpeg\ffmpeg.exe"
$video = "d:\AG\la garza aguachilera\VIDEOS\aguachile video 1.mp4"
$overlay = "d:\AG\la garza aguachilera\herramientas\branding_pop_overlay.png"
$music = "d:\AG\la garza aguachilera\herramientas\Beachfront_Celebration.mp3"
$tools = "d:\AG\la garza aguachilera\herramientas"
$sub1 = "$tools\pop_sub1.png"
$sub2 = "$tools\pop_sub2.png"
$sub3 = "$tools\pop_sub3.png"
$sub4 = "$tools\pop_sub4.png"
$sub5 = "$tools\pop_sub5.png"
$output = "d:\AG\la garza aguachilera\VIDEOS\promo_aguachile_verde_final.mp4"

$filter = @"
[0:v]crop=w=640:h=663:x=70:y=350,scale=1080:1120:flags=lanczos,eq=contrast=1.16:brightness=0.03:saturation=1.35,unsharp=luma_msize_x=7:luma_msize_y=7:luma_amount=1.2:chroma_amount=0.5,pad=1080:1920:0:420:black[vbase];
[vbase][1:v]overlay=0:0[vb];
[vb][3:v]overlay=0:0:enable='between(t,0,5.5)'[vsub1];
[vsub1][4:v]overlay=0:0:enable='between(t,5.5,11.5)'[vsub2];
[vsub2][5:v]overlay=0:0:enable='between(t,11.5,17.5)'[vsub3];
[vsub3][6:v]overlay=0:0:enable='between(t,17.5,23.0)'[vsub4];
[vsub4][7:v]overlay=0:0:enable='between(t,23.0,29.04)'[vfinal];
[2:a]volume=0.88,afade=t=in:ss=0:d=0.8,afade=t=out:st=27.5:d=1.5[aout]
"@

$filterClean = ($filter -replace "`r`n", " ") -replace "`n", " "

Write-Host "Iniciando renderizacion de Video Pop de Alto Impacto con Juancho, Ovni, Mapache y Beachfront Celebration..."

& $ffmpeg -i $video -i $overlay -i $music -i $sub1 -i $sub2 -i $sub3 -i $sub4 -i $sub5 -filter_complex $filterClean -map "[vfinal]" -map "[aout]" -c:v libx264 -preset medium -crf 16 -pix_fmt yuv420p -c:a aac -b:a 192k -movflags +faststart -t 29.04 $output -y

Write-Host "RENDER COMPLETO CON EXITO!"
Get-Item $output | Select-Object Name, Length, LastWriteTime
