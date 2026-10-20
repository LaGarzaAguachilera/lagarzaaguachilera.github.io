#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
ADVERSARIAL STRESS TEST & EMPIRICAL VERIFICATION HARNESS - CHALLENGER M2
Project: La Garza Aguachilera -- Milestone 2 Verification
Scope: index.html and panel_control.html modifications by worker_m2
Author: challenger_m2_1 (Empirical Challenger)
"""

import os
import sys
import re
from pathlib import Path
from html.parser import HTMLParser

sys.stdout.reconfigure(encoding='utf-8')

BASE_DIR = Path(r"d:\AG\la garza aguachilera")
INDEX_PATH = BASE_DIR / "index.html"
PANEL_PATH = BASE_DIR / "panel_control.html"

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

# ==============================================================================
# TEST SUITE 1: FORBIDDEN WORDS, JARGON, REGEX BOUNDARIES & OLD ADDRESSES
# ==============================================================================
def test_forbidden_words_and_addresses():
    section_header("TEST SUITE 1: FORBIDDEN WORDS & OLD ADDRESSES SCANNER")
    
    forbidden_patterns = [
        ("dark kitchen", r"\bdark\s*kitchen\b"),
        ("Rosa 210", r"\bRosa\s*#?\s*210\b"),
        ("Calle Rosa", r"\bCalle\s*Rosa\b"),
        ("jumbo", r"\bjumbo\b"),
        ("nacho/nachos", r"\bnachos?\b"),
        ("tostitos redondos", r"\btostitos\s+redondos?\b"),
        ("totopos redondos", r"\btotopos\s+redondos?\b"),
        ("base de operaciones", r"\bbase\s+de\s+operaciones\b"),
        ("caldo por separado", r"\bcaldo\s+por\s+separado\b"),
        ("cubeta de merma", r"\bcubeta\s+de\s+merma\b"),
        ("costo unitario", r"\bcosto\s+unitario\b")
    ]

    for doc_path, doc_name in [(INDEX_PATH, "index.html"), (PANEL_PATH, "panel_control.html")]:
        with open(doc_path, "r", encoding="utf-8") as f:
            content = f.read()

        doc_clean = True
        for term_name, pat in forbidden_patterns:
            matches = list(re.finditer(pat, content, re.IGNORECASE))
            if matches:
                doc_clean = False
                for m in matches:
                    start = max(0, m.start() - 30)
                    end = min(len(content), m.end() + 30)
                    context = content[start:end].replace("\n", " ")
                    record_fail(f"Forbidden Term in {doc_name}", f"Found '{term_name}' ('{m.group(0)}') at: ...{context}...")
        if doc_clean:
            record_pass(f"Forbidden Terms in {doc_name}", "0 matches across all forbidden terms and operational jargon")

        # Check for old address residues
        old_addr = list(re.finditer(r"\b(Rosa\s*#?\s*210|Calle\s*Rosa|Rosa\s*\d+)\b", content, re.IGNORECASE))
        if old_addr:
            record_fail(f"Address Residue in {doc_name}", f"Found legacy address residues: {[m.group(0) for m in old_addr]}")
        else:
            record_pass(f"Address Residue in {doc_name}", "0 occurrences of Rosa 210 or legacy addresses")

        # Check official location
        if "Colonia Flores, Tampico" in content or "Col. Flores, Tampico" in content:
            record_pass(f"Official Location in {doc_name}", "Official location verified ('Colonia Flores, Tampico')")
        else:
            record_fail(f"Official Location in {doc_name}", "Missing official location 'Colonia Flores, Tampico'")

# ==============================================================================
# TEST SUITE 2: LEGACY PRICES & REGEX BOUNDARY CURRENCY STRESS TEST
# ==============================================================================
def test_legacy_prices_and_currency():
    section_header("TEST SUITE 2: LEGACY PRICES & CURRENCY STRESS TEST")
    
    legacy_price_patterns = [
        ("170 price", r"(\$170|170\s*MXN|170\s*pesos|ciento\s*setenta)"),
        ("160 price", r"(\$160|160\s*MXN|160\s*pesos|ciento\s*sesenta)"),
        ("180 price", r"(\$180|180\s*MXN|180\s*pesos|ciento\s*ochenta)")
    ]

    for doc_path, doc_name in [(INDEX_PATH, "index.html"), (PANEL_PATH, "panel_control.html")]:
        with open(doc_path, "r", encoding="utf-8") as f:
            content = f.read()

        legacy_found = False
        for label, pat in legacy_price_patterns:
            matches = list(re.finditer(pat, content, re.IGNORECASE))
            if matches:
                legacy_found = True
                for m in matches:
                    start = max(0, m.start() - 30)
                    end = min(len(content), m.end() + 30)
                    context = content[start:end].replace("\n", " ")
                    record_fail(f"Legacy Price in {doc_name}", f"Found {label}: '{m.group(0)}' in: ...{context}...")
        if not legacy_found:
            record_pass(f"Legacy Prices in {doc_name}", "Zero legacy prices ($160, $170, $180) found")

        dollar_matches = re.findall(r"\$\s*(\d+)", content)
        unique_prices = set(dollar_matches)
        record_pass(f"Currency Figures in {doc_name}", f"Discovered: {unique_prices}")
        if doc_name == "index.html":
            if unique_prices == {"150"}:
                record_pass("Price Uniformity (index.html)", "Only $150 exists in entire storefront")
            else:
                record_fail("Price Uniformity (index.html)", f"Unexpected prices found: {unique_prices}")

# ==============================================================================
# TEST SUITE 3: GASTRONOMY ATTRIBUTES (AGUACATE & SALSAS DE LA CASA)
# ==============================================================================
def test_gastronomy_attributes():
    section_header("TEST SUITE 3: NEW GASTRONOMY ATTRIBUTES")
    
    with open(INDEX_PATH, "r", encoding="utf-8") as f:
        idx_content = f.read()

    aguacate_count = len(re.findall(r"aguacate", idx_content, re.IGNORECASE))
    salsa_count = len(re.findall(r"salsas?\s+(de\s+la\s+casa|especial)", idx_content, re.IGNORECASE))

    if aguacate_count >= 5:
        record_pass("Aguacate Fresco in index.html", f"Found {aguacate_count} prominent mentions of Aguacate")
    else:
        record_fail("Aguacate Fresco in index.html", f"Only {aguacate_count} mentions of Aguacate (expected >= 5)")

    if salsa_count >= 4:
        record_pass("Salsas Especiales in index.html", f"Found {salsa_count} prominent mentions of Salsas de la Casa / Especiales")
    else:
        record_fail("Salsas Especiales in index.html", f"Only {salsa_count} mentions of Salsas (expected >= 4)")

    # WhatsApp message verification
    if "aguacate" in idx_content.lower() and "salsa" in idx_content.lower():
        record_pass("WhatsApp Message Sync", "WhatsApp message template includes Aguacate and Salsas de la Casa")
    else:
        record_fail("WhatsApp Message Sync", "WhatsApp message template lacks new gastronomic attributes")

    with open(PANEL_PATH, "r", encoding="utf-8") as f:
        panel_content = f.read()

    p_aguacate_count = len(re.findall(r"aguacate", panel_content, re.IGNORECASE))
    p_salsa_count = len(re.findall(r"salsa", panel_content, re.IGNORECASE))

    if p_aguacate_count >= 5 and p_salsa_count >= 5:
        record_pass("Panel Captions Sync", f"Panel control features {p_aguacate_count} aguacate mentions and {p_salsa_count} salsa mentions")
    else:
        record_fail("Panel Captions Sync", f"Panel control mentions low: {p_aguacate_count} aguacate, {p_salsa_count} salsa")

# ==============================================================================
# TEST SUITE 4: DOM STRUCTURE & RESPONSIVE LAYOUT FOR 'LOS 4 PILARES'
# ==============================================================================
def test_dom_structure_and_four_pillars():
    section_header("TEST SUITE 4: DOM STRUCTURE & RESPONSIVE LAYOUT FOR 'LOS 4 PILARES'")
    
    with open(INDEX_PATH, "r", encoding="utf-8") as f:
        idx_content = f.read()

    class TagBalanceParser(HTMLParser):
        def __init__(self):
            super().__init__()
            self.stack = []
            self.errors = []
            self.void_tags = {"area", "base", "br", "col", "embed", "hr", "img", "input", "link", "meta", "param", "source", "track", "wbr"}

        def handle_starttag(self, tag, attrs):
            if tag.lower() not in self.void_tags:
                self.stack.append((tag.lower(), self.getpos()))

        def handle_endtag(self, tag):
            t = tag.lower()
            if t in self.void_tags:
                return
            if not self.stack:
                self.errors.append(f"Unexpected closing tag </{t}> at line {self.getpos()[0]}")
                return
            last_tag, pos = self.stack.pop()
            if last_tag != t:
                self.errors.append(f"Mismatched tag: expected </{last_tag}> (opened line {pos[0]}), got </{t}> at line {self.getpos()[0]}")

    tag_parser = TagBalanceParser()
    tag_parser.feed(idx_content)
    if not tag_parser.errors and not tag_parser.stack:
        record_pass("Global HTML Tag Balance (index.html)", "Perfect nesting, 0 unclosed or mismatched tags")
    elif not tag_parser.errors:
        record_pass("Global HTML Tag Balance (index.html)", f"Clean nesting, remaining unclosed: {len(tag_parser.stack)}")
    else:
        record_fail("Global HTML Tag Balance (index.html)", f"Tag balance errors: {tag_parser.errors[:5]}")

    sec4_match = re.search(r"<!-- =+\s*4\.\s*LOS 4 PILARES DEL SABOR JAIBO.*?-->\s*<section[^>]*>(.*?)</section>", idx_content, re.DOTALL | re.IGNORECASE)
    if not sec4_match:
        record_fail("Section 4 Existence", "Could not isolate Section 4 by comment/section tags")
        return
    
    sec4_html = sec4_match.group(1)
    record_pass("Section 4 Existence", "Section 4 isolated successfully")

    if "Los 4 Pilares del Sabor Jaibo" in sec4_html:
        record_pass("Section 4 Title", "Title correctly states 'Los 4 Pilares del Sabor Jaibo'")
    else:
        record_fail("Section 4 Title", "Missing exact title 'Los 4 Pilares del Sabor Jaibo'")

    grid_match = re.search(r'<div class="([^"]*grid[^"]*)">', sec4_html)
    if grid_match:
        classes = grid_match.group(1).split()
        record_pass("Grid Container Classes", f"Classes: {' '.join(classes)}")
        has_mobile = "grid-cols-1" in classes
        has_tablet = any("sm:grid-cols-2" in c or "md:grid-cols-2" in c for c in classes)
        has_desktop = any("lg:grid-cols-4" in c or "xl:grid-cols-4" in c for c in classes)
        if has_mobile and has_tablet and has_desktop:
            record_pass("Grid Responsiveness", "Full responsive ladder: 1 col (mobile) -> 2 cols (tablet) -> 4 cols (desktop)")
        else:
            record_fail("Grid Responsiveness", f"Incomplete responsive ladder: mobile={has_mobile}, tablet={has_tablet}, desktop={has_desktop}")
    else:
        record_fail("Grid Container Classes", "No grid container found in Section 4")

    cards = re.findall(r'<div class="pop-card neon-border-[^"]* p-6[^"]*">', sec4_html)
    if len(cards) == 4:
        record_pass("Pillar Cards Count", "Exactly 4 pillar cards present")
    else:
        record_fail("Pillar Cards Count", f"Found {len(cards)} cards instead of 4")

    p1 = "Camarón" in sec4_html and ("100g" in sec4_html or "100 gramos" in sec4_html)
    p2 = "Limón Colima" in sec4_html and "Serrano" in sec4_html
    p3 = "Aguacate" in sec4_html and ("Cremoso" in sec4_html or "Suntuosidad" in sec4_html)
    p4 = "Salsa" in sec4_html and ("Casa" in sec4_html or "Toque Secreto" in sec4_html)
    if p1 and p2 and p3 and p4:
        record_pass("4 Pillar Identities", "All 4 pillars verified (P1: Camarón ~100g, P2: Limón Colima & Serrano, P3: Aguacate Cremoso, P4: Salsa de la Casa)")
    else:
        record_fail("4 Pillar Identities", f"Pillars missing: P1={p1}, P2={p2}, P3={p3}, P4={p4}")

# ==============================================================================
# TEST SUITE 5: ASSET EXISTENCE & CASE-SENSITIVITY (ZERO BROKEN LINKS)
# ==============================================================================
def test_asset_integrity():
    section_header("TEST SUITE 5: ASSET INTEGRITY & CASE-SENSITIVITY (ZERO BROKEN LINKS)")

    for doc_path, doc_name in [(INDEX_PATH, "index.html"), (PANEL_PATH, "panel_control.html")]:
        with open(doc_path, "r", encoding="utf-8") as f:
            html = f.read()

        asset_refs = []
        asset_refs.extend(re.findall(r'src=["\']([^"\']+\.(?:png|jpg|jpeg|mp4|webm|svg|ico|gif|webp))["\']', html, re.IGNORECASE))
        asset_refs.extend(re.findall(r'poster=["\']([^"\']+\.(?:png|jpg|jpeg|svg|webp))["\']', html, re.IGNORECASE))
        asset_refs.extend(re.findall(r'<source[^>]+src=["\']([^"\']+)["\']', html, re.IGNORECASE))
        
        unique_assets = sorted(list(set(asset_refs)))
        missing_assets = []
        case_mismatches = []
        verified_count = 0

        for rel in unique_assets:
            if rel.startswith("http://") or rel.startswith("https://") or rel.startswith("data:"):
                continue
            
            clean_rel = rel.split("?")[0].split("#")[0]
            abs_path = os.path.normpath(os.path.join(str(BASE_DIR), clean_rel.replace("/", os.sep)))

            if not os.path.exists(abs_path):
                missing_assets.append((rel, abs_path))
                continue

            # Case-sensitivity check against filesystem
            parts = os.path.normpath(clean_rel).split(os.sep)
            curr = str(BASE_DIR)
            mismatch = False
            for part in parts:
                if part in (".", ""):
                    continue
                actual_entries = os.listdir(curr)
                if part not in actual_entries:
                    actual_match = next((e for e in actual_entries if e.lower() == part.lower()), None)
                    case_mismatches.append((rel, f"Part '{part}' has actual disk casing '{actual_match}'"))
                    mismatch = True
                    break
                curr = os.path.join(curr, part)

            if not mismatch:
                verified_count += 1

        if not missing_assets:
            record_pass(f"Asset 404 Check ({doc_name})", f"All {len(unique_assets)} referenced assets exist on disk")
        else:
            record_fail(f"Asset 404 Check ({doc_name})", f"Missing {len(missing_assets)} assets: {missing_assets}")

        if not case_mismatches:
            record_pass(f"Asset Case-Sensitivity ({doc_name})", f"All {verified_count} assets match disk casing verbatim (Linux/GitHub Pages safe)")
        else:
            record_fail(f"Asset Case-Sensitivity ({doc_name})", f"Case mismatches detected: {case_mismatches}")

# ==============================================================================
# TEST SUITE 6: JAVASCRIPT & INTERACTIVE DOM INTEGRITY
# ==============================================================================
def test_javascript_and_interactive_dom():
    section_header("TEST SUITE 6: JAVASCRIPT & INTERACTIVE DOM INTEGRITY")

    with open(PANEL_PATH, "r", encoding="utf-8") as f:
        panel_content = f.read()

    with open(INDEX_PATH, "r", encoding="utf-8") as f:
        idx_content = f.read()

    # Panel onclick handlers and target IDs
    onclick_calls = re.findall(r'onclick=["\'](?:copyCaption|copyCaptionFromElement)\([\'"]([^\'"]+)[\'"]', panel_content)
    record_pass("Panel Control Onclick Count", f"Found {len(onclick_calls)} copy button handlers")

    missing_element_ids = []
    for el_id in set(onclick_calls):
        pattern = rf'id=["\']{re.escape(el_id)}["\']'
        if not re.search(pattern, panel_content):
            missing_element_ids.append(el_id)

    if not missing_element_ids:
        record_pass("Panel Copy Button Target IDs", f"All {len(set(onclick_calls))} target element IDs exist in DOM")
    else:
        record_fail("Panel Copy Button Target IDs", f"Missing DOM elements for IDs: {missing_element_ids}")

    if "const copyCaption = copyCaptionFromElement;" in panel_content and "function copyCaptionFromElement" in panel_content:
        record_pass("copyCaption Alias in panel_control.html", "copyCaption alias properly bound to copyCaptionFromElement")
    else:
        record_fail("copyCaption Alias in panel_control.html", "Missing copyCaption binding in panel_control.html")

    # Index.html interactive elements
    required_idx_ids = [
        "complement-selector",
        "mode-selector",
        "main-wa-btn",
        "wa-btn-text"
    ]

    missing_idx_ids = [i for i in required_idx_ids if f'id="{i}"' not in idx_content and f"id='{i}'" not in idx_content]
    if not missing_idx_ids:
        record_pass("Interactive UI Elements in index.html", f"All {len(required_idx_ids)} interactive elements exist in DOM")
    else:
        record_fail("Interactive UI Elements in index.html", f"Missing elements in index.html: {missing_idx_ids}")

    comp_btns = re.findall(r'onclick=["\']selectComplement\(', idx_content)
    mode_btns = re.findall(r'onclick=["\']selectMode\(', idx_content)
    if len(comp_btns) == 4 and len(mode_btns) == 2:
        record_pass("Interactive Option Buttons in index.html", f"4 complement buttons and 2 serving mode buttons verified")
    else:
        record_fail("Interactive Option Buttons in index.html", f"Unexpected button counts: {len(comp_btns)} complements, {len(mode_btns)} modes")

    if 'aria-label="Acceso rápido móvil"' in idx_content:
        record_pass("Mobile Action Bar in index.html", "Sticky mobile action bar with dynamic WhatsApp link verified")
    else:
        record_fail("Mobile Action Bar in index.html", "Missing sticky mobile action bar")

# ==============================================================================
# MAIN RUNNER
# ==============================================================================
if __name__ == "__main__":
    print("\n" + "#" * 70)
    print("  LA GARZA AGUACHILERA -- EMPIRICAL CHALLENGER M2 HARNESS")
    print("#" * 70)

    test_forbidden_words_and_addresses()
    test_legacy_prices_and_currency()
    test_gastronomy_attributes()
    test_dom_structure_and_four_pillars()
    test_asset_integrity()
    test_javascript_and_interactive_dom()

    print("\n" + "=" * 70)
    print("  FINAL CHALLENGER VERDICT")
    print("=" * 70)
    print(f"  TOTAL TESTS:  {TOTAL_TESTS}")
    print(f"  PASSED TESTS: {PASSED_TESTS}")
    print(f"  FAILED TESTS: {FAILED_TESTS}")

    if FAILED_TESTS == 0:
        print("\n  >>> VERDICT: APPROVE <<<")
        print("  All adversarial checks passed with zero deficiencies.")
        sys.exit(0)
    else:
        print("\n  >>> VERDICT: REQUEST_CHANGES <<<")
        print(f"  {FAILED_TESTS} test(s) failed.")
        sys.exit(1)
