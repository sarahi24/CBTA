# Test script para validar pagos de Stripe
# Este script prueba el endpoint POST /api/v1/debts/validate

param(
    [string]$BaseUrl = "http://localhost:8000/api/v1",
    [string]$Token = "",
    [Parameter(Mandatory=$true)]
    [string]$Search,
    [Parameter(Mandatory=$true)]
    [string]$PaymentIntentId
)

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "TEST: Validar Pago de Stripe" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Si no se proporciona token, pedirlo
if ([string]::IsNullOrWhiteSpace($Token)) {
    Write-Host "No se proporcionó token. Por favor ingresa el access_token:" -ForegroundColor Yellow
    $Token = Read-Host "Token"
}

if ([string]::IsNullOrWhiteSpace($Token)) {
    Write-Host "❌ Error: Se requiere un token válido" -ForegroundColor Red
    exit 1
}

try {
    $url = "$BaseUrl/debts/validate"
    
    Write-Host "🔄 Validando pago de Stripe..." -ForegroundColor Yellow
    Write-Host "URL: $url" -ForegroundColor Gray
    Write-Host "Search: $Search" -ForegroundColor Gray
    Write-Host "Payment Intent ID: $PaymentIntentId" -ForegroundColor Gray
    Write-Host ""
    
    $headers = @{
        "Authorization" = "Bearer $Token"
        "Content-Type" = "application/json"
        "Accept" = "application/json"
        "X-User-Role" = "financial-staff"
        "X-User-Permission" = "validate.debt"
    }
    
    $body = @{
        search = $Search
        payment_intent_id = $PaymentIntentId
    } | ConvertTo-Json
    
    Write-Host "📦 Request Body:" -ForegroundColor Gray
    Write-Host $body -ForegroundColor White
    Write-Host ""
    
    $response = Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Body $body -ErrorAction Stop
    
    Write-Host "✅ Pago validado exitosamente!" -ForegroundColor Green
    Write-Host ""
    
    # Mostrar respuesta
    Write-Host "📊 RESPUESTA:" -ForegroundColor Cyan
    Write-Host "Success: $($response.success)" -ForegroundColor White
    Write-Host "Message: $($response.message)" -ForegroundColor White
    
    if ($response.data.validated_payment) {
        $payment = $response.data.validated_payment
        
        Write-Host ""
        Write-Host "👤 INFORMACIÓN DEL ESTUDIANTE:" -ForegroundColor Cyan
        Write-Host "  ID: $($payment.student.id)" -ForegroundColor White
        Write-Host "  Nombre: $($payment.student.fullName)" -ForegroundColor White
        Write-Host "  Email: $($payment.student.email)" -ForegroundColor White
        Write-Host "  CURP: $($payment.student.curp)" -ForegroundColor White
        Write-Host "  N° Control: $($payment.student.n_control)" -ForegroundColor White
        
        Write-Host ""
        Write-Host "💳 INFORMACIÓN DEL PAGO:" -ForegroundColor Cyan
        Write-Host "  ID del Pago: $($payment.payment.id)" -ForegroundColor White
        Write-Host "  Monto Total: `$$($payment.payment.amount) MXN" -ForegroundColor Green
        Write-Host "  Monto Recibido: `$$($payment.payment.amount_received) MXN" -ForegroundColor Green
        Write-Host "  Estado: $($payment.payment.status)" -ForegroundColor $(
            if ($payment.payment.status -eq 'completed') { 'Green' }
            else { 'Yellow' }
        )
        Write-Host "  Payment Intent ID: $($payment.payment.payment_intent_id)" -ForegroundColor Gray
        
        Write-Host ""
        Write-Host "⏰ FECHAS:" -ForegroundColor Cyan
        Write-Host "  Actualizado: $($payment.updatedAt)" -ForegroundColor White
        
        Write-Host ""
        Write-Host "📋 METADATOS:" -ForegroundColor Cyan
        Write-Host "  Pago Creado: $($payment.metadata.wasCreated)" -ForegroundColor $(if ($payment.metadata.wasCreated) { 'Green' } else { 'Yellow' })
        Write-Host "  Pago Reconciliado: $($payment.metadata.wasReconciled)" -ForegroundColor $(if ($payment.metadata.wasReconciled) { 'Green' } else { 'Yellow' })
        Write-Host "  Mensaje: $($payment.metadata.message)" -ForegroundColor White
        
        if ($payment.metadata.reconciliationResult) {
            $result = $payment.metadata.reconciliationResult
            Write-Host ""
            Write-Host "🔄 RESULTADO DE RECONCILIACIÓN:" -ForegroundColor Yellow
            Write-Host "  Procesados: $($result.processed)" -ForegroundColor White
            Write-Host "  Actualizados: $($result.updated)" -ForegroundColor White
            Write-Host "  Notificados: $($result.notified)" -ForegroundColor White
            Write-Host "  Fallidos: $($result.failed)" -ForegroundColor $(if ($result.failed -gt 0) { 'Red' } else { 'Green' })
        }
        
        Write-Host ""
        Write-Host "✅ VALIDACIÓN COMPLETADA EXITOSAMENTE" -ForegroundColor Green
    }
    
    Write-Host ""
    Write-Host "📋 Respuesta completa (JSON):" -ForegroundColor Gray
    $response | ConvertTo-Json -Depth 10
    
} catch {
    Write-Host "❌ Error al validar pago" -ForegroundColor Red
    Write-Host ""
    
    if ($_.Exception.Response) {
        $statusCode = [int]$_.Exception.Response.StatusCode
        Write-Host "Código de estado: $statusCode" -ForegroundColor Red
        
        $statusMessages = @{
            401 = "No autenticado - Verifica tu token"
            403 = "No autorizado - No tienes permisos para validar pagos"
            409 = "Conflicto - El pago podría estar ya validado o no existe"
            422 = "Error de validación - Verifica los datos enviados"
            429 = "Demasiadas solicitudes - Espera un momento e intenta de nuevo"
            500 = "Error interno del servidor"
            502 = "Error de Stripe - Problema con el servicio de pagos"
        }
        
        if ($statusMessages.ContainsKey($statusCode)) {
            Write-Host "ℹ️  $($statusMessages[$statusCode])" -ForegroundColor Yellow
        }
        
        try {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $responseBody = $reader.ReadToEnd() | ConvertFrom-Json
            
            Write-Host ""
            Write-Host "Mensaje: $($responseBody.message)" -ForegroundColor Yellow
            
            if ($responseBody.error_code) {
                Write-Host "Código de error: $($responseBody.error_code)" -ForegroundColor Yellow
            }
            
            if ($responseBody.errors) {
                Write-Host ""
                Write-Host "Errores de validación:" -ForegroundColor Yellow
                $responseBody.errors | ConvertTo-Json -Depth 3
            }
            
        } catch {
            Write-Host "Respuesta de error:" -ForegroundColor Yellow
            Write-Host $_.Exception.Message -ForegroundColor Red
        }
    } else {
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Test completado" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "💡 EJEMPLOS DE USO:" -ForegroundColor Yellow
Write-Host ""
Write-Host "# Validar con email:" -ForegroundColor Gray
Write-Host ".\test-validate-payment.ps1 -Search 'juan.perez@example.com' -PaymentIntentId 'pi_1Hh1XYZ1234567890' -Token 'tu_token'" -ForegroundColor White
Write-Host ""
Write-Host "# Validar con n_control:" -ForegroundColor Gray
Write-Host ".\test-validate-payment.ps1 -Search '2025001' -PaymentIntentId 'pi_1Hh1XYZ1234567890' -Token 'tu_token'" -ForegroundColor White
Write-Host ""
Write-Host "# Validar con CURP:" -ForegroundColor Gray
Write-Host ".\test-validate-payment.ps1 -Search 'PEPJ800101HDFRRN09' -PaymentIntentId 'pi_1Hh1XYZ1234567890' -Token 'tu_token'" -ForegroundColor White
Write-Host ""
Write-Host "# Con URL base personalizada:" -ForegroundColor Gray
Write-Host ".\test-validate-payment.ps1 -Search 'student@email.com' -PaymentIntentId 'pi_xxx' -Token 'token' -BaseUrl 'https://api.ejemplo.com/api/v1'" -ForegroundColor White
