#!/usr/bin/env python3
"""
Adversarial Boundary Stress Test - Challenger 1
Focus Areas:
1. Audio Duration vs Video Duration Delta
2. Frame Rate Stability (60/1 fps) across master and scene clips
3. Pixel Format Compliance (yuv420p)
4. ZIP Package Size Headroom before 100 MB
5. Deep Regex Scan for Hidden Pricing Defects & Forbidden Words across non-agent files
"""

import os
import sys
import json
import subprocess
import zipfile
import re
from pathlib import Path

BASE_DIR = Path(r"d:\AG\la garza aguachilera")
FFPROBE = BASE_DIR / "herramientas" / "ffmpeg" / "ffprobe.exe"

def run_ffprobe(file_path):
    cmd = [
        str(FFPROBE),
        "-v", "error",
        "-print_format", "json",
        "-show_format",
        "-show_streams",
        str(file_path)
    ]
    res = subprocess.run(cmd, capture_output=True, text=True, check=True)
    return json.loads(res.stdout)

def test_durations_and_sync():
    print("\n=== 1. AUDIO DURATION VS VIDEO DURATION DELTA STRESS TEST ===")
    videos = [
        BASE_DIR / "VIDEOS" / "animacion_la_garza_episodio_crudos_60fps.mp4",
        BASE_DIR / "VIDEOS" / "promo_halloween_zombies_crudos.mp4"
    ]
    master_wav = BASE_DIR / "herramientas" / "audio_animacion_master_60fps.wav"
    
    # Check WAV
    wav_probe = run_ffprobe(master_wav)
    wav_dur = float(wav_probe["format"]["duration"])
    print(f"Master WAV: {master_wav.name}")
    print(f"  Duration: {wav_dur:.6f}s")
    
    results = []
    for v in videos:
        print(f"\nAnalyzing video: {v.name}")
        probe = run_ffprobe(v)
        v_stream = next(s for s in probe["streams"] if s["codec_type"] == "video")
        a_stream = next(s for s in probe["streams"] if s["codec_type"] == "audio")
        fmt = probe["format"]
        
        v_dur = float(v_stream.get("duration", fmt.get("duration", 0)))
        a_dur = float(a_stream.get("duration", fmt.get("duration", 0)))
        container_dur = float(fmt.get("duration", 0))
        delta = abs(v_dur - a_dur)
        
        print(f"  Container Duration: {container_dur:.6f}s")
        print(f"  Video Stream Duration: {v_dur:.6f}s")
        print(f"  Audio Stream Duration: {a_dur:.6f}s")
        print(f"  Delta |Video - Audio|: {delta:.6f}s ({delta*1000:.2f} ms)")
        
        # Audio vs video delta threshold: under 0.1s (100ms) or exact frame boundary (1/60s = 0.01667s)
        # In professional broadcast/streaming, audio/video delta < 50ms is ideal.
        status = "PASS" if delta < 0.1 else "FAIL"
        print(f"  Assessment: {status} (Delta < 100ms tolerance)")
        results.append({
            "video": v.name,
            "v_dur": v_dur,
            "a_dur": a_dur,
            "delta": delta,
            "status": status
        })
    return results

def test_framerate_and_pixel_format():
    print("\n=== 2. FRAME RATE STABILITY & PIXEL FORMAT COMPLIANCE ===")
    targets = [
        BASE_DIR / "VIDEOS" / "animacion_la_garza_episodio_crudos_60fps.mp4",
        BASE_DIR / "VIDEOS" / "promo_halloween_zombies_crudos.mp4",
        BASE_DIR / "VIDEOS" / "clips" / "scene1.mp4",
        BASE_DIR / "VIDEOS" / "clips" / "scene2.mp4",
        BASE_DIR / "VIDEOS" / "clips" / "scene3.mp4",
        BASE_DIR / "VIDEOS" / "clips" / "scene4.mp4",
        BASE_DIR / "VIDEOS" / "clips" / "scene5.mp4",
        BASE_DIR / "VIDEOS" / "clips" / "scene6.mp4"
    ]
    
    results = []
    for target in targets:
        print(f"\nTarget: {target.relative_to(BASE_DIR)}")
        probe = run_ffprobe(target)
        v_stream = next(s for s in probe["streams"] if s["codec_type"] == "video")
        
        r_frame_rate = v_stream.get("r_frame_rate")
        avg_frame_rate = v_stream.get("avg_frame_rate")
        pix_fmt = v_stream.get("pix_fmt")
        width = v_stream.get("width")
        height = v_stream.get("height")
        nb_frames = v_stream.get("nb_frames")
        
        # Evaluate 60fps
        r_num, r_den = map(int, r_frame_rate.split("/"))
        r_fps = r_num / r_den if r_den != 0 else 0
        
        a_num, a_den = map(int, avg_frame_rate.split("/"))
        a_fps = a_num / a_den if a_den != 0 else 0
        
        fps_exact = (r_fps == 60.0 and a_fps == 60.0)
        pix_fmt_ok = (pix_fmt == "yuv420p")
        res_ok = (width == 1080 and height == 1920)
        
        print(f"  Dimensions: {width}x{height} (OK: {res_ok})")
        print(f"  r_frame_rate: {r_frame_rate} ({r_fps:.4f} fps)")
        print(f"  avg_frame_rate: {avg_frame_rate} ({a_fps:.4f} fps)")
        print(f"  nb_frames: {nb_frames}")
        print(f"  pix_fmt: {pix_fmt} (OK: {pix_fmt_ok})")
        
        status = "PASS" if (fps_exact and pix_fmt_ok and res_ok) else "FAIL"
        print(f"  Assessment: {status}")
        results.append({
            "target": str(target.relative_to(BASE_DIR)),
            "fps_exact": fps_exact,
            "pix_fmt_ok": pix_fmt_ok,
            "res_ok": res_ok,
            "r_frame_rate": r_frame_rate,
            "avg_frame_rate": avg_frame_rate,
            "pix_fmt": pix_fmt,
            "status": status
        })
    return results

def test_zip_headroom():
    print("\n=== 3. ZIP PACKAGE SIZE & HEADROOM TEST ===")
    zip_path = BASE_DIR / "paquete_redes_la_garza.zip"
    stat = zip_path.stat()
    size_bytes = stat.st_size
    size_mib = size_bytes / (1024 * 1024)
    size_mb = size_bytes / 1_000_000
    limit_100_mib = 100 * 1024 * 1024 # 104,857,600 bytes
    limit_100_mb = 100_000_000        # 100,000,000 bytes
    
    headroom_mib = limit_100_mib - size_bytes
    headroom_mb = limit_100_mb - size_bytes
    
    print(f"ZIP path: {zip_path}")
    print(f"  Bytes: {size_bytes:,} bytes")
    print(f"  Size (MiB): {size_mib:.2f} MiB")
    print(f"  Size (MB):  {size_mb:.2f} MB")
    print(f"  Headroom before 100 MiB (104.86 MB): {headroom_mib:,} bytes ({headroom_mib / (1024*1024):.2f} MiB)")
    print(f"  Headroom before 100 MB decimal:      {headroom_mb:,} bytes ({headroom_mb / 1_000_000:.2f} MB)")
    
    with zipfile.ZipFile(zip_path, 'r') as zf:
        infolist = zf.infolist()
        total_uncompressed = sum(info.file_size for info in infolist)
        print(f"  Entries count: {len(infolist)}")
        print(f"  Total uncompressed size: {total_uncompressed:,} bytes ({total_uncompressed / (1024*1024):.2f} MiB)")
        # Test integrity by reading all bytes
        corrupted = 0
        for info in infolist:
            try:
                _ = zf.read(info.filename)
            except Exception as e:
                corrupted += 1
                print(f"    CORRUPTED: {info.filename}: {e}")
        print(f"  Archive read check: {'PASS (0 corrupted)' if corrupted == 0 else f'FAIL ({corrupted} corrupted)'}")
        
    status = "PASS" if (size_bytes < limit_100_mib and size_bytes < limit_100_mb and corrupted == 0) else "FAIL"
    print(f"  Overall Assessment: {status}")
    return {
        "size_bytes": size_bytes,
        "size_mib": size_mib,
        "headroom_mib": headroom_mib / (1024*1024),
        "headroom_mb": headroom_mb / 1_000_000,
        "corrupted": corrupted,
        "status": status
    }

def test_global_scan_pricing_and_forbidden_words():
    print("\n=== 4. DEEP SCAN FOR PRICING DEFECTS & FORBIDDEN WORDS ===")
    forbidden_terms = [
        r"\$170\b",
        r"170\s*MXN",
        r"170\s*pesos",
        r"ciento\s*setenta",
        r"\bjumbo\b",
        r"\bnacho\b",
        r"tostitos?\s+redondos?",
        r"totopos?\s+redondos?",
        r"#tostitosredondos?",
        r"dark\s*kitchen",
        r"caldo\s*por\s*separado",
        r"Rosa\s*210",
        r"base\s*de\s*operaciones"
    ]
    regexes = [(term, re.compile(term, re.IGNORECASE)) for term in forbidden_terms]
    
    excluded_dirs = {".git", ".agents", ".gemini", "tests"}
    excluded_files = {
        "auditar_multimedia_qa.ps1",
        "proposed_auditar_multimedia_qa.ps1",
        "TEST_INFRA.md",
        "TEST_READY.md"
    }
    
    violations = []
    misplaced_test_files = []
    scanned_count = 0
    
    for root, dirs, files in os.walk(BASE_DIR):
        # Skip excluded dirs
        dirs[:] = [d for d in dirs if d not in excluded_dirs]
        for f in files:
            if f in excluded_files:
                continue
            # Flag test files residing outside tests/ directory
            if f.startswith("test_") and root != str(BASE_DIR / "tests"):
                misplaced_test_files.append(str((Path(root) / f).relative_to(BASE_DIR)))
                continue
            ext = os.path.splitext(f)[1].lower()
            if ext in [".ps1", ".html", ".md", ".txt", ".json", ".js", ".py", ".css"]:
                full_path = Path(root) / f
                scanned_count += 1
                try:
                    content = full_path.read_text(encoding="utf-8", errors="ignore")
                except Exception as e:
                    continue
                
                for term_pattern, rgx in regexes:
                    for line_num, line in enumerate(content.splitlines(), start=1):
                        if rgx.search(line):
                            violations.append({
                                "file": str(full_path.relative_to(BASE_DIR)),
                                "line_num": line_num,
                                "term": term_pattern,
                                "snippet": line.strip()[:100]
                            })
                            
    print(f"Total non-agent production files scanned: {scanned_count}")
    if misplaced_test_files:
        print(f"Notice: Found {len(misplaced_test_files)} test file(s) located outside tests/ directory:")
        for mtf in misplaced_test_files:
            print(f"  - {mtf}")
    if violations:
        print(f"FAIL: Found {len(violations)} forbidden term / pricing violations:")
        for v in violations:
            print(f"  {v['file']}:{v['line_num']} [{v['term']}] -> {v['snippet']}")
    else:
        print("PASS: Zero forbidden terms or pricing defects found across all scanned non-agent production files.")
        
    return {
        "scanned_files": scanned_count,
        "violations": violations,
        "misplaced_test_files": misplaced_test_files,
        "status": "PASS" if len(violations) == 0 else "FAIL"
    }

def main():
    r1 = test_durations_and_sync()
    r2 = test_framerate_and_pixel_format()
    r3 = test_zip_headroom()
    r4 = test_global_scan_pricing_and_forbidden_words()
    
    all_passed = (
        all(x["status"] == "PASS" for x in r1) and
        all(x["status"] == "PASS" for x in r2) and
        r3["status"] == "PASS" and
        r4["status"] == "PASS"
    )
    
    print("\n==================================================")
    print(f"OVERALL ADVERSARIAL STRESS TEST VERDICT: {'APPROVE' if all_passed else 'REQUEST_CHANGES'}")
    print("==================================================")
    
    summary = {
        "duration_sync": r1,
        "framerate_pixel_format": r2,
        "zip_headroom": r3,
        "pricing_forbidden_scan": r4,
        "overall_passed": all_passed
    }
    
    with open(BASE_DIR / "tests" / "adversarial_boundary_results.json", "w", encoding="utf-8") as f:
        json.dump(summary, f, indent=2)
        
    sys.exit(0 if all_passed else 1)

if __name__ == "__main__":
    main()
