"""
=============================================================================
PRODUCIR VIDEO TIKTOK FULL HD (1080x1920) - LA GARZA AGUACHILERA
Milestone 13: Aislamiento Total, Locución Neural Mexicana, Ducking y Render HD
=============================================================================
"""

import os
import sys
import shutil
import asyncio
import subprocess
import numpy as np
from PIL import Image, ImageDraw, ImageFilter
import edge_tts

BASE_DIR = r"d:\AG\la garza aguachilera"
FFMPEG = os.path.join(BASE_DIR, "herramientas", "ffmpeg", "ffmpeg.exe")
FFPROBE = os.path.join(BASE_DIR, "herramientas", "ffmpeg", "ffprobe.exe")

VIDEO_SRC = os.path.join(BASE_DIR, "VIDEOS", "aguachile video 1.mp4")
MUSIC_SRC = os.path.join(BASE_DIR, "herramientas", "Beachfront_Celebration.mp3")
STAGE_PNG = os.path.join(BASE_DIR, "herramientas", "studio_stage_1080x1920.png")
MATTE_PNG = os.path.join(BASE_DIR, "herramientas", "pan_alpha_matte_720x1280.png")
OVERLAY_PNG = os.path.join(BASE_DIR, "herramientas", "branding_pop_overlay.png")
ASS_SUBTITLES = os.path.join(BASE_DIR, "herramientas", "tiktok_subtitles_170.ass")

RAW_VOICE_MP3 = os.path.join(BASE_DIR, "herramientas", "locucion_tiktok_dalia_raw.mp3")
MASTER_VOICE_WAV = os.path.join(BASE_DIR, "herramientas", "locucion_tiktok_dalia_master.wav")

OUT_PROMO = os.path.join(BASE_DIR, "VIDEOS", "promo_aguachile_verde_final.mp4")
OUT_TIKTOK_HD = os.path.join(BASE_DIR, "VIDEOS", "aguachile_video_1_tiktok_hd.mp4")

SCRIPT_TEXT = (
    "¡Aguachile preparado con Tostitos hasta la puerta de tu hogar! "
    "¡A solo 170 pesos! "
    "¡Haz tu pedido con nosotros y te lo llevamos hasta la puerta de tu hogar!"
)


def create_pan_alpha_matte():
    """Generates the feathered elliptical alpha matte (cx=360, cy=595, rx=310, ry=370, sigma=14)."""
    print("[1/6] Generando pan_alpha_matte_720x1280.png...")
    matte = Image.new("L", (720, 1280), 0)
    draw = ImageDraw.Draw(matte)
    cx, cy = 360, 595
    rx, ry = 310, 370
    draw.ellipse([cx - rx, cy - ry, cx + rx, cy + ry], fill=255)
    matte_feathered = matte.filter(ImageFilter.GaussianBlur(radius=14))
    matte_feathered.save(MATTE_PNG)
    print(f"      [OK] Máscara elíptica difuminada guardada en: {MATTE_PNG}")


def create_studio_stage():
    """Generates the dark marine slate studio background with emerald glow and drop shadow."""
    print("[2/6] Generando studio_stage_1080x1920.png...")
    width, height = 1080, 1920

    # Base dark marine slate (#0A121E)
    base_rgb = np.array([10.0, 18.0, 30.0])
    glow_rgb = np.array([16.0, 85.0, 68.0])  # Emerald highlight

    y_coords, x_coords = np.ogrid[:height, :width]
    dist_glow = np.sqrt(((x_coords - 540) / 1.0) ** 2 + ((y_coords - 920) / 1.1) ** 2)
    glow_radius = 650.0
    glow_intensity = np.clip(1.0 - (dist_glow / glow_radius) ** 1.5, 0.0, 1.0)

    stage_arr = np.zeros((height, width, 3), dtype=np.float32)
    for c in range(3):
        stage_arr[:, :, c] = base_rgb[c] + (glow_rgb[c] - base_rgb[c]) * glow_intensity * 0.75

    stage_img = Image.fromarray(np.uint8(stage_arr))

    # Contact drop shadow under the pan
    shadow_layer = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    sdraw = ImageDraw.Draw(shadow_layer)
    scx, scy = 540, 940
    srx, sry = 460, 320
    sdraw.ellipse([scx - srx, scy - sry, scx + srx, scy + sry], fill=(0, 0, 0, 185))
    shadow_blurred = shadow_layer.filter(ImageFilter.GaussianBlur(radius=35))

    stage_img = stage_img.convert("RGBA")
    stage_final = Image.alpha_composite(stage_img, shadow_blurred).convert("RGB")
    stage_final.save(STAGE_PNG)
    print(f"      [OK] Fondo de estudio con resplandor esmeralda guardado en: {STAGE_PNG}")


def create_ass_subtitles():
    """Writes the TikTok safe zone dynamic subtitles."""
    print("[3/6] Creando tiktok_subtitles_170.ass...")
    ass_content = """[Script Info]
Title: TikTok Safe Zone Dynamic Subtitles - La Garza Aguachilera
ScriptType: v4.00+
WrapStyle: 0
ScaledBorderAndShadow: yes
YCbCr Matrix: TV.709
PlayResX: 1080
PlayResY: 1920

[V4+ Styles]
Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding
Style: TikTokNorm,Arial Black,56,&H00FFFFFF,&H000000FF,&H00000000,&HA0000000,-1,0,0,0,100,100,1,0,1,6,3,2,60,60,470,1
Style: TikTokHook,Arial Black,60,&H0024E0FF,&H000000FF,&H00000000,&HA0000000,-1,0,0,0,100,100,2,0,1,7,4,2,60,60,470,1
Style: TikTokPrice,Arial Black,70,&H0000F5FF,&H000000FF,&H00000000,&HB0000000,-1,0,0,0,105,105,2,0,1,8,5,2,60,60,460,1
Style: TikTokCTA,Arial Black,58,&H0080FF70,&H000000FF,&H00000000,&HA0000000,-1,0,0,0,100,100,1,0,1,7,4,2,60,60,470,1

[Events]
Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text
Dialogue: 0,0:00:00.80,0:00:02.60,TikTokHook,,0,0,0,,{\\an2\\fad(100,80)}¡AGUACHILE PREPARADO!
Dialogue: 0,0:00:02.60,0:00:04.57,TikTokNorm,,0,0,0,,{\\an2\\fad(80,80)}¡CON TOSTITOS HASTA TU HOGAR!
Dialogue: 0,0:00:04.57,0:00:07.00,TikTokPrice,,0,0,0,,{\\an2\\fad(80,80)}¡A SOLO {\\c&H0000FFFF}170 PESOS{\\c&H0000F5FF}!
Dialogue: 0,0:00:07.00,0:00:09.00,TikTokCTA,,0,0,0,,{\\an2\\fad(80,80)}¡HAZ TU PEDIDO CON NOSOTROS!
Dialogue: 0,0:00:09.00,0:00:11.00,TikTokNorm,,0,0,0,,{\\an2\\fad(80,100)}¡TE LO LLEVAMOS A TU PUERTA!
Dialogue: 0,0:00:11.20,0:00:28.00,TikTokPrice,,0,0,0,,{\\an2\\fad(150,250)}PEDIDOS WHATSAPP: 833 252 09 88\\N{\\fs48\\c&H00FFFFFF}$170 MXN • LA GARZA AGUACHILERA
"""
    with open(ASS_SUBTITLES, "w", encoding="utf-8") as f:
        f.write(ass_content)
    print(f"      [OK] Subtítulos ASS guardados en: {ASS_SUBTITLES}")


async def synthesize_voiceover():
    """Synthesizes the energetic Mexican TikTok voiceover with edge-tts and masters audio."""
    print("[4/6] Sintetizando locución TikTok (es-MX-DaliaNeural, rate=+12%, pitch=+2Hz)...")
    comm = edge_tts.Communicate(SCRIPT_TEXT, "es-MX-DaliaNeural", rate="+12%", pitch="+2Hz")
    await comm.save(RAW_VOICE_MP3)
    print(f"      [OK] Audio crudo sintetizado: {RAW_VOICE_MP3}")

    # Master with broadcast EQ and peak limiter
    eq_filter = (
        "equalizer=f=250:width_type=h:width=150:g=2,"
        "equalizer=f=3500:width_type=h:width=1000:g=1.5,"
        "alimiter=limit=0.95"
    )
    cmd_wav = [
        FFMPEG, "-y",
        "-i", RAW_VOICE_MP3,
        "-ar", "44100",
        "-ac", "2",
        "-c:a", "pcm_s16le",
        "-af", eq_filter,
        MASTER_VOICE_WAV,
    ]
    subprocess.run(cmd_wav, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    print(f"      [OK] Pista vocal masterizada en: {MASTER_VOICE_WAV}")


def render_composite_video():
    """Renders the full 1080x1920 video with video isolation, color grading, ducked audio and ASS subtitles."""
    print("[5/6] Ejecutando renderizado unificado Full HD 1080x1920 con FFmpeg...")

    escaped_ass = ASS_SUBTITLES.replace("\\", "/").replace(":", "\\:")

    filter_complex = (
        # 1. Color grading, Green saturation boost, Lanczos upscale and Unsharp
        "[1:v]eq=contrast=1.12:brightness=0.01:saturation=1.35,"
        "colorbalance=rs=0.03:gs=0.06:bs=-0.04:rm=0.02:gm=0.05:bm=-0.03,"
        "unsharp=5:5:1.2:5:5:0.0[vg];"
        # 2. Feathered elliptical alpha matte masking and scaling to 1020x1813
        "[vg][2:v]alphamerge,scale=1020:1813:flags=lanczos[v_iso];"
        # 3. Overlay isolated dish over studio stage (offset 30, 54 to center at 540, 960)
        "[0:v][v_iso]overlay=30:54[v_comp];"
        # 4. Overlay branding frame (Header + Footer with $170 MXN pill)
        "[v_comp][3:v]overlay=0:0,"
        # 5. Burn dynamic safe-zone TikTok subtitles
        f"ass='{escaped_ass}'[vfinal];"
        # 6. Audio Auto-Ducking of Beachfront_Celebration.mp3 under voiceover
        # Music ducks from 0.75 to 0.18 during voiceover (0.6s to 11.2s), smooth swell to 0.75, outro fadeout
        "[4:a]volume='if(lt(t,0.6),0.75,if(lt(t,0.9),0.75-(0.75-0.18)*(t-0.6)/0.3,if(lt(t,11.2),0.18,if(lt(t,11.7),0.18+(0.75-0.18)*(t-11.2)/0.5,0.75))))':eval=frame,afade=t=in:ss=0:d=0.5,afade=t=out:st=27.5:d=1.54[amusic];"
        # 7. Vocal track with 800ms intro delay and slight presence boost
        "[5:a]adelay=800|800,volume=1.20[avocal];"
        # 8. Clean audio mix (original audio from input 1 is 100% stripped!)
        "[amusic][avocal]amix=inputs=2:duration=first:weights=1.0 1.0:normalize=0[aout]"
    )

    cmd_render = [
        FFMPEG, "-y",
        "-loop", "1", "-i", STAGE_PNG,           # Input 0: Studio stage (1080x1920)
        "-i", VIDEO_SRC,                         # Input 1: Original video (720x1280)
        "-loop", "1", "-i", MATTE_PNG,           # Input 2: Alpha matte (720x1280)
        "-loop", "1", "-i", OVERLAY_PNG,         # Input 3: Branding overlay (1080x1920)
        "-i", MUSIC_SRC,                         # Input 4: Beachfront Celebration music
        "-i", MASTER_VOICE_WAV,                  # Input 5: Mastered Dalia voiceover
        "-filter_complex", filter_complex,
        "-map", "[vfinal]",
        "-map", "[aout]",
        "-c:v", "libx264",
        "-profile:v", "high",
        "-level", "4.2",
        "-preset", "medium",
        "-b:v", "5200k",
        "-minrate", "4300k",
        "-maxrate", "6000k",
        "-bufsize", "10000k",
        "-pix_fmt", "yuv420p",
        "-c:a", "aac",
        "-b:a", "192k",
        "-ar", "44100",
        "-ac", "2",
        "-t", "29.04",
        "-movflags", "+faststart",
        OUT_PROMO,
    ]

    print("      Lanzando codificación de alta definición...")
    subprocess.run(cmd_render, check=True)
    print(f"      [OK] Render master generado: {OUT_PROMO}")

    # Copy to delivery target aguachile_video_1_tiktok_hd.mp4
    shutil.copyfile(OUT_PROMO, OUT_TIKTOK_HD)
    print(f"      [OK] Copia sincronizada generada: {OUT_TIKTOK_HD}")


def verify_telemetry(file_path):
    """Inspects video and audio stream telemetry with ffprobe."""
    cmd = [
        FFPROBE, "-v", "error",
        "-print_format", "json",
        "-show_format",
        "-show_streams",
        file_path,
    ]
    res = subprocess.run(cmd, capture_output=True, text=True, check=True)
    import json
    data = json.loads(res.stdout)

    v_stream = next((s for s in data.get("streams", []) if s.get("codec_type") == "video"), None)
    a_stream = next((s for s in data.get("streams", []) if s.get("codec_type") == "audio"), None)
    fmt = data.get("format", {})

    print(f"\n--- TELEMETRÍA TÉCNICA: {os.path.basename(file_path)} ---")
    print(f"  Tamaño: {int(fmt.get('size', 0)) / (1024 * 1024):.2f} MB")
    print(f"  Duración: {float(fmt.get('duration', 0)):.2f} s")
    total_bitrate = int(fmt.get("bit_rate", 0))
    print(f"  Bitrate total: {total_bitrate / 1000:.1f} kbps")

    if v_stream:
        w = v_stream.get("width")
        h = v_stream.get("height")
        v_codec = v_stream.get("codec_name")
        v_profile = v_stream.get("profile")
        pix_fmt = v_stream.get("pix_fmt")
        v_bitrate = int(v_stream.get("bit_rate", 0)) if v_stream.get("bit_rate") else total_bitrate
        print(f"  Video: {w}x{h} | Codec: {v_codec} ({v_profile}) | PixFmt: {pix_fmt} | Bitrate: {v_bitrate/1000:.1f} kbps")

        assert w == 1080 and h == 1920, f"Resolución no conforme: {w}x{h}"
        assert v_codec == "h264", f"Codec de video no conforme: {v_codec}"
        assert pix_fmt == "yuv420p", f"Pixel format no conforme: {pix_fmt}"
        assert v_bitrate >= 4000000 or total_bitrate >= 4000000, f"Bitrate inferior a 4000 kbps: {v_bitrate}"
        print("  => [VERIFICADO OK] Especificaciones de Video cumplen 100% criterios de aceptación.")
    else:
        raise RuntimeError("No se detectó stream de video.")

    if a_stream:
        a_codec = a_stream.get("codec_name")
        a_channels = a_stream.get("channels")
        a_rate = a_stream.get("sample_rate")
        print(f"  Audio: Codec: {a_codec} | Canales: {a_channels} | Sample Rate: {a_rate} Hz")

        assert a_codec == "aac", f"Codec de audio no conforme: {a_codec}"
        assert a_channels == 2, f"Canales de audio no conforman stereo: {a_channels}"
        assert str(a_rate) == "44100", f"Sample rate no conforme: {a_rate}"
        print("  => [VERIFICADO OK] Especificaciones de Audio cumplen 100% criterios de aceptación.")
    else:
        raise RuntimeError("No se detectó stream de audio.")


async def main():
    print("=================================================================")
    print(" INICIANDO PIPELINE DE PRODUCCIÓN M13 (LA GARZA AGUACHILERA)")
    print("=================================================================")
    create_pan_alpha_matte()
    create_studio_stage()
    create_ass_subtitles()
    await synthesize_voiceover()
    render_composite_video()

    print("\n[6/6] Verificando especificaciones de entrega con FFprobe...")
    verify_telemetry(OUT_PROMO)
    verify_telemetry(OUT_TIKTOK_HD)

    print("\n=================================================================")
    print(" PRODUCCIÓN Y VERIFICACIÓN DE MILESTONE 13 COMPLETADA CON ÉXITO")
    print("=================================================================")


if __name__ == "__main__":
    asyncio.run(main())
