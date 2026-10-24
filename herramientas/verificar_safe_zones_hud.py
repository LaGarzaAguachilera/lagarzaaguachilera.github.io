# -*- coding: utf-8 -*-
"""
EMPIRICAL SAFE-ZONE AUDITOR (Python + NumPy + PIL)
Verifica rigurosamente que todos los pases HUD y el render maestro de Blender 4.3
en 'BLENDER/renders_hud/' cumplan estrictamente:
- Dimensiones exactas 1080x1920 RGBA (32-bit).
- Píxeles visibles (alpha > 10) estrictamente contenidos en:
    X in [90, 990]  (Margen horizontal >= 90 px, ancho <= 900 px)
    Y in [220, 1600] (Margen superior >= 220 px, margen inferior <= 1600 px)
"""

import os
import sys
import glob
import numpy as np
from PIL import Image

RENDERS_DIR = r"d:\AG\la garza aguachilera\BLENDER\renders_hud"

REQUIRED_FILES = [
    "hud_act1.png",
    "hud_act2.png",
    "hud_act3.png",
    "hud_act4.png",
    "blender_3d_stage_master.png",
]


def audit_hud_safe_zones():
    print("=" * 75)
    print(" EMPIRICAL SAFE-ZONE AUDIT REPORT: BLENDER 4.3 3D HUD PASSES")
    print("=" * 75)
    
    all_passed = True
    results = []

    for fname in REQUIRED_FILES:
        fpath = os.path.join(RENDERS_DIR, fname)
        if not os.path.exists(fpath):
            print(f" [FAIL] MISSING FILE: {fpath}")
            all_passed = False
            continue

        im = Image.open(fpath)
        arr = np.array(im)
        h, w = arr.shape[:2]
        channels = arr.shape[2] if len(arr.shape) > 2 else 1

        if (w, h) != (1080, 1920) or channels != 4:
            print(f" [FAIL] {fname}: Dimension mismatch: got {w}x{h}x{channels}, expected 1080x1920x4 RGBA")
            all_passed = False
            continue

        alpha = arr[:, :, 3]
        nz = np.where(alpha > 10)
        if len(nz[0]) == 0:
            print(f" [FAIL] {fname}: Entire image is transparent (alpha <= 10)!")
            all_passed = False
            continue

        ymin, ymax = int(nz[0].min()), int(nz[0].max())
        xmin, xmax = int(nz[1].min()), int(nz[1].max())
        span_w = xmax - xmin + 1
        span_h = ymax - ymin + 1

        x_ok = (xmin >= 90 and xmax <= 990)
        y_ok = (ymin >= 220 and ymax <= 1600)
        status = "PASS" if (x_ok and y_ok) else "FAIL"

        if not (x_ok and y_ok):
            all_passed = False

        results.append({
            "file": fname,
            "xmin": xmin,
            "xmax": xmax,
            "span_w": span_w,
            "ymin": ymin,
            "ymax": ymax,
            "span_h": span_h,
            "x_ok": x_ok,
            "y_ok": y_ok,
            "status": status,
        })

        print(
            f" [{status}] {fname:28s}: "
            f"X=[{xmin:3d}, {xmax:3d}] (w={span_w:3d}, req=[90, 990]) | "
            f"Y=[{ymin:4d}, {ymax:4d}] (h={span_h:4d}, req=[220, 1600])"
        )

    print("-" * 75)
    if all_passed:
        print(" [PASS] 100% OF BLENDER HUD DELIVERABLES SATISFY SAFE-ZONE CONSTRAINTS!")
    else:
        print(" [FAIL] ONE OR MORE DELIVERABLES VIOLATED SAFE-ZONE GEOMETRY!")
    print("=" * 75)
    return 0 if all_passed else 1


if __name__ == "__main__":
    sys.exit(audit_hud_safe_zones())
