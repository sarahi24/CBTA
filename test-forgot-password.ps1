# Script para probar el endpoint de forgot password
# Ejecutar: powershell -ExecutionPolicy Bypass -File test-forgot-password.ps1

param(
    [string]$Email = "admin@example.com"
)

$API_BASE = "https://nginx-production-728f.up.railway.app/api/v1"

Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   TEST ENDPOINT - FORGOT PASSWORD" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

Write-Host "📧 Solicitando link de recuperación para:" -ForegroundColor Yellow
Write-Host "   Email: $Email" -ForegroundColor Gray
Write-Host ""

$requestBody = @{
    email = $Email
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$API_BASE/forgot-password" -Method Post -Body $requestBody -ContentType "application/json"
    
    if ($response.success) {
        Write-Host "   ✅ Solicitud procesada exitosamente!" -ForegroundColor Green
        Write-Host ""
        Write-Host "   📬 RESULTADO:" -ForegroundColor Cyan
        Write-Host "   ────────────────────────────────────────────" -ForegroundColor Gray
        Write-Host "   💬 Mensaje: $($response.message)" -ForegroundColor Gray
        
        if ($response.data) {
            Write-Host ""
            Write-Host "   📊 Datos adicionales:" -ForegroundColor Cyan
            $response.data.PSObject.Properties | ForEach-Object {
                Write-Host "   • $($_.Name): $($_.Value)" -ForegroundColor Gray
            }
        }
        
        Write-Host ""
        Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
        Write-Host "   ✅ PRUEBA COMPLETADA EXITOSAMENTE" -ForegroundColor Green
        Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
        Write-Host ""
        Write-Host "📝 Notas importantes:" -ForegroundColor Cyan
        Write-Host "  • Se ha enviado un correo con el link de recuperación" -ForegroundColor Gray
        Write-Host "  • El link contiene un token que expira en un tiempo limitado" -ForegroundColor Gray
        Write-Host "  • Revisa la bandeja de entrada (y spam) del correo proporcionado" -ForegroundColor Gray
        Write-Host "  • Usa el token del email con el endpoint reset-password" -ForegroundColor Gray
        
    } else {
        Write-Host "   ⚠️  Solicitud no exitosa" -ForegroundColor Yellow
        Write-Host "   💬 Mensaje: $($response.message)" -ForegroundColor Gray
    }
    
} catch {
    $errorDetails = $_.ErrorDetails.Message
    
    if ($errorDetails) {
        try {
            $errorJson = $errorDetails | ConvertFrom-Json
            
            Write-Host "   ❌ Error al solicitar recuperación" -ForegroundColor Red
            Write-Host "   💬 Mensaje: $($errorJson.message)" -ForegroundColor Red
            
            if ($errorJson.error_code) {
                Write-Host "   🔍 Código de error: $($errorJson.error_code)" -ForegroundColor Red
            }
            
            if ($errorJson.errors) {
                Write-Host ""
                Write-Host "   📋 Detalles de errores:" -ForegroundColor Yellow
                foreach ($field in $errorJson.errors.PSObject.Properties) {
                    Write-Host "      • $($field.Name):" -ForegroundColor Yellow
                    foreach ($error in $field.Value) {
                        Write-Host "        - $error" -ForegroundColor Red
                    }
                }
            }
        } catch {
            Write-Host "   ❌ Error: $errorDetails" -ForegroundColor Red
        }
    } else {
        Write-Host "   ❌ Error al conectar con el servidor" -ForegroundColor Red
        Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Red
    Write-Host "   ❌ PRUEBA FALLÓ" -ForegroundColor Red
    Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   📊 INFORMACIÓN DEL ENDPOINT" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Endpoint: POST /api/v1/forgot-password" -ForegroundColor Gray
Write-Host "Parámetros requeridos:" -ForegroundColor Gray
Write-Host "  • email (string, debe existir en el sistema)" -ForegroundColor Gray
Write-Host ""
Write-Host "Flujo completo de recuperación:" -ForegroundColor Gray
Write-Host "  1. Usuario solicita recuperación (este endpoint)" -ForegroundColor Gray
Write-Host "  2. Sistema envía email con token" -ForegroundColor Gray
Write-Host "  3. Usuario recibe email con link" -ForegroundColor Gray
Write-Host "  4. Usuario usa token con endpoint reset-password" -ForegroundColor Gray
Write-Host ""
Write-Host "Ejemplos de uso:" -ForegroundColor Yellow
Write-Host '  .\test-forgot-password.ps1' -ForegroundColor Gray
Write-Host '  .\test-forgot-password.ps1 -Email "usuario@test.com"' -ForegroundColor Gray
Write-Host ""
