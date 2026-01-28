# Script para probar el endpoint show-users
# Ejecutar: powershell -ExecutionPolicy Bypass -File test-show-users.ps1

param(
    [int]$Page = 1,
    [int]$PerPage = 15,
    [string]$Status = "activo",
    [bool]$ForceRefresh = $false
)

$API_BASE = "https://nginx-production-728f.up.railway.app/api/v1"

Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   TEST ENDPOINT - LISTAR USUARIOS" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Paso 1: Login
Write-Host "📝 PASO 1: Autenticación..." -ForegroundColor Yellow
$loginBody = @{
    email = "admin@example.com"
    password = "password"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "$API_BASE/auth/login" -Method Post -Body $loginBody -ContentType "application/json"
    
    if ($loginResponse.success) {
        $token = $loginResponse.data.token
        Write-Host "   ✅ Login exitoso!" -ForegroundColor Green
        Write-Host "   👤 Usuario: $($loginResponse.data.user.name)" -ForegroundColor Gray
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
}

# Paso 2: Obtener lista de usuarios
Write-Host "👥 PASO 2: Obteniendo lista de usuarios..." -ForegroundColor Yellow
Write-Host ""
Write-Host "   Parámetros:" -ForegroundColor White
Write-Host "   • Page: $Page" -ForegroundColor Cyan
Write-Host "   • Per Page: $PerPage" -ForegroundColor Cyan
Write-Host "   • Status: $Status" -ForegroundColor Cyan
Write-Host "   • Force Refresh: $ForceRefresh" -ForegroundColor Cyan
Write-Host ""

# Construir query string
$queryParams = "?page=$Page&perPage=$PerPage&status=$Status&forceRefresh=$ForceRefresh"

try {
    $response = Invoke-RestMethod -Uri "$API_BASE/admin-actions/show-users$queryParams" -Method Get -Headers $headers
    
    if ($response.success) {
        Write-Host ""
        Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
        Write-Host "   ✅ USUARIOS OBTENIDOS" -ForegroundColor Green
        Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
        Write-Host ""
        Write-Host "   📊 Información de paginación:" -ForegroundColor White
        Write-Host "   • Total de usuarios: $($response.data.users.total)" -ForegroundColor Cyan
        Write-Host "   • Página actual: $($response.data.users.currentPage) de $($response.data.users.lastPage)" -ForegroundColor Cyan
        Write-Host "   • Usuarios por página: $($response.data.users.perPage)" -ForegroundColor Cyan
        Write-Host "   • ¿Hay más páginas?: $($response.data.users.hasMorePages)" -ForegroundColor Cyan
        if ($response.data.users.nextPage) {
            Write-Host "   • Próxima página: $($response.data.users.nextPage)" -ForegroundColor Cyan
        }
        
        Write-Host ""
        Write-Host "   👥 Usuarios en esta página:" -ForegroundColor White
        Write-Host ""
        
        $counter = 1
        foreach ($user in $response.data.users.items) {
            Write-Host "   $counter. $($user.fullName)" -ForegroundColor Cyan
            Write-Host "      • ID: $($user.id)" -ForegroundColor Gray
            Write-Host "      • Email: $($user.email)" -ForegroundColor Gray
            Write-Host "      • CURP: $($user.curp)" -ForegroundColor Gray
            Write-Host "      • Status: $($user.status)" -ForegroundColor Gray
            Write-Host "      • Roles: $($user.roles_count)" -ForegroundColor Gray
            Write-Host "      • Registrado: $($user.createdAtHuman)" -ForegroundColor Gray
            Write-Host ""
            $counter++
        }
        
        Write-Host "   💬 Mensaje: $($response.message)" -ForegroundColor Gray
        Write-Host ""
    } else {
        Write-Host ""
        Write-Host "❌ NO SE ENCONTRARON USUARIOS" -ForegroundColor Red
        Write-Host ""
        Write-Host "   Error: $($response.message)" -ForegroundColor Red
        Write-Host ""
    }
} catch {
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Red
    Write-Host "   ❌ ERROR AL OBTENER USUARIOS" -ForegroundColor Red
    Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Red
    Write-Host ""
    
    $statusCode = $_.Exception.Response.StatusCode.value__
    Write-Host "   HTTP Status: $statusCode" -ForegroundColor Red
    
    if ($_.Exception.Response) {
        try {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $reader.BaseStream.Position = 0
            $reader.DiscardBufferedData()
            $responseBody = $reader.ReadToEnd()
            $errorData = $responseBody | ConvertFrom-Json
            
            Write-Host "   Error: $($errorData.message)" -ForegroundColor Red
        } catch {
            Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    Write-Host ""
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   EJEMPLOS DE USO" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Listar página 1 con 15 usuarios:" -ForegroundColor Yellow
Write-Host "  powershell -File test-show-users.ps1" -ForegroundColor Gray
Write-Host ""
Write-Host "  Listar página 2 con 20 usuarios por página:" -ForegroundColor Yellow
Write-Host "  powershell -File test-show-users.ps1 -Page 2 -PerPage 20" -ForegroundColor Gray
Write-Host ""
Write-Host "  Listar solo usuarios con estado 'baja':" -ForegroundColor Yellow
Write-Host "  powershell -File test-show-users.ps1 -Status baja" -ForegroundColor Gray
Write-Host ""
Write-Host "  Forzar actualización del caché:" -ForegroundColor Yellow
Write-Host "  powershell -File test-show-users.ps1 -ForceRefresh `$true" -ForegroundColor Gray
Write-Host ""
Write-Host "  Estados disponibles: activo, baja-temporal, baja, eliminado, all" -ForegroundColor Yellow
Write-Host ""
