# Script para probar el endpoint de verificación de email
# Ejecutar: powershell -ExecutionPolicy Bypass -File test-email-verification.ps1

param(
    [string]$TestEmail = "admin@example.com",
    [string]$TestPassword = "password"
)

$API_BASE = "https://nginx-production-728f.up.railway.app/api/v1"

Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   TEST ENDPOINT - VERIFICACIÓN DE EMAIL" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Paso 1: Login
Write-Host "📝 PASO 1: Autenticación..." -ForegroundColor Yellow
$loginBody = @{
    email = $TestEmail
    password = $TestPassword
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "$API_BASE/auth/login" -Method Post -Body $loginBody -ContentType "application/json"
    
    if ($loginResponse.success) {
        $token = $loginResponse.data.token
        Write-Host "   ✅ Login exitoso!" -ForegroundColor Green
        Write-Host "   👤 Usuario: $($loginResponse.data.user.name)" -ForegroundColor Gray
        Write-Host "   📧 Email: $($loginResponse.data.user.email)" -ForegroundColor Gray
        
        if ($loginResponse.data.user.email_verified_at) {
            Write-Host "   ✅ Email ya verificado en: $($loginResponse.data.user.email_verified_at)" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️  Email sin verificar" -ForegroundColor Yellow
        }
        Write-Host ""
    } else {
        Write-Host "   ❌ Login falló: $($loginResponse.message)" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "   ❌ Error al conectar con el servidor" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

# Paso 2: Enviar enlace de verificación
Write-Host "📧 PASO 2: Enviando enlace de verificación de email..." -ForegroundColor Yellow
Write-Host ""

try {
    $response = Invoke-RestMethod -Uri "$API_BASE/email/verification-notification" -Method Post -Headers $headers
    
    if ($response.success) {
        Write-Host "   ✅ Respuesta exitosa!" -ForegroundColor Green
        Write-Host "   📬 Estado: $($response.data.status)" -ForegroundColor Gray
        Write-Host "   💬 Mensaje: $($response.message)" -ForegroundColor Gray
        Write-Host ""
        
        Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
        Write-Host "   ✅ PRUEBA COMPLETADA EXITOSAMENTE" -ForegroundColor Green
        Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
        Write-Host ""
        Write-Host "📝 Nota: Revisa el correo electrónico para verificar la recepción del enlace" -ForegroundColor Cyan
    } else {
        Write-Host "   ⚠️  Respuesta no exitosa" -ForegroundColor Yellow
        Write-Host "   💬 Mensaje: $($response.message)" -ForegroundColor Gray
    }
    
} catch {
    $errorDetails = $_.ErrorDetails.Message
    
    if ($errorDetails) {
        try {
            $errorJson = $errorDetails | ConvertFrom-Json
            
            Write-Host "   ❌ Error al enviar verificación" -ForegroundColor Red
            Write-Host "   💬 Mensaje: $($errorJson.message)" -ForegroundColor Red
            
            # Caso 302: Ya verificado (puede redirigir al dashboard)
            if ($_.Exception.Response.StatusCode -eq 302) {
                Write-Host "   ℹ️  El email ya está verificado" -ForegroundColor Cyan
                Write-Host "   🔄 Redirección al dashboard" -ForegroundColor Cyan
            }
            
            # Caso 401: No autenticado
            if ($_.Exception.Response.StatusCode -eq 401) {
                Write-Host "   🔒 Error de autenticación" -ForegroundColor Red
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
        } catch {
            Write-Host "   ❌ Error: $errorDetails" -ForegroundColor Red
        }
    } else {
        Write-Host "   ❌ Error al enviar verificación" -ForegroundColor Red
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
Write-Host "   📊 RESUMEN DE LA PRUEBA" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Usuario: $TestEmail" -ForegroundColor Gray
Write-Host "Endpoint: POST /api/v1/email/verification-notification" -ForegroundColor Gray
Write-Host ""
Write-Host "Instrucciones de uso:" -ForegroundColor Yellow
Write-Host "  1. Ejecuta este script con un usuario sin verificar" -ForegroundColor Gray
Write-Host "  2. Revisa el correo electrónico del usuario" -ForegroundColor Gray
Write-Host "  3. Haz clic en el enlace de verificación" -ForegroundColor Gray
Write-Host ""
Write-Host "Ejemplos de uso:" -ForegroundColor Yellow
Write-Host '  .\test-email-verification.ps1' -ForegroundColor Gray
Write-Host '  .\test-email-verification.ps1 -TestEmail "usuario@test.com" -TestPassword "clave123"' -ForegroundColor Gray
Write-Host ""
