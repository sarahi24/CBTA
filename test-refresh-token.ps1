# Script para probar el endpoint de refresh token
# Ejecutar: powershell -ExecutionPolicy Bypass -File test-refresh-token.ps1

param(
    [string]$TestEmail = "admin@example.com",
    [string]$TestPassword = "password"
)

$API_BASE = "https://nginx-production-728f.up.railway.app/api/v1"

Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   TEST ENDPOINT - REFRESH TOKEN" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Paso 1: Login para obtener token inicial
Write-Host "📝 PASO 1: Login inicial para obtener token..." -ForegroundColor Yellow
$loginBody = @{
    email = $TestEmail
    password = $TestPassword
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "$API_BASE/auth/login" -Method Post -Body $loginBody -ContentType "application/json"
    
    if ($loginResponse.success) {
        $oldToken = $loginResponse.data.token
        Write-Host "   ✅ Login exitoso!" -ForegroundColor Green
        Write-Host "   👤 Usuario: $($loginResponse.data.user.name)" -ForegroundColor Gray
        $oldTokenPreview = $oldToken.Substring(0, [Math]::Min(30, $oldToken.Length))
        Write-Host "   🔑 Token obtenido: $oldTokenPreview..." -ForegroundColor Gray
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

# Paso 2: Refrescar el token
Write-Host "🔄 PASO 2: Refrescando token de acceso..." -ForegroundColor Yellow
Write-Host ""

$headers = @{
    "Authorization" = "Bearer $oldToken"
    "Content-Type" = "application/json"
}

try {
    $response = Invoke-RestMethod -Uri "$API_BASE/auth/refresh-token" -Method Post -Headers $headers
    
    if ($response.success) {
        Write-Host "   ✅ Token refrescado exitosamente!" -ForegroundColor Green
        Write-Host ""
        
        Write-Host "   🔑 COMPARACIÓN DE TOKENS:" -ForegroundColor Cyan
        Write-Host "   ────────────────────────────────────────────" -ForegroundColor Gray
        $oldTokenPreview = $oldToken.Substring(0, [Math]::Min(40, $oldToken.Length))
        Write-Host "   🔴 Token anterior: $oldTokenPreview..." -ForegroundColor Red
        
        $newToken = $response.data.token
        $newTokenPreview = $newToken.Substring(0, [Math]::Min(40, $newToken.Length))
        Write-Host "   🟢 Token nuevo:    $newTokenPreview..." -ForegroundColor Green
        Write-Host ""
        
        if ($oldToken -eq $newToken) {
            Write-Host "   ⚠️  ADVERTENCIA: Los tokens son idénticos" -ForegroundColor Yellow
        } else {
            Write-Host "   ✅ Los tokens son diferentes (correcto)" -ForegroundColor Green
        }
        Write-Host ""
        
        # Paso 3: Probar el nuevo token
        Write-Host "🧪 PASO 3: Probando el nuevo token..." -ForegroundColor Yellow
        $newHeaders = @{
            "Authorization" = "Bearer $newToken"
            "Content-Type" = "application/json"
        }
        
        try {
            $testResponse = Invoke-RestMethod -Uri "$API_BASE/admin-actions/show-users?page=1" -Method Get -Headers $newHeaders
            Write-Host "   ✅ El nuevo token funciona correctamente!" -ForegroundColor Green
            Write-Host ""
        } catch {
            Write-Host "   ⚠️  No se pudo probar el token (puede que no tengas permisos para show-users)" -ForegroundColor Yellow
            Write-Host ""
        }
        
        Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
        Write-Host "   ✅ PRUEBA COMPLETADA EXITOSAMENTE" -ForegroundColor Green
        Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
        
    } else {
        Write-Host "   ⚠️  Refresh no exitoso" -ForegroundColor Yellow
        Write-Host "   💬 Mensaje: $($response.message)" -ForegroundColor Gray
    }
    
} catch {
    $errorDetails = $_.ErrorDetails.Message
    
    if ($errorDetails) {
        try {
            $errorJson = $errorDetails | ConvertFrom-Json
            
            Write-Host "   ❌ Error al refrescar token" -ForegroundColor Red
            Write-Host "   💬 Mensaje: $($errorJson.message)" -ForegroundColor Red
            
            if ($_.Exception.Response.StatusCode -eq 401) {
                Write-Host "   🔒 Token inválido o expirado" -ForegroundColor Red
            }
            
            if ($errorJson.error_code) {
                Write-Host "   🔍 Código de error: $($errorJson.error_code)" -ForegroundColor Red
            }
        } catch {
            Write-Host "   ❌ Error: $errorDetails" -ForegroundColor Red
        }
    } else {
        Write-Host "   ❌ Error al refrescar token" -ForegroundColor Red
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
Write-Host "Endpoint: POST /api/v1/auth/refresh-token" -ForegroundColor Gray
Write-Host "Headers requeridos:" -ForegroundColor Gray
Write-Host "  • Authorization: Bearer {token}" -ForegroundColor Gray
Write-Host ""
Write-Host "Propósito:" -ForegroundColor Gray
Write-Host "  Obtiene un nuevo token de acceso usando el token actual" -ForegroundColor Gray
Write-Host "  Útil para mantener sesiones activas sin re-login" -ForegroundColor Gray
Write-Host ""
Write-Host "Ejemplos de uso:" -ForegroundColor Yellow
Write-Host '  .\test-refresh-token.ps1' -ForegroundColor Gray
Write-Host '  .\test-refresh-token.ps1 -TestEmail "usuario@test.com" -TestPassword "clave123"' -ForegroundColor Gray
Write-Host ""
