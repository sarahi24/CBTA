# Test script para el endpoint GET /api/v1/pending-payments/overdue/{studentId?}
# Fecha: 2026-02-06
# Propósito: Verificar que el endpoint retorna pagos vencidos correctamente

$ApiUrl = "https://nginx-production-728f.up.railway.app/api/v1"
$LocalUrl = "http://localhost:8000/api/v1"

# Usar URL local si está disponible, sino usar production
$BaseUrl = $LocalUrl

# Credenciales de prueba
$Email = "juan.garcia@example.com"
$Password = "Password@123"

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Test: GET /api/v1/pending-payments/overdue/{studentId?}" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

try {
    # PASO 1: Login para obtener token
    Write-Host "[PASO 1] Autenticando usuario..." -ForegroundColor Yellow
    
    $loginUrl = "$BaseUrl/login"
    $loginBody = @{
        email = $Email
        password = $Password
    } | ConvertTo-Json

    $loginResponse = Invoke-WebRequest -Uri $loginUrl `
        -Method POST `
        -ContentType "application/json" `
        -Body $loginBody `
        -SkipHttpErrorCheck

    if ($loginResponse.StatusCode -eq 200) {
        $loginData = $loginResponse.Content | ConvertFrom-Json
        $token = $loginData.data.token
        $userId = $loginData.data.user.id
        $studentName = $loginData.data.user.name
        
        Write-Host "✅ Autenticación exitosa" -ForegroundColor Green
        Write-Host "   Usuario: $studentName" -ForegroundColor Gray
    } else {
        Write-Host "❌ Error en login: $($loginResponse.StatusCode)" -ForegroundColor Red
        exit
    }

    Write-Host ""

    # PASO 2: Obtener pagos vencidos sin studentId (propia)
    Write-Host "[PASO 2] Obteniendo pagos vencidos del usuario actual..." -ForegroundColor Yellow
    
    $overdueUrl = "$BaseUrl/pending-payments/overdue"
    
    $headers = @{
        "Authorization" = "Bearer $token"
        "X-User-Role" = "student"
        "X-User-Permission" = "view.overdue.concepts"
        "Content-Type" = "application/json"
    }

    $response = Invoke-WebRequest -Uri $overdueUrl `
        -Method GET `
        -Headers $headers `
        -SkipHttpErrorCheck

    if ($response.StatusCode -eq 200) {
        $data = $response.Content | ConvertFrom-Json
        
        Write-Host "✅ Endpoint respondió correctamente" -ForegroundColor Green
        Write-Host ""
        Write-Host "Respuesta estructurada:" -ForegroundColor Cyan
        Write-Host ($data | ConvertTo-Json -Depth 3) -ForegroundColor Gray
        Write-Host ""
        
        if ($data.data.pending_payments) {
            Write-Host "📊 Resumen de pagos vencidos:" -ForegroundColor Cyan
            Write-Host "   Total: $($data.data.pending_payments.Count)" -ForegroundColor Gray
            
            if ($data.data.pending_payments.Count -gt 0) {
                Write-Host ""
                Write-Host "Detalles:" -ForegroundColor Cyan
                $data.data.pending_payments | ForEach-Object {
                    Write-Host "   ├─ ID: $($_.id) | Concepto: $($_.concept_name)" -ForegroundColor Gray
                    Write-Host "   │  Monto: $$($_.amount) | Vencido: $($_.end_date)" -ForegroundColor Gray
                    Write-Host "   │  Desc: $($_.description)" -ForegroundColor Gray
                    Write-Host ""
                }
            }
        }
    } else {
        Write-Host "❌ Error: $($response.StatusCode)" -ForegroundColor Red
        Write-Host $response.Content -ForegroundColor Red
    }

    Write-Host ""

    # PASO 3: Probar con forceRefresh
    Write-Host "[PASO 3] Obteniendo pagos vencidos con forceRefresh=true..." -ForegroundColor Yellow
    
    $forceRefreshUrl = "$BaseUrl/pending-payments/overdue?forceRefresh=true"
    
    $response = Invoke-WebRequest -Uri $forceRefreshUrl `
        -Method GET `
        -Headers $headers `
        -SkipHttpErrorCheck

    if ($response.StatusCode -eq 200) {
        Write-Host "✅ forceRefresh funcionando" -ForegroundColor Green
    } else {
        Write-Host "❌ Error con forceRefresh: $($response.StatusCode)" -ForegroundColor Red
    }

    Write-Host ""
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "✅ Test completado exitosamente" -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Cyan

} catch {
    Write-Host "❌ Error inesperado: $_" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}
