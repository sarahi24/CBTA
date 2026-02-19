# Script para probar el endpoint de detalle de pago
# Ejecutar: powershell -ExecutionPolicy Bypass -File test-payment-detail.ps1

param(
    [string]$TestEmail = "admin@example.com",
    [string]$TestPassword = "password",
    [int]$PaymentId = 1,
    [string]$UserRole = "student"
)

$API_BASE = "https://nginx-production-728f.up.railway.app/api/v1"

Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   TEST ENDPOINT - PAYMENT DETAIL / DETALLE DE PAGO" -ForegroundColor Cyan
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
    "X-User-Permission" = "view.payments.history"
}

# Paso 2: Obtener detalle del pago
Write-Host "📋 PASO 2: Obteniendo detalle del pago #$PaymentId..." -ForegroundColor Yellow

$endpoint = "$API_BASE/history/payment/$PaymentId"

Write-Host "   URL: GET $endpoint" -ForegroundColor Gray
Write-Host ""

try {
    $response = Invoke-RestMethod -Uri $endpoint -Method Get -Headers $headers
    
    if ($response.success) {
        Write-Host "   ✅ Detalle del pago obtenido exitosamente!" -ForegroundColor Green
        Write-Host ""
        
        Write-Host "   📬 RESULTADO:" -ForegroundColor Cyan
        Write-Host "   ────────────────────────────────────────────" -ForegroundColor Gray
        
        if ($response.data.payment) {
            $payment = $response.data.payment
            
            Write-Host "   💳 INFORMACIÓN DEL PAGO:" -ForegroundColor Cyan
            Write-Host "   ────────────────────────────────────────────" -ForegroundColor Gray
            Write-Host "   ID del pago: $($payment.id)" -ForegroundColor White
            Write-Host "   Concepto: $($payment.concept_name)" -ForegroundColor White
            Write-Host "   Monto: `$$($payment.amount) MXN" -ForegroundColor Green
            Write-Host "   Monto recibido: `$$($payment.amount_received) MXN" -ForegroundColor Green
            Write-Host "   Estado: $($payment.status)" -ForegroundColor Yellow
            Write-Host ""
            
            Write-Host "   📅 FECHAS Y REFERENCIAS:" -ForegroundColor Cyan
            Write-Host "   ────────────────────────────────────────────" -ForegroundColor Gray
            Write-Host "   Creado: $($payment.created_at)" -ForegroundColor Gray
            Write-Host "   Actualizado: $($payment.updated_at)" -ForegroundColor Gray
            Write-Host ""
            
            Write-Host "   🏦 INFORMACIÓN DE PAGO:" -ForegroundColor Cyan
            Write-Host "   ────────────────────────────────────────────" -ForegroundColor Gray
            
            if ($payment.payment_method_details) {
                Write-Host "   Métodos de pago:" -ForegroundColor White
                foreach ($method in $payment.payment_method_details) {
                    Write-Host "     • $method" -ForegroundColor Gray
                }
            }
            
            if ($payment.stripe_payment_method_id) {
                Write-Host "   ID Stripe: $($payment.stripe_payment_method_id)" -ForegroundColor Gray
            }
            
            if ($payment.payment_intent_id) {
                Write-Host "   ID de intención: $($payment.payment_intent_id)" -ForegroundColor Gray
            }
            
            if ($payment.url) {
                Write-Host "   URL del recibo: $($payment.url)" -ForegroundColor Cyan
            }
            
            Write-Host ""
            Write-Host "   📊 DATOS DEL USUARIO:" -ForegroundColor Cyan
            Write-Host "   ────────────────────────────────────────────" -ForegroundColor Gray
            Write-Host "   ID Usuario: $($payment.user_id)" -ForegroundColor Gray
            Write-Host "   ID Concepto: $($payment.payment_concept_id)" -ForegroundColor Gray
            Write-Host "   ID Método: $($payment.payment_method_id)" -ForegroundColor Gray
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
            
            Write-Host "   ❌ Error al obtener detalle del pago" -ForegroundColor Red
            Write-Host "   💬 Mensaje: $($errorJson.message)" -ForegroundColor Red
            
            $statusCode = $_.Exception.Response.StatusCode.value__
            
            switch ($statusCode) {
                401 {
                    Write-Host "   🔒 No autenticado (token inválido o expirado)" -ForegroundColor Red
                }
                403 {
                    Write-Host "   🔓 No autorizado (permisos insuficientes)" -ForegroundColor Red
                }
                404 {
                    Write-Host "   📭 Pago no encontrado (ID: $PaymentId)" -ForegroundColor Red
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
Write-Host "Endpoint: GET /api/v1/history/payment/{id}" -ForegroundColor Gray
Write-Host ""
Write-Host "Propósito:" -ForegroundColor Gray
Write-Host "  Obtiene la información detallada de un pago específico" -ForegroundColor Gray
Write-Host ""
Write-Host "Headers requeridos:" -ForegroundColor Gray
Write-Host "  • Authorization: Bearer {token}" -ForegroundColor Gray
Write-Host "  • X-User-Role: student|parent" -ForegroundColor Gray
Write-Host "  • X-User-Permission: view.payments.history" -ForegroundColor Gray
Write-Host ""
Write-Host "Parámetros de ruta:" -ForegroundColor Gray
Write-Host "  • id (integer): ID del pago a buscar (requerido)" -ForegroundColor Gray
Write-Host ""
Write-Host "Datos devueltos:" -ForegroundColor Gray
Write-Host "  • concept_name: Nombre del concepto" -ForegroundColor Gray
Write-Host "  • amount: Monto del pago" -ForegroundColor Gray
Write-Host "  • amount_received: Monto recibido" -ForegroundColor Gray
Write-Host "  • status: Estado del pago (paid, pending, failed, refunded)" -ForegroundColor Gray
Write-Host "  • payment_method_details: Array de métodos de pago" -ForegroundColor Gray
Write-Host "  • created_at / updated_at: Fechas de creación y actualización" -ForegroundColor Gray
Write-Host ""
Write-Host "Respuestas esperadas:" -ForegroundColor Gray
Write-Host "  • 200: Pago encontrado correctamente" -ForegroundColor Green
Write-Host "  • 401: No autenticado" -ForegroundColor Red
Write-Host "  • 403: No autorizado" -ForegroundColor Red
Write-Host "  • 404: Pago no encontrado" -ForegroundColor Red
Write-Host "  • 429: Demasiadas solicitudes" -ForegroundColor Red
Write-Host ""
Write-Host "Ejemplos de uso:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  # Obtener detalle del pago #1" -ForegroundColor Gray
Write-Host '  .\test-payment-detail.ps1 -PaymentId 1' -ForegroundColor Yellow
Write-Host ""
Write-Host "  # Obtener detalle del pago #5" -ForegroundColor Gray
Write-Host '  .\test-payment-detail.ps1 -PaymentId 5' -ForegroundColor Yellow
Write-Host ""
Write-Host "  # Con credenciales personalizadas" -ForegroundColor Gray
Write-Host '  .\test-payment-detail.ps1 -TestEmail "usuario@test.com" -TestPassword "clave123" -PaymentId 3' -ForegroundColor Yellow
Write-Host ""
Write-Host "  # Como padre" -ForegroundColor Gray
Write-Host '  .\test-payment-detail.ps1 -PaymentId 1 -UserRole "parent"' -ForegroundColor Yellow
Write-Host ""
