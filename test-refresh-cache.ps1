# Script para probar el endpoint de limpieza de caché del dashboard
# POST /api/v1/dashboard-staff/refresh

$API_BASE = "https://nginx-production-728f.up.railway.app/api/v1"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  TEST: Limpiar Caché del Dashboard" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Solicitar token (o usar uno guardado)
$token = Read-Host "Ingresa tu token de acceso (o presiona Enter para usar uno de prueba)"
if ([string]::IsNullOrWhiteSpace($token)) {
    Write-Host "⚠️ No se proporcionó token. Usando token de prueba..." -ForegroundColor Yellow
    $token = "tu_token_aqui"
}

Write-Host ""
Write-Host "📡 Enviando petición POST a: $API_BASE/dashboard-staff/refresh" -ForegroundColor Yellow
Write-Host ""

try {
    # Preparar headers
    $headers = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json"
        "Accept" = "application/json"
        "X-User-Role" = "financial-staff"
        "X-User-Permission" = "refresh.all.dashboard"
    }

    # Hacer la petición POST
    $response = Invoke-RestMethod -Uri "$API_BASE/dashboard-staff/refresh" `
        -Method Post `
        -Headers $headers `
        -ErrorAction Stop

    # Mostrar respuesta exitosa
    Write-Host "✅ ÉXITO: Caché limpiado correctamente" -ForegroundColor Green
    Write-Host ""
    Write-Host "📦 Respuesta completa:" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
    $response | ConvertTo-Json -Depth 10
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
    Write-Host ""
    
    if ($response.success) {
        Write-Host "✨ $($response.message)" -ForegroundColor Green
    }

} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    $statusDescription = $_.Exception.Response.StatusDescription
    
    Write-Host "❌ ERROR: $statusCode - $statusDescription" -ForegroundColor Red
    Write-Host ""
    
    try {
        $errorResponse = $_.ErrorDetails.Message | ConvertFrom-Json
        Write-Host "📦 Respuesta de error:" -ForegroundColor Yellow
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
        $errorResponse | ConvertTo-Json -Depth 10
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
        
        if ($errorResponse.message) {
            Write-Host ""
            Write-Host "💡 Mensaje: $($errorResponse.message)" -ForegroundColor Yellow
        }
        
        if ($errorResponse.error_code) {
            Write-Host "🔍 Código: $($errorResponse.error_code)" -ForegroundColor Yellow
        }

        # Casos específicos
        switch ($statusCode) {
            401 {
                Write-Host ""
                Write-Host "⚠️ No autenticado. Verifica tu token de acceso." -ForegroundColor Red
            }
            403 {
                Write-Host ""
                Write-Host "⚠️ No autorizado. Verifica que tengas:" -ForegroundColor Red
                Write-Host "   - Rol: financial-staff" -ForegroundColor Yellow
                Write-Host "   - Permiso: refresh.all.dashboard" -ForegroundColor Yellow
            }
            429 {
                Write-Host ""
                Write-Host "⚠️ Demasiadas solicitudes. Espera un momento e intenta nuevamente." -ForegroundColor Red
            }
            500 {
                Write-Host ""
                Write-Host "⚠️ Error interno del servidor. Revisa los logs del backend." -ForegroundColor Red
            }
        }
        
    } catch {
        Write-Host "Detalles del error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Fin de la prueba" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Preguntar si desea reintentar
$retry = Read-Host "¿Deseas intentar nuevamente? (s/n)"
if ($retry -eq "s" -or $retry -eq "S") {
    Write-Host ""
    & $PSCommandPath
}
