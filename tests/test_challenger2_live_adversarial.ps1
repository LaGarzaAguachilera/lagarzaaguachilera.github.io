# Empirical Adversarial Test Suite for Challenger 2
# Tests live endpoints, DOM integrity, asset availability, and interactive UI logic

$ErrorActionPreference = "Stop"

Write-Host "================================================================="
Write-Host "CHALLENGER 2: EMPIRICAL LIVE DEPLOYMENT & DOM ADVERSARIAL SUITE"
Write-Host "================================================================="

$suiteFailures = 0

function Assert-Condition($condition, $passMsg, $failMsg) {
    if ($condition) {
        Write-Host "  [PASS] $passMsg" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] $failMsg" -ForegroundColor Red
        $script:suiteFailures++
    }
}

# -------------------------------------------------------------
# 1. LIVE HTTP ENDPOINTS: HEAD & GET INTEGRITY
# -------------------------------------------------------------
Write-Host "`n1. AUDITING LIVE HTTP ENDPOINTS (GitHub Pages)..."

$endpoints = @(
    "https://lagarzaaguachilera.github.io/index.html",
    "https://lagarzaaguachilera.github.io/panel_control.html",
    "https://lagarzaaguachilera.github.io/"
)

$wc = New-Object System.Net.WebClient
$wc.Encoding = [System.Text.Encoding]::UTF8

$liveHtmlIndex = ""
$liveHtmlPanel = ""

foreach ($ep in $endpoints) {
    try {
        $headReq = [System.Net.HttpWebRequest]::Create($ep)
        $headReq.Method = "HEAD"
        $headReq.Timeout = 15000
        $headResp = $headReq.GetResponse()
        $code = [int]$headResp.StatusCode
        $headResp.Close()
        Assert-Condition ($code -eq 200) "HEAD $ep returned HTTP 200 OK" "HEAD $ep returned HTTP $code"
    } catch {
        Assert-Condition $false "" "HEAD $ep failed: $($_.Exception.Message)"
    }
}

try {
    $liveHtmlIndex = $wc.DownloadString("https://lagarzaaguachilera.github.io/index.html")
    Assert-Condition ($liveHtmlIndex.Length -gt 10000) "GET index.html succeeded ($($liveHtmlIndex.Length) chars)" "GET index.html failed or empty"
} catch {
    Assert-Condition $false "" "GET index.html failed: $($_.Exception.Message)"
}

try {
    $liveHtmlPanel = $wc.DownloadString("https://lagarzaaguachilera.github.io/panel_control.html")
    Assert-Condition ($liveHtmlPanel.Length -gt 50000) "GET panel_control.html succeeded ($($liveHtmlPanel.Length) chars)" "GET panel_control.html failed or empty"
} catch {
    Assert-Condition $false "" "GET panel_control.html failed: $($_.Exception.Message)"
}

# -------------------------------------------------------------
# 2. FACEBOOK LINK INTEGRITY ON LIVE DOM
# -------------------------------------------------------------
Write-Host "`n2. AUDITING OFFICIAL FACEBOOK LINK & 0 GENERIC LINKS..."

$officialFbUrl = "https://www.facebook.com/share/19mMzwqpL4/?mibextid=wwXIfr"

# Index.html FB checks
$indexAllFb = [regex]::Matches($liveHtmlIndex, 'href=["'']([^"'']*facebook\.com[^"'']*)["'']')
Assert-Condition ($indexAllFb.Count -eq 1) "index.html has exactly 1 Facebook link (found: $($indexAllFb.Count))" "index.html has $($indexAllFb.Count) FB links (expected 1)"

if ($indexAllFb.Count -ge 1) {
    $foundUrl = $indexAllFb[0].Groups[1].Value
    Assert-Condition ($foundUrl -eq $officialFbUrl) "index.html FB link matches official URL exactly" "index.html FB link mismatch: '$foundUrl' != '$officialFbUrl'"
}

$genericFbInIndex = [regex]::Matches($liveHtmlIndex, 'href=["'']https?:\/\/(www\.)?facebook\.com\/?["'']')
Assert-Condition ($genericFbInIndex.Count -eq 0) "index.html contains 0 generic facebook.com links" "index.html contains $($genericFbInIndex.Count) generic facebook.com links"

$fbAnchorIndex = [regex]::Match($liveHtmlIndex, '<a\s+[^>]*href=["'']' + [regex]::Escape($officialFbUrl) + '["''][^>]*>')
Assert-Condition ($fbAnchorIndex.Success -and $fbAnchorIndex.Value -match 'target=["'']_blank["'']') "index.html FB link contains target='_blank'" "index.html FB link missing target='_blank'"

# Panel_control.html FB checks
$panelAllFb = [regex]::Matches($liveHtmlPanel, 'href=["'']([^"'']*facebook\.com[^"'']*)["'']')
Assert-Condition ($panelAllFb.Count -eq 1) "panel_control.html has exactly 1 Facebook link (found: $($panelAllFb.Count))" "panel_control.html has $($panelAllFb.Count) FB links (expected 1)"

if ($panelAllFb.Count -ge 1) {
    $foundPanelUrl = $panelAllFb[0].Groups[1].Value
    Assert-Condition ($foundPanelUrl -eq $officialFbUrl) "panel_control.html FB link matches official URL exactly" "panel_control.html FB link mismatch: '$foundPanelUrl' != '$officialFbUrl'"
}

$genericFbInPanel = [regex]::Matches($liveHtmlPanel, 'href=["'']https?:\/\/(www\.)?facebook\.com\/?["'']')
Assert-Condition ($genericFbInPanel.Count -eq 0) "panel_control.html contains 0 generic facebook.com links" "panel_control.html contains $($genericFbInPanel.Count) generic facebook.com links"

# -------------------------------------------------------------
# 3. SPOOKY TAB & INTERACTIVE UI CARD ELEMENTS
# -------------------------------------------------------------
Write-Host "`n3. AUDITING SPOOKY TAB & INTERACTIVE CARDS IN panel_control.html..."

# Filter tab button
$spookyTabMatch = [regex]::Match($liveHtmlPanel, '<button[^>]*data-filter=["'']spooky["''][^>]*onclick=["'']filterTab\([''"]spooky[''"],\s*this\)["''][^>]*>')
Assert-Condition ($spookyTabMatch.Success) "Spooky filter tab button exists with data-filter='spooky' and onclick='filterTab(\`'spooky\`', this)'" "Spooky filter tab button missing or misconfigured"

# Spooky category cards
$spookyCardMatches = [regex]::Matches($liveHtmlPanel, '<article[^>]*class=["''][^"'']*media-card[^"'']*["''][^>]*data-category=["''][^"'']*spooky[^"'']*["''][^>]*>')
Assert-Condition ($spookyCardMatches.Count -eq 8) "Found exactly 8 media-cards in Spooky category (found: $($spookyCardMatches.Count))" "Expected 8 spooky cards, found: $($spookyCardMatches.Count)"

# Card 1: Master Video
$videoSrcMatch = [regex]::Match($liveHtmlPanel, '<video[^>]*src=["'']VIDEOS\/promo_halloween_zombies_crudos\.mp4["''][^>]*controls')
Assert-Condition ($videoSrcMatch.Success) "Card 1: Master Video element found with controls and correct source" "Card 1: Master Video element missing"

# Spooky Posters (Feed & Story)
$expectedPosters = @(
    "contenido_redes/posts_periodicos/spooky_post01_juancho_resurreccion.png",
    "contenido_redes/posts_periodicos/spooky_post01_juancho_resurreccion_story.png",
    "contenido_redes/posts_periodicos/spooky_post02_mapache_freddy_crunch.png",
    "contenido_redes/posts_periodicos/spooky_post02_mapache_freddy_crunch_story.png",
    "contenido_redes/posts_periodicos/spooky_post03_ovni_ultratumba.png",
    "contenido_redes/posts_periodicos/spooky_post03_ovni_ultratumba_story.png",
    "contenido_redes/posts_periodicos/spooky_post04_tridente_spooky_pack.png",
    "contenido_redes/posts_periodicos/spooky_post04_tridente_spooky_pack_story.png"
)

foreach ($poster in $expectedPosters) {
    $foundInDom = $liveHtmlPanel.Contains($poster)
    Assert-Condition $foundInDom "Poster asset '$poster' referenced in live DOM" "Poster asset '$poster' NOT referenced in live DOM"
}

# Spooky Stickers
$expectedStickers = @(
    "sticker_spooky_juancho_jason.png",
    "sticker_spooky_mapache_freddy.png",
    "sticker_spooky_ovni_muertos.png"
)

foreach ($sticker in $expectedStickers) {
    $foundInDom = $liveHtmlPanel.Contains($sticker)
    Assert-Condition $foundInDom "Sticker asset '$sticker' referenced in live DOM" "Sticker asset '$sticker' NOT referenced in live DOM"
}

# 1-Click Copy Buttons & Target Pre Elements
$copyTargets = @(
    "caption-spooky-video",
    "caption-spooky-01",
    "caption-spooky-02",
    "caption-spooky-03",
    "caption-spooky-04",
    "caption-spooky-sticker01",
    "caption-spooky-sticker02",
    "caption-spooky-sticker03"
)

foreach ($target in $copyTargets) {
    $hasPre = $liveHtmlPanel.Contains("id=`"$target`"")
    $hasBtn = $liveHtmlPanel -match ('onclick=["'']copyCaptionFromElement\([''"]' + [regex]::Escape($target) + '[''"],\s*this\)["'']')
    Assert-Condition ($hasPre -and $hasBtn) "Copy target '$target' has both <pre id> and copy button" "Copy target '$target' incomplete (hasPre=$hasPre, hasBtn=$hasBtn)"
}

# Download buttons in Spooky cards
$downloadMatches = [regex]::Matches($liveHtmlPanel, 'download=["''][^"'']*spooky[^"'']*["'']')
Assert-Condition ($downloadMatches.Count -ge 8) "Found $($downloadMatches.Count) download links with 'spooky' in filename" "Expected >= 8 spooky download links, found $($downloadMatches.Count)"

# -------------------------------------------------------------
# 4. LIVE RESOURCE ACCESSIBILITY ON GITHUB PAGES (HTTP 200/206)
# -------------------------------------------------------------
Write-Host "`n4. AUDITING LIVE ASSET ACCESSIBILITY OVER HTTP..."

$liveAssetsToCheck = @(
    "https://lagarzaaguachilera.github.io/VIDEOS/promo_halloween_zombies_crudos.mp4",
    "https://lagarzaaguachilera.github.io/contenido_redes/posts_periodicos/spooky_post01_juancho_resurreccion.png",
    "https://lagarzaaguachilera.github.io/contenido_redes/posts_periodicos/spooky_post02_mapache_freddy_crunch.png",
    "https://lagarzaaguachilera.github.io/contenido_redes/posts_periodicos/spooky_post03_ovni_ultratumba.png",
    "https://lagarzaaguachilera.github.io/contenido_redes/posts_periodicos/spooky_post04_tridente_spooky_pack.png",
    "https://lagarzaaguachilera.github.io/sticker_spooky_juancho_jason.png",
    "https://lagarzaaguachilera.github.io/sticker_spooky_mapache_freddy.png",
    "https://lagarzaaguachilera.github.io/sticker_spooky_ovni_muertos.png",
    "https://lagarzaaguachilera.github.io/paquete_redes_la_garza.zip"
)

foreach ($assetUrl in $liveAssetsToCheck) {
    try {
        $req = [System.Net.HttpWebRequest]::Create($assetUrl)
        $req.Method = "HEAD"
        $req.Timeout = 15000
        $resp = $req.GetResponse()
        $cCode = [int]$resp.StatusCode
        $cLen = [int64]$resp.ContentLength
        $resp.Close()
        Assert-Condition ($cCode -eq 200 -and $cLen -gt 1000) "Live Asset: $(Split-Path $assetUrl -Leaf) -> HTTP $cCode ($([math]::Round($cLen/1KB, 1)) KB)" "Live Asset $(Split-Path $assetUrl -Leaf) failed: HTTP $cCode, Len=$cLen"
    } catch {
        Assert-Condition $false "" "Live Asset $(Split-Path $assetUrl -Leaf) unreachable: $($_.Exception.Message)"
    }
}

# -------------------------------------------------------------
# 5. BRAND SHIELDING & FORBIDDEN TERMS ON LIVE DOM
# -------------------------------------------------------------
Write-Host "`n5. AUDITING BRAND SHIELDING & ZERO FORBIDDEN TERMS..."

$forbiddenTerms = @("dark kitchen", "caldo por separado", "jumbo", "tostitos redondos", "Rosa 210")

foreach ($term in $forbiddenTerms) {
    $idxCount = ([regex]::Matches($liveHtmlIndex, [regex]::Escape($term), [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)).Count
    Assert-Condition ($idxCount -eq 0) "index.html has 0 mentions of '$term'" "index.html contains $idxCount mentions of '$term'"
    
    $pnlCount = ([regex]::Matches($liveHtmlPanel, [regex]::Escape($term), [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)).Count
    Assert-Condition ($pnlCount -eq 0) "panel_control.html has 0 mentions of '$term'" "panel_control.html contains $pnlCount mentions of '$term'"
}

# Required brand promises
$officialLocation = "Colonia Flores, Tampico, Tamaulipas"
Assert-Condition ($liveHtmlIndex.Contains($officialLocation)) "index.html contains official location: '$officialLocation'" "index.html missing official location"
Assert-Condition ($liveHtmlPanel.Contains($officialLocation)) "panel_control.html contains official location: '$officialLocation'" "panel_control.html missing official location"

$officialPrice = "$170"
Assert-Condition ($liveHtmlIndex.Contains($officialPrice)) "index.html contains official price: '$officialPrice'" "index.html missing official price"
Assert-Condition ($liveHtmlPanel.Contains($officialPrice)) "panel_control.html contains official price: '$officialPrice'" "panel_control.html missing official price"

Write-Host "`n================================================================="
if ($suiteFailures -eq 0) {
    Write-Host "SUITE COMPLETED: 100% OF EMPIRICAL ADVERSARIAL CHECKS PASSED!" -ForegroundColor Green
    Write-Host "Sello: ✅ Auditado y aprobado por Control de Calidad: Cumple con los estándares de La Garza Aguachilera" -ForegroundColor Cyan
} else {
    Write-Host "SUITE COMPLETED WITH $suiteFailures FAILURE(S)!" -ForegroundColor Red
}
Write-Host "================================================================="

exit $suiteFailures
