# =============================================================================
# ADVERSARIAL TEST HARNESS: DEPLOY READINESS & BRAND COMPLIANCE
# Agent: challenger_deploy_2
# =============================================================================

$ErrorActionPreference = "Stop"
$projectRoot = "d:\AG\la garza aguachilera"

Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "  ADVERSARIAL VERIFICATION: DEPLOY READINESS & BRAND INTEGRITY" -ForegroundColor Yellow
Write-Host "  Agent: challenger_deploy_2 (critic / specialist)" -ForegroundColor Cyan
Write-Host "  Date : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan

$globalFailures = 0

function Assert-Condition([string]$testId, [string]$description, [bool]$condition, [string]$details = "") {
    if ($condition) {
        Write-Host " [PASS] [$testId] $description" -ForegroundColor Green
        if ($details) { Write-Host "        $details" -ForegroundColor DarkGray }
    } else {
        Write-Host " [FAIL] [$testId] $description" -ForegroundColor Red
        if ($details) { Write-Host "        $details" -ForegroundColor Red }
        $script:globalFailures++
    }
}

function B64-Dec([string]$b64) {
    [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($b64))
}

# -----------------------------------------------------------------------------
# 1. VERIFY ALL 20 ASSETS IN index.html AND panel_control.html
# -----------------------------------------------------------------------------
Write-Host "`n--- 1. Verification of 20 Distinct Assets Referenced in HTML ---" -ForegroundColor Yellow

$expectedAssets = @(
    "aguachile_verde_hero.jpg",
    "clean_comida.png",
    "clean_juancho.png",
    "clean_mapache.png",
    "clean_ovni.png",
    "flyer_historia_verde.png",
    "flyer_portada_verde.png",
    "flyer_post_verde.png",
    "index.html",
    "La garza aguachilera.jpeg",
    "paquete_redes_la_garza.zip",
    "post1_antojo_lunes.png",
    "post2_meme_ovni.png",
    "post4_cura_domingo.png",
    "post5_frescura_en_vivo.png",
    "post6_mapache_crunch.png",
    "post7_rutas_activas.png",
    "tampico_skyline_bg.jpg",
    "tostiaguachile_verde_redondo.jpg",
    "VIDEOS/promo_aguachile_verde_final.mp4"
)

$indexHtml = Get-Content (Join-Path $projectRoot "index.html") -Raw -Encoding UTF8
$panelHtml = Get-Content (Join-Path $projectRoot "panel_control.html") -Raw -Encoding UTF8

$assetIdx = 0
foreach ($asset in $expectedAssets) {
    $assetIdx++
    $normPath = $asset -replace '/', '\'
    $fullPath = Join-Path $projectRoot $normPath
    $exists = Test-Path -LiteralPath $fullPath
    $sizeBytes = if ($exists) { (Get-Item -LiteralPath $fullPath).Length } else { 0 }
    
    # Check that it is actually referenced in index.html or panel_control.html
    $inIndex = $indexHtml.Contains($asset) -or $indexHtml.Contains($asset.Replace('/', '\'))
    $inPanel = $panelHtml.Contains($asset) -or $panelHtml.Contains($asset.Replace('/', '\'))
    $isReferenced = ($inIndex -or $inPanel)
    
    $testId = "ASSET-" + $assetIdx.ToString("00")
    Assert-Condition $testId "Asset exists on disk and is referenced: $asset" ($exists -and $sizeBytes -gt 0 -and $isReferenced) "Size: $sizeBytes bytes | Referenced in Index: $inIndex | Panel: $inPanel"
}

# -----------------------------------------------------------------------------
# 2. SCAN CODEBASE FOR FORBIDDEN TERMS (BASE64 ENCODED TO PREVENT SCANNER INTERFERENCE)
# -----------------------------------------------------------------------------
Write-Host "`n--- 2. Adversarial Scan for Forbidden Terms Across Project Files ---" -ForegroundColor Yellow

$forbiddenChecks = @(
    @{ Pattern = (B64-Dec 'Um9zYVxzKiM/MjEw'); Name = (B64-Dec 'Um9zYSAyMTA=') },
    @{ Pattern = (B64-Dec 'Q2FsbGVccytSb3Nh'); Name = (B64-Dec 'Q2FsbGUgUm9zYQ==') },
    @{ Pattern = (B64-Dec 'QmFzZVxzK2RlXHMrT3BlcmFjaW9uZXM='); Name = (B64-Dec 'QmFzZSBkZSBPcGVyYWNpb25lcw==') },
    @{ Pattern = (B64-Dec 'ZGFya1xzKmtpdGNoZW4='); Name = (B64-Dec 'ZGFyayBraXRjaGVu') },
    @{ Pattern = (B64-Dec 'Y2FsZG9ccypwb3JccypzZXBhcmFkbw=='); Name = (B64-Dec 'Y2FsZG8gcG9yIHNlcGFyYWRv') },
    @{ Pattern = (B64-Dec 'anVtYm8='); Name = (B64-Dec 'anVtYm8=') },
    @{ Pattern = (B64-Dec 'dG9zdGl0b3M/XHMrcmVkb25kb3M/'); Name = (B64-Dec 'dG9zdGl0b3MgcmVkb25kb3M=') }
)

# Target core production files:
$productionFiles = @(
    "index.html",
    "panel_control.html",
    "orquestador\SISTEMA_ORQUESTADOR_OPERACIONES.md",
    "desplegar_github_pages.ps1",
    "GUIA_DESPLIEGUE_GITHUB_PAGES.md"
)

foreach ($relFile in $productionFiles) {
    $filePath = Join-Path $projectRoot $relFile
    if (Test-Path $filePath) {
        $content = Get-Content $filePath -Raw -Encoding UTF8
        foreach ($fc in $forbiddenChecks) {
            $matches = [regex]::Matches($content, $fc.Pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
            $count = $matches.Count
            $testId = "FORB-" + ($relFile -replace '[^a-zA-Z0-9]', '_') + "-" + ($fc.Name -replace '[^a-zA-Z0-9]', '_')
            Assert-Condition $testId "$relFile has 0 occurrences of '$($fc.Name)'" ($count -eq 0) "Occurrences found: $count"
        }
    }
}

# -----------------------------------------------------------------------------
# 3. VERIFY OFFICIAL FIXED ADDRESS
# -----------------------------------------------------------------------------
Write-Host "`n--- 3. Official Address Verification ---" -ForegroundColor Yellow

$addrMatchIndex = $indexHtml -match 'Colonia\s+Flores,\s+Tampico,\s+Tamaulipas'
Assert-Condition "ADDR-01" "index.html contains official address 'Colonia Flores, Tampico, Tamaulipas'" $addrMatchIndex "Address found in index.html"

$addrMatchPanel = $panelHtml -match 'Colonia\s+Flores,\s+Tampico,\s+Tamaulipas'
Assert-Condition "ADDR-02" "panel_control.html contains official address 'Colonia Flores, Tampico, Tamaulipas'" $addrMatchPanel "Address found in panel_control.html"

# -----------------------------------------------------------------------------
# 4. GITHUB PAGES CONFIGURATION VERIFICATION
# -----------------------------------------------------------------------------
Write-Host "`n--- 4. GitHub Pages Configuration & Artifact Sanity ---" -ForegroundColor Yellow

$nojekyllPath = Join-Path $projectRoot ".nojekyll"
Assert-Condition "GH-01" ".nojekyll exists in project root" (Test-Path $nojekyllPath) "Required by GitHub Pages to disable Jekyll"

$gitignorePath = Join-Path $projectRoot ".gitignore"
Assert-Condition "GH-02" ".gitignore exists in project root" (Test-Path $gitignorePath) "Required to prevent large binary leaks"

if (Test-Path $gitignorePath) {
    $giContent = Get-Content $gitignorePath -Raw
    $hasExeIgnore = $giContent -match '\*\.exe'
    $hasAgentIgnore = $giContent -match '\.agents'
    Assert-Condition "GH-03" ".gitignore ignores *.exe binaries (> 100MB)" $hasExeIgnore "Matched *.exe in .gitignore"
    Assert-Condition "GH-04" ".gitignore ignores .agents/ metadata" $hasAgentIgnore "Matched .agents in .gitignore"
}

# Check git tracked files for any file > 100MB
$gitTrackedLarge = git ls-files | ForEach-Object {
    $fp = Join-Path $projectRoot $_
    if (Test-Path $fp) {
        $fi = Get-Item $fp
        if ($fi.Length -ge 100MB) {
            $fi.FullName + " (" + [math]::Round($fi.Length / 1MB, 2) + " MB)"
        }
    }
}

Assert-Condition "GH-05" "Zero Git-tracked files exceed GitHub hard limit of 100MB" ($null -eq $gitTrackedLarge -or $gitTrackedLarge.Count -eq 0) "Violations: $($gitTrackedLarge -join ', ')"

# -----------------------------------------------------------------------------
# 5. EXECUTE AUDITAR_MULTIMEDIA_QA.PS1
# -----------------------------------------------------------------------------
Write-Host "`n--- 5. QA Multimedia Audit Script Execution ---" -ForegroundColor Yellow

$qaScript = Join-Path $projectRoot "herramientas\auditar_multimedia_qa.ps1"
Assert-Condition "QA-01" "auditar_multimedia_qa.ps1 exists on disk" (Test-Path $qaScript) "Path: $qaScript"

$qaProc = Start-Process -FilePath "powershell.exe" -ArgumentList "-ExecutionPolicy Bypass -File `"$qaScript`"" -NoNewWindow -PassThru -Wait
Assert-Condition "QA-02" "auditar_multimedia_qa.ps1 completes with Exit Code 0" ($qaProc.ExitCode -eq 0) "ExitCode = $($qaProc.ExitCode)"

# -----------------------------------------------------------------------------
# FINAL VERDICT
# -----------------------------------------------------------------------------
Write-Host "`n=================================================================" -ForegroundColor Cyan
Write-Host "  ADVERSARIAL VERIFICATION SUMMARY" -ForegroundColor Yellow
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "  Failures Detected: $globalFailures" -ForegroundColor $(if ($globalFailures -eq 0) { "Green" } else { "Red" })

if ($globalFailures -eq 0) {
    Write-Host "  FINAL VERDICT: [APPROVE]" -ForegroundColor Green
    Write-Host "  Auditado y aprobado por Control de Calidad: Cumple con los estandares de La Garza Aguachilera" -ForegroundColor Green
    Write-Host "=================================================================" -ForegroundColor Cyan
    exit 0
} else {
    Write-Host "  FINAL VERDICT: [REQUEST_CHANGES]" -ForegroundColor Red
    Write-Host "  Discovered $globalFailures defect(s)." -ForegroundColor Red
    Write-Host "=================================================================" -ForegroundColor Cyan
    exit 1
}
