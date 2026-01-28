# Script para probar el endpoint get-student
# Ejecutar: powershell -ExecutionPolicy Bypass -File test-get-student.ps1

param(
    [int]$UserId = 4  # Cambiar por un ID válido
)

$API_BASE = "https://nginx-production-728f.up.railway.app/api/v1"

Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   TEST ENDPOINT - OBTENER DETALLES DE ESTUDIANTE" -ForegroundColor Cyan
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

# Paso 2: Obtener detalles del estudiante
Write-Host "🔍 PASO 2: Obteniendo detalles del estudiante ID: $UserId..." -ForegroundColor Yellow
Write-Host ""

try {
    $response = Invoke-RestMethod -Uri "$API_BASE/admin-actions/get-student/$UserId" -Method Get -Headers $headers
    
    if ($response.success) {
        Write-Host ""
        Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
        Write-Host "   ✅ DETALLES ENCONTRADOS" -ForegroundColor Green
        Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
        Write-Host ""
        Write-Host "   📊 Información del estudiante:" -ForegroundColor White
        Write-Host "   • User ID: $($response.data.user.user_id)" -ForegroundColor Cyan
        Write-Host "   • N° Control: $($response.data.user.n_control)" -ForegroundColor Cyan
        Write-Host "   • Semestre: $($response.data.user.semestre)" -ForegroundColor Cyan
        Write-Host "   • Grupo: $($response.data.user.group)" -ForegroundColor Cyan
        Write-Host "   • Taller: $($response.data.user.workshop)" -ForegroundColor Cyan
        Write-Host "   • Career ID: $($response.data.user.career_id)" -ForegroundColor Cyan
        
        if ($response.data.user.career) {
            Write-Host ""
            Write-Host "   🏫 Carrera:" -ForegroundColor White
            Write-Host "   • ID: $($response.data.user.career.id)" -ForegroundColor Cyan
            Write-Host "   • Nombre: $($response.data.user.career.name)" -ForegroundColor Cyan
        }
        
        Write-Host ""
        Write-Host "   💬 Mensaje: $($response.message)" -ForegroundColor Gray
        Write-Host ""
    } else {
        Write-Host ""
        Write-Host "❌ NO SE ENCONTRARON DETALLES" -ForegroundColor Red
        Write-Host ""
        Write-Host "   Error: $($response.message)" -ForegroundColor Red
        Write-Host "   Código: $($response.error_code)" -ForegroundColor Red
        Write-Host ""
    }
} catch {
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Red
    Write-Host "   ❌ ERROR AL OBTENER DETALLES" -ForegroundColor Red
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
            Write-Host "   Código: $($errorData.error_code)" -ForegroundColor Red
        } catch {
            Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    Write-Host ""
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   NOTAS IMPORTANTES" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Para probar con otro usuario:" -ForegroundColor Yellow
Write-Host "  powershell -File test-get-student.ps1 -UserId 5" -ForegroundColor Gray
Write-Host ""
Write-Host "  Si retorna 404 'Usuario no tiene detalles...'" -ForegroundColor Yellow
Write-Host "  significa que el usuario no tiene asociados" -ForegroundColor Yellow
Write-Host "  detalles de estudiante. Usa attach-student primero." -ForegroundColor Yellow
Write-Host ""
