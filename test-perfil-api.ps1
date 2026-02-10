# Test script para verificar que la API de perfil funciona correctamente
# Este script prueba el endpoint /v1/users/user

$API_URL = "https://nginx-production-728f.up.railway.app/api"

# Obtener token del usuario (necesitas estar autenticado)
Write-Host "🔍 Script de Prueba - Perfil de Usuario" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

# Si tienes un token, puedes usarlo como parámetro
if ($args.Count -eq 0) {
    Write-Host "❌ Uso: .\test-perfil-api.ps1 <TOKEN>" -ForegroundColor Red
    Write-Host ""
    Write-Host "Ejemplo:" -ForegroundColor Yellow
    Write-Host "  .\test-perfil-api.ps1 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'" -ForegroundColor Yellow
    exit 1
}

$TOKEN = $args[0]

Write-Host "📤 Testing GET /v1/users/user" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

try {
    $headers = @{
        "Authorization" = "Bearer $TOKEN"
        "Accept" = "application/json"
    }

    $response = Invoke-RestMethod -Uri "$API_URL/v1/users/user" `
        -Method GET `
        -Headers $headers `
        -ContentType "application/json"

    Write-Host "✅ Response received successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Response Structure:" -ForegroundColor Yellow
    $response | ConvertTo-Json -Depth 10 | Write-Host -ForegroundColor Gray
    Write-Host ""

    if ($response.data.user) {
        Write-Host "User Information:" -ForegroundColor Cyan
        Write-Host "  Name: $($response.data.user.name) $($response.data.user.last_name)" -ForegroundColor White
        Write-Host "  Email: $($response.data.user.email)" -ForegroundColor White
        Write-Host "  ID: $($response.data.user.id)" -ForegroundColor White
        Write-Host "  Roles: $($response.data.user.roles | ConvertTo-Json)" -ForegroundColor White
        Write-Host "  Permissions: $($response.data.user.permissions | ConvertTo-Json)" -ForegroundColor White
    } else {
        Write-Host "⚠️ User data not found in response" -ForegroundColor Yellow
    }
}
catch [System.Net.Http.HttpRequestException] {
    Write-Host "❌ API Request Failed!" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}
catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "Test Complete!" -ForegroundColor Green
