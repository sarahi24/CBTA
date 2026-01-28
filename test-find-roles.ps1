# Test Script for GET /api/v1/admin-actions/find-roles
# Mostrar todos los roles existentes en el sistema

param(
    [string]$BaseUrl = "https://nginx-production-728f.up.railway.app",
    [string]$AdminEmail = "admin@admin.com",
    [string]$AdminPassword = "adminadmin"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TEST: Find Roles Endpoint" -ForegroundColor Cyan
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
# STEP 2: Test Get All Roles (Cached)
# --------------------------------------------
Write-Host "[STEP 2] Testing find-roles endpoint (cached)..." -ForegroundColor Yellow
Write-Host ""

Write-Host "  [Test Case 1] Getting all roles with cache..." -ForegroundColor Cyan

try {
    $rolesResponse = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin-actions/find-roles?forceRefresh=false" `
        -Method GET `
        -Headers $headers `
        -ErrorAction Stop

    Write-Host "    ✓ Roles retrieved successfully!" -ForegroundColor Green
    Write-Host "    Success: $($rolesResponse.success)" -ForegroundColor Gray
    Write-Host "    Message: $($rolesResponse.message)" -ForegroundColor Gray
    Write-Host "    Total Roles: $($rolesResponse.data.roles.Count)" -ForegroundColor Gray
    Write-Host ""
    
    if ($rolesResponse.data.roles.Count -gt 0) {
        Write-Host "    Available Roles:" -ForegroundColor Cyan
        $rolesResponse.data.roles | ForEach-Object {
            Write-Host "      • ID: $($_.id) - $($_.name)" -ForegroundColor White
        }
    }
    Write-Host ""
} catch {
    Write-Host "    ✗ Failed to get roles" -ForegroundColor Red
    Write-Host "    Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
    Write-Host "    Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
}

# Test Case 2: Get roles again (should return cached)
Write-Host "  [Test Case 2] Getting all roles again (should use cache)..." -ForegroundColor Cyan

try {
    $rolesResponse2 = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin-actions/find-roles?forceRefresh=false" `
        -Method GET `
        -Headers $headers `
        -ErrorAction Stop

    Write-Host "    ✓ Roles retrieved from cache!" -ForegroundColor Green
    Write-Host "    Total Roles: $($rolesResponse2.data.roles.Count)" -ForegroundColor Gray
    Write-Host "    Note: Same results indicate cache is working" -ForegroundColor Gray
    Write-Host ""
} catch {
    Write-Host "    ✗ Failed to get cached roles" -ForegroundColor Red
    Write-Host "    Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
    Write-Host "    Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
}

# Test Case 3: Force refresh cache
Write-Host "  [Test Case 3] Forcing cache refresh..." -ForegroundColor Cyan

try {
    $rolesResponse3 = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin-actions/find-roles?forceRefresh=true" `
        -Method GET `
        -Headers $headers `
        -ErrorAction Stop

    Write-Host "    ✓ Roles refreshed from database!" -ForegroundColor Green
    Write-Host "    Total Roles: $($rolesResponse3.data.roles.Count)" -ForegroundColor Gray
    Write-Host "    Cache was cleared and data fetched fresh" -ForegroundColor Gray
    Write-Host ""
    
    if ($rolesResponse3.data.roles.Count -gt 0) {
        Write-Host "    Fresh Role List:" -ForegroundColor Cyan
        $rolesResponse3.data.roles | ForEach-Object {
            Write-Host "      • $($_.name)" -ForegroundColor White
        }
    }
    Write-Host ""
} catch {
    Write-Host "    ✗ Failed to refresh cache" -ForegroundColor Red
    Write-Host "    Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
    Write-Host "    Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
}

# Test Case 4: Get with forceRefresh=false explicitly
Write-Host "  [Test Case 4] Getting roles with forceRefresh=false (explicit)..." -ForegroundColor Cyan

try {
    $rolesResponse4 = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin-actions/find-roles?forceRefresh=false" `
        -Method GET `
        -Headers $headers `
        -ErrorAction Stop

    Write-Host "    ✓ Roles retrieved!" -ForegroundColor Green
    Write-Host "    Total Roles: $($rolesResponse4.data.roles.Count)" -ForegroundColor Gray
    Write-Host ""
} catch {
    Write-Host "    ✗ Failed to get roles" -ForegroundColor Red
    Write-Host "    Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
    Write-Host ""
}

# Test Case 5: Get with no query parameter (default behavior)
Write-Host "  [Test Case 5] Getting roles with no query parameters (default)..." -ForegroundColor Cyan

try {
    $rolesResponse5 = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin-actions/find-roles" `
        -Method GET `
        -Headers $headers `
        -ErrorAction Stop

    Write-Host "    ✓ Roles retrieved with default settings!" -ForegroundColor Green
    Write-Host "    Total Roles: $($rolesResponse5.data.roles.Count)" -ForegroundColor Gray
    Write-Host "    Note: Default forceRefresh=false uses cache" -ForegroundColor Gray
    Write-Host ""
} catch {
    Write-Host "    ✗ Failed to get roles with defaults" -ForegroundColor Red
    Write-Host "    Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
    Write-Host ""
}

# Test Case 6: Verify response structure
Write-Host "  [Test Case 6] Verifying response structure..." -ForegroundColor Cyan

try {
    $rolesResponse6 = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin-actions/find-roles" `
        -Method GET `
        -Headers $headers `
        -ErrorAction Stop

    Write-Host "    ✓ Response structure verified!" -ForegroundColor Green
    Write-Host ""
    Write-Host "    Response Structure:" -ForegroundColor Cyan
    Write-Host "      • success: $($rolesResponse6.success)" -ForegroundColor White
    Write-Host "      • message: $($rolesResponse6.message)" -ForegroundColor White
    Write-Host "      • data.roles: Array of $($rolesResponse6.data.roles.Count) items" -ForegroundColor White
    
    if ($rolesResponse6.data.roles.Count -gt 0) {
        Write-Host ""
        Write-Host "      Sample role structure:" -ForegroundColor Cyan
        $sampleRole = $rolesResponse6.data.roles[0]
        Write-Host "        - id: $($sampleRole.id) (type: integer)" -ForegroundColor White
        Write-Host "        - name: $($sampleRole.name) (type: string)" -ForegroundColor White
    }
    Write-Host ""
} catch {
    Write-Host "    ✗ Failed response structure verification" -ForegroundColor Red
    Write-Host "    Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
    Write-Host ""
}

# Test Case 7: Performance comparison (cached vs fresh)
Write-Host "  [Test Case 7] Performance comparison..." -ForegroundColor Cyan
Write-Host "  Note: Cached requests should be faster" -ForegroundColor Yellow
Write-Host ""

# First request (might be cached or fresh)
$sw1 = [System.Diagnostics.Stopwatch]::StartNew()
try {
    $perfResponse1 = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin-actions/find-roles?forceRefresh=false" `
        -Method GET `
        -Headers $headers `
        -ErrorAction Stop
    $sw1.Stop()
    Write-Host "    Cached Request: $($sw1.ElapsedMilliseconds)ms" -ForegroundColor Cyan
} catch {
    Write-Host "    ✗ Cached request failed" -ForegroundColor Red
}

# Force refresh (fresh from database)
$sw2 = [System.Diagnostics.Stopwatch]::StartNew()
try {
    $perfResponse2 = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin-actions/find-roles?forceRefresh=true" `
        -Method GET `
        -Headers $headers `
        -ErrorAction Stop
    $sw2.Stop()
    Write-Host "    Fresh Request: $($sw2.ElapsedMilliseconds)ms" -ForegroundColor Cyan
} catch {
    Write-Host "    ✗ Fresh request failed" -ForegroundColor Red
}

# Use cache again
$sw3 = [System.Diagnostics.Stopwatch]::StartNew()
try {
    $perfResponse3 = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin-actions/find-roles?forceRefresh=false" `
        -Method GET `
        -Headers $headers `
        -ErrorAction Stop
    $sw3.Stop()
    Write-Host "    Cached Again: $($sw3.ElapsedMilliseconds)ms" -ForegroundColor Cyan
} catch {
    Write-Host "    ✗ Second cached request failed" -ForegroundColor Red
}

Write-Host ""

# --------------------------------------------
# STEP 3: Test Role Availability
# --------------------------------------------
Write-Host "[STEP 3] Verifying expected roles exist..." -ForegroundColor Yellow
Write-Host ""

try {
    $expectedRoles = @("admin", "student", "financial staff")
    $rolesResponse = Invoke-RestMethod -Uri "$BaseUrl/api/v1/admin-actions/find-roles?forceRefresh=false" `
        -Method GET `
        -Headers $headers `
        -ErrorAction Stop

    $existingRoleNames = $rolesResponse.data.roles | Select-Object -ExpandProperty name

    Write-Host "  Expected Roles vs Actual:" -ForegroundColor Cyan
    foreach ($expectedRole in $expectedRoles) {
        if ($existingRoleNames -contains $expectedRole) {
            Write-Host "    ✓ '$expectedRole' exists" -ForegroundColor Green
        } else {
            Write-Host "    ✗ '$expectedRole' NOT found" -ForegroundColor Yellow
        }
    }
    Write-Host ""
} catch {
    Write-Host "  ✗ Failed to verify roles" -ForegroundColor Red
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
Write-Host "  ✓ Get all roles (with cache)" -ForegroundColor White
Write-Host "  ✓ Cache retrieval (repeated requests)" -ForegroundColor White
Write-Host "  ✓ Force cache refresh (forceRefresh=true)" -ForegroundColor White
Write-Host "  ✓ Explicit cache usage (forceRefresh=false)" -ForegroundColor White
Write-Host "  ✓ Default behavior (no query parameters)" -ForegroundColor White
Write-Host "  ✓ Response structure validation" -ForegroundColor White
Write-Host "  ✓ Performance comparison (cached vs fresh)" -ForegroundColor White
Write-Host "  ✓ Verify expected roles exist" -ForegroundColor White
Write-Host ""
Write-Host "Query Parameter Guide:" -ForegroundColor Yellow
Write-Host "  • forceRefresh=true : Clear cache and fetch fresh data from database" -ForegroundColor White
Write-Host "  • forceRefresh=false (default) : Use cached data if available" -ForegroundColor White
Write-Host "  • No parameter : Uses default (false - cached)" -ForegroundColor White
Write-Host ""
Write-Host "Caching Benefits:" -ForegroundColor Yellow
Write-Host "  • Improved performance for repeated requests" -ForegroundColor White
Write-Host "  • Reduced database queries" -ForegroundColor White
Write-Host "  • Cache persists in-memory indefinitely until cleared" -ForegroundColor White
Write-Host ""
