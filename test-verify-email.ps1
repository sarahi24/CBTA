# Script para probar el endpoint de verify email
# Ejecutar: powershell -ExecutionPolicy Bypass -File test-verify-email.ps1

param(
    [string]$UserId = "",
    [string]$Hash = ""
)

$API_BASE = "https://nginx-production-728f.up.railway.app/api/v1"

Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   TEST ENDPOINT - VERIFY EMAIL" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

if ([string]::IsNullOrWhiteSpace($UserId) -or [string]::IsNullOrWhiteSpace($Hash)) {
    Write-Host "⚠️  ERROR: Debes proporcionar UserId y Hash" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "💡 Cómo obtener estos parámetros:" -ForegroundColor Cyan
    Write-Host "  1. Registra un nuevo usuario con test-register.ps1" -ForegroundColor Gray
    Write-Host "  2. Revisa el correo de verificación recibido" -ForegroundColor Gray
    Write-Host "  3. El link tendrá este formato:" -ForegroundColor Gray
    Write-Host "     https://dominio.com/api/v1/verify-email/{id}/{hash}" -ForegroundColor Gray
    Write-Host "  4. Copia el ID y el hash del link" -ForegroundColor Gray
    Write-Host "  5. Ejecuta:" -ForegroundColor Gray
    Write-Host '     .\test-verify-email.ps1 -UserId "123" -Hash "abc123hash"' -ForegroundColor Gray
    Write-Host ""
    Write-Host "📝 Alternativa: También puedes obtenerlos ejecutando:" -ForegroundColor Cyan
    Write-Host '     .\test-email-verification.ps1' -ForegroundColor Gray
    Write-Host ""
    exit 1
}

Write-Host "✉️  Intentando verificar email:" -ForegroundColor Yellow
Write-Host "   👤 User ID: $UserId" -ForegroundColor Gray
Write-Host "   🔑 Hash: $($Hash.Substring(0, [Math]::Min(20, $Hash.Length)))..." -ForegroundColor Gray
Write-Host ""

$url = "$API_BASE/verify-email/$UserId/$Hash"

try {
    $response = Invoke-RestMethod -Uri $url -Method Get
    
    if ($response.success) {
        Write-Host "   ✅ Email verificado exitosamente!" -ForegroundColor Green
        Write-Host ""
        Write-Host "   📬 RESULTADO:" -ForegroundColor Cyan
        Write-Host "   ────────────────────────────────────────────" -ForegroundColor Gray
        Write-Host "   💬 Mensaje: $($response.message)" -ForegroundColor Gray
        
        if ($response.data) {
            Write-Host ""
            Write-Host "   📊 Información del usuario:" -ForegroundColor Cyan
            $response.data.PSObject.Properties | ForEach-Object {
                if ($_.Name -eq "user") {
                    Write-Host "   👤 Usuario:" -ForegroundColor Cyan
                    Write-Host "      • ID: $($_.Value.id)" -ForegroundColor Gray
                    Write-Host "      • Nombre: $($_.Value.name)" -ForegroundColor Gray
                    Write-Host "      • Email: $($_.Value.email)" -ForegroundColor Gray
                    if ($_.Value.email_verified_at) {
                        Write-Host "      • Verificado en: $($_.Value.email_verified_at)" -ForegroundColor Green
                    }
                } else {
                    Write-Host "   • $($_.Name): $($_.Value)" -ForegroundColor Gray
                }
            }
        }
        
        Write-Host ""
        Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
        Write-Host "   ✅ PRUEBA COMPLETADA EXITOSAMENTE" -ForegroundColor Green
        Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
        Write-Host ""
        Write-Host "📝 El usuario ahora puede acceder a todas las funcionalidades" -ForegroundColor Cyan
        
    } else {
        Write-Host "   ⚠️  Verificación no exitosa" -ForegroundColor Yellow
        Write-Host "   💬 Mensaje: $($response.message)" -ForegroundColor Gray
    }
    
} catch {
    $errorDetails = $_.ErrorDetails.Message
    
    if ($errorDetails) {
        try {
            $errorJson = $errorDetails | ConvertFrom-Json
            
            Write-Host "   ❌ Error al verificar email" -ForegroundColor Red
            Write-Host "   💬 Mensaje: $($errorJson.message)" -ForegroundColor Red
            
            # Manejar diferentes códigos de estado
            $statusCode = $_.Exception.Response.StatusCode.value__
            
            switch ($statusCode) {
                403 {
                    Write-Host "   🔒 Acceso prohibido: Link inválido o expirado" -ForegroundColor Red
                }
                404 {
                    Write-Host "   🔍 Usuario no encontrado" -ForegroundColor Red
                }
                409 {
                    Write-Host "   ℹ️  El email ya fue verificado anteriormente" -ForegroundColor Yellow
                }
            }
            
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
            
            Write-Host ""
            Write-Host "💡 Posibles causas del error:" -ForegroundColor Cyan
            Write-Host "  • Hash inválido o expirado" -ForegroundColor Gray
            Write-Host "  • User ID incorrecto" -ForegroundColor Gray
            Write-Host "  • Email ya verificado previamente" -ForegroundColor Gray
            Write-Host "  • Link de verificación ya usado" -ForegroundColor Gray
            
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
Write-Host "Endpoint: GET /api/v1/verify-email/{id}/{hash}" -ForegroundColor Gray
Write-Host "Parámetros de ruta:" -ForegroundColor Gray
Write-Host "  • id (integer, ID del usuario)" -ForegroundColor Gray
Write-Host "  • hash (string, hash de verificación)" -ForegroundColor Gray
Write-Host ""
Write-Host "Flujo de verificación:" -ForegroundColor Gray
Write-Host "  1. Usuario se registra (POST /api/v1/auth/register)" -ForegroundColor Gray
Write-Host "  2. Sistema envía email con link de verificación" -ForegroundColor Gray
Write-Host "  3. Usuario hace clic en el link (este endpoint)" -ForegroundColor Gray
Write-Host "  4. Sistema marca el email como verificado" -ForegroundColor Gray
Write-Host ""
Write-Host "Ejemplos de uso:" -ForegroundColor Yellow
Write-Host '  .\test-verify-email.ps1 -UserId "123" -Hash "abc123def456hash"' -ForegroundColor Gray
Write-Host ""
Write-Host "💡 Tip: Los parámetros se obtienen del correo de verificación" -ForegroundColor Cyan
Write-Host ""
