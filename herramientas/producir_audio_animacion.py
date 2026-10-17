"""
 ESCUADRÓN DE PRODUCCIÓN AUDIOVISUAL — LA GARZA AGUACHILERA
 Módulo 1: Agente_Voces_y_Prosodia_TTS + Agente_Diseno_Sonoro_y_Mezcla
 
 Genera:
 1. Las 6 pistas vocales diferenciadas en español mexicano (es-MX) con dirección actoral fonética.
 2. Efectos de sonido (SFX) cómicos y gastronómicos sintetizados en estéreo a 44.1 kHz:
    - Gemido/tambor de cruda, Whoosh de transición, Garras metálicas de Freddy (Schwing!),
    - Rayo abductor OVNI de Miramar, Vapor criogénico a 2°C y exprimido de limón,
    - Trueno/destello mágico de resurrección, CRUNCH ASMR de Tostitos Salsa Verde y Campana final.
 3. Mezcla Maestra Estéreo (audio_animacion_master_60fps.wav) con Auto-Ducking dinámico sobre
    Beachfront_Celebration.mp3 para que cada diálogo en español se escuche fuerte, claro y en primer plano.
 4. Archivo de telemetría (timeline_animacion_60fps.json) con la envolvente de amplitud RMS cuadro por cuadro
    a 60.0 fps para sincronización labial (Lip-Sync) exacta en el motor de animación 2D.
"""

import asyncio
import json
import math
import os
import subprocess
import wave
import edge_tts
import numpy as np

BASE_DIR = r"d:\AG\la garza aguachilera"
TOOLS_DIR = os.path.join(BASE_DIR, "herramientas")
AUDIO_DIR = os.path.join(TOOLS_DIR, "audio_animacion")
FFMPEG = os.path.join(TOOLS_DIR, "ffmpeg", "ffmpeg.exe")
MUSIC_PATH = os.path.join(TOOLS_DIR, "Beachfront_Celebration.mp3")

os.makedirs(AUDIO_DIR, exist_ok=True)

SAMPLE_RATE = 44100
FPS = 60

# Casting vocal multi-personaje con ortografía fonética expresiva mexicana/tampiqueña
DIALOGUES = [
    {
        "id": "sc1_juancho_zombie",
        "character": "juancho_zombie",
        "speaker_label": "🐊 JUANCHO EL COCODRILO (MODO CRUDO)",
        "voice": "es-MX-JorgeNeural",
        "rate": "-4%",
        "pitch": "-10Hz",
        "eq_filter": "equalizer=f=160:width_type=h:width=90:g=4.5,equalizer=f=3000:width_type=h:width=900:g=2.0,alimiter=limit=0.95",
        "text": "¡Aaaay mamá!... ¡Noooombre compadre, qué trancazo me puso la fiesta de anoche!... No estoy muerto... ¡ando bien crudo aquí en la Laguna del Carpintero!",
        "subtitle_text": "¡Aaaay mamá! ¡Noooombre compadre, qué trancazo! No estoy muerto... ¡ando bien crudo en la Laguna del Carpintero!",
        "pre_pad": 0.35,
        "post_pad": 0.35
    },
    {
        "id": "sc2_mapache_freddy",
        "character": "mapache_freddy",
        "speaker_label": "🦝 MAPACHE FREDDY (ESCOLLERAS)",
        "voice": "es-MX-JorgeNeural",
        "rate": "+14%",
        "pitch": "+24Hz",
        "eq_filter": "equalizer=f=1100:width_type=h:width=500:g=3.0,equalizer=f=3800:width_type=h:width=1000:g=2.5,alimiter=limit=0.95",
        "text": "¡Pérate tantito Juancho, que yo ando peor!... ¡Ni con estas garras de Freddy alcanzo un camaroncito!... ¡Tráiganme unos Tostitos Salsa Verde que me muero de antojo!",
        "subtitle_text": "¡Pérate tantito Juancho, que yo ando peor! ¡Tráiganme unos Tostitos Salsa Verde que me muero de antojo!",
        "pre_pad": 0.30,
        "post_pad": 0.35
    },
    {
        "id": "sc3_alien_miramar",
        "character": "alien_ovni",
        "speaker_label": "👽 ALIEN DEL OVNI DE MIRAMAR",
        "voice": "es-MX-DaliaNeural",
        "rate": "+8%",
        "pitch": "+18Hz",
        "eq_filter": "aecho=0.8:0.85:35:0.22,equalizer=f=2800:width_type=h:width=900:g=2.5,alimiter=limit=0.95",
        "text": "¡Tsss, tranquilos jaibos crudos!... Desde la base submarina de Miramar les trajimos el antídoto sagrado... ¡Hielera a dos grados y puro limón Colima recién exprimido!",
        "subtitle_text": "¡Tsss, tranquilos jaibos crudos! Desde la base de Miramar trajimos el antídoto a 2°C con limón Colima recién exprimido.",
        "pre_pad": 0.30,
        "post_pad": 0.35
    },
    {
        "id": "sc4_locutora_climax",
        "character": "locutora_climax",
        "speaker_label": "🎙️ LA GARZA AGUACHILERA",
        "voice": "es-MX-DaliaNeural",
        "rate": "+8%",
        "pitch": "+2Hz",
        "eq_filter": "equalizer=f=240:width_type=h:width=120:g=2.5,equalizer=f=3600:width_type=h:width=1000:g=2.0,alimiter=limit=0.95",
        "text": "¡Y PUM, papá! Al primer crujido con cien gramos de camarón mariposa... ¡no estaban muertos, solo andaban crudos! El producto es preparado frente a usted para corroborar su frescura.",
        "subtitle_text": "¡Y PUM, PAPÁ! Al primer CRUNCH con ~100g de camarón mariposa... ¡no estaban muertos, solo andaban crudos! Preparado frente a usted.",
        "pre_pad": 0.40,
        "post_pad": 0.35
    },
    {
        "id": "sc5_juancho_vivo",
        "character": "juancho_vivo",
        "speaker_label": "🐊 JUANCHO RESUCITADO (AL 100%)",
        "voice": "es-MX-JorgeNeural",
        "rate": "+8%",
        "pitch": "-4Hz",
        "eq_filter": "equalizer=f=200:width_type=h:width=100:g=3.0,equalizer=f=3400:width_type=h:width=900:g=2.2,alimiter=limit=0.95",
        "text": "¡Noooombre, qué delicia! ¡Reviví al cien por solo ciento cincuenta pesitos!",
        "subtitle_text": "¡Noooombre, qué delicia! ¡Reviví al 100% por solo $150 MXN!",
        "pre_pad": 0.25,
        "post_pad": 0.30
    },
    {
        "id": "sc6_locutora_cierre",
        "character": "locutora_cierre",
        "speaker_label": "🦅 PEDIDOS WHATSAPP 833 252 09 88",
        "voice": "es-MX-DaliaNeural",
        "rate": "+8%",
        "pitch": "+2Hz",
        "eq_filter": "equalizer=f=240:width_type=h:width=120:g=2.5,equalizer=f=3600:width_type=h:width=1000:g=2.0,alimiter=limit=0.95",
        "text": "¡La Garza Aguachilera! Sábados y domingos en Tampico y Madero. ¡Manda WhatsApp al 833 252 09 88 y pide tu cura ya!",
        "subtitle_text": "¡La Garza Aguachilera! Sábados y domingos en Tampico y Madero. ¡WhatsApp 833 252 09 88!",
        "pre_pad": 0.20,
        "post_pad": 0.85
    }
]


async def synthesize_line(line_cfg):
    mp3_tmp = os.path.join(AUDIO_DIR, f"{line_cfg['id']}.mp3")
    wav_out = os.path.join(AUDIO_DIR, f"{line_cfg['id']}.wav")
    comm = edge_tts.Communicate(
        line_cfg["text"],
        line_cfg["voice"],
        rate=line_cfg["rate"],
        pitch=line_cfg["pitch"]
    )
    await comm.save(mp3_tmp)

    # Convert to 44.1kHz stereo 16-bit PCM WAV and strip leading/trailing dead silence
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
        os.remove(mp3_tmp)
    return wav_out


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
    # Moving bandpass via amplitude modulation + sweep
    sweep = np.sin(2 * np.pi * (180 + 900 * (t / duration)) * t)
    env = np.sin(np.pi * (t / duration)) ** 1.8
    sig = (noise * 0.35 + sweep * 0.45) * env * 0.45
    # Pan left to right
    pan_l = np.linspace(0.9, 0.2, n)
    pan_r = np.linspace(0.2, 0.9, n)
    return np.column_stack([sig * pan_l, sig * pan_r])


def make_sfx_freddy_claws(duration=0.38):
    t = np.linspace(0, duration, int(SAMPLE_RATE * duration), endpoint=False)
    # Metallic high-frequency ring ("Schwing!")
    freqs = [2450, 3720, 5180, 6890]
    sig = np.zeros_like(t)
    for idx, f in enumerate(freqs):
        sig += np.sin(2 * np.pi * (f + idx * 120 * t) * t) * np.exp(-t * (8 + idx * 2))
    noise_scrape = np.random.normal(0, 0.3, len(t)) * np.exp(-t * 18)
    out = (sig * 0.22 + noise_scrape * 0.35) * 0.65
    return np.column_stack([out, out])


def make_sfx_ufo_beam(duration=1.4):
    t = np.linspace(0, duration, int(SAMPLE_RATE * duration), endpoint=False)
    # Sci-fi theremin wobble chord
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
    # Cold steam hiss + bubbly citrus splash
    hiss = np.random.normal(0, 1, n) * np.exp(-t * 4.5) * 0.30
    bubbles = np.sin(2 * np.pi * (900 + 600 * np.sin(2 * np.pi * 28 * t)) * t) * np.exp(-t * 5.0) * 0.25
    sig = hiss + bubbles
    return np.column_stack([sig, sig])


def make_sfx_crunch_asmr(duration=0.55):
    n = int(SAMPLE_RATE * duration)
    t = np.linspace(0, duration, n, endpoint=False)
    # Multi-impulse crisp tortilla chip fracture bursts
    rng = np.random.default_rng(42)
    noise = rng.normal(0, 1, n)
    # High-pass crispness by differencing
    crisp = np.diff(noise, prepend=0)
    crisp = np.diff(crisp, prepend=0)
    crisp = crisp / (np.max(np.abs(crisp)) + 1e-6)
    # 4 distinct jaw-bite micro-impulses for authentic Tostitos crunch
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
    # Magical emerald chord (C5, E5, G5, B5, D6) + thunder impact
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
    print("=== FASE 2.2: GENERANDO CASTING VOCAL EXPRESIVO (es-MX) ===")
    scenes_meta = []
    current_sec = 0.0

    for line in DIALOGUES:
        wav_path = await synthesize_line(line)
        audio_data = load_wav_stereo(wav_path)
        voice_dur = len(audio_data) / SAMPLE_RATE
        scene_dur = round(line["pre_pad"] + voice_dur + line["post_pad"], 3)

        voice_start_sec = round(current_sec + line["pre_pad"], 3)
        voice_end_sec = round(voice_start_sec + voice_dur, 3)
        scene_end_sec = round(current_sec + scene_dur, 3)

        print(f" [OK] {line['id']} ({line['voice']} pitch={line['pitch']} rate={line['rate']}) -> {voice_dur:.2f}s (Escena: {current_sec:.2f}s - {scene_end_sec:.2f}s)")

        scenes_meta.append({
            "id": line["id"],
            "character": line["character"],
            "speaker_label": line["speaker_label"],
            "text": line["text"],
            "subtitle_text": line["subtitle_text"],
            "wav_path": wav_path,
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
        # Normalizar RMS para apertura de mandíbula (0.0 a 1.0)
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

    print("=== FASE 2.4: SINTETIZANDO SFX CÓMICOS Y MEZCLANDO CON AUTO-DUCKING ===")
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
    # Escena 5: Campana de resurrección al 100% ($150 MXN)
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
        os.remove(music_wav_tmp)

    # Auto-Ducking: calcular envolvente suavizada de voz para atenuar la música a 0.14 cuando hablan y subir a 0.52 en pausas/final
    voice_mono_abs = np.max(np.abs(voice_master), axis=1)
    win = int(SAMPLE_RATE * 0.18)
    kernel = np.ones(win, dtype=np.float32) / win
    smooth_voice = np.convolve(voice_mono_abs, kernel, mode="same")
    duck_gain = np.where(smooth_voice > 0.012, 0.14, 0.46).astype(np.float32)
    # Suavizar transiciones de ducking (attack/release de 0.25s)
    win_duck = int(SAMPLE_RATE * 0.25)
    duck_gain = np.convolve(duck_gain, np.ones(win_duck, dtype=np.float32) / win_duck, mode="same")
    # Fade-in inicial y fade-out final de la música
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


if __name__ == "__main__":
    asyncio.run(main())
