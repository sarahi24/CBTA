# Test Dashboard Refresh Cache Endpoint
# POST /api/v1/dashboard/refresh/{studentId?}
# Author: GitHub Copilot
# Date: February 5, 2026

$baseUrl = "https://nginx-production-728f.up.railway.app/api/v1"
$endpoint = "/dashboard/refresh"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Test Dashboard Cache Refresh" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# 1. Request access token
Write-Host "Step 1: Requesting access token..." -ForegroundColor Yellow

$loginBody = @{
    email = "student@cbta.edu.mx"  # Change to your test student email
    password = "password123"        # Change to your test password
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/login" -Method Post -Body $loginBody -ContentType "application/json"
    $token = $loginResponse.data.access_token
    $studentId = $loginResponse.data.user.id
    
    Write-Host "✓ Token obtained successfully" -ForegroundColor Green
    Write-Host "Student ID: $studentId`n" -ForegroundColor Gray
    
} catch {
    Write-Host "✗ Login failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Response: $($_.ErrorDetails.Message)" -ForegroundColor Red
    exit 1
}

# 2. Test cache refresh without studentId (for student)
Write-Host "Step 2: Testing cache refresh (without studentId)..." -ForegroundColor Yellow

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
    "Accept" = "application/json"
    "X-User-Role" = "student"
    "X-User-Permission" = "refresh.all.dashboard"
}

try {
    $refreshUrl = "$baseUrl$endpoint"
    Write-Host "URL: $refreshUrl" -ForegroundColor Gray
    
    $response = Invoke-RestMethod -Uri $refreshUrl -Method Post -Headers $headers
    
    Write-Host "✓ Cache refresh successful`n" -ForegroundColor Green
    Write-Host "Response:" -ForegroundColor Cyan
    $response | ConvertTo-Json -Depth 10 | Write-Host
    
} catch {
    Write-Host "✗ Cache refresh failed: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails.Message) {
        Write-Host "Response: $($_.ErrorDetails.Message)" -ForegroundColor Red
    }
}

# 3. Test cache refresh with studentId (for parent)
Write-Host "`nStep 3: Testing cache refresh with studentId (parent role)..." -ForegroundColor Yellow

$headersParent = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
    "Accept" = "application/json"
    "X-User-Role" = "parent"
    "X-User-Permission" = "refresh.all.dashboard"
}

try {
    $refreshUrlWithId = "$baseUrl$endpoint/$studentId"
    Write-Host "URL: $refreshUrlWithId" -ForegroundColor Gray
    
    $responseWithId = Invoke-RestMethod -Uri $refreshUrlWithId -Method Post -Headers $headersParent
    
    Write-Host "✓ Cache refresh with studentId successful`n" -ForegroundColor Green
    Write-Host "Response:" -ForegroundColor Cyan
    $responseWithId | ConvertTo-Json -Depth 10 | Write-Host
    
} catch {
    Write-Host "✗ Cache refresh with studentId failed: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails.Message) {
        Write-Host "Response: $($_.ErrorDetails.Message)" -ForegroundColor Red
    }
}

# 4. Test with invalid permission (should fail with 403)
Write-Host "`nStep 4: Testing with invalid permission (should fail)..." -ForegroundColor Yellow

$headersInvalid = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
    "Accept" = "application/json"
    "X-User-Role" = "student"
    "X-User-Permission" = "invalid.permission"
}

try {
    $responseInvalid = Invoke-RestMethod -Uri "$baseUrl$endpoint" -Method Post -Headers $headersInvalid
    Write-Host "✗ Expected 403 error but request succeeded" -ForegroundColor Red
    
} catch {
    if ($_.Exception.Response.StatusCode -eq 403) {
        Write-Host "✓ Correctly returned 403 Forbidden`n" -ForegroundColor Green
    } else {
        Write-Host "✗ Unexpected error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Test completed!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
