# Script para probar el endpoint de obtener conceptos de pago
# GET /api/v1/dashboard-staff/concepts

$API_BASE = "https://nginx-production-728f.up.railway.app/api/v1"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  TEST: Obtener Conceptos de Pago" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Solicitar token (o usar uno guardado)
$token = Read-Host "Ingresa tu token de acceso (o presiona Enter para usar uno de prueba)"
if ([string]::IsNullOrWhiteSpace($token)) {
    Write-Host "⚠️ No se proporcionó token. Usando token de prueba..." -ForegroundColor Yellow
    $token = "tu_token_aqui"
}

Write-Host ""
Write-Host "📋 Configuración de parámetros:" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray

# Parámetros
$onlyThisYear = Read-Host "¿Solo conceptos del año actual? (s/n) [s]"
$onlyThisYear = if ([string]::IsNullOrWhiteSpace($onlyThisYear) -or $onlyThisYear -eq "s") { "true" } else { "false" }

$page = Read-Host "Número de página [1]"
$page = if ([string]::IsNullOrWhiteSpace($page)) { "1" } else { $page }

$perPage = Read-Host "Registros por página [15]"
$perPage = if ([string]::IsNullOrWhiteSpace($perPage)) { "15" } else { $perPage }

$forceRefresh = Read-Host "¿Forzar actualización de caché? (s/n) [n]"
$forceRefresh = if ($forceRefresh -eq "s") { "true" } else { "false" }

Write-Host ""
Write-Host "📡 Enviando petición GET..." -ForegroundColor Yellow
Write-Host "   URL: $API_BASE/dashboard-staff/concepts" -ForegroundColor Gray
Write-Host "   Parámetros:" -ForegroundColor Gray
Write-Host "     - only_this_year: $onlyThisYear" -ForegroundColor Gray
Write-Host "     - page: $page" -ForegroundColor Gray
Write-Host "     - perPage: $perPage" -ForegroundColor Gray
Write-Host "     - forceRefresh: $forceRefresh" -ForegroundColor Gray
Write-Host ""

try {
    # Construir URL con parámetros
    $url = "$API_BASE/dashboard-staff/concepts?only_this_year=$onlyThisYear&page=$page&perPage=$perPage"
    if ($forceRefresh -eq "true") {
        $url += "&forceRefresh=true"
    }

    # Preparar headers
    $headers = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json"
        "Accept" = "application/json"
        "X-User-Role" = "financial-staff"
        "X-User-Permission" = "view.concepts.history"
    }

    # Hacer la petición GET
    $response = Invoke-RestMethod -Uri $url `
        -Method Get `
        -Headers $headers `
        -ErrorAction Stop

    # Mostrar respuesta exitosa
    Write-Host "✅ ÉXITO: Conceptos obtenidos correctamente" -ForegroundColor Green
    Write-Host ""
    
    if ($response.data -and $response.data.concepts) {
        $concepts = $response.data.concepts
        
        Write-Host "📊 Información de paginación:" -ForegroundColor Cyan
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
        Write-Host "   Total de conceptos: $($concepts.total)" -ForegroundColor White
        Write-Host "   Página actual: $($concepts.currentPage) de $($concepts.lastPage)" -ForegroundColor White
        Write-Host "   Por página: $($concepts.perPage)" -ForegroundColor White
        Write-Host "   ¿Hay más páginas?: $($concepts.hasMorePages)" -ForegroundColor White
        if ($concepts.nextPage) {
            Write-Host "   Siguiente página: $($concepts.nextPage)" -ForegroundColor White
        }
        if ($concepts.previousPage) {
            Write-Host "   Página anterior: $($concepts.previousPage)" -ForegroundColor White
        }
        Write-Host ""
        
        if ($concepts.items -and $concepts.items.Count -gt 0) {
            Write-Host "📝 Conceptos ($($concepts.items.Count) registros):" -ForegroundColor Cyan
            Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
            
            foreach ($concept in $concepts.items) {
                Write-Host ""
                Write-Host "   🔹 ID: $($concept.id)" -ForegroundColor Yellow
                Write-Host "      Nombre: $($concept.concept_name)" -ForegroundColor White
                Write-Host "      Monto: $$($ concept.amount)" -ForegroundColor Green
                Write-Host "      Estado: $($concept.status)" -ForegroundColor $(if ($concept.status -eq "activo") { "Green" } else { "Red" })
                Write-Host "      Aplica a: $($concept.applies_to)" -ForegroundColor White
                Write-Host "      Fecha inicio: $($concept.start_date)" -ForegroundColor Gray
                Write-Host "      Fecha fin: $($concept.end_date)" -ForegroundColor Gray
            }
        } else {
            Write-Host "   ℹ️ No se encontraron conceptos en esta página" -ForegroundColor Yellow
        }
    }
    
    Write-Host ""
    Write-Host "📦 Respuesta JSON completa:" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
    $response | ConvertTo-Json -Depth 10
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray

} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    $statusDescription = $_.Exception.Response.StatusDescription
    
    Write-Host "❌ ERROR: $statusCode - $statusDescription" -ForegroundColor Red
    Write-Host ""
    
    try {
        $errorResponse = $_.ErrorDetails.Message | ConvertFrom-Json
        Write-Host "📦 Respuesta de error:" -ForegroundColor Yellow
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
        $errorResponse | ConvertTo-Json -Depth 10
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
        
        if ($errorResponse.message) {
            Write-Host ""
            Write-Host "💡 Mensaje: $($errorResponse.message)" -ForegroundColor Yellow
        }
        
        if ($errorResponse.error_code) {
            Write-Host "🔍 Código: $($errorResponse.error_code)" -ForegroundColor Yellow
        }

        # Casos específicos
        switch ($statusCode) {
            401 {
                Write-Host ""
                Write-Host "⚠️ No autenticado. Verifica tu token de acceso." -ForegroundColor Red
            }
            403 {
                Write-Host ""
                Write-Host "⚠️ No autorizado. Verifica que tengas:" -ForegroundColor Red
                Write-Host "   - Rol: financial-staff" -ForegroundColor Yellow
                Write-Host "   - Permiso: view.concepts.history" -ForegroundColor Yellow
            }
            429 {
                Write-Host ""
                Write-Host "⚠️ Demasiadas solicitudes. Espera un momento e intenta nuevamente." -ForegroundColor Red
            }
            500 {
                Write-Host ""
                Write-Host "⚠️ Error interno del servidor. Revisa los logs del backend." -ForegroundColor Red
            }
        }
        
    } catch {
        Write-Host "Detalles del error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Opciones" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Probar otra página" -ForegroundColor White
Write-Host "2. Cambiar parámetros" -ForegroundColor White
Write-Host "3. Salir" -ForegroundColor White
Write-Host ""

$option = Read-Host "Selecciona una opción (1-3)"

switch ($option) {
    "1" {
        Write-Host ""
        & $PSCommandPath
    }
    "2" {
        Write-Host ""
        & $PSCommandPath
    }
    "3" {
        Write-Host ""
        Write-Host "👋 ¡Hasta luego!" -ForegroundColor Cyan
        Write-Host ""
    }
    default {
        Write-Host ""
        Write-Host "👋 ¡Hasta luego!" -ForegroundColor Cyan
        Write-Host ""
    }
}
