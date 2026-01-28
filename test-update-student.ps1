# Script para probar el endpoint update-student
# Ejecutar: powershell -ExecutionPolicy Bypass -File test-update-student.ps1

param(
    [int]$UserId = 4,  # Cambiar por un ID válido que ya tenga detalles de estudiante
    [int]$CareerId = 1,
    [string]$Group = "B",
    [string]$Workshop = "Mecánica"
)

$API_BASE = "https://nginx-production-728f.up.railway.app/api/v1"

Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   TEST ENDPOINT - ACTUALIZAR DETALLES DE ESTUDIANTE" -ForegroundColor Cyan
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

# Paso 2: Ver detalles actuales
Write-Host "🔍 PASO 2: Consultando detalles actuales del estudiante ID: $UserId..." -ForegroundColor Yellow

try {
    $currentDetails = Invoke-RestMethod -Uri "$API_BASE/admin-actions/get-student/$UserId" -Method Get -Headers $headers
    
    if ($currentDetails.success) {
        Write-Host "   📊 Detalles actuales:" -ForegroundColor White
        Write-Host "   • N° Control: $($currentDetails.data.user.n_control)" -ForegroundColor Gray
        Write-Host "   • Semestre: $($currentDetails.data.user.semestre)" -ForegroundColor Gray
        Write-Host "   • Career ID: $($currentDetails.data.user.career_id)" -ForegroundColor Gray
        Write-Host "   • Grupo: $($currentDetails.data.user.group)" -ForegroundColor Gray
        Write-Host "   • Taller: $($currentDetails.data.user.workshop)" -ForegroundColor Gray
        Write-Host ""
    }
} catch {
    Write-Host "   ⚠️  No se pudieron obtener detalles actuales" -ForegroundColor Yellow
    Write-Host ""
}

# Paso 3: Actualizar detalles
Write-Host "📤 PASO 3: Actualizando detalles de estudiante..." -ForegroundColor Yellow
Write-Host ""
Write-Host "   Nuevos valores:" -ForegroundColor White
Write-Host "   • Career ID: $CareerId" -ForegroundColor Cyan
Write-Host "   • Grupo: $Group" -ForegroundColor Cyan
Write-Host "   • Taller: $Workshop" -ForegroundColor Cyan
Write-Host ""

$updateData = @{
    career_id = $CareerId
    group = $Group
    workshop = $Workshop
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$API_BASE/admin-actions/update-student/$UserId" -Method Patch -Headers $headers -Body $updateData
    
    if ($response.success) {
        Write-Host ""
        Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
        Write-Host "   ✅ ACTUALIZACIÓN EXITOSA" -ForegroundColor Green
        Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
        Write-Host ""
        Write-Host "   📊 Datos actualizados del estudiante:" -ForegroundColor White
        Write-Host "   • User ID: $($response.data.user.id)" -ForegroundColor Cyan
        Write-Host "   • Nombre: $($response.data.user.name) $($response.data.user.last_name)" -ForegroundColor Cyan
        Write-Host "   • N° Control: $($response.data.user.studentDetail.n_control)" -ForegroundColor Cyan
        Write-Host "   • Semestre: $($response.data.user.studentDetail.semestre)" -ForegroundColor Cyan
        Write-Host "   • Career ID: $($response.data.user.studentDetail.career_id)" -ForegroundColor Cyan
        Write-Host "   • Grupo: $($response.data.user.studentDetail.group)" -ForegroundColor Cyan
        Write-Host "   • Taller: $($response.data.user.studentDetail.workshop)" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "   💬 Mensaje: $($response.message)" -ForegroundColor Gray
        Write-Host ""
    } else {
        Write-Host ""
        Write-Host "❌ ACTUALIZACIÓN FALLÓ" -ForegroundColor Red
        Write-Host ""
        Write-Host "   Error: $($response.message)" -ForegroundColor Red
        Write-Host "   Código: $($response.error_code)" -ForegroundColor Red
        
        if ($response.errors) {
            Write-Host ""
            Write-Host "   Detalles de validación:" -ForegroundColor Yellow
            foreach ($field in $response.errors.PSObject.Properties) {
                Write-Host "   • $($field.Name):" -ForegroundColor Yellow
                foreach ($error in $field.Value) {
                    Write-Host "     - $error" -ForegroundColor Yellow
                }
            }
        }
        Write-Host ""
    }
} catch {
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Red
    Write-Host "   ❌ ERROR AL ACTUALIZAR ESTUDIANTE" -ForegroundColor Red
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
            
            if ($errorData.errors) {
                Write-Host ""
                Write-Host "   Detalles:" -ForegroundColor Yellow
                foreach ($field in $errorData.errors.PSObject.Properties) {
                    Write-Host "   • $($field.Name):" -ForegroundColor Yellow
                    foreach ($error in $field.Value) {
                        Write-Host "     - $error" -ForegroundColor Yellow
                    }
                }
            }
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
Write-Host "  Para actualizar otro usuario:" -ForegroundColor Yellow
Write-Host "  powershell -File test-update-student.ps1 -UserId 5 -CareerId 2 -Group 'C' -Workshop 'Electrónica'" -ForegroundColor Gray
Write-Host ""
Write-Host "  PATCH update-student solo actualiza:" -ForegroundColor Yellow
Write-Host "  • career_id (requerido)" -ForegroundColor Gray
Write-Host "  • group (opcional)" -ForegroundColor Gray
Write-Host "  • workshop (opcional)" -ForegroundColor Gray
Write-Host ""
Write-Host "  NO actualiza n_control ni semestre" -ForegroundColor Yellow
Write-Host "  (estos solo se asignan con POST attach-student)" -ForegroundColor Gray
Write-Host ""
