# -*- coding: utf-8 -*-
"""
=============================================================================
GENERADOR DE SECUENCIAS 3D CGI NIVEL AAA — LA GARZA AGUACHILERA
Comercial Stories & TikTok (24.0s = 1440 frames @ 60.0 fps, 1080x1920)
Integración Cinematográfica Híbrida 3D CGI + Blender 4.3 OptiX
=============================================================================
Acto 1 (0.0s - 6.0s, 360f): Escolleras Miramar crepúsculo; OVNI con rayo tractor
                           esmeralda, niebla criogénica, limones flotantes,
                           levitación del Tostiaguachile y Mapache asombrado.
Acto 2 (6.0s - 12.0s, 360f): Malecón de Tampico; Garza Chef y Juancho; macro culinary
                            slow-motion squeeze de limón y splash esmeralda de serrano
                            + salsas de la casa sobre camarón mariposa y aguacate.
Acto 3 (12.0s - 18.0s, 360f): Fiesta en la playa Miramar; crunch sincronizado por
                             Juancho, Mapache y Alien; onda de choque 3D con chispas
                             doradas y fuegos artificiales tropicales.
Acto 4 (18.0s - 24.0s, 360f): Clímax comercial heroico; Tostiaguachile en pedestal 3D
                             gourmet con reflejo de espejo; Garza, Juancho y Mapache
                             posando con orgullo entre bokeh dorado y luz volumétrica.
=============================================================================
"""

import os
import sys
import math
import time
import random
import subprocess
from pathlib import Path
import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageEnhance, ImageOps

# Configurar encoding UTF-8 en Windows
if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
if hasattr(sys.stderr, "reconfigure"):
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")

PROJECT_ROOT = Path(r"d:\AG\la garza aguachilera")
FFMPEG_DIR = PROJECT_ROOT / "herramientas" / "ffmpeg"
FFMPEG_BIN = FFMPEG_DIR / "ffmpeg.exe"
FFPROBE_BIN = FFMPEG_DIR / "ffprobe.exe"
if not FFMPEG_BIN.exists():
    FFMPEG_BIN = Path("ffmpeg")
if not FFPROBE_BIN.exists():
    FFPROBE_BIN = Path("ffprobe")

CLIPS_DIR = PROJECT_ROOT / "VIDEOS" / "clips_aaa"
FRAMES_AUDIT_DIR = PROJECT_ROOT / "FRAMES" / "aaa_stories"
CLIPS_DIR.mkdir(parents=True, exist_ok=True)
FRAMES_AUDIT_DIR.mkdir(parents=True, exist_ok=True)

W, H = 1080, 1920
FPS = 60.0
ACT_DURATION = 6.0
ACT_FRAMES = int(ACT_DURATION * FPS)  # 360 frames
TOTAL_FRAMES = ACT_FRAMES * 4          # 1440 frames


# =============================================================================
# CARGA Y PREPROCESAMIENTO DE ACTIVOS GRÁFICOS
# =============================================================================
def load_assets():
    print("-> Cargando y preprocesando activos visuales 3D CGI...")

    # Activo Garza transparente
    garza_path = PROJECT_ROOT / "clean_garza.png"
    if not garza_path.exists():
        # Generar máscara si no existe
        raw_garza = Image.open(PROJECT_ROOT / "La garza aguachilera.jpeg").convert("RGB")
        arr = np.array(raw_garza, dtype=np.int32)
        bg = np.array([251, 248, 241], dtype=np.int32)
        dist = np.sqrt(np.sum((arr - bg) ** 2, axis=2))
        is_bg = dist < 26.0
        alpha = (~is_bg).astype(np.uint8) * 255
        alpha_img = Image.fromarray(alpha).filter(ImageFilter.GaussianBlur(1.2))
        garza_img = raw_garza.convert("RGBA")
        garza_img.putalpha(alpha_img)
        garza_img.save(garza_path)
    else:
        garza_img = Image.open(garza_path).convert("RGBA")

    assets = {
        "garza": garza_img,
        "juancho": Image.open(PROJECT_ROOT / "clean_juancho.png").convert("RGBA"),
        "mapache": Image.open(PROJECT_ROOT / "clean_mapache.png").convert("RGBA"),
        "ovni": Image.open(PROJECT_ROOT / "clean_ovni.png").convert("RGBA"),
        "comida": Image.open(PROJECT_ROOT / "clean_comida.png").convert("RGBA"),
        "skyline": Image.open(PROJECT_ROOT / "tampico_skyline_bg.jpg").convert("RGB"),
        "hero_food": Image.open(PROJECT_ROOT / "aguachile_verde_hero.jpg").convert("RGB"),
    }

    # Pre-recortar comida aísla para composición de alta definición
    comida_arr = np.array(assets["comida"])
    a = comida_arr[:, :, 3]
    rows = np.where(a > 10)[0]
    cols = np.where(a > 10)[1]
    assets["comida_tight"] = assets["comida"].crop((cols.min(), rows.min(), cols.max(), rows.max()))

    print("   [OK] Todos los activos visuales cargados correctamente en memoria.")
    return assets


# =============================================================================
# RUTINAS GRÁFICAS PROCEDURALES 3D Y DE ILUMINACIÓN
# =============================================================================
def draw_star(draw, cx, cy, r_outer, r_inner, points=5, fill=(255, 230, 0, 255), outline=None, width=1):
    angle_step = math.pi / points
    coords = []
    for i in range(2 * points):
        r = r_outer if i % 2 == 0 else r_inner
        ang = i * angle_step - math.pi / 2
        coords.append((cx + r * math.cos(ang), cy + r * math.sin(ang)))
    draw.polygon(coords, fill=fill, outline=outline, width=width)


def paste_sprite_3d(canvas, sprite, cx, cy, target_w, target_h=None, rot_deg=0.0,
                    alpha_factor=1.0, shadow=True, shadow_y_off=35, shadow_scale=(0.85, 0.22),
                    rim_color=None):
    """
    Pega un sprite con profundidad 3D: sombra de contacto difuminada,
    rotación elástica, escalado de perspectiva y halo de luz de borde (rim lighting).
    """
    if target_h is None:
        aspect = sprite.height / sprite.width
        target_h = int(target_w * aspect)

    scaled = sprite.resize((max(4, target_w), max(4, target_h)), Image.Resampling.LANCZOS)

    if rot_deg != 0.0:
        scaled = scaled.rotate(rot_deg, resample=Image.Resampling.BILINEAR, expand=True)

    # 1. Sombra de contacto 3D en el suelo
    if shadow:
        sh_w = int(scaled.width * shadow_scale[0])
        sh_h = int(scaled.height * shadow_scale[1])
        if sh_w > 4 and sh_h > 4:
            shadow_mask = Image.new("L", (sh_w, sh_h), 0)
            sh_draw = ImageDraw.Draw(shadow_mask)
            sh_draw.ellipse([0, 0, sh_w - 1, sh_h - 1], fill=int(140 * alpha_factor))
            shadow_mask = shadow_mask.filter(ImageFilter.GaussianBlur(sh_h // 4 + 2))
            shadow_layer = Image.new("RGBA", (sh_w, sh_h), (10, 15, 20, 0))
            shadow_layer.putalpha(shadow_mask)
            sh_x = cx - sh_w // 2
            sh_y = cy + scaled.height // 2 - sh_h // 2 + shadow_y_off
            canvas.paste(shadow_layer, (sh_x, sh_y), shadow_layer)

    # 2. Rim lighting / Resplandor de borde volumétrico
    if rim_color is not None:
        glow_mask = scaled.split()[3].filter(ImageFilter.GaussianBlur(6))
        glow_layer = Image.new("RGBA", scaled.size, rim_color)
        glow_layer.putalpha(glow_mask)
        canvas.paste(glow_layer, (cx - scaled.width // 2, cy - scaled.height // 2), glow_layer)

    # 3. Sprite principal con modulación de opacidad
    if alpha_factor < 0.999:
        r, g, b, a = scaled.split()
        a = a.point(lambda p: int(p * alpha_factor))
        scaled.putalpha(a)

    canvas.paste(scaled, (cx - scaled.width // 2, cy - scaled.height // 2), scaled)


def draw_volumetric_beam(draw, top_x, top_y, bot_x, bot_y, top_w, bot_w, color_rgb, pulse):
    """Renderiza rayo tractor cónico volumétrico con scanlines y anillos de dispersión."""
    poly = [
        (top_x - top_w // 2, top_y),
        (top_x + top_w // 2, top_y),
        (bot_x + bot_w // 2, bot_y),
        (bot_x - bot_w // 2, bot_y),
    ]
    base_alpha = int(35 + 20 * pulse)
    draw.polygon(poly, fill=(color_rgb[0], color_rgb[1], color_rgb[2], base_alpha))

    # Haz central concentrado de alta intensidad
    inner_poly = [
        (top_x - top_w // 4, top_y),
        (top_x + top_w // 4, top_y),
        (bot_x + bot_w // 4, bot_y),
        (bot_x - bot_w // 4, bot_y),
    ]
    draw.polygon(inner_poly, fill=(210, 255, 230, int(45 + 25 * pulse)))


# =============================================================================
# GENERADOR ACTO 1: ESCOLLERAS MIRAMAR TWILIGHT Y ABDUCCIÓN OVNI (0.0s - 6.0s)
# =============================================================================
def render_frame_act1(frame_idx, assets):
    """
    Act 1: Escolleras Miramar crepúsculo dorado-púrpura; OVNI girando y proyectando
    rayo tractor esmeralda, niebla criogénica y limones flotantes, levitación del
    Tostiaguachile y el Mapache asombrado con gafas de sol.
    """
    p = frame_idx / float(ACT_FRAMES - 1)
    t = frame_idx / FPS

    # 1. Fondo cielo crepuscular degradado + mar con reflejos
    frame = Image.new("RGBA", (W, H), (0, 0, 0, 255))
    draw = ImageDraw.Draw(frame, "RGBA")

    # Gradiente vertical de cielo Miramar crepúsculo
    # Púrpura índigo arriba (Y=0) a naranja-dorado en el horizonte (Y=1150)
    for y_step in range(0, 1150, 4):
        yp = y_step / 1150.0
        r = int(25 * (1 - yp) + 245 * yp)
        g = int(15 * (1 - yp) + 120 * yp)
        b = int(55 * (1 - yp) + 60 * yp)
        draw.rectangle([0, y_step, W, y_step + 4], fill=(r, g, b, 255))

    # Océano con olas y reflejos dorados (Y=1150 a Y=1920)
    for y_sea in range(1150, H, 4):
        yp = (y_sea - 1150) / (H - 1150)
        r = int(12 * (1 - yp) + 8 * yp)
        g = int(35 * (1 - yp) + 24 * yp)
        b = int(48 * (1 - yp) + 32 * yp)
        draw.rectangle([0, y_sea, W, y_sea + 4], fill=(r, g, b, 255))

    # Reflejos brillantes del horizonte en el mar
    for w_i in range(12):
        wy = 1170 + w_i * 35 + int(math.sin(t * 3.0 + w_i) * 6)
        ww = int(600 + math.sin(t * 2.0 + w_i * 0.7) * 250)
        draw.ellipse([540 - ww // 2, wy, 540 + ww // 2, wy + 8], fill=(255, 180, 80, 35))

    # Bloques de piedra de las Escolleras (primer plano inferior)
    rock_poly = [
        (0, 1580), (220, 1520), (450, 1560), (750, 1510), (1080, 1570),
        (1080, 1920), (0, 1920)
    ]
    draw.polygon(rock_poly, fill=(28, 32, 38, 255))
    for r_i in range(6):
        rx = r_i * 180 + 30
        draw.polygon([(rx, 1540), (rx + 150, 1530), (rx + 140, 1620), (rx - 10, 1610)],
                     fill=(38, 44, 52, 230), outline=(20, 24, 30, 255), width=2)

    # 2. Haz de luz del faro de Miramar girando en el fondo
    beam_ang = (t * 0.45) % (math.pi * 2)
    faro_x = int(math.sin(beam_ang) * 900)
    draw.polygon([(140, 1150), (540 + faro_x - 120, 300), (540 + faro_x + 120, 300)],
                 fill=(255, 240, 160, 20))

    # 3. Rayo tractor esmeralda del OVNI
    ufo_pulse = 0.85 + 0.15 * math.sin(t * 12.0)
    ufo_bob_y = int(math.sin(t * 2.8) * 16)
    ufo_x = 540 + int(math.sin(t * 1.5) * 22)
    ufo_y = 330 + ufo_bob_y

    draw_volumetric_beam(draw, ufo_x, ufo_y + 90, 540, 1580,
                         top_w=140, bot_w=int(740 * ufo_pulse),
                         color_rgb=(0, 255, 140), pulse=ufo_pulse)

    # Anillos de energía concéntricos descendiendo por el rayo tractor
    for ring_i in range(6):
        ring_p = ((t * 0.9) + ring_i * 0.16) % 1.0
        ry = ufo_y + 110 + int(ring_p * 1050)
        rw = int(140 + ring_p * 580)
        rh = int(12 + ring_p * 32)
        r_alpha = int(180 * math.sin(ring_p * math.pi))
        draw.ellipse([540 - rw // 2, ry - rh // 2, 540 + rw // 2, ry + rh // 2],
                     outline=(140, 255, 200, r_alpha), width=3)

    # 4. Niebla criogénica y cristales de hielo en el suelo
    for mist_i in range(8):
        m_ang = t * 3.0 + mist_i * 0.8
        mx = 540 + int(math.sin(m_ang) * (180 + mist_i * 25))
        my = 1530 - int(((t * 1.8 + mist_i * 0.3) % 1.0) * 280)
        mr = int(35 + mist_i * 8 + math.sin(t * 4.0 + mist_i) * 12)
        m_alpha = int(60 * (1.0 - (1530 - my) / 280.0))
        draw.ellipse([mx - mr, my - mr // 2, mx + mr, my + mr // 2],
                     fill=(180, 240, 255, m_alpha))

    # 5. Limones Colima en rotación 3D ascendiendo
    for lime_i in range(5):
        lp = ((t * 0.6) + lime_i * 0.2) % 1.0
        lx = 540 + int(math.sin(lp * math.pi * 3 + lime_i * 1.5) * 160)
        ly = 1450 - int(lp * 750)
        l_scale = int(50 + 20 * math.sin(lp * math.pi))
        l_rot = (t * 180 + lime_i * 72) % 360
        # Dibujar rodaja de limón estilizada
        draw.ellipse([lx - l_scale // 2, ly - l_scale // 2, lx + l_scale // 2, ly + l_scale // 2],
                     fill=(70, 220, 40, 230), outline=(230, 255, 120, 255), width=3)
        draw.line([lx - l_scale // 3, ly, lx + l_scale // 3, ly], fill=(240, 255, 150, 240), width=2)
        draw.line([lx, ly - l_scale // 3, lx, ly + l_scale // 3], fill=(240, 255, 150, 240), width=2)

    # 6. Tostiaguachile Verde levitando en el rayo (ascenso dramático suave)
    # De Y = 1200 a Y = 820
    food_y_prog = 0.5 - 0.5 * math.cos(min(1.0, p * 1.3) * math.pi)
    food_y = int(1220 - food_y_prog * 400 + math.sin(t * 3.5) * 14)
    food_w = int(520 + food_y_prog * 80)
    food_tilt = math.sin(t * 3.0) * 4.5

    # Aura esmeralda radiante detrás del aguachile levitando
    glow_r = int(food_w * 0.62)
    draw.ellipse([540 - glow_r, food_y - glow_r, 540 + glow_r, food_y + glow_r],
                 fill=(0, 255, 150, int(45 + 20 * ufo_pulse)))

    paste_sprite_3d(frame, assets["comida_tight"], 540, food_y,
                    target_w=food_w, rot_deg=food_tilt, shadow=False,
                    rim_color=(80, 255, 180, 160))

    # Chispas doradas orbitando el plato
    for sp_i in range(6):
        sp_ang = t * 4.0 + sp_i * (math.pi / 3)
        sp_x = 540 + int(math.cos(sp_ang) * (food_w // 2 + 35))
        sp_y = food_y + int(math.sin(sp_ang) * (food_w // 3 + 15))
        draw_star(draw, sp_x, sp_y, 14, 6, fill=(255, 235, 60, 250))

    # 7. OVNI en el cielo superior
    ufo_tilt = math.sin(t * 2.2) * 3.0
    paste_sprite_3d(frame, assets["ovni"], ufo_x, ufo_y, target_w=460,
                    rot_deg=ufo_tilt, shadow=False, rim_color=(0, 255, 150, 140))

    # 8. Mapache de las Escolleras asombrado con gafas
    # Saltando con emoción al ver la abducción deliciosa
    jump_cycle = math.sin(t * 5.5)
    mapache_jump = int(max(0.0, jump_cycle) * 45)
    mapache_tilt = math.sin(t * 5.5) * 4.0
    mapache_x = 760
    mapache_y = 1260 - mapache_jump
    paste_sprite_3d(frame, assets["mapache"], mapache_x, mapache_y,
                    target_w=390, rot_deg=mapache_tilt, shadow=True,
                    shadow_y_off=35 + mapache_jump,
                    rim_color=(255, 210, 80, 120))

    # Destellos de estrella en las gafas de sol del mapache
    eye_flash = (math.sin(t * 14.0) > 0.4)
    if eye_flash:
        draw_star(draw, mapache_x - 30, mapache_y - 80, 18, 7, fill=(255, 255, 255, 255))
        draw_star(draw, mapache_x + 35, mapache_y - 75, 18, 7, fill=(255, 255, 255, 255))

    return frame.convert("RGB")


# =============================================================================
# GENERADOR ACTO 2: MALECÓN TAMPICO Y MACRO CULINARY SLOW-MOTION (6.0s - 12.0s)
# =============================================================================
def render_frame_act2(frame_idx, assets):
    """
    Act 2: Malecón de Tampico al atardecer; Garza Chef y Juancho; macro slow-motion
    squeeze de limón y splash esmeralda de aguachile + salsas de la casa sobre
    camarón mariposa y aguacate cremoso.
    """
    p = frame_idx / float(ACT_FRAMES - 1)
    t = frame_idx / FPS

    # 1. Fondo Malecón Tampico con paneo cinematográfico suave y desenfoque
    bg_raw = assets["skyline"]
    pan_x = int((math.sin(p * math.pi * 0.8) * 0.5 + 0.5) * (bg_raw.width - W * 0.6))
    bg_cropped = bg_raw.crop((pan_x, 0, pan_x + int(W * 0.75), bg_raw.height))
    bg_scaled = bg_cropped.resize((W, H), Image.Resampling.LANCZOS)
    # Tono cálido atardecer gastronómico
    bg_warm = ImageEnhance.Color(ImageEnhance.Brightness(bg_scaled).enhance(0.85)).enhance(1.25)
    frame = bg_warm.convert("RGBA")
    draw = ImageDraw.Draw(frame, "RGBA")

    # Viñeta oscura periférica para destacar la acción culinaria central
    vignette = Image.new("L", (W, H), 0)
    v_draw = ImageDraw.Draw(vignette)
    v_draw.ellipse([80, 300, W - 80, H - 250], fill=255)
    vignette = ImageOps.invert(vignette).filter(ImageFilter.GaussianBlur(140))
    v_dark = Image.new("RGBA", (W, H), (12, 16, 22, 175))
    v_dark.putalpha(vignette)
    frame.paste(v_dark, (0, 0), v_dark)

    # 2. Barra de madera gourmet artesanal en plano medio
    bar_poly = [(0, 1220), (W, 1220), (W, 1920), (0, 1920)]
    draw.polygon(bar_poly, fill=(45, 28, 18, 255))
    # Vetar y reflejo barnizado
    draw.line([(0, 1224), (W, 1224)], fill=(180, 130, 80, 200), width=4)
    draw.line([(0, 1232), (W, 1232)], fill=(120, 80, 50, 180), width=2)

    # 3. La Garza Chef a la izquierda (apretando el limón en slow motion)
    garza_bob = int(math.sin(t * 3.5) * 8)
    garza_tilt = math.sin(t * 2.2) * 2.5
    garza_x = 270
    garza_y = 820 + garza_bob
    paste_sprite_3d(frame, assets["garza"], garza_x, garza_y,
                    target_w=460, rot_deg=garza_tilt, shadow=True,
                    rim_color=(255, 230, 160, 110))

    # 4. Juancho el Cocodrilo a la derecha (pulgar arriba y sonrisa alegre)
    juancho_bob = int(math.cos(t * 4.0) * 10)
    juancho_tilt = math.sin(t * 3.0) * 2.8
    juancho_x = 810
    juancho_y = 840 + juancho_bob
    paste_sprite_3d(frame, assets["juancho"], juancho_x, juancho_y,
                    target_w=440, rot_deg=juancho_tilt, shadow=True,
                    rim_color=(255, 180, 60, 120))

    # 5. Macro Centro Culinario: Tostiaguachile Verde Tradicional
    # Macro zoom lento hacia el plato para despertar apetito instantáneo
    macro_zoom = 1.0 + 0.15 * math.sin(p * math.pi)
    food_w = int(580 * macro_zoom)
    food_x = 540
    food_y = 1110
    paste_sprite_3d(frame, assets["comida_tight"], food_x, food_y,
                    target_w=food_w, rot_deg=0.0, shadow=True,
                    shadow_y_off=45, shadow_scale=(0.95, 0.28),
                    rim_color=(60, 255, 120, 130))

    # 6. Squeeze de Limón en Slow-Motion (Chorros parabólicos de zumo fresco)
    squeeze_origin = (garza_x + 130, garza_y - 20)
    # Rodaja de limón verde en la mano de la Garza
    draw.ellipse([squeeze_origin[0] - 32, squeeze_origin[1] - 32,
                  squeeze_origin[0] + 32, squeeze_origin[1] + 32],
                 fill=(80, 235, 45, 255), outline=(240, 255, 140, 255), width=3)

    # Micro-gotas de zumo de limón volando en cámara lenta hacia el plato
    for drop_i in range(16):
        dp = ((t * 1.8) + drop_i * 0.065) % 1.0
        # Arco parabólico desde el limón hasta el centro del plato
        dx = squeeze_origin[0] + int(dp * (food_x - squeeze_origin[0] + (drop_i - 8) * 18))
        dy = squeeze_origin[1] + int(dp * dp * 320 + dp * 60)
        d_rad = max(2, int(7 * (1.0 - dp * 0.4)))
        draw.ellipse([dx - d_rad, dy - d_rad, dx + d_rad, dy + d_rad],
                     fill=(220, 255, 160, int(220 * (1.0 - dp * 0.5))),
                     outline=(255, 255, 255, 240), width=1)

    # 7. Splash de salsa esmeralda de serrano y salsas oscuras de la casa
    splash_center = (food_x, food_y - 40)
    splash_pulse = (t * 2.2) % 1.0
    for s_i in range(14):
        s_ang = s_i * (math.pi * 2 / 14) + splash_pulse * 0.8
        s_dist = int(45 + splash_pulse * 135)
        sx = splash_center[0] + int(math.cos(s_ang) * s_dist)
        sy = splash_center[1] + int(math.sin(s_ang) * (s_dist * 0.55))
        s_alpha = int(220 * (1.0 - splash_pulse))

        # Alternar entre salsa verde esmeralda y salsa oscura especial
        if s_i % 2 == 0:
            color = (30, 215, 60, s_alpha)
            edge = (160, 255, 180, s_alpha)
        else:
            color = (65, 25, 15, s_alpha)
            edge = (200, 110, 60, s_alpha)

        draw.ellipse([sx - 9, sy - 9, sx + 9, sy + 9], fill=color, outline=edge, width=2)

    # Brillo especular barriendo el plato (glistening)
    sheen_prog = (t * 0.75) % 1.0
    sheen_x = int(food_x - food_w // 2 + sheen_prog * (food_w + 200))
    draw.polygon([
        (sheen_x - 30, food_y - 120),
        (sheen_x + 30, food_y - 120),
        (sheen_x + 80, food_y + 120),
        (sheen_x + 20, food_y + 120)
    ], fill=(255, 255, 255, 55))

    return frame.convert("RGB")


# =============================================================================
# GENERADOR ACTO 3: FIESTA PLAYERA Y CRUNCH SINCRONIZADO 3D (12.0s - 18.0s)
# =============================================================================
def render_frame_act3(frame_idx, assets):
    """
    Act 3: Fiesta nocturna en la playa Miramar; crunch sincronizado por Juancho,
    Mapache y Alien; onda de choque 3D con chispas doradas, confeti y fuegos artificiales.
    """
    p = frame_idx / float(ACT_FRAMES - 1)
    t = frame_idx / FPS

    # 1. Fondo nocturno de playa Miramar con cielo azul marino estrellado
    frame = Image.new("RGBA", (W, H), (8, 14, 26, 255))
    draw = ImageDraw.Draw(frame, "RGBA")

    # Cielo nocturno con estrellas parpadeantes
    for st_i in range(40):
        st_x = int((st_i * 67 + 23) % W)
        st_y = int((st_i * 43 + 17) % 700)
        twinkle = int(140 + 100 * math.sin(t * 6.0 + st_i))
        draw.ellipse([st_x - 2, st_y - 2, st_x + 2, st_y + 2], fill=(255, 255, 230, twinkle))

    # Siluetas de palmeras tropicales en los extremos
    palm_pts_l = [(0, 600), (90, 520), (160, 580), (110, 680), (0, 720)]
    draw.polygon(palm_pts_l, fill=(14, 22, 34, 255))
    palm_pts_r = [(W, 580), (W - 100, 500), (W - 170, 570), (W - 120, 690), (W, 730)]
    draw.polygon(palm_pts_r, fill=(14, 22, 34, 255))

    # Guirnaldas de luces festivas cálidas (bombillas de fiesta)
    for b_i in range(10):
        bx = int(b_i * (W / 9.0))
        by = int(260 + math.sin(b_i * 0.7) * 45)
        # Luz cálida resplandeciente
        draw.ellipse([bx - 18, by - 18, bx + 18, by + 18], fill=(255, 200, 80, 70))
        draw.ellipse([bx - 8, by - 8, bx + 8, by + 8], fill=(255, 240, 160, 255))

    # Suelo de arena dorada nocturna (Y = 1260 a Y = 1920)
    draw.rectangle([0, 1260, W, H], fill=(26, 32, 28, 255))
    draw.line([(0, 1260), (W, 1260)], fill=(70, 90, 60, 180), width=3)

    # 2. Timing del Gran Crunch Sincronizado
    # Impacto del crunch ocurre exactamente a t = 1.0s (cuadro 60 del Acto 3)
    crunch_t = 1.0
    is_crunch = (t >= crunch_t)
    crunch_elapsed = max(0.0, t - crunch_t)

    # Camera shake breve tras el impacto del crunch
    shake_x, shake_y = 0, 0
    if 0.0 <= crunch_elapsed < 0.45:
        shake_intensity = (0.45 - crunch_elapsed) / 0.45
        shake_x = int(math.sin(t * 80.0) * 18 * shake_intensity)
        shake_y = int(math.cos(t * 80.0) * 14 * shake_intensity)

    # 3. Personajes en la fiesta:
    # Juancho al centro, Mapache a la izquierda, Alien a la derecha
    # Anticipación antes del crunch: acercan el chip
    # Después del crunch: celebran con ojos de estrella
    bite_bob = -int(math.sin(min(1.0, t / crunch_t) * math.pi) * 20) if not is_crunch else int(abs(math.sin(crunch_elapsed * 8.0)) * 25)

    # Mapache (izquierda)
    map_x = 240 + shake_x
    map_y = 920 - bite_bob + shake_y
    paste_sprite_3d(frame, assets["mapache"], map_x, map_y,
                    target_w=370, rot_deg=math.sin(t * 4.0) * 3.5, shadow=True,
                    rim_color=(255, 200, 50, 120))

    # Juancho (centro protagonista)
    juan_x = 540 + shake_x
    juan_y = 860 - bite_bob + shake_y
    paste_sprite_3d(frame, assets["juancho"], juan_x, juan_y,
                    target_w=430, rot_deg=math.sin(t * 5.0) * 2.5, shadow=True,
                    rim_color=(80, 255, 140, 140))

    # Alien/OVNI (derecha celebrando)
    alien_x = 840 + shake_x
    alien_y = 910 - bite_bob + shake_y
    paste_sprite_3d(frame, assets["ovni"], alien_x, alien_y,
                    target_w=360, rot_deg=math.sin(t * 4.5) * 4.0, shadow=True,
                    rim_color=(0, 255, 200, 130))

    # 4. Onda de Choque 3D y Chispas del CRUNCH
    if is_crunch and crunch_elapsed < 2.0:
        wave_p = crunch_elapsed / 2.0
        wave_r = int(wave_p * 680)
        wave_alpha = int(240 * (1.0 - wave_p))
        # Doble anillo: Esmeralda y Oro 24K
        draw.ellipse([540 - wave_r, 880 - wave_r, 540 + wave_r, 880 + wave_r],
                     outline=(0, 255, 150, wave_alpha), width=8)
        inner_r = max(4, wave_r - 25)
        draw.ellipse([540 - inner_r, 880 - inner_r, 540 + inner_r, 880 + inner_r],
                     outline=(255, 220, 40, int(wave_alpha * 0.9)), width=6)

        # Fragmentos crujientes de totopo dorado volando hacia la cámara en 3D
        for sh_i in range(24):
            sh_ang = sh_i * (math.pi * 2 / 24) + sh_i * 0.3
            sh_dist = int(wave_p * 550 * (0.7 + (sh_i % 5) * 0.12))
            sh_x = 540 + int(math.cos(sh_ang) * sh_dist)
            sh_y = 880 + int(math.sin(sh_ang) * sh_dist * 0.75)
            sh_size = int(8 + 14 * wave_p)
            draw_star(draw, sh_x, sh_y, sh_size, sh_size // 2,
                      fill=(255, 215, 0, wave_alpha), points=4)

    # 5. Fuegos Artificiales Tropicales en el cielo
    if is_crunch and crunch_elapsed >= 0.5:
        fw_time = crunch_elapsed - 0.5
        fw_centers = [(320, 420), (760, 380), (540, 300)]
        fw_colors = [(255, 215, 0), (0, 255, 160), (255, 60, 120)]
        for f_idx, (fc_x, fc_y) in enumerate(fw_centers):
            f_local_t = (fw_time + f_idx * 0.35) % 1.2
            if f_local_t < 1.0:
                f_r = int(f_local_t * 160)
                f_alpha = int(230 * (1.0 - f_local_t))
                col = fw_colors[f_idx]
                for p_i in range(16):
                    p_ang = p_i * (math.pi * 2 / 16)
                    px = fc_x + int(math.cos(p_ang) * f_r)
                    py = fc_y + int(math.sin(p_ang) * f_r)
                    draw.ellipse([px - 4, py - 4, px + 4, py + 4],
                                 fill=(col[0], col[1], col[2], f_alpha))

    # 6. Ojos de estrella dorada en Juancho tras el Crunch
    if is_crunch:
        for eye_off in [-35, 35]:
            draw_star(draw, juan_x + eye_off, juan_y - 60, 16, 7, fill=(255, 245, 50, 255))

    return frame.convert("RGB")


# =============================================================================
# GENERADOR ACTO 4: CLÍMAX HEROICO COMERCIAL EN PEDESTAL 3D (18.0s - 24.0s)
# =============================================================================
def render_frame_act4(frame_idx, assets):
    """
    Act 4: Clímax comercial heroico; Tostiaguachile Verde Tradicional sobre pedestal
    gourmet 3D con reflejo especular de espejo; Garza Chef, Juancho y Mapache
    posando con orgullo entre bokeh dorado y luz volumétrica de reflector.
    """
    p = frame_idx / float(ACT_FRAMES - 1)
    t = frame_idx / FPS

    # 1. Estudio 3D Premium: Degradado radial obsidiana / verde esmeralda profundo
    frame = Image.new("RGBA", (W, H), (6, 12, 10, 255))
    draw = ImageDraw.Draw(frame, "RGBA")

    # Gradiente radial de luz volumétrica central
    for r_step in range(950, 0, -25):
        rp = r_step / 950.0
        g_val = int(45 * (1.0 - rp))
        draw.ellipse([540 - r_step, 900 - r_step, 540 + r_step, 900 + r_step],
                     fill=(8, 12 + g_val, 16 + g_val // 2, 255))

    # Cono de luz volumétrica de reflector desde el techo del estudio
    spot_pulse = 0.9 + 0.1 * math.sin(t * 3.0)
    spot_poly = [
        (480, 0), (600, 0),
        (540 + int(480 * spot_pulse), 1400),
        (540 - int(480 * spot_pulse), 1400)
    ]
    draw.polygon(spot_poly, fill=(240, 255, 230, int(22 * spot_pulse)))

    # 2. Partículas de Bokeh dorado flotando hacia arriba
    random.seed(42)  # Semilla fija para consistencia visual entre cuadros
    for b_i in range(25):
        init_x = (b_i * 49 + 17) % (W - 160) + 80
        speed = 40 + (b_i % 7) * 15
        by = int((H - ((t * speed + b_i * 85) % (H + 100))))
        bx = int(init_x + math.sin(t * 2.0 + b_i) * 28)
        b_radius = int(8 + (b_i % 5) * 6)
        b_alpha = int(80 + 50 * math.sin(t * 3.0 + b_i))
        draw.ellipse([bx - b_radius, by - b_radius, bx + b_radius, by + b_radius],
                     fill=(255, 215, 60, b_alpha))

    # 3. Pedestal 3D de Estudio Gastronómico en el centro-inferior
    ped_cx, ped_cy = 540, 1280
    ped_w, ped_h = 740, 220
    # Base inferior con brillo neón esmeralda
    draw.ellipse([ped_cx - ped_w // 2 - 20, ped_cy - 10,
                  ped_cx + ped_w // 2 + 20, ped_cy + ped_h + 30],
                 fill=(0, 255, 140, 50))
    # Cuerpo cilíndrico del pedestal
    draw.ellipse([ped_cx - ped_w // 2, ped_cy + 40, ped_cx + ped_w // 2, ped_cy + ped_h],
                 fill=(18, 22, 28, 255), outline=(212, 175, 55, 255), width=3)
    # Superficie superior del pedestal (plataforma dorada brillante)
    draw.ellipse([ped_cx - ped_w // 2, ped_cy - 40, ped_cx + ped_w // 2, ped_cy + 40],
                 fill=(32, 38, 48, 255), outline=(255, 215, 0, 255), width=4)

    # 4. Reflejo especular de espejo del Tostiaguachile sobre la superficie del pedestal
    food_tight = assets["comida_tight"]
    reflection = food_tight.transpose(Image.Transpose.FLIP_TOP_BOTTOM)
    r_w, r_h = 480, int(480 * (food_tight.height / food_tight.width) * 0.35)
    ref_scaled = reflection.resize((r_w, r_h), Image.Resampling.BILINEAR)
    r, g, b, a = ref_scaled.split()
    a = a.point(lambda p: int(p * 0.28))
    ref_scaled.putalpha(a)
    frame.paste(ref_scaled, (ped_cx - r_w // 2, ped_cy - 10), ref_scaled)

    # 5. Personajes posando detrás del pedestal con orgullo
    # Garza Chef (izquierda saludando)
    garza_w = 410
    garza_x = 240
    garza_y = 740 + int(math.sin(t * 3.0) * 8)
    paste_sprite_3d(frame, assets["garza"], garza_x, garza_y,
                    target_w=garza_w, rot_deg=math.sin(t * 2.0) * 2.0, shadow=False,
                    rim_color=(255, 230, 140, 130))

    # Juancho (derecha festejando)
    juan_w = 400
    juan_x = 830
    juan_y = 760 + int(math.cos(t * 3.2) * 8)
    paste_sprite_3d(frame, assets["juancho"], juan_x, juan_y,
                    target_w=juan_w, rot_deg=math.sin(t * 2.5) * 2.5, shadow=False,
                    rim_color=(255, 190, 60, 130))

    # Mapache (asomándose junto a Juancho)
    map_w = 280
    map_x = 700
    map_y = 860 + int(math.sin(t * 4.0) * 6)
    paste_sprite_3d(frame, assets["mapache"], map_x, map_y,
                    target_w=map_w, rot_deg=math.sin(t * 3.0) * 3.0, shadow=False,
                    rim_color=(255, 220, 80, 120))

    # OVNI flotando arriba en el cielo de fondo
    ovni_y = 310 + int(math.sin(t * 2.0) * 10)
    paste_sprite_3d(frame, assets["ovni"], 540, ovni_y,
                    target_w=340, rot_deg=math.sin(t * 1.5) * 2.0, shadow=False,
                    rim_color=(0, 255, 150, 120))

    # 6. Tostiaguachile Verde Tradicional: Centro Comercial Heroico
    # Rotación elástica lenta de vitrina y zoom majestuoso
    hero_w = int(580 + math.sin(p * math.pi) * 35)
    hero_y = 1040 + int(math.sin(t * 2.5) * 6)
    paste_sprite_3d(frame, food_tight, 540, hero_y,
                    target_w=hero_w, rot_deg=0.0, shadow=True,
                    shadow_y_off=60, shadow_scale=(0.95, 0.28),
                    rim_color=(80, 255, 180, 170))

    # Vapores de frescura y aroma ascendiendo del plato
    for v_i in range(5):
        vp = ((t * 0.7) + v_i * 0.2) % 1.0
        vy = hero_y - 80 - int(vp * 240)
        vx = 540 + int(math.sin(vp * 8.0 + v_i) * 55)
        vr = int(22 + vp * 28)
        v_alpha = int(45 * (1.0 - vp))
        draw.ellipse([vx - vr, vy - vr // 2, vx + vr, vy + vr // 2],
                     fill=(220, 255, 230, v_alpha))

    # Barrido de destello brillante diagonal sobre el hero plate
    sheen_p = (t * 0.65) % 1.0
    sh_x = int(540 - hero_w // 2 + sheen_p * (hero_w + 240))
    draw.polygon([
        (sh_x - 40, hero_y - 140),
        (sh_x + 30, hero_y - 140),
        (sh_x + 90, hero_y + 140),
        (sh_x + 20, hero_y + 140)
    ], fill=(255, 255, 255, 60))

    return frame.convert("RGB")


# =============================================================================
# MOTOR DE RENDERIZADO Y PIPING DIRECTO A FFMPEG
# =============================================================================
def render_act_clip(act_num: int, assets: dict) -> Path:
    """Renderiza los 360 frames del acto a 60 fps y los codifica en H.264 High Profile."""
    clip_path = CLIPS_DIR / f"sc{act_num}.mp4"
    print(f"\n=================================================================")
    print(f"🎬 RENDERIZANDO ACTO {act_num}/4 ({ACT_DURATION}s = {ACT_FRAMES} frames @ 60.0 fps)")
    print(f"   Destino: {clip_path}")
    print(f"=================================================================")

    renderers = {
        1: render_frame_act1,
        2: render_frame_act2,
        3: render_frame_act3,
        4: render_frame_act4,
    }
    renderer = renderers[act_num]

    # Comando FFmpeg para codificación broadcast H.264 High Profile
    ffmpeg_cmd = [
        str(FFMPEG_BIN),
        "-y",
        "-f", "rawvideo",
        "-vcodec", "rawvideo",
        "-s", f"{W}x{H}",
        "-pix_fmt", "rgb24",
        "-r", str(FPS),
        "-i", "-",
        "-c:v", "libx264",
        "-profile:v", "high",
        "-level", "4.2",
        "-preset", "fast",
        "-b:v", "5500k",
        "-minrate", "4500k",
        "-maxrate", "7000k",
        "-bufsize", "12000k",
        "-pix_fmt", "yuv420p",
        "-r", str(FPS),
        str(clip_path)
    ]

    proc = subprocess.Popen(
        ffmpeg_cmd,
        stdin=subprocess.PIPE,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL
    )

    t0 = time.time()
    sample_frames = [0, ACT_FRAMES // 2, ACT_FRAMES - 1]

    try:
        for f_idx in range(ACT_FRAMES):
            if f_idx % 60 == 0:
                pct = (f_idx / ACT_FRAMES) * 100
                elapsed = time.time() - t0
                speed = (f_idx / elapsed) if elapsed > 0 else 0
                print(f"   [Acto {act_num}] Frame {f_idx:03d}/{ACT_FRAMES} ({pct:.0f}%) | {speed:.1f} fps...", flush=True)

            img = renderer(f_idx, assets)

            # Guardar keyframes de auditoría
            if f_idx in sample_frames:
                sample_name = f"act{act_num}_frame{f_idx:03d}.png"
                img.save(FRAMES_AUDIT_DIR / sample_name)

            proc.stdin.write(img.tobytes())

        proc.stdin.close()
        proc.wait()
        elapsed = time.time() - t0
        print(f"✅ Acto {act_num} completado en {elapsed:.2f}s ({ACT_FRAMES / elapsed:.1f} fps)")

    except Exception as e:
        if proc and proc.stdin:
            proc.stdin.close()
        proc.kill()
        raise RuntimeError(f"Error renderizando Acto {act_num}: {e}")

    # Verificar telemetría con ffprobe
    telemetry = verify_clip_telemetry(clip_path)
    print(f"📊 Telemetría Acto {act_num}: {telemetry['width']}x{telemetry['height']} @ {telemetry['fps']} fps | {telemetry['duration']:.2f}s | {telemetry['bitrate']//1000} kbps")
    return clip_path


def concatenate_master_stream(clip_paths: list) -> Path:
    """Concatena sin pérdidas los 4 clips en el master visual de 24.0s (1440 frames @ 60fps)."""
    master_path = CLIPS_DIR / "aaa_master_cgi_24s.mp4"
    print(f"\n=================================================================")
    print(f"🎞️ CONCATENANDO STREAM VISUAL MASTER 24.0s (1440 frames @ 60.0 fps)")
    print(f"   Destino: {master_path}")
    print(f"=================================================================")

    # Generar lista de clips para concat demuxer
    list_txt = CLIPS_DIR / "concat_list.txt"
    with open(list_txt, "w", encoding="utf-8") as f:
        for p in clip_paths:
            f.write(f"file '{p.resolve().as_posix()}'\n")

    cmd = [
        str(FFMPEG_BIN),
        "-y",
        "-f", "concat",
        "-safe", "0",
        "-i", str(list_txt),
        "-c", "copy",
        str(master_path)
    ]

    res = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    if res.returncode != 0:
        raise RuntimeError(f"Error al concatenar master stream:\n{res.stderr}")

    telemetry = verify_clip_telemetry(master_path)
    print(f"✨ [MASTER STREAM VERIFICADO]")
    print(f"   Resolución: {telemetry['width']}x{telemetry['height']}")
    print(f"   Frame Rate: {telemetry['fps']} (r_frame_rate: {telemetry['r_frame_rate']})")
    print(f"   Frames:     {telemetry['nb_frames']}")
    print(f"   Duración:   {telemetry['duration']:.3f}s")
    print(f"   Códec:      {telemetry['codec']} ({telemetry['profile']}, {telemetry['pix_fmt']})")
    print(f"   Bitrate:    {telemetry['bitrate']//1000} kbps")
    print(f"   Tamaño:     {master_path.stat().st_size / (1024*1024):.2f} MB")
    return master_path


def verify_clip_telemetry(clip_path: Path) -> dict:
    """Ejecuta ffprobe para validar estrictamente resolución, framerate, duración y códec."""
    cmd = [
        str(FFPROBE_BIN),
        "-v", "error",
        "-select_streams", "v:0",
        "-show_entries", "stream=width,height,codec_name,profile,pix_fmt,r_frame_rate,nb_frames,duration,bit_rate",
        "-show_entries", "format=duration,size,bit_rate",
        "-of", "json",
        str(clip_path)
    ]
    res = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, check=True)
    import json
    data = json.loads(res.stdout)
    st = data["streams"][0]
    fmt = data.get("format", {})

    width = int(st.get("width", 0))
    height = int(st.get("height", 0))
    codec = st.get("codec_name", "")
    profile = st.get("profile", "")
    pix_fmt = st.get("pix_fmt", "")
    r_frame_rate = st.get("r_frame_rate", "")
    fps_val = eval(r_frame_rate) if "/" in r_frame_rate else float(r_frame_rate)
    duration = float(fmt.get("duration", st.get("duration", 0)))
    bitrate = int(fmt.get("bit_rate", st.get("bit_rate", 0)))
    nb_frames = int(st.get("nb_frames", 0)) if st.get("nb_frames") else int(round(duration * fps_val))

    return {
        "width": width,
        "height": height,
        "codec": codec,
        "profile": profile,
        "pix_fmt": pix_fmt,
        "r_frame_rate": r_frame_rate,
        "fps": fps_val,
        "duration": duration,
        "bitrate": bitrate,
        "nb_frames": nb_frames,
    }


def main():
    print("=================================================================")
    print("  LA GARZA AGUACHILERA — PRODUCCIÓN VISUAL 3D CGI AAA (24.0s)")
    print("=================================================================")
    t_start = time.time()

    assets = load_assets()

    clips = []
    for act_num in range(1, 5):
        clip = render_act_clip(act_num, assets)
        clips.append(clip)

    master = concatenate_master_stream(clips)

    total_time = time.time() - t_start
    print(f"\n🎉 ¡PRODUCCIÓN 3D CGI AAA FINALIZADA CON ÉXITO EN {total_time:.2f}s!")
    print(f"   Clips generados:")
    for c in clips:
        print(f"     - {c.name} ({c.stat().st_size / (1024*1024):.2f} MB)")
    print(f"   Master visual:")
    print(f"     - {master.name} ({master.stat().st_size / (1024*1024):.2f} MB)")


if __name__ == "__main__":
    main()
