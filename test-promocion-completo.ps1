# Script completo para probar el endpoint de promoción
# Ejecutar: powershell -ExecutionPolicy Bypass -File test-promocion-completo.ps1

$API_BASE = "https://nginx-production-728f.up.railway.app/api/v1"

Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   TEST COMPLETO - ENDPOINT DE PROMOCIÓN DE ESTUDIANTES" -ForegroundColor Cyan
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
        Write-Host "   🎫 Token: $($token.substring(0, 20))..." -ForegroundColor Gray
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

# Paso 2: Debug Info
Write-Host "🔍 PASO 2: Verificando configuración..." -ForegroundColor Yellow

try {
    $debugResponse = Invoke-RestMethod -Uri "$API_BASE/admin-actions/promotion-debug" -Headers $headers -Method Get
    
    if ($debugResponse.success) {
        Write-Host "   ✅ Configuración correcta!" -ForegroundColor Green
        Write-Host "   📊 Roles en sistema: $($debugResponse.debug.total_roles)" -ForegroundColor Gray
        Write-Host "   📚 Roles: $($debugResponse.debug.roles -join ', ')" -ForegroundColor Gray
        Write-Host "   👨‍🎓 ID rol estudiante: $($debugResponse.debug.student_role_id)" -ForegroundColor Gray
        Write-Host "   🔐 Permiso 'promote.student' existe: $($debugResponse.debug.promote_permission_exists)" -ForegroundColor Gray
        Write-Host "   📈 Estudiantes para promover: $($debugResponse.debug.students_count)" -ForegroundColor Gray
        Write-Host ""
        
        if (-not $debugResponse.debug.promote_permission_exists) {
            Write-Host "   ⚠️  ADVERTENCIA: El permiso 'promote.student' no existe en BD" -ForegroundColor Yellow
            Write-Host "   Ejecuta: php artisan db:seed" -ForegroundColor Yellow
            Write-Host ""
        }
        
        if ($debugResponse.debug.students_count -eq 0) {
            Write-Host "   ⚠️  ADVERTENCIA: No hay estudiantes en la base de datos" -ForegroundColor Yellow
            Write-Host "   No se promoverá a nadie." -ForegroundColor Yellow
            Write-Host ""
        }
    } else {
        Write-Host "   ❌ Error en debug: $($debugResponse.message)" -ForegroundColor Red
    }
} catch {
    Write-Host "   ⚠️  No se pudo obtener info de debug" -ForegroundColor Yellow
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host ""
}

# Paso 3: Test Endpoint
Write-Host "🧪 PASO 3: Probando endpoint de test..." -ForegroundColor Yellow

try {
    $testResponse = Invoke-RestMethod -Uri "$API_BASE/admin-actions/promotion-test" -Headers $headers -Method Post
    
    if ($testResponse.success) {
        Write-Host "   ✅ Endpoint de test funciona!" -ForegroundColor Green
        Write-Host "   Usuario autenticado: $($testResponse.user)" -ForegroundColor Gray
        Write-Host ""
    } else {
        Write-Host "   ❌ Test falló: $($testResponse.message)" -ForegroundColor Red
        Write-Host ""
    }
} catch {
    Write-Host "   ❌ Error en test: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
}

# Paso 4: Confirmación
Write-Host "🚀 PASO 4: Ejecutar promoción de estudiantes" -ForegroundColor Yellow
Write-Host ""
Write-Host "   Esta acción:" -ForegroundColor White
Write-Host "   • Incrementará el semestre de TODOS los estudiantes" -ForegroundColor White
Write-Host "   • Dará de baja (status='baja') a estudiantes con semestre > 12" -ForegroundColor White
Write-Host ""

$confirmation = Read-Host "¿Deseas continuar? (S/N)"

if ($confirmation -ne "S" -and $confirmation -ne "s") {
    Write-Host ""
    Write-Host "❌ Operación cancelada por el usuario" -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "📤 Ejecutando promoción..." -ForegroundColor Yellow

try {
    $promoResponse = Invoke-RestMethod -Uri "$API_BASE/admin-actions/promotion" -Headers $headers -Method Post
    
    if ($promoResponse.success) {
        Write-Host ""
        Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
        Write-Host "   ✅ PROMOCIÓN COMPLETADA EXITOSAMENTE" -ForegroundColor Green
        Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
        Write-Host ""
        Write-Host "   📊 Resultados:" -ForegroundColor White
        Write-Host "   • Estudiantes promovidos: $($promoResponse.data.affected.usuarios_promovidos)" -ForegroundColor Cyan
        Write-Host "   • Estudiantes dados de baja: $($promoResponse.data.affected.usuarios_baja)" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "   💬 Mensaje: $($promoResponse.message)" -ForegroundColor Gray
        Write-Host ""
    } else {
        Write-Host ""
        Write-Host "❌ PROMOCIÓN FALLÓ" -ForegroundColor Red
        Write-Host ""
        Write-Host "   Error: $($promoResponse.message)" -ForegroundColor Red
        Write-Host "   Código: $($promoResponse.error_code)" -ForegroundColor Red
        
        if ($promoResponse.errors) {
            Write-Host ""
            Write-Host "   Detalles:" -ForegroundColor Yellow
            $promoResponse.errors | ConvertTo-Json -Depth 3 | Write-Host -ForegroundColor Yellow
        }
        
        if ($promoResponse.debug) {
            Write-Host ""
            Write-Host "   Debug Info:" -ForegroundColor Yellow
            $promoResponse.debug | ConvertTo-Json -Depth 3 | Write-Host -ForegroundColor Yellow
        }
        Write-Host ""
    }
} catch {
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Red
    Write-Host "   ❌ ERROR AL EJECUTAR PROMOCIÓN" -ForegroundColor Red
    Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Red
    Write-Host ""
    Write-Host "   Error HTTP: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
    Write-Host "   Mensaje: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($_.Exception.Response) {
        try {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $reader.BaseStream.Position = 0
            $reader.DiscardBufferedData()
            $responseBody = $reader.ReadToEnd()
            
            Write-Host ""
            Write-Host "   Respuesta del servidor:" -ForegroundColor Yellow
            $responseBody | Write-Host -ForegroundColor Yellow
        } catch {
            Write-Host "   (No se pudo leer la respuesta del servidor)" -ForegroundColor Gray
        }
    }
    Write-Host ""
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   FIN DEL TEST" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
