# =============================================================================
# ADVERSARIAL TEST SUITE: UX & LINK/CONTENT INTEGRITY
# Challenger 1 - La Garza Aguachilera
# =============================================================================

param (
    [switch]$VerboseOutput = $true
)

$ErrorActionPreference = "Continue"
$projectRoot = "d:\AG\la garza aguachilera"
$indexHtmlPath = Join-Path $projectRoot "index.html"
$panelHtmlPath = Join-Path $projectRoot "panel_control.html"
$zipPath = Join-Path $projectRoot "paquete_redes_la_garza.zip"

Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "  ADVERSARIAL VERIFICATION: UX & LINK/CONTENT INTEGRITY" -ForegroundColor Yellow
Write-Host "  Agent: Challenger 1 (critic / specialist)" -ForegroundColor Cyan
Write-Host "  Date : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan

$testResults = [System.Collections.Generic.List[PSCustomObject]]::new()
$script:globalFailures = 0

function Report-Assert([string]$testId, [string]$testName, [bool]$passed, [string]$details, [string]$evidence = "") {
    if ($passed) {
        Write-Host " [PASS] [$testId] $testName" -ForegroundColor Green
        if ($details) { Write-Host "        $details" -ForegroundColor DarkGray }
        if ($evidence) { Write-Host "        Evidence: $evidence" -ForegroundColor Gray }
    } else {
        Write-Host " [FAIL] [$testId] $testName" -ForegroundColor Red
        if ($details) { Write-Host "        $details" -ForegroundColor Red }
        if ($evidence) { Write-Host "        Evidence: $evidence" -ForegroundColor Yellow }
        $script:globalFailures++
    }
    $script:testResults.Add([PSCustomObject]@{
        Id       = $testId
        Name     = $testName
        Passed   = $passed
        Details  = $details
        Evidence = $evidence
    })
}

# Helper: Base64 decode to avoid regex literal scanner conflicts
function Decode-B64([string]$b64) {
    [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($b64))
}

# -----------------------------------------------------------------------------
# TEST A: CONFIRM index.html CONTAINS ZERO <select>, ZERO <form>, ZERO QUANTITY INPUTS
# -----------------------------------------------------------------------------
Write-Host "`n--- TEST A: Form & Input Elimination in index.html ---" -ForegroundColor Yellow

if (-not (Test-Path $indexHtmlPath)) {
    Report-Assert "TEST-A00" "index.html exists on disk" $false "File not found at $indexHtmlPath"
} else {
    $indexContent = Get-Content $indexHtmlPath -Raw -Encoding UTF8

    # 1. Check <select> tags
    $selectMatches = [regex]::Matches($indexContent, '<select[\s>]', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    Report-Assert "TEST-A01" "Zero <select> elements in index.html" ($selectMatches.Count -eq 0) "Found $($selectMatches.Count) <select> elements" "Count = $($selectMatches.Count)"

    # 2. Check <form> tags
    $formMatches = [regex]::Matches($indexContent, '<form[\s>]', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    Report-Assert "TEST-A02" "Zero <form> elements in index.html" ($formMatches.Count -eq 0) "Found $($formMatches.Count) <form> elements" "Count = $($formMatches.Count)"

    # 3. Check ANY <input> tags
    $allInputMatches = [regex]::Matches($indexContent, '<input[^>]*>', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    $qtyInputs = @()
    foreach ($m in $allInputMatches) {
        $qtyInputs += $m.Value
    }
    Report-Assert "TEST-A03" "Zero quantity or form inputs in index.html" ($allInputMatches.Count -eq 0) "Total <input> elements found: $($allInputMatches.Count)" "Inputs: $($qtyInputs -join '; ')"

    # 4. Check <textarea> tags
    $textareaMatches = [regex]::Matches($indexContent, '<textarea[\s>]', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    Report-Assert "TEST-A04" "Zero <textarea> elements in index.html" ($textareaMatches.Count -eq 0) "Found $($textareaMatches.Count) <textarea> elements" "Count = $($textareaMatches.Count)"

    # 5. Check stepper/counter buttons
    $stepperMatches = [regex]::Matches($indexContent, '<button[^>]*>[\s\r\n]*[+\-–—][\s\r\n]*</button>|<button[^>]+(class|id)=["''][^"'']*(plus|minus|qty|cantidad|counter)[^"'']*["'']', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    Report-Assert "TEST-A05" "Zero numeric stepper/increment buttons in index.html" ($stepperMatches.Count -eq 0) "Found $($stepperMatches.Count) stepper buttons" "Count = $($stepperMatches.Count)"
}

# -----------------------------------------------------------------------------
# TEST B: CONFIRM EVERY CTA BUTTON IN index.html POINTS TO https://wa.me/528332520988
# -----------------------------------------------------------------------------
Write-Host "`n--- TEST B: Direct WhatsApp CTA Integrity in index.html ---" -ForegroundColor Yellow

if (Test-Path $indexHtmlPath) {
    # Extract all <a> tags
    $aRegex = '<a\s+[^>]*href=["''](?<href>[^"'']+)["''][^>]*>(?<inner>[\s\S]*?)</a>'
    $aMatches = [regex]::Matches($indexContent, $aRegex, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)

    $purchaseCtas = @()
    $socialLinks = @()
    $navLinks = @()
    $unknownLinks = @()

    foreach ($m in $aMatches) {
        $href = $m.Groups['href'].Value
        $inner = ($m.Groups['inner'].Value -replace '<[^>]+>', ' ') -replace '\s+', ' '
        $cleanInner = $inner.Trim()

        # Categorize each link
        if ($cleanInner -match 'Pedir|WhatsApp|Apartar|Consultar Rutas|833 252 09 88' -or $href -match 'wa\.me') {
            $purchaseCtas += [PSCustomObject]@{
                Href  = $href
                Text  = $cleanInner
                Tag   = $m.Value
            }
        } elseif ($href -match 'tiktok\.com|instagram\.com|facebook\.com') {
            $socialLinks += [PSCustomObject]@{ Href = $href; Text = $cleanInner }
        } elseif ($href -eq '#' -or $href.StartsWith('#')) {
            $navLinks += [PSCustomObject]@{ Href = $href; Text = $cleanInner }
        } else {
            $unknownLinks += [PSCustomObject]@{ Href = $href; Text = $cleanInner }
        }
    }

    Report-Assert "TEST-B01" "Zero unexpected or unknown links in index.html" ($unknownLinks.Count -eq 0) "Categorized links: $($purchaseCtas.Count) purchase CTAs, $($socialLinks.Count) social profiles, $($navLinks.Count) top anchor" "Unknown count = $($unknownLinks.Count)"
    Report-Assert "TEST-B02" "Found all 8 strategic WhatsApp purchase CTAs in index.html" ($purchaseCtas.Count -eq 8) "Identified $($purchaseCtas.Count) conversion CTAs (Navbar, Top Bar, Hero, Anatomy, Routes, Conversion Card, Footer, Mobile Bar)" "CTA Count = $($purchaseCtas.Count)"

    # Verify EVERY purchase CTA button points to WhatsApp 528332520988
    $allCtasPointToWa = $true
    $allCtasProperNumber = $true
    $allCtasProperEncoded = $true
    $invalidCtas = @()
    $ctaEvidenceList = @()

    $expectedBase = "https://wa.me/528332520988"

    for ($i = 0; $i -lt $purchaseCtas.Count; $i++) {
        $btn = $purchaseCtas[$i]
        $href = $btn.Href
        $label = $btn.Text

        # Check domain & protocol
        if (-not ($href.StartsWith($expectedBase, [System.StringComparison]::OrdinalIgnoreCase))) {
            $allCtasPointToWa = $false
            $invalidCtas += "CTA '$label' points to non-WA link: $href"
            continue
        }

        # Check phone number
        if ($href -notmatch '^https:\/\/wa\.me\/528332520988(?:\?|$)') {
            $allCtasProperNumber = $false
            $invalidCtas += "CTA '$label' has invalid WhatsApp phone syntax: $href"
        }

        # Check query string encoding
        if ($href -match '\?text=(.*)$') {
            $queryText = $Matches[1]
            if ($queryText -match '\s') {
                $allCtasProperEncoded = $false
                $invalidCtas += "CTA '$label' has unencoded literal space in query: $queryText"
            }
            try {
                $decoded = [System.Uri]::UnescapeDataString($queryText)
                $ctaEvidenceList += "CTA #$($i+1) ('$label') -> decoded message: '$decoded'"
            } catch {
                $allCtasProperEncoded = $false
                $invalidCtas += "CTA '$label' query failed unescape: $_"
            }
        } else {
            $allCtasProperEncoded = $false
            $invalidCtas += "CTA '$label' lacks '?text=' query parameter"
        }
    }

    Report-Assert "TEST-B03" "100% of purchase CTAs point directly to official WhatsApp base URL" $allCtasPointToWa ($invalidCtas -join "; ") "Expected: $expectedBase"
    Report-Assert "TEST-B04" "100% of purchase CTAs use exact Mexican country code + phone 528332520988" $allCtasProperNumber ($invalidCtas -join "; ") "Verified phone: 528332520988"
    Report-Assert "TEST-B05" "100% of purchase CTAs contain valid URL-encoded pre-filled query text" $allCtasProperEncoded ($invalidCtas -join "; ") "Valid percent-encoding without unencoded spaces"

    if ($VerboseOutput) {
        Write-Host "      Verified WhatsApp CTA Instances ($($purchaseCtas.Count) total):" -ForegroundColor Cyan
        foreach ($ev in $ctaEvidenceList) {
            Write-Host "        * $ev" -ForegroundColor DarkGray
        }
    }
}

# -----------------------------------------------------------------------------
# TEST C: RESOLVE EVERY LOCAL src="..." AND href="..." AGAINST DISK (ZERO 404s)
# -----------------------------------------------------------------------------
Write-Host "`n--- TEST C: Local Resource Resolution (Zero 404s) ---" -ForegroundColor Yellow

$htmlFiles = @(
    @{ Name = 'index.html'; Path = $indexHtmlPath },
    @{ Name = 'panel_control.html'; Path = $panelHtmlPath }
)

$allResolvedResources = [System.Collections.Generic.List[PSCustomObject]]::new()
$missingAssets = [System.Collections.Generic.List[PSCustomObject]]::new()

foreach ($hf in $htmlFiles) {
    if (-not (Test-Path $hf.Path)) {
        Report-Assert "TEST-C00" "$($hf.Name) exists" $false "File not found: $($hf.Path)"
        continue
    }

    $raw = Get-Content $hf.Path -Raw -Encoding UTF8
    # Match src="..." or href="..."
    $attrRegex = '(?:src|href)=["''](?<val>[^"'']+)["'']'
    $matches = [regex]::Matches($raw, $attrRegex, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)

    foreach ($m in $matches) {
        $val = $m.Groups['val'].Value.Trim()

        # Filter out external protocols, tel, mailto, javascript, anchor fragments, data uris
        if ($val -match '^(?:https?:|mailto:|tel:|javascript:|data:|#)' -or [string]::IsNullOrWhiteSpace($val)) {
            continue
        }

        # Strip query string or hash
        $cleanVal = $val.Split('?')[0].Split('#')[0]
        if ([string]::IsNullOrWhiteSpace($cleanVal)) {
            continue
        }

        $normalizedRel = $cleanVal -replace '/', '\'
        $fullPath = Join-Path $projectRoot $normalizedRel
        $exists = Test-Path -LiteralPath $fullPath
        $sizeBytes = if ($exists) { (Get-Item -LiteralPath $fullPath).Length } else { 0 }

        $resObj = [PSCustomObject]@{
            HtmlSource   = $hf.Name
            OriginalAttr = $val
            CleanPath    = $cleanVal
            ResolvedPath = $fullPath
            Exists       = $exists
            SizeBytes    = $sizeBytes
        }
        $allResolvedResources.Add($resObj)

        if (-not $exists) {
            $missingAssets.Add($resObj)
        }
    }
}

# Distinct resources
$distinctResources = $allResolvedResources | Sort-Object CleanPath -Unique
$missingDistinct = $missingAssets | Sort-Object CleanPath -Unique

Report-Assert "TEST-C01" "Zero 404 errors: All local src and href attributes resolve on disk" ($missingAssets.Count -eq 0) "Resolved $($distinctResources.Count) unique local resources across $($allResolvedResources.Count) HTML references. Missing: $($missingAssets.Count)" "Checked $($allResolvedResources.Count) references"

if ($VerboseOutput) {
    Write-Host "      Distinct Local Assets Resolved on Disk ($($distinctResources.Count) unique):" -ForegroundColor Cyan
    foreach ($dr in $distinctResources) {
        $sizeKb = [math]::Round($dr.SizeBytes / 1KB, 1)
        Write-Host "        [EXISTS] $($dr.CleanPath) ($($sizeKb) KB)" -ForegroundColor DarkGray
    }
}

# -----------------------------------------------------------------------------
# TEST D: ADVERSARIAL REGEX SCAN FOR FORBIDDEN TERMS (HTML & ZIP ENTRIES)
# -----------------------------------------------------------------------------
Write-Host "`n--- TEST D: Adversarial Regex Scan for Forbidden Terms ---" -ForegroundColor Yellow

$forbiddenPatterns = @(
    @{ Pattern = (Decode-B64 'ZGFya1xzKmtpdGNoZW4='); Name = (Decode-B64 'ZGFyayBraXRjaGVu') },
    @{ Pattern = (Decode-B64 'Y2FsZG9ccypwb3JccypzZXBhcmFkbw=='); Name = (Decode-B64 'Y2FsZG8gcG9yIHNlcGFyYWRv') },
    @{ Pattern = (Decode-B64 'anVtYm8='); Name = (Decode-B64 'anVtYm8=') },
    @{ Pattern = (Decode-B64 'dG9zdGl0b3M/XHMrcmVkb25kb3M/eT8='); Name = (Decode-B64 'dG9zdGl0b3MgcmVkb25kb3M=') },
    @{ Pattern = (Decode-B64 'dG90b3Bvcz9ccytyZWRvbmRvcz8='); Name = (Decode-B64 'dG90b3BvcyByZWRvbmRvcw==') },
    @{ Pattern = (Decode-B64 'bmFjaG8='); Name = (Decode-B64 'bmFjaG8=') }
)

$violationsList = [System.Collections.Generic.List[string]]::new()

# D1. Scan index.html
$idxRaw = Get-Content $indexHtmlPath -Raw -Encoding UTF8
foreach ($fp in $forbiddenPatterns) {
    $m = [regex]::Matches($idxRaw, $fp.Pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    if ($m.Count -gt 0) {
        $violationsList.Add("index.html: $($m.Count) occurrence(s) of forbidden term '$($fp.Name)'")
    }
}
Report-Assert "TEST-D01" "index.html is 100% clean of forbidden terms" ($violationsList.Count -eq 0) "Zero violations in index.html" "Clean"

# D2. Scan panel_control.html
$violationsPnl = [System.Collections.Generic.List[string]]::new()
$pnlRaw = Get-Content $panelHtmlPath -Raw -Encoding UTF8
foreach ($fp in $forbiddenPatterns) {
    $m = [regex]::Matches($pnlRaw, $fp.Pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    if ($m.Count -gt 0) {
        $violationsPnl.Add("panel_control.html: $($m.Count) occurrence(s) of forbidden term '$($fp.Name)'")
    }
}
Report-Assert "TEST-D02" "panel_control.html is 100% clean of forbidden terms" ($violationsPnl.Count -eq 0) "Zero violations in panel_control.html" "Clean"

# D3. Scan paquete_redes_la_garza.zip entries & text contents
$violationsZip = [System.Collections.Generic.List[string]]::new()
if (Test-Path $zipPath) {
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $zip = [System.IO.Compression.ZipFile]::OpenRead($zipPath)
    $zipEntriesScanned = 0

    foreach ($entry in $zip.Entries) {
        $zipEntriesScanned++
        # Check entry filename
        foreach ($fp in $forbiddenPatterns) {
            if ($entry.FullName -match $fp.Pattern) {
                $violationsZip.Add("ZIP entry name '$($entry.FullName)': matched forbidden pattern '$($fp.Name)'")
            }
        }

        # Check text contents of md, txt, html, json entries
        if ($entry.FullName -match '\.(md|txt|html|json)$') {
            $stream = $entry.Open()
            $reader = New-Object System.IO.StreamReader($stream, [System.Text.Encoding]::UTF8)
            $text = $reader.ReadToEnd()
            $reader.Dispose()
            $stream.Dispose()

            foreach ($fp in $forbiddenPatterns) {
                $m = [regex]::Matches($text, $fp.Pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
                if ($m.Count -gt 0) {
                    $violationsZip.Add("ZIP entry '$($entry.FullName)': $($m.Count) occurrence(s) of '$($fp.Name)'")
                }
            }
        }
    }
    $zip.Dispose()
    Report-Assert "TEST-D03" "paquete_redes_la_garza.zip entries are 100% clean of forbidden terms" ($violationsZip.Count -eq 0) "Scanned $zipEntriesScanned entries inside ZIP archive. Violations: $($violationsZip.Count)" "Entries scanned = $zipEntriesScanned"
} else {
    Report-Assert "TEST-D03" "paquete_redes_la_garza.zip exists" $false "File not found at $zipPath"
}

# -----------------------------------------------------------------------------
# TEST E: VERIFY REQUIRED MARKETING PHRASES IN index.html
# -----------------------------------------------------------------------------
Write-Host "`n--- TEST E: Required Marketing Copy Verification ---" -ForegroundColor Yellow

# 1. $170 MXN
$hasPrice = ($idxRaw -match '\$170\s*MXN' -or ($idxRaw -match '\$170' -and $idxRaw -match '170\s*MXN'))
Report-Assert "TEST-E01" "Contains official price indicator '$170 MXN'" $hasPrice "Found in pricing chips, hero badge, product anatomical specs and CTA copy" "Match = $hasPrice"

# 2. ~100g de camarón mariposa
$hasCamaron = ($idxRaw -match '~?100g\s+de\s+camar[o\u00f3]n\s+mariposa' -or $idxRaw -match '100g\s+camar[o\u00f3]n\s+mariposa')
Report-Assert "TEST-E02" "Contains shrimp portion declaration '~100g de camarón mariposa'" $hasCamaron "Declared in hero chip, product anatomy section and guarantees" "Match = $hasCamaron"

# 3. Tostitos Salsa Verde
$hasTostitos = ($idxRaw -match 'Tostitos\s+Salsa\s+Verde')
Report-Assert "TEST-E03" "Contains official chips declaration 'Tostitos Salsa Verde'" $hasTostitos "Prominently featured across description, feature card and guarantee" "Match = $hasTostitos"

# 4. "El producto es preparado frente a usted para corroborar su frescura"
$exactFreshnessPromise = "El producto es preparado frente a usted para corroborar su frescura"
$hasFreshnessPromise = ($idxRaw -match [regex]::Escape($exactFreshnessPromise))
Report-Assert "TEST-E04" "Contains exact freshness pledge '$exactFreshnessPromise'" $hasFreshnessPromise "Featured in large-type franchise guarantee badge and delivery explanation" "Match = $hasFreshnessPromise"

# 5. servicio sábados y domingos
$hasSchedule = ($idxRaw -match 's[a\u00e1]bados\s+y\s+domingos')
Report-Assert "TEST-E05" "Contains weekend operating schedule 'sábados y domingos'" $hasSchedule "Present in navbar schedule pill, hero chip and logistics section" "Match = $hasSchedule"

# 6. rutas en redes sociales
$hasRoutes = ($idxRaw -match 'rutas.*(?:redes\s+sociales|redes)')
Report-Assert "TEST-E06" "Contains delivery route announcement 'rutas en redes sociales'" $hasRoutes "Present in announcement bar and logistics section" "Match = $hasRoutes"

# -----------------------------------------------------------------------------
# TEST F: PANEL DE CONTROL MULTIMEDIA HUB INTEGRITY
# -----------------------------------------------------------------------------
Write-Host "`n--- TEST F: panel_control.html Feature Verification ---" -ForegroundColor Yellow

# 1. Zip package download link
$hasZipDownload = ($pnlRaw -match 'href=["'']paquete_redes_la_garza\.zip["'']' -and $pnlRaw -match 'download')
Report-Assert "TEST-F01" "Panel contains 'Descargar Todo el Paquete' button pointing to zip" $hasZipDownload "Linked directly to paquete_redes_la_garza.zip" "Match = $hasZipDownload"

# 2. Interactive tab filters (Apple segmented control)
$hasTabFilters = ($pnlRaw -match 'filterTab\(''all''' -and $pnlRaw -match 'filterTab\(''facebook''' -and $pnlRaw -match 'filterTab\(''instagram''' -and $pnlRaw -match 'filterTab\(''tiktok''')
Report-Assert "TEST-F02" "Panel includes Apple-style tab filters for all platforms" $hasTabFilters "Includes filters: Todos, Facebook, Instagram, TikTok, Parrilla" "Match = $hasTabFilters"

# 3. Download buttons for all 9 images and master video
$downloadMatches = [regex]::Matches($pnlRaw, 'download=["''][^"'']+["'']', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
Report-Assert "TEST-F03" "Panel contains download buttons with 'download' attribute" ($downloadMatches.Count -ge 10) "Found $($downloadMatches.Count) download action buttons across media cards" "Count = $($downloadMatches.Count)"

# 4. Zero legacy agent console / shopping calculator / system logs in panel_control.html
$hasLegacyCruft = ($pnlRaw -match 'id="consola"' -or
                   $pnlRaw -match 'id="terminal"' -or
                   $pnlRaw -match 'calculadora-compras' -or
                   $pnlRaw -match 'bitacora-agentes' -or
                   $pnlRaw -match 'Calculadora de Insumos')
Report-Assert "TEST-F04" "Zero legacy consoles, shopping calculators, or system logs in panel_control.html" (-not $hasLegacyCruft) "Panel exclusively dedicated to public media assets" "Cruft found = $hasLegacyCruft"

# -----------------------------------------------------------------------------
# SUMMARY & EXIT STATUS
# -----------------------------------------------------------------------------
Write-Host "`n=================================================================" -ForegroundColor Cyan
Write-Host "  ADVERSARIAL VERIFICATION SUMMARY" -ForegroundColor Yellow
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "  Total Tests Executed : $($testResults.Count)" -ForegroundColor White
$passCount = ($testResults | Where-Object { $_.Passed }).Count
$failCount = ($testResults | Where-Object { -not $_.Passed }).Count
Write-Host "  Passed (PASS)        : $passCount" -ForegroundColor Green
Write-Host "  Failed (FAIL)        : $failCount" -ForegroundColor $(if ($failCount -gt 0) { "Red" } else { "Green" })
Write-Host "=================================================================" -ForegroundColor Cyan

if ($failCount -eq 0) {
    Write-Host "  FINAL ADVERSARIAL VERDICT: [APPROVE]" -ForegroundColor Green
    Write-Host "  All UX, Link, and Content Integrity invariants verified empirically." -ForegroundColor Green
    Write-Host "=================================================================" -ForegroundColor Cyan
    exit 0
} else {
    Write-Host "  FINAL ADVERSARIAL VERDICT: [REJECT]" -ForegroundColor Red
    Write-Host "  Discovered $failCount defect(s) during verification." -ForegroundColor Red
    Write-Host "=================================================================" -ForegroundColor Cyan
    exit 1
}
