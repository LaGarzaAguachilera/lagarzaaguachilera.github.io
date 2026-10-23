"""
Generador de locuciones neurales de alta definición para La Garza Aguachilera.
Utiliza Microsoft Edge TTS con la voz 'es-MX-DaliaNeural' para locución comercial humana natural,
eliminando de raíz cualquier artefacto robótico, timbre genérico o sobre-aceleración de SAPI.
Convierte la salida a 44.1 kHz, 16-bit, Estéreo PCM WAV vía FFmpeg.
"""

import asyncio
import os
import subprocess
import edge_tts

BASE_DIR = r"d:\AG\la garza aguachilera"
FFMPEG = os.path.join(BASE_DIR, "herramientas", "ffmpeg", "ffmpeg.exe")

PROMO_REGULAR_TEXT = (
    "¡Atención Tampico y Ciudad Madero! En La Garza Aguachilera ya estamos en servicio "
    "sábados y domingos. Disfruta el auténtico Tostiaguachile Verde con camarón fresco "
    "en mariposa por solo ciento setenta pesos. El producto se prepara frente a ti "
    "para corroborar su frescura. Anunciaremos las rutas de entrega en nuestras redes sociales. "
    "¡Aparta tu pedido por WhatsApp al 833 252 09 88!"
)

PROMO_HALLOWEEN_TEXT = (
    "¡No estaban muertos, solo andaban crudos! Llegó la verdadera cura de Tampico y Madero. "
    "Tostiaguachile Verde Tradicional a solo ciento setenta pesos. Sábados y domingos "
    "de una a cinco de la tarde. El producto se prepara frente a ti al momento. "
    "¡Aparta tu pedido por WhatsApp al 833 252 09 88!"
)

ZOMBIE_GROAN_TEXT = "¡Crrrruuuudaaaa...! ¡mariscoooo!"

async def generate_audio(text: str, voice: str, rate: str, pitch: str, output_mp3: str):
    communicate = edge_tts.Communicate(text, voice, rate=rate, pitch=pitch)
    await communicate.save(output_mp3)

def convert_to_wav(mp3_path: str, wav_path: str, extra_filters: str = ""):
    cmd = [
        FFMPEG,
        "-y",
        "-i", mp3_path,
        "-ar", "44100",
        "-ac", "2",
        "-c:a", "pcm_s16le"
    ]
    if extra_filters:
        cmd.extend(["-af", extra_filters])
    cmd.append(wav_path)
    subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    if os.path.exists(mp3_path):
        os.remove(mp3_path)

async def main():
    print("1. Sintetizando locución comercial regular (DaliaNeural, $170 MXN)...")
    reg_mp3 = os.path.join(BASE_DIR, "herramientas", "temp_promo_reg.mp3")
    reg_wav = os.path.join(BASE_DIR, "herramientas", "locucion_comercial_sabina.wav")
    await generate_audio(PROMO_REGULAR_TEXT, "es-MX-DaliaNeural", rate="+10%", pitch="+0Hz", output_mp3=reg_mp3)
    # Filtro cálido de broadcast: ecualización y limitador suave
    convert_to_wav(reg_mp3, reg_wav, "equalizer=f=250:width_type=h:width=150:g=2,equalizer=f=3500:width_type=h:width=1000:g=1.5,alimiter=limit=0.95")
    print(f" -> Generado: {reg_wav}")

    print("2. Sintetizando locución comercial Halloween (DaliaNeural, $170 MXN)...")
    hal_mp3 = os.path.join(BASE_DIR, "herramientas", "temp_promo_hal.mp3")
    hal_wav = os.path.join(BASE_DIR, "herramientas", "locucion_halloween_sabina.wav")
    await generate_audio(PROMO_HALLOWEEN_TEXT, "es-MX-DaliaNeural", rate="+6%", pitch="+0Hz", output_mp3=hal_mp3)
    convert_to_wav(hal_mp3, hal_wav, "equalizer=f=250:width_type=h:width=150:g=2,equalizer=f=3500:width_type=h:width=1000:g=1.5,alimiter=limit=0.95")
    print(f" -> Generado: {hal_wav}")

    print("3. Sintetizando gemido zombi modulado (JorgeNeural)...")
    zomb_mp3 = os.path.join(BASE_DIR, "herramientas", "temp_zomb.mp3")
    zomb_wav = os.path.join(BASE_DIR, "herramientas", "locucion_zombie_groan.wav")
    await generate_audio(ZOMBIE_GROAN_TEXT, "es-MX-JorgeNeural", rate="-25%", pitch="-15Hz", output_mp3=zomb_mp3)
    # Modulación de ultratumba cómica con FFmpeg
    convert_to_wav(zomb_mp3, zomb_wav, "asetrate=44100*0.75,atempo=1.35,aecho=0.8:0.88:300:0.4,lowpass=f=3200,volume=1.5,aresample=44100")
    print(f" -> Generado: {zomb_wav}")

    print("Todas las pistas vocales neurales fueron generadas con éxito y masterizadas a 44.1 kHz estéreo.")

if __name__ == "__main__":
    asyncio.run(main())
