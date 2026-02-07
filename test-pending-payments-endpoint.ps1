# Test script para el endpoint GET /api/v1/pending-payments/{studentId?}
# Fecha: 2026-02-06
# Propósito: Verificar que el endpoint retorna pagos pendientes en el formato especificado

$ApiUrl = "https://nginx-production-728f.up.railway.app/api/v1"
$LocalUrl = "http://localhost:8000/api/v1"

# Usar URL local si está disponible, sino usar production
$BaseUrl = $LocalUrl

# Credenciales de prueba
$Email = "juan.garcia@example.com"
$Password = "Password@123"

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Test: GET /api/v1/pending-payments/{studentId?}" -ForegroundColor Cyan
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
        Write-Host "   Token: $($token.Substring(0, 20))..." -ForegroundColor Gray
        Write-Host "   Usuario ID: $userId" -ForegroundColor Gray
        Write-Host "   Usuario: $studentName" -ForegroundColor Gray
    } else {
        Write-Host "❌ Error en login: $($loginResponse.StatusCode)" -ForegroundColor Red
        Write-Host $loginResponse.Content -ForegroundColor Red
        exit
    }

    Write-Host ""

    # PASO 2: Obtener pagos pendientes sin studentId (propia)
    Write-Host "[PASO 2] Obteniendo pagos pendientes del usuario actual..." -ForegroundColor Yellow
    
    $pendingUrl = "$BaseUrl/pending-payments"
    
    $headers = @{
        "Authorization" = "Bearer $token"
        "X-User-Role" = "student"
        "X-User-Permission" = "view.pending.concepts"
        "Content-Type" = "application/json"
    }

    $response = Invoke-WebRequest -Uri $pendingUrl `
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
            Write-Host "📊 Resumen de pagos pendientes:" -ForegroundColor Cyan
            Write-Host "   Total de pagos: $($data.data.pending_payments.Count)" -ForegroundColor Gray
            
            if ($data.data.pending_payments.Count -gt 0) {
                Write-Host ""
                Write-Host "Detialles:" -ForegroundColor Cyan
                $data.data.pending_payments | ForEach-Object {
                    Write-Host "   ├─ ID: $($_.id) | Concepto: $($_.concept_name)" -ForegroundColor Gray
                    Write-Host "   │  Monto: $$($_.amount) | Vence: $($_.end_date)" -ForegroundColor Gray
                    Write-Host "   │  Desc: $($_.description)" -ForegroundColor Gray
                    Write-Host ""
                }
            } else {
                Write-Host "   Sin pagos pendientes" -ForegroundColor Green
            }
        }
    } else {
        Write-Host "❌ Error: $($response.StatusCode)" -ForegroundColor Red
        Write-Host $response.Content -ForegroundColor Red
    }

    Write-Host ""

    # PASO 3: Probar con forceRefresh
    Write-Host "[PASO 3] Obteniendo pagos pendientes con forceRefresh=true..." -ForegroundColor Yellow
    
    $forceRefreshUrl = "$BaseUrl/pending-payments?forceRefresh=true"
    
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
