# Arquitectura de Infraestructura de Pruebas E2E y Control de Calidad (QA)
**Proyecto:** La Garza Aguachilera -- Elevacion de Multimedia y Franquicia  
**Documento:** `TEST_INFRA.md`  
**Autor:** Ingeniero de Infraestructura de Pruebas E2E y QA (`worker_e2e_testing_1`)  
**Fecha:** 16 de Octubre de 2026  
**Version:** 1.0.0 (Produccion / Enterprise Grade)

---

## 1. Resumen Ejecutivo y Filosofia de Calidad

Este documento define la arquitectura, convenciones, herramientas y jerarquia de pruebas de extremo a extremo (E2E) para el ecosistema multimedia y comercial de **La Garza Aguachilera**.

### Principios Rectores:
1. **Pruebas de Caja Opaca Reales (Opaque-Box Testing):** Las pruebas inspeccionan unicamente los artefactos compilados y generados (videos MP4, imagenes PNG/JPG, streams de audio, scripts PowerShell y portales HTML). Cero pruebas de fachada (facade tests); las asersiones evaluan propiedades reales de archivos y flujos de ejecucion.
2. **Determinismo y Trazabilidad:** Cada prueba cuenta con un origen autoritativo derivado directamente de `ORIGINAL_REQUEST.md` y `PROJECT.md`.
3. **Enforcement Estricto de Codigos de Salida (Exit Codes):**
   - Retorno `exit 0` si y solo si todas las asersiones pasan al 100%.
   - Retorno `exit 1` ante cualquier discrepancia o desviacion de estandares de franquicia.
4. **Independencia y Aislamiento:** Cada suite puede ejecutarse de manera autonoma o integrada en pipelines de CI/CD.

---

## 2. Herramientas y Pila Tecnologica

| Herramienta / Tecnologia | Version / Componente | Proposito |
|---|---|---|
| **PowerShell** | 5.1 / 7+ (Windows) | Motor de orquestacion, ejecucion de pruebas y auditorias |
| **FFmpeg / FFprobe** | 6.0 / 6.1 x64 (`herramientas\ffmpeg\`) | Inspeccion binaria de streams multimedia (video y audio) |
| **GDI+ (`System.Drawing`)** | .NET Framework nativo | Calculo metrico de fuentes, cajas tipograficas y Safe Zones |
| **Microsoft Speech API (SAPI)**| `System.Speech.Synthesis` | Validacion de master de locucion comercial Sabina |

---

## 3. Jerarquia de Pruebas (Test Hierarchy)

La suite de pruebas automatizada (`tests\e2e_test_suite.ps1`) organiza la verificacion en cuatro capas exhaustivas:

```
+-----------------------------------------------------------------------+
|  TIER 4: Escenarios Reales de Aceptacion (UAT - Experiencia Usuario)  |
+-----------------------------------------------------------------------+
                                  ^
                                  |
+-----------------------------------------------------------------------+
|  TIER 3: Combinaciones Cruzadas entre Componentes (Cross-Feature)    |
+-----------------------------------------------------------------------+
                                  ^
                                  |
+-----------------------------------------------------------------------+
|  TIER 2: Casos Limite, Umbrales y Fronteras (Boundaries & Corners)   |
+-----------------------------------------------------------------------+
                                  ^
                                  |
+-----------------------------------------------------------------------+
|  TIER 1: Cobertura Funcional de Caracteristicas (Features 1 a 17)     |
+-----------------------------------------------------------------------+
```

### 3.1 Tier 1: Cobertura de Caracteristicas (Feature Coverage)
Cubre las 17 funcionalidades estipuladas en `PROJECT.md`:
* **T1-F01:** Full HD Video 1080x1920 (H.264 High Profile, >=4000 kbps, AAC stereo).
* **T1-F02:** Eliminacion de franjas negras (`pad=...:black`) y recorte de baja resolucion (`640x663`).
* **T1-F03:** Movimiento cinematico Ken Burns (pan/zoom) en fotografia macro de comida.
* **T1-F04:** Integracion estetica de iconos de Tampico (Mapache, OVNI, Juancho).
* **T1-F05:** Master de locucion comercial en espanol anunciando servicio en fin de semana y rutas.
* **T1-F06:** Ducking automatico de la musica oficial `Beachfront_Celebration.mp3`.
* **T1-F07:** Portada Facebook `flyer_portada_verde.png` (1200x630, 32bpp, sin desbordes).
* **T1-F08:** Flyer Post Feed `flyer_post_verde.png` (1080x1080, 32bpp).
* **T1-F09:** Flyer Historia `flyer_historia_verde.png` (1080x1920, 32bpp).
* **T1-F10:** Elevacion de parrilla periodica (6 posts en 1080x1080 con paletas diferenciadas).
* **T1-F11:** Sanitizacion total de copys y calendario de redes (cero palabras prohibidas).
* **T1-F12:** Localizacion de fondos de Tampico en `herramientas\` eliminando rutas rotas.
* **T1-F13:** Auditor QA `auditar_multimedia_qa.ps1` con FFprobe y codigos de salida.
* **T1-F14:** Suite E2E de caja opaca y documentacion de arquitectura `TEST_INFRA.md`.
* **T1-F15:** Sincronizacion y sanitizacion del Panel de Control (`panel_control.html`).
* **T1-F16:** Sincronizacion de Landing Page Publica (`index.html`).
* **T1-F17:** Meta-verificacion del arnes de pruebas.

### 3.2 Tier 2: Casos Limite y Fronteras (Boundaries & Corner Cases)
* **T2-B01:** Relacion de aspecto de video 9:16 vertical (tolerancia delta < 0.001).
* **T2-B02:** Relacion de aspecto de historia 9:16 vertical.
* **T2-B03:** Relacion de aspecto 1:1 exacta en piezas de feed (7 imagenes cuadradas).
* **T2-B04:** Geometria estandar de Portada Facebook (1200x630 px).
* **T2-B05:** Limites de margenes libres en Safe Zones (>=30 px en feed, >=25 px en subtitulos y posts periodicos).
* **T2-B06:** Umbral estricto de bitrate de video: `>= 4,000,000 bps`.
* **T2-B07:** Umbrales de calidad sonora: AAC estéreo, `>= 44,100 Hz`, `>= 128 kbps`.
* **T2-B08:** Rango controlado de atenuacion de musica de fondo (ducking 0.10 a 0.25).
* **T2-B09:** Umbral minimo de integridad de archivo de video (`>= 10 MB`).

### 3.3 Tier 3: Combinaciones Cruzadas entre Componentes (Cross-Feature Combinations)
* **T3-C01:** Sincronizacion video + audio (diferencia entre duracion de video y duracion de audio `< 1.0s`).
* **T3-C02:** Emparejamiento de personajes locales segun narrativa comercial (OVNI en Post 2, Mapache en Post 6, Juancho en Post 1).
* **T3-C03:** Interaccion de Safe Zones con etiquetas comerciales de precio ($170 MXN sin colision tipografica).
* **T3-C04:** Consistencia textual de la promesa de frescura ("El producto es preparado frente a usted para corroborar su frescura") a traves de HTML y marketing.
* **T3-C05:** Consistencia del canal telefonico WhatsApp (833 252 09 88 y `wa.me/528332520988`).

### 3.4 Tier 4: Escenarios Reales de Aceptacion (User Acceptance Testing - UAT)
* **T4-U01:** Experiencia de usuario movil en pantalla vertical 9:16 (TikTok, Instagram Reels, Stories sin obstruccion por botones de UI).
* **T4-U02:** Flujo de conversion de cliente (calculadora de pedidos en `index.html` vinculada a WhatsApp).
* **T4-U03:** Cumplimiento normativo y blindaje de marca (cero menciones de presentaciones no autorizadas, variantes redondas o totopos genericos).

---

## 4. Herramientas Entregadas y Especificacion de Scripts

### 4.1 Auditor Multimedia QA (`herramientas\auditar_multimedia_qa.ps1`)
Script oficial de control de calidad para inspeccion rapida antes de desplegar:
* **Entradas:** 9 imagenes del proyecto, video final `VIDEOS\promo_aguachile_verde_final.mp4`, binario `ffprobe.exe`.
* **Verificaciones:**
  1. Existencia y dimensiones exactas de las 9 piezas graficas.
  2. Medicion GDI+ de Safe Zones y colisiones tipograficas.
  3. Verificacion automatizada FFprobe de video (1080x1920, H.264, pix_fmt yuv420p, bitrate >= 4000 kbps, audio AAC stereo).
  4. Verificacion de presencia de master de locucion y musica oficial.
  5. Escaneo integral de palabras prohibidas con auto-exclusion limpia de si mismo.
* **Salida y Codigo de Retorno:**
  - `exit 0`: Aprobado (0 fallas).
  - `exit 1`: Rechazado (falla registrada).

### 4.2 Suite E2E (`tests\e2e_test_suite.ps1`)
Arnes de pruebas de extremo a extremo:
* **Parametros:**
  - `-Tier <All|1|2|3|4>`: Permite ejecutar todos los tiers o filtrar por nivel.
  - `-VerboseReport`: Muestra detalles tecnicos y causas de fallo por asersion.
* **Metricas Reportadas:** Total de pruebas, pruebas aprobadas, pruebas fallidas, tiempo transcurrido, veredicto final.
* **Codigo de Retorno:** `exit 0` si todas las pruebas del tier seleccionado pasan; `exit 1` si alguna falla.

---

## 5. Guia de Ejecucion

### Ejecucion del Auditor Multimedia QA:
```powershell
powershell -ExecutionPolicy Bypass -File "d:\AG\la garza aguachilera\herramientas\auditar_multimedia_qa.ps1"
```

### Ejecucion de la Suite de Pruebas E2E:
```powershell
# Ejecutar suite completa (Tiers 1 a 4)
powershell -ExecutionPolicy Bypass -File "d:\AG\la garza aguachilera\tests\e2e_test_suite.ps1"

# Ejecutar unicamente Tier 1 (Cobertura de Features)
powershell -ExecutionPolicy Bypass -File "d:\AG\la garza aguachilera\tests\e2e_test_suite.ps1" -Tier 1

# Ejecutar con reporte detallado
powershell -ExecutionPolicy Bypass -File "d:\AG\la garza aguachilera\tests\e2e_test_suite.ps1" -VerboseReport
```

---

## 6. Matriz de Trazabilidad (Requirements ↔ Features ↔ Test IDs)

| Requerimiento | Caracteristica | Test ID | Metodo de Verificacion |
|:---|:---|:---|:---|
| R1.1 Full HD Video | Feature 1 | T1-F01, T2-B01, T2-B06 | FFprobe stream width, height, bitrate, codec |
| R1.1 Sin Franjas Negras | Feature 2 | T1-F02 | Inspeccion estatica de script de render sin pad:black |
| R1.1 Fotografia HD | Feature 3 | T1-F03 | Dimension de fotos macro >= 800px y filtro zoompan |
| R1.2 Identidad Tampico | Feature 4 | T1-F04, T3-C02 | Validacion de PNGs 32bpp y composicion de stickers |
| R1.3 Locucion Sabina | Feature 5 | T1-F05 | Validacion de WAV >= 1MB y copys de servicio/rutas |
| R1.3 Audio Ducking | Feature 6 | T1-F06, T2-B08 | Presencia de musica oficial y ducking 0.18 en script |
| R2 Portada Facebook | Feature 7 | T1-F07, T2-B04 | Resolucion 1200x630, 32bpp y medicion GDI+ de Safe Zones |
| R2 Flyer Post Feed | Feature 8 | T1-F08, T2-B03 | Resolucion 1080x1080, 32bpp y margen libre >= 30px |
| R2 Flyer Historia | Feature 9 | T1-F09, T2-B02 | Resolucion 1080x1920, 32bpp y proporcion 9:16 |
| R2 Posts Periodicos | Feature 10 | T1-F10, T2-B03 | 6 posts en 1080x1080 con margenes libres >= 25px |
| R3 Sanitizacion Copys | Feature 11 | T1-F11, T4-U03 | Escaneo de palabras prohibidas en markdowns |
| Localizacion Activos | Feature 12 | T1-F12 | Verificacion de archivo skyline local en herramientas |
| R3 Auditor QA | Feature 13 | T1-F13 | Verificacion de FFprobe y codigos de salida en script |
| Dual Track E2E | Feature 14 | T1-F14 | Verificacion de e2e_test_suite.ps1 y TEST_INFRA.md |
| R3 Panel de Control | Feature 15 | T1-F15 | Vinculacion de video/flyers y 0 palabras prohibidas |
| R3 Landing Publica | Feature 16 | T1-F16, T4-U02 | WhatsApp 833 252 09 88, precio $170 y calculadora |
| Cierre E2E | Feature 17 | T1-F17 | Meta-verificacion del arnes de prueba |
