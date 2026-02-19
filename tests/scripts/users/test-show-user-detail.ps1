# Script para probar el endpoint show-users/{id}
# Ejecutar: powershell -ExecutionPolicy Bypass -File test-show-user-detail.ps1

param(
    [int]$UserId = 1,
    [bool]$ForceRefresh = $false
)

$API_BASE = "https://nginx-production-728f.up.railway.app/api/v1"

Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   TEST ENDPOINT - DETALLES DE USUARIO" -ForegroundColor Cyan
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

# Paso 2: Obtener detalles del usuario
Write-Host "👤 PASO 2: Obteniendo detalles del usuario ID: $UserId..." -ForegroundColor Yellow
Write-Host ""

$queryParams = "?forceRefresh=$ForceRefresh"

try {
    $response = Invoke-RestMethod -Uri "$API_BASE/admin-actions/show-users/$UserId$queryParams" -Method Get -Headers $headers
    
    if ($response.success) {
        Write-Host ""
        Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
        Write-Host "   ✅ USUARIO ENCONTRADO" -ForegroundColor Green
        Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
        Write-Host ""
        
        $user = $response.data.user
        
        Write-Host "   📋 Información Personal:" -ForegroundColor White
        Write-Host "   • ID: $($user.id)" -ForegroundColor Cyan
        Write-Host "   • Nombre: $($user.name) $($user.last_name)" -ForegroundColor Cyan
        Write-Host "   • Email: $($user.email)" -ForegroundColor Cyan
        Write-Host "   • CURP: $($user.curp)" -ForegroundColor Cyan
        Write-Host "   • Fecha de Nacimiento: $($user.birthdate)" -ForegroundColor Cyan
        Write-Host "   • Género: $($user.gender)" -ForegroundColor Cyan
        Write-Host "   • Status: $($user.status)" -ForegroundColor Cyan
        Write-Host "   • Registrado: $($user.created_at)" -ForegroundColor Cyan
        
        Write-Host ""
        Write-Host "   📱 Información Básica Adicional:" -ForegroundColor White
        Write-Host "   • Teléfono: $($user.basicInfo.phone_number)" -ForegroundColor Cyan
        Write-Host "   • Dirección: $($user.basicInfo.address)" -ForegroundColor Cyan
        Write-Host "   • Tipo de Sangre: $($user.basicInfo.blood_type)" -ForegroundColor Cyan
        
        if ($user.roles -and $user.roles.Count -gt 0) {
            Write-Host ""
            Write-Host "   🔐 Roles:" -ForegroundColor White
            foreach ($role in $user.roles) {
                Write-Host "   • $role" -ForegroundColor Cyan
            }
        }
        
        if ($user.permissions -and $user.permissions.Count -gt 0) {
            Write-Host ""
            Write-Host "   🔑 Permisos:" -ForegroundColor White
            foreach ($perm in $user.permissions) {
                Write-Host "   • $perm" -ForegroundColor Cyan
            }
        }
        
        if ($user.studentDetail) {
            Write-Host ""
            Write-Host "   🎓 Detalles de Estudiante:" -ForegroundColor White
            Write-Host "   • N° Control: $($user.studentDetail.nControl)" -ForegroundColor Cyan
            Write-Host "   • Semestre: $($user.studentDetail.semestre)" -ForegroundColor Cyan
            Write-Host "   • Grupo: $($user.studentDetail.group)" -ForegroundColor Cyan
            Write-Host "   • Taller: $($user.studentDetail.workshop)" -ForegroundColor Cyan
            Write-Host "   • Carrera: $($user.studentDetail.careerName)" -ForegroundColor Cyan
        } else {
            Write-Host ""
            Write-Host "   ℹ️  Este usuario no tiene detalles de estudiante asignados" -ForegroundColor Yellow
        }
        
        Write-Host ""
        Write-Host "   💬 Mensaje: $($response.message)" -ForegroundColor Gray
        Write-Host ""
    } else {
        Write-Host ""
        Write-Host "❌ USUARIO NO ENCONTRADO" -ForegroundColor Red
        Write-Host ""
        Write-Host "   Error: $($response.message)" -ForegroundColor Red
        Write-Host ""
    }
} catch {
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Red
    Write-Host "   ❌ ERROR AL OBTENER DETALLES DEL USUARIO" -ForegroundColor Red
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
Write-Host "  Ver detalles del usuario 1:" -ForegroundColor Yellow
Write-Host "  powershell -File test-show-user-detail.ps1" -ForegroundColor Gray
Write-Host ""
Write-Host "  Ver detalles del usuario 5:" -ForegroundColor Yellow
Write-Host "  powershell -File test-show-user-detail.ps1 -UserId 5" -ForegroundColor Gray
Write-Host ""
Write-Host "  Forzar actualización del caché:" -ForegroundColor Yellow
Write-Host "  powershell -File test-show-user-detail.ps1 -UserId 1 -ForceRefresh `$true" -ForegroundColor Gray
Write-Host ""
