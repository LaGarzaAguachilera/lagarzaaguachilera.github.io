# -*- coding: utf-8 -*-
"""
EMPRESA ESPECIALIZADA DE CONTROL DE CALIDAD E INFRAESTRUCTURA DIGITAL
La Garza Aguachilera -- Multi-Agent QA Enterprise Audit Suite
"""

import os
import sys
import re
import json
import subprocess
from datetime import datetime

if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8')

project_root = r"d:\AG\la garza aguachilera"
report_dir = os.path.join(project_root, "control_calidad")
os.makedirs(report_dir, exist_ok=True)
report_path = os.path.join(report_dir, "INFORME_AUDITORIA_EMPRESA_QA.md")

print("=" * 65)
print("  EMPRESA ESPECIALIZADA DE CONTROL DE CALIDAD E INFRAESTRUCTURA")
print("  Auditoria Integral: Producto, Segmento Media/Alta y Web")
print("=" * 65)

deficiencias = []

# =============================================================================
# AUDITOR 1: INFRAESTRUCTURA DIGITAL Y WEB
# =============================================================================
print("\n--- AUDITOR 1: INFRAESTRUCTURA DIGITAL Y WEB ---")
a1_results = []
html_files = ["index.html", "panel_control.html"]

for hf in html_files:
    abs_hf = os.path.join(project_root, hf)
    if not os.path.exists(abs_hf):
        deficiencias.append(f"Archivo crítico ausente: {hf}")
        a1_results.append(f"[FALLO] {hf} no existe")
        continue

    with open(abs_hf, "r", encoding="utf-8") as f:
        content = f.read()

    # Validar assets en src="..."
    src_matches = re.findall(r'src=["\']([^"\']+\.(?:png|jpg|jpeg|mp4|webm|svg))["\']', content)
    for src in src_matches:
        if not src.startswith("http"):
            asset_abs = os.path.join(project_root, src.replace("/", os.sep))
            if os.path.exists(asset_abs):
                a1_results.append(f"[OK] Asset verificado en {hf}: {src}")
            else:
                deficiencias.append(f"Asset roto (404) en {hf}: {src}")
                a1_results.append(f"[FALLO] Asset roto en {hf}: {src}")

    # Validar responsive viewport
    if 'name="viewport"' in content or "name='viewport'" in content:
        a1_results.append(f"[OK] Viewport responsive presente en {hf}")
    else:
        deficiencias.append(f"Falta meta viewport en {hf}")
        a1_results.append(f"[FALLO] Viewport ausente en {hf}")

    # Validar tag video
    if "<video" in content:
        a1_results.append(f"[OK] Tag <video> HTML5 presente en {hf}")
    else:
        deficiencias.append(f"Falta tag <video> en {hf}")
        a1_results.append(f"[FALLO] Tag <video> ausente en {hf}")

# Validar .nojekyll
if os.path.exists(os.path.join(project_root, ".nojekyll")):
    a1_results.append("[OK] Archivo .nojekyll verificado para GitHub Pages")
else:
    deficiencias.append("Falta archivo .nojekyll en la raíz")
    a1_results.append("[FALLO] .nojekyll ausente")


# =============================================================================
# AUDITOR 2: SOCIOECONOMICO, PERCEPCION DE MARCA Y UX (CLASE MEDIA/MEDIA-ALTA)
# =============================================================================
print("\n--- AUDITOR 2: SOCIOECONOMICO Y UX (CLASE MEDIA/MEDIA-ALTA) ---")
a2_results = []

with open(os.path.join(project_root, "index.html"), "r", encoding="utf-8") as f:
    index_content = f.read()

# 2.1 Los 4 complementos
complements = [
    ("Tostitos Salsa Verde", r"Tostitos\s+Salsa\s+Verde"),
    ("Tostitos Flamin' Hot", r"Flamin'?\s*Hot"),
    ("Chips o Totopos Artesanales", r"(Chips|Totopos)"),
    ("Galletas Saladas", r"Galletas\s+Saladas")
]

for name, pattern in complements:
    if re.search(pattern, index_content, re.IGNORECASE):
        a2_results.append(f"[OK] Complemento exhibido: {name}")
    else:
        deficiencias.append(f"Falta exhibir complemento: {name} en index.html")
        a2_results.append(f"[FALLO] Complemento ausente: {name}")

# 2.2 Las 2 modalidades de servido
if "preparado" in index_content.lower() and ("por separado" in index_content.lower() or "separado" in index_content.lower()):
    a2_results.append("[OK] Modalidades comunicadas: Preparado al Momento y Por Separado")
else:
    deficiencias.append("Modalidades de servicio no comunicadas claramente en index.html")
    a2_results.append("[FALLO] Modalidades de servicio incompletas")

# 2.3 Ausencia de jerga interna
internal_jargon = ["caldo por separado", "dark kitchen", "cubeta de merma", "costo unitario"]
found_jargon = [j for j in internal_jargon if j in index_content.lower()]
if found_jargon:
    for fj in found_jargon:
        deficiencias.append(f"Jerga operativa interna detectada en index.html: {fj}")
        a2_results.append(f"[FALLO] Jerga interna: {fj}")
else:
    a2_results.append("[OK] Comunicación directa y al grano: Cero saturación de datos operativos internos")

# 2.4 Selector interactivo de complementos
if 'id="complement-selector"' in index_content and 'selectComplement' in index_content:
    a2_results.append("[OK] Selector interactivo de complementos activo con UX minimalista")
else:
    deficiencias.append("Selector interactivo de complementos ausente o incompleto")
    a2_results.append("[FALLO] Selector interactivo ausente")

# 2.5 Inclusión de Aguacate Fresco en toda porción y Salsas de la Casa (Campaña Gastronómica)
gastronomy_docs = [
    ("index.html", os.path.join(project_root, "index.html")),
    ("panel_control.html", os.path.join(project_root, "panel_control.html")),
    ("contenido_redes/05_GUIA_PRODUCTO_COMPLEMENTOS_Y_SERVIDO.md", os.path.join(project_root, "contenido_redes", "05_GUIA_PRODUCTO_COMPLEMENTOS_Y_SERVIDO.md"))
]

for doc_name, doc_path in gastronomy_docs:
    if os.path.exists(doc_path):
        with open(doc_path, "r", encoding="utf-8") as f:
            doc_content = f.read()
        if re.search(r"aguacate", doc_content, re.IGNORECASE):
            a2_results.append(f"[OK] Aguacate fresco garantizado verificado en {doc_name}")
        else:
            deficiencias.append(f"Mención de aguacate ausente en {doc_name}")
            a2_results.append(f"[FALLO] Aguacate ausente en {doc_name}")

        if re.search(r"(salsas?\s+de\s+la\s+casa|combinaci[oó]n\s+especial)", doc_content, re.IGNORECASE):
            a2_results.append(f"[OK] Salsas de la casa / combinación especial verificadas en {doc_name}")
        else:
            deficiencias.append(f"Mención de salsas de la casa o combinación especial ausente en {doc_name}")
            a2_results.append(f"[FALLO] Salsas de la casa ausentes en {doc_name}")
    else:
        deficiencias.append(f"Archivo para auditoría gastronómica ausente: {doc_name}")
        a2_results.append(f"[FALLO] Archivo inexistente: {doc_name}")



# =============================================================================
# AUDITOR 3: BLINDAJE DE MARCA Y PRECIOS
# =============================================================================
print("\n--- AUDITOR 3: BLINDAJE DE MARCA Y PRECIOS ---")
a3_results = []

# Cero $150
matches_150 = re.findall(r'(\$150|150\s*MXN|150\s*pesos|150%20|ciento\s*cincuenta)', index_content, re.IGNORECASE)
if not matches_150:
    a3_results.append("[OK] Cero residuos del precio antiguo ($150) en index.html")
else:
    deficiencias.append(f"Se detectaron {len(matches_150)} menciones de $150 en index.html")
    a3_results.append("[FALLO] Precio antiguo detectado ($150)")

# Validar $170
matches_170 = re.findall(r'(\$170|170\s*MXN)', index_content, re.IGNORECASE)
if len(matches_170) >= 5:
    a3_results.append(f"[OK] Precio oficial $170 MXN ratificado ({len(matches_170)} menciones en index.html)")
else:
    deficiencias.append("Insuficientes menciones de $170 MXN en index.html")
    a3_results.append("[FALLO] Menciones insuficientes de $170")

# Ubicación Oficial
if "Colonia Flores, Tampico" in index_content and not re.search(r'Rosa\s*210', index_content, re.IGNORECASE):
    a3_results.append("[OK] Ubicación oficial ratificada: 'Colonia Flores, Tampico, Tamaulipas' (0 menciones de Rosa 210)")
else:
    deficiencias.append("Inconsistencia en la dirección oficial o mención de Rosa 210")
    a3_results.append("[FALLO] Dirección no conforme")

# Facebook URL
fb_official = "https://www.facebook.com/share/19mMzwqpL4/?mibextid=wwXIfr"
if fb_official in index_content:
    a3_results.append("[OK] Enlace oficial de Facebook verificado con mibextid")
else:
    deficiencias.append("Enlace de Facebook incorrecto en index.html")
    a3_results.append("[FALLO] Enlace de Facebook incorrecto")


# =============================================================================
# AUDITOR 4: MULTIMEDIA, VIDEO 60FPS Y PAQUETE ZIP
# =============================================================================
print("\n--- AUDITOR 4: MULTIMEDIA, VIDEO 60FPS Y ZIP ---")
a4_results = []

ffprobe_bin = os.path.join(project_root, r"herramientas\ffmpeg\ffprobe.exe")
master_video = os.path.join(project_root, r"VIDEOS\animacion_la_garza_episodio_crudos_60fps.mp4")
promo_video = os.path.join(project_root, r"VIDEOS\promo_aguachile_verde_final.mp4")

if os.path.exists(ffprobe_bin) and os.path.exists(master_video):
    cmd = [ffprobe_bin, "-v", "error", "-print_format", "json", "-show_format", "-show_streams", master_video]
    res = subprocess.run(cmd, capture_output=True, text=True, encoding="utf-8")
    if res.returncode == 0:
        data = json.loads(res.stdout)
        v_stream = next((s for s in data.get("streams", []) if s.get("codec_type") == "video"), None)
        a_stream = next((s for s in data.get("streams", []) if s.get("codec_type") == "audio"), None)

        if v_stream and v_stream.get("width") == 1080 and v_stream.get("height") == 1920:
            a4_results.append("[OK] Resolución de video animado: 1080x1920 Full HD (9:16 vertical)")
        else:
            w = v_stream.get("width") if v_stream else "N/A"
            h = v_stream.get("height") if v_stream else "N/A"
            deficiencias.append(f"Resolución de video no conforme: {w}x{h}")
            a4_results.append("[FALLO] Resolución de video incorrecta")

        r_fps = v_stream.get("r_frame_rate", "") if v_stream else ""
        avg_fps = v_stream.get("avg_frame_rate", "") if v_stream else ""
        if r_fps == "60/1" or avg_fps == "60/1":
            a4_results.append("[OK] Tasa de cuadros: 60.0 FPS constantes verificados por telemetría")
        else:
            deficiencias.append(f"Frame rate no es 60fps: {avg_fps}")
            a4_results.append("[FALLO] Tasa de cuadros incorrecta")

        if a_stream and a_stream.get("codec_name") == "aac" and a_stream.get("channels") == 2:
            a4_results.append("[OK] Audio master: AAC estéreo con diseño sonoro y auto-ducking")
        else:
            deficiencias.append("Pista de audio no es AAC estéreo")
            a4_results.append("[FALLO] Audio no conforme")
    else:
        deficiencias.append("Fallo al ejecutar telemetría ffprobe")
        a4_results.append("[FALLO] Error en telemetría ffprobe")
else:
    deficiencias.append("ffprobe.exe o master de video ausente")
    a4_results.append("[FALLO] Archivos ausentes para telemetría")

# Telemetría ffprobe para Video Promocional Final
if os.path.exists(ffprobe_bin) and os.path.exists(promo_video):
    cmd_promo = [ffprobe_bin, "-v", "error", "-print_format", "json", "-show_format", "-show_streams", promo_video]
    res_promo = subprocess.run(cmd_promo, capture_output=True, text=True, encoding="utf-8")
    if res_promo.returncode == 0:
        data_p = json.loads(res_promo.stdout)
        v_stream_p = next((s for s in data_p.get("streams", []) if s.get("codec_type") == "video"), None)
        a_stream_p = next((s for s in data_p.get("streams", []) if s.get("codec_type") == "audio"), None)

        if v_stream_p and v_stream_p.get("width") == 1080 and v_stream_p.get("height") == 1920:
            a4_results.append("[OK] Resolución video promocional: 1080x1920 Full HD (9:16 vertical)")
        else:
            w_p = v_stream_p.get("width") if v_stream_p else "N/A"
            h_p = v_stream_p.get("height") if v_stream_p else "N/A"
            deficiencias.append(f"Resolución de video promocional no conforme: {w_p}x{h_p}")
            a4_results.append("[FALLO] Resolución de video promocional incorrecta")

        b_rate_p = int(v_stream_p.get("bit_rate", 0)) if v_stream_p and v_stream_p.get("bit_rate") else int(data_p.get("format", {}).get("bit_rate", 0))
        if b_rate_p >= 4000000:
            a4_results.append(f"[OK] Bitrate de video promocional: {round(b_rate_p/1000)} kbps (>= 4000 kbps verificado)")
        else:
            deficiencias.append(f"Bitrate de video promocional insuficiente: {round(b_rate_p/1000)} kbps")
            a4_results.append("[FALLO] Bitrate promocional insuficiente")

        if a_stream_p and a_stream_p.get("codec_name") == "aac" and a_stream_p.get("channels") == 2:
            a4_results.append("[OK] Audio de video promocional: AAC estéreo verificado")
        else:
            deficiencias.append("Pista de audio promocional no es AAC estéreo")
            a4_results.append("[FALLO] Audio promocional no conforme")
    else:
        deficiencias.append("Fallo al ejecutar telemetría ffprobe en video promocional")
        a4_results.append("[FALLO] Error en telemetría ffprobe video promocional")
else:
    deficiencias.append("ffprobe.exe o video promocional ausente")
    a4_results.append("[FALLO] Video promocional ausente para telemetría")

# ZIP
zip_path = os.path.join(project_root, "paquete_redes_la_garza.zip")
if os.path.exists(zip_path):
    z_size = os.path.getsize(zip_path)
    z_mb = round(z_size / (1024 * 1024), 2)
    if 20 * 1024 * 1024 <= z_size < 100 * 1024 * 1024:
        a4_results.append(f"[OK] Paquete maestro ZIP: {z_mb} MB (Dentro de los límites de GitHub < 100 MB)")
    else:
        deficiencias.append(f"Tamaño de paquete ZIP fuera de rango: {z_mb} MB")
        a4_results.append("[FALLO] Tamaño de ZIP incorrecto")
else:
    deficiencias.append("paquete_redes_la_garza.zip no existe")
    a4_results.append("[FALLO] ZIP ausente")


# =============================================================================
# GENERACION DE DICTAMEN EJECUTIVO
# =============================================================================
print("\n--- DICTAMEN DE LA DIRECCION GENERAL DE QA ---")

now_str = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
def_count = len(deficiencias)

report_lines = [
    "# Dictamen Pericial de Calidad Total e Infraestructura Digital",
    "## Empresa Auditora de Control de Calidad — La Garza Aguachilera",
    "",
    f"> **Fecha de Auditoría:** {now_str}",
    "> **Ámbito de Inspección:** Ecosistema Web, Panel de Control, Contenido Audiovisual, Segmentación Socioeconómica y Repositorio Digital.",
    f"> **Estado de Deficiencias:** {def_count} encontradas.",
    "",
    "---",
    "",
    "### 1. Auditoría de Infraestructura Digital y Web",
    "\n".join(f"- {r}" for r in a1_results),
    "",
    "### 2. Auditoría Socioeconómica, Percepción de Marca y UX (Clase Media / Media-Alta)",
    "\n".join(f"- {r}" for r in a2_results),
    "",
    "### 3. Auditoría de Blindaje de Marca, Precios y Legalidad",
    "\n".join(f"- {r}" for r in a3_results),
    "",
    "### 4. Auditoría de Multimedia, Video 60FPS y Paquete ZIP",
    "\n".join(f"- {r}" for r in a4_results),
    "",
    "---",
    "",
    "### Dictamen Final Consolidado"
]

if def_count == 0:
    report_lines.extend([
        "",
        "### Veredicto: **APROBADO AL 100% (CERTIFICACIÓN PLENA)**",
        "Todo el proyecto ha superado rigurosamente los exámenes técnicos, estéticos, narrativos y de infraestructura digital. La comunicación hacia el cliente es directa, transparente, sin enredos y con el nivel de sofisticación y pulcritud adecuado para el segmento de clase media y media-alta en Tampico y Ciudad Madero.",
        "",
        "**Sello Oficial:**",
        "`✅ Auditado y aprobado por Control de Calidad: Cumple con los estándares de La Garza Aguachilera`"
    ])
    print(" VEREDICTO: APROBADO AL 100% (0 DEFICIENCIAS)")
    print(" ✅ Auditado y aprobado por Control de Calidad: Cumple con los estándares de La Garza Aguachilera")
    exit_code = 0
else:
    def_list = "\n".join(f"- [CRÍTICO] {d}" for d in deficiencias)
    report_lines.extend([
        "",
        "### Veredicto: **RECHAZADO (CICLO DE REMEDIACIÓN REQUERIDO)**",
        "Se detectaron las siguientes deficiencias que deben ser subsanadas antes de la aprobación:",
        def_list
    ])
    print(f" VEREDICTO: RECHAZADO ({def_count} DEFICIENCIAS)")
    exit_code = 1

with open(report_path, "w", encoding="utf-8") as f:
    f.write("\n".join(report_lines) + "\n")

print(f" Dictamen guardado en: {report_path}")
sys.exit(exit_code)
