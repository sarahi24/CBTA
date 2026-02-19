# Script para probar el endpoint de pagos pendientes
# Ejecutar: powershell -ExecutionPolicy Bypass -File test-pending-payments.ps1

param(
    [string]$TestEmail = "admin@example.com",
    [string]$TestPassword = "password",
    [int]$StudentId = $null,
    [switch]$ForceRefresh = $false,
    [string]$UserRole = "student"
)

$API_BASE = "https://nginx-production-728f.up.railway.app/api/v1"

Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   TEST ENDPOINT - PENDING PAYMENTS / PAGOS PENDIENTES" -ForegroundColor Cyan
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
    "X-User-Permission" = "view.own.pending.concepts.summary"
}

# Paso 2: Obtener información de pagos pendientes
Write-Host "⏳ PASO 2: Obteniendo información de pagos pendientes..." -ForegroundColor Yellow

$endpoint = if ($StudentId) { 
    "$API_BASE/dashboard/pending/$StudentId"
} else { 
    "$API_BASE/dashboard/pending"
}


$queryParams = @()
if ($ForceRefresh) {
    $queryParams += "forceRefresh=true"
}

if ($queryParams.Count -gt 0) {
    $endpoint += "?" + ($queryParams -join "&")
}

Write-Host "   URL: GET $endpoint" -ForegroundColor Gray
Write-Host ""

try {
    $response = Invoke-RestMethod -Uri $endpoint -Method Get -Headers $headers
    
    if ($response.success) {
        Write-Host "   ✅ Información obtenida exitosamente!" -ForegroundColor Green
        Write-Host ""
        
        Write-Host "   📬 RESULTADO:" -ForegroundColor Cyan
        Write-Host "   ────────────────────────────────────────────" -ForegroundColor Gray
        Write-Host "   💬 Mensaje: $($response.message)" -ForegroundColor Gray
        Write-Host ""
        
        if ($response.data.total_pending) {
            $pending = $response.data.total_pending
            
            Write-Host "   💳 TOTAL DE PAGOS PENDIENTES:" -ForegroundColor Cyan
            Write-Host "   ────────────────────────────────────────────" -ForegroundColor Gray
            
            $totalAmount = [double]$pending.totalAmount
            $totalCount = [int]$pending.totalCount
            
            # Determinar color basado en cantidad pendiente
            if ($totalCount -eq 0) {
                Write-Host "   ✅ Monto pendiente: `$$($pending.totalAmount) MXN" -ForegroundColor Green
                Write-Host "   ✅ Cantidad de pagos pendientes: $totalCount" -ForegroundColor Green
                Write-Host ""
                Write-Host "   🎉 ¡No hay pagos pendientes!" -ForegroundColor Green
            } else {
                Write-Host "   ⚠️  Monto pendiente: `$$($pending.totalAmount) MXN" -ForegroundColor Yellow
                Write-Host "   ⚠️  Cantidad de pagos pendientes: $totalCount" -ForegroundColor Yellow
                
                if ($totalCount -gt 1) {
                    Write-Host "   📊 Promedio por pago: `$$([Math]::Round($totalAmount / $totalCount, 2)) MXN" -ForegroundColor Gray
                }
            }
        }
        
        Write-Host ""
        Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
        Write-Host "   ✅ PRUEBA COMPLETADA EXITOSAMENTE" -ForegroundColor Green
        Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
        
    } else {
        Write-Host "   ⚠️  Solicitud no exitosa" -ForegroundColor Yellow
        Write-Host "   💬 Mensaje: $($response.message)" -ForegroundColor Gray
    }
    
} catch {
    $errorDetails = $_.ErrorDetails.Message
    
    if ($errorDetails) {
        try {
            $errorJson = $errorDetails | ConvertFrom-Json
            
            Write-Host "   ❌ Error al obtener pagos pendientes" -ForegroundColor Red
            Write-Host "   💬 Mensaje: $($errorJson.message)" -ForegroundColor Red
            
            $statusCode = $_.Exception.Response.StatusCode.value__
            
            switch ($statusCode) {
                401 {
                    Write-Host "   🔒 No autenticado (token inválido o expirado)" -ForegroundColor Red
                }
                403 {
                    Write-Host "   🔓 No autorizado (permisos insuficientes o no es padre/admin del estudiante)" -ForegroundColor Red
                }
                404 {
                    Write-Host "   📭 Estudiante no encontrado" -ForegroundColor Red
                }
                429 {
                    Write-Host "   ⏱️  Demasiadas solicitudes (rate limit)" -ForegroundColor Red
                    Write-Host "   💡 Espera unos momentos antes de reintentar" -ForegroundColor Gray
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
Write-Host "Endpoint: GET /api/v1/dashboard/pending/{studentId?}" -ForegroundColor Gray
Write-Host ""
Write-Host "Propósito:" -ForegroundColor Gray
Write-Host "  Devuelve la cantidad y monto total de pagos pendientes" -ForegroundColor Gray
Write-Host ""
Write-Host "Headers requeridos:" -ForegroundColor Gray
Write-Host "  • Authorization: Bearer {token}" -ForegroundColor Gray
Write-Host "  • X-User-Role: student|parent" -ForegroundColor Gray
Write-Host "  • X-User-Permission: view.own.pending.concepts.summary" -ForegroundColor Gray
Write-Host ""
Write-Host "Query Parameters:" -ForegroundColor Gray
Write-Host "  • forceRefresh (boolean): Forzar actualización de caché (default: false)" -ForegroundColor Gray
Write-Host ""
Write-Host "Parámetros de ruta:" -ForegroundColor Gray
Write-Host "  • studentId (integer): ID del estudiante - opcional, solo para padres" -ForegroundColor Gray
Write-Host ""
Write-Host "Respuestas esperadas:" -ForegroundColor Gray
Write-Host "  • 200: Información obtenida correctamente" -ForegroundColor Green
Write-Host "  • 401: No autenticado" -ForegroundColor Red
Write-Host "  • 403: No autorizado (usuario no relacionado con estudiante)" -ForegroundColor Red
Write-Host "  • 404: Estudiante no encontrado" -ForegroundColor Red
Write-Host "  • 429: Demasiadas solicitudes" -ForegroundColor Red
Write-Host ""
Write-Host "Ejemplos de uso:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  # Obtener pagos pendientes del usuario autenticado" -ForegroundColor Gray
Write-Host '  .\test-pending-payments.ps1' -ForegroundColor Yellow
Write-Host ""
Write-Host "  # Forzar actualización de caché" -ForegroundColor Gray
Write-Host '  .\test-pending-payments.ps1 -ForceRefresh' -ForegroundColor Yellow
Write-Host ""
Write-Host "  # Como padre, obtener pagos pendientes de un hijo" -ForegroundColor Gray
Write-Host '  .\test-pending-payments.ps1 -StudentId 5 -UserRole "parent"' -ForegroundColor Yellow
Write-Host ""
Write-Host "  # Combinado: hijo específico y forzar refresh" -ForegroundColor Gray
Write-Host '  .\test-pending-payments.ps1 -StudentId 5 -UserRole "parent" -ForceRefresh' -ForegroundColor Yellow
Write-Host ""
Write-Host "  # Con credenciales personalizadas" -ForegroundColor Gray
Write-Host '  .\test-pending-payments.ps1 -TestEmail "usuario@test.com" -TestPassword "clave123" -StudentId 3' -ForegroundColor Yellow
Write-Host ""
Write-Host ".\test-pending-payments.ps1 -Token 'tu_token' -ForceRefresh" -ForegroundColor White
