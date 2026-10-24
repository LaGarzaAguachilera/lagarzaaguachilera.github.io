# Test Infrastructure & Methodology — Spot Publicitario "La Garza Aguachilera"

**Document:** `TEST_INFRA.md`  
**Location:** Workspace Root (`d:\AG\la garza aguachilera\TEST_INFRA.md`)  
**Scope:** Opaque-Box E2E Testing for Commercial Spot & DaVinci Resolve Master  
**Authoritative Request:** `ORIGINAL_REQUEST.md` (§ 2026-10-24T05:12:41Z) & `SCOPE.md`  
**Test Suite Directory:** `tests/spot_commercial/`

---

## 1. Test Philosophy & Principles

The E2E Test Suite for **La Garza Aguachilera** follows strict opaque-box adversarial quality assurance principles to guarantee broadcast-grade audiovisual quality, cryptographic source immutability, and hardware thermal safety:

1. **Opaque-Box Verification:** Tests validate external observable artifacts (`.mp4`, `.fcpxml`, telemetry streams, system registries) rather than internal implementation mockups.
2. **Authoritative Output Derivation:** Every test assertion is derived strictly from `ORIGINAL_REQUEST.md` (§ 2026-10-24T05:12:41Z), `SCOPE.md`, and empirical hardware/media survey handoffs (`explorer_survey_1` and `explorer_survey_2`).
3. **Zero Facade Tests:** Tests strictly fail when deliverables are missing, corrupt, non-conformant, or out-of-spec. Facade tests that pass blindly are strictly prohibited.
4. **Dual Engine Execution:** Complete dual-engine compatibility via native Windows PowerShell (`run_spot_e2e_tests.ps1`) and standalone Python (`test_spot_e2e_suite.py`), executable with zero external third-party dependencies using Blender Python 3.11 or Packman Python 3.10 and local FFmpeg/FFprobe binaries.

---

## 2. Feature Inventory (F1 to F12)

| # | Feature | Scope & Component | Authoritative Requirement | Verification Mechanism |
|:---:|:---|:---|:---|:---|
| **F1** | CPU Thermal Protection & powercfg 99% | Windows OS Power Configuration (`PROCTHROTTLEMAX`) | Lock max CPU state at 99% (`0x00000063`) to prevent Ryzen 7 boost spikes | `powercfg /query SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX` |
| **F2** | RTX 4060 GPU Acceleration & NVENC | Hardware Telemetry & FFmpeg NVENC Compilers | Utilize NVIDIA GeForce RTX 4060 Laptop GPU for NVDEC, CUDA, and NVENC | `nvidia-smi` driver query + `ffmpeg -encoders` detection of `h264_nvenc` |
| **F3** | Read-Only Source Clips Preservation | Source Media Cryptographic Forensics | Protect 9 iPhone source clips in `spot publicitario` against modification/deletion | SHA-256 hash comparison + byte size verification against survey baseline |
| **F4** | Rec.709 Color Space Management | Master Video Stream Metadata | SDR Rec.709 signaling (`bt709` primaries, transfer, matrix, `yuv420p`, 0 HDR) | `ffprobe -show_streams` color metadata extraction |
| **F5** | Six-Beat Chronological Narrative Cut | Video Editing Sequence Structure | Exact order: (1) Hook → (2) Creamy Base → (3) Protagonist → (4) Dark Sauce → (5) Sesame → (6) Models | Frame sampling across narrative segments + duration analysis |
| **F6** | 50% Slow-Motion Shrimp Protagonist Hero | Optical Flow Retiming & Fluidity | Retime hero shrimp cascade to 50% speed ramp with smooth 60fps frame interpolation | Segment duration verification + frame-difference motion analysis |
| **F7** | Silent Audio Master | Audio Stream Loudness | Silent track (mean & max volume <= -60.0 dBFS or muted) for social media audio injection | `ffmpeg -af volumedetect` max_volume and mean_volume analysis |
| **F8** | Smart Reframing & Stabilization | Frame Composition & Upscaling | Full HD 1080x1920 (9:16 vertical), 0 letterbox/pillarbox, crop distracting clutter | Frame dimension audit + edge line scan + safe zone compliance |
| **F9** | GPU Background Isolation & Bokeh + Vignette | Spatial Filtering & Contrast | Soft lens blur on background + dark perimeter vignette keeping 100% focus on food/models | Background spatial frequency analysis + perimeter luminance roll-off |
| **F10** | Commercial Culinary & Beauty Color Grading | Colorimetry & Luma Ceiling | Coral shrimp, fresh green aguachile, clean white crema, glossy dark sauce, natural skin | YUV420p luma histogram (<1% at 255) + RGB chromaticity balance |
| **F11** | Master Video Deliverable Integrity | Container & File Health | File `spot_publicitario_la_garza_master_nvenc.mp4` exists, duration [15.0s, 30.0s], 60fps, >4000kbps | Complete decode test via FFmpeg + container integrity inspection |
| **F12** | DaVinci Resolve Project / Timeline Package | Timeline Deliverable & Media Links | `spot_publicitario_la_garza.fcpxml` / `.drp` ready to inspect with 100% online media | XML schema parsing + local file path existence check for all media assets |

---

## 3. Four-Tier Test Case Design Methodology

The test suite organizes 105 automated test cases into four distinct testing tiers:

```
+-----------------------------------------------------------------------------------+
|  TIER 4: REAL-WORLD APPLICATION SCENARIOS (5 Tests)                               |
|  - Instagram Reels, TikTok in-feed, VLC/Chrome playback, Culinary & Beauty        |
+-----------------------------------------------------------------------------------+
|  TIER 3: CROSS-FEATURE COMBINATIONS (6 Pairwise Tests)                            |
|  - NVENC+60fps, Slow-mo+Flow, Reframing+Bokeh, Resolve+Media, Grade+Luma, Silence |
+-----------------------------------------------------------------------------------+
|  TIER 2: BOUNDARY & CORNER CASES (34 Tests)                                       |
|  - Duration [15s, 30s], 1080x1920, Luma clipping <1%, Silence <= -60dB, SHA-256   |
+-----------------------------------------------------------------------------------+
|  TIER 1: FEATURE COVERAGE (60 Tests, >=5 per Feature)                             |
|  - Happy path and functional verification across all 12 system features (F1-F12)  |
+-----------------------------------------------------------------------------------+
```

### 3.1 Tier 1: Feature Coverage (60 Tests)
Provides >= 5 test cases per feature (F1 through F12) verifying primary functional specifications:
- **F1 (CPU Thermal):** 5 tests verifying `powercfg` query execution, 0x00000063 setting, active scheme, subgroup GUID, and thread count.
- **F2 (GPU & NVENC):** 5 tests verifying RTX 4060 hardware detection, 8GB VRAM capacity, `h264_nvenc`, `hevc_nvenc`, and CUVID decoders.
- **F3 (Source Preservation):** 5 tests verifying clip count (9), batch 1 hashes, batch 2 hashes, batch 3 hashes, and byte sizes.
- **F4 (Color Management):** 5 tests verifying bt709 primaries, transfer, matrix, yuv420p chroma, and absence of HDR flags.
- **F5 (Narrative Cut):** 5 tests verifying presence of Beat 1 (Hook), Beat 2 (Creamy Base), Beat 3 (Shrimp Hero), Beat 4 (Dark Sauce), and Beats 5/6 (Sesame/Models).
- **F6 (50% Slow-Motion):** 5 tests verifying duration expansion, distinct consecutive frame motion, absence of freeze-frame stutter, shrimp abundance visual prominence, and smooth ramp pacing.
- **F7 (Silent Audio):** 5 tests verifying mean volume <= -60 dBFS, max volume <= -60 dBFS, absence of dialogue, AAC/null stream format, and social-ready music injection capability.
- **F8 (Reframing):** 5 tests verifying 1080x1920 resolution, 0 letterbox bars, 0 pillarbox bars, clean upscaling, and clutter crop.
- **F9 (Bokeh/Vignette):** 5 tests verifying background softening, foreground sharpness, perimeter vignette roll-off, halo prevention, and model isolation.
- **F10 (Color Grading):** 5 tests verifying coral shrimp chroma, fresh green saturation, neutral white dressing balance, glossy dark sauce contrast, and healthy skin tones.
- **F11 (Master Integrity):** 5 tests verifying file presence, size > 5 MB, duration [15.0s, 30.0s], constant 60.0 fps, and NVENC H.264/HEVC codec.
- **F12 (DaVinci Resolve):** 5 tests verifying timeline deliverable existence, well-formed XML parsing, 1080x1920 @ 60fps declaration, 100% online local media links, and zero offline clip references.

### 3.2 Tier 2: Boundary & Corner Cases (34 Tests)
Validates extreme operational limits and invariants:
- **B1 Duration Boundaries (5 Tests):** Lower limit >= 15.000s, upper limit <= 30.000s, commercial sweet spot [24.0s, 29.5s], format/stream delta <= 0.1s, and non-decreasing PTS monotonicity.
- **B2 Resolution & Geometry (5 Tests):** Exact width 1080px (rejects 1088/720), exact height 1920px (rejects 1928/1080), aspect ratio 0.5625 (9:16), sample aspect ratio 1:1 square, and display aspect ratio 9:16.
- **B3 Luma Clipping Thresholds (5 Tests):** Pure 255 luma pixels strictly < 1.0%, severe high luma (>=254) < 2.0%, shadow crushing (<=1) < 5.0%, dynamic range span >= 180 levels, and mean frame luminance in legal range [40, 210].
- **B4 Audio Silence Limits (5 Tests):** Mean volume <= -60.0 dBFS, max peak volume <= -60.0 dBFS, zero transient spikes > -50.0 dBFS, noise floor below audibility, and digital ceiling preservation.
- **B5 CPU Throttle Boundary (5 Tests):** AC index exact 0x00000063, strictly < 100%, strictly > 50%, exit code 0, and balanced scheme verification.
- **B6 SHA-256 Immutability (9 Tests):** Independent cryptographic hash verification for each of the 9 source clips.

### 3.3 Tier 3: Cross-Feature Combinations (6 Tests)
Validates pairwise interaction matrix:
- **T3.C1:** GPU NVENC hardware encoding + constant 60.0 fps throughput under 99% CPU throttle.
- **T3.C2:** 50% slow-motion speed ramp + optical-flow frame interpolation without ghosting.
- **T3.C3:** Smart reframing (clutter cropping) + GPU bokeh/vignette isolation without border artifacts.
- **T3.C4:** DaVinci Resolve FCPXML project + 100% online local media synchronization.
- **T3.C5:** Commercial culinary color grading + Rec.709 highlight clipping protection (<1% at 255).
- **T3.C6:** Silent audio track (<= -60 dBFS) + social media faststart MP4 container (`moov` at start).

### 3.4 Tier 4: Real-World Application Scenarios (5 Tests)
Validates end-user deployment and broadcast compliance:
- **T4.S1 (Instagram Reels):** Strict vertical 9:16 canvas, duration <= 30s, H.264 High profile, silent audio track ready for Reels audio replacement.
- **T4.S2 (TikTok Delivery):** 1080x1920, 60fps, high bitrate (>= 4000 kbps), safe zones [90, 990] free of cropped critical food elements.
- **T4.S3 (Cross-Player Playback):** Universal decoding compatibility across VLC Media Player, Chrome/Edge HTML5 `<video>`, and DaVinci Resolve 21.1.
- **T4.S4 (Culinary Appetite Appeal):** Rich coral shrimp, vibrant lime green aguachile, crisp neutral white crema, maximizing viewer conversion.
- **T4.S5 (Model Natural Beauty):** Flattering natural warm skin tones without artificial plastic over-smoothing, showcasing genuine delight.

---

## 4. Test Suite Architecture & File Layout

```
d:\AG\la garza aguachilera\
├── TEST_INFRA.md                          # Test infrastructure & methodology (this file)
├── TEST_READY.md                          # Operational test execution & status matrix
├── tests\
│   └── spot_commercial\
│       ├── test_spot_e2e_suite.py        # Python 4-tier automated test harness (105 tests)
│       ├── run_spot_e2e_tests.ps1        # PowerShell automated test runner
│       ├── spot_test_report.json         # Structured machine-readable test execution output
│       ├── spot_test_summary.md          # Human-readable markdown test execution summary
│       └── sampled_frames\               # Extracted verification frames for visual audit
├── spot_publicitario_la_garza_master_nvenc.mp4  # Master video deliverable under test
└── spot_publicitario_la_garza.fcpxml     # DaVinci Resolve timeline deliverable under test
```

---

## 5. Coverage & Quality Gates

| Quality Gate | Acceptance Threshold | Failure Action |
|---|---|---|
| **CPU Throttle Invariant** | `0x00000063` (99%) | Hard block: Re-execute `powercfg /setacvalueindex` |
| **Source Clip Immutability** | 9 / 9 SHA-256 hashes exact match | Hard block: Restore clips from read-only backup |
| **Duration Limit** | 15.000s <= Duration <= 30.000s | Re-edit master assembly |
| **Resolution & Orientation** | Exactly 1080x1920 (9:16 vertical) | Re-render with `-s 1080x1920` Lanczos |
| **Frame Cadence** | Constant 60.0 fps (`60/1`) | Re-render with `-r 60` |
| **Highlight Clipping** | < 1.0% of pixels at pure 255 luma | Adjust color grade highlight compression |
| **Audio Silence** | Max & Mean volume <= -60.0 dBFS | Apply `-an` or volume attenuation |
| **Resolve Media Status** | 100% online media (0 missing assets) | Relink absolute paths in FCPXML |
