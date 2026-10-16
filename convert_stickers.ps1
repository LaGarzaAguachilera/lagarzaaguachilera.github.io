Add-Type -AssemblyName System.Drawing

function Convert-StickerToTransparentPng($srcPath, $dstPath, $threshold = 238) {
    $src = [System.Drawing.Bitmap]::FromFile($srcPath)
    $w = $src.Width
    $h = $src.Height
    $dst = [System.Drawing.Bitmap]::new($w, $h, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    
    # Lock bits for fast processing
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
    
    # Enqueue borders
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
    
    # BFS
    while ($queue.Count -gt 0) {
        $curr = $queue.Dequeue()
        $px = $curr % $w
        $py = [math]::Floor($curr / $w)
        $offset = $curr * 4
        
        $b = $srcBytes[$offset]
        $g = $srcBytes[$offset + 1]
        $r = $srcBytes[$offset + 2]
        
        # If this outer pixel is near white or light grey shadow
        $isLight = ($r -gt $threshold -and $g -gt $threshold -and $b -gt $threshold)
        
        if ($isLight) {
            # Make transparent
            $dstBytes[$offset + 3] = 0
            
            # Check 4 neighbors
            $neighbors = @(
                @($px + 1, $py),
                @($px - 1, $py),
                @($px, $py + 1),
                @($px, $py - 1)
            )
            foreach ($n in $neighbors) {
                $nx = $n[0]
                $ny = $n[1]
                if ($nx -ge 0 -and $nx -lt $w -and $ny -ge 0 -and $ny -lt $h) {
                    $nIdx = ($ny * $w + $nx)
                    if (-not $visited[$nIdx]) {
                        $visited[$nIdx] = $true
                        $nOffset = $nIdx * 4
                        $nr = $srcBytes[$nOffset + 2]
                        $ng = $srcBytes[$nOffset + 1]
                        $nb = $srcBytes[$nOffset]
                        if ($nr -gt $threshold -and $ng -gt $threshold -and $nb -gt $threshold) {
                            $queue.Enqueue($nIdx)
                        }
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
    Write-Host "Created transparent sticker: $dstPath"
}

Convert-StickerToTransparentPng "C:\Users\aleja\.gemini\antigravity\brain\cc8cc15d-5c1d-4b14-93d0-54cd561c6a33\juancho_cocodrilo_sticker_1792107600560.jpg" "d:\AG\la garza aguachilera\sticker_juancho.png" 240
Convert-StickerToTransparentPng "C:\Users\aleja\.gemini\antigravity\brain\cc8cc15d-5c1d-4b14-93d0-54cd561c6a33\ovni_miramar_limon_sticker_1792107614372.jpg" "d:\AG\la garza aguachilera\sticker_ovni.png" 235
Convert-StickerToTransparentPng "C:\Users\aleja\.gemini\antigravity\brain\cc8cc15d-5c1d-4b14-93d0-54cd561c6a33\mapache_escolleras_sticker_1792107626866.jpg" "d:\AG\la garza aguachilera\sticker_mapache.png" 240
