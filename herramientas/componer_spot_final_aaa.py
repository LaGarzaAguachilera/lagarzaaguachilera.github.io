# -*- coding: utf-8 -*-
"""
COMPOSITOR FINAL DEL COMERCIAL AAA (1080x1920 @ 60 FPS, NVENC + BLENDER 3D HUD + AOEDE AUDIO)
Proyecto: La Garza Aguachilera — Spot Publicitario Stories & TikTok ($170 MXN)
"""

import os
import re
import sys
import json
import shutil
import hashlib
import subprocess
from pathlib import Path

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")
if hasattr(sys.stderr, "reconfigure"):
    sys.stderr.reconfigure(encoding="utf-8")

PROJECT_ROOT = Path(r"d:\AG\la garza aguachilera")
FFMPEG = PROJECT_ROOT / "herramientas" / "ffmpeg" / "ffmpeg.exe"
FFPROBE = PROJECT_ROOT / "herramientas" / "ffmpeg" / "ffprobe.exe"

MASTER_CGI = PROJECT_ROOT / "VIDEOS" / "clips_aaa" / "aaa_master_cgi_24s.mp4"
HUD_DIR = PROJECT_ROOT / "BLENDER" / "renders_hud"
AUDIO_WAV = PROJECT_ROOT / "herramientas" / "audio_master_aaa_24s.wav"
SUBS_REL = "herramientas/subtitulos_aaa_stories_170.ass"

OUT_MASTER = PROJECT_ROOT / "spot_publicitario_la_garza_aaa_stories_tiktok.mp4"
MIRRORS = [
    PROJECT_ROOT / "VIDEOS" / "promo_aguachile_verde_final.mp4",
    PROJECT_ROOT / "VIDEOS" / "aguachile_video_1_tiktok_hd.mp4",
    PROJECT_ROOT / "VIDEOS" / "spot_la_garza_aaa_blender_rtx4060.mp4",
]


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with open(path, "rb") as f:
        while chunk := f.read(1024 * 1024):
            h.update(chunk)
    return h.hexdigest().upper()


def render_final_spot(audio_gain_db: float = -0.3) -> None:
    print("=" * 75)
    print(" [INFO] ENSAMBLANDO SPOT COMERCIAL FINAL AAA CON GPU NVENC (RTX 4060)")
    print("=" * 75)

    filter_complex = (
        "[0:v][1:v]overlay=0:0:enable='lt(t,6)'[v1];"
        "[v1][2:v]overlay=0:0:enable='gte(t,6)*lt(t,12)'[v2];"
        "[v2][3:v]overlay=0:0:enable='gte(t,12)*lt(t,18)'[v3];"
        "[v3][4:v]overlay=0:0:enable='gte(t,18)'[v4];"
        f"[v4]ass={SUBS_REL}[vout];"
        f"[5:a]volume={audio_gain_db}dB,alimiter=limit=-1.35dB:level=false[aout]"
    )

    cmd = [
        str(FFMPEG),
        "-y",
        "-i", str(MASTER_CGI),
        "-i", str(HUD_DIR / "hud_act1.png"),
        "-i", str(HUD_DIR / "hud_act2.png"),
        "-i", str(HUD_DIR / "hud_act3.png"),
        "-i", str(HUD_DIR / "hud_act4.png"),
        "-i", str(AUDIO_WAV),
        "-filter_complex", filter_complex,
        "-map", "[vout]",
        "-map", "[aout]",
        "-c:v", "h264_nvenc",
        "-profile:v", "high",
        "-preset", "p4",
        "-tune", "hq",
        "-b:v", "6200k",
        "-minrate", "5200k",
        "-maxrate", "8200k",
        "-bufsize", "12400k",
        "-pix_fmt", "yuv420p",
        "-r", "60",
        "-frames:v", "1440",
        "-c:a", "aac",
        "-b:a", "256k",
        "-ar", "44100",
        "-ac", "2",
        "-t", "24.0",
        "-movflags", "+faststart",
        str(OUT_MASTER),
    ]

    subprocess.run(cmd, cwd=str(PROJECT_ROOT), check=True)
    print(f" [OK] Master renderizado: {OUT_MASTER} ({OUT_MASTER.stat().st_size:,} bytes)")


def update_act4_sample_frames() -> None:
    act4_samples = [
        ("18.0", PROJECT_ROOT / "FRAMES" / "aaa_stories" / "act4_frame000.png"),
        ("21.0", PROJECT_ROOT / "FRAMES" / "aaa_stories" / "act4_frame180.png"),
        ("23.95", PROJECT_ROOT / "FRAMES" / "aaa_stories" / "act4_frame359.png"),
    ]
    for ts, out_png in act4_samples:
        subprocess.run(
            [str(FFMPEG), "-y", "-ss", ts, "-i", str(MASTER_CGI), "-frames:v", "1", str(out_png)],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            check=True,
        )
    print(" [OK] Frames testigo de Acto 4 actualizados en FRAMES/aaa_stories/.")


def verify_and_mirror() -> None:
    probe_raw = subprocess.check_output(
        [str(FFPROBE), "-v", "error", "-print_format", "json", "-show_format", "-show_streams", str(OUT_MASTER)],
        text=True,
    )
    probe = json.loads(probe_raw)
    vs = next(s for s in probe["streams"] if s["codec_type"] == "video")
    aus = next(s for s in probe["streams"] if s["codec_type"] == "audio")

    vol_res = subprocess.run(
        [str(FFMPEG), "-i", str(OUT_MASTER), "-af", "volumedetect", "-f", "null", "-"],
        capture_output=True,
        text=True,
    )
    mean_v = float(re.search(r"mean_volume:\s*([-\d\.]+)\s*dB", vol_res.stderr).group(1))
    max_v = float(re.search(r"max_volume:\s*([-\d\.]+)\s*dB", vol_res.stderr).group(1))

    ebur_res = subprocess.run(
        [str(FFMPEG), "-i", str(OUT_MASTER), "-af", "ebur128=framelog=quiet", "-f", "null", "-"],
        capture_output=True,
        text=True,
    )
    i_lufs = float(re.search(r"I:\s*([-\d\.]+)\s*LUFS", ebur_res.stderr).group(1))

    print(
        f" [TELEMETRÍA] {vs['width']}x{vs['height']} @ {vs['r_frame_rate']} (avg {vs['avg_frame_rate']}) | "
        f"frames={vs['nb_frames']} | dur={float(vs['duration']):.3f}s | "
        f"{vs['codec_name']} ({vs['profile']}) {int(vs.get('bit_rate', 0)) // 1000} kbps"
    )
    print(
        f" [AUDIO] {aus['codec_name']} {aus['channels']}ch @ {aus['sample_rate']}Hz | "
        f"mean={mean_v:.1f} dBFS | max={max_v:.1f} dBFS | I={i_lufs:.1f} LUFS"
    )

    assert int(vs["width"]) == 1080 and int(vs["height"]) == 1920
    assert vs["r_frame_rate"] == "60/1" and vs["avg_frame_rate"] == "60/1"
    assert int(vs["nb_frames"]) == 1440
    assert abs(float(vs["duration"]) - 24.0) < 0.05
    assert vs["codec_name"] == "h264" and vs["profile"] == "High" and vs["pix_fmt"] == "yuv420p"
    assert int(vs.get("bit_rate", 0)) >= 4000000
    assert aus["codec_name"] == "aac" and int(aus["channels"]) == 2 and str(aus["sample_rate"]) == "44100"
    assert mean_v > -28.0 and max_v < -1.0 and (-16.0 <= i_lufs <= -12.0)

    master_hash = sha256_file(OUT_MASTER)
    for m in MIRRORS:
        shutil.copyfile(OUT_MASTER, m)
        assert sha256_file(m) == master_hash, f"Hash mismatch en espejo {m}"
        print(f" [ESPEJO OK] {m.name} -> SHA-256 {master_hash[:16]}...")


if __name__ == "__main__":
    render_final_spot()
    update_act4_sample_frames()
    verify_and_mirror()
