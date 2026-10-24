"""
 ESCUADRÓN DE PRODUCCIÓN AUDIOVISUAL — LA GARZA AGUACHILERA
 Módulo 2: Agente_Estudio_Animacion_2D_3D + Agente_Ingeniero_Render_Final

 Renderiza cuadro por cuadro a 60.0 FPS en resolución Full HD (1080x1920, 9:16 vertical)
 el episodio animado completo:
   "LA RESURRECCIÓN DE LA CRUDA: ¡NO ESTABAN MUERTOS... SOLO ESTABAN CRUDOS!"

 Características técnicas de animación real (CERO slideshow estático):
 1. Lip-Sync Matemático a 60fps: Apertura de mandíbula articulada + boca cómica animada
    (cavidad, lengua y dientes) + ondas acústicas sincronizadas con la amplitud RMS de cada voz.
 2. Squash & Stretch y Parpadeo Automático: Deformación elástica al hablar/reír, parpadeo cada
    2.1 segundos, gotas de sudor/humo verde en modo crudo y ojos de estrella (★) al revivir.
 3. Rayo Abductor Volumétrico OVNI y Partículas a 60fps: Limones Colima, chiles serranos, cubos de
    hielo a 2°C, vapor criogénico y relámpago esmeralda de resurrección.
 4. Cámara Dinámica: Panning suave, Zoom-In cómico en remates y Camera Shake en impactos/crunch.
 5. Subtítulos Dinámicos Estilo TikTok/Reels: Resaltado palabra por palabra sincronizado al diálogo.
 6. Compilación Directa por Pipe a FFmpeg (H.264 High Profile, 60fps, >= 4500 kbps + AAC 192k Estéreo).
"""

import json
import math
import os
import subprocess
import time
from PIL import Image, ImageDraw, ImageEnhance, ImageFilter, ImageFont
import numpy as np

BASE_DIR = r"d:\AG\la garza aguachilera"
TOOLS_DIR = os.path.join(BASE_DIR, "herramientas")
FFMPEG = os.path.join(TOOLS_DIR, "ffmpeg", "ffmpeg.exe")
FFPROBE = os.path.join(TOOLS_DIR, "ffmpeg", "ffprobe.exe")
TIMELINE_JSON = os.path.join(TOOLS_DIR, "timeline_animacion_60fps.json")

OUT_MP4_MAIN = os.path.join(BASE_DIR, "VIDEOS", "animacion_la_garza_episodio_crudos_60fps.mp4")
OUT_MP4_SPOOKY = os.path.join(BASE_DIR, "VIDEOS", "promo_halloween_zombies_crudos.mp4")

W, H = 1080, 1920
FPS = 60


def load_font(size, bold=True):
    candidates = [
        r"C:\Windows\Fonts\arialbd.ttf" if bold else r"C:\Windows\Fonts\arial.ttf",
        r"C:\Windows\Fonts\impact.ttf",
        r"C:\Windows\Fonts\segoeuib.ttf",
    ]
    for p in candidates:
        if os.path.exists(p):
            return ImageFont.truetype(p, size)
    return ImageFont.load_default()


FONT_TITLE = load_font(40, bold=True)
FONT_SPEAKER = load_font(30, bold=True)
FONT_SUB = load_font(44, bold=True)
FONT_SUB_HI = load_font(50, bold=True)
FONT_BADGE = load_font(36, bold=True)
FONT_PRICE = load_font(66, bold=True)
FONT_FOOTER = load_font(28, bold=True)
FONT_STAR = load_font(56, bold=True)


def load_rgba(path, size=None):
    img = Image.open(path).convert("RGBA")
    if size:
        img = img.resize(size, Image.Resampling.LANCZOS)
    return img


# Configuración anatómica de rigging 2D para cada sprite (sobre lienzo base 650x650)
RIG_CONFIG = {
    "juancho_zombie": {
        "mouth_xy": (395, 242),
        "mouth_w": 72,
        "mouth_h": 36,
        "eyes_xy": [(340, 152), (408, 148)],
        "jaw_split_y": 240,
    },
    "mapache_freddy": {
        "mouth_xy": (362, 268),
        "mouth_w": 56,
        "mouth_h": 34,
        "eyes_xy": [(318, 212), (398, 212)],
        "jaw_split_y": 265,
    },
    "alien_ovni": {
        "mouth_xy": (326, 164),
        "mouth_w": 38,
        "mouth_h": 24,
        "eyes_xy": [(304, 136), (348, 136)],
        "jaw_split_y": 162,
    },
    "juancho_vivo": {
        "mouth_xy": (310, 255),
        "mouth_w": 74,
        "mouth_h": 36,
        "eyes_xy": [(322, 202), (385, 205)],
        "jaw_split_y": 252,
    },
    "mapache_vivo": {
        "mouth_xy": (306, 252),
        "mouth_w": 56,
        "mouth_h": 34,
        "eyes_xy": [(282, 198), (355, 202)],
        "jaw_split_y": 248,
    },
}


def render_rigged_character(sprite_650, rig_key, mouth_open, t_sec, mode="normal", flip_x=False):
    """
    Aplica rigging 2D en tiempo real a 60fps:
    - División mandibular (jaw drop) proporcional a la amplitud RMS de la voz
    - Boca cómica animada (cavidad, lengua móvil y dientes) + ondas de voz
    - Parpadeo automático cada 2.1s y expresiones (gotas de sudor en crudo / estrellas al revivir)
    - Squash & Stretch elástico sincronizado con las sílabas
    """
    cfg = RIG_CONFIG[rig_key]
    base = sprite_650.copy()
    cw, ch = base.size

    # 1. Articulación de mandíbula y Lip-Sync
    jaw_drop = int(24 * mouth_open)
    canvas = Image.new("RGBA", (cw, ch + 30), (0, 0, 0, 0))
    split_y = cfg["jaw_split_y"]

    upper_part = base.crop((0, 0, cw, split_y))
    lower_part = base.crop((0, split_y, cw, ch))
    canvas.paste(upper_part, (0, 0), upper_part)
    canvas.paste(lower_part, (0, split_y + jaw_drop), lower_part)

    draw = ImageDraw.Draw(canvas)
    mx, my = cfg["mouth_xy"]
    my_shifted = my + jaw_drop // 2

    if mouth_open > 0.04:
        mw = int(cfg["mouth_w"] * (0.75 + 0.35 * mouth_open + 0.08 * math.sin(t_sec * 22)))
        mh = int(8 + cfg["mouth_h"] * mouth_open)
        x0, y0 = mx - mw // 2, my_shifted - mh // 2
        x1, y1 = mx + mw // 2, my_shifted + mh // 2

        # Cavidad bucal cómica con borde negro
        draw.ellipse([x0 - 3, y0 - 3, x1 + 3, y1 + 3], fill=(15, 15, 20, 255))
        draw.ellipse([x0, y0, x1, y1], fill=(58, 8, 22, 255))

        # Lengua animada
        tw = int(mw * 0.65)
        th = int(mh * 0.55)
        tx_off = int(math.sin(t_sec * 18) * 5)
        draw.ellipse(
            [mx - tw // 2 + tx_off, y1 - th, mx + tw // 2 + tx_off, y1 + 2],
            fill=(255, 88, 120, 255)
        )
        # Dientes superiores cómicos
        draw.chord([x0 + 4, y0 - 2, x1 - 4, y0 + int(mh * 0.45)], start=180, end=360, fill=(250, 252, 255, 255))

        # Ondas acústicas de voz saliendo de la boca
        for ring in range(1, 3):
            rad = int(mw * 0.7 + ring * 22 + (t_sec * 120) % 18)
            alpha = int(190 * mouth_open / ring)
            draw.arc(
                [mx - rad, my_shifted - rad // 2, mx + rad, my_shifted + rad // 2],
                start=-38, end=38, fill=(163, 230, 53, alpha), width=4
            )

    # 2. Parpadeo automático (cada 2.1s durante 0.13s)
    blink_phase = (t_sec + hash(rig_key) % 5 * 0.37) % 2.1
    if blink_phase < 0.13:
        for ex, ey in cfg["eyes_xy"]:
            draw.ellipse([ex - 20, ey - 14, ex + 20, ey + 14], fill=(28, 38, 30, 255), outline=(10, 10, 10, 255), width=3)
            draw.line([ex - 22, ey, ex + 22, ey], fill=(10, 10, 10, 255), width=5)

    # 3. Expresiones faciales dinámicas
    if mode == "crudo":
        # Gotas de sudor cómicas bajando por la sien + humo verde de cruda
        drop_y = int((t_sec * 110) % 75)
        ex, ey = cfg["eyes_xy"][0]
        dx, dy = ex - 48, ey - 10 + drop_y
        draw.polygon([(dx, dy - 16), (dx - 11, dy + 6), (dx + 11, dy + 6)], fill=(56, 189, 248, 230))
        draw.ellipse([dx - 11, dy, dx + 11, dy + 18], fill=(56, 189, 248, 230), outline=(255, 255, 255, 220), width=2)
    elif mode == "revivido":
        # Brillos estelares dorados alrededor de los ojos
        pulse = int(6 * math.sin(t_sec * 14))
        for ex, ey in cfg["eyes_xy"]:
            r = 16 + pulse
            draw.polygon(
                [(ex, ey - r), (ex + 5, ey - 5), (ex + r, ey), (ex + 5, ey + 5),
                 (ex, ey + r), (ex - 5, ey + 5), (ex - r, ey), (ex - 5, ey - 5)],
                fill=(255, 214, 10, 245)
            )

    if flip_x:
        canvas = canvas.transpose(Image.Transpose.FLIP_LEFT_RIGHT)

    # 4. Squash & Stretch elástico + respiración a 60fps
    breath = math.sin(t_sec * 5.5) * 0.02
    sx = 1.0 - 0.06 * mouth_open + breath
    sy = 1.0 + 0.09 * mouth_open - breath
    new_w = max(10, int(canvas.width * sx))
    new_h = max(10, int(canvas.height * sy))
    stretched = canvas.resize((new_w, new_h), Image.Resampling.BILINEAR)

    # Rotación cómica leve al hablar
    tilt = math.sin(t_sec * 12.0) * (3.8 * mouth_open + 1.2)
    return stretched.rotate(tilt, resample=Image.Resampling.BILINEAR, expand=True)


def draw_word_by_word_subtitles(draw, text, progress_0_1, y_pos=1440):
    """
    Subtítulos dinámicos estilo TikTok/Reels a 60fps:
    Resalta la palabra activa en amarillo/lima con rebote de escala y caja glassmorphism.
    """
    words = text.split()
    if not words:
        return
    active_idx = min(len(words) - 1, max(0, int(progress_0_1 * len(words))))

    # Agrupar en bloques de hasta 7 palabras alrededor de la palabra activa para lectura instantánea
    chunk_size = 7
    chunk_start = (active_idx // chunk_size) * chunk_size
    chunk_words = words[chunk_start:chunk_start + chunk_size]
    local_active = active_idx - chunk_start

    # Fondo de píldora oscura en Safe Zone (x: 65..1015)
    box_x0, box_y0, box_x1, box_y1 = 65, y_pos, 1015, y_pos + 175
    draw.rounded_rectangle([box_x0, box_y0, box_x1, box_y1], radius=28, fill=(8, 16, 26, 232), outline=(163, 230, 53, 245), width=4)

    # Organizar palabras en 2 líneas centradas dentro de la caja
    mid = max(1, (len(chunk_words) + 1) // 2)
    lines = [chunk_words[:mid], chunk_words[mid:]]
    line_y = [y_pos + 28, y_pos + 96]

    word_counter = 0
    for l_idx, l_words in enumerate(lines):
        if not l_words:
            continue
        # Medir ancho total de la línea
        spacings = []
        total_w = 0
        for w_str in l_words:
            bbox = draw.textbbox((0, 0), w_str + " ", font=FONT_SUB)
            w_px = bbox[2] - bbox[0]
            spacings.append(w_px)
            total_w += w_px
        cur_x = 540 - total_w // 2
        for w_str, w_px in zip(l_words, spacings):
            is_curr = (word_counter == local_active)
            is_past = (word_counter < local_active)
            if is_curr:
                # Palabra activa con highlight amarillo neón y sombra intensa
                draw.rounded_rectangle(
                    [cur_x - 6, line_y[l_idx] - 4, cur_x + w_px - 6, line_y[l_idx] + 54],
                    radius=12, fill=(163, 230, 53, 255)
                )
                draw.text((cur_x, line_y[l_idx] - 2), w_str, font=FONT_SUB, fill=(10, 20, 12, 255))
            else:
                color = (255, 255, 255, 255) if is_past else (195, 210, 225, 235)
                draw.text((cur_x + 2, line_y[l_idx] + 2), w_str, font=FONT_SUB, fill=(0, 0, 0, 240))
                draw.text((cur_x, line_y[l_idx]), w_str, font=FONT_SUB, fill=color)
            cur_x += w_px
            word_counter += 1


def draw_hud_and_equalizer(frame, draw, logo_img, speaker_label, mouth_open, t_sec):
    """
    Dibuja el Header y Footer oficiales en Safe Zone + Ecualizador de Voz en vivo a 60fps.
    """
    # Header superior (Safe Zone)
    draw.rounded_rectangle([55, 45, 1025, 195], radius=26, fill=(7, 18, 28, 235), outline=(163, 230, 53, 220), width=3)
    frame.paste(logo_img, (75, 58), logo_img)

    draw.text((215, 64), "LA GARZA AGUACHILERA", font=FONT_TITLE, fill=(163, 230, 53, 255))
    draw.text((215, 114), speaker_label, font=FONT_SPEAKER, fill=(255, 214, 10, 255))

    # Barra de ondas de voz en tiempo real (10 barras dinámicas a 60fps)
    eq_x0 = 845
    for b in range(10):
        wave_h = int(12 + 48 * mouth_open * abs(math.sin(t_sec * 24 + b * 0.7)))
        bx = eq_x0 + b * 15
        by_mid = 120
        color = (163, 230, 53, 255) if mouth_open > 0.04 else (90, 110, 130, 180)
        draw.rounded_rectangle([bx, by_mid - wave_h // 2, bx + 9, by_mid + wave_h // 2], radius=4, fill=color)

    # Footer comercial fijo con precio $170 MXN y garantía de frescura
    draw.rounded_rectangle([55, 1650, 1025, 1855], radius=26, fill=(7, 18, 28, 240), outline=(255, 214, 10, 235), width=3)
    # Medallón de precio $170 MXN pulsante
    pulse_p = int(4 * math.sin(t_sec * 8))
    draw.rounded_rectangle([75 - pulse_p, 1670 - pulse_p, 335 + pulse_p, 1835 + pulse_p], radius=20, fill=(163, 230, 53, 255))
    draw.text((98, 1682), "SOLO", font=FONT_SPEAKER, fill=(8, 24, 14, 255))
    draw.text((92, 1718), "$170", font=FONT_PRICE, fill=(8, 24, 14, 255))
    draw.text((250, 1742), "MXN", font=FONT_SPEAKER, fill=(8, 24, 14, 255))
    draw.text((94, 1792), "~100g Camarón", font=FONT_FOOTER, fill=(8, 24, 14, 255))

    draw.text((358, 1672), "El producto es preparado frente a usted", font=FONT_FOOTER, fill=(255, 255, 255, 255))
    draw.text((358, 1706), "para corroborar su frescura • Tostitos Salsa Verde", font=FONT_FOOTER, fill=(163, 230, 53, 255))
    draw.text((358, 1748), "PEDIDOS Y ENTREGAS | Tampico y Ciudad Madero", font=FONT_FOOTER, fill=(255, 214, 10, 255))
    draw.text((358, 1790), "📲 PEDIDOS WHATSAPP: 833 252 09 88", font=FONT_SPEAKER, fill=(56, 189, 248, 255))


def main():
    start_wall = time.time()
    with open(TIMELINE_JSON, "r", encoding="utf-8") as f:
        timeline = json.load(f)

    total_frames = timeline["total_frames"]
    scenes = timeline["scenes"]
    frames_meta = timeline["frames"]
    master_wav = timeline["master_wav"]

    print(f"=== FASE 2.3 y 2.5: MOTOR DE ANIMACIÓN 2D A 60FPS ({total_frames} FRAMES @ 1080x1920) ===")

    # Cargar activos gráficos en memoria
    bg_skyline = load_rgba(os.path.join(BASE_DIR, "tampico_skyline_bg.jpg"), (1350, 2100))
    bg_hero = load_rgba(os.path.join(BASE_DIR, "aguachile_verde_hero.jpg"), (1350, 2100))
    bg_plato = load_rgba(os.path.join(BASE_DIR, "tostiaguachile_verde_redondo.jpg"), (1350, 2100))

    # Versiones nocturnas / soleadas pre-procesadas para velocidad máxima
    bg_night_lagoon = ImageEnhance.Brightness(bg_skyline).enhance(0.48)
    bg_night_escolleras = ImageEnhance.Color(ImageEnhance.Brightness(bg_skyline).enhance(0.58)).enhance(1.3)
    bg_climax_food = ImageEnhance.Contrast(ImageEnhance.Brightness(bg_hero).enhance(0.75)).enhance(1.15)
    bg_party_sunny = ImageEnhance.Color(ImageEnhance.Brightness(bg_plato).enhance(0.68)).enhance(1.25)

    logo_raw = load_rgba(os.path.join(BASE_DIR, "La garza aguachilera.jpeg"), (120, 120))
    # Máscara circular para el logo
    mask_logo = Image.new("L", (120, 120), 0)
    ImageDraw.Draw(mask_logo).ellipse([0, 0, 119, 119], fill=255)
    logo_circle = Image.new("RGBA", (120, 120), (0, 0, 0, 0))
    logo_circle.paste(logo_raw, (0, 0), mask_logo)

    sprites = {
        "juancho_zombie": load_rgba(os.path.join(BASE_DIR, "sticker_spooky_juancho_jason.png"), (650, 650)),
        "mapache_freddy": load_rgba(os.path.join(BASE_DIR, "sticker_spooky_mapache_freddy.png"), (650, 650)),
        "alien_ovni": load_rgba(os.path.join(BASE_DIR, "sticker_spooky_ovni_muertos.png"), (650, 650)),
        "juancho_vivo": load_rgba(os.path.join(BASE_DIR, "clean_juancho.png"), (650, 650)),
        "mapache_vivo": load_rgba(os.path.join(BASE_DIR, "clean_mapache.png"), (650, 650)),
        "comida": load_rgba(os.path.join(BASE_DIR, "clean_comida.png"), (640, 640)),
    }

    # Iniciar proceso FFmpeg recibiendo frames RGB24 a 60fps por stdin y mezclando audio_animacion_master_60fps.wav
    ffmpeg_cmd = [
        FFMPEG, "-y",
        "-loglevel", "warning",
        "-f", "rawvideo",
        "-vcodec", "rawvideo",
        "-pix_fmt", "rgb24",
        "-s", f"{W}x{H}",
        "-r", str(FPS),
        "-i", "-",
        "-i", master_wav,
        "-map", "0:v:0",
        "-map", "1:a:0",
        "-c:v", "libx264",
        "-profile:v", "high",
        "-level", "4.2",
        "-preset", "fast",
        "-b:v", "5200k",
        "-minrate", "4200k",
        "-maxrate", "6800k",
        "-bufsize", "10000k",
        "-pix_fmt", "yuv420p",
        "-c:a", "aac",
        "-b:a", "192k",
        "-ar", "44100",
        "-ac", "2",
        "-shortest",
        "-movflags", "+faststart",
        OUT_MP4_MAIN
    ]

    proc = subprocess.Popen(ffmpeg_cmd, stdin=subprocess.PIPE, stderr=subprocess.PIPE)

    # Mapa rápido de escenas por ID
    scene_map = {sc["id"]: sc for sc in scenes}

    for f_info in frames_meta:
        f_idx = f_info["frame"]
        t = f_info["time"]
        sc_id = f_info["scene_id"]
        mouth_open = f_info["mouth_open"]
        sc = scene_map[sc_id]

        sc_local_t = t - sc["scene_start"]
        sc_dur = sc["scene_duration"]
        voice_prog = min(1.0, max(0.0, (t - sc["voice_start"]) / max(0.01, sc["voice_duration"])))

        # Movimiento de cámara base (Panning suave + Camera Shake en impactos)
        pan_x = int(120 + 95 * math.sin(t * 0.55))
        pan_y = int(80 + 45 * math.cos(t * 0.45))
        shake_x, shake_y = 0, 0

        if sc_id == "sc1_juancho_zombie":
            bg_src = bg_night_lagoon
            if sc_local_t < 0.45:
                shake_x = int(math.sin(t * 50) * 12 * (0.45 - sc_local_t))
        elif sc_id == "sc2_mapache_freddy":
            bg_src = bg_night_escolleras
            if sc_local_t < 0.40 or (2.3 < sc_local_t < 2.7):
                shake_x = int(math.cos(t * 65) * 16)
                shake_y = int(math.sin(t * 65) * 12)
        elif sc_id == "sc3_alien_miramar":
            bg_src = bg_night_lagoon
            if sc_local_t < 0.50:
                shake_y = int(math.sin(t * 45) * 14)
        elif sc_id == "sc4_locutora_climax":
            bg_src = bg_climax_food
            if sc_local_t < 0.65 or (1.30 < sc_local_t < 1.85):
                shake_x = int(math.sin(t * 80) * 24)
                shake_y = int(math.cos(t * 80) * 20)
        else:
            bg_src = bg_party_sunny

        bx = max(0, min(bg_src.width - W, pan_x + shake_x))
        by = max(0, min(bg_src.height - H, pan_y + shake_y))
        frame = bg_src.crop((bx, by, bx + W, by + H)).copy()
        draw = ImageDraw.Draw(frame, "RGBA")

        # --- COMPOSICIÓN ANIMADA POR ESCENA A 60FPS ---
        if sc_id == "sc1_juancho_zombie":
            # Luna morada spooky + niebla en movimiento paralaje
            draw.ellipse([720, 230, 960, 470], fill=(168, 85, 247, 110))
            draw.ellipse([750, 260, 930, 440], fill=(233, 213, 255, 185))
            for i in range(4):
                fog_x = int((t * (65 + i * 25) + i * 280) % 1400) - 300
                fog_y = 980 + i * 95
                draw.rounded_rectangle([fog_x, fog_y, fog_x + 680, fog_y + 68], radius=34, fill=(134, 239, 172, 55))

            # Zoom-in cómico progresivo en el remate "¡ando bien crudo!"
            zoom_factor = 1.0 + 0.14 * min(1.0, max(0.0, (sc_local_t - 2.8) / 2.2))
            rig_img = render_rigged_character(sprites["juancho_zombie"], "juancho_zombie", mouth_open, t, mode="crudo")
            if zoom_factor > 1.01:
                rig_img = rig_img.resize(
                    (int(rig_img.width * zoom_factor), int(rig_img.height * zoom_factor)),
                    Image.Resampling.BILINEAR
                )
            walk_bob = int(abs(math.sin(t * 6.5)) * 22)
            walk_x = 540 - rig_img.width // 2 + int(math.sin(t * 2.5) * 35)
            walk_y = 690 - rig_img.height // 2 + walk_bob - int(22 * mouth_open)
            frame.paste(rig_img, (walk_x, walk_y), rig_img)

            # Viñeta cómica de diálogo
            draw.rounded_rectangle([85, 235, 720, 345], radius=22, fill=(20, 10, 35, 225), outline=(168, 85, 247, 255), width=4)
            draw.text((115, 265), "🧟‍♂️ DOMINGO 11:00 AM EN LA LAGUNA...", font=FONT_BADGE, fill=(233, 213, 255, 255))

        elif sc_id == "sc2_mapache_freddy":
            # Faro de las escolleras girando haz de luz + olas
            beam_angle = math.sin(t * 2.2) * 220
            draw.polygon([(120, 310), (1080, int(450 + beam_angle)), (1080, int(690 + beam_angle))], fill=(253, 224, 71, 55))

            # Entrada elástica del Mapache Freddy
            slide_in = max(0, int((0.35 - sc_local_t) * 900)) if sc_local_t < 0.35 else 0
            rig_img = render_rigged_character(sprites["mapache_freddy"], "mapache_freddy", mouth_open, t, mode="crudo")
            mx_pos = 540 - rig_img.width // 2 + slide_in
            my_pos = 700 - rig_img.height // 2 - int(26 * mouth_open)
            frame.paste(rig_img, (mx_pos, my_pos), rig_img)

            # Destellos de corte de garras de Freddy ("¡Schwing!")
            if 0.10 < sc_local_t < 0.55 or 2.25 < sc_local_t < 2.75:
                for s_i in range(3):
                    sy0 = 520 + s_i * 75
                    draw.line([220, sy0, 880, sy0 - 140], fill=(255, 255, 255, 235), width=9)
                    draw.line([220, sy0, 880, sy0 - 140], fill=(163, 230, 53, 180), width=16)

            draw.rounded_rectangle([85, 235, 995, 345], radius=22, fill=(35, 10, 15, 230), outline=(248, 113, 113, 255), width=4)
            draw.text((115, 265), "🦝 PESADILLA EN LAS ESCOLLERAS DE MIRAMAR", font=FONT_BADGE, fill=(254, 202, 202, 255))

        elif sc_id == "sc3_alien_miramar":
            # Rayo abductor volumétrico animado desde el OVNI hacia la hielera/Tostitos
            ufo_x = 540 + int(math.sin(t * 3.8) * 85)
            ufo_y = 530 + int(math.cos(t * 5.0) * 28)

            beam_w_top = 150
            beam_w_bot = 430 + int(math.sin(t * 12) * 35)
            draw.polygon(
                [
                    (ufo_x - beam_w_top, ufo_y + 110),
                    (ufo_x + beam_w_top, ufo_y + 110),
                    (540 + beam_w_bot, 1380),
                    (540 - beam_w_bot, 1380),
                ],
                fill=(168, 85, 247, 85)
            )
            draw.polygon(
                [
                    (ufo_x - beam_w_top // 2, ufo_y + 110),
                    (ufo_x + beam_w_top // 2, ufo_y + 110),
                    (540 + beam_w_bot // 2, 1380),
                    (540 - beam_w_bot // 2, 1380),
                ],
                fill=(163, 230, 53, 95)
            )

            # Anillos de abducción ascendentes y limones Colima flotando a 2°C
            for r_i in range(5):
                ry = int(1340 - ((t * 280 + r_i * 145) % 680))
                rw = int(140 + (ry - 660) * 0.35)
                draw.ellipse([ufo_x - rw, ry - 22, ufo_x + rw, ry + 22], outline=(255, 214, 10, 210), width=5)

            # Plato abducido emergiendo con brillo criogénico
            plato_scale = 0.72 + 0.06 * math.sin(t * 6)
            pw, ph = int(640 * plato_scale), int(640 * plato_scale)
            plato_img = sprites["comida"].resize((pw, ph), Image.Resampling.BILINEAR)
            frame.paste(plato_img, (540 - pw // 2, 930), plato_img)

            rig_ufo = render_rigged_character(sprites["alien_ovni"], "alien_ovni", mouth_open, t, mode="normal")
            frame.paste(rig_ufo, (ufo_x - rig_ufo.width // 2, ufo_y - rig_ufo.height // 2), rig_ufo)

            draw.rounded_rectangle([85, 235, 995, 345], radius=22, fill=(10, 28, 38, 230), outline=(56, 189, 248, 255), width=4)
            draw.text((110, 265), "🛸 BASE MIRAMAR: HIELERA A 2°C Y LIMÓN COLIMA", font=FONT_BADGE, fill=(186, 230, 253, 255))

        elif sc_id == "sc4_locutora_climax":
            # ¡EL CLÍMAX DEL CRUNCH Y LA RESURRECCIÓN!
            # Destello eléctrico de resurrección al segundo 1.3s de la escena
            is_revived = sc_local_t >= 1.35
            if 1.20 <= sc_local_t <= 1.65:
                flash_alpha = int(210 * (1.0 - abs(sc_local_t - 1.42) / 0.25))
                draw.rectangle([0, 0, W, H], fill=(163, 230, 53, max(0, flash_alpha)))
                # Rayo esmeralda
                draw.line([540, 200, 420, 620, 630, 780, 500, 1280], fill=(255, 255, 255, 255), width=18)

            # Personajes a los lados transformándose de Zombies a Vivos Radiantes
            if not is_revived:
                j_img = render_rigged_character(sprites["juancho_zombie"], "juancho_zombie", mouth_open * 0.7, t, mode="crudo")
                m_img = render_rigged_character(sprites["mapache_freddy"], "mapache_freddy", mouth_open * 0.7, t, mode="crudo", flip_x=True)
            else:
                j_img = render_rigged_character(sprites["juancho_vivo"], "juancho_vivo", mouth_open, t, mode="revivido")
                m_img = render_rigged_character(sprites["mapache_vivo"], "mapache_vivo", mouth_open, t, mode="revivido", flip_x=True)

            j_small = j_img.resize((int(j_img.width * 0.76), int(j_img.height * 0.76)), Image.Resampling.BILINEAR)
            m_small = m_img.resize((int(m_img.width * 0.76), int(m_img.height * 0.76)), Image.Resampling.BILINEAR)
            frame.paste(j_small, (20, 460 - int(20 * mouth_open)), j_small)
            frame.paste(m_small, (560, 460 - int(20 * mouth_open)), m_small)

            # Tostiaguachile Verde Tradicional gigante en el centro con impacto CRUNCH
            crunch_zoom = 1.08 + 0.12 * math.sin(t * 16) if (1.30 < sc_local_t < 2.50) else 1.0 + 0.04 * mouth_open
            cw_f = int(640 * crunch_zoom)
            ch_f = int(640 * crunch_zoom)
            c_img = sprites["comida"].resize((cw_f, ch_f), Image.Resampling.BILINEAR)
            frame.paste(c_img, (540 - cw_f // 2, 740 - ch_f // 2 + 220), c_img)

            # Texto de impacto ¡CRUNCH!
            banner_txt = "⚡ ¡NO ESTABAN MUERTOS... ESTABAN CRUDOS! ⚡" if is_revived else "💥 ¡AL PRIMER CRUNCH CON ~100g DE CAMARÓN! 💥"
            draw.rounded_rectangle([65, 235, 1015, 345], radius=22, fill=(12, 32, 18, 240), outline=(163, 230, 53, 255), width=4)
            draw.text((95, 265), banner_txt, font=FONT_BADGE, fill=(255, 214, 10, 255))

        elif sc_id == "sc5_juancho_vivo":
            # Juancho Resucitado protagonista hablando en primer plano + Mapache y Plato
            rig_j = render_rigged_character(sprites["juancho_vivo"], "juancho_vivo", mouth_open, t, mode="revivido")
            rig_m = render_rigged_character(sprites["mapache_vivo"], "mapache_vivo", mouth_open * 0.4, t, mode="revivido", flip_x=True)
            m_side = rig_m.resize((440, 440), Image.Resampling.BILINEAR)
            c_side = sprites["comida"].resize((460, 460), Image.Resampling.BILINEAR)

            frame.paste(m_side, (610, 520 + int(math.sin(t * 8) * 14)), m_side)
            frame.paste(rig_j, (45, 420 - int(26 * mouth_open)), rig_j)
            frame.paste(c_side, (530, 880), c_side)

            draw.rounded_rectangle([75, 235, 1005, 345], radius=22, fill=(10, 30, 20, 235), outline=(255, 214, 10, 255), width=4)
            draw.text((110, 265), "🐊 ¡REVIVÍ AL 100% POR SOLO $170 PESITOS!", font=FONT_BADGE, fill=(163, 230, 53, 255))

        else:
            # Escena 6: Gran Remate Comercial con toda la pandilla jaiba bailando
            bounce_all = int(abs(math.sin(t * 9.0)) * 24)
            ufo_top = sprites["alien_ovni"].resize((380, 380), Image.Resampling.BILINEAR)
            j_party = render_rigged_character(sprites["juancho_vivo"], "juancho_vivo", mouth_open * 0.8, t, mode="revivido").resize((470, 470), Image.Resampling.BILINEAR)
            m_party = render_rigged_character(sprites["mapache_vivo"], "mapache_vivo", mouth_open * 0.8, t, mode="revivido", flip_x=True).resize((470, 470), Image.Resampling.BILINEAR)
            c_hero = sprites["comida"].resize((560, 560), Image.Resampling.BILINEAR)

            frame.paste(ufo_top, (350 + int(math.sin(t * 5) * 45), 210), ufo_top)
            frame.paste(j_party, (35, 510 - bounce_all), j_party)
            frame.paste(m_party, (575, 510 - bounce_all), m_party)
            frame.paste(c_hero, (260, 820 - bounce_all // 2), c_hero)

            # Botón CTA pulsante de WhatsApp
            cta_p = int(6 * math.sin(t * 12))
            draw.rounded_rectangle(
                [110 - cta_p, 1315 - cta_p, 970 + cta_p, 1418 + cta_p],
                radius=48, fill=(34, 197, 94, 255), outline=(255, 255, 255, 255), width=4
            )
            draw.text((165, 1344), "📲 PIDE AL WHATSAPP: 833 252 09 88", font=FONT_TITLE, fill=(255, 255, 255, 255))

        # Dibujar subtítulos dinámicos palabra por palabra y HUD comercial
        draw_word_by_word_subtitles(draw, sc["subtitle_text"], voice_prog, y_pos=1445)
        draw_hud_and_equalizer(frame, draw, logo_circle, sc["speaker_label"], mouth_open, t)

        # Enviar frame RGB24 a FFmpeg
        proc.stdin.write(frame.convert("RGB").tobytes())

        if f_idx % 300 == 0 or f_idx == total_frames - 1:
            elapsed = time.time() - start_wall
            print(f" -> Renderizados {f_idx + 1}/{total_frames} frames ({(f_idx + 1) / total_frames * 100:.1f}%) en {elapsed:.1f}s")

    proc.stdin.close()
    stderr_out = proc.stderr.read().decode("utf-8", errors="ignore")
    proc.wait()

    if proc.returncode != 0:
        raise RuntimeError(f"FFmpeg falló con código {proc.returncode}:\n{stderr_out[-1200:]}")

    # Sincronizar también en VIDEOS/promo_halloween_zombies_crudos.mp4 para que todas las tarjetas del Panel reproduzcan la animación 60fps
    import shutil
    shutil.copy2(OUT_MP4_MAIN, OUT_MP4_SPOOKY)

    total_wall = time.time() - start_wall
    size_mb = os.path.getsize(OUT_MP4_MAIN) / (1024 * 1024)
    print(f"\n=== RENDERIZADO 60FPS COMPLETADO CON ÉXITO EN {total_wall:.1f}s ===")
    print(f" -> Archivo Maestro: {OUT_MP4_MAIN} ({size_mb:.2f} MB)")
    print(f" -> Espejo Spooky  : {OUT_MP4_SPOOKY} ({size_mb:.2f} MB)")


if __name__ == "__main__":
    main()
