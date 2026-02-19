# Test script para obtener pagos desde Stripe
# Este script prueba el endpoint GET /api/v1/debts/stripe-payments

param(
    [string]$BaseUrl = "http://localhost:8000/api/v1",
    [string]$Token = "",
    [string]$Search = "",
    [int]$Year = 0,
    [switch]$ForceRefresh
)

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "TEST: Obtener Pagos desde Stripe" -ForegroundColor Cyan
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
    # Construir URL
    $url = "$BaseUrl/debts/stripe-payments"
    $queryParams = @()
    
    if (![string]::IsNullOrWhiteSpace($Search)) {
        $queryParams += "search=$([System.Web.HttpUtility]::UrlEncode($Search))"
    }
    
    if ($Year -gt 0) {
        $queryParams += "year=$Year"
    }
    
    if ($ForceRefresh) {
        $queryParams += "forceRefresh=true"
    }
    
    if ($queryParams.Count -gt 0) {
        $url += "?" + ($queryParams -join "&")
    }
    
    Write-Host "🔄 Obteniendo pagos de Stripe..." -ForegroundColor Yellow
    Write-Host "URL: $url" -ForegroundColor Gray
    if (![string]::IsNullOrWhiteSpace($Search)) {
        Write-Host "Search: $Search" -ForegroundColor Gray
    }
    if ($Year -gt 0) {
        Write-Host "Year: $Year" -ForegroundColor Gray
    }
    Write-Host ""
    
    $headers = @{
        "Authorization" = "Bearer $Token"
        "Content-Type" = "application/json"
        "Accept" = "application/json"
        "X-User-Role" = "financial-staff"
        "X-User-Permission" = "view.stripe.payments"
    }
    
    $response = Invoke-RestMethod -Uri $url -Method Get -Headers $headers -ErrorAction Stop
    
    Write-Host "✅ Pagos de Stripe obtenidos exitosamente!" -ForegroundColor Green
    Write-Host ""
    
    # Mostrar respuesta
    Write-Host "📊 RESPUESTA:" -ForegroundColor Cyan
    Write-Host "Success: $($response.success)" -ForegroundColor White
    Write-Host "Message: $($response.message)" -ForegroundColor White
    
    if ($response.data.payments) {
        $payments = $response.data.payments
        Write-Host ""
        Write-Host "💳 PAGOS DE STRIPE: $($payments.Count)" -ForegroundColor Green
        Write-Host ""
        
        $totalAmount = 0
        foreach ($payment in $payments) {
            Write-Host "  📌 Pago #$($payment.id)" -ForegroundColor Yellow
            Write-Host "     Payment Intent ID: $($payment.payment_intent_id)" -ForegroundColor Gray
            Write-Host "     Concepto: $($payment.concept_name)" -ForegroundColor White
            Write-Host "     Estado: $($payment.status)" -ForegroundColor $(
                if ($payment.status -eq 'succeeded') { 'Green' }
                elseif ($payment.status -eq 'pending') { 'Yellow' }
                else { 'Red' }
            )
            Write-Host "     Monto Total: `$$($payment.amount_total) MXN" -ForegroundColor Cyan
            Write-Host "     Monto Recibido: `$$($payment.amount_received) MXN" -ForegroundColor Cyan
            Write-Host "     Fecha de Creación: $($payment.created)" -ForegroundColor Gray
            
            if ($payment.receipt_url) {
                Write-Host "     URL de Recibo: $($payment.receipt_url)" -ForegroundColor Blue
            }
            
            Write-Host ""
            $totalAmount += [decimal]$payment.amount_received
        }
        
        Write-Host "💰 TOTAL RECIBIDO: `$$($totalAmount.ToString('N2')) MXN" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "ℹ️  No se encontraron pagos en Stripe" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "📋 Respuesta completa (JSON):" -ForegroundColor Gray
    $response | ConvertTo-Json -Depth 10
    
} catch {
    Write-Host "❌ Error al obtener pagos de Stripe" -ForegroundColor Red
    Write-Host ""
    
    if ($_.Exception.Response) {
        $statusCode = [int]$_.Exception.Response.StatusCode
        Write-Host "Código de estado: $statusCode" -ForegroundColor Red
        
        $statusMessages = @{
            401 = "No autenticado - Verifica tu token"
            403 = "No autorizado - No tienes permisos para ver pagos de Stripe"
            409 = "Conflicto - Verifica los parámetros de búsqueda"
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
Write-Host "# Obtener todos los pagos de Stripe:" -ForegroundColor Gray
Write-Host ".\test-stripe-payments.ps1 -Token 'tu_token'" -ForegroundColor White
Write-Host ""
Write-Host "# Buscar pagos por email/CURP/n_control:" -ForegroundColor Gray
Write-Host ".\test-stripe-payments.ps1 -Token 'tu_token' -Search '25687290'" -ForegroundColor White
Write-Host ""
Write-Host "# Filtrar por año específico:" -ForegroundColor Gray
Write-Host ".\test-stripe-payments.ps1 -Token 'tu_token' -Year 2025" -ForegroundColor White
Write-Host ""
Write-Host "# Búsqueda + año:" -ForegroundColor Gray
Write-Host ".\test-stripe-payments.ps1 -Token 'tu_token' -Search 'estudiante@email.com' -Year 2025" -ForegroundColor White
Write-Host ""
Write-Host "# Forzar actualización de caché:" -ForegroundColor Gray
Write-Host ".\test-stripe-payments.ps1 -Token 'tu_token' -ForceRefresh" -ForegroundColor White
Write-Host ""
Write-Host "# Combinado:" -ForegroundColor Gray
Write-Host ".\test-stripe-payments.ps1 -Token 'tu_token' -Search 'john.doe' -Year 2025 -ForceRefresh" -ForegroundColor White
Write-Host ""
Write-Host "# Con URL base personalizada:" -ForegroundColor Gray
Write-Host ".\test-stripe-payments.ps1 -Token 'tu_token' -BaseUrl 'https://api.ejemplo.com/api/v1' -Search '123456'" -ForegroundColor White
