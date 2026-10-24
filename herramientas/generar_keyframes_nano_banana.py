#!/usr/bin/env python3
"""
herramientas/generar_keyframes_nano_banana.py
---------------------------------------------
Generador y Gestor de Keyframes 2D Cel-Shaded Estilo Cartoon Network
para el Episodio Animado de La Garza Aguachilera ($170 MXN).

Genera y normaliza los 12 cuadros clave (start y end de Escenas 1 a 6)
en formato vertical 9:16 (1080x1920 PNG), condicionados en el arte oficial
y los modelos de personajes de Tampico / Playa Miramar.
"""

import os
import sys
import glob
import math
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont, ImageStat, ImageFilter

# Configuración de rutas
WORKSPACE_DIR = Path(__file__).resolve().parent.parent
FRAMES_DIR = WORKSPACE_DIR / "FRAMES"
BRAIN_DIR = Path(r"C:\Users\aleja\.gemini\antigravity\brain\326fe189-01fd-4575-9304-3e260d103241")

TARGET_WIDTH = 1080
TARGET_HEIGHT = 1920

# Catálogo de los 12 keyframes oficiales
KEYFRAME_SPECS = [
    {
        "name": "scene1_start",
        "scene": 1,
        "type": "start",
        "title": "Juancho Zombie emergiendo de Laguna del Carpintero",
        "desc": "Juancho el cocodrilo zombie saliendo del agua turbia de la laguna entre manglares y tormenta, camisa hawaiana rota, gafas chuecas y lengua de fuera por cruda extrema.",
        "cache_pattern": "scene1_start_*.jpg",
        "ref": "clean_juancho.png"
    },
    {
        "name": "scene1_end",
        "scene": 1,
        "type": "end",
        "title": "Juancho Zombie en agonia comica por la cruda",
        "desc": "Juancho de pie en la orilla lodosa sujetandose la cabeza con ambas garras en dolor comico, moscas zumbando y cielo morado con relampagos.",
        "cache_pattern": "scene1_end_*.jpg",
        "ref": "clean_juancho.png"
    },
    {
        "name": "scene2_start",
        "scene": 2,
        "type": "start",
        "title": "Freddy Mapache hambriento en Escolleras Miramar",
        "desc": "El mapache con sueter a rayas rojas y verdes, sombrero fedora y garra de cuchillas parado en los tetrapodos de Miramar, muriendo de hambre y cruda.",
        "cache_pattern": "scene2_start_*.jpg",
        "ref": "sticker_spooky_mapache_freddy.png"
    },
    {
        "name": "scene2_end",
        "scene": 2,
        "type": "end",
        "title": "Freddy Mapache chocando sus garras con chispas",
        "desc": "Freddy Mapache frotando sus cuchillas con chispas amarillas, sonrisa comica y loca esperando curar su cruda con algo picante.",
        "cache_pattern": "scene2_end_*.jpg",
        "ref": "sticker_spooky_mapache_freddy.png"
    },
    {
        "name": "scene3_start",
        "scene": 3,
        "type": "start",
        "title": "OVNI Miramar con rayo tractor esmeralda",
        "desc": "Platillo volador con motivos de calavera de Dia de Muertos y flores de cempasuchil disparando su rayo verde hacia la arena de Miramar.",
        "cache_pattern": "scene3_start_*.jpg",
        "ref": "sticker_spooky_ovni_muertos.png"
    },
    {
        "name": "scene3_end",
        "scene": 3,
        "type": "end",
        "title": "Abduccion de limones Colima y hielera a 2C",
        "desc": "El rayo del OVNI abduciendo una hielera marcada 2C, cubos de hielo y limones Colima verdes flotando en el rayo neón.",
        "cache_pattern": "scene3_end_*.jpg",
        "ref": "sticker_spooky_ovni_muertos.png"
    },
    {
        "name": "scene4_start",
        "scene": 4,
        "type": "start",
        "title": "Climax del Crunch - Tostiaguachile Verde Tradicional $170 MXN",
        "desc": "Bolsa abierta de Tostitos Salsa Verde con camaron mariposa (~100g), pepino, cebolla morada, aguachile verde y estallido CRUNCH! a $170 MXN.",
        "cache_pattern": "scene4_start_*.jpg",
        "ref": "clean_comida.png"
    },
    {
        "name": "scene4_end",
        "scene": 4,
        "type": "end",
        "title": "Resurreccion Blast - Despertar de Juancho y Mapache",
        "desc": "Relampago esmeralda transformando a Juancho y al Mapache; los espiritus zombies son expulsados y Juancho despierta con ojos de estrella dorada.",
        "cache_pattern": "scene4_end_*.jpg",
        "ref": "clean_juancho.png"
    },
    {
        "name": "scene5_start",
        "scene": 5,
        "type": "start",
        "title": "Fiesta Miramar - Inicio del Festejo Playero",
        "desc": "Playa Miramar soleada, Juancho vivo y radiante con gafas oscuras celebrando junto al mapache y el alienigena con platos de Tostiaguachile.",
        "cache_pattern": "scene5_start_*.jpg",
        "ref": "clean_juancho.png"
    },
    {
        "name": "scene5_end",
        "scene": 5,
        "type": "end",
        "title": "Fiesta Miramar - Baile de Juancho con Ojos de Estrella",
        "desc": "Juancho bailando con ojos de estrella mientras sostiene un tazon gigante de Tostiaguachile Verde Tradicional, confeti, musica y alegria tropical.",
        "cache_pattern": "scene5_end_*.jpg",
        "ref": "clean_juancho.png"
    },
    {
        "name": "scene6_start",
        "scene": 6,
        "type": "start",
        "title": "Cierre Comercial - Kiosco Playero de La Garza Aguachilera",
        "desc": "Puesto playero tropical de madera de La Garza Aguachilera con la garza chef en delantal blanco y gorro, hielera, limones y camaron fresco.",
        "cache_pattern": "scene6_start_*.jpg",
        "ref": "card_real_food.png"
    },
    {
        "name": "scene6_end",
        "scene": 6,
        "type": "end",
        "title": "Cierre Comercial - Ficha Tecnica Comercial $170 MXN",
        "desc": "Ficha comercial televisiva estilo Cartoon Network con horarios (Sab-Dom 1-5 PM), Tampico Tampico, WhatsApp 833 252 09 88 y precio $170 MXN.",
        "cache_pattern": "scene6_end_*.jpg",
        "ref": "card_real_food.png"
    }
]

def draw_text_stroke(d, text, pos, font, fill, stroke_fill=(0, 0, 0), stroke_w=4, anchor="mm"):
    x, y = pos
    for dx in range(-stroke_w, stroke_w + 1):
        for dy in range(-stroke_w, stroke_w + 1):
            if dx * dx + dy * dy <= stroke_w * stroke_w:
                d.text((x + dx, y + dy), text, font=font, fill=stroke_fill, anchor=anchor)
    d.text((x, y), text, font=font, fill=fill, anchor=anchor)

def generar_scene4_start_170(base_image_path: Path, output_png_path: Path):
    """
    Re-pinta el estallido cómico inferior derecho de scene4_start con '$170 MXN'
    en estilo Cartoon Network 2D cel-shaded cubriendo al 100% cualquier rastro previo.
    """
    print(f"Generando estallido comico $170 MXN en 1080x1920: {output_png_path.name}...")
    base = Image.open(base_image_path).convert("RGBA").resize((TARGET_WIDTH, TARGET_HEIGHT), Image.Resampling.LANCZOS)
    overlay = Image.new("RGBA", (TARGET_WIDTH, TARGET_HEIGHT), (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)

    cx, cy = 778, 1605
    num_spikes = 16

    def make_star_poly(center_x, center_y, r_outer, r_inner, phase_deg=-11.0):
        pts = []
        for i in range(num_spikes * 2):
            ang = math.radians(phase_deg + i * (180.0 / num_spikes))
            # Ligera asimetría dinámica estilo cómic
            jitter = 1.06 if (i % 4 == 0) else (0.96 if (i % 4 == 2) else 1.0)
            r = (r_outer * jitter) if (i % 2 == 0) else (r_inner * (2.0 - jitter))
            pts.append((center_x + r * math.cos(ang), center_y + r * math.sin(ang)))
        return pts

    # Resplandor cálido exterior para cubrir por completo las puntas previas
    glow_layer = Image.new("RGBA", (TARGET_WIDTH, TARGET_HEIGHT), (0, 0, 0, 0))
    gdraw = ImageDraw.Draw(glow_layer)
    gdraw.polygon(make_star_poly(cx, cy, 342, 228), fill=(255, 240, 150, 235))
    glow_layer = glow_layer.filter(ImageFilter.GaussianBlur(radius=14))
    overlay = Image.alpha_composite(overlay, glow_layer)
    draw = ImageDraw.Draw(overlay)

    # Capas cel-shaded de la estrella cómica (borde negro grueso -> rojo/naranja -> amarillo brillante)
    draw.polygon(make_star_poly(cx + 8, cy + 10, 332, 212), fill=(0, 0, 0, 220))
    draw.polygon(make_star_poly(cx, cy, 332, 212), fill=(15, 10, 10, 255))
    draw.polygon(make_star_poly(cx, cy, 316, 198), fill=(230, 52, 18, 255))
    draw.polygon(make_star_poly(cx, cy, 294, 182), fill=(255, 145, 15, 255))
    draw.polygon(make_star_poly(cx, cy, 268, 165), fill=(255, 238, 55, 255))

    # Texto cómico inclinado "$170" y "MXN" con gradiente naranja-amarillo y contorno 3D negro
    txt_canvas = Image.new("RGBA", (700, 500), (0, 0, 0, 0))
    tdraw = ImageDraw.Draw(txt_canvas)
    try:
        font_big = ImageFont.truetype("impact.ttf", 162)
        font_sub = ImageFont.truetype("impact.ttf", 86)
    except Exception:
        font_big = font_sub = ImageFont.load_default()

    # Sombra 3D cómica + contorno negro grueso para "$170"
    for ox in range(-10, 15):
        for oy in range(-10, 18):
            if ox * ox + oy * oy <= 110 or (0 <= ox <= 12 and 0 <= oy <= 14):
                tdraw.text((350 + ox, 195 + oy), "$170", font=font_big, fill=(10, 10, 10, 255), anchor="mm")
    tdraw.text((350, 195), "$170", font=font_big, fill=(255, 195, 20, 255), anchor="mm")

    # Sombra 3D cómica + contorno negro grueso para "MXN"
    for ox in range(-8, 12):
        for oy in range(-8, 14):
            if ox * ox + oy * oy <= 72 or (0 <= ox <= 9 and 0 <= oy <= 11):
                tdraw.text((365 + ox, 330 + oy), "MXN", font=font_sub, fill=(10, 10, 10, 255), anchor="mm")
    tdraw.text((365, 330), "MXN", font=font_sub, fill=(255, 140, 20, 255), anchor="mm")

    txt_rotated = txt_canvas.rotate(10, resample=Image.Resampling.BICUBIC, expand=True)
    tx = cx - txt_rotated.width // 2
    ty = cy - txt_rotated.height // 2 + 8
    overlay.alpha_composite(txt_rotated, (tx, ty))

    final_img = Image.alpha_composite(base, overlay).convert("RGB")
    final_img.save(output_png_path, format="PNG")
    print(f"-> {output_png_path.name} actualizado con $170 MXN ({output_png_path.stat().st_size} bytes).")


def generar_scene6_end_comercial(base_image_path: Path, output_png_path: Path):
    """
    Compone el cuadro final del cierre comercial (scene6_end) con calidad de emision
    estilo Cartoon Network TV, integrando la ficha tecnica y datos comerciales exactos.
    """
    print(f"Generando cierre comercial televisivo 1080x1920: {output_png_path.name}...")
    base = Image.open(base_image_path).convert("RGBA").resize((TARGET_WIDTH, TARGET_HEIGHT), Image.Resampling.LANCZOS)
    overlay = Image.new("RGBA", (TARGET_WIDTH, TARGET_HEIGHT), (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)

    # Cargar tipografías del sistema
    try:
        font_xl = ImageFont.truetype("impact.ttf", 74)
        font_lg = ImageFont.truetype("impact.ttf", 58)
        font_md = ImageFont.truetype("impact.ttf", 44)
        font_sm = ImageFont.truetype("impact.ttf", 34)
        font_bd = ImageFont.truetype("arialbd.ttf", 30)
        font_reg = ImageFont.truetype("arialbd.ttf", 24)
    except Exception:
        font_xl = font_lg = font_md = font_sm = font_bd = font_reg = ImageFont.load_default()

    # Banner Superior: Titular de Marca
    top_y = 50
    top_h = 240
    draw.rounded_rectangle([35, top_y, TARGET_WIDTH - 35, top_y + top_h], radius=25, fill=(18, 24, 38, 235), outline=(255, 215, 0, 255), width=6)
    draw_text_stroke(draw, "LA GARZA AGUACHILERA", (TARGET_WIDTH // 2, top_y + 55), font_xl, (255, 235, 50), stroke_w=5)
    draw_text_stroke(draw, "TOSTIAGUACHILE VERDE TRADICIONAL", (TARGET_WIDTH // 2, top_y + 125), font_md, (80, 255, 140), stroke_w=4)
    draw_text_stroke(draw, "Preparado al momento frente a usted para corroborar su frescura", (TARGET_WIDTH // 2, top_y + 190), font_reg, (255, 255, 255), stroke_w=3)

    # Medallon de Precio Estrella en el lateral izquierdo
    star_cx, star_cy = 230, 1160
    draw.ellipse([star_cx - 165, star_cy - 120, star_cx + 165, star_cy + 120], fill=(230, 35, 35, 245), outline=(255, 230, 40, 255), width=8)
    draw_text_stroke(draw, "PRECIO ESPECIAL", (star_cx, star_cy - 50), font_sm, (255, 255, 255), stroke_w=4)
    draw_text_stroke(draw, "$170 MXN", (star_cx, star_cy + 15), font_xl, (255, 235, 50), stroke_w=6)
    draw_text_stroke(draw, "~100g Camaron Mariposa", (star_cx, star_cy + 75), font_reg, (255, 255, 255), stroke_w=3)

    # Mascota Juancho en lateral derecho
    juancho_path = WORKSPACE_DIR / "clean_juancho.png"
    if juancho_path.exists():
        j_img = Image.open(juancho_path).convert("RGBA")
        j_w = 430
        j_h = int(j_img.height * (j_w / j_img.width))
        j_img = j_img.resize((j_w, j_h), Image.Resampling.LANCZOS)
        overlay.paste(j_img, (TARGET_WIDTH - j_w - 15, 975), j_img)

    # Tarjeta Comercial Inferior: Horario, Ubicación y Pedidos
    bot_y = 1530
    bot_h = 340
    draw.rounded_rectangle([35, bot_y, TARGET_WIDTH - 35, bot_y + bot_h], radius=30, fill=(18, 24, 38, 245), outline=(50, 220, 120, 255), width=6)
    draw_text_stroke(draw, "HORARIO Y UBICACION", (TARGET_WIDTH // 2, bot_y + 45), font_md, (255, 215, 0), stroke_w=4)
    draw_text_stroke(draw, "Sabados y Domingos | Servicio en Rutas Activas", (TARGET_WIDTH // 2, bot_y + 105), font_bd, (255, 255, 255), stroke_w=3)
    draw_text_stroke(draw, "Ubicacion: Tampico y Madero", (TARGET_WIDTH // 2, bot_y + 160), font_bd, (180, 240, 255), stroke_w=3)

    # Boton WhatsApp
    wa_y = bot_y + 250
    draw.rounded_rectangle([90, wa_y - 42, TARGET_WIDTH - 90, wa_y + 42], radius=25, fill=(37, 211, 102, 255), outline=(255, 255, 255, 255), width=4)
    draw_text_stroke(draw, "PEDIDOS WHATSAPP: 833 252 09 88", (TARGET_WIDTH // 2, wa_y), font_lg, (255, 255, 255), stroke_fill=(0, 90, 25), stroke_w=4)

    final_img = Image.alpha_composite(base, overlay).convert("RGB")
    final_img.save(output_png_path, format="PNG")
    print(f"-> {output_png_path.name} guardado con exito ({output_png_path.stat().st_size} bytes).")

def procesar_y_validar_keyframes():
    """
    Procesa todos los keyframes generados por Nano Banana / gemini-image, los escala
    a 1080x1920 con filtro Lanczos y genera los 12 archivos PNG en FRAMES/.
    """
    FRAMES_DIR.mkdir(parents=True, exist_ok=True)
    print(f"=== INICIANDO PROCESAMIENTO DE KEYFRAMES EN {FRAMES_DIR} ===")

    resultados = []

    for spec in KEYFRAME_SPECS:
        name = spec["name"]
        out_png = FRAMES_DIR / f"{name}.png"
        print(f"\n[Procesando {name}] {spec['title']}")

        # Si es scene6_end, componemos el cierre comercial a partir de scene6_start
        if name == "scene6_end":
            s6_start_cache = sorted(BRAIN_DIR.glob("scene6_start_*.jpg")) if BRAIN_DIR.exists() else []
            s6_base = s6_start_cache[-1] if s6_start_cache else (FRAMES_DIR / "scene6_start.png")
            if s6_base.exists():
                generar_scene6_end_comercial(s6_base, out_png)
            else:
                raise FileNotFoundError("No se encontro la imagen base para scene6_start.")
        elif name == "scene4_start":
            s4_cache = sorted(BRAIN_DIR.glob("scene4_start_*.jpg")) if BRAIN_DIR.exists() else []
            s4_base = s4_cache[-1] if s4_cache else out_png
            if s4_base.exists():
                generar_scene4_start_170(s4_base, out_png)
            else:
                raise FileNotFoundError("No se encontro la imagen base para scene4_start.")
        else:
            # Buscar la imagen en el directorio de cache del modelo o usar existente en FRAMES/
            matches = sorted(BRAIN_DIR.glob(spec["cache_pattern"])) if BRAIN_DIR.exists() else []
            if not matches and BRAIN_DIR.exists():
                alt_matches = sorted(BRAIN_DIR.glob(f"*{name}*.jpg"))
                if alt_matches:
                    matches = alt_matches
            
            src_file = matches[-1] if matches else out_png
            if not src_file.exists():
                raise FileNotFoundError(f"No se encontro imagen generada para {name}")
            print(f"Cargando origen: {src_file.name}")
            img = Image.open(src_file).convert("RGB")

            # Re-muestreo a vertical 9:16 de alta definicion (1080x1920)
            if img.size != (TARGET_WIDTH, TARGET_HEIGHT):
                print(f"Escalando de {img.size} a ({TARGET_WIDTH}, {TARGET_HEIGHT}) con filtro Lanczos...")
                img_resized = img.resize((TARGET_WIDTH, TARGET_HEIGHT), Image.Resampling.LANCZOS)
            else:
                img_resized = img

            # Guardar en formato PNG lossless RGB
            img_resized.save(out_png, format="PNG", optimize=True)
            print(f"-> Guardado {out_png.name} ({out_png.stat().st_size} bytes)")

        # Validacion del archivo
        im_check = Image.open(out_png).convert("RGB")
        stat = ImageStat.Stat(im_check)
        is_blank = any(stddev < 5.0 for stddev in stat.stddev[:3])
        file_size = out_png.stat().st_size

        if file_size < 100_000:
            raise ValueError(f"Alerta QA: {out_png.name} tiene un peso anormalmente bajo: {file_size} bytes")
        if is_blank:
            raise ValueError(f"Alerta QA: {out_png.name} parece ser una imagen vacia o monocromatica")

        resultados.append({
            "name": out_png.name,
            "dimensions": f"{TARGET_WIDTH}x{TARGET_HEIGHT}",
            "size_kb": round(file_size / 1024, 1),
            "status": "VALIDADO_QA"
        })

    print("\n" + "=" * 60)
    print("RESUMEN DE VERIFICACION DE 12 KEYFRAMES (CARTOON NETWORK 2D)")
    print("=" * 60)
    for r in resultados:
        print(f"OK | {r['name']:<18} | {r['dimensions']} | {r['size_kb']:>7} KB | {r['status']}")
    print("=" * 60)
    print("Todos los 12 keyframes existen, tienen dimensiones 1080x1920 y pasan QA.")

if __name__ == "__main__":
    procesar_y_validar_keyframes()
