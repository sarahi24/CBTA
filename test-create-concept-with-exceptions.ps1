# Script de prueba para creación de conceptos con excepciones y tags
# Uso: .\test-create-concept-with-exceptions.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  PRUEBA: Crear Concepto con Excepciones" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Configuración
$apiBaseUrl = "https://nginx-production-728f.up.railway.app/api"
$endpoint = "$apiBaseUrl/v1/concepts"

# Solicitar token
$token = Read-Host "Ingresa tu token de acceso (access_token)"

if ([string]::IsNullOrWhiteSpace($token)) {
    Write-Host "❌ Error: El token es obligatorio" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "📋 Configurando payload de prueba..." -ForegroundColor Yellow
Write-Host ""

# Payload de ejemplo con nuevos campos
$payload = @{
    concept_name = "Concepto de Prueba con Excepciones"
    description = "Concepto para probar excepciones y tags de aplicantes"
    status = "activo"
    amount = 500.00
    start_date = "2025-02-15"
    end_date = "2025-03-01"
    is_global = $false
    applies_to = "semestre"
    semestres = @(1, 2)
    exceptionStudents = @("11", "88", "90")
    applicantTags = "applicants"
} | ConvertTo-Json -Depth 10

Write-Host "📤 Payload a enviar:" -ForegroundColor Cyan
Write-Host $payload -ForegroundColor White
Write-Host ""

$confirmSend = Read-Host "¿Deseas enviar esta petición? (s/n)"

if ($confirmSend -ne "s" -and $confirmSend -ne "S") {
    Write-Host "❌ Operación cancelada por el usuario" -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "🚀 Enviando petición POST..." -ForegroundColor Green

try {
    $headers = @{
        "Accept" = "application/json"
        "Content-Type" = "application/json"
        "Authorization" = "Bearer $token"
        "X-User-Role" = "financial-staff"
        "X-User-Permission" = "create.concepts"
    }

    $response = Invoke-RestMethod -Uri $endpoint -Method Post -Headers $headers -Body $payload -ErrorAction Stop

    Write-Host ""
    Write-Host "✅ Concepto creado exitosamente!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📊 Respuesta del servidor:" -ForegroundColor Cyan
    Write-Host ($response | ConvertTo-Json -Depth 10) -ForegroundColor White

} catch {
    Write-Host ""
    Write-Host "❌ Error al crear concepto:" -ForegroundColor Red
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
