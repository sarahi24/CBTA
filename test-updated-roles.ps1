# Test Script for POST /api/v1/admin-actions/updated-roles
# Sincroniza roles de múltiples usuarios
# Agrega o elimina roles a varios usuarios simultáneamente

param(
    [string]$BaseUrl = "https://nginx-production-728f.up.railway.app",
    [string]$AdminEmail = "admin@admin.com",
    [string]$AdminPassword = "adminadmin"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TEST: Updated Roles Endpoint" -ForegroundColor Cyan
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
# STEP 2: Test Updated-Roles with Multiple Users
# --------------------------------------------
Write-Host "[STEP 2] Testing updated-roles endpoint..." -ForegroundColor Yellow
Write-Host ""

# Test Case 1: Add roles to multiple users
Write-Host "  [Test Case 1] Adding roles to users..." -ForegroundColor Cyan

$addRolesPayload = @{
    curps = @(
        "GODE561231HDFABC09",
        "PEMJ800101MDFLRS08"
    )
    rolesToAdd = @(
        "student"
    )
    rolesToRemove = @()
} | ConvertTo-Json

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
    "Accept" = "application/json"
}

try {
    $addRolesResponse = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin-actions/updated-roles" `
        -Method POST `
        -Headers $headers `
        -Body $addRolesPayload `
        -ErrorAction Stop

    Write-Host "    ✓ Roles added successfully!" -ForegroundColor Green
    Write-Host "    Success: $($addRolesResponse.success)" -ForegroundColor Gray
    Write-Host "    Message: $($addRolesResponse.message)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "    Users Updated:" -ForegroundColor Cyan
    foreach ($name in $addRolesResponse.data.users_roles.fullNames) {
        Write-Host "      - $name" -ForegroundColor White
    }
    Write-Host ""
    Write-Host "    Metadata:" -ForegroundColor Cyan
    Write-Host "      Total Found: $($addRolesResponse.data.users_roles.metadata.totalFound)" -ForegroundColor White
    Write-Host "      Total Updated: $($addRolesResponse.data.users_roles.metadata.totalUpdated)" -ForegroundColor White
    Write-Host "      Failed: $($addRolesResponse.data.users_roles.metadata.failed)" -ForegroundColor White
    Write-Host "      Chunks Processed: $($addRolesResponse.data.users_roles.metadata.operations.chunks_processed)" -ForegroundColor White
    Write-Host ""
} catch {
    Write-Host "    ✗ Failed to add roles" -ForegroundColor Red
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

# Test Case 2: Remove roles from multiple users
Write-Host "  [Test Case 2] Removing roles from users..." -ForegroundColor Cyan

$removeRolesPayload = @{
    curps = @(
        "GODE561231HDFABC09",
        "PEMJ800101MDFLRS08"
    )
    rolesToAdd = @()
    rolesToRemove = @(
        "financial staff"
    )
} | ConvertTo-Json

try {
    $removeRolesResponse = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin-actions/updated-roles" `
        -Method POST `
        -Headers $headers `
        -Body $removeRolesPayload `
        -ErrorAction Stop

    Write-Host "    ✓ Roles removed successfully!" -ForegroundColor Green
    Write-Host "    Success: $($removeRolesResponse.success)" -ForegroundColor Gray
    Write-Host "    Message: $($removeRolesResponse.message)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "    Users Updated:" -ForegroundColor Cyan
    foreach ($name in $removeRolesResponse.data.users_roles.fullNames) {
        Write-Host "      - $name" -ForegroundColor White
    }
    Write-Host ""
    Write-Host "    Metadata:" -ForegroundColor Cyan
    Write-Host "      Total Found: $($removeRolesResponse.data.users_roles.metadata.totalFound)" -ForegroundColor White
    Write-Host "      Total Updated: $($removeRolesResponse.data.users_roles.metadata.totalUpdated)" -ForegroundColor White
    Write-Host "      Failed: $($removeRolesResponse.data.users_roles.metadata.failed)" -ForegroundColor White
    Write-Host ""
} catch {
    Write-Host "    ✗ Failed to remove roles" -ForegroundColor Red
    Write-Host "    Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
    Write-Host "    Error: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($_.ErrorDetails.Message) {
        $errorDetail = $_.ErrorDetails.Message | ConvertFrom-Json
        Write-Host "    Details: $($errorDetail.message)" -ForegroundColor Red
    }
    Write-Host ""
}

# Test Case 3: Add and remove roles simultaneously
Write-Host "  [Test Case 3] Adding and removing roles simultaneously..." -ForegroundColor Cyan

$mixedRolesPayload = @{
    curps = @(
        "GODE561231HDFABC09"
    )
    rolesToAdd = @(
        "admin"
    )
    rolesToRemove = @(
        "student"
    )
} | ConvertTo-Json

try {
    $mixedRolesResponse = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin-actions/updated-roles" `
        -Method POST `
        -Headers $headers `
        -Body $mixedRolesPayload `
        -ErrorAction Stop

    Write-Host "    ✓ Roles updated successfully!" -ForegroundColor Green
    Write-Host "    Success: $($mixedRolesResponse.success)" -ForegroundColor Gray
    Write-Host "    Message: $($mixedRolesResponse.message)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "    Roles Added:" -ForegroundColor Cyan
    foreach ($role in $mixedRolesResponse.data.users_roles.updatedRoles.added) {
        Write-Host "      + $role" -ForegroundColor Green
    }
    Write-Host ""
    Write-Host "    Roles Removed:" -ForegroundColor Cyan
    foreach ($role in $mixedRolesResponse.data.users_roles.updatedRoles.removed) {
        Write-Host "      - $role" -ForegroundColor Red
    }
    Write-Host ""
} catch {
    Write-Host "    ✗ Failed to update roles" -ForegroundColor Red
    Write-Host "    Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
    Write-Host "    Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
}

# Test Case 4: Invalid CURP format (validation test)
Write-Host "  [Test Case 4] Testing validation with invalid CURP..." -ForegroundColor Cyan

$invalidPayload = @{
    curps = @(
        "INVALID123"
    )
    rolesToAdd = @(
        "student"
    )
} | ConvertTo-Json

try {
    $invalidResponse = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin-actions/updated-roles" `
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
    }
    Write-Host ""
}

# Test Case 5: Non-existent role (validation test)
Write-Host "  [Test Case 5] Testing validation with non-existent role..." -ForegroundColor Cyan

$nonExistentRolePayload = @{
    curps = @(
        "GODE561231HDFABC09"
    )
    rolesToAdd = @(
        "superadmin"
    )
} | ConvertTo-Json

try {
    $nonExistentResponse = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin-actions/updated-roles" `
        -Method POST `
        -Headers $headers `
        -Body $nonExistentRolePayload `
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
# Summary
# --------------------------------------------
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Test Complete" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Tested Scenarios:" -ForegroundColor Yellow
Write-Host "  ✓ Login authentication" -ForegroundColor White
Write-Host "  ✓ Add roles to multiple users" -ForegroundColor White
Write-Host "  ✓ Remove roles from multiple users" -ForegroundColor White
Write-Host "  ✓ Add and remove roles simultaneously" -ForegroundColor White
Write-Host "  ✓ Invalid CURP validation" -ForegroundColor White
Write-Host "  ✓ Non-existent role validation" -ForegroundColor White
Write-Host ""
Write-Host "Note: Replace the test CURPs with real CURPs from your database" -ForegroundColor Yellow
Write-Host ""
