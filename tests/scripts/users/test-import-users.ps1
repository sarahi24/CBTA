# Test script for import-users endpoint
# Usage: .\test-import-users.ps1

param(
    [string]$FilePath = "C:\temp\usuarios.xlsx",
    [string]$ApiBaseUrl = "https://nginx-production-728f.up.railway.app/api",
    [string]$Token = ""
)

if ([string]::IsNullOrEmpty($Token)) {
    Write-Host "❌ Token requerido. Usa: .\test-import-users.ps1 -Token 'your_token_here'"
    exit 1
}

if (-not (Test-Path $FilePath)) {
    Write-Host "❌ Archivo no encontrado: $FilePath"
    exit 1
}

Write-Host "📥 Iniciando importación de usuarios..."
Write-Host "🔗 URL: $ApiBaseUrl/v1/admin-actions/import-users"
Write-Host "📄 Archivo: $FilePath"

try {
    $file = Get-Item -Path $FilePath
    
    $headers = @{
        "Authorization" = "Bearer $Token"
        "X-User-Role" = "admin"
        "X-User-Permission" = "import.users"
    }

    $form = @{
        file = $file
    }

    $response = Invoke-WebRequest -Uri "$ApiBaseUrl/v1/admin-actions/import-users" `
        -Method POST `
        -Headers $headers `
        -Form $form `
        -ContentType "multipart/form-data"

    $result = $response.Content | ConvertFrom-Json

    if ($result.success) {
        Write-Host "✓ Importación exitosa!" -ForegroundColor Green
        Write-Host ""
        
        $summary = $result.data.summary
        
        Write-Host "📊 Resumen de Importación:" -ForegroundColor Cyan
        Write-Host "  ├─ Total recibidas: $($summary.total_rows_received)"
        Write-Host "  ├─ Procesadas: $($summary.rows_processed)"
        Write-Host "  ├─ Insertadas: $($summary.rows_inserted)"
        Write-Host "  ├─ Fallidas: $($summary.rows_failed)"
        Write-Host "  └─ Tasa de éxito: $($summary.success_rate.ToString('F2'))%"
        
        if ($result.data.errors.total_errors -gt 0) {
            Write-Host ""
            Write-Host "⚠️  Errores Encontrados ($($result.data.errors.total_errors)):" -ForegroundColor Yellow
            
            if ($result.data.errors.row_errors) {
                foreach ($error in $result.data.errors.row_errors | Select-Object -First 5) {
                    Write-Host "  • Fila $($error.row_number): $($error.message)"
                }
                if ($result.data.errors.row_errors.Count -gt 5) {
                    Write-Host "  ... y $($result.data.errors.row_errors.Count - 5) errores más"
                }
            }
        }
        
        if ($result.data.warnings.total_warnings -gt 0) {
            Write-Host ""
            Write-Host "⚠️  Advertencias ($($result.data.warnings.total_warnings)):" -ForegroundColor DarkYellow
            
            if ($result.data.warnings.list) {
                foreach ($warning in $result.data.warnings.list | Select-Object -First 3) {
                    Write-Host "  • $($warning.message)"
                }
            }
        }
        
    } else {
        Write-Host "❌ Error en la importación:" -ForegroundColor Red
        Write-Host "  Mensaje: $($result.message)"
        
        if ($result.errors) {
            Write-Host "  Errores:"
            $result.errors.PSObject.Properties | ForEach-Object {
                Write-Host "    • $($_.Name): $($_.Value -join ', ')"
            }
        }
        exit 1
    }

} catch {
    Write-Host "❌ Error al ejecutar la solicitud:" -ForegroundColor Red
    Write-Host "  $($_.Exception.Message)"
    
    if ($_.Exception.Response) {
        $errorContent = $_.Exception.Response.Content.ReadAsStream()
        $reader = [System.IO.StreamReader]::new($errorContent)
        $errorBody = $reader.ReadToEnd()
        Write-Host "  Response: $errorBody"
    }
    exit 1
}
