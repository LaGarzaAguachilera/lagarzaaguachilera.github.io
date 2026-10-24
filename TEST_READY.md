# Test Execution Guide & Readiness Matrix — Spot Publicitario "La Garza Aguachilera"

**Document:** `TEST_READY.md`  
**Location:** Workspace Root (`d:\AG\la garza aguachilera\TEST_READY.md`)  
**Suite Location:** `d:\AG\la garza aguachilera\tests\spot_commercial\`  
**Primary Test Runners:**
- PowerShell: `tests\spot_commercial\run_spot_e2e_tests.ps1`
- Python: `tests\spot_commercial\test_spot_e2e_suite.py`

---

## 1. Quick Start / How to Run the Tests

### Option A: Unified Windows PowerShell Runner (Recommended)
From PowerShell in the project root `d:\AG\la garza aguachilera`:
```powershell
powershell -ExecutionPolicy Bypass -File tests\spot_commercial\run_spot_e2e_tests.ps1
```
*Features:* Performs native pre-flight invariant checks (powercfg 99%, 9 source clip hashes, file presence), runs all 105 tests across all 4 tiers, displays colorized terminal output, exports JSON and Markdown reports, and exits with code 0 or 1.

### Option B: Standalone Python Runner
Using Blender Python 3.11:
```powershell
& "C:\Program Files\Blender Foundation\Blender 4.3\4.3\python\bin\python.exe" tests\spot_commercial\test_spot_e2e_suite.py
```
Or using Packman Python 3.10:
```powershell
& "C:\packman-repo\python\3.10.5-1-windows-x86_64\python.exe" tests\spot_commercial\test_spot_e2e_suite.py
```

---

## 2. Expected Exit Codes & Interpretation

| Exit Code | Status | Meaning & Next Action |
|:---:|:---:|:---|
| **`0`** | **PASS** | **100% of tests passed.** Hardware guardrails verified, source clips intact, master MP4 fulfills all technical and aesthetic criteria, DaVinci Resolve project has 100% online media. Deliverables approved for deployment. |
| **`1`** | **PENDING / DEFICIENCY** | **One or more test assertions failed.** Details are logged to `tests\spot_commercial\spot_test_summary.md` and `spot_test_report.json`. Typically indicates master render is in-progress by `worker_spot_master_1` or a specific technical boundary (e.g., duration, luma clipping, offline media) requires refinement. |

---

## 3. Four-Tier Coverage Matrix (105 Automated Test Cases)

| Feature / Invariant | Tier 1 (Feature) | Tier 2 (Boundary) | Tier 3 (Pairwise) | Tier 4 (Scenario) | Total Tests | Target Specification | Current Status |
|:---|:---:|:---:|:---:|:---:|:---:|:---|:---:|
| **F1: CPU Thermal Protection** | 5 | 5 | 1 | - | **11** | `powercfg` locked at 99% AC (`0x00000063`) | **PASS (11/11)** |
| **F2: RTX 4060 GPU & NVENC** | 5 | - | 1 | - | **6** | RTX 4060 Laptop GPU, 8GB VRAM, `h264_nvenc` | **PASS (6/6)** |
| **F3: 9 Source Clips Immutability** | 5 | 9 | - | - | **14** | Exact SHA-256 hashes preserved verbatim | **PASS (14/14)** |
| **F4: Rec.709 Color Space Management** | 5 | - | 1 | - | **6** | SDR bt709, yuv420p, zero HDR metadata | *PENDING RENDER* |
| **F5: Six-Beat Narrative Cut** | 5 | - | - | - | **5** | Hook → Creamy → Shrimp → Dark → Sesame → Models | *PENDING RENDER* |
| **F6: 50% Slow-Motion Shrimp Hero** | 5 | - | 1 | - | **6** | Smooth optical flow 50% ramp, abundant shrimp | *PENDING RENDER* |
| **F7: Silent Audio Master** | 5 | 5 | 1 | - | **11** | Mean & max volume <= -60.0 dBFS or muted track | *PENDING RENDER* |
| **F8: Smart Reframing & Stabilization** | 5 | 5 | 1 | - | **11** | Full HD 1080x1920 (9:16), 0 letterbox, crop clutter | *PENDING RENDER* |
| **F9: GPU Bokeh & Vignette** | 5 | - | 1 | - | **6** | Background lens blur + subtle dark vignette | *PENDING RENDER* |
| **F10: Culinary & Beauty Color Grade** | 5 | 5 | 1 | 2 | **13** | Coral shrimp, lime green, white crema, natural skin | *PENDING RENDER* |
| **F11: Master Video Deliverable** | 5 | 5 | - | 2 | **12** | Duration [15s, 30s], 60fps, >4000kbps, H.264 NVENC | *PENDING RENDER* |
| **F12: DaVinci Resolve Timeline Package**| 5 | - | 1 | 1 | **7** | `spot_publicitario_la_garza.fcpxml` 100% online | *PENDING EXPORT* |
| **TOTALS** | **60** | **34** | **6** | **5** | **105** | **100% Requirements Coverage** | **29 PASS / 76 PENDING** |

---

## 4. Current Test Suite Execution Snapshot

As of test run on `2026-10-24T01:25:16Z`:
- **Hardware & Environment Guardrails (F1, F2):** `100% PASS`  
  - Windows CPU throttle index confirmed `0x00000063` (99%).
  - NVIDIA GeForce RTX 4060 Laptop GPU detected with 8188 MiB VRAM.
  - Local FFmpeg binary compiled with `h264_nvenc`, `hevc_nvenc`, and CUVID decoders.
- **Source Clips Cryptographic Immutability (F3):** `100% PASS`  
  - All 9 clips verified against authoritative baseline hashes with zero bytes altered.
- **Master Video & DaVinci Resolve Deliverables (F4 to F12):** `PENDING IMPLEMENTATION`  
  - The test suite faithfully tracks `spot_publicitario_la_garza_master_nvenc.mp4` and `spot_publicitario_la_garza.fcpxml`.
  - Once `worker_spot_master_1` completes the render and timeline generation, re-executing `run_spot_e2e_tests.ps1` will automatically evaluate all 76 remaining media, editorial, narrative, and Resolve assertions.

---

## 5. Artifact Inspection & Reporting

When the test suite executes, it writes comprehensive telemetry reports:
1. `tests\spot_commercial\spot_test_report.json`: Full machine-readable test records with individual pass/fail flags, timestamps, and error diagnostics.
2. `tests\spot_commercial\spot_test_summary.md`: Human-readable summary table and detailed inventory.
3. `tests\spot_commercial\sampled_frames\`: High-resolution frame samples extracted during narrative cut and luma clipping audits.
