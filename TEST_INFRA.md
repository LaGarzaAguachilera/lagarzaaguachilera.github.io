# Arquitectura de Infraestructura de Pruebas E2E y Control de Calidad (QA)
**Proyecto:** La Garza Aguachilera — Reproducción de Episodio Animado Cartoon Network ($150 MXN)  
**Documento:** `TEST_INFRA.md`  
**Autor:** Ingeniero de Infraestructura de Pruebas E2E y QA (`test_writer_e2e`)  
**Fecha:** 17 de Octubre de 2026  
**Versión:** 2.0.0 (Cartoon Network 60 FPS / Producción Audiovisual)

---

## 1. Resumen Ejecutivo y Filosofía de Calidad

Este documento establece la arquitectura, taxonomía, herramientas y directrices de prueba de extremo a extremo (E2E) para la producción audiovisual y el ecosistema comercial de **La Garza Aguachilera**, enfocado en la re-producción del episodio animado *"La Resurrección de la Cruda: ¡No estaban muertos... solo estaban crudos!"* a un precio oficial y estricto de **$150 MXN**.

### Principios Rectores:
1. **Pruebas de Caja Opaca Reales (Opaque-Box Testing):** Las pruebas inspeccionan únicamente artefactos binarios, streams multimedia, marcas de tiempo, parámetros de audio y código fuente de entrega (`VIDEOS/*.mp4`, `herramientas/*.wav`, `*.html`, `paquete_redes_la_garza.zip`). Queda estrictamente prohibido el uso de pruebas de fachada (*facade tests*) que pasen sin verificar la lógica y contenido real.
2. **Determinismo y Origen Autoritativo:** Cada caso de prueba se deriva de forma trazable desde `ORIGINAL_REQUEST.md` y `PROJECT.md`.
3. **Control Estricto de Códigos de Salida (Exit Codes):**
   - Retorno `exit 0`: Aprobación total (100% de aserciones conformes).
   - Retorno `exit 1`: Cualquier fallo, regresión de precio (mención de $170), violación de bitrate, desalineación temporal o palabra prohibida.
4. **Independencia y Aislamiento:** Cada prueba es autosuficiente, no depende del orden de ejecución y puede ejecutarse de manera individual o por niveles (Tiers).

---

## 2. Herramientas y Pila Tecnológica

| Componente / Herramienta | Versión / Entorno | Rol en la Infraestructura de Pruebas |
|---|---|---|
| **PowerShell** | 5.1 / 7+ (Windows) | Motor del arnés principal de pruebas (`tests/e2e_cartoon_network_suite.ps1`) |
| **FFprobe / FFmpeg** | 6.0 / 6.1 x64 (`herramientas/ffmpeg/`) | Extracción y validación de streams de video (H.264, 60fps, 1080x1920) y audio (AAC, 44.1kHz) |
| **Python** | 3.14 x64 (`pythoncore-3.14-64`) | Procesamiento matricial, análisis de luminancia y varianza de color en cuadros clave |
| **GDI+ (`System.Drawing`)** | .NET Framework nativo | Medición métrica de dimensiones de imagen, canales alfa y safe zones |
| **System.IO.Compression** | .NET Framework nativo | Inspección binaria del archivo ZIP distribuible sin extracción previa |

---

## 3. Jerarquía de Pruebas en 4 Niveles (4-Tier Test Architecture)

La suite E2E implementa 161 pruebas estructuradas en cuatro capas complementarias:

```
+-----------------------------------------------------------------------------------------+
|  TIER 4: Escenarios Reales de Aceptación (UAT - Customer Journey) [>= 7 Escenarios]     |
+-----------------------------------------------------------------------------------------+
                                             ^
                                             |
+-----------------------------------------------------------------------------------------+
|  TIER 3: Combinaciones Cruzadas entre Componentes (Cross-Feature) [>= 14 Pruebas]       |
+-----------------------------------------------------------------------------------------+
                                             ^
                                             |
+-----------------------------------------------------------------------------------------+
|  TIER 2: Casos Límite, Umbrales y Fronteras (Boundaries & Corners) [>= 70 Pruebas]      |
|          (>= 5 pruebas por cada una de las 14 características en PROJECT.md)            |
+-----------------------------------------------------------------------------------------+
                                             ^
                                             |
+-----------------------------------------------------------------------------------------+
|  TIER 1: Cobertura Funcional de Características (Features 1 a 14) [>= 70 Pruebas]       |
|          (>= 5 pruebas por cada una de las 14 características en PROJECT.md)            |
+-----------------------------------------------------------------------------------------+
```

---

## 4. Mapeo del Inventario de Características (PROJECT.md)

Las 14 características del inventario de `PROJECT.md` están cubiertas exhaustivamente en los cuatro tiers:

| Feature ID | Nombre de Característica | Descripción y Artefactos Clave | Milestone |
|---|---|---|---|
| **F01** | Voces Mexicanas Expresivas TTS | Síntesis vocal de Juancho, Freddy, Alien y Locutora (`sc[1-6].wav`, `audio_animacion_master_60fps.wav`) | M1 |
| **F02** | Diseño Sonoro y Auto-Ducking | Efectos procedurales (crunch ASMR, garras Freddy, abducción) y auto-ducking con `Beachfront_Celebration.mp3` | M1 |
| **F03** | Keyframes 2D Cel-Shaded Escena 1 | Juancho Zombie en Laguna del Carpintero (start & end) en 9:16 estilo Cartoon Network | M2 |
| **F04** | Keyframes 2D Cel-Shaded Escena 2 | Mapache Freddy Krueger en Escolleras Miramar (start & end) en 9:16 estilo Cartoon Network | M2 |
| **F05** | Keyframes 2D Cel-Shaded Escena 3 | OVNI Miramar abduciendo limones y hielera a 2°C (start & end) en 9:16 estilo Cartoon Network | M2 |
| **F06** | Keyframes 2D Cel-Shaded Escena 4 | Clímax del Crunch y Resurrección (~100g camarón mariposa, Tostitos Salsa Verde a $150 MXN) | M2 |
| **F07** | Keyframes 2D Cel-Shaded Escenas 5 y 6 | Fiesta en Miramar y Cierre Comercial con horario (Sáb-Dom 1-5 PM) y WhatsApp 833 252 09 88 | M2 |
| **F08** | Interpolación de Video Omni Flash Escenas 1-3 | Clips de video fluido 1080x1920 9:16 para escenas 1, 2 y 3 usando `--first-frame` y `--last-frame` | M3 |
| **F09** | Interpolación de Video Omni Flash Escenas 4-6 | Clips de video fluido 1080x1920 9:16 para escenas 4, 5 y 6 usando `--first-frame` y `--last-frame` | M3 |
| **F10** | Ensamble Master 1080x1920 @ 60fps | Master `VIDEOS/animacion_la_garza_episodio_crudos_60fps.mp4` a 60 fps, H.264, bitrate >=4000 kbps | M4 |
| **F11** | Integración Web y Empaque ZIP < 100MB | Actualización de `<video>` en `index.html` y `panel_control.html`, empaque `paquete_redes_la_garza.zip` | M4 |
| **F12** | Auditoría QA y Precio $150 MXN | Ejecución de `herramientas/auditar_multimedia_qa.ps1`, 0 menciones de $170, precio $150 MXN intacto | M5 |
| **F13** | Validación Visual Cartoon Network | Extracción y verificación visual de frames confirmando estética 2D cel-shaded, riqueza cromática | M5 |
| **F14** | Despliegue en GitHub Pages | Configuración Git para `lagarzaaguachilera.github.io`, `.nojekyll` presente y sello de calidad | M5 |

---

## 5. Especificación de Pruebas por Nivel

### 5.1 Tier 1: Cobertura Funcional (70 Pruebas: 5 por Feature)
- **T1-F01 (01-05):** Existencia de audio master WAV (>= 5 MB), sample rate 44.1 kHz estéreo, duración nominal 65.3s, integridad de timeline JSON con marcas por escena, y presencia de los 6 clips de voz independientes en `herramientas/audio_animacion/`.
- **T1-F02 (01-05):** Presencia de música oficial `Beachfront_Celebration.mp3` (>= 5 MB), presencia de factor de ducking en script de producción de audio, datos de onda no nulos (RMS > 0.01), estructura de escenas en JSON, e implementación de SFX procedurales (crunch, garras, abducción).
- **T1-F03 (01-05):** Activos de Juancho (`clean_juancho.png`, `sticker_spooky_juancho_jason.png`) en 32bpp, rigging anatómico para Juancho Zombie, proporción 9:16 vertical, y diálogo inicial de cruda en Laguna del Carpintero.
- **T1-F04 (01-05):** Activos de Mapache (`clean_mapache.png`, `sticker_spooky_mapache_freddy.png`) en 32bpp, rigging anatómico para Mapache Freddy, proporción 9:16 vertical, y diálogo de hambre cómica en Escolleras Miramar.
- **T1-F05 (01-05):** Activos de OVNI (`clean_ovni.png`, `sticker_spooky_ovni_muertos.png`) en 32bpp, rigging de rayo abductor y alien, proporción 9:16 vertical, y parámetros de abducción criogénica a 2°C y limones Colima.
- **T1-F06 (01-05):** Fotografía macro de alta resolución del platillo (`clean_comida.png`), rigging de Juancho revivido (`juancho_vivo`), transición de relámpago esmeralda, mandatos de precio estricto $150 MXN, y especificación de ~100g de camarón mariposa.
- **T1-F07 (01-05):** Fondo panorámico de Tampico (`tampico_skyline_bg.jpg`), teléfono oficial WhatsApp `833 252 09 88`, horario de servicio `1:00 PM a 5:00 PM`, promesa de frescura ("El producto es preparado frente a usted..."), y márgenes de overlay comercial.
- **T1-F08 (01-05):** Parámetros para generación Omni Flash en 9:16, renderizado de Escena 1 (duración >= 9.0s), renderizado de Escena 2 (duración >= 8.0s), renderizado de Escena 3 (duración >= 9.5s), y motor de squash & stretch con parpadeo automático.
- **T1-F09 (01-05):** Renderizado de Escena 4 (duración >= 10.0s), renderizado de Escena 5 (duración >= 4.5s), renderizado de Escena 6 (duración >= 9.5s), subtítulos dinámicos palabra por palabra, y efectos de camera shake en crunch.
- **T1-F10 (01-05):** Existencia de video master (`VIDEOS/animacion_la_garza_episodio_crudos_60fps.mp4`) <= 42 MB, resolución 1080x1920, framerate exacto 60.0 fps, codec H.264 High Profile con bitrate >= 4000 kbps, y espejo spooky `VIDEOS/promo_halloween_zombies_crudos.mp4`.
- **T1-F11 (01-05):** Reproductor `<video>` en `index.html`, reproductor `<video>` en `panel_control.html`, archivo `paquete_redes_la_garza.zip` < 100 MB, estructura de 4 semanas en ZIP, y script de empaquetado `empaquetar_redes_zip.ps1`.
- **T1-F12 (01-05):** Existencia de script auditor `herramientas/auditar_multimedia_qa.ps1`, blindaje de `index.html` (cero menciones de $170), presencia dominante de $150 MXN en `index.html` (>= 5), presencia dominante de $150 MXN en `panel_control.html` (>= 20), y blindaje de `panel_control.html` (cero menciones de $170).
- **T1-F13 (01-05):** Extracción de frames en t=2.0s, t=15.0s, t=28.0s, t=42.0s y t=60.0s confirmando dimensiones 1080x1920 y datos de imagen válidos.
- **T1-F14 (01-05):** Archivo `.nojekyll` en raíz, scripts de despliegue `desplegar_github_pages.ps1` y `desplegar_automatico.bat`, referencia al dominio `lagarzaaguachilera.github.io`, y presencia del sello de control de calidad.

### 5.2 Tier 2: Casos Límite y Fronteras (70 Pruebas: 5 por Feature)
- **T2-B01 a T2-B14:** Validación de límites estrictos:
  - Audio: Bits por muestra = 16, duración entre 60.0s y 70.0s, sample rate exacto 44,100 Hz, canales exactos = 2.
  - Diseño Sonoro: Tamaño de música >= 5 MB, factor de ducking en rango [0.10, 0.30], valores RMS en [0.0, 1.0], amplitud máxima <= 0 dBFS.
  - Keyframes y Sprites: Dimensiones mínimas >= 400px, aspect ratio 9:16 con tolerancia delta < 0.001, anclajes de boca/ojos en rango [0, 650], canales alfa con transparencia real.
  - Blindaje Comercial: Rechazo de precios vacíos/cero/negativos, rechazo de $170 en activos clave, gramaje de camarón en [90g, 110g], foto macro >= 800px.
  - Cierre y Contacto: Teléfono exacto de 10 dígitos (8332520988), horario de 13:00 a 17:00, días estrictos "Sábados y Domingos", safe zone >= 25px.
  - Duración de Escenas: Escena 1 [8-15s], Escena 2 [6-12s], Escena 3 [8-14s], Escena 4 [8-15s], Escena 5 [4-8s], Escena 6 [8-14s].
  - Video Master: Bitrate >= 4,000,000 bps, framerate 60.0 fps (delta < 0.1), peso <= 42,000,000 bytes, audio bitrate >= 128 kbps, pix_fmt `yuv420p`.
  - Paquete ZIP: Peso < 104,857,600 bytes y >= 20,000,000 bytes, rutas relativas sin dependencias de disco local (`C:\` o `d:\`).
  - Términos Prohibidos: Cero menciones de "totopos redondos" en páginas web y catálogo.
  - Cuadros de Animación: Peso de frame extraído >= 200 KB, luminancia media en [10, 245] (cero pantallas negras o blancas), desviación estándar de color >= 15.0, total de frames entre 3915 y 3925.
  - Despliegue: Branch de despliegue = `main`, `.nojekyll` de 0 bytes, sello exacto de calidad verificado.

### 5.3 Tier 3: Combinaciones Cruzadas entre Componentes (14 Pruebas)
- **T3-C01:** F01 + F02 — Mezcla de voces TTS con música auto-atenuada sin recorte acústico.
- **T3-C02:** F01 + F10 — Sincronía temporal audio WAV vs video master (delta < 0.2s).
- **T3-C03:** F02 + F10 — Parámetros de stream de audio en MP4 coinciden con diseño sonoro (AAC stereo 44.1kHz).
- **T3-C04:** F03 + F08 — Keyframes y rigging de Escena 1 alineados con clip animado de Juancho Zombie.
- **T3-C05:** F04 + F08 — Keyframes y rigging de Escena 2 alineados con clip animado de Mapache Freddy.
- **T3-C06:** F05 + F08 — Keyframes y rigging de Escena 3 alineados con abducción OVNI y limones a 2°C.
- **T3-C07:** F06 + F09 — Keyframes de Escena 4 alineados con relámpago esmeralda, crunch y resurrección $150 MXN.
- **T3-C08:** F07 + F09 — Keyframes de Escenas 5 y 6 alineados con fiesta Miramar, WhatsApp y horario.
- **T3-C09:** F08/F09 + F10 — Sumatoria de escenas coincide con duración total del master a 60fps (delta < 1.0s).
- **T3-C10:** F10 + F11 — Reproductor HTML5 en `index.html` y `panel_control.html` reproduce el video compilado a 60fps.
- **T3-C11:** F10 + F12 — El video maestro 60fps satisface los criterios técnicos del auditor QA.
- **T3-C12:** F11 + F12 — Consistencia del precio oficial $150 MXN entre páginas web y suite de calidad.
- **T3-C13:** F11 + F14 — Páginas web y paquete ZIP estructurados para publicación inmediata en GitHub Pages.
- **T3-C14:** F10 + F13 — Cuadros muestreados a 60fps confirman continuidad estilística 2D Cartoon Network.

### 5.4 Tier 4: Escenarios Reales de Aceptación (7 Escenarios)
- **T4-U01:** Experiencia móvil vertical 9:16 en alta definición (resolución 1080x1920 a 60fps, sincronía A/V < 0.2s, legibilidad sin obstrucción).
- **T4-U02:** Distribución del kit para redes sociales (ZIP < 100MB con 4 semanas de copys y gráficos estructurados).
- **T4-U03:** Flujo completo de conversión y blindaje de precio $150 MXN (visita a `index.html`, visualización de precio, enlace wa.me prellenado).
- **T4-U04:** Panel de control operativo de franquicia (`panel_control.html` con reproducción de master 60fps, catálogo de publicaciones e inventario).
- **T4-U05:** Integridad del promocional viral (`promo_halloween_zombies_crudos.mp4` equivalente al master en calidad y especificaciones).
- **T4-U06:** Certificación de puerta de calidad automatizada (`herramientas/auditar_multimedia_qa.ps1` exit code 0).
- **T4-U07:** Cumplimiento para despliegue en vivo en GitHub Pages (`main`, `.nojekyll`, rutas relativas, sello de aprobación).

---

## 6. Guía de Ejecución y Comandos Oficiales

El arnés principal se ubica en `tests/e2e_cartoon_network_suite.ps1`.

### 6.1 Ejecución Completa (161 Pruebas):
```powershell
powershell -ExecutionPolicy Bypass -File "d:\AG\la garza aguachilera\tests\e2e_cartoon_network_suite.ps1"
```

### 6.2 Ejecución por Nivel (Tier Específico):
```powershell
# Tier 1: Cobertura Funcional (70 pruebas)
powershell -ExecutionPolicy Bypass -File "d:\AG\la garza aguachilera\tests\e2e_cartoon_network_suite.ps1" -Tier 1

# Tier 2: Casos Límite y Fronteras (70 pruebas)
powershell -ExecutionPolicy Bypass -File "d:\AG\la garza aguachilera\tests\e2e_cartoon_network_suite.ps1" -Tier 2

# Tier 3: Combinaciones Cruzadas (14 pruebas)
powershell -ExecutionPolicy Bypass -File "d:\AG\la garza aguachilera\tests\e2e_cartoon_network_suite.ps1" -Tier 3

# Tier 4: Escenarios Reales de Aceptación (7 escenarios)
powershell -ExecutionPolicy Bypass -File "d:\AG\la garza aguachilera\tests\e2e_cartoon_network_suite.ps1" -Tier 4
```

### 6.3 Ejecución Filtrada por Característica:
```powershell
# Filtrar pruebas asociadas únicamente a Feature 10 (Ensamble Master 60fps)
powershell -ExecutionPolicy Bypass -File "d:\AG\la garza aguachilera\tests\e2e_cartoon_network_suite.ps1" -Feature 10
```

### 6.4 Ejecución con Reporte Detallado:
```powershell
powershell -ExecutionPolicy Bypass -File "d:\AG\la garza aguachilera\tests\e2e_cartoon_network_suite.ps1" -VerboseReport
```

---

## 7. Criterios de Aceptación y Códigos de Retorno

| Código | Significado | Criterio de Activación |
|---|---|---|
| `0` | **APROBADO (PASS)** | Todas las pruebas evaluadas resultaron conformes. Cumplimiento del 100%. |
| `1` | **RECHAZADO (FAIL)** | Una o más pruebas fallaron por discrepancia con las especificaciones autoritativas. |

---

## 8. Matriz de Trazabilidad Consolidada

| Requerimiento Autoritativo | Feature ID | Casos Tier 1 | Casos Tier 2 | Casos Tier 3 | Escenarios Tier 4 |
|---|---|---|---|---|---|
| ORIGINAL_REQUEST §4 (TTS Mexicano) | F01 | T1-F01-01..05 | T2-B01-01..05 | T3-C01, T3-C02 | T4-U01 |
| ORIGINAL_REQUEST §4 & R2 (Audio/Ducking) | F02 | T1-F02-01..05 | T2-B02-01..05 | T3-C01, T3-C03 | T4-U01 |
| ORIGINAL_REQUEST R1.1 (Escena 1 Juancho) | F03 | T1-F03-01..05 | T2-B03-01..05 | T3-C04 | T4-U01, T4-U04 |
| ORIGINAL_REQUEST R1.2 (Escena 2 Freddy) | F04 | T1-F04-01..05 | T2-B04-01..05 | T3-C05 | T4-U01, T4-U04 |
| ORIGINAL_REQUEST R1.3 (Escena 3 OVNI) | F05 | T1-F05-01..05 | T2-B05-01..05 | T3-C06 | T4-U01, T4-U04 |
| ORIGINAL_REQUEST R1.4 (Escena 4 Clímax) | F06 | T1-F06-01..05 | T2-B06-01..05 | T3-C07 | T4-U01, T4-U03 |
| ORIGINAL_REQUEST R1.5 (Escenas 5-6 Cierre) | F07 | T1-F07-01..05 | T2-B07-01..05 | T3-C08 | T4-U01, T4-U03 |
| ORIGINAL_REQUEST R2.1 (Omni Flash 1-3) | F08 | T1-F08-01..05 | T2-B08-01..05 | T3-C04..06, T3-C09 | T4-U01 |
| ORIGINAL_REQUEST R2.1 (Omni Flash 4-6) | F09 | T1-F09-01..05 | T2-B09-01..05 | T3-C07..08, T3-C09 | T4-U01 |
| ORIGINAL_REQUEST R2.2 & R3.1 (Master 60fps) | F10 | T1-F10-01..05 | T2-B10-01..05 | T3-C02,03,09,10,11,14 | T4-U01, T4-U05 |
| ORIGINAL_REQUEST R3.3 (Web & ZIP < 100MB) | F11 | T1-F11-01..05 | T2-B11-01..05 | T3-C10, T3-C12, T3-C13 | T4-U02, T4-U03, T4-U04 |
| ORIGINAL_REQUEST Criteria (QA $150 MXN) | F12 | T1-F12-01..05 | T2-B12-01..05 | T3-C11, T3-C12 | T4-U03, T4-U06 |
| ORIGINAL_REQUEST R3.2 (Estética 2D CN) | F13 | T1-F13-01..05 | T2-B13-01..05 | T3-C14 | T4-U01, T4-U04 |
| ORIGINAL_REQUEST Criteria (GitHub Pages) | F14 | T1-F14-01..05 | T2-B14-01..05 | T3-C13 | T4-U07 |
