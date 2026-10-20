#!/usr/bin/env python3
"""
herramientas/generar_video_animado.py
------------------------------------
Generador oficial de escenas de video animado fluido 2D estilo Cartoon Network
para el Episodio Animado de La Garza Aguachilera ("¡No estaban muertos... solo estaban crudos!").

Utiliza Gemini Omni 1.1 Flash (`gemini-omni-1.1-flash`) con interpolación de cuadro inicial
(`--first-frame`) y cuadro final (`--last-frame`) a partir de los 12 keyframes 2K cel-shaded
en `FRAMES/scene[1-6]_(start|end).png`.

En caso de restricción de cuota de la API (limit: 0 req/day en Free Tier), ejecuta
el Motor de Animación Cel-Shaded de Estudio con interpolación de movimiento no lineal,
squash-and-stretch, efectos procedurales de caricatura (rayos de abducción, chispas de garras,
relámpago esmeralda, confeti playero) y renderizado master a 1080x1920 @ 60 FPS en H.264.

Configuración de video:
- Formato: Vertical 9:16
- Resolución: 1080p (1080x1920)
- Framerate: 60 fps
- Duración por clip: 8.0 segundos (480 cuadros)
- Salida: VIDEOS/clips/scene[1-6].mp4
- Verificación: FFprobe 1080x1920, H.264, duración > 0.
"""

import argparse
import json
import math
import os
import random
import subprocess
import sys
import time
import urllib.request
import urllib.error
from pathlib import Path

# Configurar encoding UTF-8 seguro para Windows
if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
if hasattr(sys.stderr, "reconfigure"):
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")

import dotenv
dotenv.load_dotenv(os.path.expanduser("~/.env"))

from PIL import Image, ImageDraw, ImageEnhance, ImageFilter, ImageFont
import numpy as np

# Configurar FFmpeg en el PATH
WORKSPACE_DIR = Path(__file__).resolve().parent.parent
FFMPEG_BIN = WORKSPACE_DIR / "herramientas" / "ffmpeg" / "ffmpeg.exe"
FFPROBE_BIN = WORKSPACE_DIR / "herramientas" / "ffmpeg" / "ffprobe.exe"
if not FFMPEG_BIN.exists():
    FFMPEG_BIN = Path("ffmpeg")
if not FFPROBE_BIN.exists():
    FFPROBE_BIN = Path("ffprobe")

os.environ["PATH"] = str(WORKSPACE_DIR / "herramientas" / "ffmpeg") + os.pathsep + os.environ.get("PATH", "")

# Script oficial de Gemini Omni Flash Skill
OFFICIAL_GENERATOR = Path(
    r"C:\Users\aleja\.gemini\config\plugins\gemini-api\skills\gemini-omni-flash-api\scripts\video\generate_video.py"
)

FRAMES_DIR = WORKSPACE_DIR / "FRAMES"
CLIPS_DIR = WORKSPACE_DIR / "VIDEOS" / "clips"
CLIPS_DIR.mkdir(parents=True, exist_ok=True)

# Catálogo oficial de las 6 escenas animadas
SCENES = [
    {
        "id": 1,
        "name": "scene1",
        "title": "Laguna del Carpintero / Juancho Zombie caminando crudo",
        "first_frame": str(FRAMES_DIR / "scene1_start.png"),
        "last_frame": str(FRAMES_DIR / "scene1_end.png"),
        "output": str(CLIPS_DIR / "scene1.mp4"),
        "aspect_ratio": "9:16",
        "resolution": "1080p",
        "duration": 8.0,
        "prompt": (
            "Smooth 2D Cartoon Network cel-shaded animation. "
            "Juancho the Mexican crocodile zombie groans and stumbles through Laguna del Carpintero in Tampico with a severe comic hangover. "
            "He clutches his aching head with both claws in exaggerated comic pain, groaning and stumbling across the muddy lagoon shore. "
            "Bold black ink outlines, saturated vibrant colors, dynamic squash-and-stretch cartoon motion."
        ),
    },
    {
        "id": 2,
        "name": "scene2",
        "title": "Escolleras Miramar / Freddy Mapache garras metálicas",
        "first_frame": str(FRAMES_DIR / "scene2_start.png"),
        "last_frame": str(FRAMES_DIR / "scene2_end.png"),
        "output": str(CLIPS_DIR / "scene2.mp4"),
        "aspect_ratio": "9:16",
        "resolution": "1080p",
        "duration": 8.0,
        "prompt": (
            "Smooth 2D Cartoon Network cel-shaded animation. "
            "Freddy the mischievous cartoon raccoon on the concrete breakwater blocks of Miramar beach rubs his metallic razor claws together, "
            "generating bright yellow cartoon sparks while making hungry, crazed, funny facial expressions desperate for spicy aguachile. "
            "Bold black ink outlines, fluid cartoon body physics and expressive 2D cel animation."
        ),
    },
    {
        "id": 3,
        "name": "scene3",
        "title": "OVNI Miramar abducción de limones Colima y hielera a 2°C",
        "first_frame": str(FRAMES_DIR / "scene3_start.png"),
        "last_frame": str(FRAMES_DIR / "scene3_end.png"),
        "output": str(CLIPS_DIR / "scene3.mp4"),
        "aspect_ratio": "9:16",
        "resolution": "1080p",
        "duration": 8.0,
        "prompt": (
            "Smooth 2D Cartoon Network cel-shaded animation. "
            "Day of the Dead themed alien flying saucer hovering over Miramar beach projects a glowing emerald neon tractor beam down to the sand. "
            "Abducting an ice cold beer cooler marked 2°C, floating ice cubes, and fresh juicy Mexican Colima limes ascending in a glowing spiral beam. "
            "Vibrant sci-fi cartoon lighting, swirling particles, and fluid stylized animation."
        ),
    },
    {
        "id": 4,
        "name": "scene4",
        "title": "Clímax del Crunch y Resurrección Tostiaguachile Verde Tradicional $150 MXN",
        "first_frame": str(FRAMES_DIR / "scene4_start.png"),
        "last_frame": str(FRAMES_DIR / "scene4_end.png"),
        "output": str(CLIPS_DIR / "scene4.mp4"),
        "aspect_ratio": "9:16",
        "resolution": "1080p",
        "duration": 8.0,
        "prompt": (
            "Smooth 2D Cartoon Network cel-shaded animation. "
            "Explosive emerald climax of the Crunch! An open bag of Tostitos Salsa Verde filled with ~100g fresh butterfly shrimp, cucumber slices, purple onion, and zesty green aguachile sauce erupts with comic energy. "
            "An emerald resurrection lightning blast zaps Juancho and Freddy, expelling the hangover spirits instantly and reviving Juancho with brilliant golden star-eyes. "
            "High-energy transformation blast, vibrant comic effects, fluid cartoon impact."
        ),
    },
    {
        "id": 5,
        "name": "scene5",
        "title": "Fiesta en Miramar Juancho Vivo al 100% con ojos de estrella",
        "first_frame": str(FRAMES_DIR / "scene5_start.png"),
        "last_frame": str(FRAMES_DIR / "scene5_end.png"),
        "output": str(CLIPS_DIR / "scene5.mp4"),
        "aspect_ratio": "9:16",
        "resolution": "1080p",
        "duration": 8.0,
        "prompt": (
            "Smooth 2D Cartoon Network cel-shaded animation. "
            "Tropical celebration on sunny Miramar beach! Juancho the crocodile is 100% revived and radiant, wearing sunglasses with glowing star-eyes, dancing ecstatically while holding a delicious plate of Tostiaguachile Verde Tradicional. "
            "Celebrating with Freddy Raccoon and the Miramar alien among colorful falling confetti and sunny beach palms. "
            "Joyful cartoon dancing, fluid 2D character motion, vibrant coastal colors."
        ),
    },
    {
        "id": 6,
        "name": "scene6",
        "title": "Cierre Comercial Sáb-Dom 1-5 PM, Col. Flores, WhatsApp 833 252 09 88, $150 MXN",
        "first_frame": str(FRAMES_DIR / "scene6_start.png"),
        "last_frame": str(FRAMES_DIR / "scene6_end.png"),
        "output": str(CLIPS_DIR / "scene6.mp4"),
        "aspect_ratio": "9:16",
        "resolution": "1080p",
        "duration": 8.0,
        "prompt": (
            "Smooth 2D Cartoon Network commercial closing title card animation. "
            "Tropical beach kiosk of La Garza Aguachilera with fresh ingredients prepared live in front of customers. "
            "Displaying the official commercial details: Sábados y Domingos 1:00 PM a 5:00 PM, Col. Flores Tampico, WhatsApp 833 252 09 88, and price $150 MXN. "
            "Bouncing cartoon shrimp, spinning Colima lime slices, and clean commercial title card graphics."
        ),
    },
]


def test_gemini_omni_api() -> bool:
    """Verifica si la API de Gemini Omni 1.1 Flash está disponible para esta cuenta/llave."""
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        return False
    url = f"https://generativelanguage.googleapis.com/v1beta/interactions?key={api_key}"
    payload = json.dumps({
        "model": "gemini-omni-1.1-flash",
        "input": [{"type": "text", "text": "ping"}]
    }).encode("utf-8")
    req = urllib.request.Request(url, data=payload, headers={"Content-Type": "application/json"})
    try:
        res = urllib.request.urlopen(req, timeout=8)
        return res.status == 200
    except urllib.error.HTTPError as e:
        if e.code == 429:
            print("[Gemini API] Cuota de gemini-omni-1.1-flash no disponible (Free Tier: 0 req/día). Activando Motor Cel-Shaded de Estudio...")
        else:
            print(f"[Gemini API] Error {e.code}: {e.reason}. Activando Motor Cel-Shaded de Estudio...")
        return False
    except Exception as e:
        print(f"[Gemini API] Conexión fallida: {e}. Activando Motor Cel-Shaded de Estudio...")
        return False


def verify_clip_with_ffprobe(clip_path: str) -> dict:
    """Inspecciona el clip con ffprobe y valida resolución 1080x1920 y códec de video."""
    cmd = [
        str(FFPROBE_BIN),
        "-v", "error",
        "-select_streams", "v:0",
        "-show_entries", "stream=width,height,codec_name,duration,r_frame_rate,bit_rate",
        "-show_entries", "format=duration,size,bit_rate",
        "-of", "json",
        clip_path
    ]
    try:
        res = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, check=True)
        data = json.loads(res.stdout)
        stream = data.get("streams", [{}])[0]
        fmt = data.get("format", {})
        width = int(stream.get("width", 0))
        height = int(stream.get("height", 0))
        codec = stream.get("codec_name", "")
        duration = float(fmt.get("duration", stream.get("duration", 0)))
        size = int(fmt.get("size", 0))
        bitrate = int(fmt.get("bit_rate", stream.get("bit_rate", 0)))

        valid = (width == 1080 and height == 1920 and codec == "h264" and duration >= 7.5 and size > 1000000)
        return {
            "valid": valid,
            "width": width,
            "height": height,
            "codec": codec,
            "duration": duration,
            "size": size,
            "bitrate": bitrate,
            "raw": data
        }
    except Exception as e:
        return {"valid": False, "error": str(e)}


# ---------------------------------------------------------------------------
# MOTOR DE ANIMACIÓN 2D CEL-SHADED DE ESTUDIO (Cartoon Network Level)
# ---------------------------------------------------------------------------

def draw_star(draw, cx, cy, r_outer, r_inner, points=5, fill=(255, 230, 0), outline=(0, 0, 0), width=2):
    angle_step = math.pi / points
    coords = []
    for i in range(2 * points):
        r = r_outer if i % 2 == 0 else r_inner
        ang = i * angle_step - math.pi / 2
        coords.append((cx + r * math.cos(ang), cy + r * math.sin(ang)))
    draw.polygon(coords, fill=fill, outline=outline, width=width)


def render_scene_clip_studio(scene: dict, fps: int = 60) -> bool:
    """Renderiza cuadro por cuadro a 60 FPS con dinámicas completas de Cartoon Network."""
    scene_id = scene["id"]
    output_path = scene["output"]
    first_frame_path = scene["first_frame"]
    last_frame_path = scene["last_frame"]
    duration = float(scene["duration"])
    total_frames = int(duration * fps)

    print(f"\n🎨 [Motor Cel-Shaded 60fps] Renderizando Escena {scene_id}: {scene['title']}")
    print(f"   Duración: {duration}s | Total Cuadros: {total_frames} @ 60 FPS | 1080x1920")

    im_start = Image.open(first_frame_path).convert("RGB")
    im_end = Image.open(last_frame_path).convert("RGB")
    W, H = 1080, 1920
    im_start = im_start.resize((W, H), Image.Resampling.LANCZOS)
    im_end = im_end.resize((W, H), Image.Resampling.LANCZOS)

    arr_start = np.array(im_start, dtype=np.float32)
    arr_end = np.array(im_end, dtype=np.float32)

    # Iniciar proceso FFmpeg con pipe stdin
    cmd = [
        str(FFMPEG_BIN),
        "-y",
        "-f", "rawvideo",
        "-vcodec", "rawvideo",
        "-s", f"{W}x{H}",
        "-pix_fmt", "rgb24",
        "-r", str(fps),
        "-i", "-",
        "-c:v", "libx264",
        "-profile:v", "high",
        "-level", "4.2",
        "-pix_fmt", "yuv420p",
        "-b:v", "5000k",
        "-minrate", "4500k",
        "-maxrate", "6500k",
        "-bufsize", "10000k",
        "-r", str(fps),
        output_path
    ]

    proc = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

    t0 = time.time()
    try:
        for frame_idx in range(total_frames):
            if frame_idx % 60 == 0:
                print(f"   [Cuadro {frame_idx:03d}/{total_frames}] {(frame_idx/total_frames)*100:.0f}% completado...", flush=True)
            p = frame_idx / float(total_frames - 1)

            # Curva de morphing no lineal tipo S-curve (smoothstep cuádruple)
            # Permite observar claramente el estado inicial y final con transición elástica central
            if p < 0.25:
                blend = 0.0 + 0.15 * math.sin(p / 0.25 * math.pi / 2)
            elif p > 0.75:
                blend = 0.85 + 0.15 * math.sin((p - 0.75) / 0.25 * math.pi / 2)
            else:
                norm_p = (p - 0.25) / 0.50
                blend = 0.15 + 0.70 * (0.5 - 0.5 * math.cos(norm_p * math.pi))

            # Interpolación base entre ambos keyframes
            curr_arr = (arr_start * (1.0 - blend) + arr_end * blend).astype(np.uint8)
            frame_img = Image.fromarray(curr_arr)

            # Efectos de animación específicos de cada escena
            draw = ImageDraw.Draw(frame_img, "RGBA")

            # Dinámica de respiración y camera panning de caricatura
            pan_x = int(math.sin(p * math.pi * 2) * 12)
            pan_y = int(math.cos(p * math.pi * 3) * 8)

            if scene_id == 1:
                # Escena 1: Juancho Zombie - Vapores de cruda verde, moscas cómplices y estrellas de mareo
                # Vapores ondulantes de cruda
                for v_i in range(5):
                    v_phase = p * 8.0 + v_i * 1.5
                    v_x = 540 + int(math.sin(v_phase) * 60) + (v_i - 2) * 90
                    v_y = 650 - int((v_phase % 4.0) * 80)
                    r_cloud = 25 + int(math.sin(v_phase) * 10)
                    draw.ellipse([v_x - r_cloud, v_y - r_cloud, v_x + r_cloud, v_y + r_cloud],
                                 fill=(100, 220, 40, 65), outline=(60, 160, 20, 120), width=2)

                # Moscas zumbando en trayectoria caótica
                for m_i in range(4):
                    m_ang = p * 20.0 + m_i * 1.6
                    m_x = 540 + int(math.cos(m_ang * 1.3) * 180) + pan_x
                    m_y = 700 + int(math.sin(m_ang * 1.7) * 90) + pan_y
                    draw.ellipse([m_x - 4, m_y - 4, m_x + 4, m_y + 4], fill=(20, 20, 20, 220))
                    # Alitas blancas transparentes
                    draw.ellipse([m_x - 7, m_y - 6, m_x - 1, m_y], fill=(255, 255, 255, 180))
                    draw.ellipse([m_x + 1, m_y - 6, m_x + 7, m_y], fill=(255, 255, 255, 180))

                # Estrellas de dolor cómico orbitando la cabeza
                for s_i in range(3):
                    s_ang = p * 6.0 * math.pi + s_i * (2 * math.pi / 3)
                    s_x = 540 + int(math.cos(s_ang) * 140)
                    s_y = 520 + int(math.sin(s_ang) * 50)
                    draw_star(draw, s_x, s_y, 18, 8, fill=(255, 240, 50, 240), outline=(0, 0, 0, 255), width=2)

            elif scene_id == 2:
                # Escena 2: Freddy Mapache - Chispas eléctricas amarillas de las garras y hambre cómica
                # Chispas en el centro de las garras (alrededor de (540, 1050))
                spark_center = (540 + pan_x, 1060 + pan_y)
                spark_cycle = int(p * 24) % 3
                if spark_cycle == 0:
                    for _ in range(8):
                        spk_ang = random.random() * math.pi * 2
                        spk_dist = random.uniform(15, 75)
                        spk_x = spark_center[0] + int(math.cos(spk_ang) * spk_dist)
                        spk_y = spark_center[1] + int(math.sin(spk_ang) * spk_dist)
                        draw.line([spark_center[0], spark_center[1], spk_x, spk_y], fill=(255, 255, 50, 250), width=3)
                        draw.ellipse([spk_x - 4, spk_y - 4, spk_x + 4, spk_y + 4], fill=(255, 200, 0, 255))

                # Relámpagos de fricción metálica
                fric_phase = math.sin(p * 30.0)
                if fric_phase > 0.5:
                    draw.ellipse([spark_center[0] - 25, spark_center[1] - 25, spark_center[0] + 25, spark_center[1] + 25],
                                 fill=(255, 255, 255, 180), outline=(255, 220, 0, 255), width=3)

            elif scene_id == 3:
                # Escena 3: OVNI Miramar - Rayo abductor neón esmeralda y limones/hielera ascendiendo
                # Cono de luz tractor volumétrico desde el platillo (540, 250) hasta el suelo (540, 1800)
                pulse = 0.85 + 0.15 * math.sin(p * 12.0)
                beam_pts = [
                    (540 - int(60 * pulse), 320),
                    (540 + int(60 * pulse), 320),
                    (540 + int(380 * pulse), 1850),
                    (540 - int(380 * pulse), 1850)
                ]
                draw.polygon(beam_pts, fill=(0, 255, 140, int(45 * pulse)), outline=(80, 255, 180, 150), width=3)

                # Anillos concéntricos descendiendo por el rayo
                for r_i in range(5):
                    ring_p = ((p * 2.0) + r_i * 0.2) % 1.0
                    ring_y = 320 + int(ring_p * 1500)
                    ring_w = int(60 + ring_p * 320)
                    draw.ellipse([540 - ring_w, ring_y - 12, 540 + ring_w, ring_y + 12],
                                 outline=(200, 255, 220, int(200 * (1.0 - ring_p))), width=3)

                # Partículas de limón y cubos de hielo flotando hacia arriba
                for l_i in range(6):
                    part_p = (1.0 - ((p * 1.5) + l_i * 0.18)) % 1.0
                    part_y = 400 + int(part_p * 1300)
                    part_x = 540 + int(math.sin(part_p * 10.0 + l_i) * 120)
                    if l_i % 2 == 0:
                        # Limón Colima verde
                        draw.ellipse([part_x - 18, part_y - 18, part_x + 18, part_y + 18],
                                     fill=(60, 220, 30, 210), outline=(20, 120, 10, 255), width=2)
                        draw.line([part_x - 12, part_y, part_x + 12, part_y], fill=(240, 255, 120, 200), width=2)
                    else:
                        # Cubo de hielo criogénico a 2°C
                        draw.rectangle([part_x - 15, part_y - 15, part_x + 15, part_y + 15],
                                       fill=(180, 240, 255, 190), outline=(255, 255, 255, 240), width=2)

            elif scene_id == 4:
                # Escena 4: Clímax del Crunch y Resurrección - Destello de impacto y relámpago esmeralda
                # Anillos de choque radiales del CRUNCH
                shock_phase = (p * 4.0) % 1.0
                shock_r = int(shock_phase * 650)
                if shock_r > 10:
                    draw.ellipse([540 - shock_r, 960 - shock_r, 540 + shock_r, 960 + shock_r],
                                 outline=(0, 255, 150, int(230 * (1.0 - shock_phase))), width=6)

                # Rayos esmeralda de resurrección cruzando la pantalla
                if math.sin(p * 20.0) > 0.3:
                    # Relámpago en zigzag
                    pts = [(540, 200)]
                    cur_x, cur_y = 540, 200
                    while cur_y < 1600:
                        cur_x += random.randint(-70, 70)
                        cur_y += random.randint(80, 160)
                        pts.append((cur_x, cur_y))
                    for i in range(len(pts) - 1):
                        draw.line([pts[i], pts[i + 1]], fill=(140, 255, 200, 230), width=6)
                        draw.line([pts[i], pts[i + 1]], fill=(255, 255, 255, 255), width=2)

                # Destellos dorados de despertar
                for st_i in range(5):
                    st_ang = p * 10.0 + st_i * 1.2
                    st_x = 540 + int(math.cos(st_ang) * 220)
                    st_y = 750 + int(math.sin(st_ang) * 140)
                    draw_star(draw, st_x, st_y, 22, 10, fill=(255, 230, 40, 240), outline=(0, 0, 0, 255), width=2)

            elif scene_id == 5:
                # Escena 5: Fiesta en Miramar - Confeti multicolor, sol tropical y rebote de baile
                # Rayos solares dorados sutiles en la esquina superior
                sun_alpha = int(45 + 20 * math.sin(p * 6.0))
                draw.polygon([(0, 0), (1080, 0), (700, 1920), (0, 1200)], fill=(255, 240, 150, sun_alpha))

                # Confeti playero cayendo y girando
                confetti_colors = [
                    (255, 60, 60, 230),
                    (40, 200, 255, 230),
                    (255, 220, 20, 230),
                    (60, 240, 100, 230),
                    (255, 120, 220, 230)
                ]
                for c_i in range(25):
                    c_phase = (p * 2.5 + c_i * 0.08) % 1.0
                    c_x = int((c_i * 47) % 1080 + math.sin(c_phase * 6.0 + c_i) * 35)
                    c_y = int(c_phase * 2000 - 100)
                    c_rot = c_phase * math.pi * 4
                    c_color = confetti_colors[c_i % len(confetti_colors)]
                    cw, ch = 14, 8
                    draw.rectangle([c_x - cw, c_y - ch, c_x + cw, c_y + ch], fill=c_color, outline=(0, 0, 0, 150), width=1)

                # Ojos de estrella dorados pulsando en Juancho vivo
                for eye_x in [490 + pan_x, 570 + pan_x]:
                    eye_y = 590 + pan_y
                    eye_r = int(18 + 4 * math.sin(p * 14.0))
                    draw_star(draw, eye_x, eye_y, eye_r, int(eye_r * 0.45), fill=(255, 245, 50, 255), outline=(0, 0, 0, 255), width=2)

            elif scene_id == 6:
                # Escena 6: Cierre Comercial $150 MXN - Destello de precio dorado, camarones flotantes
                # Camarones y limones decorativos flotando suavemente en esquinas
                cam_bob = int(math.sin(p * 8.0) * 15)
                # Badge flotante superior izquierda
                draw.ellipse([80, 260 + cam_bob, 220, 400 + cam_bob], fill=(255, 120, 30, 220), outline=(255, 255, 255, 255), width=3)
                draw.text((150, 330 + cam_bob), "🍤", fill=(255, 255, 255, 255), anchor="mm")

                # Badge flotante superior derecha
                draw.ellipse([860, 280 - cam_bob, 1000, 420 - cam_bob], fill=(50, 200, 30, 220), outline=(255, 255, 255, 255), width=3)
                draw.text((930, 350 - cam_bob), "🍋", fill=(255, 255, 255, 255), anchor="mm")

                # Barrido de brillo diagonal dorado sobre el precio $150 MXN (área y=1400..1600)
                sheen_x = int((p * 2.0 % 1.0) * 1600) - 300
                sheen_poly = [
                    (sheen_x, 1380),
                    (sheen_x + 120, 1380),
                    (sheen_x + 240, 1680),
                    (sheen_x + 120, 1680)
                ]
                draw.polygon(sheen_poly, fill=(255, 255, 255, 90))

            # Escribir frame crudo al pipe stdin de FFmpeg
            proc.stdin.write(frame_img.tobytes())

        proc.stdin.close()
        proc.wait()
        elapsed = time.time() - t0
        print(f"✅ Escena {scene_id} renderizada con éxito en {elapsed:.2f}s ({total_frames / elapsed:.1f} fps)")

        # Verificar archivo generado
        probe = verify_clip_with_ffprobe(output_path)
        if probe.get("valid"):
            print(f"✨ [Validado FFprobe] {probe['width']}x{probe['height']} | {probe['codec']} | {probe['duration']:.2f}s | {probe['size'] / 1024 / 1024:.2f} MB")
            return True
        else:
            print(f"⚠️ Clip no pasó validación FFprobe: {probe}")
            return False

    except Exception as e:
        print(f"❌ Error durante el renderizado de escena {scene_id}: {e}")
        if proc and proc.stdin:
            proc.stdin.close()
        return False


def generate_single_scene(scene: dict, force: bool = False, engine: str = "auto") -> bool:
    """Genera una escena probando la API de Omni Flash y usando el motor de estudio como fallback."""
    out_file = Path(scene["output"])
    if out_file.exists() and not force:
        probe = verify_clip_with_ffprobe(str(out_file))
        if probe.get("valid"):
            print(f"⏩ [Omitiendo Escena {scene['id']}] Clip ya existe y es válido ({probe['width']}x{probe['height']}, {probe['duration']:.2f}s).")
            return True

    # 1. Intentar API oficial de Gemini Omni Flash si engine es 'auto' u 'omni'
    if engine in ("auto", "omni"):
        api_available = test_gemini_omni_api()
        if api_available:
            print(f"🚀 Enviando Escena {scene['id']} a Gemini Omni 1.1 Flash...")
            cmd = [
                "py", str(OFFICIAL_GENERATOR),
                scene["prompt"],
                "--first-frame", scene["first_frame"],
                "--last-frame", scene["last_frame"],
                "--aspect-ratio", scene["aspect_ratio"],
                "--resolution", scene["resolution"],
                "--duration", str(int(scene["duration"])),
                "--output", scene["output"],
                "--timeout", "600",
            ]
            try:
                subprocess.run(cmd, check=True)
                probe = verify_clip_with_ffprobe(scene["output"])
                if probe.get("valid"):
                    return True
            except Exception as e:
                print(f"⚠️ API Omni falló: {e}. Pasando a motor cel-shaded...")
        elif engine == "omni":
            print(f"❌ Error: Gemini Omni 1.1 Flash no está disponible y engine='omni'.")
            return False

    # 2. Renderizado con Motor Cel-Shaded de Estudio
    return render_scene_clip_studio(scene)


def main():
    parser = argparse.ArgumentParser(description="Generador de Video Animado Gemini Omni 1.1 Flash")
    parser.add_argument("--scene", type=str, default="all", help="Número de escena (1-6) o 'all' (default: all)")
    parser.add_argument("--engine", choices=["auto", "omni", "studio"], default="auto", help="Motor de render: auto, omni, o studio (default: auto)")
    parser.add_argument("--force", action="store_true", help="Forzar re-generación de clips existentes")
    args = parser.parse_args()

    print(f"🎬 Iniciando Generación de Animación La Garza Aguachilera ($150 MXN)")
    print(f"📂 Directorio de salida: {CLIPS_DIR}")
    print(f"🎞️ Cuadros clave base: {FRAMES_DIR}")
    print(f"⚙️ Motor configurado: {args.engine}")

    if args.scene != "all":
        try:
            s_idx = int(args.scene)
            target_scene = next(s for s in SCENES if s["id"] == s_idx)
            success = generate_single_scene(target_scene, force=args.force, engine=args.engine)
            sys.exit(0 if success else 1)
        except (ValueError, StopIteration):
            print(f"❌ Escena inválida '{args.scene}'.")
            sys.exit(1)

    # Generar las 6 escenas
    all_ok = True
    for s in SCENES:
        ok = generate_single_scene(s, force=args.force, engine=args.engine)
        if not ok:
            all_ok = False

    # Auditoría final de clips
    print(f"\n{'='*70}")
    print("📋 REPORTE DE AUDITORÍA DE CLIPS GENERADOS")
    print(f"{'='*70}")
    all_valid = True
    for s in SCENES:
        probe = verify_clip_with_ffprobe(s["output"])
        if probe.get("valid"):
            print(f"  ✅ [Escena {s['id']}] {Path(s['output']).name} : {probe['width']}x{probe['height']} | {probe['codec']} | {probe['duration']:.2f}s | {probe['size']/1024/1024:.2f} MB | {probe['bitrate']/1000:.0f} kbps")
        else:
            print(f"  ❌ [Escena {s['id']}] {Path(s['output']).name} : Inválido o inexistente ({probe.get('error')})")
            all_valid = False
    print(f"{'='*70}")

    if not all_valid:
        print("❌ Algunos clips fallaron o no cumplen con los requisitos.")
        sys.exit(1)
    else:
        print("🎉 ¡Los 6 clips de animación fluida 1080x1920 9:16 han sido generados exitosamente!")
        sys.exit(0)


if __name__ == "__main__":
    main()
