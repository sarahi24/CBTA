#!/usr/bin/env pwsh
# Test: GET /api/v1/payments/students
# Verificar endpoint de resumen de estudiantes con pagos

$API_BASE = "https://nginx-production-728f.up.railway.app/api/v1"

Write-Host "`n🔍 TEST: GET /api/v1/payments/students" -ForegroundColor Cyan
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
        "X-User-Permission" = "view.payments.student.summary"
    }

    $uri = "$API_BASE/payments/students?page=1&perPage=5"
    
    Write-Host "`n📤 REQUEST:" -ForegroundColor Yellow
    Write-Host "URL: $uri" -ForegroundColor Gray
    Write-Host "Role: financial-staff" -ForegroundColor Gray
    Write-Host "Permission: view.payments.student.summary" -ForegroundColor Gray

    $response = Invoke-RestMethod -Uri $uri -Method Get -Headers $headers -ErrorAction Stop

    Write-Host "`n✅ RESPONSE OK:" -ForegroundColor Green
    Write-Host ($response | ConvertTo-Json -Depth 10) -ForegroundColor White

    Write-Host "`n📊 ANÁLISIS DE ESTRUCTURA:" -ForegroundColor Cyan
    Write-Host "success: $($response.success)" -ForegroundColor Gray
    Write-Host "data existe: $($null -ne $response.data)" -ForegroundColor Gray
    Write-Host "data.payments existe: $($null -ne $response.data.payments)" -ForegroundColor Gray
    
    if ($response.data.payments.items) {
        $items = $response.data.payments.items
        Write-Host "Total items: $($items.Count)" -ForegroundColor Gray
        Write-Host "Paginación: Página $($response.data.payments.currentPage) de $($response.data.payments.lastPage)" -ForegroundColor Gray
        Write-Host "Total registros: $($response.data.payments.total)" -ForegroundColor Gray
        
        if ($items.Count -gt 0) {
            Write-Host "`n📋 PRIMER ESTUDIANTE:" -ForegroundColor Cyan
            $first = $items[0]
            Write-Host "  n_control: $($first.n_control)" -ForegroundColor White
            Write-Host "  fullName: $($first.fullName)" -ForegroundColor White
            Write-Host "  semestre: $($first.semestre)" -ForegroundColor White
            Write-Host "  career_name: $($first.career_name)" -ForegroundColor White
            Write-Host "  num_pending: $($first.num_pending)" -ForegroundColor Yellow
            Write-Host "  num_expired: $($first.num_expired)" -ForegroundColor Red
            Write-Host "  total_amount_pending: $($first.total_amount_pending)" -ForegroundColor Yellow
            Write-Host "  total_paid: $($first.total_paid)" -ForegroundColor Green
        }
    } else {
        Write-Host "⚠️  No hay items en la respuesta" -ForegroundColor Yellow
    }

} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    Write-Host "`n❌ ERROR (Status: $statusCode):" -ForegroundColor Red
    
    if ($statusCode -eq 404) {
        Write-Host "🚫 El endpoint /payments/students NO EXISTE (404)" -ForegroundColor Yellow
        Write-Host "Backend necesita implementar este endpoint" -ForegroundColor Yellow
    } elseif ($statusCode -eq 403) {
        Write-Host "🚫 Sin permisos (403) - Verifica rol y permisos del usuario" -ForegroundColor Yellow
    } elseif ($statusCode -eq 401) {
        Write-Host "🚫 No autenticado (401) - Token inválido o expirado" -ForegroundColor Yellow
    } else {
        Write-Host $_.Exception.Message -ForegroundColor Red
        if ($_.ErrorDetails.Message) {
            Write-Host "`nDetalles:" -ForegroundColor Yellow
            Write-Host $_.ErrorDetails.Message -ForegroundColor White
        }
    }
}

Write-Host "`n" -NoNewline
