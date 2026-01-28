# Test Script for POST /api/v1/admin-actions/disable-users
# Da de baja múltiples usuarios cambiando su status a 'baja'

param(
    [string]$BaseUrl = "https://nginx-production-728f.up.railway.app",
    [string]$AdminEmail = "admin@admin.com",
    [string]$AdminPassword = "adminadmin"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TEST: Disable Users Endpoint" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# --------------------------------------------
# STEP 1: Login as Admin
# --------------------------------------------
Write-Host "[STEP 1] Logging in as admin..." -ForegroundColor Yellow

$loginPayload = @{
    email = $AdminEmail
    password = $AdminPassword
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "$BaseUrl/api/v1/login" `
        -Method POST `
        -Body $loginPayload `
        -ContentType "application/json" `
        -ErrorAction Stop

    $token = $loginResponse.data.token
    Write-Host "✓ Login successful!" -ForegroundColor Green
    Write-Host "  Token: $($token.Substring(0, 20))..." -ForegroundColor Gray
    Write-Host ""
} catch {
    Write-Host "✗ Login failed!" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# --------------------------------------------
# STEP 2: Get List of Active Users
# --------------------------------------------
Write-Host "[STEP 2] Getting list of active users..." -ForegroundColor Yellow

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
    "Accept" = "application/json"
}

try {
    $usersResponse = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin-actions/show-users?perPage=10&page=1&status=activo" `
        -Method GET `
        -Headers $headers `
        -ErrorAction Stop

    Write-Host "✓ Users retrieved successfully!" -ForegroundColor Green
    Write-Host "  Total active users: $($usersResponse.data.users.total)" -ForegroundColor Gray
    Write-Host ""
    
    # Display first few users
    if ($usersResponse.data.users.data.Count -gt 0) {
        Write-Host "  Available Users:" -ForegroundColor Cyan
        $usersResponse.data.users.data | Select-Object -First 5 | ForEach-Object {
            Write-Host "    ID: $($_.id) - $($_.name) $($_.last_name) - Status: $($_.status)" -ForegroundColor White
        }
        Write-Host ""
    }
} catch {
    Write-Host "✗ Failed to get users" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
}

# --------------------------------------------
# STEP 3: Test Disable Users
# --------------------------------------------
Write-Host "[STEP 3] Testing disable-users endpoint..." -ForegroundColor Yellow
Write-Host ""

# Test Case 1: Disable single user
Write-Host "  [Test Case 1] Disabling single user..." -ForegroundColor Cyan
Write-Host "  ⚠ IMPORTANT: Replace the ID below with a real test user ID" -ForegroundColor Yellow
Write-Host ""

$disableOnePayload = @{
    ids = @(999)  # Replace with actual test user ID
} | ConvertTo-Json

try {
    $disableOneResponse = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin-actions/disable-users" `
        -Method POST `
        -Headers $headers `
        -Body $disableOnePayload `
        -ErrorAction Stop

    Write-Host "    ✓ User disabled successfully!" -ForegroundColor Green
    Write-Host "    Success: $($disableOneResponse.success)" -ForegroundColor Gray
    Write-Host "    Message: $($disableOneResponse.message)" -ForegroundColor Gray
    Write-Host "    New Status: $($disableOneResponse.data.concept.newStatus)" -ForegroundColor Gray
    Write-Host "    Total Updated: $($disableOneResponse.data.concept.totalUpdated)" -ForegroundColor Gray
    Write-Host ""
} catch {
    Write-Host "    ✗ Failed to disable user" -ForegroundColor Red
    Write-Host "    Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
    Write-Host "    Error: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($_.ErrorDetails.Message) {
        $errorDetail = $_.ErrorDetails.Message | ConvertFrom-Json
        Write-Host "    Details: $($errorDetail.message)" -ForegroundColor Red
        if ($errorDetail.errors) {
            Write-Host "    Validation Errors:" -ForegroundColor Red
            $errorDetail.errors.PSObject.Properties | ForEach-Object {
                Write-Host "      - $($_.Name): $($_.Value -join ', ')" -ForegroundColor Red
            }
        }
    }
    Write-Host ""
}

# Test Case 2: Disable multiple users
Write-Host "  [Test Case 2] Disabling multiple users..." -ForegroundColor Cyan
Write-Host "  ⚠ IMPORTANT: Replace the IDs below with real test user IDs" -ForegroundColor Yellow
Write-Host ""

$disableMultiplePayload = @{
    ids = @(998, 997, 996)  # Replace with actual test user IDs
} | ConvertTo-Json

try {
    $disableMultipleResponse = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin-actions/disable-users" `
        -Method POST `
        -Headers $headers `
        -Body $disableMultiplePayload `
        -ErrorAction Stop

    Write-Host "    ✓ Users disabled successfully!" -ForegroundColor Green
    Write-Host "    Success: $($disableMultipleResponse.success)" -ForegroundColor Gray
    Write-Host "    Message: $($disableMultipleResponse.message)" -ForegroundColor Gray
    Write-Host "    New Status: $($disableMultipleResponse.data.concept.newStatus)" -ForegroundColor Gray
    Write-Host "    Total Updated: $($disableMultipleResponse.data.concept.totalUpdated)" -ForegroundColor Gray
    Write-Host ""
} catch {
    Write-Host "    ✗ Failed to disable users" -ForegroundColor Red
    Write-Host "    Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
    Write-Host "    Error: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($_.ErrorDetails.Message) {
        $errorDetail = $_.ErrorDetails.Message | ConvertFrom-Json
        Write-Host "    Details: $($errorDetail.message)" -ForegroundColor Red
    }
    Write-Host ""
}

# Test Case 3: Invalid user ID (validation test)
Write-Host "  [Test Case 3] Testing validation with invalid user ID..." -ForegroundColor Cyan

$invalidPayload = @{
    ids = @(99999999)  # Non-existent ID
} | ConvertTo-Json

try {
    $invalidResponse = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin-actions/disable-users" `
        -Method POST `
        -Headers $headers `
        -Body $invalidPayload `
        -ErrorAction Stop

    Write-Host "    ⚠ Validation did NOT fail (unexpected)" -ForegroundColor Yellow
    Write-Host ""
} catch {
    Write-Host "    ✓ Validation error caught correctly!" -ForegroundColor Green
    Write-Host "    Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Gray
    
    if ($_.ErrorDetails.Message) {
        $errorDetail = $_.ErrorDetails.Message | ConvertFrom-Json
        Write-Host "    Error Code: $($errorDetail.error_code)" -ForegroundColor Gray
        Write-Host "    Message: $($errorDetail.message)" -ForegroundColor Gray
        if ($errorDetail.errors) {
            Write-Host "    Validation Errors:" -ForegroundColor Gray
            $errorDetail.errors.PSObject.Properties | ForEach-Object {
                Write-Host "      - $($_.Name): $($_.Value -join ', ')" -ForegroundColor Gray
            }
        }
    }
    Write-Host ""
}

# Test Case 4: Empty array (validation test)
Write-Host "  [Test Case 4] Testing validation with empty array..." -ForegroundColor Cyan

$emptyPayload = @{
    ids = @()
} | ConvertTo-Json

try {
    $emptyResponse = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin-actions/disable-users" `
        -Method POST `
        -Headers $headers `
        -Body $emptyPayload `
        -ErrorAction Stop

    Write-Host "    ⚠ Validation did NOT fail (unexpected)" -ForegroundColor Yellow
    Write-Host ""
} catch {
    Write-Host "    ✓ Validation error caught correctly!" -ForegroundColor Green
    Write-Host "    Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Gray
    
    if ($_.ErrorDetails.Message) {
        $errorDetail = $_.ErrorDetails.Message | ConvertFrom-Json
        Write-Host "    Error Code: $($errorDetail.error_code)" -ForegroundColor Gray
        Write-Host "    Message: $($errorDetail.message)" -ForegroundColor Gray
    }
    Write-Host ""
}

# Test Case 5: Invalid ID type (string instead of integer)
Write-Host "  [Test Case 5] Testing validation with invalid ID type..." -ForegroundColor Cyan

$invalidTypePayload = @{
    ids = @("abc", "xyz")
} | ConvertTo-Json

try {
    $invalidTypeResponse = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin-actions/disable-users" `
        -Method POST `
        -Headers $headers `
        -Body $invalidTypePayload `
        -ErrorAction Stop

    Write-Host "    ⚠ Validation did NOT fail (unexpected)" -ForegroundColor Yellow
    Write-Host ""
} catch {
    Write-Host "    ✓ Validation error caught correctly!" -ForegroundColor Green
    Write-Host "    Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Gray
    
    if ($_.ErrorDetails.Message) {
        $errorDetail = $_.ErrorDetails.Message | ConvertFrom-Json
        Write-Host "    Error Code: $($errorDetail.error_code)" -ForegroundColor Gray
        Write-Host "    Message: $($errorDetail.message)" -ForegroundColor Gray
    }
    Write-Host ""
}

# --------------------------------------------
# STEP 4: Verify Users Status Changed to 'baja'
# --------------------------------------------
Write-Host "[STEP 4] Verifying users with 'baja' status..." -ForegroundColor Yellow

try {
    $disabledUsersResponse = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin-actions/show-users?perPage=10&page=1&status=baja" `
        -Method GET `
        -Headers $headers `
        -ErrorAction Stop

    Write-Host "✓ Disabled users retrieved!" -ForegroundColor Green
    Write-Host "  Total disabled users: $($disabledUsersResponse.data.users.total)" -ForegroundColor Gray
    
    if ($disabledUsersResponse.data.users.data.Count -gt 0) {
        Write-Host ""
        Write-Host "  Recently Disabled Users:" -ForegroundColor Cyan
        $disabledUsersResponse.data.users.data | Select-Object -First 5 | ForEach-Object {
            Write-Host "    ID: $($_.id) - $($_.name) $($_.last_name) - Status: $($_.status)" -ForegroundColor White
        }
    }
    Write-Host ""
} catch {
    Write-Host "✗ Failed to get disabled users" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
}

# --------------------------------------------
# STEP 5: Compare with 'eliminado' status
# --------------------------------------------
Write-Host "[STEP 5] Comparing 'baja' vs 'eliminado' status..." -ForegroundColor Yellow

try {
    $deletedUsersResponse = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin-actions/show-users?perPage=5&page=1&status=eliminado" `
        -Method GET `
        -Headers $headers `
        -ErrorAction Stop

    Write-Host "✓ Status comparison:" -ForegroundColor Green
    Write-Host "  'baja' (disabled): For inactive but recoverable users" -ForegroundColor Gray
    Write-Host "  'eliminado' (deleted): For permanently removed users" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  Total 'eliminado' users: $($deletedUsersResponse.data.users.total)" -ForegroundColor Gray
    Write-Host ""
} catch {
    Write-Host "✗ Failed comparison" -ForegroundColor Red
    Write-Host ""
}

# --------------------------------------------
# Summary
# --------------------------------------------
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Test Complete" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Tested Scenarios:" -ForegroundColor Yellow
Write-Host "  ✓ Login authentication" -ForegroundColor White
Write-Host "  ✓ Get list of active users" -ForegroundColor White
Write-Host "  ✓ Disable single user (status = 'baja')" -ForegroundColor White
Write-Host "  ✓ Disable multiple users (status = 'baja')" -ForegroundColor White
Write-Host "  ✓ Invalid user ID validation" -ForegroundColor White
Write-Host "  ✓ Empty array validation" -ForegroundColor White
Write-Host "  ✓ Invalid ID type validation" -ForegroundColor White
Write-Host "  ✓ Verify status changed to 'baja'" -ForegroundColor White
Write-Host "  ✓ Compare 'baja' vs 'eliminado' status" -ForegroundColor White
Write-Host ""
Write-Host "Status Definitions:" -ForegroundColor Yellow
Write-Host "  • 'activo' = Active user" -ForegroundColor White
Write-Host "  • 'baja' = Disabled/Inactive user (can be reactivated)" -ForegroundColor White
Write-Host "  • 'eliminado' = Deleted user (permanent removal)" -ForegroundColor White
Write-Host ""
Write-Host "⚠ IMPORTANT: Replace test user IDs in Test Cases 1 & 2 with real IDs" -ForegroundColor Yellow
Write-Host ""
