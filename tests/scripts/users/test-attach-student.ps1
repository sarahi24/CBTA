# Script para probar el endpoint attach-student
# Ejecutar: powershell -ExecutionPolicy Bypass -File test-attach-student.ps1

$API_BASE = "https://nginx-production-728f.up.railway.app/api/v1"

Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   TEST ENDPOINT - ASOCIAR DETALLES DE ESTUDIANTE" -ForegroundColor Cyan
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

# Paso 2: Crear o usar un usuario existente para asociar
Write-Host "👤 PASO 2: Preparando usuario de prueba..." -ForegroundColor Yellow
Write-Host "   (En producción, usa un user_id real existente)" -ForegroundColor Gray
Write-Host ""

# Ejemplo de datos para asociar
$attachData = @{
    user_id = 4  # Cambiar por un ID real
    career_id = 1  # Cambiar por un career_id real
    n_control = "2578900"
    semestre = 1
    group = "A"
    workshop = "Dibujo"
} | ConvertTo-Json

Write-Host "📤 PASO 3: Asociando detalles de estudiante..." -ForegroundColor Yellow
Write-Host ""
Write-Host "   Datos a enviar:" -ForegroundColor White
Write-Host "   • user_id: $($attachData | ConvertFrom-Json | Select-Object -ExpandProperty user_id)" -ForegroundColor Gray
Write-Host "   • career_id: $($attachData | ConvertFrom-Json | Select-Object -ExpandProperty career_id)" -ForegroundColor Gray
Write-Host "   • n_control: $($attachData | ConvertFrom-Json | Select-Object -ExpandProperty n_control)" -ForegroundColor Gray
Write-Host "   • semestre: $($attachData | ConvertFrom-Json | Select-Object -ExpandProperty semestre)" -ForegroundColor Gray
Write-Host "   • group: $($attachData | ConvertFrom-Json | Select-Object -ExpandProperty group)" -ForegroundColor Gray
Write-Host "   • workshop: $($attachData | ConvertFrom-Json | Select-Object -ExpandProperty workshop)" -ForegroundColor Gray
Write-Host ""

try {
    $response = Invoke-RestMethod -Uri "$API_BASE/admin-actions/attach-student" -Method Post -Headers $headers -Body $attachData
    
    if ($response.success) {
        Write-Host ""
        Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
        Write-Host "   ✅ ASOCIACIÓN EXITOSA" -ForegroundColor Green
        Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
        Write-Host ""
        Write-Host "   📊 Datos del usuario:" -ForegroundColor White
        Write-Host "   • ID: $($response.data.user.id)" -ForegroundColor Cyan
        Write-Host "   • Nombre: $($response.data.user.name) $($response.data.user.last_name)" -ForegroundColor Cyan
        Write-Host "   • Email: $($response.data.user.email)" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "   📚 Detalles de estudiante:" -ForegroundColor White
        Write-Host "   • N° Control: $($response.data.user.studentDetail.n_control)" -ForegroundColor Cyan
        Write-Host "   • Semestre: $($response.data.user.studentDetail.semestre)" -ForegroundColor Cyan
        Write-Host "   • Grupo: $($response.data.user.studentDetail.group)" -ForegroundColor Cyan
        Write-Host "   • Taller: $($response.data.user.studentDetail.workshop)" -ForegroundColor Cyan
        Write-Host "   • Career ID: $($response.data.user.studentDetail.career_id)" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "   💬 Mensaje: $($response.message)" -ForegroundColor Gray
        Write-Host ""
    } else {
        Write-Host ""
        Write-Host "❌ ASOCIACIÓN FALLÓ" -ForegroundColor Red
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
    Write-Host "   ❌ ERROR AL ASOCIAR ESTUDIANTE" -ForegroundColor Red
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
Write-Host "  1. Cambia 'user_id' por un ID de usuario real que no" -ForegroundColor Yellow
Write-Host "     tenga detalles de estudiante asignados." -ForegroundColor Yellow
Write-Host ""
Write-Host "  2. Cambia 'career_id' por un ID de carrera válido" -ForegroundColor Yellow
Write-Host "     existente en la tabla 'careers'." -ForegroundColor Yellow
Write-Host ""
Write-Host "  3. El 'n_control' debe ser único (no existir en BD)." -ForegroundColor Yellow
Write-Host ""
Write-Host "  4. Si el endpoint da 500, asegúrate de que Railway" -ForegroundColor Yellow
Write-Host "     esté funcionando y de ejecutar las migraciones:" -ForegroundColor Yellow
Write-Host "     php artisan migrate" -ForegroundColor Gray
Write-Host ""
