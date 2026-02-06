# Test script para obtener pagos vencidos
# Este script prueba el endpoint GET /api/v1/pending-payments/overdue/{studentId?}

param(
    [string]$BaseUrl = "http://localhost:8000/api/v1",
    [string]$Token = "",
    [string]$StudentId = "",
    [string]$Role = "student",
    [switch]$ForceRefresh
)

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "TEST: Obtener Pagos Vencidos" -ForegroundColor Cyan
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
    $url = if ([string]::IsNullOrWhiteSpace($StudentId)) {
        "$BaseUrl/pending-payments/overdue"
    } else {
        "$BaseUrl/pending-payments/overdue/$StudentId"
    }
    
    # Agregar query parameters
    if ($ForceRefresh) {
        $url += "?forceRefresh=true"
    }
    
    Write-Host "🔄 Obteniendo pagos vencidos..." -ForegroundColor Yellow
    Write-Host "URL: $url" -ForegroundColor Gray
    Write-Host "Role: $Role" -ForegroundColor Gray
    if (![string]::IsNullOrWhiteSpace($StudentId)) {
        Write-Host "Student ID: $StudentId" -ForegroundColor Gray
    }
    Write-Host ""
    
    $headers = @{
        "Authorization" = "Bearer $Token"
        "Content-Type" = "application/json"
        "Accept" = "application/json"
        "X-User-Role" = $Role
        "X-User-Permission" = "view.overdue.concepts"
    }
    
    $response = Invoke-RestMethod -Uri $url -Method Get -Headers $headers -ErrorAction Stop
    
    Write-Host "✅ Pagos vencidos obtenidos exitosamente!" -ForegroundColor Green
    Write-Host ""
    
    # Mostrar respuesta
    Write-Host "📊 RESPUESTA:" -ForegroundColor Cyan
    Write-Host "Success: $($response.success)" -ForegroundColor White
    Write-Host "Message: $($response.message)" -ForegroundColor White
    
    if ($response.data.pending_payments) {
        $payments = $response.data.pending_payments
        Write-Host ""
        Write-Host "⚠️  PAGOS VENCIDOS: $($payments.Count)" -ForegroundColor Red
        Write-Host ""
        
        $totalAmount = 0
        foreach ($payment in $payments) {
            Write-Host "  📌 Pago #$($payment.id)" -ForegroundColor Yellow
            Write-Host "     Concepto: $($payment.concept_name)" -ForegroundColor White
            Write-Host "     Descripción: $($payment.description)" -ForegroundColor Gray
            Write-Host "     Monto: `$$($payment.amount) MXN" -ForegroundColor Red
            Write-Host "     Fecha inicio: $($payment.start_date)" -ForegroundColor Gray
            Write-Host "     Fecha vencimiento: $($payment.end_date)" -ForegroundColor Red
            
            if ($payment.student_id) {
                Write-Host "     Student ID: $($payment.student_id)" -ForegroundColor Gray
            }
            
            Write-Host ""
            $totalAmount += [decimal]$payment.amount
        }
        
        Write-Host "⚠️  TOTAL VENCIDO: `$$($totalAmount.ToString('N2')) MXN" -ForegroundColor Red
        Write-Host ""
        Write-Host "🚨 ACCIÓN REQUERIDA: Estos pagos están vencidos y requieren atención inmediata" -ForegroundColor Yellow
    } else {
        Write-Host ""
        Write-Host "✅ No hay pagos vencidos" -ForegroundColor Green
        Write-Host ""
        Write-Host "📝 Todos los pagos están al día" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "📋 Respuesta completa (JSON):" -ForegroundColor Gray
    $response | ConvertTo-Json -Depth 10
    
} catch {
    Write-Host "❌ Error al obtener pagos vencidos" -ForegroundColor Red
    Write-Host ""
    
    if ($_.Exception.Response) {
        $statusCode = [int]$_.Exception.Response.StatusCode
        Write-Host "Código de estado: $statusCode" -ForegroundColor Red
        
        $statusMessages = @{
            401 = "No autenticado - Verifica tu token"
            403 = "No autorizado - No tienes permisos para ver pagos vencidos"
            404 = "No encontrado - Verifica el ID del estudiante"
            422 = "Error de validación - Verifica los datos enviados"
            429 = "Demasiadas solicitudes - Espera un momento e intenta de nuevo"
            500 = "Error interno del servidor"
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
Write-Host "# Como estudiante (sin studentId):" -ForegroundColor Gray
Write-Host ".\test-overdue-payments.ps1 -Token 'tu_token' -Role 'student'" -ForegroundColor White
Write-Host ""
Write-Host "# Como padre (con studentId específico):" -ForegroundColor Gray
Write-Host ".\test-overdue-payments.ps1 -Token 'tu_token' -Role 'parent' -StudentId 3" -ForegroundColor White
Write-Host ""
Write-Host "# Con forzar actualización de caché:" -ForegroundColor Gray
Write-Host ".\test-overdue-payments.ps1 -Token 'tu_token' -ForceRefresh" -ForegroundColor White
Write-Host ""
Write-Host "# Con URL base personalizada:" -ForegroundColor Gray
Write-Host ".\test-overdue-payments.ps1 -Token 'tu_token' -BaseUrl 'https://api.ejemplo.com/api/v1' -ForceRefresh" -ForegroundColor White
