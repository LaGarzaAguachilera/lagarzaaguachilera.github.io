Add-Type -AssemblyName System.Drawing

function Convert-StickerToTransparentPng($srcPath, $dstPath, $threshold = 238, $targetSize = 1024) {
    Write-Host "Processing: $srcPath -> $dstPath"
    $rawSrc = [System.Drawing.Bitmap]::FromFile($srcPath)
    
    # Resize to exact targetSize x targetSize if needed with high quality bicubic
    $src = [System.Drawing.Bitmap]::new($targetSize, $targetSize, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($src)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.Clear([System.Drawing.Color]::White)
    $g.DrawImage($rawSrc, 0, 0, $targetSize, $targetSize)
    $g.Dispose()
    $rawSrc.Dispose()

    $w = $src.Width
    $h = $src.Height
    $dst = [System.Drawing.Bitmap]::new($w, $h, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    
    # Lock bits for fast BFS processing
    $rect = [System.Drawing.Rectangle]::new(0, 0, $w, $h)
    $srcData = $src.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::ReadOnly, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $dstData = $dst.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::WriteOnly, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    
    $bytes = $w * $h * 4
    $srcBytes = [byte[]]::new($bytes)
    $dstBytes = [byte[]]::new($bytes)
    [System.Runtime.InteropServices.Marshal]::Copy($srcData.Scan0, $srcBytes, 0, $bytes)
    
    # Visited array for BFS flood fill
    $visited = [bool[]]::new($w * $h)
    $queue = [System.Collections.Generic.Queue[int]]::new()
    
    # Enqueue outer border pixels
    for ($x = 0; $x -lt $w; $x++) {
        $idxTop = (0 * $w + $x)
        $idxBottom = (($h - 1) * $w + $x)
        $queue.Enqueue($idxTop)
        $queue.Enqueue($idxBottom)
        $visited[$idxTop] = $true
        $visited[$idxBottom] = $true
    }
    for ($y = 0; $y -lt $h; $y++) {
        $idxLeft = ($y * $w + 0)
        $idxRight = ($y * $w + ($w - 1))
        if (-not $visited[$idxLeft]) { $queue.Enqueue($idxLeft); $visited[$idxLeft] = $true }
        if (-not $visited[$idxRight]) { $queue.Enqueue($idxRight); $visited[$idxRight] = $true }
    }
    
    # Copy all pixels to dst initially
    [Array]::Copy($srcBytes, $dstBytes, $bytes)
    
    # BFS traversal
    while ($queue.Count -gt 0) {
        $curr = $queue.Dequeue()
        $px = $curr % $w
        $py = [math]::Floor($curr / $w)
        $offset = $curr * 4
        
        $b = $srcBytes[$offset]
        $gCol = $srcBytes[$offset + 1]
        $r = $srcBytes[$offset + 2]
        
        # If this outer pixel is near white / light background
        if ($r -gt $threshold -and $gCol -gt $threshold -and $b -gt $threshold) {
            # Set alpha channel to 0 (fully transparent)
            $dstBytes[$offset + 3] = 0
            
            # Check East
            if ($px + 1 -lt $w) {
                $nIdx = $curr + 1
                if (-not $visited[$nIdx]) {
                    $visited[$nIdx] = $true
                    $nOffset = $nIdx * 4
                    if ($srcBytes[$nOffset + 2] -gt $threshold -and $srcBytes[$nOffset + 1] -gt $threshold -and $srcBytes[$nOffset] -gt $threshold) {
                        $queue.Enqueue($nIdx)
                    }
                }
            }
            # Check West
            if ($px - 1 -ge 0) {
                $nIdx = $curr - 1
                if (-not $visited[$nIdx]) {
                    $visited[$nIdx] = $true
                    $nOffset = $nIdx * 4
                    if ($srcBytes[$nOffset + 2] -gt $threshold -and $srcBytes[$nOffset + 1] -gt $threshold -and $srcBytes[$nOffset] -gt $threshold) {
                        $queue.Enqueue($nIdx)
                    }
                }
            }
            # Check South
            if ($py + 1 -lt $h) {
                $nIdx = $curr + $w
                if (-not $visited[$nIdx]) {
                    $visited[$nIdx] = $true
                    $nOffset = $nIdx * 4
                    if ($srcBytes[$nOffset + 2] -gt $threshold -and $srcBytes[$nOffset + 1] -gt $threshold -and $srcBytes[$nOffset] -gt $threshold) {
                        $queue.Enqueue($nIdx)
                    }
                }
            }
            # Check North
            if ($py - 1 -ge 0) {
                $nIdx = $curr - $w
                if (-not $visited[$nIdx]) {
                    $visited[$nIdx] = $true
                    $nOffset = $nIdx * 4
                    if ($srcBytes[$nOffset + 2] -gt $threshold -and $srcBytes[$nOffset + 1] -gt $threshold -and $srcBytes[$nOffset] -gt $threshold) {
                        $queue.Enqueue($nIdx)
                    }
                }
            }
        }
    }
    
    [System.Runtime.InteropServices.Marshal]::Copy($dstBytes, 0, $dstData.Scan0, $bytes)
    $src.UnlockBits($srcData)
    $dst.UnlockBits($dstData)
    
    $dst.Save($dstPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $src.Dispose()
    $dst.Dispose()
    Write-Host "Success: Created transparent sticker $dstPath ($($targetSize)x$($targetSize) 32bppArgb)" -ForegroundColor Green
}

$rawJuancho = "C:\Users\aleja\.gemini\antigravity\brain\56b19aa9-f87f-49e4-bcdd-e525daff973b\sticker_juancho_jason_1792177387339.jpg"
$rawMapache = "C:\Users\aleja\.gemini\antigravity\brain\56b19aa9-f87f-49e4-bcdd-e525daff973b\sticker_mapache_freddy_1792177400038.jpg"
$rawOvni    = "C:\Users\aleja\.gemini\antigravity\brain\56b19aa9-f87f-49e4-bcdd-e525daff973b\sticker_ovni_muertos_1792177415863.jpg"

$root = "d:\AG\la garza aguachilera"

Convert-StickerToTransparentPng $rawJuancho (Join-Path $root "sticker_spooky_juancho_jason.png") 238 1024
Convert-StickerToTransparentPng $rawMapache (Join-Path $root "sticker_spooky_mapache_freddy.png") 238 1024
Convert-StickerToTransparentPng $rawOvni    (Join-Path $root "sticker_spooky_ovni_muertos.png") 238 1024
