# Test script para crear intento de pago
# Este script prueba el endpoint POST /api/v1/pending-payments

param(
    [string]$BaseUrl = "http://localhost:8000/api/v1",
    [string]$Token = "",
    [Parameter(Mandatory=$true)]
    [int]$ConceptId,
    [string]$Role = "student"
)

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "TEST: Crear Intento de Pago" -ForegroundColor Cyan
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
    $url = "$BaseUrl/pending-payments"
    
    Write-Host "🔄 Creando intento de pago..." -ForegroundColor Yellow
    Write-Host "URL: $url" -ForegroundColor Gray
    Write-Host "Role: $Role" -ForegroundColor Gray
    Write-Host "Concept ID: $ConceptId" -ForegroundColor Gray
    Write-Host ""
    
    $headers = @{
        "Authorization" = "Bearer $Token"
        "Content-Type" = "application/json"
        "Accept" = "application/json"
        "X-User-Role" = $Role
        "X-User-Permission" = "create.payment"
    }
    
    $body = @{
        concept_id = $ConceptId
    } | ConvertTo-Json
    
    Write-Host "📦 Request Body:" -ForegroundColor Gray
    Write-Host $body -ForegroundColor White
    Write-Host ""
    
    $response = Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Body $body -ErrorAction Stop
    
    Write-Host "✅ Intento de pago creado exitosamente!" -ForegroundColor Green
    Write-Host ""
    
    # Mostrar respuesta
    Write-Host "📊 RESPUESTA:" -ForegroundColor Cyan
    Write-Host "Success: $($response.success)" -ForegroundColor White
    Write-Host "Message: $($response.message)" -ForegroundColor White
    
    if ($response.data.url_checkout) {
        Write-Host ""
        Write-Host "🔗 URL DE CHECKOUT:" -ForegroundColor Cyan
        Write-Host $response.data.url_checkout -ForegroundColor Green
        Write-Host ""
        Write-Host "👉 Copia y pega esta URL en tu navegador para completar el pago" -ForegroundColor Yellow
        
        # Preguntar si desea abrir en el navegador
        $openBrowser = Read-Host "¿Deseas abrir el checkout en el navegador? (S/N)"
        if ($openBrowser -eq "S" -or $openBrowser -eq "s") {
            Start-Process $response.data.url_checkout
            Write-Host "✅ Navegador abierto" -ForegroundColor Green
        }
    }
    
    Write-Host ""
    Write-Host "📋 Respuesta completa (JSON):" -ForegroundColor Gray
    $response | ConvertTo-Json -Depth 10
    
} catch {
    Write-Host "❌ Error al crear intento de pago" -ForegroundColor Red
    Write-Host ""
    
    if ($_.Exception.Response) {
        $statusCode = [int]$_.Exception.Response.StatusCode
        Write-Host "Código de estado: $statusCode" -ForegroundColor Red
        
        $statusMessages = @{
            401 = "No autenticado - Verifica tu token"
            403 = "No autorizado - No tienes permisos para crear pagos"
            404 = "Concepto no encontrado - Verifica el ID del concepto"
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
Write-Host "# Crear intento de pago como estudiante:" -ForegroundColor Gray
Write-Host ".\test-create-payment-intent.ps1 -ConceptId 123 -Token 'tu_token' -Role 'student'" -ForegroundColor White
Write-Host ""
Write-Host "# Crear intento de pago como padre:" -ForegroundColor Gray
Write-Host ".\test-create-payment-intent.ps1 -ConceptId 123 -Token 'tu_token' -Role 'parent'" -ForegroundColor White
Write-Host ""
Write-Host "# Con URL base personalizada:" -ForegroundColor Gray
Write-Host ".\test-create-payment-intent.ps1 -ConceptId 123 -Token 'tu_token' -BaseUrl 'https://api.ejemplo.com/api/v1'" -ForegroundColor White
