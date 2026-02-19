# Test Script for POST /api/v1/admin-actions/find-permissions
# Mostrar permisos existentes en el sistema

param(
    [string]$BaseUrl = "https://nginx-production-728f.up.railway.app",
    [string]$AdminEmail = "admin@admin.com",
    [string]$AdminPassword = "adminadmin"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TEST: Find Permissions Endpoint" -ForegroundColor Cyan
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
# STEP 2: Test Find All Permissions (No Filters)
# --------------------------------------------
Write-Host "[STEP 2] Testing find-permissions without filters..." -ForegroundColor Yellow
Write-Host ""

$allPermissionsPayload = @{} | ConvertTo-Json

try {
    $allPermissionsResponse = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin-actions/find-permissions" `
        -Method POST `
        -Headers $headers `
        -Body $allPermissionsPayload `
        -ErrorAction Stop

    Write-Host "  ✓ All permissions retrieved successfully!" -ForegroundColor Green
    Write-Host "    Success: $($allPermissionsResponse.success)" -ForegroundColor Gray
    Write-Host "    Message: $($allPermissionsResponse.message)" -ForegroundColor Gray
    Write-Host "    Total Permissions: $($allPermissionsResponse.data.permissions.total)" -ForegroundColor Gray
    Write-Host ""
    
    if ($allPermissionsResponse.data.permissions.permissions.Count -gt 0) {
        Write-Host "    Sample Permissions:" -ForegroundColor Cyan
        $allPermissionsResponse.data.permissions.permissions | Select-Object -First 10 | ForEach-Object {
            Write-Host "      • $($_.name) (Type: $($_.type))" -ForegroundColor White
        }
    }
    Write-Host ""
} catch {
    Write-Host "  ✗ Failed to get all permissions" -ForegroundColor Red
    Write-Host "    Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
    Write-Host "    Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
}

# --------------------------------------------
# STEP 3: Test Find Permissions by Role
# --------------------------------------------
Write-Host "[STEP 3] Testing find-permissions filtered by role..." -ForegroundColor Yellow
Write-Host ""

# Test with 'student' role
Write-Host "  [Test Case 1] Getting permissions for 'student' role..." -ForegroundColor Cyan

$rolePayload = @{
    role = "student"
} | ConvertTo-Json

try {
    $roleResponse = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin-actions/find-permissions" `
        -Method POST `
        -Headers $headers `
        -Body $rolePayload `
        -ErrorAction Stop

    Write-Host "    ✓ Student role permissions retrieved!" -ForegroundColor Green
    Write-Host "    Success: $($roleResponse.success)" -ForegroundColor Gray
    Write-Host "    Message: $($roleResponse.message)" -ForegroundColor Gray
    Write-Host "    Role: $($roleResponse.data.permissions.role)" -ForegroundColor Gray
    Write-Host "    Users with this role: $($roleResponse.data.permissions.users.Count)" -ForegroundColor Gray
    Write-Host "    Permissions: $($roleResponse.data.permissions.permissions.Count)" -ForegroundColor Gray
    Write-Host ""
    
    if ($roleResponse.data.permissions.permissions.Count -gt 0) {
        Write-Host "    Permissions:" -ForegroundColor Cyan
        $roleResponse.data.permissions.permissions | ForEach-Object {
            Write-Host "      • $($_.name) (Type: $($_.type), BelongsTo: $($_.belongsTo))" -ForegroundColor White
        }
    }
    
    if ($roleResponse.data.permissions.users.Count -gt 0) {
        Write-Host ""
        Write-Host "    Users with 'student' role:" -ForegroundColor Cyan
        $roleResponse.data.permissions.users | Select-Object -First 5 | ForEach-Object {
            Write-Host "      • $($_.fullName) ($($_.curp))" -ForegroundColor White
        }
    }
    Write-Host ""
} catch {
    Write-Host "    ✗ Failed to get student role permissions" -ForegroundColor Red
    Write-Host "    Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
    Write-Host "    Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
}

# Test with 'admin' role
Write-Host "  [Test Case 2] Getting permissions for 'admin' role..." -ForegroundColor Cyan

$adminRolePayload = @{
    role = "admin"
} | ConvertTo-Json

try {
    $adminRoleResponse = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin-actions/find-permissions" `
        -Method POST `
        -Headers $headers `
        -Body $adminRolePayload `
        -ErrorAction Stop

    Write-Host "    ✓ Admin role permissions retrieved!" -ForegroundColor Green
    Write-Host "    Role: $($adminRoleResponse.data.permissions.role)" -ForegroundColor Gray
    Write-Host "    Permissions: $($adminRoleResponse.data.permissions.permissions.Count)" -ForegroundColor Gray
    Write-Host ""
    
    if ($adminRoleResponse.data.permissions.permissions.Count -gt 0) {
        Write-Host "    Admin Permissions:" -ForegroundColor Cyan
        $adminRoleResponse.data.permissions.permissions | ForEach-Object {
            Write-Host "      • $($_.name)" -ForegroundColor White
        }
    }
    Write-Host ""
} catch {
    Write-Host "    ✗ Failed to get admin role permissions" -ForegroundColor Red
    Write-Host "    Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
    Write-Host "    Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
}

# Test with 'financial staff' role
Write-Host "  [Test Case 3] Getting permissions for 'financial staff' role..." -ForegroundColor Cyan

$staffRolePayload = @{
    role = "financial staff"
} | ConvertTo-Json

try {
    $staffRoleResponse = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin-actions/find-permissions" `
        -Method POST `
        -Headers $headers `
        -Body $staffRolePayload `
        -ErrorAction Stop

    Write-Host "    ✓ Financial staff role permissions retrieved!" -ForegroundColor Green
    Write-Host "    Role: $($staffRoleResponse.data.permissions.role)" -ForegroundColor Gray
    Write-Host "    Permissions: $($staffRoleResponse.data.permissions.permissions.Count)" -ForegroundColor Gray
    Write-Host ""
    
    if ($staffRoleResponse.data.permissions.permissions.Count -gt 0) {
        Write-Host "    Financial Staff Permissions:" -ForegroundColor Cyan
        $staffRoleResponse.data.permissions.permissions | Select-Object -First 8 | ForEach-Object {
            Write-Host "      • $($_.name)" -ForegroundColor White
        }
        if ($staffRoleResponse.data.permissions.permissions.Count -gt 8) {
            Write-Host "      ... and $($staffRoleResponse.data.permissions.permissions.Count - 8) more" -ForegroundColor Gray
        }
    }
    Write-Host ""
} catch {
    Write-Host "    ✗ Failed to get financial staff role permissions" -ForegroundColor Red
    Write-Host "    Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
    Write-Host "    Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
}

# --------------------------------------------
# STEP 4: Test Find Permissions by CURP(s)
# --------------------------------------------
Write-Host "[STEP 4] Testing find-permissions filtered by CURP(s)..." -ForegroundColor Yellow
Write-Host ""

Write-Host "  [Test Case 4] Getting permissions for specific users by CURP..." -ForegroundColor Cyan

$curpsPayload = @{
    curps = @(
        "LOPA800101HDFRNL09",
        "MARA900202MDFRTN05"
    )
} | ConvertTo-Json

try {
    $curpsResponse = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin-actions/find-permissions" `
        -Method POST `
        -Headers $headers `
        -Body $curpsPayload `
        -ErrorAction Stop

    Write-Host "    ✓ User permissions by CURP retrieved!" -ForegroundColor Green
    Write-Host "    Success: $($curpsResponse.success)" -ForegroundColor Gray
    Write-Host "    Message: $($curpsResponse.message)" -ForegroundColor Gray
    Write-Host "    Users found: $($curpsResponse.data.permissions.users.Count)" -ForegroundColor Gray
    Write-Host ""
    
    if ($curpsResponse.data.permissions.users.Count -gt 0) {
        Write-Host "    Users:" -ForegroundColor Cyan
        $curpsResponse.data.permissions.users | ForEach-Object {
            Write-Host "      • $($_.fullName)" -ForegroundColor White
            Write-Host "        CURP: $($_.curp)" -ForegroundColor Gray
            Write-Host "        Roles: $($_.roles -join ', ')" -ForegroundColor Gray
            if ($_.permissions.Count -gt 0) {
                Write-Host "        Permissions: $($_.permissions.Count)" -ForegroundColor Gray
            }
        }
    }
    Write-Host ""
} catch {
    Write-Host "    ✗ Failed to get permissions by CURP" -ForegroundColor Red
    Write-Host "    Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
    
    if ($_.ErrorDetails.Message) {
        $errorDetail = $_.ErrorDetails.Message | ConvertFrom-Json
        Write-Host "    Error Code: $($errorDetail.error_code)" -ForegroundColor Red
        Write-Host "    Message: $($errorDetail.message)" -ForegroundColor Red
    }
    Write-Host ""
}

# --------------------------------------------
# STEP 5: Test Find Permissions by Role + CURP
# --------------------------------------------
Write-Host "[STEP 5] Testing find-permissions with role AND CURP filters..." -ForegroundColor Yellow
Write-Host ""

Write-Host "  [Test Case 5] Getting permissions for users with 'admin' role..." -ForegroundColor Cyan

$roleAndCurpsPayload = @{
    role = "admin"
    curps = @(
        "LOPA800101HDFRNL09"
    )
} | ConvertTo-Json

try {
    $roleAndCurpsResponse = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin-actions/find-permissions" `
        -Method POST `
        -Headers $headers `
        -Body $roleAndCurpsPayload `
        -ErrorAction Stop

    Write-Host "    ✓ Role-filtered permissions retrieved!" -ForegroundColor Green
    Write-Host "    Role: $($roleAndCurpsResponse.data.permissions.role)" -ForegroundColor Gray
    Write-Host "    Users found: $($roleAndCurpsResponse.data.permissions.users.Count)" -ForegroundColor Gray
    Write-Host "    Permissions for role: $($roleAndCurpsResponse.data.permissions.permissions.Count)" -ForegroundColor Gray
    Write-Host ""
} catch {
    Write-Host "    ✗ Failed to get role-filtered permissions" -ForegroundColor Red
    Write-Host "    Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
    Write-Host ""
}

# Test Case 6: Invalid role (validation test)
Write-Host "  [Test Case 6] Testing validation with invalid role..." -ForegroundColor Cyan

$invalidRolePayload = @{
    role = "nonexistent-role"
} | ConvertTo-Json

try {
    $invalidRoleResponse = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin-actions/find-permissions" `
        -Method POST `
        -Headers $headers `
        -Body $invalidRolePayload `
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

# Test Case 7: Invalid CURP format (validation test)
Write-Host "  [Test Case 7] Testing validation with invalid CURP format..." -ForegroundColor Cyan

$invalidCurpPayload = @{
    curps = @("INVALID123")
} | ConvertTo-Json

try {
    $invalidCurpResponse = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin-actions/find-permissions" `
        -Method POST `
        -Headers $headers `
        -Body $invalidCurpPayload `
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
Write-Host "  ✓ Get all permissions (no filters)" -ForegroundColor White
Write-Host "  ✓ Get permissions by role ('student')" -ForegroundColor White
Write-Host "  ✓ Get permissions by role ('admin')" -ForegroundColor White
Write-Host "  ✓ Get permissions by role ('financial staff')" -ForegroundColor White
Write-Host "  ✓ Get permissions by CURP(s)" -ForegroundColor White
Write-Host "  ✓ Get permissions by role AND CURP filters" -ForegroundColor White
Write-Host "  ✓ Invalid role validation" -ForegroundColor White
Write-Host "  ✓ Invalid CURP format validation" -ForegroundColor White
Write-Host ""
Write-Host "Filter Options:" -ForegroundColor Yellow
Write-Host "  • No filters: Returns all system permissions" -ForegroundColor White
Write-Host "  • role only: Returns permissions for that role and users with role" -ForegroundColor White
Write-Host "  • curps only: Returns permissions for specific users" -ForegroundColor White
Write-Host "  • role + curps: Returns role permissions filtered to specific users with role" -ForegroundColor White
Write-Host ""
Write-Host "⚠ IMPORTANT: Replace test CURPs with real ones from your database" -ForegroundColor Yellow
Write-Host ""
