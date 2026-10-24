# ==============================================================================
# GENERADOR DE LOCUCIÓN Y SFX SPOOKY: LA GARZA AGUACHILERA
# Campaña: Halloween y Día de Muertos - "La Resurrección de la Cruda"
# Voz: Microsoft Sabina Desktop (es-MX) - 44.1 kHz, 16-bit, Stereo PCM
# ==============================================================================
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$baseDir = "d:\AG\la garza aguachilera"
$targetWav = "$baseDir\herramientas\locucion_halloween_sabina.wav"
$zombieRawWav = "$baseDir\herramientas\locucion_zombie_groan_raw.wav"
$zombieWav = "$baseDir\herramientas\locucion_zombie_groan.wav"
$ffmpeg = "$baseDir\herramientas\ffmpeg\ffmpeg.exe"
$ffprobe = "$baseDir\herramientas\ffmpeg\ffprobe.exe"

Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host " GENERANDO LOCUCION Y SFX VOCAL DE TEMPORADA SPOOKY (SAPI + FFMPEG)" -ForegroundColor Yellow
Write-Host "=================================================================" -ForegroundColor Cyan

Add-Type -AssemblyName System.Speech

$synth = New-Object System.Speech.Synthesis.SpeechSynthesizer
$voice = $synth.GetInstalledVoices() | Where-Object { $_.VoiceInfo.Name -like "*Sabina*" } | Select-Object -First 1

if (-not $voice) {
    Write-Error "No se encontro la voz 'Microsoft Sabina Desktop'."
    exit 1
}

$synth.SelectVoice($voice.VoiceInfo.Name)
$synth.Volume = 100

$audioFormat = New-Object System.Speech.AudioFormat.SpeechAudioFormatInfo(
    44100,
    [System.Speech.AudioFormat.AudioBitsPerSample]::Sixteen,
    [System.Speech.AudioFormat.AudioChannel]::Stereo
)

# 1. Master de Locución Comercial Sabina (Rate = 6 para ritmo radial ágil y dinámico en video vertical de 20s)
$synth.Rate = 6
$synth.SetOutputToWaveFile($targetWav, $audioFormat)

$copyScript = "¡No estaban muertos... solo estaban crudos! La verdadera cura de Tampico y Madero. Disfruta el auténtico Tostiaguachile Verde Tradicional con camarón fresco en mariposa por solo ciento setenta pesos. El producto se prepara frente a ti para corroborar su frescura. ¡Aparta tu pedido por WhatsApp al 833 252 09 88!"

Write-Host "Sintetizando locucion comercial oficial..." -ForegroundColor Yellow
$synth.Speak($copyScript.Trim())
$synth.SetOutputToNull()

# 2. Gemido Zombi Cómico
$synth.Rate = 1
$synth.SetOutputToWaveFile($zombieRawWav, $audioFormat)

Write-Host "Sintetizando gemido zombi comico base..." -ForegroundColor Yellow
$synth.Speak("Crrrruuuudaaaa... ¡mariscoooo!")
$synth.SetOutputToNull()
$synth.Dispose()

# 3. Modulación de Gemido Zombi con FFmpeg (Pitch shift gutural + Reverb tumba + Compresión)
Write-Host "Modulando gemido zombi con FFmpeg (efecto ultratumba comico)..." -ForegroundColor Yellow
& $ffmpeg -i $zombieRawWav `
          -af "asetrate=44100*0.75,atempo=1.35,aecho=0.8:0.88:300:0.4,lowpass=f=3200,volume=1.5,aresample=44100" `
          -y $zombieWav `
          -loglevel error

if (Test-Path $zombieRawWav) {
    Remove-Item -Force $zombieRawWav
}

Write-Host "`nArchivos de audio generados exitosamente:" -ForegroundColor Green

Write-Host "`n1. Locucion Sabina ($targetWav):" -ForegroundColor Cyan
& $ffprobe -v error -show_entries format=duration,size,bit_rate -show_entries stream=codec_name,sample_rate,channels -of default=noprint_wrappers=1 $targetWav

Write-Host "`n2. Gemido Zombi Modulado ($zombieWav):" -ForegroundColor Cyan
& $ffprobe -v error -show_entries format=duration,size,bit_rate -show_entries stream=codec_name,sample_rate,channels -of default=noprint_wrappers=1 $zombieWav
