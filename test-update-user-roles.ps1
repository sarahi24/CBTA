# Test script para actualizar roles de un usuario individual
# POST /api/v1/admin-actions/updated-roles/{userId}

# ============================================
# CONFIGURACIÓN
# ============================================

$API_BASE_URL = "https://nginx-production-728f.up.railway.app/api"
$USER_ID = 4  # Cambiar por el ID del usuario a actualizar

# Token de autenticación (obtenerlo del login)
$ACCESS_TOKEN = $env:ACCESS_TOKEN
if (-not $ACCESS_TOKEN) {
    Write-Host "❌ ERROR: Token no encontrado" -ForegroundColor Red
    Write-Host "Ejecuta primero: `$env:ACCESS_TOKEN = 'tu_token_aqui'" -ForegroundColor Yellow
    exit 1
}

# ============================================
# ENDPOINT
# ============================================

$endpoint = "$API_BASE_URL/v1/admin-actions/updated-roles/$USER_ID"

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  TEST: Actualizar Roles de Usuario" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "🌐 Endpoint: $endpoint" -ForegroundColor White
Write-Host "👤 User ID: $USER_ID" -ForegroundColor White
Write-Host ""

# ============================================
# REQUEST BODY
# ============================================

$body = @{
    rolesToAdd = @(
        "editor",
        "supervisor"
    )
    rolesToRemove = @(
        "viewer"
    )
} | ConvertTo-Json -Depth 10

Write-Host "📤 Request Body:" -ForegroundColor Green
Write-Host $body -ForegroundColor Gray
Write-Host ""

# ============================================
# HEADERS
# ============================================

$headers = @{
    "Authorization" = "Bearer $ACCESS_TOKEN"
    "Content-Type" = "application/json"
    "Accept" = "application/json"
    "X-User-Role" = "admin"
    "X-User-Permission" = "sync.roles"
}

Write-Host "📋 Headers:" -ForegroundColor Green
Write-Host "  Authorization: Bearer $($ACCESS_TOKEN.Substring(0, 20))..." -ForegroundColor Gray
Write-Host "  X-User-Role: admin" -ForegroundColor Gray
Write-Host "  X-User-Permission: sync.roles" -ForegroundColor Gray
Write-Host ""

# ============================================
# EJECUTAR REQUEST
# ============================================

Write-Host "⏳ Enviando request..." -ForegroundColor Yellow
Write-Host ""

try {
    $response = Invoke-RestMethod `
        -Uri $endpoint `
        -Method POST `
        -Headers $headers `
        -Body $body `
        -ContentType "application/json"
    
    Write-Host "================================================" -ForegroundColor Green
    Write-Host "  ✅ RESPUESTA EXITOSA (200)" -ForegroundColor Green
    Write-Host "================================================" -ForegroundColor Green
    Write-Host ""
    
    # Mostrar respuesta formateada
    Write-Host "📥 Respuesta:" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 10 | Write-Host -ForegroundColor White
    Write-Host ""
    
    # Mostrar detalles específicos si existen
    if ($response.data.updated) {
        $user = $response.data.updated
        
        Write-Host "📊 Detalles de la actualización:" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "  Usuario ID: $($user.userId)" -ForegroundColor White
        Write-Host "  Nombre: $($user.fullName)" -ForegroundColor White
        
        if ($user.roles.added) {
            Write-Host "  ✅ Roles agregados: $($user.roles.added.Count)" -ForegroundColor Green
            $user.roles.added | ForEach-Object {
                Write-Host "     - $_" -ForegroundColor Green
            }
        }
        
        if ($user.roles.removed) {
            Write-Host "  ❌ Roles eliminados: $($user.roles.removed.Count)" -ForegroundColor Red
            $user.roles.removed | ForEach-Object {
                Write-Host "     - $_" -ForegroundColor Red
            }
        }
        
        Write-Host ""
    }
    
    Write-Host "✅ Test completado exitosamente" -ForegroundColor Green
    
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    $errorBody = $_.ErrorDetails.Message
    
    Write-Host "================================================" -ForegroundColor Red
    Write-Host "  ❌ ERROR ($statusCode)" -ForegroundColor Red
    Write-Host "================================================" -ForegroundColor Red
    Write-Host ""
    
    # Intentar parsear el error como JSON
    try {
        $errorObj = $errorBody | ConvertFrom-Json
        
        Write-Host "📋 Mensaje: $($errorObj.message)" -ForegroundColor Yellow
        
        if ($errorObj.error_code) {
            Write-Host "🔑 Código de error: $($errorObj.error_code)" -ForegroundColor Yellow
        }
        
        if ($errorObj.errors) {
            Write-Host ""
            Write-Host "🚨 Errores de validación:" -ForegroundColor Red
            $errorObj.errors.PSObject.Properties | ForEach-Object {
                Write-Host "  $($_.Name):" -ForegroundColor Red
                $_.Value | ForEach-Object {
                    Write-Host "    - $_" -ForegroundColor Red
                }
            }
        }
        
        Write-Host ""
        Write-Host "📥 Respuesta completa:" -ForegroundColor Gray
        $errorObj | ConvertTo-Json -Depth 10 | Write-Host -ForegroundColor Gray
        
    } catch {
        Write-Host "📋 Error raw:" -ForegroundColor Yellow
        Write-Host $errorBody -ForegroundColor Gray
    }
    
    Write-Host ""
    Write-Host "🔍 Detalles técnicos:" -ForegroundColor Gray
    Write-Host $_.Exception.Message -ForegroundColor Gray
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  FIN DEL TEST" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan

# ============================================
# CASOS DE USO ADICIONALES
# ============================================

Write-Host ""
Write-Host "💡 OTROS CASOS DE USO:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Solo agregar roles:" -ForegroundColor White
Write-Host '   $body = @{ rolesToAdd = @("editor") } | ConvertTo-Json' -ForegroundColor Gray
Write-Host ""
Write-Host "2. Solo eliminar roles:" -ForegroundColor White
Write-Host '   $body = @{ rolesToRemove = @("viewer") } | ConvertTo-Json' -ForegroundColor Gray
Write-Host ""
Write-Host "3. Probar con otro usuario:" -ForegroundColor White
Write-Host '   $USER_ID = 5' -ForegroundColor Gray
Write-Host ""
Write-Host "4. Ver todos los usuarios disponibles:" -ForegroundColor White
Write-Host '   Invoke-RestMethod -Uri "$API_BASE_URL/v1/admin-actions/show-users" -Headers $headers' -ForegroundColor Gray
Write-Host ""
