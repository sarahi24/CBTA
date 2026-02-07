# Script para probar el endpoint de registro de usuario
# Ejecutar: powershell -ExecutionPolicy Bypass -File test-register.ps1

param(
    [string]$Name = "Usuario Prueba",
    [string]$Email = "prueba_$(Get-Date -Format 'yyyyMMddHHmmss')@test.com",
    [string]$Password = "Password123!",
    [string]$PasswordConfirmation = "Password123!"
)

$API_BASE = "https://nginx-production-728f.up.railway.app/api/v1"

Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   TEST ENDPOINT - REGISTRO DE USUARIO" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

Write-Host "📝 Intentando registrar usuario con:" -ForegroundColor Yellow
Write-Host "   📛 Nombre: $Name" -ForegroundColor Gray
Write-Host "   📧 Email: $Email" -ForegroundColor Gray
Write-Host "   🔑 Password: ********" -ForegroundColor Gray
Write-Host ""

$registerBody = @{
    name = $Name
    email = $Email
    password = $Password
    password_confirmation = $PasswordConfirmation
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$API_BASE/auth/register" -Method Post -Body $registerBody -ContentType "application/json"
    
    if ($response.success) {
        Write-Host "   ✅ Registro exitoso!" -ForegroundColor Green
        Write-Host ""
        
        Write-Host "   📊 DATOS DEL NUEVO USUARIO:" -ForegroundColor Cyan
        Write-Host "   ────────────────────────────────────────────" -ForegroundColor Gray
        Write-Host "   👤 ID: $($response.data.user.id)" -ForegroundColor Gray
        Write-Host "   📛 Nombre: $($response.data.user.name)" -ForegroundColor Gray
        Write-Host "   📧 Email: $($response.data.user.email)" -ForegroundColor Gray
        
        if ($response.data.user.email_verified_at) {
            Write-Host "   ✅ Email verificado: $($response.data.user.email_verified_at)" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️  Email NO verificado (debe verificar su correo)" -ForegroundColor Yellow
        }
        
        Write-Host ""
        Write-Host "   🔑 TOKEN DE ACCESO GENERADO:" -ForegroundColor Cyan
        Write-Host "   ────────────────────────────────────────────" -ForegroundColor Gray
        $tokenPreview = $response.data.token.Substring(0, [Math]::Min(50, $response.data.token.Length))
        Write-Host "   $tokenPreview..." -ForegroundColor Gray
        Write-Host ""
        
        Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
        Write-Host "   ✅ PRUEBA COMPLETADA EXITOSAMENTE" -ForegroundColor Green
        Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
        Write-Host ""
        Write-Host "📝 Nota: El usuario debe verificar su email antes de usar todas las funcionalidades" -ForegroundColor Cyan
        
    } else {
        Write-Host "   ⚠️  Registro no exitoso" -ForegroundColor Yellow
        Write-Host "   💬 Mensaje: $($response.message)" -ForegroundColor Gray
    }
    
} catch {
    $errorDetails = $_.ErrorDetails.Message
    
    if ($errorDetails) {
        try {
            $errorJson = $errorDetails | ConvertFrom-Json
            
            Write-Host "   ❌ Error en el registro" -ForegroundColor Red
            Write-Host "   💬 Mensaje: $($errorJson.message)" -ForegroundColor Red
            
            if ($errorJson.error_code) {
                Write-Host "   🔍 Código de error: $($errorJson.error_code)" -ForegroundColor Red
            }
            
            if ($errorJson.errors) {
                Write-Host ""
                Write-Host "   📋 Detalles de errores de validación:" -ForegroundColor Yellow
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
Write-Host "Endpoint: POST /api/v1/auth/register" -ForegroundColor Gray
Write-Host "Parámetros requeridos:" -ForegroundColor Gray
Write-Host "  • name (string)" -ForegroundColor Gray
Write-Host "  • email (string, único)" -ForegroundColor Gray
Write-Host "  • password (string, mínimo 8 caracteres)" -ForegroundColor Gray
Write-Host "  • password_confirmation (string, debe coincidir)" -ForegroundColor Gray
Write-Host ""
Write-Host "Ejemplos de uso:" -ForegroundColor Yellow
Write-Host '  .\test-register.ps1' -ForegroundColor Gray
Write-Host '  .\test-register.ps1 -Name "Juan Perez" -Email "juan@test.com" -Password "MiClave123!" -PasswordConfirmation "MiClave123!"' -ForegroundColor Gray
Write-Host ""
Write-Host "💡 Tip: Si no especificas email, se genera uno automático con timestamp" -ForegroundColor Cyan
Write-Host ""
