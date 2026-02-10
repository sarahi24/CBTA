# Script de prueba para actualización de relaciones con booleanos de control
# Uso: .\test-update-relations-with-booleans.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  PRUEBA: Actualizar Relaciones" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Configuración
$apiBaseUrl = "https://nginx-production-728f.up.railway.app/api"

# Solicitar datos
$token = Read-Host "Ingresa tu token de acceso (access_token)"
$conceptId = Read-Host "Ingresa el ID del concepto a actualizar"

if ([string]::IsNullOrWhiteSpace($token) -or [string]::IsNullOrWhiteSpace($conceptId)) {
    Write-Host "❌ Error: Token y ID son obligatorios" -ForegroundColor Red
    exit 1
}

$endpoint = "$apiBaseUrl/v1/concepts/update-relations/$conceptId"

Write-Host ""
Write-Host "🔧 Opciones de actualización:" -ForegroundColor Yellow
Write-Host "1. Agregar relaciones (mantener anteriores)" -ForegroundColor White
Write-Host "2. Reemplazar relaciones (eliminar anteriores)" -ForegroundColor White
Write-Host "3. Agregar excepciones (mantener anteriores)" -ForegroundColor White
Write-Host "4. Reemplazar excepciones (eliminar anteriores)" -ForegroundColor White
Write-Host "5. Eliminar TODAS las excepciones" -ForegroundColor Red
Write-Host ""

$option = Read-Host "Selecciona una opción (1-5)"

$payload = @{
    applies_to = "semestre"
    semestres = @(3, 4)
    replaceRelations = $false
    removeAllExceptions = $false
    replaceExceptions = $false
}

switch ($option) {
    "1" {
        Write-Host "✅ Configurado: Agregar semestres 3 y 4 (mantener anteriores)" -ForegroundColor Green
        $payload.replaceRelations = $false
    }
    "2" {
        Write-Host "✅ Configurado: Reemplazar con semestres 3 y 4 (eliminar anteriores)" -ForegroundColor Green
        $payload.replaceRelations = $true
    }
    "3" {
        Write-Host "✅ Configurado: Agregar excepciones (mantener anteriores)" -ForegroundColor Green
        $payload.exceptionStudents = @("11", "25", "89")
        $payload.replaceExceptions = $false
    }
    "4" {
        Write-Host "✅ Configurado: Reemplazar excepciones (eliminar anteriores)" -ForegroundColor Green
        $payload.exceptionStudents = @("11", "25", "89")
        $payload.replaceExceptions = $true
    }
    "5" {
        Write-Host "⚠️ Configurado: Eliminar TODAS las excepciones" -ForegroundColor Red
        $payload.removeAllExceptions = $true
    }
    default {
        Write-Host "❌ Opción inválida" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "📤 Payload a enviar:" -ForegroundColor Cyan
$payloadJson = $payload | ConvertTo-Json -Depth 10
Write-Host $payloadJson -ForegroundColor White
Write-Host ""

$confirmSend = Read-Host "¿Deseas enviar esta petición? (s/n)"

if ($confirmSend -ne "s" -and $confirmSend -ne "S") {
    Write-Host "❌ Operación cancelada por el usuario" -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "🚀 Enviando petición PATCH..." -ForegroundColor Green

try {
    $headers = @{
        "Accept" = "application/json"
        "Content-Type" = "application/json"
        "Authorization" = "Bearer $token"
        "X-User-Role" = "financial-staff"
        "X-User-Permission" = "update.concepts"
    }

    $response = Invoke-RestMethod -Uri $endpoint -Method Patch -Headers $headers -Body $payloadJson -ErrorAction Stop

    Write-Host ""
    Write-Host "✅ Relaciones actualizadas exitosamente!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📊 Respuesta del servidor:" -ForegroundColor Cyan
    Write-Host ($response | ConvertTo-Json -Depth 10) -ForegroundColor White

    Write-Host ""
    Write-Host "💡 Explicación de lo que ocurrió:" -ForegroundColor Yellow
    switch ($option) {
        "1" {
            Write-Host "• Se agregaron los semestres 3 y 4 sin eliminar los semestres anteriores" -ForegroundColor White
            Write-Host "• El concepto ahora aplica a TODOS los semestres configurados" -ForegroundColor White
        }
        "2" {
            Write-Host "• Se reemplazaron los semestres anteriores" -ForegroundColor White
            Write-Host "• El concepto SOLO aplica a los semestres 3 y 4 ahora" -ForegroundColor White
        }
        "3" {
            Write-Host "• Se agregaron las excepciones sin eliminar las anteriores" -ForegroundColor White
            Write-Host "• Las excepciones previas + nuevas están activas" -ForegroundColor White
        }
        "4" {
            Write-Host "• Se reemplazaron las excepciones anteriores" -ForegroundColor White
            Write-Host "• SOLO las nuevas excepciones están activas" -ForegroundColor White
        }
        "5" {
            Write-Host "• Se eliminaron TODAS las excepciones del concepto" -ForegroundColor White
            Write-Host "• El concepto ahora aplica a todos los estudiantes según filtros" -ForegroundColor White
        }
    }

} catch {
    Write-Host ""
    Write-Host "❌ Error al actualizar relaciones:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    
    if ($_.Exception.Response) {
        try {
            $streamReader = [System.IO.StreamReader]::new($_.Exception.Response.GetResponseStream())
            $errorBody = $streamReader.ReadToEnd()
            $streamReader.Close()
            
            Write-Host ""
            Write-Host "📋 Detalles del error:" -ForegroundColor Yellow
            Write-Host $errorBody -ForegroundColor White
        } catch {
            Write-Host "No se pudo leer el cuerpo del error" -ForegroundColor Yellow
        }
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Prueba completada" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
