# ==============================================================================
# EMPIRICAL VERIFICATION SUITE - CHALLENGER 1 (PREVIEW & ASSET INTEGRITY)
# La Garza Aguachilera - Halloween & Día de Muertos Campaign
# ==============================================================================
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$rootDir = "d:\AG\la garza aguachilera"
$ffprobe = "$rootDir\herramientas\ffmpeg\ffprobe.exe"
$zipPath = "$rootDir\paquete_redes_la_garza.zip"

Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "   CHALLENGER 1: EMPIRICAL HARNESS & STRESS-TEST VERIFICATION   " -ForegroundColor Yellow
Write-Host "=================================================================" -ForegroundColor Cyan

$globalTests = 0
$globalPassed = 0
$globalFailed = 0
$failureLog = @()

function Record-Result([string]$category, [string]$testName, [bool]$passed, [string]$details) {
    $script:globalTests++
    if ($passed) {
        $script:globalPassed++
        Write-Host " [PASS] [$category] $testName : $details" -ForegroundColor Green
    } else {
        $script:globalFailed++
        $script:failureLog += "[$category] $testName : $details"
        Write-Host " [FAIL] [$category] $testName : $details" -ForegroundColor Red
    }
}

# ------------------------------------------------------------------------------
# 1. EMPIRICAL VERIFICATION OF 100% RELATIVE LINKS IN HTML FILES
# ------------------------------------------------------------------------------
Write-Host "`n--- 1. RELATIVE LINKS & ASSET REFERENCE AUDIT IN HTML FILES ---" -ForegroundColor Cyan

$htmlFiles = @("index.html", "panel_control.html")

foreach ($htmlFile in $htmlFiles) {
    $fullPath = Join-Path $rootDir $htmlFile
    if (-not (Test-Path $fullPath)) {
        Record-Result "HTML" "$htmlFile exists" $false "File not found"
        continue
    }
    
    $content = [System.IO.File]::ReadAllText($fullPath, [System.Text.Encoding]::UTF8)
    Record-Result "HTML" "$htmlFile loaded" $true "Size: $($content.Length) characters"
    
    # Extract src and href attributes using Regex
    $pattern = '(?:src|href)=["'']([^"'']+)["'']'
    $matches = [regex]::Matches($content, $pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    
    $extracted = @()
    foreach ($m in $matches) {
        $val = $m.Groups[1].Value.Trim()
        if ($val -ne "" -and -not ($val.StartsWith("#")) -and -not ($val.StartsWith("javascript:")) -and -not ($val.StartsWith("mailto:")) -and -not ($val.StartsWith("tel:"))) {
            $extracted += $val
        }
    }
    
    $uniqueRefs = $extracted | Select-Object -Unique
    Write-Host "  Found $($uniqueRefs.Count) unique non-anchor/script references in $htmlFile" -ForegroundColor Gray
    
    $relativeCount = 0
    foreach ($ref in $uniqueRefs) {
        # Check if external URL
        if ($ref -match '^https?://') {
            # External link - check if Facebook link adheres to contract
            if ($ref -match 'facebook\.com') {
                $isOfficialFb = ($ref -eq 'https://www.facebook.com/share/19mMzwqpL4/?mibextid=wwXIfr')
                Record-Result "FB-CONTRACT" "$htmlFile Facebook link" $isOfficialFb "Found URL: $ref"
            }
            continue
        }
        
        $relativeCount++
        # Relative link: normalize path and verify local existence on disk
        $cleanRef = $ref.Split('?')[0].Split('#')[0] # remove query params or hash
        $cleanRef = $cleanRef.Replace('/', '\')
        
        $targetFile = Join-Path $rootDir $cleanRef
        $targetExists = Test-Path $targetFile
        
        if ($targetExists) {
            $size = (Get-Item $targetFile).Length
            Record-Result "REL-LINK" "$htmlFile -> $cleanRef" $true "Exists ($size bytes)"
        } else {
            Record-Result "REL-LINK" "$htmlFile -> $cleanRef" $false "404 NOT FOUND at $targetFile"
        }
    }
    Write-Host "  Audited $relativeCount relative links in $htmlFile (0 404s required)." -ForegroundColor Gray
}

# ------------------------------------------------------------------------------
# 2. EMPIRICAL VERIFICATION OF ZIP INTEGRITY, SIZE & INTERNAL STRUCTURE
# ------------------------------------------------------------------------------
Write-Host "`n--- 2. ZIP PACKAGE INTEGRITY & SIZE STRESS TEST ---" -ForegroundColor Cyan

if (Test-Path $zipPath) {
    $zipItem = Get-Item $zipPath
    $zipBytes = $zipItem.Length
    $zipMB = [math]::Round($zipBytes / 1MB, 2)
    $zipLimitBytes = 100 * 1024 * 1024 # 100 MiB GitHub hard limit
    
    Record-Result "ZIP" "File exists" $true $zipPath
    Record-Result "ZIP" "Size strictly under 100 MB" ($zipBytes -lt $zipLimitBytes) "$zipBytes bytes ($zipMB MB) < 100 MB limit"
    
    # Decompression and stream-read test of all entries
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $zip = [System.IO.Compression.ZipFile]::OpenRead($zipPath)
    Record-Result "ZIP" "Archive opens cleanly" ($null -ne $zip) "Total entries: $($zip.Entries.Count)"
    
    $totalDecompressed = 0
    $corruptedEntries = 0
    $spookyFolderFound = $false
    $videoInZipFound = $false
    $copiesCount = 0
    $postersCount = 0
    
    foreach ($entry in $zip.Entries) {
        try {
            $s = $entry.Open()
            $buffer = New-Object byte[] 65536
            while (($bytesRead = $s.Read($buffer, 0, $buffer.Length)) -gt 0) {
                $totalDecompressed += $bytesRead
            }
            $s.Close()
        } catch {
            $corruptedEntries++
            Write-Host "  Corrupted entry: $($entry.FullName) - Error: $($_.Exception.Message)" -ForegroundColor Red
        }
        
        if ($entry.FullName -like "Especial_Halloween_Dia_Muertos/*") {
            $spookyFolderFound = $true
            if ($entry.FullName -like "*promo_halloween_zombies_crudos.mp4") {
                $videoInZipFound = $true
            }
            if ($entry.FullName -like "*copy_*.txt") {
                $copiesCount++
            }
            if ($entry.FullName -like "*spooky_post*.png") {
                $postersCount++
            }
        }
    }
    
    $zip.Dispose()
    
    $decompressedMB = [math]::Round($totalDecompressed / 1MB, 2)
    Record-Result "ZIP" "Stream integrity (0 corrupted entries)" ($corruptedEntries -eq 0) "Decompressed $decompressedMB MB without error"
    Record-Result "ZIP" "Especial_Halloween_Dia_Muertos folder exists in ZIP" $spookyFolderFound "Found Halloween folder"
    Record-Result "ZIP" "Halloween promo video inside ZIP" $videoInZipFound "promo_halloween_zombies_crudos.mp4 present in ZIP"
    Record-Result "ZIP" "Halloween copy packages count in ZIP (6 expected)" ($copiesCount -ge 6) "$copiesCount copies found in ZIP"
    Record-Result "ZIP" "Halloween poster assets in ZIP (>= 4 expected)" ($postersCount -ge 4) "$postersCount spooky posters found in ZIP"
} else {
    Record-Result "ZIP" "File exists" $false "paquete_redes_la_garza.zip missing!"
}

# ------------------------------------------------------------------------------
# 3. EMPIRICAL VIDEO TELEMETRY VERIFICATION VIA FFPROBE
# ------------------------------------------------------------------------------
Write-Host "`n--- 3. EMPIRICAL VIDEO TELEMETRY VERIFICATION (FFPROBE) ---" -ForegroundColor Cyan

$videosToTest = @(
    @{
        Path = "$rootDir\VIDEOS\promo_halloween_zombies_crudos.mp4";
        Label = "Spooky Promo Video";
        ExpectedW = 1080; ExpectedH = 1920;
        MinBitrate = 4000000;
        MinDur = 15.0; MaxDur = 25.0
    },
    @{
        Path = "$rootDir\VIDEOS\promo_aguachile_verde_final.mp4";
        Label = "Classic Verde Promo Video";
        ExpectedW = 1080; ExpectedH = 1920;
        MinBitrate = 4000000;
        MinDur = 20.0; MaxDur = 35.0
    }
)

foreach ($v in $videosToTest) {
    $vLabel = $v.Label
    $vPath = $v.Path
    
    if (-not (Test-Path $vPath)) {
        Record-Result "VIDEO" "$vLabel exists" $false "$vPath not found"
        continue
    }
    
    Record-Result "VIDEO" "$vLabel file exists" $true "$vPath"
    
    $jsonOutput = & $ffprobe -v error -print_format json -show_format -show_streams $vPath
    $data = $jsonOutput | ConvertFrom-Json
    
    $vStream = $data.streams | Where-Object { $_.codec_type -eq 'video' } | Select-Object -First 1
    $aStream = $data.streams | Where-Object { $_.codec_type -eq 'audio' } | Select-Object -First 1
    $fmt = $data.format
    
    # 1. Video stream checks
    Record-Result "VIDEO" "$vLabel codec is h264" ($vStream.codec_name -eq 'h264') "Codec: $($vStream.codec_name), Profile: $($vStream.profile)"
    Record-Result "VIDEO" "$vLabel resolution is $($v.ExpectedW)x$($v.ExpectedH)" ($vStream.width -eq $v.ExpectedW -and $vStream.height -eq $v.ExpectedH) "$($vStream.width)x$($vStream.height)"
    Record-Result "VIDEO" "$vLabel display aspect ratio 9:16" ($vStream.display_aspect_ratio -eq '9:16') "DAR: $($vStream.display_aspect_ratio)"
    Record-Result "VIDEO" "$vLabel pixel format yuv420p" ($vStream.pix_fmt -eq 'yuv420p') "pix_fmt: $($vStream.pix_fmt)"
    
    $vBitrate = [int]$vStream.bit_rate
    $vBitrateKbps = [math]::Round($vBitrate / 1000, 1)
    Record-Result "VIDEO" "$vLabel video bitrate >= 4000 kbps" ($vBitrate -ge $v.MinBitrate) "$vBitrateKbps kbps"
    
    # 2. Audio stream checks
    Record-Result "VIDEO" "$vLabel audio codec is aac" ($aStream.codec_name -eq 'aac') "Audio codec: $($aStream.codec_name)"
    Record-Result "VIDEO" "$vLabel audio is stereo (2 ch)" ($aStream.channels -eq 2) "Channels: $($aStream.channels)"
    Record-Result "VIDEO" "$vLabel sample rate is 44100 Hz" ($aStream.sample_rate -eq 44100) "$($aStream.sample_rate) Hz"
    
    # 3. Duration check
    $dur = [double]$fmt.duration
    $durInRange = ($dur -ge $v.MinDur -and $dur -le $v.MaxDur)
    Record-Result "VIDEO" "$vLabel duration in range [$($v.MinDur)s - $($v.MaxDur)s]" $durInRange "$dur s"
}

# ------------------------------------------------------------------------------
# 4. BRAND SHIELDING & FORBIDDEN TERMS AUDIT (CORE WEB FILES)
# ------------------------------------------------------------------------------
Write-Host "`n--- 4. BRAND SHIELDING AUDIT (CORE WEB ASSETS) ---" -ForegroundColor Cyan

$forbiddenPatterns = @("dark kitchen", "caldo por separado", "jumbo", "tostitos redondos", "Rosa 210", "nacho", "base de operaciones")
$coreFiles = @(
    "index.html",
    "panel_control.html",
    "paquete_redes_la_garza.zip" # filename check
)

foreach ($f in @("index.html", "panel_control.html")) {
    $filePath = Join-Path $rootDir $f
    $text = [System.IO.File]::ReadAllText($filePath, [System.Text.Encoding]::UTF8)
    
    foreach ($pat in $forbiddenPatterns) {
        $count = ([regex]::Matches($text, [regex]::Escape($pat), [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)).Count
        Record-Result "BRAND" "$f zero occurrences of '$pat'" ($count -eq 0) "Occurrences: $count"
    }
    
    # Required brand terms
    $hasPrice = $text.Contains("150")
    $hasWhatsapp = $text.Contains("833 252 09 88") -or $text.Contains("8332520988")
    $hasTampico = $text.Contains("Colonia Flores")
    Record-Result "BRAND" "$f contains official price ($150 MXN)" $hasPrice "Price presence"
    Record-Result "BRAND" "$f contains official WhatsApp (833 252 09 88)" $hasWhatsapp "WhatsApp presence"
    Record-Result "BRAND" "$f contains official address (Colonia Flores)" $hasTampico "Colonia Flores presence"
}

# 4b. Global Scan of all production files
Write-Host "`n--- 4b. SCANNING ALL PRODUCTION SCRIPTS, TEXT & MARKDOWN FILES ---" -ForegroundColor Cyan
$prodFiles = Get-ChildItem -Path $rootDir -Recurse -Include *.ps1, *.html, *.md, *.txt | Where-Object {
    $_.FullName -notmatch '\\\.agents\\' -and
    $_.FullName -notmatch '\\\.git\\' -and
    $_.FullName -notmatch '\\tests\\' -and
    $_.Name -ne 'auditar_multimedia_qa.ps1' -and
    $_.Name -ne 'test_live_challenger2.ps1' -and
    $_.Name -ne 'TEST_INFRA.md' -and
    $_.Name -ne 'TEST_READY.md'
}

$prodViolations = 0
foreach ($pf in $prodFiles) {
    $txt = [System.IO.File]::ReadAllText($pf.FullName, [System.Text.Encoding]::UTF8)
    foreach ($pat in $forbiddenPatterns) {
        $count = ([regex]::Matches($txt, [regex]::Escape($pat), [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)).Count
        if ($count -gt 0) {
            $prodViolations += $count
            Write-Host "  [VIOLATION] $($pf.Name) contains '$pat' ($count times)" -ForegroundColor Red
        }
    }
}
Record-Result "BRAND" "All production files clean of forbidden words" ($prodViolations -eq 0) "Violations in production files: $prodViolations"

# ------------------------------------------------------------------------------
# 5. OVERALL SUMMARY
# ------------------------------------------------------------------------------
Write-Host "`n=================================================================" -ForegroundColor Cyan
Write-Host " OVERALL VERIFICATION SUMMARY: $globalPassed of $globalTests tests PASSED" -ForegroundColor $(if ($globalFailed -eq 0) { "Green" } else { "Red" })
if ($globalFailed -gt 0) {
    Write-Host " Failures encountered ($globalFailed):" -ForegroundColor Red
    foreach ($fail in $failureLog) {
        Write-Host "   - $fail" -ForegroundColor Yellow
    }
}
Write-Host "=================================================================" -ForegroundColor Cyan

if ($globalFailed -gt 0) {
    exit 1
} else {
    exit 0
}
