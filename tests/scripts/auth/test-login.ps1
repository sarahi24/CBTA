# Script para probar el endpoint de login
# Ejecutar: powershell -ExecutionPolicy Bypass -File test-login.ps1

param(
    [string]$TestEmail = "admin@example.com",
    [string]$TestPassword = "password"
)

$API_BASE = "https://nginx-production-728f.up.railway.app/api/v1"

Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   TEST ENDPOINT - LOGIN DE USUARIO" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

Write-Host "📝 Intentando login con:" -ForegroundColor Yellow
Write-Host "   📧 Email: $TestEmail" -ForegroundColor Gray
Write-Host "   🔑 Password: ********" -ForegroundColor Gray
Write-Host ""

$loginBody = @{
    email = $TestEmail
    password = $TestPassword
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$API_BASE/auth/login" -Method Post -Body $loginBody -ContentType "application/json"
    
    if ($response.success) {
        Write-Host "   ✅ Login exitoso!" -ForegroundColor Green
        Write-Host ""
        
        Write-Host "   📊 DATOS DEL USUARIO:" -ForegroundColor Cyan
        Write-Host "   ────────────────────────────────────────────" -ForegroundColor Gray
        Write-Host "   👤 ID: $($response.data.user.id)" -ForegroundColor Gray
        Write-Host "   📛 Nombre: $($response.data.user.name)" -ForegroundColor Gray
        Write-Host "   📧 Email: $($response.data.user.email)" -ForegroundColor Gray
        
        if ($response.data.user.email_verified_at) {
            Write-Host "   ✅ Email verificado: $($response.data.user.email_verified_at)" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️  Email NO verificado" -ForegroundColor Yellow
        }
        
        Write-Host ""
        Write-Host "   🔑 TOKEN DE ACCESO:" -ForegroundColor Cyan
        Write-Host "   ────────────────────────────────────────────" -ForegroundColor Gray
        $tokenPreview = $response.data.token.Substring(0, [Math]::Min(50, $response.data.token.Length))
        Write-Host "   $tokenPreview..." -ForegroundColor Gray
        Write-Host ""
        
        if ($response.data.roles) {
            Write-Host "   👔 ROLES:" -ForegroundColor Cyan
            Write-Host "   ────────────────────────────────────────────" -ForegroundColor Gray
            foreach ($role in $response.data.roles) {
                Write-Host "   • $role" -ForegroundColor Gray
            }
            Write-Host ""
        }
        
        if ($response.data.permissions) {
            Write-Host "   🔐 PERMISOS (primeros 5):" -ForegroundColor Cyan
            Write-Host "   ────────────────────────────────────────────" -ForegroundColor Gray
            $permissionCount = 0
            foreach ($permission in $response.data.permissions) {
                if ($permissionCount -lt 5) {
                    Write-Host "   • $permission" -ForegroundColor Gray
                    $permissionCount++
                }
            }
            if ($response.data.permissions.Count -gt 5) {
                Write-Host "   ... y $($response.data.permissions.Count - 5) más" -ForegroundColor DarkGray
            }
            Write-Host ""
        }
        
        Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
        Write-Host "   ✅ PRUEBA COMPLETADA EXITOSAMENTE" -ForegroundColor Green
        Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
        
    } else {
        Write-Host "   ⚠️  Login no exitoso" -ForegroundColor Yellow
        Write-Host "   💬 Mensaje: $($response.message)" -ForegroundColor Gray
    }
    
} catch {
    $errorDetails = $_.ErrorDetails.Message
    
    if ($errorDetails) {
        try {
            $errorJson = $errorDetails | ConvertFrom-Json
            
            Write-Host "   ❌ Error en el login" -ForegroundColor Red
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
Write-Host "Endpoint: POST /api/v1/auth/login" -ForegroundColor Gray
Write-Host "Parámetros requeridos:" -ForegroundColor Gray
Write-Host "  • email (string)" -ForegroundColor Gray
Write-Host "  • password (string)" -ForegroundColor Gray
Write-Host ""
Write-Host "Ejemplos de uso:" -ForegroundColor Yellow
Write-Host '  .\test-login.ps1' -ForegroundColor Gray
Write-Host '  .\test-login.ps1 -TestEmail "usuario@test.com" -TestPassword "clave123"' -ForegroundColor Gray
Write-Host ""
