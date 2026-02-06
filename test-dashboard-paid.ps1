# Test Dashboard Paid Payments Endpoint
# GET /api/v1/dashboard/paid/{studentId?}
# Author: GitHub Copilot
# Date: February 5, 2026

$baseUrl = "https://nginx-production-728f.up.railway.app/api/v1"
$endpoint = "/dashboard/paid"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Test Dashboard Paid Payments" -ForegroundColor Cyan
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

# 2. Test get paid total without studentId (for student)
Write-Host "Step 2: Getting paid total (without studentId)..." -ForegroundColor Yellow

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
    "Accept" = "application/json"
    "X-User-Role" = "student"
    "X-User-Permission" = "view.own.paid.concepts.summary"
}

try {
    $paidUrl = "$baseUrl$endpoint"
    Write-Host "URL: $paidUrl" -ForegroundColor Gray
    
    $response = Invoke-RestMethod -Uri $paidUrl -Method Get -Headers $headers
    
    Write-Host "✓ Paid total retrieved successfully`n" -ForegroundColor Green
    Write-Host "Response:" -ForegroundColor Cyan
    $response | ConvertTo-Json -Depth 10 | Write-Host
    
    $totalPayments = $response.paid_data.totalPayments
    Write-Host "`nSummary:" -ForegroundColor Cyan
    Write-Host "  Total Payments: $totalPayments MXN" -ForegroundColor White
    
    if ($response.paid_data.paymentsByMonth) {
        Write-Host "  Payments by Month:" -ForegroundColor White
        $response.paid_data.paymentsByMonth.PSObject.Properties | ForEach-Object {
            Write-Host "    $($_.Name): $($_.Value) MXN" -ForegroundColor Gray
        }
    }
    Write-Host ""
    
} catch {
    Write-Host "✗ Failed to retrieve paid total: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails.Message) {
        Write-Host "Response: $($_.ErrorDetails.Message)" -ForegroundColor Red
    }
}

# 3. Test with forceRefresh parameter
Write-Host "Step 3: Getting paid total with forceRefresh=true..." -ForegroundColor Yellow

try {
    $paidUrlRefresh = "$baseUrl$endpoint`?forceRefresh=true"
    Write-Host "URL: $paidUrlRefresh" -ForegroundColor Gray
    
    $responseRefresh = Invoke-RestMethod -Uri $paidUrlRefresh -Method Get -Headers $headers
    
    Write-Host "✓ Paid total with forceRefresh retrieved successfully`n" -ForegroundColor Green
    Write-Host "Response:" -ForegroundColor Cyan
    $responseRefresh | ConvertTo-Json -Depth 10 | Write-Host
    
} catch {
    Write-Host "✗ Failed to retrieve paid total with forceRefresh: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails.Message) {
        Write-Host "Response: $($_.ErrorDetails.Message)" -ForegroundColor Red
    }
}

# 4. Test with studentId (for parent)
Write-Host "`nStep 4: Getting paid total with studentId (parent role)..." -ForegroundColor Yellow

$headersParent = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
    "Accept" = "application/json"
    "X-User-Role" = "parent"
    "X-User-Permission" = "view.own.paid.concepts.summary"
}

try {
    $paidUrlWithId = "$baseUrl$endpoint/$studentId"
    Write-Host "URL: $paidUrlWithId" -ForegroundColor Gray
    
    $responseWithId = Invoke-RestMethod -Uri $paidUrlWithId -Method Get -Headers $headersParent
    
    Write-Host "✓ Paid total with studentId retrieved successfully`n" -ForegroundColor Green
    Write-Host "Response:" -ForegroundColor Cyan
    $responseWithId | ConvertTo-Json -Depth 10 | Write-Host
    
} catch {
    Write-Host "✗ Failed to retrieve paid total with studentId: $($_.Exception.Message)" -ForegroundColor Red
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
    "X-User-Permission" = "view.own.paid.concepts.summary"
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

# 7. Test data structure validation
Write-Host "Step 7: Validating response data structure..." -ForegroundColor Yellow

try {
    $validationUrl = "$baseUrl$endpoint"
    $validationResponse = Invoke-RestMethod -Uri $validationUrl -Method Get -Headers $headers
    
    $hasSuccess = $null -ne $validationResponse.success
    $hasPaidData = $null -ne $validationResponse.paid_data
    $hasTotalPayments = $null -ne $validationResponse.paid_data.totalPayments
    $hasPaymentsByMonth = $null -ne $validationResponse.paid_data.paymentsByMonth
    
    Write-Host "Data Structure Validation:" -ForegroundColor Cyan
    Write-Host "  success field: $(if($hasSuccess){'✓'}else{'✗'})" -ForegroundColor $(if($hasSuccess){'Green'}else{'Red'})
    Write-Host "  paid_data field: $(if($hasPaidData){'✓'}else{'✗'})" -ForegroundColor $(if($hasPaidData){'Green'}else{'Red'})
    Write-Host "  totalPayments field: $(if($hasTotalPayments){'✓'}else{'✗'})" -ForegroundColor $(if($hasTotalPayments){'Green'}else{'Red'})
    Write-Host "  paymentsByMonth field: $(if($hasPaymentsByMonth){'✓'}else{'✗'})" -ForegroundColor $(if($hasPaymentsByMonth){'Green'}else{'Red'})
    
    if ($hasSuccess -and $hasPaidData -and $hasTotalPayments) {
        Write-Host "`n✓ Response structure is valid`n" -ForegroundColor Green
    } else {
        Write-Host "`n✗ Response structure has issues`n" -ForegroundColor Red
    }
    
} catch {
    Write-Host "✗ Validation failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Test completed!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
