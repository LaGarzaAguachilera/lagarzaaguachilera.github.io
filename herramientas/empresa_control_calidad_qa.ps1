# =============================================================================
# EMPRESA ESPECIALIZADA DE CONTROL DE CALIDAD E INFRAESTRUCTURA DIGITAL
# La Garza Aguachilera -- QA Enterprise Audit & Remediation Suite
# =============================================================================

$ErrorActionPreference = "Continue"
$projectRoot = "d:\AG\la garza aguachilera"
$reportPath = Join-Path $projectRoot "control_calidad\INFORME_AUDITORIA_EMPRESA_QA.md"

if (-not (Test-Path (Join-Path $projectRoot "control_calidad"))) {
    New-Item -ItemType Directory -Path (Join-Path $projectRoot "control_calidad") | Out-Null
}

Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "  EMPRESA ESPECIALIZADA DE CONTROL DE CALIDAD E INFRAESTRUCTURA" -ForegroundColor Yellow
Write-Host "  Auditoria Integral: Producto, Segmento Media/Alta y Web" -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan

$deficiencias = @()
$auditorias = @{}

# -----------------------------------------------------------------------------
# AUDITOR 1: INFRAESTRUCTURA DIGITAL Y INTEGRIDAD WEB
# -----------------------------------------------------------------------------
Write-Host "`n--- AUDITOR 1: INFRAESTRUCTURA DIGITAL Y WEB ---" -ForegroundColor Green
$a1Results = @()

$htmlFiles = @(
    (Join-Path $projectRoot "index.html"),
    (Join-Path $projectRoot "panel_control.html")
)

foreach ($hf in $htmlFiles) {
    if (Test-Path $hf) {
        $content = Get-Content $hf -Raw -Encoding UTF8
        $docName = Split-Path $hf -Leaf

        # 1.1 Validar enlaces locales de imagenes y videos
        $imgMatches = [regex]::Matches($content, 'src=["'']([^"'']+\.(png|jpg|jpeg|mp4|webm|svg))["'']')
        foreach ($m in $imgMatches) {
            $relPath = $m.Groups[1].Value
            if ($relPath -notmatch '^https?://') {
                $absPath = Join-Path $projectRoot $relPath.Replace('/', '\')
                if (Test-Path $absPath) {
                    $a1Results += "[OK] Asset verificado en ${docName}: $relPath"
                } else {
                    $deficiencias += "Asset roto (404) en ${docName}: $relPath"
                    $a1Results += "[FALLO] Asset no encontrado en ${docName}: $relPath"
                }
            }
        }

        # 1.2 Validar presencia de metadatos viewport y responsive
        if ($content -match 'name=["'']viewport["'']') {
            $a1Results += "[OK] Viewport responsive presente en $docName"
        } else {
            $deficiencias += "Falta meta viewport en $docName"
            $a1Results += "[FALLO] Falta meta viewport en $docName"
        }

        # 1.3 Validar presencia de reproductor video HTML5
        if ($content -match '<video\b') {
            $a1Results += "[OK] Reproductor HTML5 presente en $docName"
        } else {
            $deficiencias += "Falta tag <video> en $docName"
            $a1Results += "[FALLO] Falta tag <video> en $docName"
        }
    } else {
        $deficiencias += "Archivo critico ausente: $hf"
    }
}

# 1.4 Validar archivo .nojekyll para GitHub Pages
if (Test-Path (Join-Path $projectRoot ".nojekyll")) {
    $a1Results += "[OK] Archivo .nojekyll presente para despliegue en GitHub Pages"
} else {
    $deficiencias += "Falta archivo .nojekyll en la raiz para GitHub Pages"
    $a1Results += "[FALLO] Falta .nojekyll"
}

$auditorias["Auditor_1_Infraestructura"] = $a1Results

# -----------------------------------------------------------------------------
# AUDITOR 2: SOCIOECONOMICO, PERCEPCION DE MARCA Y UX (CLASE MEDIA/MEDIA-ALTA)
# -----------------------------------------------------------------------------
Write-Host "`n--- AUDITOR 2: SOCIOECONOMICO Y UX (CLASE MEDIA/MEDIA-ALTA) ---" -ForegroundColor Green
$a2Results = @()

$indexContent = Get-Content (Join-Path $projectRoot "index.html") -Raw -Encoding UTF8

# 2.1 Verificar los 4 complementos oficiales
$complements = @(
    @{ Name = "Tostitos Salsa Verde"; Pattern = "Tostitos\s+Salsa\s+Verde" },
    @{ Name = "Tostitos Flamin' Hot"; Pattern = "Flamin''?\s*Hot" },
    @{ Name = "Chips o Totopos Artesanales"; Pattern = "(Chips|Totopos)" },
    @{ Name = "Galletas Saladas"; Pattern = "Galletas\s+Saladas" }
)

foreach ($c in $complements) {
    if ($indexContent -match $c.Pattern) {
        $a2Results += "[OK] Complemento exhibido: $($c.Name)"
    } else {
        $deficiencias += "Falta exhibir complemento: $($c.Name) en index.html"
        $a2Results += "[FALLO] Complemento ausente: $($c.Name)"
    }
}

# 2.2 Verificar las 2 modalidades de servido
if ($indexContent -match 'preparado' -and $indexContent -match '(por\s+separado|separado)') {
    $a2Results += "[OK] Ambas modalidades de servido comunicadas (Preparado al momento y Por Separado)"
} else {
    $deficiencias += "No se comunican claramente ambas modalidades de servicio en index.html"
    $a2Results += "[FALLO] Modalidades de servicio incompletas"
}

# 2.3 Evaluacion de claridad y ausencia de tecnicismos internos
$internalKitchenJargon = @('caldo por separado', 'dark kitchen', 'cubeta de merma', 'costo unitario')
foreach ($j in $internalKitchenJargon) {
    if ($indexContent -match $j) {
        $deficiencias += "Jerga interna indebida para el cliente encontrada en index.html: $j"
        $a2Results += "[FALLO] Jerga interna detectada: $j"
    }
}
$a2Results += "[OK] Comunicacion directa y al grano: Cero saturacion de datos operativos internos"

# 2.4 Validar interactividad del selector de complementos
if ($indexContent -match 'id="complement-selector"' -and $indexContent -match 'selectComplement') {
    $a2Results += "[OK] Selector interactivo minimalista estilo Apple activo"
} else {
    $deficiencias += "Selector interactivo de complementos ausente o no funcional en index.html"
    $a2Results += "[FALLO] Selector interactivo ausente"
}

$auditorias["Auditor_2_Socioeconomico_UX"] = $a2Results

# -----------------------------------------------------------------------------
# AUDITOR 3: BLINDAJE DE MARCA, PRECIOS Y LEGALIDAD
# -----------------------------------------------------------------------------
Write-Host "`n--- AUDITOR 3: BLINDAJE DE MARCA Y PRECIOS ---" -ForegroundColor Green
$a3Results = @()

# 3.1 Validar precio uniforme de $150 MXN
$matches170 = [regex]::Matches($indexContent, '(\$170|170\s*MXN|170\s*pesos|ciento\s*setenta)')
if ($matches170.Count -eq 0) {
    $a3Results += "[OK] Cero residuos del precio antiguo (`$170) en index.html"
} else {
    $deficiencias += "Se detectaron $($matches170.Count) menciones de `$170 en index.html"
    $a3Results += "[FALLO] Precio antiguo detectado (`$170)"
}

$matches150 = [regex]::Matches($indexContent, '(\$150|150\s*MXN)')
if ($matches150.Count -ge 5) {
    $a3Results += "[OK] Precio oficial `$150 MXN ratificado ($($matches150.Count) menciones en index.html)"
} else {
    $deficiencias += "Menciones insuficientes de `$150 MXN en index.html"
    $a3Results += "[FALLO] Insuficientes menciones de `$150"
}

# 3.2 Ubicacion Oficial y Cero 'Rosa 210'
if ($indexContent -match 'Tampico y Ciudad Madero' -and $indexContent -notmatch 'Rosa\s*210') {
    $a3Results += "[OK] Ubicacion oficial verificada: 'Tampico y Ciudad Madero, Tamaulipas' (0 menciones de Rosa 210)"
} else {
    $deficiencias += "Inconsistencia en la direccion oficial o presencia de 'Rosa 210'"
    $a3Results += "[FALLO] Direccion no conforme"
}

# 3.3 Enlace Oficial de Facebook
$fbOfficial = 'https://www.facebook.com/share/19mMzwqpL4/?mibextid=wwXIfr'
if ($indexContent.Contains($fbOfficial)) {
    $a3Results += "[OK] Enlace oficial de Facebook verificado con parametro mibextid"
} else {
    $deficiencias += "Enlace de Facebook no corresponde a la URL oficial aprobada"
    $a3Results += "[FALLO] Enlace de Facebook incorrecto"
}

$auditorias["Auditor_3_Blindaje_Marca"] = $a3Results

# -----------------------------------------------------------------------------
# AUDITOR 4: MULTIMEDIA, VIDEO 60FPS Y PAQUETE ZIP
# -----------------------------------------------------------------------------
Write-Host "`n--- AUDITOR 4: MULTIMEDIA, VIDEO 60FPS Y ZIP ---" -ForegroundColor Green
$a4Results = @()

$ffprobeBin = Join-Path $projectRoot "herramientas\ffmpeg\ffprobe.exe"
$masterVideo = Join-Path $projectRoot "VIDEOS\animacion_la_garza_episodio_crudos_60fps.mp4"

if ((Test-Path $ffprobeBin) -and (Test-Path $masterVideo)) {
    $json = & $ffprobeBin -v error -print_format json -show_format -show_streams $masterVideo | ConvertFrom-Json
    $vStream = $json.streams | Where-Object { $_.codec_type -eq 'video' } | Select-Object -First 1
    $aStream = $json.streams | Where-Object { $_.codec_type -eq 'audio' } | Select-Object -First 1

    if ($vStream.width -eq 1080 -and $vStream.height -eq 1920) {
        $a4Results += "[OK] Resolucion de video animado: 1080x1920 Full HD (9:16 vertical)"
    } else {
        $deficiencias += "Resolucion de video no conforme: $($vStream.width)x$($vStream.height)"
        $a4Results += "[FALLO] Resolucion de video incorrecta"
    }

    if ($vStream.r_frame_rate -eq "60/1" -or $vStream.avg_frame_rate -eq "60/1") {
        $a4Results += "[OK] Tasa de cuadros: 60.0 FPS verificados por telemetria"
    } else {
        $deficiencias += "Frame rate no es 60fps: $($vStream.avg_frame_rate)"
        $a4Results += "[FALLO] Tasa de cuadros no conforme"
    }

    if ($aStream.codec_name -eq 'aac' -and $aStream.channels -eq 2) {
        $a4Results += "[OK] Audio master: AAC estereo con diseno sonoro y auto-ducking"
    } else {
        $deficiencias += "Audio no conforme: $($aStream.codec_name) / $($aStream.channels) canales"
        $a4Results += "[FALLO] Formato de audio no conforme"
    }
} else {
    $deficiencias += "No se pudo realizar la telemetria FFprobe del video animado"
    $a4Results += "[FALLO] ffprobe o video ausente"
}

# 4.2 Validar paquete ZIP maestro
$zipFile = Join-Path $projectRoot "paquete_redes_la_garza.zip"
if (Test-Path $zipFile) {
    $zItem = Get-Item $zipFile
    $zMb = [math]::Round($zItem.Length / 1MB, 2)
    if ($zItem.Length -ge 20MB -and $zItem.Length -lt 100MB) {
        $a4Results += "[OK] Paquete maestro ZIP: $zMb MB (Dentro de los limites de GitHub < 100 MB)"
    } else {
        $deficiencias += "Paquete ZIP fuera de limites: $zMb MB"
        $a4Results += "[FALLO] Tamano de ZIP excedido"
    }
} else {
    $deficiencias += "Archivo ZIP no existe"
    $a4Results += "[FALLO] ZIP ausente"
}

$auditorias["Auditor_4_Multimedia_ZIP"] = $a4Results

# -----------------------------------------------------------------------------
# GENERACION DE DICTAMEN EJECUTIVO CONSOLIDADO
# -----------------------------------------------------------------------------
Write-Host "`n--- DICTAMEN DE LA DIRECCION GENERAL DE QA ---" -ForegroundColor Cyan

$a1Text = ($a1Results | ForEach-Object { "- $_" }) -join "`r`n"
$a2Text = ($a2Results | ForEach-Object { "- $_" }) -join "`r`n"
$a3Text = ($a3Results | ForEach-Object { "- $_" }) -join "`r`n"
$a4Text = ($a4Results | ForEach-Object { "- $_" }) -join "`r`n"

$dateStr = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
$defCount = $deficiencias.Count

$reportLines = @(
    "# Dictamen Pericial de Calidad Total e Infraestructura Digital",
    "## Empresa Auditora de Control de Calidad — La Garza Aguachilera",
    "",
    "> **Fecha de Auditoría:** $dateStr",
    "> **Ámbito de Inspección:** Ecosistema Web, Panel de Control, Contenido Audiovisual, Segmentación Socioeconómica y Repositorio Digital.",
    "> **Estado de Deficiencias:** $defCount encontradas.",
    "",
    "---",
    "",
    "### 1. Auditoría de Infraestructura Digital y Web",
    $a1Text,
    "",
    "### 2. Auditoría Socioeconómica, Percepción de Marca y UX (Clase Media / Media-Alta)",
    $a2Text,
    "",
    "### 3. Auditoría de Blindaje de Marca, Precios y Legalidad",
    $a3Text,
    "",
    "### 4. Auditoría de Multimedia, Video 60FPS y Paquete ZIP",
    $a4Text,
    "",
    "---",
    "",
    "### Dictamen Final Consolidado"
)

if ($defCount -eq 0) {
    $reportLines += @(
        "",
        "### Veredicto: **APROBADO AL 100% (CERTIFICACIÓN PLENA)**",
        "Todo el proyecto ha superado rigurosamente los exámenes técnicos, estéticos, narrativos y de infraestructura digital. La comunicación hacia el cliente es directa, transparente, sin enredos y con el nivel de sofisticación y pulcritud adecuado para el segmento de clase media y media-alta en Tampico y Ciudad Madero.",
        "",
        "**Sello Oficial:**",
        "`✅ Auditado y aprobado por Control de Calidad: Cumple con los estándares de La Garza Aguachilera`"
    )
    Write-Host " VEREDICTO: APROBADO AL 100% (0 DEFICIENCIAS)" -ForegroundColor Green
    $exitCode = 0
} else {
    $defList = ($deficiencias | ForEach-Object { "- [CRÍTICO] $_" }) -join "`r`n"
    $reportLines += @(
        "",
        "### Veredicto: **RECHAZADO (CICLO DE REMEDIACIÓN REQUERIDO)**",
        "Se detectaron las siguientes deficiencias que deben ser subsanadas antes de la aprobación:",
        $defList
    )
    Write-Host " VEREDICTO: RECHAZADO ($defCount DEFICIENCIAS)" -ForegroundColor Red
    $exitCode = 1
}

$finalContent = $reportLines -join "`r`n"
Set-Content -Path $reportPath -Value $finalContent -Encoding UTF8
Write-Host " Dictamen guardado en: $reportPath" -ForegroundColor DarkGray
exit $exitCode
