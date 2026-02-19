# Script para probar el endpoint de reset password
# Ejecutar: powershell -ExecutionPolicy Bypass -File test-reset-password.ps1

param(
    [string]$Email = "admin@example.com",
    [string]$Token = "",
    [string]$Password = "NewPassword123!",
    [string]$PasswordConfirmation = "NewPassword123!"
)

$API_BASE = "https://nginx-production-728f.up.railway.app"

Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   TEST ENDPOINT - RESET PASSWORD" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

if ([string]::IsNullOrWhiteSpace($Token)) {
    Write-Host "⚠️  ERROR: Debes proporcionar un token de recuperación" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "💡 Cómo obtener un token:" -ForegroundColor Cyan
    Write-Host "  1. Ejecuta: .\test-forgot-password.ps1 -Email `"$Email`"" -ForegroundColor Gray
    Write-Host "  2. Revisa el correo electrónico" -ForegroundColor Gray
    Write-Host "  3. Copia el token del link recibido" -ForegroundColor Gray
    Write-Host "  4. Ejecuta este script con el token:" -ForegroundColor Gray
    Write-Host '     .\test-reset-password.ps1 -Email "usuario@test.com" -Token "TOKEN_AQUI"' -ForegroundColor Gray
    Write-Host ""
    exit 1
}

Write-Host "🔒 Intentando restablecer contraseña para:" -ForegroundColor Yellow
Write-Host "   📧 Email: $Email" -ForegroundColor Gray
Write-Host "   🔑 Token: $($Token.Substring(0, [Math]::Min(20, $Token.Length)))..." -ForegroundColor Gray
Write-Host "   🆕 Nueva contraseña: ********" -ForegroundColor Gray
Write-Host ""

$requestBody = @{
    email = $Email
    token = $Token
    password = $Password
    password_confirmation = $PasswordConfirmation
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$API_BASE/api/reset-password" -Method Post -Body $requestBody -ContentType "application/json"
    
    if ($response.success) {
        Write-Host "   ✅ Contraseña restablecida exitosamente!" -ForegroundColor Green
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
        
        # Intentar login con la nueva contraseña
        Write-Host "🧪 Probando login con la nueva contraseña..." -ForegroundColor Yellow
        $loginBody = @{
            email = $Email
            password = $Password
        } | ConvertTo-Json
        
        try {
            $loginResponse = Invoke-RestMethod -Uri "$API_BASE/api/v1/auth/login" -Method Post -Body $loginBody -ContentType "application/json"
            
            if ($loginResponse.success) {
                Write-Host "   ✅ Login exitoso con la nueva contraseña!" -ForegroundColor Green
                Write-Host "   👤 Usuario: $($loginResponse.data.user.name)" -ForegroundColor Gray
            }
        } catch {
            Write-Host "   ⚠️  No se pudo verificar con login automático" -ForegroundColor Yellow
        }
        
    } else {
        Write-Host "   ⚠️  Restablecimiento no exitoso" -ForegroundColor Yellow
        Write-Host "   💬 Mensaje: $($response.message)" -ForegroundColor Gray
    }
    
} catch {
    $errorDetails = $_.ErrorDetails.Message
    
    if ($errorDetails) {
        try {
            $errorJson = $errorDetails | ConvertFrom-Json
            
            Write-Host "   ❌ Error al restablecer contraseña" -ForegroundColor Red
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
            
            Write-Host ""
            Write-Host "💡 Posibles causas del error:" -ForegroundColor Cyan
            Write-Host "  • Token expirado o inválido" -ForegroundColor Gray
            Write-Host "  • Email no coincide con el token" -ForegroundColor Gray
            Write-Host "  • Las contraseñas no coinciden" -ForegroundColor Gray
            Write-Host "  • La contraseña no cumple los requisitos mínimos" -ForegroundColor Gray
            
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
Write-Host "Endpoint: POST /api/reset-password" -ForegroundColor Cyan
Write-Host "Parámetros requeridos:" -ForegroundColor Gray
Write-Host "  • email (string, debe ser válido)" -ForegroundColor Gray
Write-Host "  • token (string, obtenido del correo de recuperación)" -ForegroundColor Gray
Write-Host "  • password (string, mínimo 8 caracteres)" -ForegroundColor Gray
Write-Host "  • password_confirmation (string, debe coincidir exactamente)" -ForegroundColor Gray
Write-Host "" -ForegroundColor Gray
Write-Host "Respuestas esperadas:" -ForegroundColor Gray
Write-Host "  • 200: Contraseña actualizada correctamente" -ForegroundColor Green
Write-Host "  • 422: Validación fallida o token inválido" -ForegroundColor Red
Write-Host ""
Write-Host "Ejemplos de uso:" -ForegroundColor Yellow
Write-Host '  .\test-reset-password.ps1 -Email "user@test.com" -Token "abc123token" -Password "NuevaClave123!" -PasswordConfirmation "NuevaClave123!"' -ForegroundColor Gray
Write-Host ""
Write-Host "💡 Recuerda: Primero debes ejecutar test-forgot-password.ps1 para obtener el token" -ForegroundColor Cyan
Write-Host ""
