param(
    [Parameter(Mandatory=$false)]
    [int]$Preventas = 75
)

# Meta táctica con reserva de seguridad (+15%)
$P = [Math]::Ceiling($Preventas * 1.15)

# Porción calibrada por Dirección: ~100g neto de camarón mariposa por bolsa
# Factor bruto con merma de limpieza/desvenado (+15% merma): 115g = 0.115 kg/bolsa
$CamaronKg = [Math]::Round(($P * 0.115), 2)
$LimonKg = [Math]::Round(($P * 0.242), 2)
$CajasTostitos = [Math]::Ceiling($P / 24)
$BolsasTostitos = $CajasTostitos * 24
$PepinoKg = [Math]::Round(($P * 0.130), 2)
$CebollaKg = [Math]::Round(($P * 0.045), 2)
$HieloBolsas = 4 + [Math]::Ceiling($P / 15)
$VentaEstimada = $P * 170

Write-Host "================================================================" -ForegroundColor DarkGreen
Write-Host "  🦐 LA GARZA AGUACHILERA — ALGORITMO DE COMPRAS DE VIERNES" -ForegroundColor Yellow
Write-Host "  📍 Colonia Flores, Tampico, Tamaulipas | WhatsApp: 833 252 09 88" -ForegroundColor Gray
Write-Host "  🎯 Capacidad Oficial: 75 bolsas por tanda (ajustable según producto)" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor DarkGreen
Write-Host "Preventas Confirmadas de la Semana  : $Preventas bolsas" -ForegroundColor White
Write-Host "Meta Táctica (+15% de Reserva)      : $P bolsas" -ForegroundColor White
Write-Host "----------------------------------------------------------------" -ForegroundColor DarkGray
Write-Host "1. Camarón Crudo Fresco (La Puntilla): $CamaronKg kg (mariposa ~100g neto/bolsa)" -ForegroundColor Cyan
Write-Host "2. Limón Colima Verde con Jugo       : $LimonKg kg" -ForegroundColor Cyan
Write-Host "3. Cajas de Tostitos Salsa Verde : $CajasTostitos cajas ($BolsasTostitos bolsas de reserva)" -ForegroundColor Cyan
Write-Host "4. Pepino Criollo Fresco             : $PepinoKg kg" -ForegroundColor Cyan
Write-Host "5. Cebolla Morada                    : $CebollaKg kg (para pluma desflemada)" -ForegroundColor Cyan
Write-Host "6. Bolsas de Hielo en Escama         : $HieloBolsas bolsas para hielera y cubetas con termómetro" -ForegroundColor Cyan
Write-Host "----------------------------------------------------------------" -ForegroundColor DarkGray
Write-Host "💰 Proyección de Venta Bruta ($170 MXN/bolsa): `$ $VentaEstimada MXN" -ForegroundColor Green
Write-Host "================================================================" -ForegroundColor DarkGreen
