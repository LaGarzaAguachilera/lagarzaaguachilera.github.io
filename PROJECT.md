# Project: La Garza Aguachilera — Reproducción de Episodio Animado Cartoon Network ($150 MXN)

## Architecture
- **Pipeline Audiovisual:**
  1. `Audio Track (TTS & SFX)`: `gemini-3.8-flash-tts` + `herramientas/producir_audio_animacion.py` -> `herramientas/audio_animacion_master_60fps.wav` & `herramientas/timeline_animacion_60fps.json`.
  2. `Keyframe Studio (2D Cel-Shaded)`: `gemini-nano-banana-2.1` / `image-generator` con condicionamiento multimodal (stickers base) -> `FRAMES/scene[1-6]_(start|end).png` (9:16 vertical 2K).
  3. `Video Animation Engine`: `gemini-omni-1.1-flash` via `gemini-omni-flash-api/scripts/video/generate_video.py` con `--first-frame` y `--last-frame` -> `VIDEOS/clips/scene[1-6].mp4` (1080x1920 9:16).
  4. `Compositing & Mastering`: FFmpeg concat + master audio track + subtítulos dinámicos -> `VIDEOS/animacion_la_garza_episodio_crudos_60fps.mp4` (1080x1920 @ 60fps, H.264 High Profile, >=4000 kbps, AAC stereo, peso <= 42 MB).
  5. `Web & Packaging`: `index.html`, `panel_control.html`, `paquete_redes_la_garza.zip` (< 100 MB).
  6. `QA & Deployment`: `herramientas/auditar_multimedia_qa.ps1` (código 0, precio estricto $150 MXN) y GitHub Pages (`lagarzaaguachilera.github.io`).

## Feature Inventory
| # | Feature | Description | Milestone | Source |
|---|---------|-------------|-----------|--------|
| 1 | Voces Mexicanas Expresivas TTS | Síntesis vocal cómica de Juancho, Freddy, Alien y Locutora con `gemini-3.8-flash-tts` y speech_metadata | M1 | ORIGINAL_REQUEST §4 |
| 2 | Diseño Sonoro y Auto-Ducking | Efectos procedurales (crunch ASMR, garras Freddy, abducción) y auto-ducking con Beachfront_Celebration.mp3 | M1 | ORIGINAL_REQUEST §4 & R2 |
| 3 | Keyframes 2D Cel-Shaded Escena 1 | Juancho Zombie en Laguna del Carpintero (start & end) en 9:16 estilo Cartoon Network con Nano Banana | M2 | ORIGINAL_REQUEST R1.1 |
| 4 | Keyframes 2D Cel-Shaded Escena 2 | Mapache Freddy Krueger en Escolleras Miramar (start & end) en 9:16 estilo Cartoon Network con Nano Banana | M2 | ORIGINAL_REQUEST R1.2 |
| 5 | Keyframes 2D Cel-Shaded Escena 3 | OVNI Miramar abduciendo limones y hielera a 2°C (start & end) en 9:16 estilo Cartoon Network con Nano Banana | M2 | ORIGINAL_REQUEST R1.3 |
| 6 | Keyframes 2D Cel-Shaded Escena 4 | Clímax del Crunch y Resurrección (~100g camarón mariposa, Tostitos Salsa Verde a $150 MXN) con Nano Banana | M2 | ORIGINAL_REQUEST R1.4 |
| 7 | Keyframes 2D Cel-Shaded Escenas 5 y 6 | Fiesta en Miramar y Cierre Comercial con horario (Sáb-Dom 1-5 PM) y WhatsApp 833 252 09 88 con Nano Banana | M2 | ORIGINAL_REQUEST R1.5 |
| 8 | Interpolación de Video Omni Flash Escenas 1-3 | Clips de video fluido 1080x1920 9:16 para escenas 1, 2 y 3 usando `--first-frame` y `--last-frame` | M3 | ORIGINAL_REQUEST R2.1 |
| 9 | Interpolación de Video Omni Flash Escenas 4-6 | Clips de video fluido 1080x1920 9:16 para escenas 4, 5 y 6 usando `--first-frame` y `--last-frame` | M3 | ORIGINAL_REQUEST R2.1 |
| 10 | Ensamble Master 1080x1920 @ 60fps | Concatenación de clips con audio master y subtítulos dinámicos a 60 fps exactos, H.264, bitrate >=4000 kbps | M4 | ORIGINAL_REQUEST R2.2 & R3.1 |
| 11 | Integración Web y Empaque ZIP < 100MB | Actualización de reproductores `<video>` en `index.html` y `panel_control.html`, re-empaque de `paquete_redes_la_garza.zip` | M4 | ORIGINAL_REQUEST R3.3 |
| 12 | Auditoría QA y Precio $150 MXN | Ejecución y aprobación al 100% de `herramientas/auditar_multimedia_qa.ps1`, cero menciones de precio erróneo, 0 palabras prohibidas | M5 | ORIGINAL_REQUEST R3.3 & Criteria |
| 13 | Validación Visual Cartoon Network | Extracción y verificación visual de frames del video compilado confirmando estética 2D cel-shaded | M5 | ORIGINAL_REQUEST R3.2 |
| 14 | Despliegue en GitHub Pages | Commit y push a `origin/main` en GitHub Pages con sello de control de calidad | M5 | ORIGINAL_REQUEST Criteria |

## Milestones
| # | Name | Scope | Dependencies | Status |
|---|------|-------|-------------|--------|
| M1 | Audio Master & Voces TTS | `gemini-3.8-flash-tts`, SFX procedurales, auto-ducking, `audio_animacion_master_60fps.wav`, `timeline_animacion_60fps.json` | none | DONE (audio_animacion_master_60fps.wav 89.94s, timeline_animacion_60fps.json 5397 frames @ 60fps) |
| M2 | Keyframes 2D Cel-Shaded Cartoon Network | `gemini-nano-banana-2.1`, pares start/end 9:16 para Escenas 1 a 6 con referencias de personaje | none | DONE (12 keyframes 1080x1920 en FRAMES/scene[1-6]_(start|end).png) |
| M3 | Animación Fluida Gemini Omni 1.1 Flash | `gemini-omni-1.1-flash`, generación de 6 clips 1080x1920 9:16 vía `--first-frame` y `--last-frame` | M2 | DONE (6 clips 1080x1920 @ 60fps en VIDEOS/clips/scene[1-6].mp4) |
| M4 | Ensamble Master 60fps, Web & ZIP | FFmpeg concat 1080x1920 @ 60fps, H.264 >=4000kbps, audio sync, `index.html`, `panel_control.html`, `paquete_redes_la_garza.zip` (<100MB) | M1, M3 | IN_PROGRESS (b5dccc14) |
| M5 | Auditoría QA, Validación Visual & Deploy | `auditar_multimedia_qa.ps1` código 0, inspección visual de frames, despliegue a GitHub Pages | M4 | PLANNED |

## Interface Contracts
### Audio Engine (M1) ↔ Animation & Master Compositing (M3, M4)
- **Archivos emitidos por M1:**
  - `herramientas/audio_animacion_master_60fps.wav`: WAV PCM 16-bit estéreo a 44,100 Hz, duración exacta ~65.32s.
  - `herramientas/timeline_animacion_60fps.json`: Marcas de tiempo exactas por escena (`sc1_juancho_zombie` a `sc6_locutora_cierre`), RMS envelope para lip-sync y duración por escena.

### Keyframe Studio (M2) ↔ Gemini Omni 1.1 Flash (M3)
- **Archivos emitidos por M2:**
  - `FRAMES/scene[1-6]_start.png`: PNG 9:16 (resolución >= 1080x1920), 2D cel-shaded estilo Cartoon Network.
  - `FRAMES/scene[1-6]_end.png`: PNG 9:16 (resolución >= 1080x1920), 2D cel-shaded estilo Cartoon Network.
- **Entradas para M3:**
  - Invocación de `generate_video.py` con `--first-frame FRAMES/sceneN_start.png --last-frame FRAMES/sceneN_end.png --aspect-ratio 9:16 --resolution 1080p --duration [6|8]`.

### Video Clips (M3) ↔ Ensamble Master (M4)
- **Archivos emitidos por M3:**
  - `VIDEOS/clips/scene[1-6].mp4`: Video clips 1080x1920 H.264.
- **Entradas para M4:**
  - Concatenación con FFmpeg:
    `-f concat -safe 0 -i clips_list.txt -i herramientas/audio_animacion_master_60fps.wav -c:v libx264 -profile:v high -level 4.2 -pix_fmt yuv420p -b:v 4600k -minrate 4200k -maxrate 5500k -bufsize 10000k -r 60 -c:a aac -b:a 192k -ac 2 -shortest VIDEOS/animacion_la_garza_episodio_crudos_60fps.mp4`.

### Master Video (M4) ↔ QA & Deployment (M5)
- **Archivos emitidos por M4:**
  - `VIDEOS/animacion_la_garza_episodio_crudos_60fps.mp4` (tamaño <= 42 MB, 1080x1920, 60fps, bitrate >= 4000 kbps).
  - `VIDEOS/promo_halloween_zombies_crudos.mp4` (copia idéntica del master).
  - `paquete_redes_la_garza.zip` (tamaño < 100 MB, con estructura intacta).
  - `index.html` y `panel_control.html` con tags `<video>` apuntando al nuevo video y precio $150 MXN intacto.

## Code Layout
- `herramientas/`: Scripts de audio (`producir_audio_animacion.py`), animación (`generar_animacion_omni.py`), render y QA (`auditar_multimedia_qa.ps1`, `empaquetar_redes_zip.ps1`), binarios FFmpeg (`herramientas/ffmpeg/`).
- `FRAMES/`: Cuadros clave 2D cel-shaded (`scene[1-6]_(start|end).png`).
- `VIDEOS/`: Clips individuales (`VIDEOS/clips/`) y videos finales maestros (`VIDEOS/animacion_la_garza_episodio_crudos_60fps.mp4`, `VIDEOS/promo_halloween_zombies_crudos.mp4`).
- `tests/`: Suites de pruebas automatizadas E2E y QA.
- `index.html`, `panel_control.html`: Páginas web de visualización y control.
- `paquete_redes_la_garza.zip`: Paquete de distribución para redes sociales.
