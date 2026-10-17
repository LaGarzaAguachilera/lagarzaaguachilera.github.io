# Project: La Garza Aguachilera — Multimedia & Franchise Elevation

## Architecture
- **Video & Audio Pipeline**: FFmpeg 6.1 engine in `herramientas\ffmpeg\`, Windows native SAPI (`System.Speech.Synthesis`) with Mexican Spanish voice `Microsoft Sabina Desktop` for commercial voiceover WAV generation, automated audio ducking with `Beachfront_Celebration.mp3`, edge-to-edge 1080x1920 composition combining high-def macro food photos, smooth Ken Burns zoom/pan, Tampico characters, live fork-lift video clip, and franchise graphic cards.
- **Graphic Design Pipeline**: .NET `System.Drawing` (GDI+) renderers upgraded to multi-layer ambient occlusion shadows, studio vignettes, glassmorphic badge borders, Unicode-safe string encoding, and bold franchise advertising typography across the 3 main flyers and 6 periodic posts.
- **Web & Panel Integration**: `panel_control.html` and `index.html` reflecting updated assets, active players, download links, and sanitized copy without forbidden words.
- **E2E Testing & QA Track**: Upgraded `herramientas\auditar_multimedia_qa.ps1` with FFprobe stream validation, comprehensive forbidden word scanning with proper exclusions, and strict exit code semantics (`exit 0` / `exit 1`). Independent opaque-box test runner covering Tiers 1-4.

## Feature Inventory
| # | Feature | Description | Milestone | Source |
|---|---------|-------------|-----------|--------|
| 1 | Full HD Video 1080x1920 | True 1080x1920 (9:16) H.264 High Profile, >= 4000 kbps, AAC stereo, 30/60 fps | M1 | ORIGINAL_REQUEST §R1.1 |
| 2 | Elimination of Black Bars & Pixelation | Edge-to-edge canvas eliminating letterboxing (`pad=...:black`) and 640x663 crop | M1 | ORIGINAL_REQUEST §R1.1 |
| 3 | High-Definition Food Photography Motion | Dynamic Ken Burns pan/zoom on `tostiaguachile_verde_redondo.jpg` and `aguachile_verde_hero.jpg` | M1 | ORIGINAL_REQUEST §R1.1 |
| 4 | Tampico Local Identity in Video | Aesthetic integration of Mapaches, OVNIs, and Juancho stickers with franchise styling | M1 | ORIGINAL_REQUEST §R1.2 |
| 5 | Spanish Commercial Voiceover | Native Mexican voice announcing weekend service, fresh prep in front of customer, routes on social media, WhatsApp 833 252 09 88 | M1 | ORIGINAL_REQUEST §R1.3 |
| 6 | Audio Ducking with Official Music | Ducking `Beachfront_Celebration.mp3` to ~0.18 (-15dB) during speech with intro/outro swells | M1 | ORIGINAL_REQUEST §R1.3 |
| 7 | Facebook Cover Elevation (`flyer_portada_verde.png`) | 1200x630, Unicode-safe glyphs, zero mojibake, zero forbidden words, franchise polish | M2 | ORIGINAL_REQUEST §R2 |
| 8 | Feed Post Flyer Elevation (`flyer_post_verde.png`) | 1080x1080, incorporate real food photo, Tampico characters, bold franchise typography | M2 | ORIGINAL_REQUEST §R2 |
| 9 | Story Flyer Elevation (`flyer_historia_verde.png`) | 1080x1920, incorporate real food photo, Tampico characters, vertical franchise design | M2 | ORIGINAL_REQUEST §R2 |
| 10 | Periodic Posts Elevation (6 posts) | 1080x1080, multi-layer shadows, studio vignettes, glassmorphic badges, safe zone compliance | M2 | ORIGINAL_REQUEST §R2 |
| 11 | Forbidden Words Sanitation in Marketing Copy | Eliminate "jumbo", "tostitos redondos", and `#TostitosRedondos` across calendar & copy | M2 | ORIGINAL_REQUEST §R3 |
| 12 | Asset Localization | Copy external Tampico skyline background to `herramientas\` for self-contained builds | M2 | Survey 2 finding |
| 13 | QA Auditor Tool Upgrade | Add FFprobe video validation, fix self-exclusion, expand directory scan, enforce exit codes | E2E_Track | ORIGINAL_REQUEST §R3 |
| 14 | Opaque-Box E2E Test Suite | Automated test harness covering Tiers 1-4 with explicit assertions and TEST_READY.md | E2E_Track | Dual Track standard |
| 15 | Control Panel Synchronization | Synchronize video, flyers, and periodic posts in `panel_control.html`, sanitize forbidden words | M3 | ORIGINAL_REQUEST §R3 |
| 16 | Public Landing Page Synchronization | Synchronize links and assets in `index.html`, verify mobile layout and zero forbidden words | M3 | ORIGINAL_REQUEST §R3 |
| 17 | Final E2E Test Pass & Coverage Hardening | 100% pass of Tiers 1-4 tests followed by Tier 5 adversarial coverage hardening | M4 | Final Milestone standard |
| 18 | GitHub Pages Git Repository Initialization | Local Git repo on main, .nojekyll in root, .gitignore excluding >100MB binaries | M5 | ORIGINAL_REQUEST 2026-10-16T05:01:09Z §R1 |
| 19 | Assisted Deployment Script & Beginner Guide | `desplegar_github_pages.ps1` and `GUIA_DESPLIEGUE_GITHUB_PAGES.md` by Mentor Técnico | M5 | ORIGINAL_REQUEST 2026-10-16T05:01:09Z §R2 |
| 20 | Zero Rosa 210 & Colonia Flores Address Lock | Pure "Colonia Flores, Tampico, Tamaulipas" address, zero "Rosa 210" or "Base de Operaciones" | M5 | ORIGINAL_REQUEST 2026-10-16T05:01:09Z §R3 |
| 21 | 1-Month 16-Piece Content Calendar Matrix | 4 thematic weeks (Semana 1-4) with 16 strategic pieces for FB, IG, and TikTok | M6 | ORIGINAL_REQUEST 2026-10-16T06:43:08Z §R1 |
| 22 | Viral Copywriting & 48 Opening Hooks | 3 hooks per piece, A/B roll text, dosed Tampico slang, hashtags, WhatsApp CTA | M6 | ORIGINAL_REQUEST 2026-10-16T06:43:08Z §R1, R2 |
| 23 | High-Impact Commercial Graphics Rendering | 16 pieces Feed 1080x1080 & Stories 1080x1920 with pop aesthetic, contact shadows, badges | M7 | ORIGINAL_REQUEST 2026-10-16T06:43:08Z §R2 |
| 24 | Control Panel Interactive Tabs & Cards | Interactive tabs (Semana 1-4, FB, IG, TikTok), responsive cards, 1-click copy & download | M8 | ORIGINAL_REQUEST 2026-10-16T06:43:08Z §R3 |
| 25 | Master ZIP Package Re-architecture | Organized weekly subfolders (Semana_1 to Semana_4) with PNGs and copy TXTs | M8 | ORIGINAL_REQUEST 2026-10-16T06:43:08Z §R3 |
| 26 | QA Automation & Live GitHub Pages Sync | Zero forbidden words, Rosa 210 check, exit code 0, git push, live 200 OK verification | M9 | ORIGINAL_REQUEST 2026-10-16T06:43:08Z §R3, R4 |
| 27 | 60fps Dynamic 2D Animation Engine & MP4 Render | 1080x1920 @ 60fps H.264, lip-sync RMS envelope, expressions, blinking, camera dynamics, emerald lightning transformation, $150 MXN subtitles | M10 | ORIGINAL_REQUEST 2026-10-17T03:10:32Z §R3 |
| 28 | Spooky Promo Sync & Alignment | Update `VIDEOS/promo_halloween_zombies_crudos.mp4` with the 60fps animation render | M10 | ORIGINAL_REQUEST 2026-10-17T03:10:32Z §R3 |
| 29 | Interactive Web Players & Download Integration | Dedicated ready-to-play player in `panel_control.html` and responsive neon video player in `index.html` | M11 | ORIGINAL_REQUEST 2026-10-17T03:10:32Z §R3 |
| 30 | Master ZIP Alignment (< 100 MB) | Rebuild `paquete_redes_la_garza.zip` with 60fps animation while strictly capping at < 100 MB | M11 | ORIGINAL_REQUEST 2026-10-17T03:10:32Z §R3 |
| 31 | QA Audit Hardening & Live Deployment | Extend `auditar_multimedia_qa.ps1` with 60fps ffprobe and zip checks, git push, live 200 OK | M12 | ORIGINAL_REQUEST 2026-10-17T03:10:32Z §R4 |

## Milestones
| # | Name | Scope | Dependencies | Status |
|---|------|-------|-------------|--------|
| E2E | E2E Testing Track | Test harness, QA script upgrade (`auditar_multimedia_qa.ps1`), Tiers 1-4 test suite, `TEST_READY.md` | none | DONE |
| M1 | Video & Audio Production | Voiceover generation, audio ducking, full HD 1080x1920 video composition without black bars | none | DONE |
| M2 | Graphic Design & Marketing Assets | Elevation of 3 flyers and 6 periodic posts, forbidden words elimination in copy, asset localization | none | DONE |
| M3 | Web Presentation & Control Panel Sync | Updating `panel_control.html` and `index.html` with new video and images, copy sanitation | M1, M2 | DONE |
| M4 | Final E2E Pass & Adversarial Hardening | 100% pass of E2E test suite (Tiers 1-4) + Tier 5 adversarial hardening | E2E, M1, M2, M3 | DONE |
| M5 | GitHub Pages & Production Deployment | Git init main, .nojekyll, .gitignore, clean relative paths, deploy script, beginner guide, zero Rosa 210 | M1, M2, M3, M4 | DONE |
| M6 | 1-Month Copywriting & Content Matrix | Full calendar in `CALENDARIO_MES_COMPLETO.md`, 16 copy files, 48 hooks, Tampico slang, WhatsApp CTAs | none | DONE (3bc08e61-05c7-4faa-8e21-03976bd544a1: 17 files authored, 48 hooks, 0 forbidden words, QA exit 0) |
| M7 | High-Impact Graphics Production (16 pieces) | Automated GDI+ renderer `generar_catalogo_mes.ps1`, 16 Feed 1080x1080 and Stories 1080x1920 images | M6 | DONE (be2e337a-a3b6-4222-b820-b0402ba0c01b: 32 high-res PNGs rendered, 64 mirrored files, >1.3MB each, QA exit 0) |
| M8 | Control Panel Sync & Master ZIP Packaging | Upgrade `panel_control.html` with 4-week tabs, copy/download actions; rebuild `paquete_redes_la_garza.zip` | M6, M7 | DONE (f525f59a-10eb-4589-bfa3-71ae9db73b5d: 29 cards, multi-tag filter, 82.9MB ZIP with 4 subfolders, QA exit 0) |
| M9 | Brand QA Audit, GitHub Pages Push & Live Sync | Update `auditar_multimedia_qa.ps1`, verify exit 0, git commit/push, live HTTP 200 OK | M8 | DONE (Gate PASS: commit 807babe, live 200 OK, 34/34 tests pass, QA exit 0, Auditor CLEAN) |
| M10 | 60fps Dynamic Animation Rendering | Execute `producir_animacion_estudio_60fps.py` producing `VIDEOS/animacion_la_garza_episodio_crudos_60fps.mp4` and updating `VIDEOS/promo_halloween_zombies_crudos.mp4` | none | DONE (Gate PASS: 3919 frames, 60.0 fps, 4895 kbps, 0 errors, CLEAN audit) |
| M11 | Web Player Integration & ZIP Packaging | Embed interactive video players in `panel_control.html` and `index.html`, rebuild ZIP (< 100 MB), extend QA script | M10 | DONE (c985c628-46ee-406d-9160-0c49a0bb0953: players embedded, ZIP 96.16 MB, QA audit exit 0) |
| M12 | Autonomous QA Audit & Production Deployment | Execute updated QA script, verify exit code 0, git push, live HTTP 200 OK | M11 | DONE (aba8b8f4-b3ea-4a8c-827e-298ea9364364: QA audit exit 0, git push origin main, live 200 OK) |

## Interface Contracts
### Video Pipeline ↔ Web & Presentation (`VIDEOS\promo_aguachile_verde_final.mp4`)
- **Container**: MP4 (ISO Base Media)
- **Video**: H.264 / AVC, High Profile, 1080 x 1920 px (9:16 vertical), >= 4000 kbps, pixel format `yuv420p`, progressive.
- **Audio**: AAC, 2 channels stereo, 44.1 kHz, >= 192 kbps.
- **Content**: Voiceover (announcing weekend service, fresh prep in front of customer, routes announced on social media, WhatsApp 833 252 09 88) ducked with `Beachfront_Celebration.mp3`.
- **Target File**: `d:\AG\la garza aguachilera\VIDEOS\promo_aguachile_verde_final.mp4`

### 60fps Dynamic Animation Video ↔ Web & Presentation (M10 ↔ M11)
- **Container**: MP4 (ISO Base Media)
- **Video**: H.264 / AVC, High Profile, 1080 x 1920 px (9:16 vertical), 60 fps (exact `60/1`), >= 4000 kbps, pixel format `yuv420p`.
- **Audio**: AAC, 2 channels stereo, 44.1 kHz, master audio ducked with SFX and Mexican voices (`es-MX`).
- **Features**: Lip-sync matching RMS envelope, 2.1s eye blinking, dynamic squash & stretch, camera shake & zoom, UFO abductor beam, emerald lightning zombie resurrection, $150 MXN subtitles in Safe Zone.
- **Target Files**:
  - `d:\AG\la garza aguachilera\VIDEOS\animacion_la_garza_episodio_crudos_60fps.mp4`
  - `d:\AG\la garza aguachilera\VIDEOS\promo_halloween_zombies_crudos.mp4`

### Web Players ↔ Master ZIP & Deployment (M11 ↔ M12)
- **panel_control.html**: Dedicated video showcase card for the 60fps animated episode with interactive player (`<video controls playsinline ...>`) and 1-click download button.
- **index.html**: Responsive HTML5 video player embedded with neon-tropical styling so visitors can watch the episode directly.
- **Master ZIP**: `paquete_redes_la_garza.zip` rebuilt to include the updated 60fps animation while strictly remaining `< 100 MB`.
- **QA Script**: `herramientas\auditar_multimedia_qa.ps1` enforcing 60fps ffprobe verification, `< 100 MB` ZIP size, and returning exit code 0.
- **Production Host**: `https://lagarzaaguachilera.github.io/` and `https://lagarzaaguachilera.github.io/panel_control.html` responding HTTP 200 OK.

## Code Layout & File Boundaries
- `herramientas/producir_animacion_estudio_60fps.py`, `VIDEOS/animacion_la_garza_episodio_crudos_60fps.mp4`, `VIDEOS/promo_halloween_zombies_crudos.mp4`: Owned by Milestone 10.
- `index.html`, `panel_control.html`, `herramientas/empaquetar_redes_zip.ps1`, `paquete_redes_la_garza.zip`, `herramientas/auditar_multimedia_qa.ps1`: Owned by Milestone 11.
- Git commit, push & live verification: Owned by Milestone 12.
