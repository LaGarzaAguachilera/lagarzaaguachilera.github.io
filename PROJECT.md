# Project: La Garza Aguachilera — Producción Spot Publicitario & DaVinci Resolve Master

## Architecture
- **Source Footage**: 9 read-only `.mp4` clips inside `D:\AG\la garza aguachilera\spot publicitario` (H.264, vertical 464x832, Rec.709 SDR). Preserved with immutable SHA-256 cryptographic hashes.
- **Hardware Guardrails**: Windows CPU throttle locked at 99% AC setting (`0x00000063`) via `powercfg` on AMD Ryzen 7 7840HS (16 threads). NVIDIA GeForce RTX 4060 Laptop GPU (8 GB VRAM, Driver 617.42) offload for NVDEC decoding, CUDA filtering, and NVENC encoding (`-c:v h264_nvenc -preset p6 -tune hq -rc vbr -cq 15 -b:v 28M -maxrate 35M -spatial-aq 1 -temporal-aq 1 -bf 0`).
- **Editorial Pipeline (Iteration 2 — Zero-Blur HD Remaster)**:
  - Six-beat chronological cut (39.83s total duration = 2390 frames @ 60fps, silent audio <= -60 dBFS):
    1. Hook (Clip 9: `00:03.20`–`00:06.20`, 3.00s = 180 frames) bag opening.
    2. Creamy Base (Clip 7: `00:27.80`–`00:31.00`, 3.20s = 192 frames) white dressing pour.
    3. Protagonist (Clip 7: `00:54.30`–`00:56.10` lift + `00:56.20`–`00:58.45` 50% optical flow slow-mo cascade [4.50s] + `00:58.45`–`00:59.65` reveal + `01:21.50`–`01:23.80` avocado fan, 9.80s = 588 frames).
    4. Dark Contrast (Clip 7: `01:33.00`–`01:36.00`, 3.00s = 180 frames) black sauce pour.
    5. Final Touch & Beauty (Clip 7: `01:40.00`–`01:43.00` sesame sprinkle + `01:58.50`–`02:01.50` hero presentation, 6.00s = 360 frames).
    6. The Models (Clip 2 Model 1 red top [3.50s], Clip 3 Model 2 chocolate dress [4.00s], Clip 4 Model 3 floral corset complete unbroken arc [7.33s = 440 frames], 14.83s = 890 frames).
  - 100% Zero-Blur & Zero-Vignette Optical Clarity: Completely eliminated `radial_mask.png`, `boxblur`, `gblur`, `vignette`, and `maskedmerge`. Clean linear pipeline with edge-to-edge sharpness.
  - Native 464x832 Framing & Surgical Clutter Removal: Using native 464x832 framing (`464:824:0:4`) preserving >80% to 99% of native sensor pixels, with minimal surgical framing on Beat 4 (`410:728:54:20`), Beat 2 (`424:754:20:20`), and Beat 6b (`420:746:22:0`).
  - Pre-Upscaling Deblocking & Denoising: Pre-upscaling deblocking (`deblock=filter=weak:block=8`) + denoising (`hqdn3d=1.5:1.5:2.5:2.5`) to eliminate compression macroblocking and sensor grain before upscaling.
  - Lanczos Upscaling + Contrast-Adaptive Sharpening: Upscaled to 1080x1920 with Lanczos interpolation and CAS (`cas=strength=0.35`).
  - Optical Flow Slow-Motion: Bidirectional optical flow motion compensation on native resolution (`minterpolate=fps=60:mi_mode=mci:mc_mode=aobmc:me_mode=bidir:vsbmc=1`) achieving >95% unique frames without 2-frame duplication stutter.
  - Model 3 Unbroken Narrative Arc: Model 3 cut unbroken from `00:03.65` through clip end `10.98s` (7.33s = 440 frames @ 60fps) featuring pre-bite anticipation, bite, savoring, and thumbs-up approval.
  - Commercial Color Grading: Rec.709 SDR compliant culinary grade (vibrant coral shrimp, fresh green aguachile and avocado, clean neutral white dressing, glossy black sauce, natural warm skin tones).
- **Master Video Deliverable**: `D:\AG\la garza aguachilera\spot_publicitario_la_garza_master_nvenc.mp4` (Full HD 1080x1920, 60fps, 34.99 Mbps, H.264 NVENC, silent, duration 39.83s / 2390 frames).
- **Master Assets Deliverable**: `D:\AG\la garza aguachilera\spot_publicitario_master_assets\` (12 graded Full HD hero clips).
- **DaVinci Resolve Deliverable**: `D:\AG\la garza aguachilera\spot_publicitario_la_garza.fcpxml` (Apple FCPXML v1.8 with 6 beat markers), `spot_publicitario_la_garza.otio`, `spot_publicitario_la_garza.drp` (project archive), and utility scripts in `%APPDATA%\Blackmagic Design\DaVinci Resolve\Support\Fusion\Scripts\Utility\`.
- **Web Storefront & Public App**: `index.html` (Tailwind CSS, interactive selector for WhatsApp, video player).
- **Asset & Marketing Panel**: `panel_control.html` (media cards, product specifications).
- **QA Forensic & Brand Shield Suites**: `herramientas/ejecutar_empresa_qa.py` and `herramientas/auditar_multimedia_qa.ps1`.

## Code Layout
- `spot_publicitario_la_garza_master_nvenc.mp4` — Final rendered master commercial spot (1080x1920, 60fps, 39.83s, 2390 frames, NVENC, silent)
- `spot_publicitario_la_garza.fcpxml` — DaVinci Resolve timeline exchange file (FCPXML v1.8) with 100% online local media and beat markers
- `spot_publicitario_la_garza.otio` — OpenTimelineIO timeline exchange file
- `spot_publicitario_la_garza.drp` — DaVinci Resolve Project Archive ready to import
- `spot_publicitario_master_assets/` — 12 graded Full HD hero clips (1080x1920 @ 60fps)
- `spot publicitario/` — 9 read-only iPhone source clips (preserved with SHA-256 hashes)
- `herramientas/spot_editor/` — Python/FFmpeg mastering, rendering, and timeline generation engine (`render_spot_master.py`)
- `tests/spot_commercial/` — 105-test comprehensive E2E verification suite (`test_spot_e2e_suite.py`)
- `tests/challenger_2/` — Timeline & media stress test (`stress_test_timeline_media.py`)
- `tests/challenger_spot_1/` — Adversarial video metrics verifier (`test_master_video_adversarial.py`)
- `index.html` — Public storefront
- `panel_control.html` — Marketing & media dashboard
- `contenido_redes/` — Product guides and social media copy

## Feature Inventory
| # | Feature | Description | Milestone | Status |
|---|---------|-------------|-----------|--------|
| 1 | CPU Thermal Protection & powercfg 99% | Set Windows AC max processor state to 99% (`0x00000063`) to eliminate CPU boost spikes | M1 | VERIFIED |
| 2 | RTX 4060 GPU Acceleration & NVENC | Configure CUDA, NVDEC decoding, and NVIDIA NVENC encoding at high bitrate (35 Mbps) | M1 | VERIFIED |
| 3 | Read-Only Source Clips Preservation | Audit and preserve exact SHA-256 hashes of all 9 clips in `spot publicitario` | M2 | VERIFIED |
| 4 | Color Space Telemetry & Rec.709 Management | Validate Rec.709 SDR metadata, ensure zero highlight clipping (<0.02% at 255) | M2 | VERIFIED |
| 5 | Six-Beat Chronological Narrative Cut | Extended 39.83s sequence: Hook -> Creamy Base -> Protagonist -> Dark Sauce -> Sesame -> Models | M3 | VERIFIED |
| 6 | Optical Flow Slow-Motion Shrimp Protagonist | 50% slow-motion with bidirectional optical flow (`minterpolate`) achieving >95% unique frames | M3 | VERIFIED |
| 7 | Silent Audio Master | Master MP4 rendered with silent audio (<= -60 dBFS / completely absent stream) | M3 | VERIFIED |
| 8 | Native Framing & Surgical Reframing | Native 464x832 framing with minimal surgical crops saving >80%-99% native sensor pixels | M4 | VERIFIED |
| 9 | 100% Zero-Blur & Zero-Vignette Optical Clarity | Completely eliminated artificial blurs, vignettes, and bokeh masks for edge-to-edge HD clarity | M4 | VERIFIED |
| 10 | Commercial Culinary & Beauty Color Grading | Vibrant coral shrimp, fresh avocado green, neutral white dressing, glossy black sauce, natural skin | M4 | VERIFIED |
| 11 | Model 3 Complete Unbroken Narrative Arc | Model 3 extended to 7.33s (440 frames) showing anticipation, bite, savoring, and thumbs-up | M4 | VERIFIED |
| 12 | Master Video Generation (NVIDIA NVENC) | High-bitrate Full HD 1080x1920 60fps MP4 master in workspace root | M5 | VERIFIED |
| 13 | DaVinci Resolve Project & Timeline Package | FCPXML v1.8, OTIO, DRP, and utility scripts ready for Resolve 21.1 with 100% online local media | M5 | VERIFIED |
| 14 | Comprehensive Verification & Forensic Integrity Audit | 105-test E2E suite, Challenger 1 adversarial suite, Challenger 2 stress test all passing 100% | M6 | VERIFIED |

## Milestones
| # | Name | Scope | Dependencies | Status |
|---|------|-------|-------------|--------|
| M1 | Hardware Guardrails & GPU Setup | powercfg 99% AC setting, RTX 4060 GPU NVENC/CUDA validation | none | DONE |
| M2 | Media Telemetry & Color Pipeline Setup | 9 clips integrity audit, Rec.709 color management strategy | none | DONE |
| M3 | Six-Beat Narrative Assembly & Slow-Motion | Cut extraction, optical flow slow-mo on shrimp, 39.83s assembly, silent audio | M1, M2 | DONE |
| M4 | Cleanup, Reframing, Model 3 Arc & Color Grade | Native framing, zero-blur clarity, Model 3 7.33s arc, culinary & beauty grade | M3 | DONE |
| M5 | Dual Deliverables Generation | Render NVENC 1080x1920 master .mp4 + DaVinci Resolve .fcpxml/.otio/.drp/scripts | M4 | DONE |
| M6 | Dual Track Verification & Forensic Audit | Verification against 105 E2E tests, Challenger 1 & 2 stress tests (100% pass) | M5 | DONE |

## Interface Contracts
### M3 ↔ M4 (Assembly to Cleanup & Grade)
- Input: Cut list with exact in/out frames and bidirectional optical flow slow-mo shrimp hero.
- Output: Master edit assembly sequence at 1080x1920 @ 60fps (2390 frames).
- Reframing directives: Beat 1 native (`464:824:0:4`), Beat 2 minimal crop (`424:754:20:20`), Beat 4 minimal crop (`410:728:54:20`), Beat 6b minimal crop (`420:746:22:0`).

### M4 ↔ M5 (Graded Shots to Deliverables)
- Graded shots passed to NVENC master exporter and DaVinci Resolve timeline assembler.
- Audio: strictly silent (no audio stream or stream muted at -inf dBFS).
- Media files linked with absolute local paths: zero missing/offline clips in DaVinci Resolve.
