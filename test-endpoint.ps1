# Test the promotion endpoint deployment

# First, let's get a token by logging in with test credentials
$loginUrl = "https://nginx-production-728f.up.railway.app/api/v1/auth/login"
$loginPayload = @{
    email = "admin@example.com"
    password = "password"
} | ConvertTo-Json

Write-Host "Attempting to login..." -ForegroundColor Yellow

$loginResponse = Invoke-RestMethod -Uri $loginUrl -Method Post -ContentType "application/json" -Body $loginPayload -ErrorAction SilentlyContinue

if ($loginResponse) {
    $token = $loginResponse.data.token
    Write-Host "✅ Login successful! Token: $($token.substring(0, 20))..." -ForegroundColor Green
    
    # Now test the promotion-test endpoint
    $testUrl = "https://nginx-production-728f.up.railway.app/api/v1/admin-actions/promotion-test"
    $headers = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json"
    }
    
    Write-Host "`nTesting promotion-test endpoint..." -ForegroundColor Yellow
    $testResponse = Invoke-RestMethod -Uri $testUrl -Method Post -Headers $headers -ErrorAction SilentlyContinue
    
    if ($testResponse) {
        Write-Host "✅ Test endpoint response:" -ForegroundColor Green
        $testResponse | ConvertTo-Json | Write-Host
    } else {
        Write-Host "❌ Test endpoint failed" -ForegroundColor Red
    }
    
} else {
    Write-Host "❌ Login failed. Check credentials." -ForegroundColor Red
}
