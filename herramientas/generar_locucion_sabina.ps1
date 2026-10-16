# ==============================================================================
# GENERADOR DE LOCUCION COMERCIAL SAPI: LA GARZA AGUACHILERA
# Voz: Microsoft Sabina Desktop (es-MX) - 44.1 kHz, 16-bit, Stereo PCM
# ==============================================================================
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$targetWav = "d:\AG\la garza aguachilera\herramientas\locucion_comercial_sabina.wav"
$ffprobe = "d:\AG\la garza aguachilera\herramientas\ffmpeg\ffprobe.exe"

Write-Host "Inicializando síntesis de voz con Microsoft Sabina Desktop..." -ForegroundColor Cyan

Add-Type -AssemblyName System.Speech

$synth = New-Object System.Speech.Synthesis.SpeechSynthesizer

# Verificar si la voz Sabina está instalada
$voice = $synth.GetInstalledVoices() | Where-Object { $_.VoiceInfo.Name -like "*Sabina*" } | Select-Object -First 1

if (-not $voice) {
    Write-Error "No se encontró la voz 'Microsoft Sabina Desktop'. Voces disponibles:"
    $synth.GetInstalledVoices() | ForEach-Object { Write-Host " - $($_.VoiceInfo.Name) ($($_.VoiceInfo.Culture.Name))" }
    exit 1
}

$synth.SelectVoice($voice.VoiceInfo.Name)
$synth.Rate = 1        # Ritmo comercial dinámico y natural
$synth.Volume = 100    # Volumen óptimo al 100%

# Formato de broadcast profesional: 44.1 kHz, 16-bit, Estéreo PCM
$audioFormat = New-Object System.Speech.AudioFormat.SpeechAudioFormatInfo(
    44100,
    [System.Speech.AudioFormat.AudioBitsPerSample]::Sixteen,
    [System.Speech.AudioFormat.AudioChannel]::Stereo
)

$synth.SetOutputToWaveFile($targetWav, $audioFormat)

# Guion comercial oficial autorizado
$copyScript = @"
¡Atención Tampico y Ciudad Madero! En La Garza Aguachilera ya estamos en servicio sábados y domingos. Disfruta el auténtico Tostiaguachile Verde con camarón fresco en mariposa por solo ciento setenta pesos. El producto se prepara frente a ti para corroborar su frescura. Anunciaremos las rutas de entrega en nuestras redes sociales. ¡Aparta tu pedido por WhatsApp al 833 252 09 88!
"@

Write-Host "Sintetizando locución comercial..." -ForegroundColor Yellow
$synth.Speak($copyScript.Trim())
$synth.SetOutputToNull()
$synth.Dispose()

Write-Host "Locución generada exitosamente en: $targetWav" -ForegroundColor Green

if (Test-Path $ffprobe) {
    Write-Host "`nMetadatos de la locución generada:" -ForegroundColor Cyan
    & $ffprobe -v error -show_entries format=duration,size,bit_rate -show_entries stream=codec_name,sample_rate,channels -of default=noprint_wrappers=1 $targetWav
} else {
    Get-Item $targetWav | Select-Object Name, Length, LastWriteTime
}
