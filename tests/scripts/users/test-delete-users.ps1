# Test Script for POST /api/v1/admin-actions/delete-users
# Elimina múltiples usuarios cambiando su status a 'eliminado'

param(
    [string]$BaseUrl = "https://nginx-production-728f.up.railway.app",
    [string]$AdminEmail = "admin@admin.com",
    [string]$AdminPassword = "adminadmin"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TEST: Delete Users Endpoint" -ForegroundColor Cyan
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
Write-Host "[STEP 2] Getting list of users..." -ForegroundColor Yellow

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
    Write-Host "  Total users: $($usersResponse.data.users.total)" -ForegroundColor Gray
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
# STEP 3: Test Delete Users (Soft Delete)
# --------------------------------------------
Write-Host "[STEP 3] Testing delete-users endpoint..." -ForegroundColor Yellow
Write-Host ""

# Test Case 1: Delete single user
Write-Host "  [Test Case 1] Deleting single user..." -ForegroundColor Cyan
Write-Host "  ⚠ IMPORTANT: Replace the ID below with a real test user ID" -ForegroundColor Yellow
Write-Host ""

$deleteOnePayload = @{
    ids = @(999)  # Replace with actual test user ID
} | ConvertTo-Json

try {
    $deleteOneResponse = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin-actions/delete-users" `
        -Method POST `
        -Headers $headers `
        -Body $deleteOnePayload `
        -ErrorAction Stop

    Write-Host "    ✓ User deleted successfully!" -ForegroundColor Green
    Write-Host "    Success: $($deleteOneResponse.success)" -ForegroundColor Gray
    Write-Host "    Message: $($deleteOneResponse.message)" -ForegroundColor Gray
    Write-Host "    New Status: $($deleteOneResponse.data.concept.newStatus)" -ForegroundColor Gray
    Write-Host "    Total Updated: $($deleteOneResponse.data.concept.totalUpdated)" -ForegroundColor Gray
    Write-Host ""
} catch {
    Write-Host "    ✗ Failed to delete user" -ForegroundColor Red
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

# Test Case 2: Delete multiple users
Write-Host "  [Test Case 2] Deleting multiple users..." -ForegroundColor Cyan
Write-Host "  ⚠ IMPORTANT: Replace the IDs below with real test user IDs" -ForegroundColor Yellow
Write-Host ""

$deleteMultiplePayload = @{
    ids = @(998, 997, 996)  # Replace with actual test user IDs
} | ConvertTo-Json

try {
    $deleteMultipleResponse = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin-actions/delete-users" `
        -Method POST `
        -Headers $headers `
        -Body $deleteMultiplePayload `
        -ErrorAction Stop

    Write-Host "    ✓ Users deleted successfully!" -ForegroundColor Green
    Write-Host "    Success: $($deleteMultipleResponse.success)" -ForegroundColor Gray
    Write-Host "    Message: $($deleteMultipleResponse.message)" -ForegroundColor Gray
    Write-Host "    New Status: $($deleteMultipleResponse.data.concept.newStatus)" -ForegroundColor Gray
    Write-Host "    Total Updated: $($deleteMultipleResponse.data.concept.totalUpdated)" -ForegroundColor Gray
    Write-Host ""
} catch {
    Write-Host "    ✗ Failed to delete users" -ForegroundColor Red
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
    $invalidResponse = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin-actions/delete-users" `
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
    $emptyResponse = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin-actions/delete-users" `
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
    $invalidTypeResponse = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin-actions/delete-users" `
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
# STEP 4: Verify Users Status Changed
# --------------------------------------------
Write-Host "[STEP 4] Verifying users with 'eliminado' status..." -ForegroundColor Yellow

try {
    $deletedUsersResponse = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin-actions/show-users?perPage=10&page=1&status=eliminado" `
        -Method GET `
        -Headers $headers `
        -ErrorAction Stop

    Write-Host "✓ Deleted users retrieved!" -ForegroundColor Green
    Write-Host "  Total deleted users: $($deletedUsersResponse.data.users.total)" -ForegroundColor Gray
    
    if ($deletedUsersResponse.data.users.data.Count -gt 0) {
        Write-Host ""
        Write-Host "  Recently Deleted Users:" -ForegroundColor Cyan
        $deletedUsersResponse.data.users.data | Select-Object -First 5 | ForEach-Object {
            Write-Host "    ID: $($_.id) - $($_.name) $($_.last_name) - Status: $($_.status)" -ForegroundColor White
        }
    }
    Write-Host ""
} catch {
    Write-Host "✗ Failed to get deleted users" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
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
Write-Host "  ✓ Get list of users" -ForegroundColor White
Write-Host "  ✓ Delete single user (soft delete)" -ForegroundColor White
Write-Host "  ✓ Delete multiple users (soft delete)" -ForegroundColor White
Write-Host "  ✓ Invalid user ID validation" -ForegroundColor White
Write-Host "  ✓ Empty array validation" -ForegroundColor White
Write-Host "  ✓ Invalid ID type validation" -ForegroundColor White
Write-Host "  ✓ Verify status changed to 'eliminado'" -ForegroundColor White
Write-Host ""
Write-Host "Note: This is a SOFT DELETE - users are not removed from database" -ForegroundColor Yellow
Write-Host "      Their status is changed to 'eliminado' instead." -ForegroundColor Yellow
Write-Host ""
Write-Host "⚠ IMPORTANT: Replace test user IDs in Test Cases 1 & 2 with real IDs" -ForegroundColor Yellow
Write-Host ""
