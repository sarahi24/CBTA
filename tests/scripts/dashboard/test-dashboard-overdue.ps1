# Test Dashboard Overdue Payments Endpoint
# GET /api/v1/dashboard/overdue/{studentId?}
# Author: GitHub Copilot
# Date: February 5, 2026

$baseUrl = "https://nginx-production-728f.up.railway.app/api/v1"
$endpoint = "/dashboard/overdue"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Test Dashboard Overdue Payments" -ForegroundColor Cyan
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

# 2. Test get overdue total without studentId (for student)
Write-Host "Step 2: Getting overdue total (without studentId)..." -ForegroundColor Yellow

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
    "Accept" = "application/json"
    "X-User-Role" = "student"
    "X-User-Permission" = "view.own.overdue.concepts.summary"
}

try {
    $overdueUrl = "$baseUrl$endpoint"
    Write-Host "URL: $overdueUrl" -ForegroundColor Gray
    
    $response = Invoke-RestMethod -Uri $overdueUrl -Method Get -Headers $headers
    
    Write-Host "✓ Overdue total retrieved successfully`n" -ForegroundColor Green
    Write-Host "Response:" -ForegroundColor Cyan
    $response | ConvertTo-Json -Depth 10 | Write-Host
    
    $totalAmount = $response.data.total_overdue.totalAmount
    $totalCount = $response.data.total_overdue.totalCount
    Write-Host "`nSummary:" -ForegroundColor Cyan
    Write-Host "  Total Amount: $totalAmount MXN" -ForegroundColor White
    Write-Host "  Total Count: $totalCount overdue payment(s)`n" -ForegroundColor White
    
} catch {
    Write-Host "✗ Failed to retrieve overdue total: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails.Message) {
        Write-Host "Response: $($_.ErrorDetails.Message)" -ForegroundColor Red
    }
}

# 3. Test with forceRefresh parameter
Write-Host "Step 3: Getting overdue total with forceRefresh=true..." -ForegroundColor Yellow

try {
    $overdueUrlRefresh = "$baseUrl$endpoint`?forceRefresh=true"
    Write-Host "URL: $overdueUrlRefresh" -ForegroundColor Gray
    
    $responseRefresh = Invoke-RestMethod -Uri $overdueUrlRefresh -Method Get -Headers $headers
    
    Write-Host "✓ Overdue total with forceRefresh retrieved successfully`n" -ForegroundColor Green
    Write-Host "Response:" -ForegroundColor Cyan
    $responseRefresh | ConvertTo-Json -Depth 10 | Write-Host
    
} catch {
    Write-Host "✗ Failed to retrieve overdue total with forceRefresh: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails.Message) {
        Write-Host "Response: $($_.ErrorDetails.Message)" -ForegroundColor Red
    }
}

# 4. Test with studentId (for parent)
Write-Host "`nStep 4: Getting overdue total with studentId (parent role)..." -ForegroundColor Yellow

$headersParent = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
    "Accept" = "application/json"
    "X-User-Role" = "parent"
    "X-User-Permission" = "view.own.overdue.concepts.summary"
}

try {
    $overdueUrlWithId = "$baseUrl$endpoint/$studentId"
    Write-Host "URL: $overdueUrlWithId" -ForegroundColor Gray
    
    $responseWithId = Invoke-RestMethod -Uri $overdueUrlWithId -Method Get -Headers $headersParent
    
    Write-Host "✓ Overdue total with studentId retrieved successfully`n" -ForegroundColor Green
    Write-Host "Response:" -ForegroundColor Cyan
    $responseWithId | ConvertTo-Json -Depth 10 | Write-Host
    
} catch {
    Write-Host "✗ Failed to retrieve overdue total with studentId: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails.Message) {
        Write-Host "Response: $($_.ErrorDetails.Message)" -ForegroundColor Red
    }
}

# 5. Test with invalid permission (should fail with 403)
Write-Host "`nStep 5: Testing with invalid permission (should fail)..." -ForegroundColor Yellow

$headersInvalid = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
    "Accept" = "application/json"
    "X-User-Role" = "student"
    "X-User-Permission" = "invalid.permission"
}

try {
    $responseInvalid = Invoke-RestMethod -Uri "$baseUrl$endpoint" -Method Get -Headers $headersInvalid
    Write-Host "✗ Expected 403 error but request succeeded" -ForegroundColor Red
    
} catch {
    if ($_.Exception.Response.StatusCode -eq 403) {
        Write-Host "✓ Correctly returned 403 Forbidden`n" -ForegroundColor Green
    } else {
        Write-Host "✗ Unexpected error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# 6. Test without authentication (should fail with 401)
Write-Host "Step 6: Testing without authentication (should fail)..." -ForegroundColor Yellow

$headersNoAuth = @{
    "Content-Type" = "application/json"
    "Accept" = "application/json"
    "X-User-Role" = "student"
    "X-User-Permission" = "view.own.overdue.concepts.summary"
}

try {
    $responseNoAuth = Invoke-RestMethod -Uri "$baseUrl$endpoint" -Method Get -Headers $headersNoAuth
    Write-Host "✗ Expected 401 error but request succeeded" -ForegroundColor Red
    
} catch {
    if ($_.Exception.Response.StatusCode -eq 401) {
        Write-Host "✓ Correctly returned 401 Unauthorized`n" -ForegroundColor Green
    } else {
        Write-Host "✗ Unexpected error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Test completed!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
