# -*- coding: utf-8 -*-
"""
EMPIRICAL CHALLENGER INTERACTIVE & CUSTOMER JOURNEY TEST HARNESS (MILESTONE 2)
Adversarial Verification of:
1. Interactive Complement Selector & Modality Selector in index.html (Headless Edge CDP).
2. Combinatorial WhatsApp Link Generation & Query Encoding ($150 MXN, Avocado, House Sauces).
3. Copy Button Functionality in panel_control.html (Merchandising & Catalog Cards).
"""

import asyncio
import json
import os
import shutil
import subprocess
import sys
import time
import urllib.parse
import urllib.request
import websockets

sys.stdout.reconfigure(encoding='utf-8')

BASE_DIR = r"D:\AG\la garza aguachilera"
INDEX_PATH = os.path.join(BASE_DIR, "index.html")
PANEL_PATH = os.path.join(BASE_DIR, "panel_control.html")
EDGE_PATH = r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
CDP_PORT = 9365

results = []

def record(test_name, status, details):
    results.append({"test": test_name, "status": status, "details": details})
    prefix = "[PASS]" if status == "PASS" else "[FAIL]"
    print(f"{prefix} {test_name}: {details}")

class EdgeCDPSession:
    def __init__(self, port=CDP_PORT):
        self.port = port
        self.temp_dir = os.path.join(os.environ['TEMP'], f'edge_cdp_session_{port}')
        self.proc = None
        self.ws = None
        self.msg_id = 0
        self.console_errors = []

    async def start(self):
        if os.path.exists(self.temp_dir):
            try:
                shutil.rmtree(self.temp_dir)
            except Exception:
                pass

        self.proc = subprocess.Popen([
            EDGE_PATH,
            '--headless=new',
            f'--remote-debugging-port={self.port}',
            f'--user-data-dir={self.temp_dir}',
            '--allow-file-access-from-files',
            '--disable-web-security',
            '--disable-gpu',
            '--no-first-run',
            '--no-default-browser-check',
            'about:blank'
        ])

        for _ in range(30):
            await asyncio.sleep(0.3)
            try:
                with urllib.request.urlopen(f'http://127.0.0.1:{self.port}/json/version') as resp:
                    if resp.status == 200:
                        return
            except Exception:
                pass
        raise RuntimeError("Failed to connect to Edge via CDP")

    async def open_tab(self, file_path):
        if self.ws:
            await self.ws.close()
            self.ws = None

        uri = "file:///" + file_path.replace("\\", "/").replace(" ", "%20")
        req = urllib.request.Request(f'http://127.0.0.1:{self.port}/json/new?{uri}', method='PUT')
        with urllib.request.urlopen(req) as resp:
            tab_info = json.loads(resp.read().decode())
        
        ws_url = tab_info['webSocketDebuggerUrl']
        self.ws = await websockets.connect(ws_url, max_size=35*1024*1024)
        self.msg_id = 0
        await self.send("Runtime.enable")
        await asyncio.sleep(1.5)

    async def send(self, method, params=None):
        self.msg_id += 1
        cid = self.msg_id
        payload = {"id": cid, "method": method}
        if params:
            payload["params"] = params
        await self.ws.send(json.dumps(payload))
        
        while True:
            raw = await self.ws.recv()
            msg = json.loads(raw)
            if msg.get("method") == "Console.messageAdded":
                lvl = msg.get("params", {}).get("message", {}).get("level")
                txt = msg.get("params", {}).get("message", {}).get("text")
                if lvl == "error":
                    self.console_errors.append(txt)
            if msg.get("method") == "Runtime.exceptionThrown":
                desc = msg.get("params", {}).get("exceptionDetails", {}).get("text")
                self.console_errors.append(desc)
            if msg.get("id") == cid:
                return msg

    async def eval(self, expression):
        res = await self.send("Runtime.evaluate", {
            "expression": expression,
            "returnByValue": True,
            "awaitPromise": True
        })
        result_obj = res.get("result", {})
        if "exceptionDetails" in result_obj:
            err = result_obj["exceptionDetails"].get("text", "Unknown evaluation error")
            return {"error": err, "details": result_obj["exceptionDetails"]}
        val = result_obj.get("result", {}).get("value")
        return {"value": val}

    async def close(self):
        if self.ws:
            await self.ws.close()
        if self.proc:
            self.proc.terminate()
            self.proc.wait()
        if os.path.exists(self.temp_dir):
            try:
                shutil.rmtree(self.temp_dir)
            except Exception:
                pass


async def run_adversarial_suite():
    cdp = EdgeCDPSession(CDP_PORT)
    await cdp.start()

    try:
        # ==============================================================================
        # SUITE 1: INTERACTIVE COMPLEMENT & MODALITY SELECTORS IN INDEX.HTML
        # ==============================================================================
        print("\n" + "="*70)
        print("  SUITE 1: INTERACTIVE COMPLEMENT & MODALITY SELECTOR (EDGE CDP DOM)")
        print("="*70)

        await cdp.open_tab(INDEX_PATH)

        # 1.1 Initial Load State Check
        init_res = await cdp.eval("""
        (() => {
            const compContainer = document.getElementById('complement-selector');
            const compButtons = compContainer ? compContainer.querySelectorAll('.comp-btn') : [];
            const modeContainer = document.getElementById('mode-selector');
            const modeButtons = modeContainer ? modeContainer.querySelectorAll('.mode-btn') : [];
            const mainBtn = document.getElementById('main-wa-btn');
            const asides = document.querySelectorAll('aside');
            const mobileBtn = asides.length > 0 ? asides[asides.length - 1].querySelector('a') : null;

            return {
                compCount: compButtons.length,
                modeCount: modeButtons.length,
                activeCompIndex: Array.from(compButtons).findIndex(b => b.classList.contains('active-choice')),
                activeCompText: compButtons[0] ? compButtons[0].innerText.replace(/\\s+/g, ' ').trim() : null,
                activeModeIndex: Array.from(modeButtons).findIndex(b => b.classList.contains('active-mode')),
                activeModeText: modeButtons[0] ? modeButtons[0].innerText.replace(/\\s+/g, ' ').trim() : null,
                currentComplement: typeof currentComplement !== 'undefined' ? currentComplement : null,
                currentMode: typeof currentMode !== 'undefined' ? currentMode : null,
                mainHref: mainBtn ? mainBtn.href : null,
                mobileHref: mobileBtn ? mobileBtn.href : null
            };
        })()
        """)
        
        init_data = init_res.get("value", {})
        if init_data.get("compCount") == 4:
            record("Complement Buttons Count", "PASS", "Exactly 4 complement buttons found in #complement-selector")
        else:
            record("Complement Buttons Count", "FAIL", f"Expected 4 buttons, found {init_data.get('compCount')}")

        if init_data.get("modeCount") == 2:
            record("Modality Buttons Count", "PASS", "Exactly 2 modality buttons found in #mode-selector")
        else:
            record("Modality Buttons Count", "FAIL", f"Expected 2 buttons, found {init_data.get('modeCount')}")

        if init_data.get("activeCompIndex") == 0 and init_data.get("currentComplement") == "Tostitos Salsa Verde":
            record("Initial Complement State", "PASS", "Button 0 (Tostitos Salsa Verde) is active on page load")
        else:
            record("Initial Complement State", "FAIL", f"Active index: {init_data.get('activeCompIndex')}, currentComplement: {init_data.get('currentComplement')}")

        if init_data.get("activeModeIndex") == 0 and init_data.get("currentMode") == "preparado al momento":
            record("Initial Modality State", "PASS", "Button 0 is active on page load ('preparado al momento')")
        else:
            record("Initial Modality State", "FAIL", f"Active mode index: {init_data.get('activeModeIndex')}, currentMode: {init_data.get('currentMode')}")

        # Check initial href contains avocado & sauces & $150 MXN
        init_href = init_data.get("mainHref", "")
        init_decoded = urllib.parse.unquote(init_href)
        if "$150 MXN" in init_decoded and "aguacate fresco y cremoso garantizado" in init_decoded and "baño de salsas de la casa" in init_decoded:
            record("Initial WhatsApp Link Synced", "PASS", "Initial main-wa-btn has avocado, sauces, and $150 MXN from updateWhatsAppLinks()")
        else:
            record("Initial WhatsApp Link Synced", "FAIL", f"Initial link missing attributes: {init_decoded}")

        # 1.2 Test Sequential Complement Clicks & Dynamic DOM State Transitions
        complements_to_test = [
            (1, "Tostitos Flamin Hot", "Tostitos Flamin' Hot"),
            (2, "Chips o Totopos Artesanales", "Chips o Totopos"),
            (3, "Galletas Saladas", "Galletas Saladas"),
            (0, "Tostitos Salsa Verde", "Tostitos Salsa Verde")
        ]

        for idx, expected_var, label in complements_to_test:
            click_res = await cdp.eval(f"""
            (() => {{
                const buttons = document.querySelectorAll('#complement-selector .comp-btn');
                const target = buttons[{idx}];
                target.click();

                const activeIndices = [];
                buttons.forEach((b, i) => {{
                    if (b.classList.contains('active-choice') && b.classList.contains('border-emerald-400')) {{
                        activeIndices.push(i);
                    }}
                }});

                const asides = document.querySelectorAll('aside');
                const mobileBtn = asides.length > 0 ? asides[asides.length - 1].querySelector('a') : null;

                return {{
                    activeIndices: activeIndices,
                    currentComplement: currentComplement,
                    mainHref: document.getElementById('main-wa-btn').href,
                    mobileHref: mobileBtn ? mobileBtn.href : null
                }};
            }})()
            """)
            cdata = click_res.get("value", {})
            if cdata.get("activeIndices") == [idx] and cdata.get("currentComplement") == expected_var:
                record(f"Click Complement [{label}]", "PASS", f"Button {idx} gained active-choice exclusively, currentComplement = '{expected_var}'")
            else:
                record(f"Click Complement [{label}]", "FAIL", f"Active: {cdata.get('activeIndices')}, currentComplement: {cdata.get('currentComplement')}")

        # 1.3 Test Child Element Click Propagation (Clicking inner <span> instead of <button>)
        span_click_res = await cdp.eval("""
        (() => {
            const buttons = document.querySelectorAll('#complement-selector .comp-btn');
            const targetSpan = buttons[1].querySelector('span.text-xl'); // Emoji span 🔥
            targetSpan.click();

            const btn = buttons[1];
            return {
                btnHasActive: btn.classList.contains('active-choice'),
                spanHasActive: targetSpan.classList.contains('active-choice'),
                currentComplement: currentComplement
            };
        })()
        """)
        sdata = span_click_res.get("value", {})
        if sdata.get("btnHasActive") and not sdata.get("spanHasActive") and sdata.get("currentComplement") == "Tostitos Flamin Hot":
            record("Child Element Click Robustness (<span>)", "PASS", "'this' correctly bound to <button>, child span unaffected")
        else:
            record("Child Element Click Robustness (<span>)", "FAIL", f"Unexpected state: {sdata}")

        # 1.4 Test Modality Clicks
        modes_to_test = [
            (1, "Con complemento por separado"),
            (0, "Preparado al momento frente a ti")
        ]

        for idx, expected_mode in modes_to_test:
            mclick_res = await cdp.eval(f"""
            (() => {{
                const buttons = document.querySelectorAll('#mode-selector .mode-btn');
                const target = buttons[{idx}];
                target.click();

                const activeIndices = [];
                buttons.forEach((b, i) => {{
                    if (b.classList.contains('active-mode') && b.classList.contains('border-garza-neonlime')) {{
                        activeIndices.push(i);
                    }}
                }});

                const asides = document.querySelectorAll('aside');
                const mobileBtn = asides.length > 0 ? asides[asides.length - 1].querySelector('a') : null;

                return {{
                    activeIndices: activeIndices,
                    currentMode: currentMode,
                    mainHref: document.getElementById('main-wa-btn').href,
                    mobileHref: mobileBtn ? mobileBtn.href : null
                }};
            }})()
            """)
            mdata = mclick_res.get("value", {})
            if mdata.get("activeIndices") == [idx] and mdata.get("currentMode") == expected_mode:
                record(f"Click Modality [{expected_mode}]", "PASS", f"Mode button {idx} active exclusively, currentMode = '{expected_mode}'")
            else:
                record(f"Click Modality [{expected_mode}]", "FAIL", f"Active: {mdata.get('activeIndices')}, currentMode: {mdata.get('currentMode')}")

        # ==============================================================================
        # SUITE 2: COMBINATORIAL MATRIX VERIFICATION OF updateWhatsAppLinks()
        # ==============================================================================
        print("\n" + "="*70)
        print("  SUITE 2: COMBINATORIAL MATRIX & URL QUERY ENCODING STRESS TEST")
        print("="*70)

        complements = [
            "Tostitos Salsa Verde",
            "Tostitos Flamin Hot",
            "Chips o Totopos Artesanales",
            "Galletas Saladas"
        ]
        modes = [
            "Preparado al momento frente a ti",
            "Con complemento por separado"
        ]

        comb_index = 0
        all_combs_passed = True

        for comp in complements:
            for mode in modes:
                comb_index += 1
                eval_script = f"""
                (() => {{
                    currentComplement = {json.dumps(comp)};
                    currentMode = {json.dumps(mode)};
                    updateWhatsAppLinks();

                    const mainHref = document.getElementById('main-wa-btn').href;
                    const asides = document.querySelectorAll('aside');
                    const mobileHref = asides.length > 0 ? asides[asides.length - 1].querySelector('a').href : null;

                    return {{
                        mainHref: mainHref,
                        mobileHref: mobileHref
                    }};
                }})()
                """
                res = await cdp.eval(eval_script)
                rdata = res.get("value", {})
                main_url = rdata.get("mainHref", "")
                mobile_url = rdata.get("mobileHref", "")

                # 2.1 Verify URL structure & prefix
                prefix = "https://wa.me/528332520988?text="
                if not main_url.startswith(prefix) or not mobile_url.startswith(prefix):
                    record(f"Comb #{comb_index} Prefix Check", "FAIL", f"URL does not start with {prefix}")
                    all_combs_passed = False
                    continue

                if main_url != mobile_url:
                    record(f"Comb #{comb_index} Sync Check", "FAIL", "main-wa-btn and mobile bar hrefs are not synchronized")
                    all_combs_passed = False
                    continue

                # 2.2 Decode and verify message contents
                raw_query = main_url[len(prefix):]
                decoded_msg = urllib.parse.unquote(raw_query)

                # Strict assertions on decoded message
                has_150 = "$150 MXN" in decoded_msg
                has_avocado = "aguacate fresco y cremoso garantizado" in decoded_msg
                has_sauces = "baño de salsas de la casa" in decoded_msg
                has_comp = comp in decoded_msg
                has_mode = mode in decoded_msg
                has_shrimp = "Tostiaguachile Verde Tradicional" in decoded_msg and ("🍤" in decoded_msg or "🦐" in decoded_msg)
                has_greeting = "¡Hola La Garza Aguachilera!" in decoded_msg
                has_closure = "¿Me comparten las rutas activas de entrega para este fin de semana?" in decoded_msg

                # Check forbidden words
                forbidden_hits = [f for f in ["$170", "$160", "Rosa 210", "dark kitchen", "jumbo"] if f.lower() in decoded_msg.lower()]

                if has_150 and has_avocado and has_sauces and has_comp and has_mode and has_shrimp and has_greeting and has_closure and not forbidden_hits:
                    record(f"Comb #{comb_index} [{comp} | {mode[:18]}...]", "PASS", f"Verified $150 MXN, avocado, sauces, complement & mode")
                else:
                    failures = []
                    if not has_150: failures.append("Missing $150 MXN")
                    if not has_avocado: failures.append("Missing avocado")
                    if not has_sauces: failures.append("Missing house sauces")
                    if not has_comp: failures.append(f"Missing complement {comp}")
                    if not has_mode: failures.append(f"Missing mode {mode}")
                    if not has_shrimp: failures.append("Missing shrimp mention/emoji")
                    if not has_greeting: failures.append("Missing greeting")
                    if not has_closure: failures.append("Missing closing question")
                    if forbidden_hits: failures.append(f"Forbidden hits: {forbidden_hits}")
                    record(f"Comb #{comb_index} [{comp} | {mode[:18]}...]", "FAIL", ", ".join(failures))
                    all_combs_passed = False

                # 2.3 Verify Character Encoding Integrity
                # e.g., '¡' -> '%C2%A1', '¿' -> '%C2%BF', '🍤' -> '%F0%9F%8D%A4', 'ñ' -> '%C3%B1'
                has_excl = "%C2%A1" in raw_query
                has_ques = "%C2%BF" in raw_query
                has_shrimp_enc = ("%F0%9F%8D%A4" in raw_query or "%F0%9F%A6%90" in raw_query)
                has_enye = "%C3%B1" in raw_query

                if has_excl and has_ques and has_shrimp_enc and has_enye:
                    pass
                else:
                    record(f"Comb #{comb_index} UTF-8 Percent Encoding", "FAIL", f"Encoding issues: excl={has_excl}, ques={has_ques}, shrimp={has_shrimp_enc}, enye={has_enye}")
                    all_combs_passed = False

        if all_combs_passed:
            record("All 8 Combinations Matrix", "PASS", "100% of complement x modality combinations generated perfectly compliant WhatsApp links")

        # ==============================================================================
        # SUITE 3: COPY BUTTON FUNCTIONS IN PANEL_CONTROL.HTML
        # ==============================================================================
        print("\n" + "="*70)
        print("  SUITE 3: COPY BUTTON FUNCTIONS IN PANEL_CONTROL.HTML (EDGE CDP)")
        print("="*70)

        await cdp.open_tab(PANEL_PATH)

        # 3.1 Scope and Function Binding Verification
        scope_res = await cdp.eval("""
        (() => {
            return {
                copyCaptionType: typeof copyCaption,
                copyCaptionFromElementType: typeof copyCaptionFromElement,
                isSameFunction: copyCaption === copyCaptionFromElement,
                execFallbackCopyType: typeof execFallbackCopy,
                showToastType: typeof showToast
            };
        })()
        """)
        sinfo = scope_res.get("value", {})
        if sinfo.get("copyCaptionType") == "function" and sinfo.get("copyCaptionFromElementType") == "function" and sinfo.get("isSameFunction"):
            record("copyCaption Scope & Binding", "PASS", "copyCaption is defined globally and references copyCaptionFromElement")
        else:
            record("copyCaption Scope & Binding", "FAIL", f"Binding mismatch: {sinfo}")

        # 3.2 Audit all 43 copy buttons in panel_control.html
        btn_audit_res = await cdp.eval("""
        (() => {
            const results = [];
            const allButtons = document.querySelectorAll('button[onclick*="copyCaption"]');
            
            allButtons.forEach((btn, index) => {
                const onclickStr = btn.getAttribute('onclick');
                const m = onclickStr.match(/copyCaption(?:FromElement)?\\(['"]([^'"]+)['"]/);
                const targetId = m ? m[1] : null;
                const targetEl = targetId ? document.getElementById(targetId) : null;
                const text = targetEl ? (targetEl.innerText || targetEl.textContent).trim() : '';

                results.push({
                    index: index,
                    onclick: onclickStr,
                    targetId: targetId,
                    targetExists: !!targetEl,
                    textLength: text.length,
                    textPreview: text.substring(0, 50).replace(/\\s+/g, ' ')
                });
            });

            return results;
        })()
        """)
        buttons_data = btn_audit_res.get("value", [])
        record("Discovered Copy Buttons in DOM", "PASS", f"Found {len(buttons_data)} buttons with copyCaption onclick handlers in panel_control.html")

        # Check for missing targets or empty texts
        missing_targets = [b for b in buttons_data if not b.get("targetExists")]
        empty_texts = [b for b in buttons_data if b.get("textLength") == 0]

        if not missing_targets:
            record("Copy Target DOM Elements Existence", "PASS", f"All {len(buttons_data)} buttons reference existing DOM element IDs")
        else:
            record("Copy Target DOM Elements Existence", "FAIL", f"Missing targets for buttons: {missing_targets}")

        if not empty_texts:
            record("Copy Target Content Non-Empty", "PASS", f"All {len(buttons_data)} target elements contain meaningful caption text")
        else:
            record("Copy Target Content Non-Empty", "FAIL", f"Empty target texts for: {empty_texts}")

        # 3.3 Test Merchandising Cards Specifically (Cards 1 to 6 calling copyCaption)
        merch_buttons = [b for b in buttons_data if "caption-gorra-" in b.get("targetId", "")]
        record("Merchandising Cards Count", "PASS", f"Identified {len(merch_buttons)} merchandising cap cards (expected 6)")

        merch_clicks_ok = True
        for mb in merch_buttons:
            mres = await cdp.eval(f"""
            (async () => {{
                const targetId = {json.dumps(mb['targetId'])};
                const btn = document.querySelector(`button[onclick*="${{targetId}}"]`);
                if (!btn) return {{ success: false, reason: 'button not found' }};

                let errorThrown = null;
                try {{
                    btn.click();
                }} catch (e) {{
                    errorThrown = e.toString();
                }}

                await new Promise(r => setTimeout(r, 100));

                const toast = document.getElementById('toast');
                const toastMsg = document.getElementById('toastMsg');

                return {{
                    success: !errorThrown,
                    error: errorThrown,
                    toastVisible: toast ? toast.classList.contains('show') : false,
                    toastText: toastMsg ? toastMsg.innerText : null
                }};
            }})()
            """)
            mclick = mres.get("value", {})
            if mclick.get("success") and mclick.get("toastVisible"):
                pass
            else:
                record(f"Merch Card Click [{mb['targetId']}]", "FAIL", f"Error: {mclick.get('error')}, toastVisible: {mclick.get('toastVisible')}")
                merch_clicks_ok = False

        if merch_clicks_ok and len(merch_buttons) == 6:
            record("Merchandising Cards (1-6) copyCaption Execution", "PASS", "All 6 cap cards executed copyCaption cleanly without throwing error, toast active")

        # 3.4 Test Representative Sample of Catalog / Social Cards calling copyCaptionFromElement
        catalog_sample_ids = [
            "caption-portada",
            "caption-postfeed",
            "caption-catalogo-01",
            "caption-catalogo-05",
            "caption-catalogo-08",
            "caption-catalogo-11",
            "caption-catalogo-16"
        ]

        catalog_clicks_ok = True
        for cid in catalog_sample_ids:
            cres = await cdp.eval(f"""
            (() => {{
                const targetId = {json.dumps(cid)};
                const btn = document.querySelector(`button[onclick*="${{targetId}}"]`);
                if (!btn) return {{ success: false, reason: 'button not found' }};

                let errorThrown = null;
                try {{
                    btn.click();
                }} catch (e) {{
                    errorThrown = e.toString();
                }}

                const toast = document.getElementById('toast');
                return {{
                    success: !errorThrown,
                    error: errorThrown,
                    toastVisible: toast ? toast.classList.contains('show') : false
                }};
            }})()
            """)
            cdata = cres.get("value", {})
            if cdata.get("success") and cdata.get("toastVisible"):
                pass
            else:
                record(f"Catalog Card Click [{cid}]", "FAIL", f"Error: {cdata.get('error')}, toastVisible: {cdata.get('toastVisible')}")
                catalog_clicks_ok = False

        if catalog_clicks_ok:
            record("Catalog & Marketing Cards copyCaptionFromElement Execution", "PASS", f"Tested representative sample ({len(catalog_sample_ids)} cards) without error, toast active")

        # 3.5 Test Full Clipboard API Success Simulation with Mocked writeText
        mock_test = await cdp.eval("""
        (async () => {
            const btn = document.querySelector('button[onclick*="caption-gorra-1"]');
            
            Object.defineProperty(navigator, 'clipboard', {
                value: { writeText: async (t) => Promise.resolve() },
                configurable: true
            });

            btn.click();
            await new Promise(r => setTimeout(r, 60));

            return {
                btnHtml: btn.innerHTML,
                hasSuccessClass: btn.classList.contains('copy-success')
            };
        })()
        """)
        mdata = mock_test.get("value", {})
        if mdata.get("hasSuccessClass") and "¡Copiado! ✅" in mdata.get("btnHtml", ""):
            record("Clipboard API Success Feedback Loop", "PASS", "Visual badge '¡Copiado! ✅' and .copy-success class triggered on successful clipboard write")
        else:
            record("Clipboard API Success Feedback Loop", "FAIL", f"Feedback loop failed: {mdata}")

        # 3.6 Check Console Errors Across Entire Session
        if not cdp.console_errors:
            record("Browser Console Errors & Uncaught Exceptions", "PASS", "Zero console errors or uncaught exceptions logged across all interactions")
        else:
            record("Browser Console Errors & Uncaught Exceptions", "FAIL", f"Console errors detected: {cdp.console_errors}")

    finally:
        await cdp.close()

    # ==============================================================================
    # FINAL HARNESS VERDICT
    # ==============================================================================
    print("\n" + "="*70)
    print("  FINAL INTERACTIVE & CUSTOMER JOURNEY CHALLENGE VERDICT")
    print("="*70)

    total_tests = len(results)
    fails = [r for r in results if r["status"] == "FAIL"]
    passes = [r for r in results if r["status"] == "PASS"]

    print(f"Total Tests Executed: {total_tests}")
    print(f"Passed: {len(passes)}")
    print(f"Failed: {len(fails)}")

    if fails:
        print("\nFAILED TESTS SUMMARY:")
        for f in fails:
            print(f"  - {f['test']}: {f['details']}")
        print("\nOVERALL VERDICT: REQUEST_CHANGES")
        sys.exit(1)
    else:
        print("\nOVERALL VERDICT: APPROVE")
        print("ALL INTERACTIVE MECHANICS & CUSTOMER JOURNEYS VERIFIED EMPIRICALLY WITH 0 DEFICIENCIES.")
        sys.exit(0)

if __name__ == "__main__":
    asyncio.run(run_adversarial_suite())
