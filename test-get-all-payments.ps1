# Test Script for GET /api/v1/payments - List All Payments
# Endpoint: GET /api/v1/payments
# Role: financial-staff
# Permission: view.payments

# ========================================
# CONFIGURACIÓN
# ========================================

param(
    [string]$BaseUrl = "https://nginx-production-728f.up.railway.app",
    [string]$Token = $env:API_TOKEN,
    [string]$Search = "",
    [int]$Page = 1,
    [int]$PerPage = 15,
    [bool]$ForceRefresh = $false
)

# Validar que el token está disponible
if (-not $Token) {
    Write-Host "❌ Error: No se proporcionó token" -ForegroundColor Red
    Write-Host "Usa: -Token 'tu-token-aquí'" -ForegroundColor Yellow
    exit 1
}

# ========================================
# FUNCIÓN: Formatear Moneda
# ========================================
function Format-Currency {
    param([string]$Amount)
    $num = [decimal]::Parse($Amount)
    return "$" + $num.ToString("N2", [System.Globalization.CultureInfo]::CreateSpecificCulture("es-MX"))
}

# ========================================
# FUNCIÓN: Mostrar Encabezado
# ========================================
function Show-Header {
    Write-Host "`n" -NoNewline
    Write-Host "═" * 80 -ForegroundColor Cyan
    Write-Host "  API TEST: GET /api/v1/payments - Listar Pagos Registrados" -ForegroundColor Cyan
    Write-Host "═" * 80 -ForegroundColor Cyan
    Write-Host ""
}

# ========================================
# FUNCIÓN: Construir Query String
# ========================================
function Build-QueryString {
    param(
        [string]$Search,
        [int]$Page,
        [int]$PerPage,
        [bool]$ForceRefresh
    )
    
    $params = @()
    
    if ($Search) {
        $params += "search=$([System.Net.WebUtility]::UrlEncode($Search))"
    }
    
    $params += "page=$Page"
    $params += "perPage=$PerPage"
    
    if ($ForceRefresh) {
        $params += "forceRefresh=true"
    }
    
    if ($params.Count -gt 0) {
        return "?" + ($params -join "&")
    }
    return ""
}

# ========================================
# MAIN: Ejecutar Request
# ========================================

Show-Header

# Construir URL
$queryString = Build-QueryString $Search $Page $PerPage $ForceRefresh
$url = "$BaseUrl/api/v1/payments$queryString"

Write-Host "📊 Parámetros de búsqueda:" -ForegroundColor White
Write-Host "   URL Base: $BaseUrl" -ForegroundColor Gray
Write-Host "   Búsqueda: $(if ($Search) { $Search } else { '(vacío)' })" -ForegroundColor Gray
Write-Host "   Página: $Page" -ForegroundColor Gray
Write-Host "   Por página: $PerPage" -ForegroundColor Gray
Write-Host "   Forzar actualización: $ForceRefresh" -ForegroundColor Gray
Write-Host "   URL Final: $url" -ForegroundColor Yellow
Write-Host ""

# Headers
$headers = @{
    "Authorization" = "Bearer $Token"
    "Content-Type" = "application/json"
    "Accept" = "application/json"
    "X-User-Role" = "financial-staff"
    "X-User-Permission" = "view.payments"
}

Write-Host "🔐 Headers enviados:" -ForegroundColor White
Write-Host "   Authorization: Bearer [token]" -ForegroundColor Gray
Write-Host "   X-User-Role: financial-staff" -ForegroundColor Gray
Write-Host "   X-User-Permission: view.payments" -ForegroundColor Gray
Write-Host ""

Write-Host "📤 Enviando request..." -ForegroundColor Cyan

try {
    $response = Invoke-WebRequest -Uri $url -Method GET -Headers $headers -UseBasicParsing
    $statusCode = $response.StatusCode
    $body = $response.Content | ConvertFrom-Json
    
    Write-Host "✅ Request exitoso (Status: $statusCode)" -ForegroundColor Green
    Write-Host ""
    
    # Mostrar información principal
    Write-Host "📋 Respuesta:" -ForegroundColor White
    Write-Host "   Mensaje: $($body.message)" -ForegroundColor Green
    Write-Host ""
    
    # Mostrar información de paginación
    if ($body.data.payments) {
        $pagination = $body.data.payments
        
        Write-Host "📑 Información de Paginación:" -ForegroundColor Cyan
        Write-Host "   Página Actual: $($pagination.currentPage)" -ForegroundColor Gray
        Write-Host "   Última Página: $($pagination.lastPage)" -ForegroundColor Gray
        Write-Host "   Items por Página: $($pagination.perPage)" -ForegroundColor Gray
        Write-Host "   Total de Pagos: $($pagination.total)" -ForegroundColor Gray
        Write-Host "   ¿Hay más páginas?: $(if ($pagination.hasMorePages) { '✓ Sí' } else { '✗ No' })" -ForegroundColor Gray
        
        if ($pagination.nextPage) {
            Write-Host "   Próxima Página: $($pagination.nextPage)" -ForegroundColor Gray
        }
        if ($pagination.previousPage) {
            Write-Host "   Página Anterior: $($pagination.previousPage)" -ForegroundColor Gray
        }
        Write-Host ""
        
        # Mostrar detalles de pagos
        if ($pagination.items -and $pagination.items.Count -gt 0) {
            Write-Host "💳 Detalles de Pagos ($($pagination.items.Count) items):" -ForegroundColor Cyan
            Write-Host ""
            
            $pagination.items | ForEach-Object -Begin { $idx = 1 } {
                Write-Host "   [$idx] Estudiante: $($_.fullName)" -ForegroundColor White
                Write-Host "       Fecha: $($_.date)" -ForegroundColor Gray
                Write-Host "       Concepto: $($_.concept)" -ForegroundColor Gray
                Write-Host "       Monto: $(Format-Currency $_.amount)" -ForegroundColor Yellow
                Write-Host "       Monto Recibido: $(Format-Currency $_.amount_received)" -ForegroundColor Green
                Write-Host "       Método: $($_.method)" -ForegroundColor Gray
                Write-Host "       ID: $($_.id)" -ForegroundColor DarkGray
                Write-Host ""
                $idx++
            }
        } else {
            Write-Host "⚠️  No hay pagos registrados" -ForegroundColor Yellow
        }
    }
    
    # Mostrar respuesta JSON completa
    Write-Host "📄 Respuesta JSON Completa:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host ($body | ConvertTo-Json -Depth 10) -ForegroundColor Gray
    Write-Host ""
    
} catch {
    $statusCode = $_.Exception.Response.StatusCode.Value__
    $errorResponse = $_.Exception.Response
    
    Write-Host "❌ Error en la solicitud (Status: $statusCode)" -ForegroundColor Red
    Write-Host ""
    
    try {
        $reader = New-Object System.IO.StreamReader($errorResponse.GetResponseStream())
        $body = $reader.ReadToEnd() | ConvertFrom-Json
        $reader.Close()
        
        Write-Host "📋 Error Details:" -ForegroundColor Red
        Write-Host "   Mensaje: $($body.message)" -ForegroundColor Yellow
        Write-Host "   Error Code: $($body.error_code)" -ForegroundColor Yellow
        Write-Host ""
        
        if ($body.errors) {
            Write-Host "🔍 Errores de Validación:" -ForegroundColor Red
            $body.errors | Get-Member -MemberType NoteProperty | ForEach-Object {
                $propName = $_.Name
                Write-Host "   $propName :" -ForegroundColor Yellow
                $body.errors.$propName | ForEach-Object {
                    Write-Host "      • $_" -ForegroundColor Gray
                }
            }
        }
        
        Write-Host ""
        Write-Host "📄 Respuesta Completa:" -ForegroundColor Cyan
        Write-Host ($body | ConvertTo-Json -Depth 10) -ForegroundColor Gray
        
    } catch {
        Write-Host "⚠️  No se pudo parsear la respuesta de error" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "💡 Interpretación del Error:" -ForegroundColor Cyan
    switch ($statusCode) {
        401 {
            Write-Host "   • Token inválido o expirado" -ForegroundColor Yellow
            Write-Host "   • Necesitas iniciar sesión nuevamente" -ForegroundColor Yellow
        }
        403 {
            Write-Host "   • Usuario no tiene permisos 'view.payments'" -ForegroundColor Yellow
            Write-Host "   • Recuerda utilizar X-User-Role: 'financial-staff'" -ForegroundColor Yellow
        }
        409 {
            Write-Host "   • Conflicto de datos" -ForegroundColor Yellow
            Write-Host "   • Verifica que los datos requeridos sean válidos" -ForegroundColor Yellow
        }
        422 {
            Write-Host "   • Datos de entrada inválidos" -ForegroundColor Yellow
            Write-Host "   • Verifica los parámetros de búsqueda y paginación" -ForegroundColor Yellow
        }
        429 {
            Write-Host "   • Limite de solicitudes excedido" -ForegroundColor Yellow
            Write-Host "   • Espera unos momentos antes de reintentar" -ForegroundColor Yellow
        }
        500 {
            Write-Host "   • Error interno del servidor" -ForegroundColor Yellow
            Write-Host "   • Contacta al administrador" -ForegroundColor Yellow
        }
        502 {
            Write-Host "   • Gateway error (servidor no disponible)" -ForegroundColor Yellow
            Write-Host "   • Verifica la conectividad" -ForegroundColor Yellow
        }
        default {
            Write-Host "   • Error HTTP $statusCode" -ForegroundColor Yellow
        }
    }
    
    exit 1
}

Write-Host "═" * 80 -ForegroundColor Cyan
Write-Host "✅ Test completado exitosamente" -ForegroundColor Green
Write-Host "═" * 80 -ForegroundColor Cyan
Write-Host ""

# ========================================
# EJEMPLOS DE USO
# ========================================

Write-Host "📌 EJEMPLOS DE USO:" -ForegroundColor Green
Write-Host ""
Write-Host "1. Obtener página 1 de pagos (15 por página):" -ForegroundColor White
Write-Host "   .\test-get-all-payments.ps1 -Token 'your-token-here'" -ForegroundColor Cyan
Write-Host ""
Write-Host "2. Buscar un estudiante específico (por email):" -ForegroundColor White
Write-Host "   .\test-get-all-payments.ps1 -Token 'your-token-here' -Search 'juan.perez@example.com'" -ForegroundColor Cyan
Write-Host ""
Write-Host "3. Buscar por nombre:" -ForegroundColor White
Write-Host "   .\test-get-all-payments.ps1 -Token 'your-token-here' -Search 'juan perez'" -ForegroundColor Cyan
Write-Host ""
Write-Host "4. Buscar por concepto de pago:" -ForegroundColor White
Write-Host "   .\test-get-all-payments.ps1 -Token 'your-token-here' -Search 'inscripción'" -ForegroundColor Cyan
Write-Host ""
Write-Host "5. Obtener página 2 con 25 items por página:" -ForegroundColor White
Write-Host "   .\test-get-all-payments.ps1 -Token 'your-token-here' -Page 2 -PerPage 25" -ForegroundColor Cyan
Write-Host ""
Write-Host "6. Forzar actualización del caché:" -ForegroundColor White
Write-Host "   .\test-get-all-payments.ps1 -Token 'your-token-here' -ForceRefresh `$true" -ForegroundColor Cyan
Write-Host ""
Write-Host "7. Combinado: Buscar + Paginar + Forzar caché:" -ForegroundColor White
Write-Host "   .\test-get-all-payments.ps1 -Token 'your-token-here' -Search 'juan' -Page 2 -PerPage 50 -ForceRefresh `$true" -ForegroundColor Cyan
Write-Host ""
