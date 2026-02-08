#!/usr/bin/env pwsh
# Test: GET /api/v1/payments
# Verificar estructura de respuesta del endpoint de pagos

$API_BASE = "https://nginx-production-728f.up.railway.app/api/v1"

Write-Host "`n🔍 TEST: GET /api/v1/payments" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor DarkGray

# Token de prueba - REEMPLAZAR con un token válido
$token = Read-Host "Ingresa el token de autenticación"

if ([string]::IsNullOrWhiteSpace($token)) {
    Write-Host "❌ Token requerido" -ForegroundColor Red
    exit 1
}

try {
    $headers = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json"
        "Accept" = "application/json"
        "X-User-Role" = "financial-staff"
        "X-User-Permission" = "view.payments"
    }

    $uri = "$API_BASE/payments?page=1&perPage=5"
    
    Write-Host "`n📤 REQUEST:" -ForegroundColor Yellow
    Write-Host "URL: $uri" -ForegroundColor Gray
    Write-Host "Headers: $($headers | ConvertTo-Json -Compress)" -ForegroundColor Gray

    $response = Invoke-RestMethod -Uri $uri -Method Get -Headers $headers -ErrorAction Stop

    Write-Host "`n✅ RESPONSE:" -ForegroundColor Green
    Write-Host ($response | ConvertTo-Json -Depth 10) -ForegroundColor White

    Write-Host "`n📊 ESTRUCTURA DE DATOS:" -ForegroundColor Cyan
    if ($response.data.payments.items) {
        Write-Host "Total items: $($response.data.payments.items.Count)" -ForegroundColor Gray
        Write-Host "Primer item:" -ForegroundColor Gray
        Write-Host ($response.data.payments.items[0] | ConvertTo-Json -Depth 5) -ForegroundColor White
    }

} catch {
    Write-Host "`n❌ ERROR:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    if ($_.ErrorDetails.Message) {
        Write-Host "`nDetalles:" -ForegroundColor Yellow
        Write-Host $_.ErrorDetails.Message -ForegroundColor White
    }
}

Write-Host "`n" -NoNewline
