# Guía de Importación de Usuarios

## Descripción General

El endpoint de importación de usuarios permite cargar múltiples usuarios desde un archivo Excel (.xlsx). Este es un proceso por lotes que puede importar hasta 1000+ usuarios de una vez, con validación detallada de errores y un resumen de resultados.

## Endpoint API

**URL:** `POST /api/v1/admin-actions/import-users`

**Base URL:** `https://nginx-production-728f.up.railway.app/api`

## Requisitos

### Headers Requeridos

```
X-User-Role: admin | supervisor
X-User-Permission: import.users
Authorization: Bearer {access_token}
```

### Método HTTP

`POST` con `multipart/form-data`

### Parámetros

| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `file` | binary | Archivo Excel (.xlsx) con los datos de usuarios |

## Formato del Archivo Excel

El archivo Excel debe contener las siguientes columnas **en este orden exacto**:

| # | Columna | Formato | Ejemplo | Requerido |
|---|---------|---------|---------|-----------|
| 1 | `name` | Texto | Juan | ✓ |
| 2 | `last_name` | Texto | García López | ✓ |
| 3 | `email` | Email | juan.garcia@example.com | ✓ |
| 4 | `phone_number` | Teléfono (+52) | +5215551234567 | ✓ |
| 5 | `birthdate` | YYYY-MM-DD | 1995-03-15 | ✓ |
| 6 | `gender` | hombre / mujer | hombre | ✓ |
| 7 | `curp` | Texto (18 chars) | GARC950315HJLMNN00 | ✓ |
| 8 | `street` | Texto | Calle Principal 123 | ✓ |
| 9 | `city` | Texto | México | ✓ |
| 10 | `state` | Texto | CDMX | ✓ |
| 11 | `zip_code` | Código postal | 06500 | ✓ |
| 12 | `blood_type` | A+, A-, B+, B-, O+, O-, AB+, AB- | O+ | ✓ |
| 13 | `registration_date` | YYYY-MM-DD | 2024-01-15 | ○ (opcional) |
| 14 | `status` | activo / inactivo | activo | ○ (predeterminado: activo) |
| 15 | `career_id` | Número | 5 | ✓ |
| 16 | `n_control` | Texto/Número | 202400001 | ✓ |
| 17 | `semestre` | Número (1-8) | 3 | ✓ |
| 18 | `group` | Texto | A | ✓ |
| 19 | `workshop` | Texto | Programación | ✓ |

## Validaciones

### Validaciones por Campo

- **Nombre**: Máximo 255 caracteres
- **Apellidos**: Máximo 255 caracteres
- **Email**: Debe ser válido y único en la base de datos
- **Teléfono**: Debe empezar con +52, máximo 15 caracteres
- **CURP**: Exactamente 18 caracteres, válido según formato oficial
- **Fecha Nacimiento**: Formato YYYY-MM-DD, debe ser una fecha válida
- **Género**: Solo "hombre" o "mujer" (sensible a mayúsculas)
- **Tipo de Sangre**: Debe ser uno de: A+, A-, B+, B-, O+, O-, AB+, AB-
- **Career ID**: Debe existir en la base de datos
- **Semestre**: Número entre 1 y 8

### Manejo de Errores

El sistema valida cada fila y proporciona feedback detallado:

```json
{
  "type": "row_error",
  "message": "Email inválido",
  "row_number": 15,
  "context": {
    "email": "invalid-email",
    "curp": "GARC950315HJLMNN00"
  },
  "timestamp": "2026-01-30T00:23:49.448Z"
}
```

## Respuesta Exitosa (200 OK)

```json
{
  "success": true,
  "message": "Usuarios importados correctamente.",
  "data": {
    "summary": {
      "total_rows_received": 100,
      "rows_processed": 95,
      "rows_inserted": 90,
      "rows_failed": 5,
      "success_rate": 94.74
    },
    "errors": {
      "row_errors": [
        {
          "type": "row_error",
          "message": "CURP requerida",
          "row_number": 15,
          "context": {
            "curp": "N/A"
          },
          "timestamp": "2026-01-30T00:23:49.448Z"
        }
      ],
      "global_errors": [
        {
          "type": "global_error",
          "message": "Error en base de datos",
          "chunk_index": 2,
          "rows_count": 50,
          "timestamp": "2026-01-30T00:23:49.448Z"
        }
      ],
      "total_errors": 3
    },
    "warnings": {
      "list": [
        {
          "type": "warning",
          "message": "Chunk sin datos válidos",
          "chunk_index": 1,
          "rows_count": 20,
          "timestamp": "2026-01-30T00:23:49.448Z"
        }
      ],
      "total_warnings": 2
    },
    "timestamp": "2024-01-15 10:30:00",
    "has_errors": false,
    "has_warnings": true
  }
}
```

## Respuestas de Error

### 400 Bad Request
Error en la validación o formato del archivo

```json
{
  "success": false,
  "message": "Error descriptivo para el usuario",
  "error_code": "VALIDATION_ERROR",
  "errors": {
    "file": ["El archivo no es válido"]
  }
}
```

### 422 Unprocessable Entity
Error de validación de datos

```json
{
  "success": false,
  "message": "Hay errores en los datos del archivo",
  "error_code": "VALIDATION_ERROR",
  "errors": {
    "email": ["El email debe ser válido"],
    "curp": ["CURP requerida"]
  }
}
```

### 500 Internal Server Error
Error interno del servidor

```json
{
  "success": false,
  "message": "Error interno al procesar el archivo",
  "error_code": "INTERNAL_ERROR"
}
```

## Implementación Frontend

### Función de Importación

```javascript
async importUsersFromFile() {
    if (!this.importFile) {
        this.showNotify('Por favor selecciona un archivo', 'error');
        return;
    }

    const token = localStorage.getItem('access_token');
    if (!token) {
        this.showNotify('No hay token de autenticación', 'error');
        return;
    }

    this.isImporting = true;
    this.importError = null;
    this.importResult = null;

    try {
        const formData = new FormData();
        formData.append('file', this.importFile);

        const response = await fetch(
            `${this.apiBaseUrl}/v1/admin-actions/import-users`,
            {
                method: 'POST',
                headers: {
                    'Authorization': `Bearer ${token}`,
                    'X-User-Role': 'admin',
                    'X-User-Permission': 'import.users'
                },
                body: formData
            }
        );

        const result = await response.json();

        if (response.ok && result.success) {
            this.importResult = result.data?.summary || result.data;
            this.showNotify('✓ Usuarios importados correctamente', 'success');
            
            // Recargar usuarios
            setTimeout(() => {
                this.loadUsers();
            }, 1000);

            // Cerrar modal
            setTimeout(() => {
                this.closeImportModal();
            }, 3000);
        } else {
            this.importError = {
                message: result.message || 'Error en la importación',
                errors: result.errors || null,
                hasDetails: !!result.errors
            };
            this.showNotify(`Error: ${result.message}`, 'error');
        }
    } catch (error) {
        console.error('❌ Error al importar usuarios:', error);
        this.importError = {
            message: error.message,
            hasDetails: false
        };
        this.showNotify(`Error: ${error.message}`, 'error');
    } finally {
        this.isImporting = false;
    }
}
```

### Estados de la UI

```javascript
// Estados para importación de usuarios
showImportModal: false,           // Controla la visibilidad del modal
importFile: null,                 // Archivo seleccionado
isImporting: false,               // Estado de carga
importResult: null,               // Resultado exitoso
importError: null,                // Información de error
```

### Eventos de Archivo

```javascript
handleFileSelect(event) {
    const file = event.target.files[0];
    if (!file) return;

    const validTypes = [
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        'application/vnd.ms-excel'
    ];
    
    const fileName = file.name.toLowerCase();
    if (!fileName.endsWith('.xlsx') && !fileName.endsWith('.xls')) {
        this.showNotify('Solo se permiten archivos Excel (.xlsx o .xls)', 'error');
        return;
    }

    this.importFile = file;
    this.importError = null;
}
```

## Ejemplo de Uso (Terminal)

### Con cURL

```bash
curl -X POST "https://nginx-production-728f.up.railway.app/api/v1/admin-actions/import-users" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "X-User-Role: admin" \
  -H "X-User-Permission: import.users" \
  -F "file=@usuarios.xlsx"
```

### Con PowerShell

```powershell
$token = "YOUR_ACCESS_TOKEN"
$filePath = "C:\Path\To\usuarios.xlsx"

$headers = @{
    "Authorization" = "Bearer $token"
    "X-User-Role" = "admin"
    "X-User-Permission" = "import.users"
}

$form = @{
    file = Get-Item -Path $filePath
}

Invoke-WebRequest -Uri "https://nginx-production-728f.up.railway.app/api/v1/admin-actions/import-users" `
    -Method POST `
    -Headers $headers `
    -Form $form
```

## Mejores Prácticas

### 1. Preparar el Archivo Excel

- Valida manualmente los datos antes de importar
- Asegúrate de que CURPs sean válidos (18 caracteres)
- Formatea fechas como YYYY-MM-DD
- Verifica que IDs de carrera existan en el sistema

### 2. Manejo de Errores

- Revisa el resumen de importación
- Corrige las filas con errores
- Reintenta solo con los datos válidos
- Guarda un registro de errores para auditoría

### 3. Tamaño de Archivo

- Máximo recomendado: 1000-5000 usuarios por archivo
- Si tienes más usuarios, divide en múltiples archivos
- Archivos grandes pueden tardar más en procesar

### 4. Post-Importación

- Verifica que los usuarios se crearon correctamente
- Envía credenciales temporales a los usuarios
- Notifica cambios de contraseña requerida
- Realiza auditoría de datos importados

## Requisitos de Permisos

### Roles Permitidos
- **admin**: Acceso completo
- **supervisor**: Acceso restringido (según configuración)

### Permisos Requeridos
- `import.users`: Permiso específico para importar usuarios

## Notas Importantes

1. **CURP Validación**: El sistema valida el formato CURP (18 caracteres)
2. **Email Único**: No se permiten emails duplicados
3. **Career ID**: Debe existir una carrera con este ID
4. **Transaccionalidad**: Errores graves pueden rollback de la transacción
5. **Fecha de Importación**: Se registra automáticamente en `timestamp`
6. **Auditoría**: Todas las importaciones se registran en logs de auditoría

## Solución de Problemas

### Problema: "El archivo no es válido"
- Verifica que sea un archivo .xlsx válido
- Intenta guardarlo en un formato diferente de Excel
- Comprueba que el archivo no esté corrupto

### Problema: "CURP requerida"
- Asegúrate de que la columna CURP (columna 7) no esté vacía
- Valida que sean exactamente 18 caracteres
- Verifica el formato del CURP

### Problema: "Email inválido"
- Comprueba el formato de email (debe contener @)
- Verifica que no haya espacios en blanco
- Asegúrate de que el email sea único

### Problema: "Career ID no existe"
- Verifica los IDs de carrera disponibles
- Contacta al administrador para validar IDs
- Usa un script de prueba para verificar carreras

## API de Carreras Disponibles

Para obtener una lista de carreras disponibles:

```
GET /api/v1/admin-actions/find-careers
Headers:
  X-User-Role: admin
  X-User-Permission: view.careers
```

## Historial de Cambios

### v1.0.0 (2026-01-29)
- Implementación inicial del endpoint
- Soporte para hasta 1000 usuarios por importación
- Validación detallada de errores
- Interfaz frontend completa
- Documentación completa

