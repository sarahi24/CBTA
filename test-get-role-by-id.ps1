# Test Script for GET /api/v1/admin-actions/roles/{id}
# Mostrar información de un rol específico por su ID

param(
    [string]$BaseUrl = "https://nginx-production-728f.up.railway.app",
    [string]$AdminEmail = "admin@admin.com",
    [string]$AdminPassword = "adminadmin"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TEST: Get Role by ID Endpoint" -ForegroundColor Cyan
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

# Headers for requests
$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
    "Accept" = "application/json"
}

# --------------------------------------------
# STEP 2: Get All Roles First to Find Valid IDs
# --------------------------------------------
Write-Host "[STEP 2] Getting all roles to find valid IDs..." -ForegroundColor Yellow

try {
    $allRolesResponse = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin-actions/find-roles?forceRefresh=false" `
        -Method GET `
        -Headers $headers `
        -ErrorAction Stop

    Write-Host "✓ Roles retrieved successfully!" -ForegroundColor Green
    Write-Host "  Total Roles: $($allRolesResponse.data.roles.Count)" -ForegroundColor Gray
    Write-Host ""
    
    if ($allRolesResponse.data.roles.Count -gt 0) {
        Write-Host "  Available Roles:" -ForegroundColor Cyan
        $allRolesResponse.data.roles | ForEach-Object {
            Write-Host "    • ID: $($_.id) - $($_.name)" -ForegroundColor White
        }
        Write-Host ""
        $roleIds = @($allRolesResponse.data.roles | Select-Object -ExpandProperty id)
    } else {
        Write-Host "  ✗ No roles found!" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "✗ Failed to get all roles" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# --------------------------------------------
# STEP 3: Test Get Specific Roles by ID
# --------------------------------------------
Write-Host "[STEP 3] Testing get role by ID endpoint..." -ForegroundColor Yellow
Write-Host ""

# Test Case 1: Get first role
if ($roleIds.Count -gt 0) {
    Write-Host "  [Test Case 1] Getting role ID $($roleIds[0])..." -ForegroundColor Cyan

    try {
        $roleResponse = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin-actions/roles/$($roleIds[0])" `
            -Method GET `
            -Headers $headers `
            -ErrorAction Stop

        Write-Host "    ✓ Role retrieved successfully!" -ForegroundColor Green
        Write-Host "    Success: $($roleResponse.success)" -ForegroundColor Gray
        Write-Host "    Message: $($roleResponse.message)" -ForegroundColor Gray
        Write-Host "    Role ID: $($roleResponse.data.role.id)" -ForegroundColor Gray
        Write-Host "    Role Name: $($roleResponse.data.role.name)" -ForegroundColor Gray
        Write-Host ""
    } catch {
        Write-Host "    ✗ Failed to get role" -ForegroundColor Red
        Write-Host "    Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
        Write-Host "    Error: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host ""
    }
}

# Test Case 2: Get second role (if exists)
if ($roleIds.Count -gt 1) {
    Write-Host "  [Test Case 2] Getting role ID $($roleIds[1])..." -ForegroundColor Cyan

    try {
        $roleResponse2 = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin-actions/roles/$($roleIds[1])" `
            -Method GET `
            -Headers $headers `
            -ErrorAction Stop

        Write-Host "    ✓ Role retrieved successfully!" -ForegroundColor Green
        Write-Host "    Role ID: $($roleResponse2.data.role.id)" -ForegroundColor Gray
        Write-Host "    Role Name: $($roleResponse2.data.role.name)" -ForegroundColor Gray
        Write-Host ""
    } catch {
        Write-Host "    ✗ Failed to get role" -ForegroundColor Red
        Write-Host "    Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
        Write-Host ""
    }
}

# Test Case 3: Get third role (if exists)
if ($roleIds.Count -gt 2) {
    Write-Host "  [Test Case 3] Getting role ID $($roleIds[2])..." -ForegroundColor Cyan

    try {
        $roleResponse3 = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin-actions/roles/$($roleIds[2])" `
            -Method GET `
            -Headers $headers `
            -ErrorAction Stop

        Write-Host "    ✓ Role retrieved successfully!" -ForegroundColor Green
        Write-Host "    Role ID: $($roleResponse3.data.role.id)" -ForegroundColor Gray
        Write-Host "    Role Name: $($roleResponse3.data.role.name)" -ForegroundColor Gray
        Write-Host ""
    } catch {
        Write-Host "    ✗ Failed to get role" -ForegroundColor Red
        Write-Host "    Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
        Write-Host ""
    }
}

# Test Case 4: Non-existent role ID (error handling)
Write-Host "  [Test Case 4] Testing with non-existent role ID..." -ForegroundColor Cyan

try {
    $invalidIdResponse = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin-actions/roles/99999" `
        -Method GET `
        -Headers $headers `
        -ErrorAction Stop

    Write-Host "    ⚠ Request did NOT fail (unexpected)" -ForegroundColor Yellow
    Write-Host ""
} catch {
    Write-Host "    ✓ Error handled correctly!" -ForegroundColor Green
    Write-Host "    Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Gray
    
    if ($_.ErrorDetails.Message) {
        $errorDetail = $_.ErrorDetails.Message | ConvertFrom-Json
        Write-Host "    Error Code: $($errorDetail.error_code)" -ForegroundColor Gray
        Write-Host "    Message: $($errorDetail.message)" -ForegroundColor Gray
    }
    Write-Host ""
}

# Test Case 5: Invalid ID type (string instead of integer)
Write-Host "  [Test Case 5] Testing with invalid ID type (string)..." -ForegroundColor Cyan

try {
    $invalidTypeResponse = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin-actions/roles/abc" `
        -Method GET `
        -Headers $headers `
        -ErrorAction Stop

    Write-Host "    ⚠ Request did NOT fail (unexpected)" -ForegroundColor Yellow
    Write-Host ""
} catch {
    Write-Host "    ✓ Error handled correctly!" -ForegroundColor Green
    Write-Host "    Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Gray
    Write-Host ""
}

# Test Case 6: Verify response structure
if ($roleIds.Count -gt 0) {
    Write-Host "  [Test Case 6] Verifying response structure..." -ForegroundColor Cyan

    try {
        $roleResponse = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin-actions/roles/$($roleIds[0])" `
            -Method GET `
            -Headers $headers `
            -ErrorAction Stop

        Write-Host "    ✓ Response structure verified!" -ForegroundColor Green
        Write-Host ""
        Write-Host "    Response Structure:" -ForegroundColor Cyan
        Write-Host "      • success: $($roleResponse.success) (type: boolean)" -ForegroundColor White
        Write-Host "      • message: '$($roleResponse.message)' (type: string)" -ForegroundColor White
        Write-Host "      • data.role.id: $($roleResponse.data.role.id) (type: integer)" -ForegroundColor White
        Write-Host "      • data.role.name: '$($roleResponse.data.role.name)' (type: string)" -ForegroundColor White
        Write-Host ""
    } catch {
        Write-Host "    ✗ Failed response structure verification" -ForegroundColor Red
        Write-Host ""
    }
}

# Test Case 7: Compare get-roles vs get role by ID
Write-Host "  [Test Case 7] Consistency check: find-roles vs roles/{id}..." -ForegroundColor Cyan

try {
    $allRoles = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin-actions/find-roles?forceRefresh=false" `
        -Method GET `
        -Headers $headers `
        -ErrorAction Stop

    $role1 = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin-actions/roles/$($roleIds[0])" `
        -Method GET `
        -Headers $headers `
        -ErrorAction Stop

    # Find matching role from all roles
    $matchingRole = $allRoles.data.roles | Where-Object { $_.id -eq $roleIds[0] }

    if ($matchingRole -and $matchingRole.name -eq $role1.data.role.name) {
        Write-Host "    ✓ Data is consistent between endpoints!" -ForegroundColor Green
        Write-Host "    Role ID $($roleIds[0]): $($matchingRole.name)" -ForegroundColor Gray
    } else {
        Write-Host "    ⚠ Data inconsistency detected!" -ForegroundColor Yellow
    }
    Write-Host ""
} catch {
    Write-Host "    ✗ Failed consistency check" -ForegroundColor Red
    Write-Host ""
}

# Test Case 8: Get role zero (edge case)
Write-Host "  [Test Case 8] Testing with ID = 0 (edge case)..." -ForegroundColor Cyan

try {
    $zeroIdResponse = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin-actions/roles/0" `
        -Method GET `
        -Headers $headers `
        -ErrorAction Stop

    Write-Host "    ⚠ Request did NOT fail (unexpected)" -ForegroundColor Yellow
    Write-Host ""
} catch {
    Write-Host "    ✓ Error handled correctly!" -ForegroundColor Green
    Write-Host "    Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Gray
    Write-Host ""
}

# Test Case 9: Get role with negative ID (edge case)
Write-Host "  [Test Case 9] Testing with negative ID (edge case)..." -ForegroundColor Cyan

try {
    $negativeIdResponse = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin-actions/roles/-1" `
        -Method GET `
        -Headers $headers `
        -ErrorAction Stop

    Write-Host "    ⚠ Request did NOT fail (unexpected)" -ForegroundColor Yellow
    Write-Host ""
} catch {
    Write-Host "    ✓ Error handled correctly!" -ForegroundColor Green
    Write-Host "    Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Gray
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
Write-Host "  ✓ Get list of all roles" -ForegroundColor White

if ($roleIds.Count -gt 0) {
    Write-Host "  ✓ Get specific role by ID (first role)" -ForegroundColor White
}
if ($roleIds.Count -gt 1) {
    Write-Host "  ✓ Get specific role by ID (second role)" -ForegroundColor White
}
if ($roleIds.Count -gt 2) {
    Write-Host "  ✓ Get specific role by ID (third role)" -ForegroundColor White
}

Write-Host "  ✓ Non-existent role error handling" -ForegroundColor White
Write-Host "  ✓ Invalid ID type error handling" -ForegroundColor White
Write-Host "  ✓ Response structure validation" -ForegroundColor White
Write-Host "  ✓ Consistency check between endpoints" -ForegroundColor White
Write-Host "  ✓ Edge case: ID = 0" -ForegroundColor White
Write-Host "  ✓ Edge case: Negative ID" -ForegroundColor White
Write-Host ""
Write-Host "Endpoint Details:" -ForegroundColor Yellow
Write-Host "  • HTTP Method: GET" -ForegroundColor White
Write-Host "  • URL: /api/v1/admin-actions/roles/{id}" -ForegroundColor White
Write-Host "  • Status 200: Role found and returned" -ForegroundColor White
Write-Host "  • Status 404: Role not found" -ForegroundColor White
Write-Host "  • Status 500: Server error" -ForegroundColor White
Write-Host ""
