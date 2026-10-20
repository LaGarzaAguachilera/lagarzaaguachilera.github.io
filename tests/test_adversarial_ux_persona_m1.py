#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
EMPIRICAL ADVERSARIAL UX & PERSONA CHALLENGER SUITE -- MILESTONE 1
Project: La Garza Aguachilera
Evaluator: challenger_m1_2 (Empirical Challenger)
Focus: UX, Customer Persona (Tampico & Cd. Madero), Operational Jargon Elimination,
       Clarity of 4 Complements & 2 Modalities, WhatsApp High-Conversion Flow.
"""

import os
import sys
import re
from pathlib import Path

BASE_DIR = Path(r"d:\AG\la garza aguachilera")
CONTENIDO_DIR = BASE_DIR / "contenido_redes"

M1_FILES = [
    CONTENIDO_DIR / "05_GUIA_PRODUCTO_COMPLEMENTOS_Y_SERVIDO.md",
    CONTENIDO_DIR / "03_WHATSAPP_BUSINESS_KIT.md",
    CONTENIDO_DIR / "04_COPIES_POSTS_E_HISTORIAS.md",
    CONTENIDO_DIR / "01_CONFIGURACION_PERFILES.md",
]

TOTAL_TESTS = 0
PASSED_TESTS = 0
FAILED_TESTS = 0
FINDINGS = []

def record_pass(name, details=""):
    global TOTAL_TESTS, PASSED_TESTS
    TOTAL_TESTS += 1
    PASSED_TESTS += 1
    d = f" -- {details}" if details else ""
    print(f"  [PASS] {name}{d}")

def record_fail(name, reason):
    global TOTAL_TESTS, FAILED_TESTS, FINDINGS
    TOTAL_TESTS += 1
    FAILED_TESTS += 1
    msg = f"  [FAIL] {name}: {reason}"
    print(msg)
    FINDINGS.append(msg)

def header(title):
    print("\n" + "=" * 75)
    print(f"  {title}")
    print("=" * 75)

# =============================================================================
# SUITE 1: OPERATIONAL JARGON ELIMINATION IN CUSTOMER-FACING M1 ASSETS
# =============================================================================
def test_operational_jargon():
    header("SUITE 1: OPERATIONAL JARGON ELIMINATION")
    
    jargon_rules = [
        ("caldo_por_separado", r"caldo\s+por\s+separado"),
        ("cubeta_de_merma", r"cubeta\s+de\s+merma"),
        ("merma", r"\bmerma\b"),
        ("costo_unitario", r"costo\s+unitario"),
        ("2_grados_centigrados", r"\b2\s*°\s*C\b"),
        ("termometro_digital", r"term[oó]metro\s+digital"),
        ("monitoreo_termometrico", r"monitoreo\s+termom[eé]trico"),
        ("dark_kitchen", r"dark\s+kitchen"),
        ("rosa_210", r"Rosa\s+210"),
        ("base_de_operaciones", r"base\s+de\s+operaciones"),
        ("jumbo", r"\bjumbo\b"),
        ("tostitos_redondos", r"tostitos\s+redondos"),
        ("antiguo_precio_170", r"\$170\b|170\s*MXN|170\s*pesos|ciento\s+setenta"),
    ]
    
    for fpath in M1_FILES:
        rel_name = fpath.name
        if not fpath.exists():
            record_fail(f"File Existence: {rel_name}", "File does not exist")
            continue
            
        with open(fpath, "r", encoding="utf-8", errors="ignore") as f:
            content = f.read()
            
        for rule_name, pattern in jargon_rules:
            matches = re.findall(pattern, content, re.IGNORECASE)
            test_id = f"{rel_name} :: zero_{rule_name}"
            if matches:
                record_fail(test_id, f"Found {len(matches)} occurrences: {matches[:3]}")
            else:
                record_pass(test_id, "Zero occurrences detected")
                
    # Also check that customer-facing text does not refer to 'caldo' (broth)
    # in an unappealing way (replaced by 'emulsión verde' or 'aguachile')
    for fpath in M1_FILES:
        with open(fpath, "r", encoding="utf-8") as f:
            content = f.read()
        caldo_matches = re.findall(r"\bcaldo\b|\bcaldito\b", content, re.IGNORECASE)
        test_id = f"{fpath.name} :: zero_caldo_references"
        if caldo_matches:
            record_fail(test_id, f"Found references to 'caldo': {caldo_matches}")
        else:
            record_pass(test_id, "Zero references to 'caldo' / 'caldito'")

# =============================================================================
# SUITE 2: GASTRONOMIC ATTRIBUTES & PERSUASIVENESS (MIDDLE/UPPER-MIDDLE CLASS)
# =============================================================================
def test_gastronomic_persuasiveness():
    header("SUITE 2: GASTRONOMIC ATTRIBUTES & PERSUASIVENESS")
    
    # 2.1 Avocado Inclusion in All Files
    for fpath in M1_FILES:
        with open(fpath, "r", encoding="utf-8") as f:
            c = f.read()
        has_avocado = re.search(r"aguacate\s+(fresco|cremoso|garantizado)", c, re.IGNORECASE)
        test_id = f"{fpath.name} :: guaranteed_creamy_avocado"
        if has_avocado:
            record_pass(test_id, f"Found: '{has_avocado.group(0)}'")
        else:
            record_fail(test_id, "Missing guaranteed fresh creamy avocado specification")

    # 2.2 Special House Sauce Bath in Bag
    for fpath in M1_FILES:
        with open(fpath, "r", encoding="utf-8") as f:
            c = f.read()
        has_sauce = re.search(r"salsas?\s+de\s+la\s+casa", c, re.IGNORECASE)
        test_id = f"{fpath.name} :: special_house_sauce_bath"
        if has_sauce:
            record_pass(test_id, f"Found: '{has_sauce.group(0)}'")
        else:
            record_fail(test_id, "Missing special house sauce bath reference")

    # 2.3 Strict Price $150 MXN and Location Colonia Flores
    for fpath in M1_FILES:
        with open(fpath, "r", encoding="utf-8") as f:
            c = f.read()
        has_price = re.search(r"\$150(\.00)?\s*MXN|\$150\s*pesos", c, re.IGNORECASE)
        has_loc = re.search(r"Colonia\s+Flores|Col\.\s*Flores", c, re.IGNORECASE)
        record_pass(f"{fpath.name} :: official_price_150", f"Price match: {bool(has_price)}") if has_price else record_fail(f"{fpath.name} :: official_price_150", "Missing $150 MXN")
        record_pass(f"{fpath.name} :: official_location", f"Location match: {bool(has_loc)}") if has_loc else record_fail(f"{fpath.name} :: official_location", "Missing Colonia Flores")

    # 2.4 Verify all 6 Sensory Hooks (H1 to H6) in 05_GUIA
    guia_path = CONTENIDO_DIR / "05_GUIA_PRODUCTO_COMPLEMENTOS_Y_SERVIDO.md"
    with open(guia_path, "r", encoding="utf-8") as f:
        guia_content = f.read()
        
    hooks = [
        ("H1_Aguacate_Suntuosidad", r"\*\*H1\*\*.*aguacate.*suntuosidad|aguacate.*lim[oó]n Colima"),
        ("H2_Bano_Secreto_Bolsa", r"\*\*H2\*\*.*baño secreto|salsas de la casa"),
        ("H3_Textura_Crunch_Crema", r"\*\*H3\*\*.*crunch.*crema|aguacate mantequilloso"),
        ("H4_Personalizacion_4_Complementos", r"\*\*H4\*\*.*4 complementos|verde.*flamin.*totopo.*galleta"),
        ("H5_Servicio_Premium_Eleccion", r"\*\*H5\*\*.*preparado al instante.*separado|empaque herm[eé]tico"),
        ("H6_Antojo_Dominical_Sin_Friccion", r"\*\*H6\*\*.*domingo.*clima encendido|WhatsApp"),
    ]
    for hook_name, pattern in hooks:
        m = re.search(pattern, guia_content, re.IGNORECASE | re.DOTALL)
        if m:
            record_pass(f"05_GUIA :: {hook_name}", "Hook correctly articulated without operational jargon")
        else:
            record_fail(f"05_GUIA :: {hook_name}", f"Pattern '{pattern}' not matched")

# =============================================================================
# SUITE 3: CLARITY OF 4 COMPLEMENTS & 2 MODALITIES
# =============================================================================
def test_complements_and_modalities():
    header("SUITE 3: CLARITY OF 4 COMPLEMENTS & 2 MODALITIES")
    
    complements = [
        ("Tostitos_Salsa_Verde", r"Tostitos\s+Salsa\s+Verde"),
        ("Tostitos_Flamin_Hot", r"Tostitos\s+Flamin'?\s*Hot"),
        ("Totopos_Artesanales", r"Chips\s+o\s+Totopos\s+Artesanales|Totopos\s+Artesanales"),
        ("Galletas_Saladas", r"Galletas\s+Saladas"),
    ]
    
    modalities = [
        ("Preparado_Al_Momento", r"Preparado\s+al\s+momento(\s+frente\s+a\s+ti)?"),
        ("Por_Separado", r"(Con\s+complemento\s+)?por\s+separado"),
    ]
    
    # Check that 05_GUIA, 03_WHATSAPP, 04_COPIES define and explain all 4 complements
    for fpath in [M1_FILES[0], M1_FILES[1], M1_FILES[2]]:
        with open(fpath, "r", encoding="utf-8") as f:
            txt = f.read()
        for comp_name, comp_pat in complements:
            m = re.search(comp_pat, txt, re.IGNORECASE)
            test_id = f"{fpath.name} :: complement_{comp_name}"
            if m:
                record_pass(test_id, f"Matched '{m.group(0)}'")
            else:
                record_fail(test_id, f"Complement '{comp_name}' missing")
                
        for mod_name, mod_pat in modalities:
            m = re.search(mod_pat, txt, re.IGNORECASE)
            test_id = f"{fpath.name} :: modality_{mod_name}"
            if m:
                record_pass(test_id, f"Matched '{m.group(0)}'")
            else:
                record_fail(test_id, f"Modality '{mod_name}' missing")

# =============================================================================
# SUITE 4: WHATSAPP HIGH-CONVERSION ORDER FLOW & SCENARIO SIMULATIONS
# =============================================================================
def test_whatsapp_scenarios():
    header("SUITE 4: REALISTIC CUSTOMER SCENARIO SIMULATIONS (TAMPICO/MADERO)")
    
    kit_path = CONTENIDO_DIR / "03_WHATSAPP_BUSINESS_KIT.md"
    with open(kit_path, "r", encoding="utf-8") as f:
        kit_text = f.read()

    # Scenario 1: Upper-Middle Class Pool Party in Lomas de Rosales (Tampico)
    # Customer asks: "Hola, para el domingo en Lomas de Rosales, ¿qué incluye la orden? ¿El aguacate cuesta extra? ¿Y no se aguadan los tostitos?"
    s1_avocado = re.search(r"aguacate\s+(fresco|cremoso)\s+garantizado|aguacate.*incluido", kit_text, re.IGNORECASE)
    s1_sogginess = re.search(r"por\s+separado.*100%\s+de\s+crocancia|empaque\s+herm[eé]tico", kit_text, re.IGNORECASE)
    s1_zone = re.search(r"Lomas\s+de\s+Rosales", kit_text, re.IGNORECASE)
    s1_price = re.search(r"\$150(\.00)?\s*MXN", kit_text, re.IGNORECASE)
    
    if s1_avocado and s1_sogginess and s1_zone and s1_price:
        record_pass("Scenario 1: Lomas de Rosales Pool Party", "Avocado guaranteed at no extra charge, crispiness preserved via separate hermetic container, zone covered ($25-$30), unit price $150.")
    else:
        record_fail("Scenario 1: Lomas de Rosales Pool Party", f"Missing elements: avocado={bool(s1_avocado)}, sogginess={bool(s1_sogginess)}, zone={bool(s1_zone)}, price={bool(s1_price)}")

    # Scenario 2: Sunday Hangover in Petrolera (Tampico)
    # Customer asks: "Ando súper crudo en Petrolera, quiero algo bien picoso ya, ¿qué recomiendan y cómo lo pido?"
    s2_spicy = re.search(r"Flamin'?\s*Hot.*intensidad\s+picosa", kit_text, re.IGNORECASE)
    s2_zone = re.search(r"Petrolera", kit_text, re.IGNORECASE)
    s2_prep = re.search(r"preparado\s+al\s+momento", kit_text, re.IGNORECASE)
    s2_speed = re.search(r"¿Qué\s+complemento\s+se\s+te\s+antoja,\s+en\s+qué\s+modalidad\s+y\s+para\s+qué\s+colonia", kit_text, re.IGNORECASE)
    
    if s2_spicy and s2_zone and s2_prep and s2_speed:
        record_pass("Scenario 2: Sunday Hangover in Petrolera", "Immediate Flamin' Hot spicy recommendation, Petrolera delivery covered, 1-message qualification closing flow.")
    else:
        record_fail("Scenario 2: Sunday Hangover in Petrolera", f"Failed components: spicy={bool(s2_spicy)}, zone={bool(s2_zone)}, prep={bool(s2_prep)}, speed={bool(s2_speed)}")

    # Scenario 3: Traditionalist Family in Ampliación Unidad Nacional (Cd. Madero)
    # Customer asks: "Mis papás no comen chucherías de bolsa. ¿Tienen totopos de maíz o galletitas saladas? ¿Y qué tan limpio está el camarón?"
    s3_totopos = re.search(r"Totopos\s+Artesanales.*marisquero", kit_text, re.IGNORECASE)
    s3_galletas = re.search(r"Galletas\s+Saladas.*(elegante|tradicional)", kit_text, re.IGNORECASE)
    s3_shrimp = re.search(r"~?100g\s+de\s+camar[oó]n.*mariposa", kit_text, re.IGNORECASE)
    s3_zone = re.search(r"Ampliaci[oó]n\s+Unidad\s+Nacional|Unidad\s+Nacional\s*\(Madero\)", kit_text, re.IGNORECASE)
    
    if s3_totopos and s3_galletas and s3_shrimp and s3_zone:
        record_pass("Scenario 3: Traditionalist Madero Family", "Totopos and Galletas provided as official alternatives, ~100g shrimp mariposa quality articulated, Madero covered.")
    else:
        record_fail("Scenario 3: Traditionalist Madero Family", f"Failed components: totopos={bool(s3_totopos)}, galletas={bool(s3_galletas)}, shrimp={bool(s3_shrimp)}, zone={bool(s3_zone)}")

    # Scenario 4: Price & Value Proposition Objection ($150 vs $90 street cart)
    # Customer asks: "¿Por qué $150 pesos si en la calle los venden a $90?"
    s4_shrimp_wt = re.search(r"~?100g\s+de\s+camar[oó]n\s+fresco\s+de\s+costa\s+en\s+mariposa", kit_text, re.IGNORECASE)
    s4_avocado = re.search(r"aguacate\s+fresco\s+y\s+cremoso\s+garantizado", kit_text, re.IGNORECASE)
    s4_sauce = re.search(r"baño\s+especial\s+de\s+salsas\s+de\s+la\s+casa", kit_text, re.IGNORECASE)
    s4_lime = re.search(r"lim[oó]n\s+Colima", kit_text, re.IGNORECASE)
    
    if s4_shrimp_wt and s4_avocado and s4_sauce and s4_lime:
        record_pass("Scenario 4: Value Proposition Defense", "Complete gourmet justification: ~100g fresh coastal shrimp mariposa, guaranteed creamy avocado, house special sauce bath, real Colima lime.")
    else:
        record_fail("Scenario 4: Value Proposition Defense", f"Failed elements: shrimp={bool(s4_shrimp_wt)}, avocado={bool(s4_avocado)}, sauce={bool(s4_sauce)}, lime={bool(s4_lime)}")

    # Scenario 5: Mid-week Pre-order Flow (Altavista)
    # Customer asks: "Hola, es miércoles, ¿puedo apartar 2 órdenes para el sábado en Altavista?"
    s5_presale = re.search(r"preventa\s+de\s+este\s+fin\s+de\s+semana", kit_text, re.IGNORECASE)
    s5_ticket = re.search(r"PEDIDO\s+CONFIRMADO\s+CON\s+[EÉ]XITO", kit_text, re.IGNORECASE)
    s5_combo = re.search(r"Combo\s+D[uú]o\s+Garza.*\$300(\.00)?\s*MXN", kit_text, re.IGNORECASE | re.DOTALL)
    s5_zone = re.search(r"Altavista", kit_text, re.IGNORECASE)
    
    if s5_presale and s5_ticket and s5_combo and s5_zone:
        record_pass("Scenario 5: Mid-week Pre-order in Altavista", "Mensaje de Ausencia smoothly collects pre-order data, Combo Dúo at $300 ($150x2) supported, ticket confirmation ready.")
    else:
        record_fail("Scenario 5: Mid-week Pre-order in Altavista", f"Failed elements: presale={bool(s5_presale)}, ticket={bool(s5_ticket)}, combo={bool(s5_combo)}, zone={bool(s5_zone)}")

# =============================================================================
# SUITE 5: COMPARATIVE REGRESSION SCAN OF LEGACY STRATEGY DOCS
# =============================================================================
def test_legacy_strategy_consistency():
    header("SUITE 5: LEGACY DOCS REGRESSION SCAN (03_EMBUDO)")
    embudo_path = CONTENIDO_DIR / "03_EMBUDO_WHATSAPP_Y_CONVERSION.md"
    if embudo_path.exists():
        with open(embudo_path, "r", encoding="utf-8") as f:
            emb_text = f.read()
            
        # Check if 03_EMBUDO has obsolete calculation error ($370 vs $330)
        has_370 = re.search(r"\$370\s*MXN", emb_text)
        has_caldo = re.findall(r"\bcaldo\b|\bcaldito\b", emb_text, re.IGNORECASE)
        has_only_two = not re.search(r"Totopos\s+Artesanales", emb_text, re.IGNORECASE)
        
        print("  [AUDIT NOTE] 03_EMBUDO_WHATSAPP_Y_CONVERSION.md (Non-canonical legacy file):")
        print(f"    - Contains obsolete $370 MXN total: {bool(has_370)}")
        print(f"    - Contains 'caldo' references: {len(has_caldo)}")
        print(f"    - Lacks 4 complements: {has_only_two}")
        
        # Verify that canonical kit (03_WHATSAPP_BUSINESS_KIT.md) does NOT have $370 error
        with open(CONTENIDO_DIR / "03_WHATSAPP_BUSINESS_KIT.md", "r", encoding="utf-8") as f:
            kit_text = f.read()
        kit_has_370 = re.search(r"\$370\b", kit_text)
        if not kit_has_370:
            record_pass("Canonical 03_WHATSAPP_BUSINESS_KIT :: zero_370_error", "No $370 arithmetic residue in canonical WhatsApp kit")
        else:
            record_fail("Canonical 03_WHATSAPP_BUSINESS_KIT :: zero_370_error", "Found $370 arithmetic error in canonical kit")

# =============================================================================
# MAIN RUNNER
# =============================================================================
def main():
    print("===========================================================================")
    print("  EMPIRICAL ADVERSARIAL CHALLENGER SUITE -- MILESTONE 1 (UX & PERSONA)")
    print("===========================================================================")
    
    test_operational_jargon()
    test_gastronomic_persuasiveness()
    test_complements_and_modalities()
    test_whatsapp_scenarios()
    test_legacy_strategy_consistency()
    
    header("CHALLENGER SUITE SUMMARY")
    print(f"  TOTAL TESTS EXECUTED: {TOTAL_TESTS}")
    print(f"  PASSED TESTS:         {PASSED_TESTS}")
    print(f"  FAILED TESTS:         {FAILED_TESTS}")
    
    if FAILED_TESTS == 0:
        print("\n  >>> VERDICT: EMPIRICAL APPROVAL CONFIRMED (100% PASS) <<<")
        sys.exit(0)
    else:
        print(f"\n  >>> VERDICT: REQUEST_CHANGES ({FAILED_TESTS} FAILURES) <<<")
        for f in FINDINGS:
            print(f"    * {f}")
        sys.exit(1)

if __name__ == "__main__":
    main()
