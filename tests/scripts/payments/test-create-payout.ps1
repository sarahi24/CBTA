# Test script para crear payout
# Este script prueba el endpoint POST /api/v1/dashboard-staff/payout

param(
    [string]$BaseUrl = "http://localhost:8000/api/v1",
    [string]$Token = ""
)

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "TEST: Crear Payout" -ForegroundColor Cyan
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
    $url = "$BaseUrl/dashboard-staff/payout"
    
    Write-Host "🔄 Creando payout..." -ForegroundColor Yellow
    Write-Host "URL: $url" -ForegroundColor Gray
    Write-Host ""
    
    $headers = @{
        "Authorization" = "Bearer $Token"
        "Content-Type" = "application/json"
        "Accept" = "application/json"
        "X-User-Role" = "financial-staff"
        "X-User-Permission" = "create.payout"
    }
    
    $response = Invoke-RestMethod -Uri $url -Method Post -Headers $headers -ErrorAction Stop
    
    Write-Host "✅ Payout creado exitosamente!" -ForegroundColor Green
    Write-Host ""
    
    # Mostrar respuesta
    Write-Host "📊 RESPUESTA:" -ForegroundColor Cyan
    Write-Host "Success: $($response.success)" -ForegroundColor White
    Write-Host "Message: $($response.message)" -ForegroundColor White
    
    if ($response.data.payout) {
        $payout = $response.data.payout
        Write-Host ""
        Write-Host "💰 DETALLES DEL PAYOUT:" -ForegroundColor Cyan
        Write-Host "  Payout ID: $($payout.payout_id)" -ForegroundColor White
        Write-Host "  Monto: $$($payout.amount) $($payout.currency.ToUpper())" -ForegroundColor Green
        Write-Host "  Estado: $($payout.status)" -ForegroundColor Yellow
        Write-Host "  Fecha estimada de llegada: $($payout.arrival_date)" -ForegroundColor White
        Write-Host "  Balance disponible antes del payout: $$($payout.available_before_payout)" -ForegroundColor White
        
        if ($payout.success) {
            Write-Host ""
            Write-Host "✅ Transferencia iniciada correctamente" -ForegroundColor Green
        }
    }
    
    Write-Host ""
    Write-Host "📋 Respuesta completa (JSON):" -ForegroundColor Gray
    $response | ConvertTo-Json -Depth 10
    
} catch {
    Write-Host "❌ Error al crear payout" -ForegroundColor Red
    Write-Host ""
    
    if ($_.Exception.Response) {
        $statusCode = [int]$_.Exception.Response.StatusCode
        Write-Host "Código de estado: $statusCode" -ForegroundColor Red
        
        try {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $responseBody = $reader.ReadToEnd() | ConvertFrom-Json
            
            Write-Host "Mensaje: $($responseBody.message)" -ForegroundColor Yellow
            
            if ($responseBody.error_code) {
                Write-Host "Código de error: $($responseBody.error_code)" -ForegroundColor Yellow
            }
            
            if ($responseBody.errors) {
                Write-Host ""
                Write-Host "Errores:" -ForegroundColor Yellow
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
