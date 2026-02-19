# Script para probar el endpoint de refresh del dashboard
# Ejecutar: powershell -ExecutionPolicy Bypass -File test-refresh-dashboard.ps1

param(
    [string]$TestEmail = "admin@example.com",
    [string]$TestPassword = "password",
    [int]$StudentId = $null,
    [string]$UserRole = "student"
)

$API_BASE = "https://nginx-production-728f.up.railway.app/api/v1"

Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   TEST ENDPOINT - REFRESH DASHBOARD CACHE" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Paso 1: Login
Write-Host "📝 PASO 1: Autenticación..." -ForegroundColor Yellow
$loginBody = @{
    email = $TestEmail
    password = $TestPassword
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "$API_BASE/login" -Method Post -Body $loginBody -ContentType "application/json"
    
    if ($loginResponse.success) {
        $token = $loginResponse.data.token
        $userId = $loginResponse.data.user.id
        Write-Host "   ✅ Login exitoso!" -ForegroundColor Green
        Write-Host "   👤 Usuario: $($loginResponse.data.user.name)" -ForegroundColor Gray
        Write-Host "   🆔 ID: $userId" -ForegroundColor Gray
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
    "X-User-Role" = $UserRole
    "X-User-Permission" = "refresh.all.dashboard"
}

# Paso 2: Obtener datos del dashboard antes de limpiar
Write-Host "📊 PASO 2: Obteniendo datos actuales del dashboard..." -ForegroundColor Yellow

try {
    $beforeResponse = Invoke-RestMethod -Uri "$API_BASE/dashboard/data" -Method Get -Headers $headers
    
    if ($beforeResponse.success) {
        Write-Host "   ✅ Datos obtenidos correctamente" -ForegroundColor Green
        Write-Host "   📈 Conceptos pendientes: $($beforeResponse.data.pending_concepts_count ?? "N/A")" -ForegroundColor Gray
        Write-Host "   💳 Pagos realizados: $($beforeResponse.data.paid_concepts_count ?? "N/A")" -ForegroundColor Gray
        Write-Host ""
    } else {
        Write-Host "   ⚠️  No se pudo obtener los datos" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ⚠️  No se pudo obtener datos previos (continuar con refresh)" -ForegroundColor Yellow
}

# Paso 3: Limpiar caché del dashboard
Write-Host "🧹 PASO 3: Limpiando caché del dashboard..." -ForegroundColor Yellow

$endpoint = if ($StudentId) { 
    "$API_BASE/dashboard/refresh/$StudentId" 
} else { 
    "$API_BASE/dashboard/refresh" 
}

Write-Host "   URL: POST $endpoint" -ForegroundColor Gray
Write-Host ""

try {
    $response = Invoke-RestMethod -Uri $endpoint -Method Post -Headers $headers
    
    if ($response.success) {
        Write-Host "   ✅ Caché limpiado exitosamente!" -ForegroundColor Green
        Write-Host ""
        
        Write-Host "   📬 RESULTADO:" -ForegroundColor Cyan
        Write-Host "   ────────────────────────────────────────────" -ForegroundColor Gray
        Write-Host "   💬 Mensaje: $($response.message)" -ForegroundColor Gray
        
        if ($response.data) {
            Write-Host ""
            Write-Host "   📊 Información del caché:" -ForegroundColor Cyan
            if ($response.data.cleared_at) {
                Write-Host "   • Limpiado en: $($response.data.cleared_at)" -ForegroundColor Gray
            }
            if ($response.data.user_id) {
                Write-Host "   • Usuario ID: $($response.data.user_id)" -ForegroundColor Gray
            }
        }
        
        Write-Host ""
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
            
            Write-Host "   ❌ Error al limpiar caché" -ForegroundColor Red
            Write-Host "   💬 Mensaje: $($errorJson.message)" -ForegroundColor Red
            
            $statusCode = $_.Exception.Response.StatusCode.value__
            
            switch ($statusCode) {
                401 {
                    Write-Host "   🔒 No autenticado" -ForegroundColor Red
                }
                403 {
                    Write-Host "   🔓 No autorizado (permisos insuficientes)" -ForegroundColor Red
                }
                429 {
                    Write-Host "   ⏱️  Demasiadas solicitudes (rate limit)" -ForegroundColor Red
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
        } catch {
            Write-Host "   ❌ Error: $errorDetails" -ForegroundColor Red
        }
    } else {
        Write-Host "   ❌ Error al conectar" -ForegroundColor Red
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
Write-Host "Endpoint: POST /api/v1/dashboard/refresh/{studentId?}" -ForegroundColor Gray
Write-Host ""
Write-Host "Propósito:" -ForegroundColor Gray
Write-Host "  Limpia el caché de datos del dashboard (estadísticas, pagos, etc.)" -ForegroundColor Gray
Write-Host ""
Write-Host "Headers requeridos:" -ForegroundColor Gray
Write-Host "  • Authorization: Bearer {token}" -ForegroundColor Gray
Write-Host "  • X-User-Role: student|parent" -ForegroundColor Gray
Write-Host "  • X-User-Permission: refresh.all.dashboard" -ForegroundColor Gray
Write-Host ""
Write-Host "Parámetros:" -ForegroundColor Gray
Write-Host "  • studentId (path): ID del estudiante - opcional, solo para padres" -ForegroundColor Gray
Write-Host ""
Write-Host "Respuestas esperadas:" -ForegroundColor Gray
Write-Host "  • 200: Caché limpiado exitosamente" -ForegroundColor Green
Write-Host "  • 401: No autenticado" -ForegroundColor Red
Write-Host "  • 403: No autorizado (permisos insuficientes)" -ForegroundColor Red
Write-Host "  • 429: Demasiadas solicitudes" -ForegroundColor Red
Write-Host "  • 500: Error interno del servidor" -ForegroundColor Red
Write-Host ""
Write-Host "Ejemplos de uso:" -ForegroundColor Yellow
Write-Host '  # Limpiar caché del usuario autenticado (estudiante)' -ForegroundColor Gray
Write-Host '  .\test-refresh-dashboard.ps1' -ForegroundColor Gray
Write-Host ""
Write-Host '  # Limpiar caché de un estudiante específico (como padre)' -ForegroundColor Gray
Write-Host '  .\test-refresh-dashboard.ps1 -StudentId 5 -UserRole "parent"' -ForegroundColor Gray
Write-Host ""
Write-Host '  # Con credenciales personalizadas' -ForegroundColor Gray
Write-Host '  .\test-refresh-dashboard.ps1 -TestEmail "usuario@test.com" -TestPassword "clave123" -StudentId 3' -ForegroundColor Gray
Write-Host ""
