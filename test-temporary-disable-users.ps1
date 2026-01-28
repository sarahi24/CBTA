# Test Script for POST /api/v1/admin-actions/temporary-disable-users
# Da de baja temporal múltiples usuarios cambiando su status a 'baja-temporal'

param(
    [string]$BaseUrl = "https://nginx-production-728f.up.railway.app",
    [string]$AdminEmail = "admin@admin.com",
    [string]$AdminPassword = "adminadmin"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TEST: Temporary Disable Users Endpoint" -ForegroundColor Cyan
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
# STEP 3: Test Temporary Disable Users
# --------------------------------------------
Write-Host "[STEP 3] Testing temporary-disable-users endpoint..." -ForegroundColor Yellow
Write-Host ""

# Test Case 1: Temporarily disable single user
Write-Host "  [Test Case 1] Temporarily disabling single user..." -ForegroundColor Cyan
Write-Host "  ⚠ IMPORTANT: Replace the ID below with a real test user ID" -ForegroundColor Yellow
Write-Host ""

$tempDisableOnePayload = @{
    ids = @(999)  # Replace with actual test user ID
} | ConvertTo-Json

try {
    $tempDisableOneResponse = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin-actions/temporary-disable-users" `
        -Method POST `
        -Headers $headers `
        -Body $tempDisableOnePayload `
        -ErrorAction Stop

    Write-Host "    ✓ User temporarily disabled successfully!" -ForegroundColor Green
    Write-Host "    Success: $($tempDisableOneResponse.success)" -ForegroundColor Gray
    Write-Host "    Message: $($tempDisableOneResponse.message)" -ForegroundColor Gray
    Write-Host "    New Status: $($tempDisableOneResponse.data.concept.newStatus)" -ForegroundColor Gray
    Write-Host "    Total Updated: $($tempDisableOneResponse.data.concept.totalUpdated)" -ForegroundColor Gray
    Write-Host ""
} catch {
    Write-Host "    ✗ Failed to temporarily disable user" -ForegroundColor Red
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

# Test Case 2: Temporarily disable multiple users
Write-Host "  [Test Case 2] Temporarily disabling multiple users..." -ForegroundColor Cyan
Write-Host "  ⚠ IMPORTANT: Replace the IDs below with real test user IDs" -ForegroundColor Yellow
Write-Host ""

$tempDisableMultiplePayload = @{
    ids = @(998, 997, 996)  # Replace with actual test user IDs
} | ConvertTo-Json

try {
    $tempDisableMultipleResponse = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin-actions/temporary-disable-users" `
        -Method POST `
        -Headers $headers `
        -Body $tempDisableMultiplePayload `
        -ErrorAction Stop

    Write-Host "    ✓ Users temporarily disabled successfully!" -ForegroundColor Green
    Write-Host "    Success: $($tempDisableMultipleResponse.success)" -ForegroundColor Gray
    Write-Host "    Message: $($tempDisableMultipleResponse.message)" -ForegroundColor Gray
    Write-Host "    New Status: $($tempDisableMultipleResponse.data.concept.newStatus)" -ForegroundColor Gray
    Write-Host "    Total Updated: $($tempDisableMultipleResponse.data.concept.totalUpdated)" -ForegroundColor Gray
    Write-Host ""
} catch {
    Write-Host "    ✗ Failed to temporarily disable users" -ForegroundColor Red
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
    $invalidResponse = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin-actions/temporary-disable-users" `
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
    $emptyResponse = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin-actions/temporary-disable-users" `
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
    $invalidTypeResponse = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin-actions/temporary-disable-users" `
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
# STEP 4: Verify Users Status Changed to 'baja-temporal'
# --------------------------------------------
Write-Host "[STEP 4] Verifying users with 'baja-temporal' status..." -ForegroundColor Yellow

try {
    $tempDisabledUsersResponse = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin-actions/show-users?perPage=10&page=1&status=baja-temporal" `
        -Method GET `
        -Headers $headers `
        -ErrorAction Stop

    Write-Host "✓ Temporarily disabled users retrieved!" -ForegroundColor Green
    Write-Host "  Total temporarily disabled users: $($tempDisabledUsersResponse.data.users.total)" -ForegroundColor Gray
    
    if ($tempDisabledUsersResponse.data.users.data.Count -gt 0) {
        Write-Host ""
        Write-Host "  Recently Temporarily Disabled Users:" -ForegroundColor Cyan
        $tempDisabledUsersResponse.data.users.data | Select-Object -First 5 | ForEach-Object {
            Write-Host "    ID: $($_.id) - $($_.name) $($_.last_name) - Status: $($_.status)" -ForegroundColor White
        }
    }
    Write-Host ""
} catch {
    Write-Host "✗ Failed to get temporarily disabled users" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
}

# --------------------------------------------
# STEP 5: Compare All User Status Types
# --------------------------------------------
Write-Host "[STEP 5] Summary of all user status types..." -ForegroundColor Yellow

$statuses = @("activo", "baja-temporal", "baja", "eliminado")
$totalByStatus = @{}

foreach ($status in $statuses) {
    try {
        $response = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin-actions/show-users?perPage=1&page=1&status=$status" `
            -Method GET `
            -Headers $headers `
            -ErrorAction Stop

        $totalByStatus[$status] = $response.data.users.total
        Write-Host "  • '$status': $($response.data.users.total) users" -ForegroundColor White
    } catch {
        Write-Host "  • '$status': Unable to fetch (status may not exist)" -ForegroundColor Gray
    }
}

Write-Host ""

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
Write-Host "  ✓ Temporarily disable single user" -ForegroundColor White
Write-Host "  ✓ Temporarily disable multiple users" -ForegroundColor White
Write-Host "  ✓ Invalid user ID validation" -ForegroundColor White
Write-Host "  ✓ Empty array validation" -ForegroundColor White
Write-Host "  ✓ Invalid ID type validation" -ForegroundColor White
Write-Host "  ✓ Verify status changed to 'baja-temporal'" -ForegroundColor White
Write-Host "  ✓ Summary of all user status types" -ForegroundColor White
Write-Host ""
Write-Host "Status Definitions:" -ForegroundColor Yellow
Write-Host "  • 'activo' = Active user" -ForegroundColor White
Write-Host "  • 'baja-temporal' = Temporarily disabled user (can be quickly reactivated)" -ForegroundColor White
Write-Host "  • 'baja' = Disabled/Inactive user (permanent until manually changed)" -ForegroundColor White
Write-Host "  • 'eliminado' = Deleted user (permanent removal)" -ForegroundColor White
Write-Host ""
Write-Host "⚠ IMPORTANT: Replace test user IDs in Test Cases 1 & 2 with real IDs" -ForegroundColor Yellow
Write-Host ""
