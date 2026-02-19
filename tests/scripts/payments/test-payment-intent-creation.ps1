# Test script para el endpoint POST /api/v1/pending-payments
# Fecha: 2026-02-06
# Propósito: Verificar que el endpoint crea un intento de pago correctamente

$ApiUrl = "https://nginx-production-728f.up.railway.app/api/v1"
$LocalUrl = "http://localhost:8000/api/v1"

# Usar URL local si está disponible, sino usar production
$BaseUrl = $LocalUrl

# Credenciales de prueba
$Email = "juan.garcia@example.com"
$Password = "Password@123"

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Test: POST /api/v1/pending-payments" -ForegroundColor Cyan
Write-Host "Crear intento de pago para concepto" -ForegroundColor Cyan
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

    # PASO 2: Obtener pagos pendientes para obtener un concepto_id
    Write-Host "[PASO 2] Obteniendo pagos pendientes..." -ForegroundColor Yellow
    
    $pendingUrl = "$BaseUrl/pending-payments"
    
    $headers = @{
        "Authorization" = "Bearer $token"
        "X-User-Role" = "student"
        "X-User-Permission" = "view.pending.concepts"
        "Content-Type" = "application/json"
    }

    $pendingResponse = Invoke-WebRequest -Uri $pendingUrl `
        -Method GET `
        -Headers $headers `
        -SkipHttpErrorCheck

    if ($pendingResponse.StatusCode -eq 200) {
        $pendingData = $pendingResponse.Content | ConvertFrom-Json
        
        if ($pendingData.data.pending_payments.Count -gt 0) {
            $conceptId = $pendingData.data.pending_payments[0].id
            $conceptName = $pendingData.data.pending_payments[0].concept_name
            $conceptAmount = $pendingData.data.pending_payments[0].amount
            
            Write-Host "✅ Concepto pendiente encontrado" -ForegroundColor Green
            Write-Host "   ID: $conceptId | Nombre: $conceptName | Monto: $$conceptAmount" -ForegroundColor Gray
        } else {
            Write-Host "❌ No hay conceptos pendientes" -ForegroundColor Red
            exit
        }
    } else {
        Write-Host "❌ Error al obtener pendientes: $($pendingResponse.StatusCode)" -ForegroundColor Red
        exit
    }

    Write-Host ""

    # PASO 3: Crear intento de pago
    Write-Host "[PASO 3] Creando intento de pago..." -ForegroundColor Yellow
    
    $paymentUrl = "$BaseUrl/pending-payments"
    
    $paymentBody = @{
        concept_id = $conceptId
    } | ConvertTo-Json

    $paymentResponse = Invoke-WebRequest -Uri $paymentUrl `
        -Method POST `
        -Headers $headers `
        -Body $paymentBody `
        -SkipHttpErrorCheck

    if ($paymentResponse.StatusCode -eq 201) {
        $paymentData = $paymentResponse.Content | ConvertFrom-Json
        
        Write-Host "✅ Intento de pago creado exitosamente" -ForegroundColor Green
        Write-Host ""
        Write-Host "Respuesta estructurada:" -ForegroundColor Cyan
        Write-Host ($paymentData | ConvertTo-Json -Depth 3) -ForegroundColor Gray
        Write-Host ""
        
        if ($paymentData.data.url_checkout) {
            Write-Host "🔗 URL de Checkout:" -ForegroundColor Cyan
            Write-Host $paymentData.data.url_checkout -ForegroundColor Green
            Write-Host ""
            Write-Host "✅ Esta URL puede usarse para redirigir al usuario a Stripe" -ForegroundColor Green
        }
    } else {
        Write-Host "❌ Error al crear intento: $($paymentResponse.StatusCode)" -ForegroundColor Red
        Write-Host "Respuesta:" -ForegroundColor Cyan
        Write-Host $paymentResponse.Content -ForegroundColor Gray
    }

    Write-Host ""
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "✅ Test completado" -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Cyan

} catch {
    Write-Host "❌ Error inesperado: $_" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}
