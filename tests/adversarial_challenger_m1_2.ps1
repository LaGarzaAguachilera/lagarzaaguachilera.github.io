# ==============================================================================
# tests/adversarial_challenger_m1_2.ps1
# EMPIRICAL ADVERSARIAL CHALLENGER SUITE -- MILESTONE 1
# ==============================================================================
param(
    [string]$ProjectRoot = "d:\AG\la garza aguachilera"
)

Add-Type -AssemblyName System.Drawing

$testCount = 0
$passCount = 0
$failCount = 0
$failures = @()

function Assert-Condition([bool]$condition, [string]$testName, [string]$details = "") {
    $script:testCount++
    if ($condition) {
        $script:passCount++
        Write-Host "  [PASS] $testName" -ForegroundColor Green
    } else {
        $script:failCount++
        $msg = "  [FAIL] $testName ($details)"
        $script:failures += $msg
        Write-Host $msg -ForegroundColor Red
    }
}

function Safe-RemoveFile([string]$path) {
    if (Test-Path $path) {
        for ($i = 0; $i -lt 10; $i++) {
            try {
                Remove-Item -Path $path -Force -ErrorAction Stop
                return
            } catch {
                Start-Sleep -Milliseconds 150
            }
        }
    }
}

Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "  EMPIRICAL ADVERSARIAL CHALLENGER -- MILESTONE 1 VERIFICATION" -ForegroundColor Yellow
Write-Host "=================================================================" -ForegroundColor Cyan

# ------------------------------------------------------------------------------
# SUITE 1: 49 GRAPHIC IMAGES DECODING, INTEGRITY, DIMENSIONS & TIMESTAMPS
# ------------------------------------------------------------------------------
Write-Host "`n>>> SUITE 1: ADVERSARIAL VALIDATION OF 49 GRAPHIC IMAGES" -ForegroundColor Cyan

$targets = @(
    # 1 Cover
    @{ Name = "Cover Facebook Master"; Path = "$ProjectRoot\flyer_portada_verde.png"; ExpW = 1200; ExpH = 630 },
    # 2 Flyers
    @{ Name = "Flyer Post Feed Verde"; Path = "$ProjectRoot\flyer_post_verde.png"; ExpW = 1080; ExpH = 1080 },
    @{ Name = "Flyer Historia Verde"; Path = "$ProjectRoot\flyer_historia_verde.png"; ExpW = 1080; ExpH = 1920 },
    # 6 Periodic
    @{ Name = "Post 1 Antojo Lunes"; Path = "$ProjectRoot\contenido_redes\posts_periodicos\post1_antojo_lunes.png"; ExpW = 1080; ExpH = 1080 },
    @{ Name = "Post 2 Meme OVNI"; Path = "$ProjectRoot\contenido_redes\posts_periodicos\post2_meme_ovni.png"; ExpW = 1080; ExpH = 1080 },
    @{ Name = "Post 4 Cura Domingo"; Path = "$ProjectRoot\contenido_redes\posts_periodicos\post4_cura_domingo.png"; ExpW = 1080; ExpH = 1080 },
    @{ Name = "Post 5 Frescura en Vivo"; Path = "$ProjectRoot\contenido_redes\posts_periodicos\post5_frescura_en_vivo.png"; ExpW = 1080; ExpH = 1080 },
    @{ Name = "Post 6 Mapache Crunch"; Path = "$ProjectRoot\contenido_redes\posts_periodicos\post6_mapache_crunch.png"; ExpW = 1080; ExpH = 1080 },
    @{ Name = "Post 7 Rutas Activas"; Path = "$ProjectRoot\contenido_redes\posts_periodicos\post7_rutas_activas.png"; ExpW = 1080; ExpH = 1080 }
)

# 32 Monthly Catalog (Posts 01 to 16, Feed & Story)
$catalogSlugs = @(
    "post01_abduccion_miramar", "post02_juancho_laguna", "post03_mapache_escolleras", "post04_tridente_jaibo",
    "post05_ensamble_vivo", "post06_cadena_frio", "post07_camaron_mariposa", "post08_secreto_crunch",
    "post09_medicina_resaca", "post10_asmr_tostitos", "post11_oro_verde", "post12_ritual_dominical",
    "post13_hieleras_cargadas", "post14_zonas_horarios", "post15_alerta_cupos", "post16_comunidad_jaiba"
)
foreach ($slug in $catalogSlugs) {
    $targets += @{ Name = "$slug (Feed)"; Path = "$ProjectRoot\contenido_redes\posts_periodicos\$slug.png"; ExpW = 1080; ExpH = 1080 }
    $targets += @{ Name = "${slug}_story (Story)"; Path = "$ProjectRoot\contenido_redes\posts_periodicos\${slug}_story.png"; ExpW = 1080; ExpH = 1920 }
}

# 8 Spooky Halloween Campaign (Posts 01 to 04, Feed & Story)
$spookySlugs = @(
    "spooky_post01_juancho_resurreccion", "spooky_post02_mapache_freddy_crunch",
    "spooky_post03_ovni_ultratumba", "spooky_post04_tridente_spooky_pack"
)
foreach ($slug in $spookySlugs) {
    $targets += @{ Name = "$slug (Feed)"; Path = "$ProjectRoot\contenido_redes\posts_periodicos\$slug.png"; ExpW = 1080; ExpH = 1080 }
    $targets += @{ Name = "${slug}_story (Story)"; Path = "$ProjectRoot\contenido_redes\posts_periodicos\${slug}_story.png"; ExpW = 1080; ExpH = 1920 }
}

Assert-Condition ($targets.Count -eq 49) "Inventory Check: Target list contains exactly 49 images" "Found: $($targets.Count)"

$now = Get-Date
$pngGuid = [System.Drawing.Imaging.ImageFormat]::Png.Guid

foreach ($t in $targets) {
    $exists = Test-Path $t.Path
    Assert-Condition $exists "Image exists: $($t.Name)" "Path: $($t.Path)"
    if (-not $exists) { continue }

    $fi = Get-Item $t.Path
    $sizeBytes = $fi.Length
    $ageMinutes = ($now - $fi.LastWriteTime).TotalMinutes

    # Check size > 10KB
    Assert-Condition ($sizeBytes -gt 10240) "Non-trivial file size: $($t.Name)" "Size: $sizeBytes bytes"

    # Check timestamp recency (< 180 minutes)
    Assert-Condition ($ageMinutes -lt 180) "Recent timestamp (< 3 hours): $($t.Name)" "Age: $([math]::Round($ageMinutes, 1)) min ago"

    # Decode and check dimensions
    try {
        $img = [System.Drawing.Image]::FromFile($t.Path)
        $w = $img.Width
        $h = $img.Height
        $rawFmt = $img.RawFormat.Guid
        $img.Dispose()

        Assert-Condition ($w -eq $t.ExpW -and $h -eq $t.ExpH) "Dimensions match spec: $($t.Name)" "Actual: ${w}x${h}, Expected: $($t.ExpW)x$($t.ExpH)"
        Assert-Condition ($rawFmt -eq $pngGuid) "Valid PNG format: $($t.Name)" "GUID: $rawFmt"
    } catch {
        Assert-Condition $false "Failed to open/decode image: $($t.Name)" $_.Exception.Message
    }
}

# ------------------------------------------------------------------------------
# SUITE 2: ADVERSARIAL FAULT-INJECTION & MUTATION TESTING OF QA SCRIPT
# ------------------------------------------------------------------------------
Write-Host "`n>>> SUITE 2: ADVERSARIAL FAULT-INJECTION ON herramientas\auditar_multimedia_qa.ps1" -ForegroundColor Cyan

$qaScript = Join-Path $ProjectRoot "herramientas\auditar_multimedia_qa.ps1"

# 2.1 Baseline test (Must Pass with Exit Code 0)
$outBaseline = & powershell -NoProfile -ExecutionPolicy Bypass -File $qaScript 2>&1
$codeBaseline = $LASTEXITCODE
Assert-Condition ($codeBaseline -eq 0) "Baseline QA Run: Passes with exit code 0" "Exit code: $codeBaseline"

# 2.2 Fault Injection: Prohibited Price $170 in temporary text file
$dummyFile1 = Join-Path $ProjectRoot "contenido_redes\posts_periodicos\dummy_fault_test_170.txt"
"Oferta especial Tostiaguachile a solo `$170 MXN por bolsa" | Out-File -FilePath $dummyFile1 -Encoding UTF8
$outFault1 = & powershell -NoProfile -ExecutionPolicy Bypass -File $qaScript 2>&1
$codeFault1 = $LASTEXITCODE
Assert-Condition ($codeFault1 -ne 0) "Fault Injection 1 (`$170 MXN): Correctly rejected with non-zero exit code" "Exit code: $codeFault1"
$detectedFault1 = ($outFault1 | Out-String) -match "dummy_fault_test_170\.txt"
Assert-Condition $detectedFault1 "Fault Injection 1: Offending file explicitly cited in QA report"
Safe-RemoveFile $dummyFile1

# Verify recovery after cleanup
$outClean1 = & powershell -NoProfile -ExecutionPolicy Bypass -File $qaScript 2>&1
$codeClean1 = $LASTEXITCODE
Assert-Condition ($codeClean1 -eq 0) "Recovery 1: Returns to clean exit code 0 after mutation removal" "Exit code: $codeClean1"

# 2.3 Fault Injection: Prohibited Spoken Price "ciento setenta" in temporary markdown file
$dummyFile2 = Join-Path $ProjectRoot "contenido_redes\dummy_fault_ciento_setenta.md"
"# Antojo`nPide tu bolsa por solo ciento setenta pesos directo a WhatsApp" | Out-File -FilePath $dummyFile2 -Encoding UTF8
$outFault2 = & powershell -NoProfile -ExecutionPolicy Bypass -File $qaScript 2>&1
$codeFault2 = $LASTEXITCODE
Assert-Condition ($codeFault2 -ne 0) "Fault Injection 2 ('ciento setenta'): Correctly rejected with non-zero exit code" "Exit code: $codeFault2"
$detectedFault2 = ($outFault2 | Out-String) -match "dummy_fault_ciento_setenta\.md"
Assert-Condition $detectedFault2 "Fault Injection 2: Offending markdown cited in QA report"
Safe-RemoveFile $dummyFile2

# Verify recovery after cleanup
$outClean2 = & powershell -NoProfile -ExecutionPolicy Bypass -File $qaScript 2>&1
$codeClean2 = $LASTEXITCODE
Assert-Condition ($codeClean2 -eq 0) "Recovery 2: Returns to clean exit code 0 after mutation removal" "Exit code: $codeClean2"

# 2.4 Fault Injection: URL Encoded Prohibited Price "170%20"
$dummyFile3 = Join-Path $ProjectRoot "contenido_redes\dummy_fault_170_url.txt"
"https://wa.me/528332520988?text=Quiero%20mi%20bolsa%20de%20170%20pesos" | Out-File -FilePath $dummyFile3 -Encoding UTF8
$outFault3 = & powershell -NoProfile -ExecutionPolicy Bypass -File $qaScript 2>&1
$codeFault3 = $LASTEXITCODE
Assert-Condition ($codeFault3 -ne 0) "Fault Injection 3 ('170%20'): Correctly rejected with non-zero exit code" "Exit code: $codeFault3"
$detectedFault3 = ($outFault3 | Out-String) -match "dummy_fault_170_url\.txt"
Assert-Condition $detectedFault3 "Fault Injection 3: Offending URL pattern cited in QA report"
Safe-RemoveFile $dummyFile3

# Verify recovery after cleanup
$outClean3 = & powershell -NoProfile -ExecutionPolicy Bypass -File $qaScript 2>&1
$codeClean3 = $LASTEXITCODE
Assert-Condition ($codeClean3 -eq 0) "Recovery 3: Returns to clean exit code 0 after mutation removal" "Exit code: $codeClean3"

# 2.5 Fault Injection: Legacy Prohibited Term "Rosa 210"
$dummyFile4 = Join-Path $ProjectRoot "contenido_redes\dummy_fault_rosa210.txt"
"Ubicados en Rosa 210, Tampico" | Out-File -FilePath $dummyFile4 -Encoding UTF8
$outFault4 = & powershell -NoProfile -ExecutionPolicy Bypass -File $qaScript 2>&1
$codeFault4 = $LASTEXITCODE
Assert-Condition ($codeFault4 -ne 0) "Fault Injection 4 ('Rosa 210'): Correctly rejected with non-zero exit code" "Exit code: $codeFault4"
Safe-RemoveFile $dummyFile4

# Verify recovery after cleanup
$outClean4 = & powershell -NoProfile -ExecutionPolicy Bypass -File $qaScript 2>&1
$codeClean4 = $LASTEXITCODE
Assert-Condition ($codeClean4 -eq 0) "Recovery 4: Returns to clean exit code 0 after mutation removal" "Exit code: $codeClean4"

# ------------------------------------------------------------------------------
# SUITE 3: COMPREHENSIVE REPOSITORY PRICE INVARIANT AUDIT
# ------------------------------------------------------------------------------
Write-Host "`n>>> SUITE 3: REPOSITORY-WIDE PRICE INVARIANT AUDIT" -ForegroundColor Cyan

$forbiddenPatterns = @(
    '\$170',
    '170\s*MXN',
    '170\s*pesos',
    '170%20',
    'ciento\s*setenta'
)

$scannableFiles = Get-ChildItem -Path $ProjectRoot -Recurse -Include *.html, *.ps1, *.md, *.txt | Where-Object {
    $_.FullName -notmatch '\\\.agents\\' -and
    $_.FullName -notmatch '\\\.git\\' -and
    $_.FullName -notmatch '\\tests\\' -and
    $_.Name -ne 'auditar_multimedia_qa.ps1' -and
    $_.Name -ne 'proposed_auditar_multimedia_qa.ps1' -and
    $_.Name -ne 'TEST_INFRA.md' -and
    $_.Name -ne 'TEST_READY.md'
}

$residual170Matches = @()
foreach ($file in $scannableFiles) {
    $m = Select-String -Path $file.FullName -Pattern $forbiddenPatterns
    if ($m) {
        $residual170Matches += $m
    }
}

Assert-Condition ($residual170Matches.Count -eq 0) "Zero residual 170 occurrences in active production & content files" "Found: $($residual170Matches.Count)"
if ($residual170Matches.Count -gt 0) {
    foreach ($m in $residual170Matches) {
        Write-Host "   -> $($m.Path):$($m.LineNumber): $($m.Line.Trim())" -ForegroundColor Red
    }
}

# Positive verification of $150
$indexContent = Get-Content (Join-Path $ProjectRoot "index.html") -Raw -Encoding UTF8
$index150Matches = [regex]::Matches($indexContent, '(\$150|150\s*MXN|150\s*pesos|150%20pesos)')
Assert-Condition ($index150Matches.Count -ge 11) "index.html contains expected `$150 pricing instances (>= 11)" "Count: $($index150Matches.Count)"

$panelContent = Get-Content (Join-Path $ProjectRoot "panel_control.html") -Raw -Encoding UTF8
$panel150Matches = [regex]::Matches($panelContent, '(\$150|150\s*MXN|150\s*pesos|150%20pesos)')
Assert-Condition ($panel150Matches.Count -ge 73) "panel_control.html contains expected `$150 pricing instances (>= 73)" "Count: $($panel150Matches.Count)"

$panelCientoCincuenta = [regex]::Matches($panelContent, 'ciento\s*cincuenta')
Assert-Condition ($panelCientoCincuenta.Count -ge 1) "panel_control.html contains verbal 'ciento cincuenta'" "Count: $($panelCientoCincuenta.Count)"

# Check UTF-8 BOM absence
$indexBytes = [System.IO.File]::ReadAllBytes((Join-Path $ProjectRoot "index.html"))[0..2]
$indexNoBOM = ($indexBytes[0] -eq 0x3C -and $indexBytes[1] -eq 0x21 -and $indexBytes[2] -eq 0x44)
Assert-Condition $indexNoBOM "index.html is clean UTF-8 without BOM" "Bytes: $($indexBytes -join ' ')"

$panelBytes = [System.IO.File]::ReadAllBytes((Join-Path $ProjectRoot "panel_control.html"))[0..2]
$panelNoBOM = ($panelBytes[0] -eq 0x3C -and $panelBytes[1] -eq 0x21 -and $panelBytes[2] -eq 0x44)
Assert-Condition $panelNoBOM "panel_control.html is clean UTF-8 without BOM" "Bytes: $($panelBytes -join ' ')"

# ------------------------------------------------------------------------------
# SUMMARY & EXIT CODE
# ------------------------------------------------------------------------------
Write-Host "`n=================================================================" -ForegroundColor Cyan
Write-Host "  ADVERSARIAL CHALLENGER VERIFICATION SUMMARY" -ForegroundColor Yellow
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "  Total Tests Executed : $testCount"
Write-Host "  Tests Passed         : $passCount" -ForegroundColor Green
Write-Host "  Tests Failed         : $failCount" -ForegroundColor $(if ($failCount -eq 0) { "Green" } else { "Red" })

if ($failCount -eq 0) {
    Write-Host "`n  VERDICT: APPROVE -- Milestone 1 is rock-solid and verified." -ForegroundColor Green
    exit 0
} else {
    Write-Host "`n  VERDICT: REQUEST_CHANGES -- $failCount failures detected." -ForegroundColor Red
    exit 1
}
