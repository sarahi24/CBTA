# Script para probar el endpoint de historial de pagos
# Ejecutar: powershell -ExecutionPolicy Bypass -File test-payment-history.ps1

param(
    [string]$TestEmail = "admin@example.com",
    [string]$TestPassword = "password",
    [int]$StudentId = $null,
    [int]$Page = 1,
    [int]$PerPage = 15,
    [switch]$ForceRefresh = $false,
    [string]$UserRole = "student"
)

$API_BASE = "https://nginx-production-728f.up.railway.app/api/v1"

Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   TEST ENDPOINT - PAYMENT HISTORY / HISTORIAL PAGOS" -ForegroundColor Cyan
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
    "X-User-Permission" = "view.payments.summary"
}

# Paso 2: Construir URL con query parameters
Write-Host "📊 PASO 2: Obteniendo historial de pagos..." -ForegroundColor Yellow

$queryParams = @()
$queryParams += "page=$Page"
$queryParams += "perPage=$PerPage"
if ($ForceRefresh) {
    $queryParams += "forceRefresh=true"
}

$endpoint = if ($StudentId) { 
    "$API_BASE/dashboard/history/$StudentId"
} else { 
    "$API_BASE/dashboard/history"
}

if ($queryParams.Count -gt 0) {
    $endpoint += "?" + ($queryParams -join "&")
}

Write-Host "   URL: GET $endpoint" -ForegroundColor Gray
Write-Host ""

try {
    $response = Invoke-RestMethod -Uri $endpoint -Method Get -Headers $headers
    
    if ($response.success) {
        Write-Host "   ✅ Historial obtenido exitosamente!" -ForegroundColor Green
        Write-Host ""
        
        Write-Host "   📬 RESULTADO:" -ForegroundColor Cyan
        Write-Host "   ────────────────────────────────────────────" -ForegroundColor Gray
        Write-Host "   💬 Mensaje: $($response.message)" -ForegroundColor Gray
        Write-Host ""
        
        if ($response.data.payment_history) {
            $history = $response.data.payment_history
            
            Write-Host "   📋 INFORMACIÓN DE PAGINACIÓN:" -ForegroundColor Cyan
            Write-Host "   • Página actual: $($history.currentPage)/$($history.lastPage)" -ForegroundColor Gray
            Write-Host "   • Registros por página: $($history.perPage)" -ForegroundColor Gray
            Write-Host "   • Total de pagos: $($history.total)" -ForegroundColor Gray
            Write-Host "   • Más páginas disponibles: $($history.hasMorePages)" -ForegroundColor Gray
            
            if ($history.nextPage) {
                Write-Host "   • Página siguiente: $($history.nextPage)" -ForegroundColor Gray
            }
            if ($history.previousPage) {
                Write-Host "   • Página anterior: $($history.previousPage)" -ForegroundColor Gray
            }
            
            Write-Host ""
            Write-Host "   💳 PAGOS EN ESTA PÁGINA:" -ForegroundColor Cyan
            Write-Host "   ────────────────────────────────────────────" -ForegroundColor Gray
            
            if ($history.items -and @($history.items).Count -gt 0) {
                $itemCount = 0
                foreach ($payment in $history.items) {
                    $itemCount++
                    Write-Host ""
                    Write-Host "   [$itemCount] ID: $($payment.id)" -ForegroundColor Yellow
                    Write-Host "       • Concepto: $($payment.concept)" -ForegroundColor Gray
                    Write-Host "       • Monto: `$$($payment.amount) MXN" -ForegroundColor Green
                    Write-Host "       • Monto Recibido: `$$($payment.amount_received) MXN" -ForegroundColor Green
                    Write-Host "       • Estado: $($payment.status)" -ForegroundColor Gray
                    Write-Host "       • Fecha: $($payment.date)" -ForegroundColor Gray
                }
                Write-Host ""
                Write-Host "   📊 Total en esta página: $itemCount pagos" -ForegroundColor Cyan
            } else {
                Write-Host "   (No hay pagos registrados en esta página)" -ForegroundColor Gray
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
            
            Write-Host "   ❌ Error al obtener historial" -ForegroundColor Red
            Write-Host "   💬 Mensaje: $($errorJson.message)" -ForegroundColor Red
            
            $statusCode = $_.Exception.Response.StatusCode.value__
            
            switch ($statusCode) {
                401 {
                    Write-Host "   🔒 No autenticado" -ForegroundColor Red
                }
                403 {
                    Write-Host "   🔓 No autorizado (permisos insuficientes)" -ForegroundColor Red
                }
                404 {
                    Write-Host "   📭 Estudiante no encontrado" -ForegroundColor Red
                }
                422 {
                    Write-Host "   ⚠️  Error de validación" -ForegroundColor Red
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

# Paso 3: Mostrar información adicional si hay más páginas
if ($response.data.payment_history.hasMorePages) {
    Write-Host ""
    Write-Host "💡 PRÓXIMAS PÁGINAS DISPONIBLES:" -ForegroundColor Cyan
    Write-Host "   Para obtener la siguiente página, ejecuta:" -ForegroundColor Gray
    Write-Host "   .\test-payment-history.ps1 -Page $($response.data.payment_history.nextPage)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   📊 INFORMACIÓN DEL ENDPOINT" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Endpoint: GET /api/v1/dashboard/history/{studentId?}" -ForegroundColor Gray
Write-Host ""
Write-Host "Propósito:" -ForegroundColor Gray
Write-Host "  Devuelve historial paginado de pagos realizados por el usuario" -ForegroundColor Gray
Write-Host ""
Write-Host "Headers requeridos:" -ForegroundColor Gray
Write-Host "  • Authorization: Bearer {token}" -ForegroundColor Gray
Write-Host "  • X-User-Role: student|parent" -ForegroundColor Gray
Write-Host "  • X-User-Permission: view.payments.summary" -ForegroundColor Gray
Write-Host ""
Write-Host "Query Parameters:" -ForegroundColor Gray
Write-Host "  • page (integer): Número de página (default: 1)" -ForegroundColor Gray
Write-Host "  • perPage (integer): Registros por página (default: 15)" -ForegroundColor Gray
Write-Host "  • forceRefresh (boolean): Forzar actualización de caché (default: false)" -ForegroundColor Gray
Write-Host ""
Write-Host "Parámetros de ruta:" -ForegroundColor Gray
Write-Host "  • studentId (integer): ID del estudiante - opcional, solo para padres" -ForegroundColor Gray
Write-Host ""
Write-Host "Respuestas esperadas:" -ForegroundColor Gray
Write-Host "  • 200: Historial obtenido correctamente" -ForegroundColor Green
Write-Host "  • 401: No autenticado" -ForegroundColor Red
Write-Host "  • 403: No autorizado (puede ser padre sin relación con estudiante)" -ForegroundColor Red
Write-Host "  • 404: Estudiante no encontrado" -ForegroundColor Red
Write-Host "  • 422: Error de validación en parámetros" -ForegroundColor Red
Write-Host "  • 429: Demasiadas solicitudes" -ForegroundColor Red
Write-Host ""
Write-Host "Ejemplos de uso:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  # Obtener primer página del historial (usuario autenticado)" -ForegroundColor Gray
Write-Host '  .\test-payment-history.ps1' -ForegroundColor Yellow
Write-Host ""
Write-Host "  # Obtener página 2 con 20 registros por página" -ForegroundColor Gray
Write-Host '  .\test-payment-history.ps1 -Page 2 -PerPage 20' -ForegroundColor Yellow
Write-Host ""
Write-Host "  # Forzar actualización de caché" -ForegroundColor Gray
Write-Host '  .\test-payment-history.ps1 -ForceRefresh' -ForegroundColor Yellow
Write-Host ""
Write-Host "  # Como padre, obtener historial de hijo específico" -ForegroundColor Gray
Write-Host '  .\test-payment-history.ps1 -StudentId 5 -UserRole "parent"' -ForegroundColor Yellow
Write-Host ""
Write-Host "  # Combinado: hijo específico, página 3, 25 registros, forzar refresh" -ForegroundColor Gray
Write-Host '  .\test-payment-history.ps1 -StudentId 5 -Page 3 -PerPage 25 -ForceRefresh' -ForegroundColor Yellow
Write-Host ""
