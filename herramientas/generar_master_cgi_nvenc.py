# -*- coding: utf-8 -*-
"""
GENERADOR DEL MASTER VISUAL 3D CGI (60 FPS, 1080x1920) CON GPU NVENC
Project: La Garza Aguachilera — Milestone 2 & 4
Compone los 1440 frames a 60 fps (24.0s) a partir de los 4 plates 3D CGI
en FRAMES/aaa_stories/ con movimientos de cámara cinemática 3D (parallax, zoom, float)
y los codifica con hardware NVENC en la NVIDIA GeForce RTX 4060.
"""

import os
import sys
import math
import time
import subprocess
from pathlib import Path
from PIL import Image, ImageEnhance, ImageFilter

if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8')
if hasattr(sys.stderr, 'reconfigure'):
    sys.stderr.reconfigure(encoding='utf-8')

PROJECT_ROOT = Path(r"d:\AG\la garza aguachilera")
FFMPEG_BIN = PROJECT_ROOT / "herramientas" / "ffmpeg" / "ffmpeg.exe"
FFPROBE_BIN = PROJECT_ROOT / "herramientas" / "ffmpeg" / "ffprobe.exe"
PLATES_DIR = PROJECT_ROOT / "FRAMES" / "aaa_stories"
CLIPS_DIR = PROJECT_ROOT / "VIDEOS" / "clips_aaa"
CLIPS_DIR.mkdir(parents=True, exist_ok=True)
MASTER_OUT = CLIPS_DIR / "aaa_master_cgi_24s.mp4"

W_OUT = 1080
H_OUT = 1920
FPS = 60
TOTAL_FRAMES = 1440  # 24.0s @ 60fps
ACT_FRAMES = 360      # 6.0s por acto

# Cargar los 4 plates 3D CGI de alta calidad
PLATES = {
    1: Image.open(PLATES_DIR / "aaa_act1_miramar_ufo.jpg").convert("RGB"),
    2: Image.open(PLATES_DIR / "aaa_act2_garza_chef_splash.jpg").convert("RGB"),
    3: Image.open(PLATES_DIR / "aaa_act3_beach_party_crunch.jpg").convert("RGB"),
    4: Image.open(PLATES_DIR / "aaa_act4_hero_pedestal.jpg").convert("RGB"),
}


def get_act_frame(act_num: int, frame_idx: int) -> Image.Image:
    """Genera un cuadro de 1080x1920 para el acto dado con cámara cinemática 3D."""
    plate = PLATES[act_num]
    pw, ph = plate.size
    p = frame_idx / float(ACT_FRAMES - 1)  # 0.0 a 1.0

    # Curva suave ease-in-out
    smooth = 0.5 - 0.5 * math.cos(math.pi * p)

    # Base crop 9:16 centrado
    base_w = pw
    base_h = int(pw * (16.0 / 9.0))
    if base_h > ph:
        base_h = ph
        base_w = int(ph * (9.0 / 16.0))

    if act_num == 1:
        # Acto 1: Dramatic push-in + floating vertical parallax (tractor beam)
        zoom = 1.00 + 0.08 * smooth
        dx = int(math.sin(p * math.pi) * 6)
        dy = int(math.sin(p * 2.0 * math.pi) * 10)
    elif act_num == 2:
        # Acto 2: Dynamic culinary push-in + splash micro-shake
        zoom = 1.02 + 0.09 * smooth
        dx = int(math.sin(p * 1.5 * math.pi) * 8)
        # Micro-shake en frame 50-70 (impacto salsa)
        shake = 0
        if 45 <= frame_idx <= 75:
            decay = 1.0 - (abs(frame_idx - 60) / 15.0)
            shake = int(math.sin(frame_idx * 1.8) * 8 * decay)
        dy = int(math.sin(p * math.pi) * 6) + shake
    elif act_num == 3:
        # Acto 3: Tracking shot lateral + crunch pulse
        zoom = 1.00 + 0.08 * smooth
        dx = int(math.cos(p * 2.0 * math.pi) * 12)
        dy = int(math.sin(p * 2.0 * math.pi) * 8)
    else:
        # Acto 4: Hero pedestal tilt-up & push
        zoom = 1.00 + 0.07 * smooth
        dx = int(math.sin(p * math.pi) * 5)
        dy = int(-12 * smooth)  # leve drift vertical para centrar el plato

    # Calcular dimensiones recortadas según zoom
    crop_w = max(10, int(base_w / zoom))
    crop_h = max(10, int(base_h / zoom))

    # Centro de la imagen
    cx = (pw // 2) + dx
    cy = (ph // 2) + dy

    # Coordenadas de recorte asegurando no salirse de límites
    x1 = max(0, min(pw - crop_w, cx - crop_w // 2))
    y1 = max(0, min(ph - crop_h, cy - crop_h // 2))
    x2 = x1 + crop_w
    y2 = y1 + crop_h

    cropped = plate.crop((x1, y1, x2, y2))
    frame = cropped.resize((W_OUT, H_OUT), Image.Resampling.BICUBIC)

    # Realce sutil de contraste y saturación para acabado cinematográfico AAA
    enh_c = ImageEnhance.Contrast(frame)
    frame = enh_c.enhance(1.04)
    enh_s = ImageEnhance.Color(frame)
    frame = enh_s.enhance(1.06)

    return frame


def render_all_frames_to_nvenc():
    print("=" * 75)
    print(" [INFO] RENDERIZANDO MASTER VISUAL AAA 3D CGI (1080x1920 @ 60 FPS)")
    print(f"    Destino: {MASTER_OUT}")
    print(f"    Encoder: h264_nvenc (NVIDIA GeForce RTX 4060)")
    print("=" * 75)

    cmd = [
        str(FFMPEG_BIN),
        "-y",
        "-f", "rawvideo",
        "-vcodec", "rawvideo",
        "-s", f"{W_OUT}x{H_OUT}",
        "-pix_fmt", "rgb24",
        "-r", str(FPS),
        "-i", "-",
        "-c:v", "h264_nvenc",
        "-profile:v", "high",
        "-preset", "p4",
        "-tune", "hq",
        "-b:v", "6000k",
        "-maxrate", "8000k",
        "-bufsize", "12000k",
        "-pix_fmt", "yuv420p",
        "-r", str(FPS),
        str(MASTER_OUT)
    ]

    log_path = PROJECT_ROOT / "herramientas" / "ffmpeg_nvenc.log"
    f_log = open(log_path, "w", encoding="utf-8", errors="replace")
    proc = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=subprocess.DEVNULL, stderr=f_log)

    t0 = time.time()
    transition_len = 12  # frames para cross-dissolve suave entre actos

    try:
        for f in range(TOTAL_FRAMES):
            act_num = (f // ACT_FRAMES) + 1
            frame_in_act = f % ACT_FRAMES

            frame_img = get_act_frame(act_num, frame_in_act)

            # Transición suave (cross-dissolve) entre actos
            if frame_in_act >= (ACT_FRAMES - transition_len) and act_num < 4:
                next_act = act_num + 1
                next_img = get_act_frame(next_act, 0)
                alpha = (frame_in_act - (ACT_FRAMES - transition_len) + 1) / float(transition_len)
                frame_img = Image.blend(frame_img, next_img, alpha)

            proc.stdin.write(frame_img.tobytes())

            if f % 120 == 0 or f == TOTAL_FRAMES - 1:
                elapsed = time.time() - t0
                fps_speed = (f + 1) / elapsed if elapsed > 0 else 0
                pct = ((f + 1) / TOTAL_FRAMES) * 100
                print(f"   Frame {f+1:04d}/{TOTAL_FRAMES} ({pct:.1f}%) | Acto {act_num}/4 | {fps_speed:.1f} fps...", flush=True)

        proc.stdin.close()
        proc.wait()
        f_log.close()

        if proc.returncode != 0:
            err_content = open(log_path, "r", encoding="utf-8", errors="replace").read()
            raise RuntimeError(f"FFmpeg error:\n{err_content}")

    except Exception as e:
        if proc and proc.stdin:
            proc.stdin.close()
        proc.kill()
        raise e

    elapsed_total = time.time() - t0
    print(f"\n [OK] Renderizado completado en {elapsed_total:.2f}s ({TOTAL_FRAMES / elapsed_total:.1f} fps promedio)!")

    # Verificación de telemetría con ffprobe
    probe_cmd = [
        str(FFPROBE_BIN),
        "-v", "error",
        "-select_streams", "v:0",
        "-show_entries", "stream=width,height,codec_name,profile,r_frame_rate,nb_frames,duration,bit_rate",
        "-of", "json",
        str(MASTER_OUT)
    ]
    res = subprocess.run(probe_cmd, capture_output=True, text=True, check=True)
    import json
    data = json.loads(res.stdout)
    st = data["streams"][0]
    print(f" [TELEMETRÍA FFPROBE] {st['width']}x{st['height']} @ {st['r_frame_rate']} | {st['codec_name']} ({st['profile']}) | Frames: {st.get('nb_frames')} | Duración: {float(st['duration']):.2f}s")
    print("=" * 75)
    return MASTER_OUT


if __name__ == "__main__":
    render_all_frames_to_nvenc()
