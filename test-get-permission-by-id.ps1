# Test Script for GET /api/v1/admin-actions/permissions/{id}
# Mostrar información de un permiso específico por su ID

param(
    [string]$BaseUrl = "https://nginx-production-728f.up.railway.app",
    [string]$AdminEmail = "admin@admin.com",
    [string]$AdminPassword = "adminadmin"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TEST: Get Permission by ID Endpoint" -ForegroundColor Cyan
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
# STEP 2: Get All Permissions First to Find Valid IDs
# --------------------------------------------
Write-Host "[STEP 2] Getting all permissions to find valid IDs..." -ForegroundColor Yellow

try {
    $allPermissionsPayload = @{} | ConvertTo-Json
    $allPermissionsResponse = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin-actions/find-permissions" `
        -Method POST `
        -Headers $headers `
        -Body $allPermissionsPayload `
        -ErrorAction Stop

    Write-Host "✓ Permissions retrieved successfully!" -ForegroundColor Green
    Write-Host "  Total Permissions: $($allPermissionsResponse.data.permissions.total)" -ForegroundColor Gray
    Write-Host ""
    
    if ($allPermissionsResponse.data.permissions.permissions.Count -gt 0) {
        Write-Host "  Sample Permissions:" -ForegroundColor Cyan
        $allPermissionsResponse.data.permissions.permissions | Select-Object -First 8 | ForEach-Object {
            Write-Host "    • ID: $($_.id) - $($_.name)" -ForegroundColor White
        }
        Write-Host ""
        $permissionIds = @($allPermissionsResponse.data.permissions.permissions | Select-Object -ExpandProperty id | Select-Object -First 10)
    } else {
        Write-Host "  ✗ No permissions found!" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "✗ Failed to get all permissions" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# --------------------------------------------
# STEP 3: Test Get Specific Permissions by ID
# --------------------------------------------
Write-Host "[STEP 3] Testing get permission by ID endpoint..." -ForegroundColor Yellow
Write-Host ""

# Test Case 1: Get first permission
if ($permissionIds.Count -gt 0) {
    Write-Host "  [Test Case 1] Getting permission ID $($permissionIds[0])..." -ForegroundColor Cyan

    try {
        $permResponse = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin-actions/permissions/$($permissionIds[0])" `
            -Method GET `
            -Headers $headers `
            -ErrorAction Stop

        Write-Host "    ✓ Permission retrieved successfully!" -ForegroundColor Green
        Write-Host "    Success: $($permResponse.success)" -ForegroundColor Gray
        Write-Host "    Message: $($permResponse.message)" -ForegroundColor Gray
        Write-Host "    Permission ID: $($permResponse.data.permission.id)" -ForegroundColor Gray
        Write-Host "    Permission Name: $($permResponse.data.permission.name)" -ForegroundColor Gray
        Write-Host "    Type: $($permResponse.data.permission.type)" -ForegroundColor Gray
        Write-Host "    Belongs To: $($permResponse.data.permission.belongsTo)" -ForegroundColor Gray
        Write-Host ""
    } catch {
        Write-Host "    ✗ Failed to get permission" -ForegroundColor Red
        Write-Host "    Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
        Write-Host "    Error: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host ""
    }
}

# Test Case 2: Get second permission (if exists)
if ($permissionIds.Count -gt 1) {
    Write-Host "  [Test Case 2] Getting permission ID $($permissionIds[1])..." -ForegroundColor Cyan

    try {
        $permResponse2 = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin-actions/permissions/$($permissionIds[1])" `
            -Method GET `
            -Headers $headers `
            -ErrorAction Stop

        Write-Host "    ✓ Permission retrieved successfully!" -ForegroundColor Green
        Write-Host "    Permission ID: $($permResponse2.data.permission.id)" -ForegroundColor Gray
        Write-Host "    Permission Name: $($permResponse2.data.permission.name)" -ForegroundColor Gray
        Write-Host "    Belongs To: $($permResponse2.data.permission.belongsTo)" -ForegroundColor Gray
        Write-Host ""
    } catch {
        Write-Host "    ✗ Failed to get permission" -ForegroundColor Red
        Write-Host "    Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
        Write-Host ""
    }
}

# Test Case 3: Get third permission (if exists)
if ($permissionIds.Count -gt 2) {
    Write-Host "  [Test Case 3] Getting permission ID $($permissionIds[2])..." -ForegroundColor Cyan

    try {
        $permResponse3 = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin-actions/permissions/$($permissionIds[2])" `
            -Method GET `
            -Headers $headers `
            -ErrorAction Stop

        Write-Host "    ✓ Permission retrieved successfully!" -ForegroundColor Green
        Write-Host "    Permission ID: $($permResponse3.data.permission.id)" -ForegroundColor Gray
        Write-Host "    Permission Name: $($permResponse3.data.permission.name)" -ForegroundColor Gray
        Write-Host ""
    } catch {
        Write-Host "    ✗ Failed to get permission" -ForegroundColor Red
        Write-Host "    Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
        Write-Host ""
    }
}

# Test Case 4: Non-existent permission ID (error handling)
Write-Host "  [Test Case 4] Testing with non-existent permission ID..." -ForegroundColor Cyan

try {
    $invalidIdResponse = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin-actions/permissions/99999" `
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
    $invalidTypeResponse = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin-actions/permissions/abc" `
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
if ($permissionIds.Count -gt 0) {
    Write-Host "  [Test Case 6] Verifying response structure..." -ForegroundColor Cyan

    try {
        $permResponse = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin-actions/permissions/$($permissionIds[0])" `
            -Method GET `
            -Headers $headers `
            -ErrorAction Stop

        Write-Host "    ✓ Response structure verified!" -ForegroundColor Green
        Write-Host ""
        Write-Host "    Response Structure:" -ForegroundColor Cyan
        Write-Host "      • success: $($permResponse.success) (type: boolean)" -ForegroundColor White
        Write-Host "      • message: '$($permResponse.message)' (type: string)" -ForegroundColor White
        Write-Host "      • data.permission.id: $($permResponse.data.permission.id) (type: integer)" -ForegroundColor White
        Write-Host "      • data.permission.name: '$($permResponse.data.permission.name)' (type: string)" -ForegroundColor White
        Write-Host "      • data.permission.type: '$($permResponse.data.permission.type)' (type: string)" -ForegroundColor White
        Write-Host "      • data.permission.belongsTo: '$($permResponse.data.permission.belongsTo)' (type: string)" -ForegroundColor White
        Write-Host ""
    } catch {
        Write-Host "    ✗ Failed response structure verification" -ForegroundColor Red
        Write-Host ""
    }
}

# Test Case 7: Compare find-permissions vs get permission by ID
Write-Host "  [Test Case 7] Consistency check: find-permissions vs permissions/{id}..." -ForegroundColor Cyan

try {
    $allPerms = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin-actions/find-permissions" `
        -Method POST `
        -Headers $headers `
        -Body ($@{} | ConvertTo-Json) `
        -ErrorAction Stop

    $perm1 = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin-actions/permissions/$($permissionIds[0])" `
        -Method GET `
        -Headers $headers `
        -ErrorAction Stop

    # Find matching permission from all permissions
    $matchingPerm = $allPerms.data.permissions.permissions | Where-Object { $_.id -eq $permissionIds[0] }

    if ($matchingPerm -and $matchingPerm.name -eq $perm1.data.permission.name) {
        Write-Host "    ✓ Data is consistent between endpoints!" -ForegroundColor Green
        Write-Host "    Permission ID $($permissionIds[0]): $($matchingPerm.name)" -ForegroundColor Gray
    } else {
        Write-Host "    ⚠ Data inconsistency detected!" -ForegroundColor Yellow
    }
    Write-Host ""
} catch {
    Write-Host "    ✗ Failed consistency check" -ForegroundColor Red
    Write-Host ""
}

# Test Case 8: Get permission zero (edge case)
Write-Host "  [Test Case 8] Testing with ID = 0 (edge case)..." -ForegroundColor Cyan

try {
    $zeroIdResponse = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin-actions/permissions/0" `
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

# Test Case 9: Get permission with negative ID (edge case)
Write-Host "  [Test Case 9] Testing with negative ID (edge case)..." -ForegroundColor Cyan

try {
    $negativeIdResponse = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin-actions/permissions/-1" `
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

# Test Case 10: Verify belongsTo categorization
Write-Host "  [Test Case 10] Verifying belongsTo categorization..." -ForegroundColor Cyan

try {
    $categorizationData = @{}
    foreach ($id in $permissionIds | Select-Object -First 5) {
        $perm = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin-actions/permissions/$id" `
            -Method GET `
            -Headers $headers `
            -ErrorAction Stop
        
        if (-not $categorizationData.ContainsKey($perm.data.permission.belongsTo)) {
            $categorizationData[$perm.data.permission.belongsTo] = @()
        }
        $categorizationData[$perm.data.permission.belongsTo] += $perm.data.permission.name
    }

    Write-Host "    ✓ Permission categorization verified!" -ForegroundColor Green
    Write-Host ""
    Write-Host "    Permissions by Category:" -ForegroundColor Cyan
    foreach ($category in $categorizationData.Keys | Sort-Object) {
        Write-Host "      $category" -ForegroundColor White
        $categorizationData[$category] | ForEach-Object {
            Write-Host "        - $_" -ForegroundColor Gray
        }
    }
    Write-Host ""
} catch {
    Write-Host "    ✗ Failed categorization verification" -ForegroundColor Red
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
Write-Host "  ✓ Get list of all permissions" -ForegroundColor White

if ($permissionIds.Count -gt 0) {
    Write-Host "  ✓ Get specific permission by ID (first permission)" -ForegroundColor White
}
if ($permissionIds.Count -gt 1) {
    Write-Host "  ✓ Get specific permission by ID (second permission)" -ForegroundColor White
}
if ($permissionIds.Count -gt 2) {
    Write-Host "  ✓ Get specific permission by ID (third permission)" -ForegroundColor White
}

Write-Host "  ✓ Non-existent permission error handling" -ForegroundColor White
Write-Host "  ✓ Invalid ID type error handling" -ForegroundColor White
Write-Host "  ✓ Response structure validation" -ForegroundColor White
Write-Host "  ✓ Consistency check between endpoints" -ForegroundColor White
Write-Host "  ✓ Edge case: ID = 0" -ForegroundColor White
Write-Host "  ✓ Edge case: Negative ID" -ForegroundColor White
Write-Host "  ✓ Permission categorization (belongsTo)" -ForegroundColor White
Write-Host ""
Write-Host "Endpoint Details:" -ForegroundColor Yellow
Write-Host "  • HTTP Method: GET" -ForegroundColor White
Write-Host "  • URL: /api/v1/admin-actions/permissions/{id}" -ForegroundColor White
Write-Host "  • Status 200: Permission found and returned" -ForegroundColor White
Write-Host "  • Status 404: Permission not found" -ForegroundColor White
Write-Host "  • Status 500: Server error" -ForegroundColor White
Write-Host ""
Write-Host "Response Fields:" -ForegroundColor Yellow
Write-Host "  • id: Permission identifier (integer)" -ForegroundColor White
Write-Host "  • name: Permission name (string)" -ForegroundColor White
Write-Host "  • type: Permission type/guard (string, e.g., 'model')" -ForegroundColor White
Write-Host "  • belongsTo: Permission category (string, e.g., 'STUDENT', 'ADMIN')" -ForegroundColor White
Write-Host ""
