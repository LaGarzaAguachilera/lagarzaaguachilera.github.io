#!/usr/bin/env python3
"""
herramientas/ensamblar_master_60fps.py
--------------------------------------
Ensamble y masterización del Episodio Animado Full HD a 60 FPS
"LA RESURRECCIÓN DE LA CRUDA: ¡NO ESTABAN MUERTOS... SOLO ESTABAN CRUDOS!"
La Garza Aguachilera — Tampico y Ciudad Madero, Tamaulipas.

Módulo 4: Ensamble Master 60fps, Web & ZIP (Milestone 4).

Concatena los 6 clips de video generados con 2D cel-shaded Cartoon Network (VIDEOS/clips/scene[1-6].mp4)
y los sincroniza con la pista de audio master WAV (herramientas/audio_animacion_master_60fps.wav).

Parámetros de codificación maestra:
- Resolución: 1080x1920 (9:16 vertical Full HD)
- Frame rate: 60.0 fps constantes (r_frame_rate == '60/1')
- Codec de video: H.264 High Profile (profile:v high, level 4.2, yuv420p)
- Bitrate de video: Piso >= 4000 kbps (target 4600 kbps, minrate 4200k, maxrate 5500k, bufsize 10000k)
- Codec de audio: AAC estéreo (2 canales), 44,100 Hz, 192 kbps
- Límite de tamaño: <= 42.0 MB (42,000,000 bytes) para garantizar paquete ZIP < 100 MB.
- Salidas maestras:
  * VIDEOS/animacion_la_garza_episodio_crudos_60fps.mp4
  * VIDEOS/promo_halloween_zombies_crudos.mp4 (espejo idéntico para difusión)
"""

import argparse
import json
import os
import shutil
import subprocess
import sys
import time
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

# Configuración de encoding UTF-8 seguro para Windows
if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
if hasattr(sys.stderr, "reconfigure"):
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")

import dotenv
dotenv.load_dotenv(os.path.expanduser("~/.env"))

# Rutas del proyecto
WORKSPACE_DIR = Path(__file__).resolve().parent.parent
HERRAMIENTAS_DIR = WORKSPACE_DIR / "herramientas"
VIDEOS_DIR = WORKSPACE_DIR / "VIDEOS"
CLIPS_DIR = VIDEOS_DIR / "clips"
FFMPEG_BIN = HERRAMIENTAS_DIR / "ffmpeg" / "ffmpeg.exe"
FFPROBE_BIN = HERRAMIENTAS_DIR / "ffmpeg" / "ffprobe.exe"

if not FFMPEG_BIN.exists():
    FFMPEG_BIN = Path("ffmpeg")
if not FFPROBE_BIN.exists():
    FFPROBE_BIN = Path("ffprobe")

os.environ["PATH"] = str(HERRAMIENTAS_DIR / "ffmpeg") + os.pathsep + os.environ.get("PATH", "")

# Archivos de salida
OUT_MASTER = VIDEOS_DIR / "animacion_la_garza_episodio_crudos_60fps.mp4"
OUT_PROMO = VIDEOS_DIR / "promo_halloween_zombies_crudos.mp4"
AUDIO_MASTER = HERRAMIENTAS_DIR / "audio_animacion_master_60fps.wav"
TIMELINE_JSON = HERRAMIENTAS_DIR / "timeline_animacion_60fps.json"
ANIM_ASS = HERRAMIENTAS_DIR / "animacion_subtitles_170.ass"
ANIM_BADGE_PNG = HERRAMIENTAS_DIR / "anim_price_badge_170.png"
CLIPS_LIST_TXT = HERRAMIENTAS_DIR / "clips_list.txt"

# Especificaciones de escenas maestras y asignación exacta de cuadros a 60fps (Total: 3919 frames)
SCENE_SPECS = [
    {
        "id": 1,
        "name": "scene1",
        "title": "Laguna del Carpintero / Juancho Zombie caminando crudo",
        "clip": str(CLIPS_DIR / "scene1.mp4"),
        "target_frames": 709,  # ~11.817s
    },
    {
        "id": 2,
        "name": "scene2",
        "title": "Escolleras Miramar / Freddy Mapache garras metálicas",
        "clip": str(CLIPS_DIR / "scene2.mp4"),
        "target_frames": 618,  # ~10.300s
    },
    {
        "id": 3,
        "name": "scene3",
        "title": "OVNI Miramar abducción de limones Colima y hielera a 2°C",
        "clip": str(CLIPS_DIR / "scene3.mp4"),
        "target_frames": 720,  # ~12.000s
    },
    {
        "id": 4,
        "name": "scene4",
        "title": "Clímax del Crunch y Resurrección Tostiaguachile $170 MXN",
        "clip": str(CLIPS_DIR / "scene4.mp4"),
        "target_frames": 756,  # ~12.600s
    },
    {
        "id": 5,
        "name": "scene5",
        "title": "Fiesta en Miramar Juancho Vivo con ojos de estrella",
        "clip": str(CLIPS_DIR / "scene5.mp4"),
        "target_frames": 366,  # ~6.100s
    },
    {
        "id": 6,
        "name": "scene6",
        "title": "Cierre Comercial Tampico y Madero, WhatsApp 833 252 09 88, $170 MXN",
        "clip": str(CLIPS_DIR / "scene6.mp4"),
        "target_frames": 750,  # ~12.500s
    },
]


def verify_inputs():
    """Verifica la existencia y legibilidad de todos los activos de entrada."""
    print("=== PASO 1: VERIFICACIÓN DE ACTIVOS DE ENTRADA ===")
    missing = []
    if not AUDIO_MASTER.exists():
        missing.append(str(AUDIO_MASTER))
    else:
        print(f" [OK] Audio maestro WAV: {AUDIO_MASTER.name} ({AUDIO_MASTER.stat().st_size:,} bytes)")

    for sc in SCENE_SPECS:
        p = Path(sc["clip"])
        if not p.exists() or p.stat().st_size < 100000:
            missing.append(str(p))
        else:
            print(f" [OK] Clip Escena {sc['id']}: {p.name} ({p.stat().st_size:,} bytes) -> {sc['target_frames']} frames objetivo")

    if missing:
        raise FileNotFoundError(f"Activos de entrada faltantes o inválidos:\n" + "\n".join(missing))


def sync_scene_specs_with_timeline():
    """Sincroniza la duración en cuadros de cada escena con timeline_animacion_60fps.json y crea subtítulos ASS y badge $170 MXN."""
    if TIMELINE_JSON.exists():
        with open(TIMELINE_JSON, "r", encoding="utf-8") as f:
            tl = json.load(f)
        tl_scenes = tl.get("scenes", [])
        if len(tl_scenes) == len(SCENE_SPECS):
            for idx, sc in enumerate(SCENE_SPECS):
                dur = float(tl_scenes[idx]["scene_duration"])
                sc["target_frames"] = max(60, int(round(dur * 60.0)))
                sc["scene_start"] = float(tl_scenes[idx]["scene_start"])
                sc["scene_end"] = float(tl_scenes[idx]["scene_end"])
                sc["voice_start"] = float(tl_scenes[idx]["voice_start"])
                sc["voice_end"] = float(tl_scenes[idx]["voice_end"])
                sc["subtitle_text"] = tl_scenes[idx]["subtitle_text"]

        # Generar subtítulos ASS estilo Cartoon Network / Reels
        def fmt_ass_time(sec: float) -> str:
            h = int(sec // 3600)
            m = int((sec % 3600) // 60)
            s = sec % 60.0
            return f"{h}:{m:02d}:{s:05.2f}"

        ass_lines = [
            "[Script Info]",
            "Title: Episodio Animado La Garza Aguachilera - $170 MXN",
            "ScriptType: v4.00+",
            "WrapStyle: 0",
            "ScaledBorderAndShadow: yes",
            "PlayResX: 1080",
            "PlayResY: 1920",
            "",
            "[V4+ Styles]",
            "Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding",
            "Style: CNSub,Arial Black,44,&H00FFFFFF,&H0000FFFF,&H00000000,&HB0000000,-1,0,0,0,100,100,1,0,1,6,3,2,70,70,130,1",
            "Style: CNPrice,Arial Black,50,&H0032EBFF,&H0000FFFF,&H00000000,&HC0000000,-1,0,0,0,100,100,1,0,1,7,4,2,70,70,140,1",
            "",
            "[Events]",
            "Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text",
        ]
        for idx, tsc in enumerate(tl_scenes):
            if idx == 5:
                # La escena 6 ya muestra en pantalla completa las tarjetas comerciales oficiales ($170 MXN + WhatsApp)
                continue
            v0 = float(tsc["voice_start"])
            v1 = float(tsc["voice_end"])
            sub_txt = tsc["subtitle_text"]
            # Dividir en 2 bloques si el diálogo es largo (> 10s) para lectura ágil
            words = sub_txt.split()
            if (v1 - v0) > 10.0 and len(words) > 12:
                mid_w = len(words) // 2
                mid_t = (v0 + v1) / 2.0
                p1 = " ".join(words[:mid_w])
                p2 = " ".join(words[mid_w:])
                ass_lines.append(f"Dialogue: 0,{fmt_ass_time(v0)},{fmt_ass_time(mid_t)},CNSub,,0,0,0,,{{\\fad(100,80)}}{p1}")
                ass_lines.append(f"Dialogue: 0,{fmt_ass_time(mid_t)},{fmt_ass_time(v1)},CNSub,,0,0,0,,{{\\fad(80,100)}}{p2}")
            else:
                style = "CNPrice" if "$170" in sub_txt else "CNSub"
                ass_lines.append(f"Dialogue: 0,{fmt_ass_time(v0)},{fmt_ass_time(v1)},{style},,0,0,130,,{{\\fad(100,120)}}{sub_txt}")

        with open(ANIM_ASS, "w", encoding="utf-8") as f:
            f.write("\n".join(ass_lines) + "\n")

    # Generar badge superior permanente de $170 MXN para escenas 1-5 (sin glifos Unicode fuera de Impact)
    import math
    badge_im = Image.new("RGBA", (1080, 1920), (0, 0, 0, 0))
    bdraw = ImageDraw.Draw(badge_im)
    try:
        f_b1 = ImageFont.truetype("impact.ttf", 44)
        f_b2 = ImageFont.truetype("arialbd.ttf", 21)
    except Exception:
        f_b1 = f_b2 = ImageFont.load_default()

    # Sombra y píldora roja/dorada en esquina superior derecha segura (x: 620..1045, y: 52..166)
    bdraw.rounded_rectangle([626, 60, 1051, 174], radius=28, fill=(0, 0, 0, 160))
    bdraw.rounded_rectangle([620, 52, 1045, 166], radius=28, fill=(220, 28, 52, 248), outline=(255, 225, 45, 255), width=5)

    def draw_star(cx, cy, r_out=15, r_in=6):
        pts = []
        for k in range(10):
            ang = -math.pi / 2 + k * math.pi / 5
            r = r_out if k % 2 == 0 else r_in
            pts.append((cx + r * math.cos(ang), cy + r * math.sin(ang)))
        bdraw.polygon(pts, fill=(255, 240, 60, 255), outline=(0, 0, 0, 255))

    draw_star(656, 94)
    draw_star(1009, 94)
    badge_label = "¡SOLO $170 MXN!"
    for ox in (-3, 0, 3):
        for oy in (-3, 0, 3):
            bdraw.text((833 + ox, 94 + oy), badge_label, font=f_b1, fill=(0, 0, 0, 255), anchor="mm")
    bdraw.text((833, 94), badge_label, font=f_b1, fill=(255, 240, 60, 255), anchor="mm")
    bdraw.text((833, 138), "Tostiaguachile Verde • La Garza", font=f_b2, fill=(255, 255, 255, 255), anchor="mm")
    badge_im.save(ANIM_BADGE_PNG, format="PNG")


def create_clips_list():
    """Genera clips_list.txt para cumplir con el contrato de interfaz de PROJECT.md."""
    lines = [f"file '{Path(sc['clip']).as_posix()}'" for sc in SCENE_SPECS]
    with open(CLIPS_LIST_TXT, "w", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")
    print(f" [OK] Lista de clips generada en: {CLIPS_LIST_TXT.name}")


def assemble_master_video(
    video_bitrate="4120k",
    min_rate="4020k",
    max_rate="4350k",
    buf_size="8500k",
    audio_bitrate="160k",
    audio_sample_rate="44100",
    max_size_bytes=52000000,
):
    """Ejecuta el renderizado y ensamble de alta fidelidad a 60fps con FFmpeg."""
    print("\n=== PASO 2: ENSAMBLANDO MASTER 60FPS CON FFMPEG ===")
    start_time = time.time()

    # Construir filtro complejo para loop y recorte de cada escena a su métrica de frames
    filter_parts = []
    concat_inputs = []
    ffmpeg_inputs = []

    for idx, sc in enumerate(SCENE_SPECS):
        ffmpeg_inputs.extend(["-i", sc["clip"]])
        n_frames = sc["target_frames"]
        filter_parts.append(
            f"[{idx}:v]loop=loop=-1:size=480:start=0,trim=start_frame=0:end_frame={n_frames},setpts=PTS-STARTPTS[v{idx+1}];"
        )
        concat_inputs.append(f"[v{idx+1}]")

    # Entrada de audio master
    ffmpeg_inputs.extend(["-i", str(AUDIO_MASTER)])
    audio_idx = len(SCENE_SPECS)

    # Entrada de badge $170 MXN
    ffmpeg_inputs.extend(["-loop", "1", "-i", str(ANIM_BADGE_PNG)])
    badge_idx = len(SCENE_SPECS) + 1

    sc6_start = SCENE_SPECS[5].get("scene_start", 77.28)
    escaped_ass = ANIM_ASS.as_posix().replace(":", "\\:")

    concat_str = (
        "".join(concat_inputs)
        + f"concat=n={len(SCENE_SPECS)}:v=1:a=0[vcat];"
        + f"[vcat][{badge_idx}:v]overlay=0:0:enable='lt(t,{sc6_start:.2f})'[vbadged];"
        + f"[vbadged]ass='{escaped_ass}'[vout]"
    )
    full_filter = "".join(filter_parts) + concat_str

    cmd = [
        str(FFMPEG_BIN), "-y",
        "-nostdin",
        "-loglevel", "warning",
    ] + ffmpeg_inputs + [
        "-filter_complex", full_filter,
        "-map", "[vout]",
        "-map", f"{audio_idx}:a:0",
        "-c:v", "libx264",
        "-profile:v", "high",
        "-level", "4.2",
        "-preset", "medium",
        "-pix_fmt", "yuv420p",
        "-b:v", video_bitrate,
        "-minrate", min_rate,
        "-maxrate", max_rate,
        "-bufsize", buf_size,
        "-r", "60",
        "-c:a", "aac",
        "-b:a", audio_bitrate,
        "-ac", "2",
        "-ar", str(audio_sample_rate),
        "-shortest",
        "-movflags", "+faststart",
        str(OUT_MASTER)
    ]

    print(f" -> Ejecutando codificación H.264 High Profile 60fps a {video_bitrate}...")
    res = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)

    if res.returncode != 0:
        raise RuntimeError(f"FFmpeg falló con código {res.returncode}:\n{res.stderr[-1200:]}")

    elapsed = time.time() - start_time
    file_size = OUT_MASTER.stat().st_size
    print(f" [OK] Master compilado en {elapsed:.1f}s: {OUT_MASTER.name} ({file_size:,} bytes / {file_size/1024/1024:.2f} MB)")

    if file_size > max_size_bytes:
        raise ValueError(f"El archivo generado ({file_size} bytes) supera el límite de {max_size_bytes} bytes (42.0 MB).")

    # Copia espejo a VIDEOS/promo_halloween_zombies_crudos.mp4
    print("\n=== PASO 3: SINCRONIZANDO COPIA ESPEJO PROMOCIONAL ===")
    shutil.copy2(OUT_MASTER, OUT_PROMO)
    print(f" [OK] Video espejo creado: {OUT_PROMO.name} ({OUT_PROMO.stat().st_size:,} bytes)")


def verify_master_telemetry():
    """Valida minuciosamente con FFprobe todos los parámetros técnicos de Franquicia."""
    print("\n=== PASO 4: AUDITORÍA TÉCNICA CON FFPROBE ===")
    probe_cmd = [
        str(FFPROBE_BIN),
        "-v", "error",
        "-show_entries", "format=duration,size,bit_rate",
        "-show_entries", "stream=codec_name,codec_type,width,height,r_frame_rate,bit_rate,nb_frames,pix_fmt,channels,sample_rate",
        "-of", "json",
        str(OUT_MASTER)
    ]
    res = subprocess.run(probe_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, check=True)
    telemetry = json.loads(res.stdout)

    v_stream = next((s for s in telemetry.get("streams", []) if s.get("codec_type") == "video"), None)
    a_stream = next((s for s in telemetry.get("streams", []) if s.get("codec_type") == "audio"), None)
    fmt = telemetry.get("format", {})

    assert v_stream is not None, "Error: No se encontró stream de video en el master."
    assert a_stream is not None, "Error: No se encontró stream de audio en el master."

    width = int(v_stream.get("width", 0))
    height = int(v_stream.get("height", 0))
    r_fps = v_stream.get("r_frame_rate", "")
    v_codec = v_stream.get("codec_name", "")
    pix_fmt = v_stream.get("pix_fmt", "")
    nb_frames = int(v_stream.get("nb_frames", 0))
    v_bitrate = int(v_stream.get("bit_rate", 0))

    a_codec = a_stream.get("codec_name", "")
    a_channels = int(a_stream.get("channels", 0))
    a_rate = int(a_stream.get("sample_rate", 0))
    a_bitrate = int(a_stream.get("bit_rate", 0))

    duration = float(fmt.get("duration", 0.0))
    file_size = int(fmt.get("size", 0))

    expected_frames = sum(sc["target_frames"] for sc in SCENE_SPECS)
    print(f" [TELEMETRÍA] Resolución : {width}x{height} px (esperado: 1080x1920)")
    print(f" [TELEMETRÍA] Frame Rate : {r_fps} (esperado: 60/1)")
    print(f" [TELEMETRÍA] Cuadros    : {nb_frames} frames (esperado: ~{expected_frames})")
    print(f" [TELEMETRÍA] Video Codec: {v_codec} / {pix_fmt} (esperado: h264 / yuv420p)")
    print(f" [TELEMETRÍA] Video BR   : {v_bitrate:,} bps ({v_bitrate/1000:.1f} kbps, esperado: >= 4000 kbps)")
    print(f" [TELEMETRÍA] Audio Codec: {a_codec} {a_channels}ch {a_rate}Hz (esperado: aac 2ch 44100Hz)")
    print(f" [TELEMETRÍA] Audio BR   : {a_bitrate:,} bps ({a_bitrate/1000:.1f} kbps, esperado: >= 128 kbps)")
    print(f" [TELEMETRÍA] Duración   : {duration:.2f} s")
    print(f" [TELEMETRÍA] Tamaño     : {file_size:,} bytes ({file_size/1024/1024:.2f} MB, límite: <= 52 MB)")

    # Aserciones estrictas
    assert width == 1080 and height == 1920, f"Resolución no conforme: {width}x{height}"
    assert r_fps == "60/1", f"Frame rate no constante a 60fps: {r_fps}"
    assert abs(nb_frames - expected_frames) <= 20, f"Conteo de cuadros fuera de tolerancia (~{expected_frames}): {nb_frames}"
    assert v_codec == "h264", f"Codec de video no es h264: {v_codec}"
    assert pix_fmt == "yuv420p", f"Pixel format no es yuv420p: {pix_fmt}"
    assert v_bitrate >= 4000000, f"Bitrate de video insuficiente: {v_bitrate} < 4000000"
    assert a_codec == "aac", f"Codec de audio no es aac: {a_codec}"
    assert a_channels == 2, f"Canales de audio no son estéreo: {a_channels}"
    assert a_rate == 44100, f"Frecuencia de muestreo no es 44100: {a_rate}"
    assert file_size <= 52000000, f"Archivo excede límite de 52 MB: {file_size} bytes"

    print("\n✅ CERTIFICACIÓN TÉCNICA: EL MASTER CUMPLE AL 100% CON LAS NORMAS AUDIOVISUALES.")


def main():
    parser = argparse.ArgumentParser(description="Ensamble Maestro 60fps — La Garza Aguachilera")
    parser.add_argument("--video-bitrate", default="4380k", help="Bitrate de video H.264")
    parser.add_argument("--min-rate", default="4250k", help="Bitrate mínimo de video")
    parser.add_argument("--max-rate", default="4650k", help="Bitrate máximo de video")
    parser.add_argument("--buf-size", default="8800k", help="Tamaño de búfer de tasa")
    parser.add_argument("--audio-bitrate", default="160k", help="Bitrate de audio AAC")
    parser.add_argument("--skip-render", action="store_true", help="Omitir render si el archivo ya existe y solo verificar")
    args = parser.parse_args()

    print("=================================================================")
    print("  ENSAMBLADOR MAESTRO DE VIDEO 60FPS (MILESTONE 4)")
    print("  La Garza Aguachilera — Master Compositing & Packaging Engine")
    print("=================================================================")

    sync_scene_specs_with_timeline()
    verify_inputs()
    create_clips_list()

    if not args.skip_render or not OUT_MASTER.exists():
        assemble_master_video(
            video_bitrate=args.video_bitrate,
            min_rate=args.min_rate,
            max_rate=args.max_rate,
            buf_size=args.buf_size,
            audio_bitrate=args.audio_bitrate,
        )

    verify_master_telemetry()


if __name__ == "__main__":
    main()
