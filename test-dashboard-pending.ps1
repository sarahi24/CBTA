# Test Dashboard Pending Payments Endpoint
# GET /api/v1/dashboard/pending/{studentId?}
# Author: GitHub Copilot
# Date: February 5, 2026

$baseUrl = "https://nginx-production-728f.up.railway.app/api/v1"
$endpoint = "/dashboard/pending"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Test Dashboard Pending Payments" -ForegroundColor Cyan
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

# 2. Test get pending total without studentId (for student)
Write-Host "Step 2: Getting pending total (without studentId)..." -ForegroundColor Yellow

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
    "Accept" = "application/json"
    "X-User-Role" = "student"
    "X-User-Permission" = "view.own.pending.concepts.summary"
}

try {
    $pendingUrl = "$baseUrl$endpoint"
    Write-Host "URL: $pendingUrl" -ForegroundColor Gray
    
    $response = Invoke-RestMethod -Uri $pendingUrl -Method Get -Headers $headers
    
    Write-Host "✓ Pending total retrieved successfully`n" -ForegroundColor Green
    Write-Host "Response:" -ForegroundColor Cyan
    $response | ConvertTo-Json -Depth 10 | Write-Host
    
    $totalAmount = $response.data.total_pending.totalAmount
    $totalCount = $response.data.total_pending.totalCount
    Write-Host "`nSummary:" -ForegroundColor Cyan
    Write-Host "  Total Amount: $totalAmount MXN" -ForegroundColor White
    Write-Host "  Total Count: $totalCount pending payment(s)`n" -ForegroundColor White
    
} catch {
    Write-Host "✗ Failed to retrieve pending total: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails.Message) {
        Write-Host "Response: $($_.ErrorDetails.Message)" -ForegroundColor Red
    }
}

# 3. Test with forceRefresh parameter
Write-Host "Step 3: Getting pending total with forceRefresh=true..." -ForegroundColor Yellow

try {
    $pendingUrlRefresh = "$baseUrl$endpoint`?forceRefresh=true"
    Write-Host "URL: $pendingUrlRefresh" -ForegroundColor Gray
    
    $responseRefresh = Invoke-RestMethod -Uri $pendingUrlRefresh -Method Get -Headers $headers
    
    Write-Host "✓ Pending total with forceRefresh retrieved successfully`n" -ForegroundColor Green
    Write-Host "Response:" -ForegroundColor Cyan
    $responseRefresh | ConvertTo-Json -Depth 10 | Write-Host
    
} catch {
    Write-Host "✗ Failed to retrieve pending total with forceRefresh: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails.Message) {
        Write-Host "Response: $($_.ErrorDetails.Message)" -ForegroundColor Red
    }
}

# 4. Test with studentId (for parent)
Write-Host "`nStep 4: Getting pending total with studentId (parent role)..." -ForegroundColor Yellow

$headersParent = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
    "Accept" = "application/json"
    "X-User-Role" = "parent"
    "X-User-Permission" = "view.own.pending.concepts.summary"
}

try {
    $pendingUrlWithId = "$baseUrl$endpoint/$studentId"
    Write-Host "URL: $pendingUrlWithId" -ForegroundColor Gray
    
    $responseWithId = Invoke-RestMethod -Uri $pendingUrlWithId -Method Get -Headers $headersParent
    
    Write-Host "✓ Pending total with studentId retrieved successfully`n" -ForegroundColor Green
    Write-Host "Response:" -ForegroundColor Cyan
    $responseWithId | ConvertTo-Json -Depth 10 | Write-Host
    
} catch {
    Write-Host "✗ Failed to retrieve pending total with studentId: $($_.Exception.Message)" -ForegroundColor Red
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
    "X-User-Permission" = "view.own.pending.concepts.summary"
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
    $hasData = $null -ne $validationResponse.data
    $hasTotalPending = $null -ne $validationResponse.data.total_pending
    $hasTotalAmount = $null -ne $validationResponse.data.total_pending.totalAmount
    $hasTotalCount = $null -ne $validationResponse.data.total_pending.totalCount
    
    Write-Host "Data Structure Validation:" -ForegroundColor Cyan
    Write-Host "  success field: $(if($hasSuccess){'✓'}else{'✗'})" -ForegroundColor $(if($hasSuccess){'Green'}else{'Red'})
    Write-Host "  data field: $(if($hasData){'✓'}else{'✗'})" -ForegroundColor $(if($hasData){'Green'}else{'Red'})
    Write-Host "  total_pending field: $(if($hasTotalPending){'✓'}else{'✗'})" -ForegroundColor $(if($hasTotalPending){'Green'}else{'Red'})
    Write-Host "  totalAmount field: $(if($hasTotalAmount){'✓'}else{'✗'})" -ForegroundColor $(if($hasTotalAmount){'Green'}else{'Red'})
    Write-Host "  totalCount field: $(if($hasTotalCount){'✓'}else{'✗'})" -ForegroundColor $(if($hasTotalCount){'Green'}else{'Red'})
    
    if ($hasSuccess -and $hasData -and $hasTotalPending -and $hasTotalAmount -and $hasTotalCount) {
        Write-Host "`n✓ Response structure is valid`n" -ForegroundColor Green
    } else {
        Write-Host "`n✗ Response structure has issues`n" -ForegroundColor Red
    }
    
} catch {
    Write-Host "✗ Validation failed: $($_.Exception.Message)" -ForegroundColor Red
}

# 8. Test comparison: pending vs overdue vs paid
Write-Host "Step 8: Comparing all payment totals..." -ForegroundColor Yellow

try {
    $pendingData = Invoke-RestMethod -Uri "$baseUrl/dashboard/pending" -Method Get -Headers $headers
    
    # Try to get overdue and paid data
    $headersOverdue = $headers.Clone()
    $headersOverdue["X-User-Permission"] = "view.own.overdue.concepts.summary"
    $overdueData = Invoke-RestMethod -Uri "$baseUrl/dashboard/overdue" -Method Get -Headers $headersOverdue -ErrorAction SilentlyContinue
    
    $headersPaid = $headers.Clone()
    $headersPaid["X-User-Permission"] = "view.own.paid.concepts.summary"
    $paidData = Invoke-RestMethod -Uri "$baseUrl/dashboard/paid" -Method Get -Headers $headersPaid -ErrorAction SilentlyContinue
    
    Write-Host "`nPayment Summary Comparison:" -ForegroundColor Cyan
    Write-Host "  Pending: $($pendingData.data.total_pending.totalAmount) MXN ($($pendingData.data.total_pending.totalCount) payments)" -ForegroundColor Yellow
    
    if ($overdueData) {
        Write-Host "  Overdue: $($overdueData.data.total_overdue.totalAmount) MXN ($($overdueData.data.total_overdue.totalCount) payments)" -ForegroundColor Red
    }
    
    if ($paidData) {
        Write-Host "  Paid: $($paidData.paid_data.totalPayments) MXN" -ForegroundColor Green
    }
    
    Write-Host ""
    
} catch {
    Write-Host "✗ Comparison failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Test completed!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
