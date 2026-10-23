"""
ESCUADRÓN DE PRODUCCIÓN AUDIOVISUAL — LA GARZA AGUACHILERA
Módulo 1: Agente_Voces_y_Prosodia_TTS + Agente_Diseno_Sonoro_y_Mezcla (Milestone 1)

Genera:
1. Las 6 pistas vocales en español mexicano con Gemini 3.8 Flash TTS (gemini-3.8-flash-tts)
   incorporando speech_metadata (speaker, style) e inline vocal tags (<groan>, <sigh>, <gasp>, <laugh>, <short pause>),
   con fallback de respaldo transparente en edge-tts.
2. Efectos de sonido (SFX) cómicos y gastronómicos sintetizados proceduralmente a 44.1 kHz estéreo:
   - Tambor cómico de cruda, Whoosh de transición, Garras metálicas de Freddy (Schwing!),
   - Rayo abductor OVNI de Miramar, Vapor criogénico a 2°C y exprimido de limón,
   - Trueno/destello mágico de resurrección, CRUNCH ASMR de Tostitos Salsa Verde y Campana final.
3. Mezcla Maestra Estéreo (audio_animacion_master_60fps.wav) con Auto-Ducking dinámico sobre
   Beachfront_Celebration.mp3 (atenuación a 0.14 bajo voz, recuperación a 0.46 en pausas).
4. Archivo de telemetría (timeline_animacion_60fps.json) con envolvente de amplitud RMS cuadro por cuadro
   a 60.0 fps para sincronización labial (Lip-Sync) exacta.
"""

import argparse
import asyncio
import base64
import json
import math
import os
import re
import subprocess
import time
import wave
import dotenv
import numpy as np

# Cargar variables de entorno y PATH para FFmpeg y Gemini API
dotenv.load_dotenv(os.path.expanduser("~/.env"))

BASE_DIR = r"d:\AG\la garza aguachilera"
TOOLS_DIR = os.path.join(BASE_DIR, "herramientas")
AUDIO_DIR = os.path.join(TOOLS_DIR, "audio_animacion")
FFMPEG_DIR = os.path.join(TOOLS_DIR, "ffmpeg")
FFMPEG = os.path.join(FFMPEG_DIR, "ffmpeg.exe")
MUSIC_PATH = os.path.join(TOOLS_DIR, "Beachfront_Celebration.mp3")

if FFMPEG_DIR not in os.environ.get("PATH", ""):
    os.environ["PATH"] = FFMPEG_DIR + os.pathsep + os.environ.get("PATH", "")

os.makedirs(AUDIO_DIR, exist_ok=True)

SAMPLE_RATE = 44100
FPS = 60

# Inicializar Google GenAI Client
genai_client = None
try:
    from google import genai
    from google.genai import types
    if os.getenv("GEMINI_API_KEY"):
        genai_client = genai.Client()
        print(" [TTS] Google GenAI SDK inicializado con Gemini API Key.")
    else:
        print(" [TTS] Aviso: GEMINI_API_KEY no encontrada en entorno.")
except Exception as e:
    print(f" [TTS] Aviso: No se pudo instanciar genai.Client(): {e}")

import edge_tts

# Casting vocal multi-personaje con gemini-3.8-flash-tts y speech_metadata
DIALOGUES = [
    {
        "id": "sc1_juancho_zombie",
        "character": "juancho_zombie",
        "speaker_label": "🐊 JUANCHO EL COCODRILO (MODO CRUDO)",
        "gemini_voice": "Puck",
        "gemini_speaker": "Juancho",
        "gemini_style": "exhausted, severe hangover, groaning, comic Mexican crocodile speaking slowly",
        "text": "<groan> ¡Aaaay mamá!... <sigh> ¡Noooombre compadre, qué trancazo me puso la fiesta de anoche!... No estoy muerto... ¡ando bien crudo aquí en la Laguna del Carpintero!",
        "subtitle_text": "¡Aaaay mamá! ¡Noooombre compadre, qué trancazo! No estoy muerto... ¡ando bien crudo en la Laguna del Carpintero!",
        "voice": "es-MX-JorgeNeural",
        "rate": "-4%",
        "pitch": "-10Hz",
        "eq_filter": "equalizer=f=160:width_type=h:width=90:g=4.5,equalizer=f=3000:width_type=h:width=900:g=2.0,alimiter=limit=0.95",
        "pre_pad": 0.35,
        "post_pad": 0.35
    },
    {
        "id": "sc2_mapache_freddy",
        "character": "mapache_freddy",
        "speaker_label": "🦝 MAPACHE FREDDY (ESCOLLERAS)",
        "gemini_voice": "Fenrir",
        "gemini_speaker": "Mapache",
        "gemini_style": "frantic, high-energy, mischievous comic cartoon raccoon, starving, desperate delivery",
        "text": "<gasp> ¡Pérate tantito Juancho, que yo ando peor!... <short pause> ¡Ni con estas garras de Freddy alcanzo un camaroncito!... ¡Tráiganme unos Tostitos Salsa Verde que me muero de antojo!",
        "subtitle_text": "¡Pérate tantito Juancho, que yo ando peor! ¡Tráiganme unos Tostitos Salsa Verde que me muero de antojo!",
        "voice": "es-MX-JorgeNeural",
        "rate": "+14%",
        "pitch": "+24Hz",
        "eq_filter": "equalizer=f=1100:width_type=h:width=500:g=3.0,equalizer=f=3800:width_type=h:width=1000:g=2.5,alimiter=limit=0.95",
        "pre_pad": 0.30,
        "post_pad": 0.35
    },
    {
        "id": "sc3_alien_miramar",
        "character": "alien_ovni",
        "speaker_label": "👽 ALIEN DEL OVNI DE MIRAMAR",
        "gemini_voice": "Enceladus",
        "gemini_speaker": "Alien",
        "gemini_style": "mysterious, friendly cosmic alien from Miramar base, calm eerie cadence",
        "text": "¡Tsss, tranquilos jaibos crudos!... <short pause> Desde la base submarina de Miramar les trajimos el antídoto sagrado... ¡Hielera a dos grados y puro limón Colima recién exprimido!",
        "subtitle_text": "¡Tsss, tranquilos jaibos crudos! Desde la base de Miramar trajimos el antídoto a 2°C con limón Colima recién exprimido.",
        "voice": "es-MX-DaliaNeural",
        "rate": "+8%",
        "pitch": "+18Hz",
        "eq_filter": "aecho=0.8:0.85:35:0.22,equalizer=f=2800:width_type=h:width=900:g=2.5,alimiter=limit=0.95",
        "pre_pad": 0.30,
        "post_pad": 0.35
    },
    {
        "id": "sc4_locutora_climax",
        "character": "locutora_climax",
        "speaker_label": "🎙️ LA GARZA AGUACHILERA",
        "gemini_voice": "Aoede",
        "gemini_speaker": "Locutora",
        "gemini_style": "high energy, dramatic, epic Mexican cartoon announcer, excited reveal",
        "text": "<gasp> ¡Y PUM, papá! Al primer crujido con cien gramos de camarón mariposa... ¡no estaban muertos, solo andaban crudos! El producto es preparado frente a usted para corroborar su frescura.",
        "subtitle_text": "¡Y PUM, PAPÁ! Al primer CRUNCH con ~100g de camarón mariposa... ¡no estaban muertos, solo andaban crudos! Preparado frente a usted.",
        "voice": "es-MX-DaliaNeural",
        "rate": "+8%",
        "pitch": "+2Hz",
        "eq_filter": "equalizer=f=240:width_type=h:width=120:g=2.5,equalizer=f=3600:width_type=h:width=1000:g=2.0,alimiter=limit=0.95",
        "pre_pad": 0.40,
        "post_pad": 0.35
    },
    {
        "id": "sc5_juancho_vivo",
        "character": "juancho_vivo",
        "speaker_label": "🐊 JUANCHO RESUCITADO (AL 100%)",
        "gemini_voice": "Puck",
        "gemini_speaker": "Juancho",
        "gemini_style": "joyful, cheerful, ecstatic, cured of hangover, energetic Mexican crocodile celebrating",
        "text": "<laugh> ¡Noooombre, qué delicia! ¡Reviví al cien por solo ciento setenta pesitos!",
        "subtitle_text": "¡Noooombre, qué delicia! ¡Reviví al 100% por solo $170 MXN!",
        "voice": "es-MX-JorgeNeural",
        "rate": "+8%",
        "pitch": "-4Hz",
        "eq_filter": "equalizer=f=200:width_type=h:width=100:g=3.0,equalizer=f=3400:width_type=h:width=900:g=2.2,alimiter=limit=0.95",
        "pre_pad": 0.25,
        "post_pad": 0.30
    },
    {
        "id": "sc6_locutora_cierre",
        "character": "locutora_cierre",
        "speaker_label": "🦅 PEDIDOS WHATSAPP 833 252 09 88",
        "gemini_voice": "Aoede",
        "gemini_speaker": "Locutora",
        "gemini_style": "professional, vibrant, inviting Mexican radio commercial call-to-action",
        "text": "¡La Garza Aguachilera! Sábados y domingos en Tampico y Madero. <short pause> ¡Manda WhatsApp al 833 252 09 88 y pide tu cura ya!",
        "subtitle_text": "¡La Garza Aguachilera! Sábados y domingos en Tampico y Madero. ¡WhatsApp 833 252 09 88!",
        "voice": "es-MX-DaliaNeural",
        "rate": "+8%",
        "pitch": "+2Hz",
        "eq_filter": "equalizer=f=240:width_type=h:width=120:g=2.5,equalizer=f=3600:width_type=h:width=1000:g=2.0,alimiter=limit=0.95",
        "pre_pad": 0.20,
        "post_pad": 0.85
    }
]


def synthesize_with_gemini(client, line_cfg, max_retries=2):
    """Sintetiza una línea con gemini-3.8-flash-tts usando speech_metadata e inline tags."""
    if not client:
        return None
    for attempt in range(max_retries + 1):
        try:
            print(f" [Gemini TTS] Sintetizando {line_cfg['id']} con {line_cfg['gemini_voice']} ({line_cfg['gemini_speaker']})...")
            resp = client.models.generate_content(
                model="gemini-3.8-flash-tts",
                contents=[{
                    "role": "user",
                    "parts": [{
                        "text": line_cfg["text"],
                        "speech_metadata": {
                            "speaker": line_cfg["gemini_speaker"],
                            "style": line_cfg["gemini_style"]
                        }
                    }]
                }],
                config=types.GenerateContentConfig(
                    response_modalities=["AUDIO"],
                    speech_config=types.SpeechConfig(
                        voice_config=types.VoiceConfig(
                            prebuilt_voice_config=types.PrebuiltVoiceConfig(
                                voice_name=line_cfg["gemini_voice"]
                            )
                        )
                    )
                )
            )
            if resp and resp.parts:
                for part in resp.parts:
                    if part.inline_data and part.inline_data.data:
                        raw_data = part.inline_data.data
                        if isinstance(raw_data, str):
                            raw_data = base64.b64decode(raw_data)
                        print(f" [Gemini TTS OK] {line_cfg['id']} -> {len(raw_data)} bytes recibidos.")
                        return raw_data
        except Exception as err:
            err_str = str(err)
            print(f" [Gemini TTS Retry] Intento {attempt+1}/{max_retries+1} para {line_cfg['id']} falló: {err}")
            if "429" in err_str or "RESOURCE_EXHAUSTED" in err_str or "quota" in err_str.lower():
                wait_sec = 25
                m = re.search(r"retry in (\d+(?:\.\d+)?)s", err_str)
                if m:
                    wait_sec = int(float(m.group(1))) + 2
                print(f" [Gemini TTS Quota] Enfriando API por {wait_sec}s antes de reintentar...")
                time.sleep(wait_sec)
            else:
                time.sleep(2)
    return None


async def synthesize_line(line_cfg, client, pace_delay=22.0, fallback_only=False, skip_existing=False):
    """Sintetiza un diálogo individual guardándolo en WAV 44.1kHz estéreo."""
    wav_out = os.path.join(AUDIO_DIR, f"{line_cfg['id']}.wav")
    gemini_raw_wav = os.path.join(AUDIO_DIR, f"{line_cfg['id']}_raw_gemini.wav")
    mp3_tmp = os.path.join(AUDIO_DIR, f"{line_cfg['id']}_tmp.mp3")

    if skip_existing and os.path.exists(wav_out) and os.path.getsize(wav_out) > 5000:
        print(f" [Cache] Reutilizando stem existente: {wav_out}")
        return wav_out, "cached"

    audio_bytes = None
    engine_used = "edge-tts"

    # Intentar síntesis con Gemini 3.8 Flash TTS
    if client and not fallback_only:
        audio_bytes = synthesize_with_gemini(client, line_cfg)
        if audio_bytes:
            engine_used = "gemini-3.8-flash-tts"
            with open(gemini_raw_wav, "wb") as f:
                f.write(audio_bytes)

            af = f"silenceremove=start_periods=1:start_duration=0.02:start_threshold=-45dB,{line_cfg['eq_filter']}"
            cmd = [
                FFMPEG, "-y", "-i", gemini_raw_wav,
                "-af", af,
                "-ar", str(SAMPLE_RATE),
                "-ac", "2",
                "-c:a", "pcm_s16le",
                wav_out
            ]
            subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            if os.path.exists(gemini_raw_wav):
                try:
                    os.remove(gemini_raw_wav)
                except Exception:
                    pass
            if pace_delay > 0:
                print(f" [Pacing] Esperando {pace_delay:.1f}s para respetar límite 3 RPM de Gemini TTS...")
                time.sleep(pace_delay)
            return wav_out, engine_used

    # Fallback con Edge-TTS (limpiando tags <...>)
    clean_text = re.sub(r"<[^>]+>", "", line_cfg["text"]).strip()
    clean_text = re.sub(r"\s+", " ", clean_text)
    print(f" [Fallback Edge-TTS] Sintetizando {line_cfg['id']} con {line_cfg['voice']}...")
    comm = edge_tts.Communicate(
        clean_text,
        line_cfg["voice"],
        rate=line_cfg["rate"],
        pitch=line_cfg["pitch"]
    )
    await comm.save(mp3_tmp)

    af = f"silenceremove=start_periods=1:start_duration=0.02:start_threshold=-45dB,{line_cfg['eq_filter']}"
    cmd = [
        FFMPEG, "-y", "-i", mp3_tmp,
        "-af", af,
        "-ar", str(SAMPLE_RATE),
        "-ac", "2",
        "-c:a", "pcm_s16le",
        wav_out
    ]
    subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    if os.path.exists(mp3_tmp):
        try:
            os.remove(mp3_tmp)
        except Exception:
            pass
    return wav_out, engine_used


def load_wav_stereo(wav_path):
    with wave.open(wav_path, "rb") as wf:
        n_frames = wf.getnframes()
        raw = wf.readframes(n_frames)
        data = np.frombuffer(raw, dtype=np.int16).astype(np.float32) / 32768.0
        if wf.getnchannels() == 2:
            data = data.reshape(-1, 2)
        else:
            data = np.column_stack([data, data])
    return data


def save_wav_stereo(wav_path, stereo_float):
    clipped = np.clip(stereo_float, -0.99, 0.99)
    pcm16 = (clipped * 32767.0).astype(np.int16)
    with wave.open(wav_path, "wb") as wf:
        wf.setnchannels(2)
        wf.setsampwidth(2)
        wf.setframerate(SAMPLE_RATE)
        wf.writeframes(pcm16.tobytes())


# --- SÍNTESIS PROCEDURAL DE SFX CÓMICOS Y GASTRONÓMICOS ---
def make_sfx_comic_drum(duration=0.45):
    t = np.linspace(0, duration, int(SAMPLE_RATE * duration), endpoint=False)
    freq = 110 * np.exp(-t * 6.5) + 42
    env = np.exp(-t * 7.0)
    sig = np.sin(2 * np.pi * freq * t) * env * 0.55
    return np.column_stack([sig, sig])


def make_sfx_whoosh(duration=0.32):
    n = int(SAMPLE_RATE * duration)
    t = np.linspace(0, duration, n, endpoint=False)
    noise = np.random.normal(0, 1, n)
    sweep = np.sin(2 * np.pi * (180 + 900 * (t / duration)) * t)
    env = np.sin(np.pi * (t / duration)) ** 1.8
    sig = (noise * 0.35 + sweep * 0.45) * env * 0.45
    pan_l = np.linspace(0.9, 0.2, n)
    pan_r = np.linspace(0.2, 0.9, n)
    return np.column_stack([sig * pan_l, sig * pan_r])


def make_sfx_freddy_claws(duration=0.38):
    t = np.linspace(0, duration, int(SAMPLE_RATE * duration), endpoint=False)
    freqs = [2450, 3720, 5180, 6890]
    sig = np.zeros_like(t)
    for idx, f in enumerate(freqs):
        sig += np.sin(2 * np.pi * (f + idx * 120 * t) * t) * np.exp(-t * (8 + idx * 2))
    noise_scrape = np.random.normal(0, 0.3, len(t)) * np.exp(-t * 18)
    out = (sig * 0.22 + noise_scrape * 0.35) * 0.65
    return np.column_stack([out, out])


def make_sfx_ufo_beam(duration=1.4):
    t = np.linspace(0, duration, int(SAMPLE_RATE * duration), endpoint=False)
    lfo = np.sin(2 * np.pi * 7.5 * t) * 35
    carrier1 = np.sin(2 * np.pi * (520 + lfo) * t)
    carrier2 = np.sin(2 * np.pi * (780 - lfo * 0.8) * t)
    sub = np.sin(2 * np.pi * 110 * t)
    env = np.sin(np.pi * (t / duration)) ** 0.7
    left = (carrier1 * 0.3 + sub * 0.25) * env * 0.45
    right = (carrier2 * 0.3 + sub * 0.25) * env * 0.45
    return np.column_stack([left, right])


def make_sfx_cryo_and_lime(duration=0.8):
    n = int(SAMPLE_RATE * duration)
    t = np.linspace(0, duration, n, endpoint=False)
    hiss = np.random.normal(0, 1, n) * np.exp(-t * 4.5) * 0.30
    bubbles = np.sin(2 * np.pi * (900 + 600 * np.sin(2 * np.pi * 28 * t)) * t) * np.exp(-t * 5.0) * 0.25
    sig = hiss + bubbles
    return np.column_stack([sig, sig])


def make_sfx_crunch_asmr(duration=0.55):
    n = int(SAMPLE_RATE * duration)
    t = np.linspace(0, duration, n, endpoint=False)
    rng = np.random.default_rng(42)
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
    return np.column_stack([sig, sig])


def make_sfx_resurrection_chime(duration=0.9):
    t = np.linspace(0, duration, int(SAMPLE_RATE * duration), endpoint=False)
    notes = [523.25, 659.25, 783.99, 987.77, 1174.66]
    chord = np.zeros_like(t)
    for i, f in enumerate(notes):
        delay = i * 0.035
        mask = (t >= delay).astype(np.float32)
        tt = np.maximum(0, t - delay)
        chord += mask * np.sin(2 * np.pi * f * tt) * np.exp(-tt * 3.5) * 0.20
    boom = np.sin(2 * np.pi * (95 * np.exp(-t * 8) + 35) * t) * np.exp(-t * 6) * 0.50
    sig = chord + boom
    return np.column_stack([sig, sig])


def mix_at(master_buf, sfx_buf, start_sec, gain=1.0):
    start_idx = int(start_sec * SAMPLE_RATE)
    if start_idx < 0 or start_idx >= len(master_buf):
        return
    end_idx = min(len(master_buf), start_idx + len(sfx_buf))
    seg_len = end_idx - start_idx
    master_buf[start_idx:end_idx] += sfx_buf[:seg_len] * gain


async def main():
    parser = argparse.ArgumentParser(description="Productor de Audio Maestro y Telemetría 60fps")
    parser.add_argument("--skip-existing", action="store_true", help="Reutilizar stems WAV si ya existen")
    parser.add_argument("--force-tts", action="store_true", help="Forzar re-síntesis de todos los stems")
    parser.add_argument("--fallback-only", action="store_true", help="Usar únicamente edge-tts")
    parser.add_argument("--pace-delay", type=float, default=21.0, help="Pausa entre llamadas a Gemini TTS")
    args = parser.parse_args()

    print("=== ESCUADRÓN AUDIOVISUAL: GENERANDO CASTING VOCAL EXPRESIVO (es-MX) ===")
    scenes_meta = []
    current_sec = 0.0

    total_lines = len(DIALOGUES)
    for idx, line in enumerate(DIALOGUES):
        # Determinar si aplicar pace delay (no es necesario tras la última línea)
        is_last = (idx == total_lines - 1)
        cur_pace = 0.0 if is_last else args.pace_delay

        wav_path, engine = await synthesize_line(
            line,
            genai_client,
            pace_delay=cur_pace,
            fallback_only=args.fallback_only,
            skip_existing=(args.skip_existing and not args.force_tts)
        )
        audio_data = load_wav_stereo(wav_path)
        voice_dur = len(audio_data) / SAMPLE_RATE
        scene_dur = round(line["pre_pad"] + voice_dur + line["post_pad"], 3)

        voice_start_sec = round(current_sec + line["pre_pad"], 3)
        voice_end_sec = round(voice_start_sec + voice_dur, 3)
        scene_end_sec = round(current_sec + scene_dur, 3)

        print(f" [OK] {line['id']} [{engine}] ({line.get('gemini_voice', line['voice'])}) -> {voice_dur:.2f}s (Escena: {current_sec:.2f}s - {scene_end_sec:.2f}s)")

        scenes_meta.append({
            "id": line["id"],
            "character": line["character"],
            "speaker_label": line["speaker_label"],
            "text": line["text"],
            "subtitle_text": line["subtitle_text"],
            "wav_path": wav_path,
            "tts_engine": engine,
            "gemini_voice": line.get("gemini_voice", "N/A"),
            "gemini_style": line.get("gemini_style", "N/A"),
            "scene_start": round(current_sec, 3),
            "scene_end": scene_end_sec,
            "scene_duration": scene_dur,
            "voice_start": voice_start_sec,
            "voice_end": voice_end_sec,
            "voice_duration": round(voice_dur, 3)
        })
        current_sec = scene_end_sec

    total_duration = round(current_sec, 3)
    total_samples = int(math.ceil(total_duration * SAMPLE_RATE))
    total_frames_60fps = int(math.ceil(total_duration * FPS))

    print(f"\nDuración total exacta del episodio animado: {total_duration:.2f}s ({total_frames_60fps} frames a 60fps)")

    # Construir búfer de voces y calcular envolvente RMS cuadro por cuadro (60fps) para Lip-Sync
    voice_master = np.zeros((total_samples, 2), dtype=np.float32)
    frame_envelopes = []
    samples_per_frame = SAMPLE_RATE / FPS

    for sc in scenes_meta:
        v_data = load_wav_stereo(sc["wav_path"])
        mix_at(voice_master, v_data, sc["voice_start"], gain=1.18)

    # Calcular amplitud normalizada por frame (60fps) y personaje activo
    for f_idx in range(total_frames_60fps):
        t_sec = f_idx / FPS
        s0 = int(f_idx * samples_per_frame)
        s1 = min(total_samples, int((f_idx + 1) * samples_per_frame))
        if s1 > s0:
            chunk = voice_master[s0:s1]
            rms = float(np.sqrt(np.mean(chunk ** 2)))
        else:
            rms = 0.0
        mouth_open = min(1.0, max(0.0, (rms - 0.015) / 0.16))

        active_sc = scenes_meta[-1]
        for sc in scenes_meta:
            if sc["scene_start"] <= t_sec < sc["scene_end"]:
                active_sc = sc
                break

        is_speaking = (active_sc["voice_start"] <= t_sec <= active_sc["voice_end"]) and (mouth_open > 0.04)
        frame_envelopes.append({
            "frame": f_idx,
            "time": round(t_sec, 4),
            "scene_id": active_sc["id"],
            "character": active_sc["character"],
            "mouth_open": round(mouth_open if is_speaking else 0.0, 3)
        })

    print("=== SINTETIZANDO SFX CÓMICOS Y MEZCLANDO CON AUTO-DUCKING ===")
    sfx_master = np.zeros((total_samples, 2), dtype=np.float32)

    # Escena 1: Tambor cómico de cruda
    mix_at(sfx_master, make_sfx_comic_drum(0.45), scenes_meta[0]["scene_start"] + 0.05, gain=0.60)
    # Escena 2: Whoosh transición + Garras de Freddy (Schwing!)
    mix_at(sfx_master, make_sfx_whoosh(0.32), scenes_meta[1]["scene_start"], gain=0.70)
    mix_at(sfx_master, make_sfx_freddy_claws(0.38), scenes_meta[1]["scene_start"] + 0.15, gain=0.65)
    mix_at(sfx_master, make_sfx_freddy_claws(0.32), scenes_meta[1]["scene_start"] + 2.40, gain=0.45)
    # Escena 3: Whoosh + Rayo abductor OVNI + Vapor criogénico 2°C y limón
    mix_at(sfx_master, make_sfx_whoosh(0.32), scenes_meta[2]["scene_start"], gain=0.70)
    mix_at(sfx_master, make_sfx_ufo_beam(1.5), scenes_meta[2]["scene_start"] + 0.05, gain=0.65)
    mix_at(sfx_master, make_sfx_cryo_and_lime(0.85), scenes_meta[2]["scene_start"] + 3.20, gain=0.60)
    # Escena 4: Trueno/Destello mágico de Resurrección + CRUNCH ASMR de Tostitos Salsa Verde
    mix_at(sfx_master, make_sfx_resurrection_chime(0.95), scenes_meta[3]["scene_start"] + 0.02, gain=0.80)
    mix_at(sfx_master, make_sfx_crunch_asmr(0.55), scenes_meta[3]["scene_start"] + 1.35, gain=0.95)
    mix_at(sfx_master, make_sfx_crunch_asmr(0.50), scenes_meta[3]["scene_start"] + 2.10, gain=0.75)
    # Escena 5: Campana de resurrección al 100% ($170 MXN)
    mix_at(sfx_master, make_sfx_resurrection_chime(0.75), scenes_meta[4]["scene_start"] + 0.05, gain=0.65)
    # Escena 6: Whoosh final + Chime comercial
    mix_at(sfx_master, make_sfx_whoosh(0.30), scenes_meta[5]["scene_start"], gain=0.60)
    mix_at(sfx_master, make_sfx_resurrection_chime(0.85), scenes_meta[5]["scene_end"] - 0.90, gain=0.70)

    # Cargar música tropical de fondo (Beachfront_Celebration.mp3) convertida a WAV temporal
    music_wav_tmp = os.path.join(AUDIO_DIR, "temp_music.wav")
    subprocess.run([
        FFMPEG, "-y", "-i", MUSIC_PATH,
        "-t", str(total_duration + 1.0),
        "-ar", str(SAMPLE_RATE), "-ac", "2", "-c:a", "pcm_s16le",
        music_wav_tmp
    ], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    music_data = load_wav_stereo(music_wav_tmp)[:total_samples]
    if os.path.exists(music_wav_tmp):
        try:
            os.remove(music_wav_tmp)
        except Exception:
            pass

    # Auto-Ducking: calcular envolvente suavizada de voz para atenuar la música a 0.14 cuando hablan y subir a 0.46 en pausas
    voice_mono_abs = np.max(np.abs(voice_master), axis=1)
    win = int(SAMPLE_RATE * 0.18)
    kernel = np.ones(win, dtype=np.float32) / win
    smooth_voice = np.convolve(voice_mono_abs, kernel, mode="same")
    duck_gain = np.where(smooth_voice > 0.012, 0.14, 0.46).astype(np.float32)
    win_duck = int(SAMPLE_RATE * 0.25)
    duck_gain = np.convolve(duck_gain, np.ones(win_duck, dtype=np.float32) / win_duck, mode="same")
    fade_in_len = int(SAMPLE_RATE * 0.5)
    fade_out_len = int(SAMPLE_RATE * 0.8)
    duck_gain[:fade_in_len] *= np.linspace(0.0, 1.0, fade_in_len)
    duck_gain[-fade_out_len:] *= np.linspace(1.0, 0.0, fade_out_len)

    music_ducked = music_data * duck_gain[:, None]

    # Mezcla Maestra Final con limitador suave
    final_mix = voice_master + sfx_master * 0.75 + music_ducked
    peak = np.max(np.abs(final_mix))
    if peak > 0.96:
        final_mix = final_mix * (0.96 / peak)

    master_wav_path = os.path.join(TOOLS_DIR, "audio_animacion_master_60fps.wav")
    save_wav_stereo(master_wav_path, final_mix)
    print(f" -> Audio Maestro Estéreo guardado en: {master_wav_path}")

    timeline_json_path = os.path.join(TOOLS_DIR, "timeline_animacion_60fps.json")
    with open(timeline_json_path, "w", encoding="utf-8") as f:
        json.dump({
            "fps": FPS,
            "sample_rate": SAMPLE_RATE,
            "total_duration": total_duration,
            "total_frames": total_frames_60fps,
            "master_wav": master_wav_path,
            "scenes": scenes_meta,
            "frames": frame_envelopes
        }, f, ensure_ascii=False, indent=2)
    print(f" -> Telemetría Lip-Sync 60fps guardada en: {timeline_json_path}")
    print("=== PRODUCCIÓN DE AUDIO COMPLETADA EXITOSAMENTE ===")


if __name__ == "__main__":
    asyncio.run(main())
