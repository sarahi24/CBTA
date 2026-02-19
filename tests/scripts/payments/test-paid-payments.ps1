# Script para probar el endpoint de pagos realizados
# Ejecutar: powershell -ExecutionPolicy Bypass -File test-paid-payments.ps1

param(
    [string]$TestEmail = "admin@example.com",
    [string]$TestPassword = "password",
    [int]$StudentId = $null,
    [switch]$ForceRefresh = $false,
    [string]$UserRole = "student"
)

$API_BASE = "https://nginx-production-728f.up.railway.app/api/v1"

Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   TEST ENDPOINT - PAID PAYMENTS / PAGOS REALIZADOS" -ForegroundColor Cyan
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
    "X-User-Permission" = "view.own.paid.concepts.summary"
}

# Paso 2: Obtener información de pagos realizados
Write-Host "💳 PASO 2: Obteniendo información de pagos realizados..." -ForegroundColor Yellow

$endpoint = if ($StudentId) { 
    "$API_BASE/dashboard/paid/$StudentId"
} else { 
    "$API_BASE/dashboard/paid"
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
        
        if ($response.data.paid_data) {
            $paidData = $response.data.paid_data
            
            Write-Host "   💰 TOTAL DE PAGOS REALIZADOS:" -ForegroundColor Cyan
            Write-Host "   ────────────────────────────────────────────" -ForegroundColor Gray
            
            $totalPayments = [double]$paidData.totalPayments
            
            if ($totalPayments -gt 0) {
                Write-Host "   ✅ Monto total pagado: `$$($paidData.totalPayments) MXN" -ForegroundColor Green
                Write-Host ""
                
                if ($paidData.paymentsByMonth) {
                    Write-Host "   📊 DESGLOSE POR MES:" -ForegroundColor Cyan
                    Write-Host "   ────────────────────────────────────────────" -ForegroundColor Gray
                    
                    $totalByMonth = 0
                    foreach ($month in $paidData.paymentsByMonth.PSObject.Properties | Sort-Object Name) {
                        $monthName = $month.Name
                        $monthAmount = [double]$month.Value
                        $totalByMonth += $monthAmount
                        
                        # Format month as "YYYY-MM" to "Month Year"
                        $dateObj = [DateTime]::ParseExact($monthName, "yyyy-MM", $null)
                        $displayMonth = $dateObj.ToString("MMMM yyyy", [System.Globalization.CultureInfo]::GetCultureInfo("es-MX"))
                        
                        Write-Host "   📅 $displayMonth`: `$$($month.Value) MXN" -ForegroundColor Green
                    }
                    
                    Write-Host ""
                    Write-Host "   📈 Subtotal de desglose: `$$($totalByMonth.ToString('N2')) MXN" -ForegroundColor White
                }
            } else {
                Write-Host "   ℹ️  Monto total pagado: `$0.00 MXN" -ForegroundColor White
                Write-Host ""
                Write-Host "   📝 No hay pagos realizados en el período" -ForegroundColor Gray
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
            
            Write-Host "   ❌ Error al obtener pagos realizados" -ForegroundColor Red
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
Write-Host "Endpoint: GET /api/v1/dashboard/paid/{studentId?}" -ForegroundColor Gray
Write-Host ""
Write-Host "Propósito:" -ForegroundColor Gray
Write-Host "  Devuelve el monto total de pagos completados organizados por mes" -ForegroundColor Gray
Write-Host ""
Write-Host "Headers requeridos:" -ForegroundColor Gray
Write-Host "  • Authorization: Bearer {token}" -ForegroundColor Gray
Write-Host "  • X-User-Role: student|parent" -ForegroundColor Gray
Write-Host "  • X-User-Permission: view.own.paid.concepts.summary" -ForegroundColor Gray
Write-Host ""
Write-Host "Query Parameters:" -ForegroundColor Gray
Write-Host "  • forceRefresh (boolean): Forzar actualización de caché (default: false)" -ForegroundColor Gray
Write-Host ""
Write-Host "Parámetros de ruta:" -ForegroundColor Gray
Write-Host "  • studentId (integer): ID del estudiante - opcional, solo para padres" -ForegroundColor Gray
Write-Host ""
Write-Host "Respuesta esperada (200 OK):" -ForegroundColor Gray
Write-Host '  {' -ForegroundColor Gray
Write-Host '    "success": true,' -ForegroundColor Gray
Write-Host '    "message": "Monto total de pagos realizados obtenido correctamente",' -ForegroundColor Gray
Write-Host '    "data": {' -ForegroundColor Gray
Write-Host '      "paid_data": {' -ForegroundColor Gray
Write-Host '        "totalPayments": "25000.00",' -ForegroundColor Gray
Write-Host '        "paymentsByMonth": {' -ForegroundColor Gray
Write-Host '          "2024-01": "15000.00",' -ForegroundColor Gray
Write-Host '          "2024-02": "12000.00",' -ForegroundColor Gray
Write-Host '          "2024-03": "18000.00"' -ForegroundColor Gray
Write-Host '        }' -ForegroundColor Gray
Write-Host '      }' -ForegroundColor Gray
Write-Host '    }' -ForegroundColor Gray
Write-Host '  }' -ForegroundColor Gray
Write-Host ""
Write-Host "Otros códigos de respuesta:" -ForegroundColor Gray
Write-Host "  • 401: No autenticado" -ForegroundColor Red
Write-Host "  • 403: No autorizado (usuario no relacionado con estudiante)" -ForegroundColor Red
Write-Host "  • 404: Estudiante no encontrado" -ForegroundColor Red
Write-Host "  • 429: Demasiadas solicitudes" -ForegroundColor Red
Write-Host "  • 500: Error interno del servidor" -ForegroundColor Red
Write-Host ""
Write-Host "Ejemplos de uso:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  # Obtener pagos realizados del usuario autenticado" -ForegroundColor Gray
Write-Host '  .\test-paid-payments.ps1' -ForegroundColor Yellow
Write-Host ""
Write-Host "  # Forzar actualización de caché" -ForegroundColor Gray
Write-Host '  .\test-paid-payments.ps1 -ForceRefresh' -ForegroundColor Yellow
Write-Host ""
Write-Host "  # Como padre, obtener pagos realizados de un hijo" -ForegroundColor Gray
Write-Host '  .\test-paid-payments.ps1 -StudentId 5 -UserRole "parent"' -ForegroundColor Yellow
Write-Host ""
Write-Host "  # Combinado: hijo específico y forzar refresh" -ForegroundColor Gray
Write-Host '  .\test-paid-payments.ps1 -StudentId 5 -UserRole "parent" -ForceRefresh' -ForegroundColor Yellow
Write-Host ""
Write-Host "  # Con credenciales personalizadas" -ForegroundColor Gray
Write-Host '  .\test-paid-payments.ps1 -TestEmail "usuario@test.com" -TestPassword "clave123" -StudentId 3' -ForegroundColor Yellow
Write-Host ""
