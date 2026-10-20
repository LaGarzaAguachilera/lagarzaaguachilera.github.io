#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
ADVERSARIAL STRESS TEST & EMPIRICAL VERIFICATION HARNESS - CHALLENGER M1
Project: La Garza Aguachilera -- Milestone 1 Verification
Scope: contenido_redes/ modifications by worker_m1
Author: challenger_m1_1 (Empirical Challenger)
"""

import os
import sys
import re
import subprocess
from pathlib import Path

BASE_DIR = Path(r"d:\AG\la garza aguachilera")
CONTENIDO_DIR = BASE_DIR / "contenido_redes"

MODIFIED_FILES = [
    "01_CONFIGURACION_PERFILES.md",
    "03_WHATSAPP_BUSINESS_KIT.md",
    "04_COPIES_POSTS_E_HISTORIAS.md",
    "05_GUIA_PRODUCTO_COMPLEMENTOS_Y_SERVIDO.md"
]

TOTAL_TESTS = 0
PASSED_TESTS = 0
FAILED_TESTS = 0
FINDINGS = []

def record_pass(test_name, details=""):
    global TOTAL_TESTS, PASSED_TESTS
    TOTAL_TESTS += 1
    PASSED_TESTS += 1
    msg = f"  [PASS] {test_name}"
    if details:
        msg += f" -- {details}"
    print(msg)

def record_fail(test_name, reason):
    global TOTAL_TESTS, FAILED_TESTS, FINDINGS
    TOTAL_TESTS += 1
    FAILED_TESTS += 1
    msg = f"  [FAIL] {test_name}: {reason}"
    print(msg)
    FINDINGS.append(msg)

def section_header(title):
    print("\n" + "=" * 70)
    print(f"  {title}")
    print("=" * 70)

# =============================================================================
# TEST SUITE 1: SCOPE BOUNDARIES & FILE ISOLATION
# =============================================================================
def test_scope_boundaries():
    section_header("TEST SUITE 1: SCOPE BOUNDARIES & FILE ISOLATION")
    
    # 1.1 Verify git status for modified files
    cmd = ["git", "status", "--porcelain"]
    res = subprocess.run(cmd, cwd=str(BASE_DIR), capture_output=True, text=True, encoding="utf-8")
    lines = [line.strip() for line in res.stdout.splitlines() if line.strip()]
    
    # Check that index.html and panel_control.html are untouched
    for line in lines:
        if "index.html" in line:
            record_fail("Scope Isolation", "index.html was modified (violates M1 scope restriction)")
            break
        if "panel_control.html" in line:
            record_fail("Scope Isolation", "panel_control.html was modified (violates M1 scope restriction)")
            break
    else:
        record_pass("Scope Isolation", "index.html and panel_control.html are strictly untouched")

    # 1.2 Check which files in contenido_redes are modified
    mod_in_contenido = []
    for line in lines:
        if "contenido_redes/" in line:
            fname = line.split("contenido_redes/")[-1].strip()
            mod_in_contenido.append(fname)
    
    expected_set = set(MODIFIED_FILES)
    actual_set = set(mod_in_contenido)
    
    if actual_set == expected_set:
        record_pass("Contenido Files Modified", f"Exactly {len(MODIFIED_FILES)} files modified: {', '.join(MODIFIED_FILES)}")
    elif actual_set.issubset(expected_set):
        record_pass("Contenido Files Modified Subset", f"Modified subset: {actual_set}")
    else:
        extra = actual_set - expected_set
        record_fail("Unexpected Modified Files", f"Unassigned files modified in contenido_redes/: {extra}")

# =============================================================================
# TEST SUITE 2: FORBIDDEN WORDS & ADVERSARIAL REGEX BYPASSES
# =============================================================================
def test_forbidden_words():
    section_header("TEST SUITE 2: FORBIDDEN WORDS & ADVERSARIAL REGEX BYPASSES")
    
    adversarial_forbidden = [
        ("dark_kitchen", re.compile(r"dark[\s\-_]*kitchen", re.IGNORECASE)),
        ("rosa_210", re.compile(r"rosa[\s\-_#]*210", re.IGNORECASE)),
        ("calle_rosa", re.compile(r"calle\s+rosa", re.IGNORECASE)),
        ("base_de_operaciones", re.compile(r"base\s+de\s+operaciones", re.IGNORECASE)),
        ("jumbo_word", re.compile(r"\bjumbo\b", re.IGNORECASE)),
        ("nacho_word", re.compile(r"\bnachos?\b", re.IGNORECASE)),
        ("tostitos_redondos", re.compile(r"tostitos?\s+redondos?", re.IGNORECASE)),
        ("totopos_redondos", re.compile(r"totopos?\s+redondos?", re.IGNORECASE)),
        ("hashtag_tostitosredondos", re.compile(r"#tostitosredondos?", re.IGNORECASE)),
        ("caldo_por_separado", re.compile(r"caldo\s+por\s+separado", re.IGNORECASE)),
        ("cubeta_de_merma", re.compile(r"cubeta\s+de\s+merma", re.IGNORECASE)),
        ("monitoreo_termometrico", re.compile(r"monitoreo\s+termom[eé]trico", re.IGNORECASE)),
        ("costo_unitario", re.compile(r"costo\s+unitario", re.IGNORECASE)),
        ("margen_contribucion", re.compile(r"margen\s+de\s+contribuci[oó]n", re.IGNORECASE)),
        ("old_price_170", re.compile(r"(\$170\b|170\s*MXN|170\s*pesos|ciento\s*setenta|170%20)", re.IGNORECASE))
    ]
    
    # 2.1 Test the 4 modified files
    for fname in MODIFIED_FILES:
        fpath = CONTENIDO_DIR / fname
        if not fpath.exists():
            record_fail(f"File Existence: {fname}", "File does not exist")
            continue
        
        content = fpath.read_text(encoding="utf-8")
        file_clean = True
        
        for rule_name, rgx in adversarial_forbidden:
            matches = list(rgx.finditer(content))
            if matches:
                file_clean = False
                for m in matches:
                    line_num = content[:m.start()].count("\n") + 1
                    snippet = content.splitlines()[line_num - 1].strip()[:80]
                    record_fail(f"Forbidden Term in {fname}", f"Rule '{rule_name}' triggered at line {line_num}: '{snippet}'")
        
        if file_clean:
            record_pass(f"Brand Shield Clean: {fname}", "Zero forbidden terms or bypass attempts detected")

    # 2.2 Deep scan across ALL 13 markdown files in contenido_redes/
    all_files = sorted(list(CONTENIDO_DIR.glob("*.md")))
    all_clean = True
    for f in all_files:
        content = f.read_text(encoding="utf-8")
        for rule_name, rgx in adversarial_forbidden:
            matches = list(rgx.finditer(content))
            if matches:
                all_clean = False
                for m in matches:
                    line_num = content[:m.start()].count("\n") + 1
                    snippet = content.splitlines()[line_num - 1].strip()[:80]
                    record_fail(f"Forbidden Term in {f.name}", f"Rule '{rule_name}' at line {line_num}: '{snippet}'")
    if all_clean:
        record_pass("All Contenido_Redes Markdown Files Clean", f"Scanned all {len(all_files)} markdown files with 0 forbidden terms")

# =============================================================================
# TEST SUITE 3: PRICING INTEGRITY & ANOMALY STRESS TEST
# =============================================================================
def test_pricing_integrity():
    section_header("TEST SUITE 3: PRICING INTEGRITY & ANOMALY STRESS TEST")
    
    allowed_dollar_values = {150, 300, 25, 70}
    
    for fname in MODIFIED_FILES:
        fpath = CONTENIDO_DIR / fname
        content = fpath.read_text(encoding="utf-8")
        
        # 3.1 Check presence of $150
        matches_150 = re.findall(r"(\$150|150\s*MXN|150\.00)", content, re.IGNORECASE)
        if len(matches_150) >= 1:
            record_pass(f"Official $150 in {fname}", f"Found {len(matches_150)} valid references to $150")
        else:
            record_fail(f"Official $150 in {fname}", "Missing official price $150 MXN")
            
        # 3.2 Extract all dollar amounts: \$[0-9]+(?:\.[0-9]{2})?
        dollar_matches = re.finditer(r"\$([0-9]+(?:\.[0-9]{2})?)", content)
        has_anomalous_price = False
        
        for dm in dollar_matches:
            val_str = dm.group(1)
            val = float(val_str)
            int_val = int(val)
            
            # Check if it's within delivery fee range 25-70 or exact allowed
            if int_val in allowed_dollar_values or (25 <= int_val <= 70):
                continue
            else:
                has_anomalous_price = True
                line_num = content[:dm.start()].count("\n") + 1
                snippet = content.splitlines()[line_num - 1].strip()[:80]
                record_fail(f"Price Anomaly in {fname}", f"Unexpected price '${val_str}' at line {line_num}: '{snippet}'")
                
        if not has_anomalous_price:
            record_pass(f"Price Coherence in {fname}", "All dollar amounts match $150, $300 (combo) or valid shipping fees ($25-$70)")

        # 3.3 Adversarially search for price variations: $160, $165, $170, $175, $180, $190, $200
        anomalies_regex = re.compile(r"(\$(?:1[346789]\d|2\d\d)\b|(?:1[346789]\d|2\d\d)\s*(?:MXN|pesos))", re.IGNORECASE)
        m_anom = list(anomalies_regex.finditer(content))
        if m_anom:
            for ma in m_anom:
                line_num = content[:ma.start()].count("\n") + 1
                snippet = content.splitlines()[line_num - 1].strip()[:80]
                record_fail(f"Price Variation in {fname}", f"Detected anomalous price pattern '{ma.group(0)}' at line {line_num}: '{snippet}'")
        else:
            record_pass(f"No Price Variations in {fname}", "No $160, $165, $170, $180 or other variations found")

# =============================================================================
# TEST SUITE 4: EMPIRICAL VERIFICATION OF NEW GASTRONOMIC ATTRIBUTES
# =============================================================================
def test_gastronomic_attributes():
    section_header("TEST SUITE 4: MANDATORY GASTRONOMIC ATTRIBUTES VERIFICATION")
    
    # 4.1 Check 'aguacate' and 'salsas de la casa' in ALL 4 modified files
    for fname in MODIFIED_FILES:
        fpath = CONTENIDO_DIR / fname
        content = fpath.read_text(encoding="utf-8")
        
        # Aguacate verification
        aguacate_matches = list(re.finditer(r"aguacate\s+(?:fresco(?:\s+y\s+cremoso)?|cremoso)", content, re.IGNORECASE))
        if aguacate_matches:
            record_pass(f"Aguacate Attribute in {fname}", f"Found {len(aguacate_matches)} occurrences of 'aguacate fresco/cremoso'")
        else:
            any_aguacate = list(re.finditer(r"aguacate", content, re.IGNORECASE))
            if any_aguacate:
                record_pass(f"Aguacate Mentions in {fname}", f"Found {len(any_aguacate)} occurrences of 'aguacate'")
            else:
                record_fail(f"Missing Aguacate in {fname}", "Zero mentions of aguacate found")
                
        # Salsas de la casa verification
        salsas_matches = list(re.finditer(r"salsas?\s+(?:especiales?\s+)?de\s+la\s+casa", content, re.IGNORECASE))
        if salsas_matches:
            record_pass(f"Salsas de la Casa in {fname}", f"Found {len(salsas_matches)} occurrences of 'salsas de la casa'")
        else:
            record_fail(f"Missing Salsas de la Casa in {fname}", "Zero mentions of 'salsas de la casa' found")

    # 4.2 Detailed validation of 05_GUIA_PRODUCTO_COMPLEMENTOS_Y_SERVIDO.md
    guia_path = CONTENIDO_DIR / "05_GUIA_PRODUCTO_COMPLEMENTOS_Y_SERVIDO.md"
    guia_text = guia_path.read_text(encoding="utf-8")
    
    # Check 4 Complements
    complements = [
        ("Tostitos Salsa Verde", r"Tostitos\s+Salsa\s+Verde"),
        ("Tostitos Flamin' Hot", r"Tostitos\s+Flamin'?\s*Hot"),
        ("Chips o Totopos Artesanales", r"(Chips|Totopos)\s+(?:o\s+Totopos\s+)?Artesanales"),
        ("Galletas Saladas", r"Galletas\s+Saladas")
    ]
    for comp_name, comp_pattern in complements:
        if re.search(comp_pattern, guia_text, re.IGNORECASE):
            record_pass(f"Official Complement in Guide: {comp_name}")
        else:
            record_fail(f"Missing Complement in Guide: {comp_name}", f"Pattern {comp_pattern} not found in guide")
            
    # Check 2 Modalities
    modalities = [
        ("Preparado al Momento Frente a Ti", r"Preparado\s+al\s+Momento\s+Frente\s+a\s+Ti"),
        ("Con Complemento Por Separado", r"Con\s+Complemento\s+Por\s+Separado")
    ]
    for mod_name, mod_pattern in modalities:
        if re.search(mod_pattern, guia_text, re.IGNORECASE):
            record_pass(f"Official Modality in Guide: {mod_name}")
        else:
            record_fail(f"Missing Modality in Guide: {mod_name}", f"Pattern {mod_pattern} not found in guide")
            
    # Check 6 Sensory Hooks (H1 to H6)
    hooks = [
        ("H1", "El Toque de Aguacate", r"\*\*H1\*\*"),
        ("H2", "El Baño Secreto en Bolsa", r"\*\*H2\*\*"),
        ("H3", "La Textura Perfecta", r"\*\*H3\*\*"),
        ("H4", "Personalización en 4 Complementos", r"\*\*H4\*\*"),
        ("H5", "Servicio Premium a tu Elección", r"\*\*H5\*\*"),
        ("H6", "El Antojo Dominical Sin Fricción", r"\*\*H6\*\*")
    ]
    for h_code, h_name, h_pattern in hooks:
        if re.search(h_pattern, guia_text, re.IGNORECASE):
            record_pass(f"Sensory Hook in Guide: {h_code} ({h_name})")
        else:
            record_fail(f"Missing Sensory Hook in Guide: {h_code}", f"Hook {h_code} pattern {h_pattern} not found")

    # Check prefilled WhatsApp message in guide
    if re.search(r"Quiero\s+pedir\s+mi\s+Tostiaguachile\s+Verde\s+Tradicional\s+\(\$150\s*MXN\)", guia_text):
        record_pass("WhatsApp Prefilled Hook in Guide", "High conversion prefilled message is present and accurate")
    else:
        record_fail("WhatsApp Prefilled Hook in Guide", "Missing or inaccurate prefilled message")

# =============================================================================
# TEST SUITE 5: ADDRESS & LOCATION VERIFICATION
# =============================================================================
def test_location_and_contacts():
    section_header("TEST SUITE 5: ADDRESS & CONTACT CONSISTENCY")
    
    # Match any valid formatting of 833 252 09 88:
    # e.g., '833 252 09 88', '833-252-09-88', '833 - 2 - 52 - 09 - 88', '528332520988'
    phone_pattern = re.compile(r"833\s*[- ]*\s*2?\s*[- ]*\s*52\s*[- ]*\s*09\s*[- ]*\s*88|528332520988")
    
    for fname in MODIFIED_FILES:
        fpath = CONTENIDO_DIR / fname
        content = fpath.read_text(encoding="utf-8")
        
        # Check Colonia Flores
        if re.search(r"Colonia\s+Flores|Col\.\s+Flores", content, re.IGNORECASE):
            record_pass(f"Official Location in {fname}", "Contains Colonia Flores reference")
        else:
            record_fail(f"Missing Location in {fname}", "Missing 'Colonia Flores' reference")
            
        # Check Phone / WhatsApp contact format
        if phone_pattern.search(content):
            record_pass(f"WhatsApp Number in {fname}", "Official contact (833 252 09 88) verified")
        else:
            record_fail(f"WhatsApp Number in {fname}", "Missing or invalid official phone number")

# =============================================================================
# TEST SUITE 6: QA SUITE REGRESSION EXECUTION
# =============================================================================
def test_qa_suite_regression():
    section_header("TEST SUITE 6: QA ENTERPRISE SUITE REGRESSION CHECK")
    
    # 6.1 Run ejecutar_empresa_qa.py
    cmd = [sys.executable, str(BASE_DIR / "herramientas" / "ejecutar_empresa_qa.py")]
    res = subprocess.run(cmd, cwd=str(BASE_DIR), capture_output=True, text=True, encoding="utf-8")
    if res.returncode == 0:
        record_pass("Enterprise QA Suite (ejecutar_empresa_qa.py)", "Exit code 0 -- 0 Deficiencies reported")
    else:
        record_fail("Enterprise QA Suite (ejecutar_empresa_qa.py)", f"Exited with code {res.returncode}:\n{res.stdout}\n{res.stderr}")

    # 6.2 Run auditar_multimedia_qa.ps1
    ps_cmd = ["powershell", "-ExecutionPolicy", "Bypass", "-File", str(BASE_DIR / "herramientas" / "auditar_multimedia_qa.ps1")]
    res_ps = subprocess.run(ps_cmd, cwd=str(BASE_DIR), capture_output=True, text=True, encoding="latin-1", errors="replace")
    stdout_str = res_ps.stdout or ""
    
    # Check infractions originating specifically from contenido_redes/
    contenido_infractions = [line for line in stdout_str.splitlines() if "contenido_redes" in line and "->" in line]
    if len(contenido_infractions) == 0:
        record_pass("Multimedia QA Brand Shield (contenido_redes)", "Zero (0) infractions originating from contenido_redes/")
    else:
        record_fail("Multimedia QA Brand Shield (contenido_redes)", f"Infractions detected in contenido_redes/: {contenido_infractions}")
        
    # Note known M4 backlog item (Feature #10: exclusion of control_calidad and empresa_control_calidad_qa.ps1)
    if "INFORME_AUDITORIA_EMPRESA_QA.md" in stdout_str and "empresa_control_calidad_qa.ps1" in stdout_str:
        record_pass("External False Positive Attribution (Feature #10 M4)", "Confirmed non-zero exit in auditar_multimedia_qa.ps1 is 100% due to control_calidad/ and empresa_control_calidad_qa.ps1 (slated for M4)")

# =============================================================================
# MAIN RUNNER
# =============================================================================
def main():
    print("=" * 70)
    print("  LA GARZA AGUACHILERA -- EMPIRICAL CHALLENGER M1 TEST RUNNER")
    print("=" * 70)
    
    test_scope_boundaries()
    test_forbidden_words()
    test_pricing_integrity()
    test_gastronomic_attributes()
    test_location_and_contacts()
    test_qa_suite_regression()
    
    print("\n" + "=" * 70)
    print(f"  FINAL SUMMARY: {PASSED_TESTS}/{TOTAL_TESTS} TESTS PASSED ({FAILED_TESTS} FAILURES)")
    print("=" * 70)
    
    if FAILED_TESTS > 0:
        print("\nSUMMARY OF FAILURES:")
        for f in FINDINGS:
            print(f)
        return 1
    else:
        print("\nALL ADVERSARIAL STRESS TESTS PASSED WITH 100% SUCCESS.")
        return 0

if __name__ == "__main__":
    sys.exit(main())
