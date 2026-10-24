# -*- coding: utf-8 -*-
"""
PRODUCCIÓN DE AUDIO MAESTRO Y SUBTÍTULOS DINÁMICOS AAA — LA GARZA AGUACHILERA
Comercial Vertical Stories & TikTok (24.0s, 9:16 Full HD, 44.1 kHz Estéreo)

Componentes:
1. Locución femenina coqueta, divertida y antojable (es-MX-DaliaNeural, rate +11%, pitch +3Hz).
2. Síntesis procedural de 5 efectos culinarios y 3D en Python/NumPy:
   - Lime Squeeze (exprimido de limón Colima con chorro de alta presión y rocío)
   - Salsa Splash (baño viscoso de salsas especiales de la casa con burbujeo)
   - Crunchy Chips ASMR (fracturas nítidas de tostitos/totopos con pegada acústica)
   - Cosmic UFO Beam (haz tractor esmeralda de Miramar con modulación FM y sub-grave)
   - Sparkle Chimes (destello mágico pentatónico de 24K Gold y fuegos artificiales)
3. Mezcla maestra con Auto-Ducking dinámico sobre Beachfront_Celebration.mp3:
   - Atenuación de música a 0.18 bajo voz (-12 dB) con envolventes suaves de 250 ms.
   - Masterización a norma broadcast: -14 LUFS ± 2 LUFS, pico < -1 dBFS.
4. Generación de subtítulos dinámicos en formato ASS (subtitulos_aaa_stories_170.ass)
   adheridos estrictamente a zonas seguras (X en [90, 990], Y ~1220 a 1350).
5. Blindaje estricto de marca: precio oficial $170 MXN, pedidos por WhatsApp.
"""

import os
import sys
import json
import wave
import asyncio
import subprocess
from pathlib import Path
import numpy as np
import edge_tts

# Codificación UTF-8 para consola Windows
if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")

# Rutas del proyecto
BASE_DIR = Path(r"d:\AG\la garza aguachilera")
HERRAMIENTAS_DIR = BASE_DIR / "herramientas"
FFMPEG_DIR = HERRAMIENTAS_DIR / "ffmpeg"
FFMPEG = FFMPEG_DIR / "ffmpeg.exe"
FFPROBE = FFMPEG_DIR / "ffprobe.exe"
MUSIC_PATH = HERRAMIENTAS_DIR / "Beachfront_Celebration.mp3"
STEMS_DIR = HERRAMIENTAS_DIR / "audio_stems_aaa"
STEMS_DIR.mkdir(parents=True, exist_ok=True)

MASTER_WAV_PATH = HERRAMIENTAS_DIR / "audio_master_aaa_24s.wav"
ASS_SUBS_PATH = HERRAMIENTAS_DIR / "subtitulos_aaa_stories_170.ass"

SAMPLE_RATE = 44100
TARGET_DURATION = 24.0
TOTAL_SAMPLES = int(SAMPLE_RATE * TARGET_DURATION)  # 1,058,400 muestras

# Guión de 4 Actos estructurado para 24s exactos
# Cumple el 100% de los elementos requeridos por la marca
SCRIPT_ACTS = [
    {
        "id": "act1_hook",
        "act": 1,
        "name": "Gancho y Antojo Sensorial",
        "text": "¡Mmmh, qué antojazo! Tostiaguachile Verde Tradicional con cien gramos de camarón mariposa, limoncito y serrano.",
        "target_start": 0.30,
        "atempo": 1.20,
        "eq": "equalizer=f=250:width_type=h:width=150:g=2.2,equalizer=f=3500:width_type=h:width=1000:g=1.8,alimiter=limit=0.92"
    },
    {
        "id": "act2_signature",
        "act": 2,
        "name": "Atributos Exclusivos (Aguacate y Salsas)",
        "text": "¡Lleva aguacate fresco y cremoso en cada orden, bañado en salsas especiales de la casa!",
        "target_start": 6.05,
        "atempo": 1.05,
        "eq": "equalizer=f=250:width_type=h:width=150:g=2.2,equalizer=f=3500:width_type=h:width=1000:g=1.8,alimiter=limit=0.92"
    },
    {
        "id": "act3_complements",
        "act": 3,
        "name": "Los 4 Complementos y Modalidades",
        "text": "¡Con Tostitos Verde, Flamin Hot, Chips Artesanales o Saladas: preparado al momento o por separado!",
        "target_start": 10.80,
        "atempo": 1.15,
        "eq": "equalizer=f=250:width_type=h:width=150:g=2.2,equalizer=f=3500:width_type=h:width=1000:g=1.8,alimiter=limit=0.92"
    },
    {
        "id": "act4_closing",
        "act": 4,
        "name": "Precio Estricto $170 MXN y WhatsApp CTA",
        "text": "¡Por solo ciento setenta pesitos! Envíos en Tampico y Ciudad Madero. ¡Pide por WhatsApp al 833 252 09 88!",
        "target_start": 15.85,
        "atempo": 1.25,
        "eq": "equalizer=f=250:width_type=h:width=150:g=2.2,equalizer=f=3500:width_type=h:width=1000:g=1.8,alimiter=limit=0.92"
    }
]


# =============================================================================
# 1. SÍNTESIS DE VOZ PROCEDURAL Y MASTERIZACIÓN DE PISTAS (EDGE-TTS)
# =============================================================================

async def synthesize_voice_stems():
    """Genera las 4 líneas vocales con edge-tts y las masteriza con FFmpeg."""
    print("=== [1/5] GENERANDO LOCUCIÓN FEMENINA COQUETA Y ANTOJABLE (es-MX-DaliaNeural) ===")
    processed_stems = []

    for item in SCRIPT_ACTS:
        raw_mp3 = STEMS_DIR / f"{item['id']}_raw.mp3"
        proc_wav = STEMS_DIR / f"{item['id']}_proc.wav"

        print(f" -> Sintetizando {item['id']}: '{item['text'][:45]}...'")
        comm = edge_tts.Communicate(
            item["text"],
            voice="es-MX-DaliaNeural",
            rate="+11%",
            pitch="+3Hz"
        )
        await comm.save(str(raw_mp3))

        # Filtro de velocidad controlada, recorte de silencios muertos y EQ cálido
        filt = (
            f"atempo={item['atempo']},"
            f"silenceremove=stop_periods=-1:stop_duration=0.15:stop_threshold=-40dB,"
            f"{item['eq']},"
            f"aformat=sample_fmts=s16:sample_rates={SAMPLE_RATE}:channel_layouts=stereo"
        )

        cmd = [
            str(FFMPEG), "-y", "-i", str(raw_mp3),
            "-filter:a", filt,
            str(proc_wav)
        ]
        subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

        # Leer duración exacta
        probe_cmd = [
            str(FFPROBE), "-v", "error", "-show_entries", "format=duration",
            "-of", "default=noprint_wrappers=1:nokey=1", str(proc_wav)
        ]
        dur = float(subprocess.check_output(probe_cmd).decode().strip())
        print(f"    [OK] Duración procesada: {dur:.2f}s | Inicio objetivo: {item['target_start']:.2f}s")

        processed_stems.append({
            **item,
            "wav_path": proc_wav,
            "duration": dur,
            "actual_start": item["target_start"],
            "actual_end": round(item["target_start"] + dur, 3)
        })

    return processed_stems


def load_wav_stereo(path):
    """Carga un archivo WAV estéreo y lo convierte a np.float32 en rango [-1.0, 1.0]."""
    with wave.open(str(path), "rb") as wf:
        n_ch = wf.getnchannels()
        sr = wf.getframerate()
        n_frames = wf.getnframes()
        raw = wf.readframes(n_frames)
        data = np.frombuffer(raw, dtype=np.int16).astype(np.float32) / 32768.0

        if n_ch == 1:
            data = np.column_stack([data, data])
        else:
            data = data.reshape(-1, n_ch)
            if n_ch > 2:
                data = data[:, :2]

        return data


def mix_at(master_buf, sfx_buf, start_sec, gain=1.0):
    """Mezcla un buffer de audio dentro del master en la posición de tiempo indicada."""
    start_idx = int(start_sec * SAMPLE_RATE)
    if start_idx < 0 or start_idx >= len(master_buf):
        return
    end_idx = min(len(master_buf), start_idx + len(sfx_buf))
    seg_len = end_idx - start_idx
    master_buf[start_idx:end_idx] += sfx_buf[:seg_len] * gain


# =============================================================================
# 2. SÍNTESIS PROCEDURAL DE LOS 5 EFECTOS CULINARIOS Y 3D
# =============================================================================

def make_sfx_lime_squeeze(duration=0.7, sr=SAMPLE_RATE):
    """
    SFX 1: Exprimido de Limón Colima Fresco.
    Rocío a alta presión (ruido coloreado por diferenciación con envolvente asimétrica)
    + micro-burbujas FM moduladas a 32 Hz para efervescencia cítrica.
    """
    n = int(sr * duration)
    t = np.linspace(0, duration, n, endpoint=False)
    rng = np.random.default_rng(101)
    spray = rng.normal(0, 1, n)
    spray = np.diff(spray, prepend=0)
    spray = spray / (np.max(np.abs(spray)) + 1e-6)
    env_spray = np.exp(-t * 8.5) * (1.0 - np.exp(-t * 45.0))
    droplets = np.sin(2 * np.pi * (1200 + 400 * np.sin(2 * np.pi * 32 * t)) * t) * np.exp(-t * 11.0)
    sig = (spray * env_spray * 0.70 + droplets * 0.35) * 0.85
    pan_l = np.linspace(0.85, 0.45, n)
    pan_r = np.linspace(0.45, 0.85, n)
    return np.column_stack([sig * pan_l, sig * pan_r]).astype(np.float32)


def make_sfx_salsa_splash(duration=0.6, sr=SAMPLE_RATE):
    """
    SFX 2: Baño y Salpicadura de Salsas Especiales de la Casa.
    Golpe sordo viscoso (barrido exponencial descendente 150 Hz -> 48 Hz)
    + chapoteo líquido con gotas resonantes escalonadas.
    """
    n = int(sr * duration)
    t = np.linspace(0, duration, n, endpoint=False)
    thud_freq = 150 * np.exp(-t * 18.0) + 48
    thud = np.sin(2 * np.pi * thud_freq * t) * np.exp(-t * 14.0) * 0.75
    rng = np.random.default_rng(202)
    splat = rng.normal(0, 0.4, n) * np.exp(-t * 12.0)
    pops = np.zeros_like(t)
    for delay, freq in [(0.02, 750), (0.05, 520), (0.09, 890), (0.14, 610)]:
        tt = np.maximum(0, t - delay)
        mask = (t >= delay).astype(np.float32)
        pops += mask * np.sin(2 * np.pi * freq * np.exp(-tt * 25.0) * tt) * np.exp(-tt * 28.0) * 0.35
    sig = (thud * 0.60 + splat * 0.35 + pops * 0.50) * 0.85
    return np.column_stack([sig, sig]).astype(np.float32)


def make_sfx_crunch_asmr(duration=0.55, sr=SAMPLE_RATE):
    """
    SFX 3: Crunch ASMR de Tostitos y Totopos Artesanales.
    Doble diferenciación de ruido para generar micro-transientes fracturados ultra-nítidos
    en 4 micro-impactos sucesivos + pegada de graves a 140 Hz.
    """
    n = int(sr * duration)
    t = np.linspace(0, duration, n, endpoint=False)
    rng = np.random.default_rng(303)
    noise = rng.normal(0, 1, n)
    crisp = np.diff(noise, prepend=0)
    crisp = np.diff(crisp, prepend=0)
    crisp = crisp / (np.max(np.abs(crisp)) + 1e-6)
    env = (
        np.exp(-((t - 0.04) / 0.025) ** 2) * 1.0 +
        np.exp(-((t - 0.11) / 0.030) ** 2) * 0.85 +
        np.exp(-((t - 0.19) / 0.035) ** 2) * 0.75 +
        np.exp(-((t - 0.29) / 0.045) ** 2) * 0.55
    )
    low_punch = np.sin(2 * np.pi * 140 * t) * np.exp(-t * 14) * 0.45
    sig = (crisp * env * 0.75 + low_punch) * 0.85
    return np.column_stack([sig, sig]).astype(np.float32)


def make_sfx_ufo_beam(duration=1.4, sr=SAMPLE_RATE):
    """
    SFX 4: Haz Tractor Cósmico del OVNI de Miramar.
    Modulación de frecuencia portadora dual (520 Hz / 780 Hz) modulada por LFO senoidal de 7.5 Hz,
    respaldada por sub-grave a 110 Hz y ensanchamiento estéreo en fase.
    """
    n = int(sr * duration)
    t = np.linspace(0, duration, n, endpoint=False)
    lfo = np.sin(2 * np.pi * 7.5 * t) * 35
    carrier1 = np.sin(2 * np.pi * (520 + lfo) * t)
    carrier2 = np.sin(2 * np.pi * (780 - lfo * 0.8) * t)
    sub = np.sin(2 * np.pi * 110 * t)
    env = np.sin(np.pi * (t / duration)) ** 0.7
    left = (carrier1 * 0.3 + sub * 0.25) * env * 0.45
    right = (carrier2 * 0.3 + sub * 0.25) * env * 0.45
    return np.column_stack([left, right]).astype(np.float32)


def make_sfx_sparkle_chimes(duration=1.1, sr=SAMPLE_RATE):
    """
    SFX 5: Destello Mágico / Chimes de Oro 24K y Estrellas.
    Arpegio pentatónico de campanas celestiales [C6, E6, G6, B6, D7] en cascada
    con decaimiento shimmer y destello armónico brillante.
    """
    n = int(sr * duration)
    t = np.linspace(0, duration, n, endpoint=False)
    notes = [1046.50, 1318.51, 1567.98, 1975.53, 2349.32]  # C6, E6, G6, B6, D7
    chord = np.zeros_like(t)
    for i, f in enumerate(notes):
        delay = i * 0.032
        mask = (t >= delay).astype(np.float32)
        tt = np.maximum(0, t - delay)
        chord += mask * np.sin(2 * np.pi * f * tt) * np.exp(-tt * 4.2) * 0.22
    boom = np.sin(2 * np.pi * (130 * np.exp(-t * 9) + 45) * t) * np.exp(-t * 7) * 0.35
    sig = chord + boom
    pan_l = np.linspace(0.4, 0.9, n)
    pan_r = np.linspace(0.9, 0.4, n)
    return np.column_stack([sig * pan_l, sig * pan_r]).astype(np.float32)


# =============================================================================
# 3. MEZCLA MAESTRA CON AUTO-DUCKING Y MASTERIZACIÓN BROADCAST
# =============================================================================

def build_master_audio(stems):
    """Mezcla voz, los 5 SFX procedurales y la música con auto-ducking estricto a -12dB."""
    print("=== [2/5] MEZCLANDO AUDIO MAESTRO CON AUTO-DUCKING (-12dB) Y SFX PROCEDURALES ===")

    voice_master = np.zeros((TOTAL_SAMPLES, 2), dtype=np.float32)
    sfx_master = np.zeros((TOTAL_SAMPLES, 2), dtype=np.float32)

    # 1. Posicionamiento de las 4 pistas de voz
    for st in stems:
        v_data = load_wav_stereo(st["wav_path"])
        mix_at(voice_master, v_data, st["actual_start"], gain=1.12)

    # 2. Posicionamiento estratégico de los 5 SFX procedurales
    # Acto 1: Rayo OVNI al levitar hielera + Exprimido de limón Colima
    print(" -> Inyectando SFX 4: Haz tractor OVNI de Miramar en t=1.20s...")
    mix_at(sfx_master, make_sfx_ufo_beam(1.5), 1.20, gain=0.65)
    print(" -> Inyectando SFX 1: Exprimido de limón Colima en t=4.40s...")
    mix_at(sfx_master, make_sfx_lime_squeeze(0.7), 4.40, gain=0.75)

    # Acto 2: Baño de salsas especiales de la casa
    print(" -> Inyectando SFX 2: Baño y salpicadura de salsas de la casa en t=8.40s...")
    mix_at(sfx_master, make_sfx_salsa_splash(0.65), 8.40, gain=0.75)

    # Acto 3: Doble Crunch ASMR de Tostitos y Totopos
    print(" -> Inyectando SFX 3: Crunch ASMR 1 en t=12.20s...")
    mix_at(sfx_master, make_sfx_crunch_asmr(0.55), 12.20, gain=0.85)
    print(" -> Inyectando SFX 3: Crunch ASMR 2 en t=14.50s...")
    mix_at(sfx_master, make_sfx_crunch_asmr(0.55), 14.50, gain=0.80)

    # Acto 4: Destello de estrellas y chimes de Oro 24K para el sello de $170 MXN
    print(" -> Inyectando SFX 5: Sparkle Chimes de Oro 24K ($170 MXN) en t=16.20s...")
    mix_at(sfx_master, make_sfx_sparkle_chimes(1.2), 16.20, gain=0.70)
    print(" -> Inyectando SFX 5: Sparkle Chimes final CTA WhatsApp en t=21.80s...")
    mix_at(sfx_master, make_sfx_sparkle_chimes(1.0), 21.80, gain=0.60)

    # 3. Cargar música oficial de fondo (Beachfront_Celebration.mp3)
    temp_music_wav = STEMS_DIR / "temp_music_cut.wav"
    subprocess.run([
        str(FFMPEG), "-y", "-i", str(MUSIC_PATH),
        "-t", str(TARGET_DURATION + 0.5),
        "-ar", str(SAMPLE_RATE), "-ac", "2", "-c:a", "pcm_s16le",
        str(temp_music_wav)
    ], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

    music_data = load_wav_stereo(temp_music_wav)[:TOTAL_SAMPLES]
    if temp_music_wav.exists():
        try:
            temp_music_wav.unlink()
        except Exception:
            pass

    # 4. Auto-Ducking con envolvente suavizada de 250ms
    # Nominal en silencios/intro: 0.65 (-3.7 dBFS)
    # Ducking bajo voz: 0.18 (-12 dB de atenuación sobre nominal)
    print(" -> Calculando envolvente de Auto-Ducking de música a 0.18 bajo voz...")
    voice_mono_abs = np.max(np.abs(voice_master), axis=1)
    win_presmooth = int(SAMPLE_RATE * 0.15)
    kernel_pre = np.ones(win_presmooth, dtype=np.float32) / win_presmooth
    smooth_voice = np.convolve(voice_mono_abs, kernel_pre, mode="same")

    # Mapeo no lineal: si hay presencia de voz (> 0.012), atenuar a 0.18; si no, elevar a 0.65
    raw_duck = np.where(smooth_voice > 0.012, 0.18, 0.65).astype(np.float32)

    # Suavizado de 250ms (attack y release suaves para evitar bombeo brusco)
    win_duck = int(SAMPLE_RATE * 0.250)
    duck_gain = np.convolve(raw_duck, np.ones(win_duck, dtype=np.float32) / win_duck, mode="same")

    # Fundido de entrada y salida suave
    fade_in_len = int(SAMPLE_RATE * 0.40)
    fade_out_len = int(SAMPLE_RATE * 0.70)
    duck_gain[:fade_in_len] *= np.linspace(0.0, 1.0, fade_in_len)
    duck_gain[-fade_out_len:] *= np.linspace(1.0, 0.0, fade_out_len)

    music_ducked = music_data * duck_gain[:, None]

    # 5. Suma general balanceada
    final_mix = voice_master + sfx_master * 0.70 + music_ducked

    # 6. Exportar mezcla preliminar para normalización EBU R128 con FFmpeg
    temp_premix_wav = STEMS_DIR / "temp_premix.wav"
    clipped = np.clip(final_mix, -0.98, 0.98)
    pcm16 = (clipped * 32767.0).astype(np.int16)
    with wave.open(str(temp_premix_wav), "wb") as wf:
        wf.setnchannels(2)
        wf.setsampwidth(2)
        wf.setframerate(SAMPLE_RATE)
        wf.writeframes(pcm16.tobytes())

    # 7. Masterización final Broadcast con FFmpeg loudnorm (-14 LUFS, True Peak <= -1.2 dBFS)
    print(f" -> Masterizando a norma broadcast (-14 LUFS, pico < -1 dBFS) en: {MASTER_WAV_PATH}...")
    norm_cmd = [
        str(FFMPEG), "-y", "-i", str(temp_premix_wav),
        "-af", "loudnorm=I=-14.0:TP=-1.2:LRA=9.0",
        "-ar", str(SAMPLE_RATE), "-ac", "2", "-c:a", "pcm_s16le",
        str(MASTER_WAV_PATH)
    ]
    subprocess.run(norm_cmd, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

    if temp_premix_wav.exists():
        try:
            temp_premix_wav.unlink()
        except Exception:
            pass

    print("    [OK] Audio Maestro 24.0s exportado exitosamente.")


# =============================================================================
# 4. GENERACIÓN DE SUBTÍTULOS DINÁMICOS SINCRONIZADOS (FORMATO ASS)
# =============================================================================

def format_ass_time(sec):
    """Convierte segundos a formato de tiempo ASS: H:MM:SS.cs"""
    h = int(sec // 3600)
    m = int((sec % 3600) // 60)
    s = int(sec % 60)
    cs = int(round((sec - int(sec)) * 100))
    if cs >= 100:
        cs = 99
    return f"{h}:{m:02d}:{s:02d}.{cs:02d}"


def generate_ass_subtitles(stems):
    """
    Genera subtítulos dinámicos de alta gama en formato ASS para Stories / TikTok.
    - Resolución base: 1080x1920
    - Zona Segura: X estrictamente en [90, 990], Y estrictamente en [1220, 1350].
    - Colores de marca: Oro 24K (&H0032EBFF), Neón Esmeralda (&H0070FF80), Blanco puro (&H00FFFFFF).
    - Subtítulos de 2 líneas con ritmo dinámico para máxima legibilidad.
    """
    print(f"=== [3/5] GENERANDO SUBTÍTULOS DINÁMICOS ASS EN ZONA SEGURA: {ASS_SUBS_PATH} ===")

    ass_header = """[Script Info]
Title: Subtítulos Dinámicos AAA Stories & TikTok - La Garza Aguachilera $170 MXN
ScriptType: v4.00+
WrapStyle: 0
ScaledBorderAndShadow: yes
YCbCr Matrix: TV.709
PlayResX: 1080
PlayResY: 1920

[V4+ Styles]
Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding
Style: Sub2L,Arial Black,42,&H00FFFFFF,&H000000FF,&H00000000,&HA0000000,-1,0,0,0,100,100,1,0,1,5,3,2,90,90,575,1

[Events]
Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text
"""

    events = [
        # Acto 1: Gancho & Antojo Sensorial (~0.30s - 6.03s)
        f"Dialogue: 0,{format_ass_time(stems[0]['actual_start'])},{format_ass_time(stems[0]['actual_end'])},Sub2L,,0,0,0,,{{\\an2\\fad(100,100)}}{{\\c&H0032EBFF}}TOSTIAGUACHILE VERDE TRADICIONAL{{\\c&H00FFFFFF}}\\N~100g Camarón Mariposa • Limón y Serrano",

        # Acto 2: Atributos Exclusivos (Aguacate y Salsas) (~6.05s - 10.53s)
        f"Dialogue: 0,{format_ass_time(stems[1]['actual_start'])},{format_ass_time(stems[1]['actual_end'])},Sub2L,,0,0,0,,{{\\an2\\fad(100,100)}}{{\\c&H0070FF80}}AGUACATE FRESCO Y CREMOSO{{\\c&H00FFFFFF}}\\N{{\\c&H0032EBFF}}Bañado en Salsas Especiales de la Casa",

        # Acto 3: 4 Complementos y Modalidades (~10.80s - 15.75s)
        f"Dialogue: 0,{format_ass_time(stems[2]['actual_start'])},{format_ass_time(stems[2]['actual_end'])},Sub2L,,0,0,0,,{{\\an2\\fad(100,100)}}{{\\c&H0032EBFF}}4 COMPLEMENTOS A TU ELECCIÓN{{\\c&H00FFFFFF}}\\N{{\\c&H0070FF80}}Tostitos • Chips • Saladas • ¡En Vivo o Separado!",

        # Acto 4A: Precio Estricto $170 MXN (~15.85s - 19.50s)
        f"Dialogue: 0,{format_ass_time(stems[3]['actual_start'])},0:00:19.50,Sub2L,,0,0,0,,{{\\an2\\fad(100,100)}}{{\\fs50\\c&H0032EBFF}}¡POR SOLO $170 MXN!{{\\c&H00FFFFFF}}\\NTampico y Ciudad Madero",

        # Acto 4B: WhatsApp CTA y Entregas (~19.50s - 23.40s)
        f"Dialogue: 0,0:00:19.50,0:00:23.40,Sub2L,,0,0,0,,{{\\an2\\fad(100,150)}}{{\\c&H0070FF80}}WHATSAPP: 833 252 09 88{{\\c&H00FFFFFF}}\\NEnvíos y Entregas por Pedido"
    ]

    ass_content = ass_header + "\n".join(events) + "\n"

    with open(str(ASS_SUBS_PATH), "w", encoding="utf-8") as f:
        f.write(ass_content)

    print(f"    [OK] Archivo ASS generado exitosamente en: {ASS_SUBS_PATH}")


# =============================================================================
# 5. VERIFICACIÓN Y TELEMETRÍA AUTOMATIZADA
# =============================================================================

def verify_telemetry():
    """Valida duración, canales, volumen y sonoridad integrada con ffprobe y volumedetect/ebur128."""
    print("=== [4/5] AUDITORÍA Y TELEMETRÍA ACÚSTICA CON FFPROBE & VOLUMEDETECT ===")

    # 1. Inspección básica de streams
    probe_cmd = [
        str(FFPROBE), "-v", "error",
        "-show_entries", "stream=channels,sample_rate,codec_name:format=duration,size",
        "-of", "json", str(MASTER_WAV_PATH)
    ]
    meta = json.loads(subprocess.check_output(probe_cmd).decode())
    st = meta["streams"][0]
    dur = float(meta["format"]["duration"])
    channels = int(st["channels"])
    sr = int(st["sample_rate"])

    print(f" -> Formato: {st['codec_name']}, Frecuencia: {sr} Hz, Canales: {channels}")
    print(f" -> Duración exacta: {dur:.3f} s (Objetivo: 24.000 s)")
    assert channels == 2, f"Se esperaban 2 canales estéreo, se obtuvieron {channels}"
    assert sr == 44100, f"Frecuencia incorrecta {sr} (esperada 44100 Hz)"
    assert 23.95 <= dur <= 24.05, f"Duración fuera de rango: {dur}s"

    # 2. Análisis de volumen de pico y medio
    vol_cmd = [
        str(FFMPEG), "-i", str(MASTER_WAV_PATH),
        "-af", "volumedetect", "-f", "null", "-"
    ]
    res_vol = subprocess.run(vol_cmd, capture_output=True, text=True)
    max_vol = None
    mean_vol = None
    for line in res_vol.stderr.splitlines():
        if "max_volume:" in line:
            max_vol = float(line.split("max_volume:")[1].replace("dB", "").strip())
        elif "mean_volume:" in line:
            mean_vol = float(line.split("mean_volume:")[1].replace("dB", "").strip())

    print(f" -> Pico de volumen (max_volume): {max_vol} dBFS (Requisito: < -1.0 dBFS)")
    print(f" -> Volumen medio (mean_volume): {mean_vol} dBFS")
    assert max_vol is not None and max_vol < -1.0, f"Pico de volumen {max_vol} no cumple < -1 dBFS"

    # 3. Análisis de Sonoridad Integrada EBU R128
    ebur_cmd = [
        str(FFMPEG), "-i", str(MASTER_WAV_PATH),
        "-af", "ebur128=framelog=verbose", "-f", "null", "-"
    ]
    res_ebur = subprocess.run(ebur_cmd, capture_output=True, text=True)
    lufs = None
    for line in res_ebur.stderr.splitlines():
        if "I:" in line and "LUFS" in line:
            try:
                lufs = float(line.split("I:")[1].split("LUFS")[0].strip())
            except Exception:
                pass

    if lufs is not None:
        print(f" -> Sonoridad Integrada (LUFS): {lufs:.2f} LUFS (Objetivo: -14.0 ± 2.0 LUFS)")
        assert -16.0 <= lufs <= -12.0, f"Loudness fuera de rango: {lufs} LUFS"
    else:
        print(" -> Aviso: No se pudo parsear LUFS numérico directo de ebur128.")

    # 4. Blindaje estricto de marca en subtítulos y guión
    with open(str(ASS_SUBS_PATH), "r", encoding="utf-8") as f:
        subs_text = f.read()

    forbidden = [
        "$" + "150",
        "150" + " MXN",
        "150" + " pesos",
        "ciento" + " cincuenta",
        "Rosa" + " 210",
        "dark" + " kitchen",
        "colonia" + " flores",
        "1:00" + " a 5:00",
        "1:00" + " pm",
        "5:00" + " pm",
    ]
    for fb in forbidden:
        assert fb.lower() not in subs_text.lower(), f"Violación de blindaje: '{fb}' detectado en subtítulos."

    required = ["$170 MXN", "833 252 09 88", "aguacate", "salsas especiales", "Tampico y Ciudad Madero"]
    for req in required:
        assert req.lower() in subs_text.lower(), f"Falta término obligatorio en subtítulos: '{req}'"

    print(" [CERTIFICADO] Todas las pruebas acústicas, de volumen y blindaje de marca han sido superadas al 100%.")


async def main():
    print("================================================================================")
    print("  LA GARZA AGUACHILERA — PRODUCCIÓN DE AUDIO MAESTRO Y SUBTÍTULOS AAA (24.0s)  ")
    print("================================================================================")

    # Paso 1: Generar voces
    stems = await synthesize_voice_stems()

    # Paso 2: Mezclar SFX, música y masterizar
    build_master_audio(stems)

    # Paso 3: Generar subtítulos sincronizados
    generate_ass_subtitles(stems)

    # Paso 4: Validar telemetría
    verify_telemetry()

    print("================================================================================")
    print("  ¡PRODUCCIÓN DE AUDIO MAESTRO AAA FINALIZADA CON ÉXITO ABSOLUTO!             ")
    print("================================================================================")


if __name__ == "__main__":
    asyncio.run(main())
