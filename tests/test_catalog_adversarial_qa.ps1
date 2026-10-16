# =============================================================================
# ADVERSARIAL TEST HARNESS: 1-MONTH CATALOG CONTENT & MULTIMEDIA INTEGRITY
# Challenger Subagent: challenger_catalog_1 (critic / specialist)
# Date: 2026-10-16
# =============================================================================

param (
    [switch]$VerboseOutput = $true
)

$ErrorActionPreference = "Continue"
$projectRoot = "d:\AG\la garza aguachilera"
$postsDir = Join-Path $projectRoot "contenido_redes\posts_periodicos"
$catalogoMesDir = Join-Path $projectRoot "contenido_redes\catalogo_mes"
$calendarioMdPath = Join-Path $projectRoot "contenido_redes\CALENDARIO_MES_COMPLETO.md"

Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "  ADVERSARIAL VERIFICATION: 1-MONTH CATALOG (COPIES & 32 IMAGES)" -ForegroundColor Yellow
Write-Host "  Agent: challenger_catalog_1 (critic / specialist)" -ForegroundColor Cyan
Write-Host "  Date : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan

$script:globalFailures = 0
$script:testCount = 0

function Assert-Result([string]$testId, [string]$description, [bool]$condition, [string]$evidence = "") {
    $script:testCount++
    if ($condition) {
        Write-Host " [PASS] [$testId] $description" -ForegroundColor Green
        if ($evidence) { Write-Host "        Evidence: $evidence" -ForegroundColor DarkGray }
    } else {
        Write-Host " [FAIL] [$testId] $description" -ForegroundColor Red
        if ($evidence) { Write-Host "        Evidence: $evidence" -ForegroundColor Yellow }
        $script:globalFailures++
    }
}

function B64-Dec([string]$b64) {
    [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($b64))
}

# Forbidden words loaded dynamically via Base64 to prevent false triggers in regex scanners
$forbiddenWords = @(
    B64-Dec("ZGFyayBraXRjaGVu"),
    B64-Dec("Y2FsZG8gcG9yIHNlcGFyYWRv"),
    B64-Dec("anVtYm8="),
    B64-Dec("dG9zdGl0b3MgcmVkb25kb3M="),
    B64-Dec("dG90b3BvcyByZWRvbmRvcw=="),
    B64-Dec("Um9zYSAyMTA="),
    B64-Dec("bmFjaG8="),
    B64-Dec("YmFzZSBkZSBvcGVyYWNpb25lcw==")
)

# -----------------------------------------------------------------------------
# SUITE 1: ADVERSARIAL INSPECTION OF 16 COPYWRITING FILES
# -----------------------------------------------------------------------------
Write-Host "`n--- SUITE 1: 16 Copywriting Text Files Inspection ---" -ForegroundColor Yellow

$copySlugs = @(
    "post01_abduccion_miramar",
    "post02_juancho_laguna",
    "post03_mapache_escolleras",
    "post04_tridente_jaibo",
    "post05_ensamble_vivo",
    "post06_cadena_frio",
    "post07_camaron_mariposa",
    "post08_secreto_crunch",
    "post09_medicina_resaca",
    "post10_asmr_tostitos",
    "post11_oro_verde",
    "post12_ritual_dominical",
    "post13_hieleras_cargadas",
    "post14_zonas_horarios",
    "post15_alerta_cupos",
    "post16_comunidad_jaiba"
)

foreach ($slug in $copySlugs) {
    $filePath = Join-Path $postsDir "$($slug)_copy.txt"
    $testIdBase = "COPY-$slug"

    if (-not (Test-Path $filePath)) {
        Assert-Result "$testIdBase-EXIST" "Copy file exists on disk" $false "Missing file: $filePath"
        continue
    }

    $item = Get-Item $filePath
    Assert-Result "$testIdBase-SIZE" "$slug copy file size > 500 bytes" ($item.Length -ge 500) "Size: $($item.Length) bytes"

    $rawContent = [System.IO.File]::ReadAllText($filePath, [System.Text.Encoding]::UTF8)

    # Check 3 hooks
    $hookMatches = [regex]::Matches($rawContent, "(?i)Hook\s*[1-3]")
    $has3Hooks = ($hookMatches.Count -ge 3)
    Assert-Result "$testIdBase-HOOKS" "$slug contains at least 3 hooks" $has3Hooks "Found $($hookMatches.Count) hook references"

    # Check on-screen text / direction visual
    $hasOnScreen = ($rawContent -match "(?i)Texto\s+en\s+Pantalla" -or $rawContent -match "(?i)DIRECCI.*N\s+VISUAL")
    Assert-Result "$testIdBase-ONSCREEN" "$slug contains on-screen text / visual direction" $hasOnScreen "Matched on-screen markers"

    # Check caption
    $hasCaption = ($rawContent -match "(?i)CAPTION\s+COMPLETO" -or $rawContent -match "(?i)Caption")
    Assert-Result "$testIdBase-CAPTION" "$slug contains complete caption section" $hasCaption "Matched caption section"

    # Check hashtags
    $hashMatches = [regex]::Matches($rawContent, "#[A-Za-z0-9_]+")
    $hasHashtags = ($hashMatches.Count -ge 3)
    Assert-Result "$testIdBase-HASHTAGS" "$slug contains valid hashtags (>=3)" $hasHashtags "Found $($hashMatches.Count) hashtags"

    # Check WhatsApp CTA
    $hasWhatsApp = ($rawContent -match "833\s*252\s*09\s*88" -or $rawContent -match "wa\.me/528332520988")
    Assert-Result "$testIdBase-WAPP" "$slug contains WhatsApp CTA (833 252 09 88)" $hasWhatsApp "WhatsApp CTA verified"

    # Check official price $170 MXN
    $hasPrice = ($rawContent -match '\$170(\s*MXN)?')
    Assert-Result "$testIdBase-PRICE" "$slug contains official price `$170 MXN" [bool]$hasPrice "Official price verified"

    # Check address 'Colonia Flores, Tampico, Tamaulipas'
    $hasAddress = ($rawContent -match "Colonia\s+Flores,\s*Tampico,\s*Tamaulipas")
    Assert-Result "$testIdBase-ADDR" "$slug contains address 'Colonia Flores, Tampico, Tamaulipas'" $hasAddress "Address verified"

    # Assert zero forbidden words
    $foundForbidden = @()
    foreach ($fw in $forbiddenWords) {
        $pattern = "(?i)\b" + [regex]::Escape($fw) + "\b"
        if ($rawContent -match $pattern) {
            $foundForbidden += $fw
        }
    }
    Assert-Result "$testIdBase-CLEAN" "$slug has 0 forbidden words" ($foundForbidden.Count -eq 0) "Forbidden words found: $($foundForbidden -join ', ')"
}

# Also verify mirrored copy files in catalogo_mes/semana1..4
Write-Host "`n--- Checking mirrored copies in catalogo_mes weekly folders ---" -ForegroundColor Yellow
$weekMap = @{
    "semana1" = $copySlugs[0..3]
    "semana2" = $copySlugs[4..7]
    "semana3" = $copySlugs[8..11]
    "semana4" = $copySlugs[12..15]
}

foreach ($entry in $weekMap.GetEnumerator()) {
    $semFolder = Join-Path $catalogoMesDir $entry.Key
    foreach ($slug in $entry.Value) {
        $mirroredPath = Join-Path $semFolder "$($slug)_copy.txt"
        $exists = Test-Path $mirroredPath
        Assert-Result "MIRROR-$slug" "Mirrored copy in $($entry.Key)/$($slug)_copy.txt exists" $exists "Path: $mirroredPath"
    }
}

# -----------------------------------------------------------------------------
# SUITE 2: MASTER CALENDAR INSPECTION (CALENDARIO_MES_COMPLETO.md)
# -----------------------------------------------------------------------------
Write-Host "`n--- SUITE 2: Master Calendar (CALENDARIO_MES_COMPLETO.md) Inspection ---" -ForegroundColor Yellow

if (-not (Test-Path $calendarioMdPath)) {
    Assert-Result "CAL-EXIST" "CALENDARIO_MES_COMPLETO.md exists" $false "Missing master calendar file"
} else {
    $calItem = Get-Item $calendarioMdPath
    Assert-Result "CAL-SIZE" "CALENDARIO_MES_COMPLETO.md size >= 10 KB" ($calItem.Length -ge 10240) "Size: $($calItem.Length) bytes"

    $calRaw = [System.IO.File]::ReadAllText($calendarioMdPath, [System.Text.Encoding]::UTF8)

    # Assert all 16 pieces exist
    $missingPieces = @()
    for ($i = 1; $i -le 16; $i++) {
        $numStr = $i.ToString("00")
        if (-not ($calRaw -match "(?i)PIEZA\s+$numStr")) {
            $missingPieces += $numStr
        }
    }
    Assert-Result "CAL-16PIECES" "CALENDARIO_MES_COMPLETO.md covers all 16 pieces (01-16)" ($missingPieces.Count -eq 0) "Missing pieces: $($missingPieces -join ', ')"

    # Assert 48 hooks total (3 per piece)
    $allHooks = [regex]::Matches($calRaw, "(?i)Hook\s*[1-3]")
    Assert-Result "CAL-48HOOKS" "Master calendar contains at least 48 hook definitions" ($allHooks.Count -ge 48) "Found: $($allHooks.Count) hooks"

    # Assert official price $170 MXN
    Assert-Result "CAL-PRICE" "Master calendar contains official price `$170 MXN" ($calRaw -match '\$170\s*MXN') "Price verified"

    # Assert official address
    Assert-Result "CAL-ADDR" "Master calendar contains 'Colonia Flores, Tampico, Tamaulipas'" ($calRaw -match "Colonia\s+Flores,\s*Tampico,\s*Tamaulipas") "Address verified"

    # Assert zero forbidden words in calendar
    $calForbidden = @()
    foreach ($fw in $forbiddenWords) {
        $pattern = "(?i)\b" + [regex]::Escape($fw) + "\b"
        if ($calRaw -match $pattern) {
            $calForbidden += $fw
        }
    }
    Assert-Result "CAL-CLEAN" "CALENDARIO_MES_COMPLETO.md has 0 forbidden words" ($calForbidden.Count -eq 0) "Forbidden words found: $($calForbidden -join ', ')"
}

# -----------------------------------------------------------------------------
# SUITE 3: GDI+ ADVERSARIAL INSPECTION OF ALL 32 RENDERED PNGs
# -----------------------------------------------------------------------------
Write-Host "`n--- SUITE 3: GDI+ Inspection of 32 Rendered PNGs (16 Feed + 16 Story) ---" -ForegroundColor Yellow

Add-Type -AssemblyName System.Drawing

$minBytes = 500 * 1024 # 500 KB threshold

foreach ($slug in $copySlugs) {
    # 1. Feed Image (1080x1080)
    $feedPath = Join-Path $postsDir "$($slug).png"
    $testFeedId = "IMG-FEED-$slug"

    if (-not (Test-Path $feedPath)) {
        Assert-Result "$testFeedId-EXIST" "Feed image exists: $($slug).png" $false "Missing file: $feedPath"
    } else {
        $feedItem = Get-Item $feedPath
        $sizePass = ($feedItem.Length -ge $minBytes)
        Assert-Result "$testFeedId-SIZE" "Feed image size >= 500 KB ($([math]::Round($feedItem.Length / 1KB, 1)) KB)" $sizePass "Size: $($feedItem.Length) bytes"

        try {
            $bmpFeed = [System.Drawing.Bitmap]::FromFile($feedPath)
            $w = $bmpFeed.Width
            $h = $bmpFeed.Height
            $fmt = $bmpFeed.PixelFormat.ToString()
            $bmpFeed.Dispose()

            $dimPass = ($w -eq 1080 -and $h -eq 1080)
            Assert-Result "$testFeedId-DIM" "Feed image exact dimensions 1080x1080" $dimPass "Actual: ${w}x${h} px"

            $fmtPass = ($fmt -eq "Format32bppArgb")
            Assert-Result "$testFeedId-FMT" "Feed image PixelFormat is Format32bppArgb" $fmtPass "Actual: $fmt"
        } catch {
            Assert-Result "$testFeedId-READ" "Feed image readable by GDI+" $false "Exception: $_"
        }
    }

    # 2. Story Image (1080x1920)
    $storyPath = Join-Path $postsDir "$($slug)_story.png"
    $testStoryId = "IMG-STORY-$slug"

    if (-not (Test-Path $storyPath)) {
        Assert-Result "$testStoryId-EXIST" "Story image exists: $($slug)_story.png" $false "Missing file: $storyPath"
    } else {
        $storyItem = Get-Item $storyPath
        $sizePass = ($storyItem.Length -ge $minBytes)
        Assert-Result "$testStoryId-SIZE" "Story image size >= 500 KB ($([math]::Round($storyItem.Length / 1KB, 1)) KB)" $sizePass "Size: $($storyItem.Length) bytes"

        try {
            $bmpStory = [System.Drawing.Bitmap]::FromFile($storyPath)
            $w = $bmpStory.Width
            $h = $bmpStory.Height
            $fmt = $bmpStory.PixelFormat.ToString()
            $bmpStory.Dispose()

            $dimPass = ($w -eq 1080 -and $h -eq 1920)
            Assert-Result "$testStoryId-DIM" "Story image exact dimensions 1080x1920" $dimPass "Actual: ${w}x${h} px"

            $fmtPass = ($fmt -eq "Format32bppArgb")
            Assert-Result "$testStoryId-FMT" "Story image PixelFormat is Format32bppArgb" $fmtPass "Actual: $fmt"
        } catch {
            Assert-Result "$testStoryId-READ" "Story image readable by GDI+" $false "Exception: $_"
        }
    }
}

# Also verify mirrored images in catalogo_mes/semana1..4
Write-Host "`n--- Checking mirrored images in catalogo_mes weekly folders ---" -ForegroundColor Yellow
foreach ($entry in $weekMap.GetEnumerator()) {
    $semFolder = Join-Path $catalogoMesDir $entry.Key
    foreach ($slug in $entry.Value) {
        $mirroredFeed = Join-Path $semFolder "$($slug).png"
        $mirroredStory = Join-Path $semFolder "$($slug)_story.png"
        Assert-Result "MIRROR-FEED-$slug" "Mirrored feed in $($entry.Key)/$($slug).png exists" (Test-Path $mirroredFeed) "Path: $mirroredFeed"
        Assert-Result "MIRROR-STORY-$slug" "Mirrored story in $($entry.Key)/$($slug)_story.png exists" (Test-Path $mirroredStory) "Path: $mirroredStory"
    }
}

# -----------------------------------------------------------------------------
# SUITE 4: SAFE ZONE MARGIN & TEXT CUTOFF STRESS TESTING
# -----------------------------------------------------------------------------
Write-Host "`n--- SUITE 4: Safe Zone Margin & Text Cutoff Stress Testing ---" -ForegroundColor Yellow

$bmpSafe = New-Object System.Drawing.Bitmap(100, 100)
$gSafe = [System.Drawing.Graphics]::FromImage($bmpSafe)

function Measure-Text([string]$text, [string]$family, [float]$size, [System.Drawing.FontStyle]$style = [System.Drawing.FontStyle]::Bold) {
    try {
        $f = New-Object System.Drawing.Font($family, $size, $style)
    } catch {
        $f = New-Object System.Drawing.Font("Arial", $size, $style)
    }
    $sizeF = $gSafe.MeasureString($text, $f)
    $f.Dispose()
    return $sizeF.Width
}

# Character map for unicode constants
$uA = [char]0x00C1; $uE = [char]0x00C9; $uI = [char]0x00CD; $uO = [char]0x00D3; $uU = [char]0x00DA; $uN = [char]0x00D1
$lA = [char]0x00E1; $lE = [char]0x00E9; $lI = [char]0x00ED; $lO = [char]0x00F3; $lU = [char]0x00FA; $lN = [char]0x00F1
$iE = [char]0x00A1; $iQ = [char]0x00BF; $deg = [char]0x00B0

$allCatalogTexts = @(
    @{ Piece = 'Post 01'; Text = "$($iQ)PROTEGEN A TAMPICO O VIENEN POR EL AGUACHILE?"; Font = 'Segoe UI Black'; Size = [float]21.0 },
    @{ Piece = 'Post 01'; Text = "$($iE)ABDUCIDOS POR EL SABOR! * TOSTITOS SALSA VERDE"; Font = 'Segoe UI Black'; Size = [float]12.5 },
    @{ Piece = 'Post 02'; Text = 'JUANCHO EL REY DE LA LAGUNA'; Font = 'Segoe UI Black'; Size = [float]21.0 },
    @{ Piece = 'Post 02'; Text = "$($iE)BIEN REPORTADO COMO DIOS MANDA! * 100% MARISCO FRESCO"; Font = 'Segoe UI Black'; Size = [float]12.5 },
    @{ Piece = 'Post 03'; Text = 'CUANDO TE DICEN QUE NO LES GUSTA EL AGUACHILE...'; Font = 'Segoe UI Black'; Size = [float]21.0 },
    @{ Piece = 'Post 03'; Text = "$($iE)HASTA EL MAPACHE SABE CU$($uA)L ES EL M$($uA)S REPORTADO!"; Font = 'Segoe UI Black'; Size = [float]12.5 },
    @{ Piece = 'Post 04'; Text = "EL ESCUADR$($uO)N JAIBO: TRES LEYENDAS"; Font = 'Segoe UI Black'; Size = [float]21.0 },
    @{ Piece = 'Post 04'; Text = 'UN SOLO TOSTIAGUACHILE VERDE TRADICIONAL'; Font = 'Segoe UI Black'; Size = [float]12.5 },
    @{ Piece = 'Post 05'; Text = "$($iQ)POR QU$($uE) LO PREPARAMOS FRENTE A TI?"; Font = 'Segoe UI Black'; Size = [float]21.0 },
    @{ Piece = 'Post 05'; Text = 'TRANSPARENCIA TOTAL: MARISCO FRESCO Y CRUNCH 100%'; Font = 'Segoe UI Black'; Size = [float]12.5 },
    @{ Piece = 'Post 06'; Text = "HIELERAS T$($uE)RMICAS GRADO ALIMENTICIO"; Font = 'Segoe UI Black'; Size = [float]21.0 },
    @{ Piece = 'Post 06'; Text = "AFUERA 38$($deg)C... ADENTRO EL CAMAR$($uO)N A 2$($deg)C"; Font = 'Segoe UI Black'; Size = [float]12.5 },
    @{ Piece = 'Post 07'; Text = "ANATOM$($uI)A DEL CAMAR$($uO)N MARIPOSA"; Font = 'Segoe UI Black'; Size = [float]21.0 },
    @{ Piece = 'Post 07'; Text = "~100g DE CAMAR$($uO)N LIMPIO EN CORTE MARIPOSA"; Font = 'Segoe UI Black'; Size = [float]12.5 },
    @{ Piece = 'Post 08'; Text = 'TOSTITOS SALSA VERDE: 100% CRUJIENTES'; Font = 'Segoe UI Black'; Size = [float]21.0 },
    @{ Piece = 'Post 08'; Text = "$($iE)CERO TOTOPOS REMOJADOS O AGUADOS!"; Font = 'Segoe UI Black'; Size = [float]12.5 },
    @{ Piece = 'Post 09'; Text = "$($iE)LA CURA SAGRADA DE LA CRUDA!"; Font = 'Segoe UI Black'; Size = [float]21.0 },
    @{ Piece = 'Post 09'; Text = "EL SUERO GASTRON$($uO)MICO DE LA CONURBADA"; Font = 'Segoe UI Black'; Size = [float]12.5 },
    @{ Piece = 'Post 10'; Text = "AUDIO EN TU CABEZA: $($iE)CRUNCH!"; Font = 'Segoe UI Black'; Size = [float]21.0 },
    @{ Piece = 'Post 10'; Text = "EL ASMR M$($uA)S DESEADO DE TAMPICO Y MADERO"; Font = 'Segoe UI Black'; Size = [float]12.5 },
    @{ Piece = 'Post 11'; Text = 'ORO VERDE ESMERALDA'; Font = 'Segoe UI Black'; Size = [float]21.0 },
    @{ Piece = 'Post 11'; Text = "CHILE SERRANO FRESCO + LIM$($uO)N COLIMA RECI$($uE)N EXPRIMIDO"; Font = 'Segoe UI Black'; Size = [float]12.5 },
    @{ Piece = 'Post 12'; Text = 'EL RITUAL DOMINICAL JAIBO'; Font = 'Segoe UI Black'; Size = [float]21.0 },
    @{ Piece = 'Post 12'; Text = "SOF$($uA), CLIMA ENCENDIDO Y TOSTIAGUACHILE A TU PUERTA"; Font = 'Segoe UI Black'; Size = [float]12.5 },
    @{ Piece = 'Post 13'; Text = "$($iE)HIELERAS CARGADAS Y EN RUTA!"; Font = 'Segoe UI Black'; Size = [float]21.0 },
    @{ Piece = 'Post 13'; Text = 'COBERTURA TOTAL TAMPICO Y CIUDAD MADERO'; Font = 'Segoe UI Black'; Size = [float]12.5 },
    @{ Piece = 'Post 14'; Text = 'ZONAS Y HORARIOS OFICIALES'; Font = 'Segoe UI Black'; Size = [float]21.0 },
    @{ Piece = 'Post 14'; Text = "S$($uA)BADOS Y DOMINGOS DE 1:00 PM A 5:00 PM"; Font = 'Segoe UI Black'; Size = [float]12.5 },
    @{ Piece = 'Post 15'; Text = "$($iE)$($uU)LTIMOS CUPOS DE LA TARDE!"; Font = 'Segoe UI Black'; Size = [float]21.0 },
    @{ Piece = 'Post 15'; Text = "MARISCO FRESCO DEL D$($uI)A * CUANDO SE ACABA SE CERR$($uO)"; Font = 'Segoe UI Black'; Size = [float]12.5 },
    @{ Piece = 'Post 16'; Text = "EL TOSTIAGUACHILE M$($uA)S REPORTADO"; Font = 'Segoe UI Black'; Size = [float]21.0 },
    @{ Piece = 'Post 16'; Text = 'ORGULLO Y COMUNIDAD 100% JAIBA * GRACIAS POR TU PREFERENCIA'; Font = 'Segoe UI Black'; Size = [float]12.5 },
    # Story Invariants
    @{ Piece = 'Story Shared'; Text = 'LA GARZA AGUACHILERA'; Font = 'Segoe UI Black'; Size = [float]30.0 },
    @{ Piece = 'Story Shared'; Text = "170 MXN LA BOLSA * ~100g CAMAR$($uO)N"; Font = 'Segoe UI Black'; Size = [float]21.0 },
    @{ Piece = 'Story Shared'; Text = 'PEDIDOS Y APARTADOS POR WHATSAPP'; Font = 'Segoe UI Black'; Size = [float]16.0 },
    @{ Piece = 'Story Shared'; Text = '833 252 09 88'; Font = 'Segoe UI Black'; Size = [float]34.0 }
)

foreach ($t in $allCatalogTexts) {
    $measW = Measure-Text $t.Text $t.Font $t.Size
    $margin = (1080 - $measW) / 2
    # Strict assertion: Margin on each side must be at least 30px (Safe Zone rule)
    $safePass = ($margin -ge 30.0)
    Assert-Result "SAFEZONE-$($t.Piece)" "Text inside safe zone (margin: $([math]::Round($margin, 1))px >= 30px): '$($t.Text)'" $safePass "Measured width: $([math]::Round($measW, 1))px in 1080px canvas"
}

$gSafe.Dispose()
$bmpSafe.Dispose()

# -----------------------------------------------------------------------------
# SUMMARY & EXIT STATUS
# -----------------------------------------------------------------------------
Write-Host "`n=================================================================" -ForegroundColor Cyan
Write-Host "  ADVERSARIAL HARNESS SUMMARY:" -ForegroundColor Cyan
Write-Host "  Total Tests Run : $script:testCount" -ForegroundColor Cyan
Write-Host "  Total Failures  : $script:globalFailures" -ForegroundColor $(if ($script:globalFailures -eq 0) { "Green" } else { "Red" })
Write-Host "=================================================================" -ForegroundColor Cyan

if ($script:globalFailures -eq 0) {
    Write-Host " [VERDICT: APPROVE] 100% of adversarial checks passed." -ForegroundColor Green
    exit 0
} else {
    Write-Host " [VERDICT: CHALLENGE_FAILED] $script:globalFailures test(s) failed." -ForegroundColor Red
    exit 1
}
