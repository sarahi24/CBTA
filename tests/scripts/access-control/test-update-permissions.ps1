# Script para probar el endpoint update-permissions
# Ejecutar: powershell -ExecutionPolicy Bypass -File test-update-permissions.ps1

param(
    [string]$Mode = "role",  # "curps" o "role"
    [array]$CurpsArray,      # Para modo curps
    [string]$Role = "student",  # Para modo role
    [array]$AddPermissions = @("view payments"),
    [array]$RemovePermissions = @()
)

$API_BASE = "https://nginx-production-728f.up.railway.app/api/v1"

Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   TEST ENDPOINT - ACTUALIZAR PERMISOS" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Paso 1: Login
Write-Host "📝 PASO 1: Autenticación..." -ForegroundColor Yellow
$loginBody = @{
    email = "admin@example.com"
    password = "password"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "$API_BASE/auth/login" -Method Post -Body $loginBody -ContentType "application/json"
    
    if ($loginResponse.success) {
        $token = $loginResponse.data.token
        Write-Host "   ✅ Login exitoso!" -ForegroundColor Green
        Write-Host "   👤 Usuario: $($loginResponse.data.user.name)" -ForegroundColor Gray
        Write-Host ""
    } else {
        Write-Host "   ❌ Login falló: $($loginResponse.message)" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "   ❌ Error al conectar con el servidor" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

# Paso 2: Preparar payload
Write-Host "📤 PASO 2: Preparando solicitud de actualización de permisos..." -ForegroundColor Yellow
Write-Host ""

$payload = @{
    permissionsToAdd = $AddPermissions
}

if ($Mode -eq "curps" -and $CurpsArray -and $CurpsArray.Count -gt 0) {
    $payload["curps"] = $CurpsArray
    Write-Host "   Modo: Actualizar por CURP(s)" -ForegroundColor White
    Write-Host "   CURPs: $($CurpsArray -join ', ')" -ForegroundColor Cyan
} elseif ($Mode -eq "role") {
    $payload["role"] = $Role
    Write-Host "   Modo: Actualizar por Rol" -ForegroundColor White
    Write-Host "   Rol: $Role" -ForegroundColor Cyan
} else {
    Write-Host "   ❌ Modo inválido. Use 'curps' o 'role'" -ForegroundColor Red
    exit 1
}

if ($RemovePermissions -and $RemovePermissions.Count -gt 0) {
    $payload["permissionsToRemove"] = $RemovePermissions
    Write-Host "   Permisos a eliminar: $($RemovePermissions -join ', ')" -ForegroundColor Yellow
}

Write-Host "   Permisos a agregar: $($AddPermissions -join ', ')" -ForegroundColor Green
Write-Host ""

$payloadJson = $payload | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$API_BASE/admin-actions/update-permissions" -Method Post -Headers $headers -Body $payloadJson
    
    if ($response.success) {
        Write-Host ""
        Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
        Write-Host "   ✅ ACTUALIZACIÓN EXITOSA" -ForegroundColor Green
        Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
        Write-Host ""
        Write-Host "   📊 Estadísticas:" -ForegroundColor White
        Write-Host "   • Usuarios encontrados: $($response.data.metadata.totalFound)" -ForegroundColor Cyan
        Write-Host "   • Usuarios actualizados: $($response.data.metadata.totalUpdated)" -ForegroundColor Cyan
        Write-Host "   • Usuarios fallidos: $($response.data.metadata.failed)" -ForegroundColor Cyan
        
        if ($response.data.metadata.failed -gt 0) {
            Write-Host "   • IDs fallidos: $($response.data.metadata.failedUsers -join ', ')" -ForegroundColor Red
        }
        
        Write-Host ""
        Write-Host "   🔐 Operaciones:" -ForegroundColor White
        
        if ($response.data.metadata.operations.permissions_added -and $response.data.metadata.operations.permissions_added.Count -gt 0) {
            Write-Host "   Permisos agregados:" -ForegroundColor Green
            foreach ($perm in $response.data.metadata.operations.permissions_added) {
                Write-Host "     • $perm" -ForegroundColor Green
            }
        }
        
        if ($response.data.metadata.operations.permissions_removed -and $response.data.metadata.operations.permissions_removed.Count -gt 0) {
            Write-Host "   Permisos eliminados:" -ForegroundColor Red
            foreach ($perm in $response.data.metadata.operations.permissions_removed) {
                Write-Host "     • $perm" -ForegroundColor Red
            }
        }
        
        Write-Host ""
        Write-Host "   👥 Usuarios actualizados:" -ForegroundColor White
        foreach ($user in $response.data.users_permissions) {
            Write-Host "   • $($user.fullName) ($($user.curp))" -ForegroundColor Cyan
            Write-Host "     Rol: $($user.role)" -ForegroundColor Gray
            Write-Host "     Permisos actuales: $($user.updatedPermissions -join ', ')" -ForegroundColor Gray
        }
        
        Write-Host ""
        Write-Host "   💬 Mensaje: $($response.message)" -ForegroundColor Gray
        Write-Host ""
    } else {
        Write-Host ""
        Write-Host "❌ ACTUALIZACIÓN FALLÓ" -ForegroundColor Red
        Write-Host ""
        Write-Host "   Error: $($response.message)" -ForegroundColor Red
        Write-Host "   Código: $($response.error_code)" -ForegroundColor Red
        
        if ($response.errors) {
            Write-Host ""
            Write-Host "   Detalles de validación:" -ForegroundColor Yellow
            foreach ($field in $response.errors.PSObject.Properties) {
                Write-Host "   • $($field.Name):" -ForegroundColor Yellow
                foreach ($error in $field.Value) {
                    Write-Host "     - $error" -ForegroundColor Yellow
                }
            }
        }
        Write-Host ""
    }
} catch {
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Red
    Write-Host "   ❌ ERROR AL ACTUALIZAR PERMISOS" -ForegroundColor Red
    Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Red
    Write-Host ""
    
    $statusCode = $_.Exception.Response.StatusCode.value__
    Write-Host "   HTTP Status: $statusCode" -ForegroundColor Red
    
    if ($_.Exception.Response) {
        try {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $reader.BaseStream.Position = 0
            $reader.DiscardBufferedData()
            $responseBody = $reader.ReadToEnd()
            $errorData = $responseBody | ConvertFrom-Json
            
            Write-Host "   Error: $($errorData.message)" -ForegroundColor Red
            Write-Host "   Código: $($errorData.error_code)" -ForegroundColor Red
            
            if ($errorData.errors) {
                Write-Host ""
                Write-Host "   Detalles:" -ForegroundColor Yellow
                foreach ($field in $errorData.errors.PSObject.Properties) {
                    Write-Host "   • $($field.Name):" -ForegroundColor Yellow
                    foreach ($error in $field.Value) {
                        Write-Host "     - $error" -ForegroundColor Yellow
                    }
                }
            }
        } catch {
            Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    Write-Host ""
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   EJEMPLOS DE USO" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Actualizar todos los estudiantes:" -ForegroundColor Yellow
Write-Host "  powershell -File test-update-permissions.ps1 -Mode role -Role student -AddPermissions @('view payments')" -ForegroundColor Gray
Write-Host ""
Write-Host "  Actualizar por CURPs específicos:" -ForegroundColor Yellow
Write-Host "  powershell -File test-update-permissions.ps1 -Mode curps -CurpsArray @('CURP1', 'CURP2') -AddPermissions @('create payment')" -ForegroundColor Gray
Write-Host ""
Write-Host "  Agregar y eliminar permisos:" -ForegroundColor Yellow
Write-Host "  powershell -File test-update-permissions.ps1 -Mode role -Role admin -AddPermissions @('view.reports') -RemovePermissions @('delete.users')" -ForegroundColor Gray
Write-Host ""
