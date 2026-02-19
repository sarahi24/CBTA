# Quick Reference - Importación de Usuarios

## 🚀 Inicio Rápido

### Para Usuarios Finales

1. Prepara archivo Excel con formato correcto
2. Abre página de Gestión de Usuarios
3. Haz clic en "📥 Importar" → "Usuarios Completos"
4. Selecciona archivo .xlsx
5. Haz clic en "Importar Usuarios"
6. Revisa resumen de resultados

### Para Desarrolladores

## 1️⃣ Implementación en Frontend

**Archivo**: `Frond-end/src/pages/roles.astro`

### Estados (Línea ~1135)
```javascript
showImportModal: false,    // Modal visible
importFile: null,          // Archivo seleccionado
isImporting: false,        // Durante importación
importResult: null,        // Resultado exitoso
importError: null,         // Información de error
```

### Métodos Principales

```javascript
openImportModal()                   // Abre modal
closeImportModal()                  // Cierra modal
handleFileSelect(event)             // Valida y almacena archivo
importUsersFromFile()               // Ejecuta importación
```

### Ejemplo de Uso

```javascript
// Abrir modal
this.openImportModal();

// El usuario selecciona archivo en <input type="file">
// Se llama handleFileSelect() automáticamente

// Usuario hace clic en botón "Importar"
// Se llama importUsersFromFile()
```

## 2️⃣ Endpoint API

### URL
```
POST /api/v1/admin-actions/import-users
```

### Headers
```javascript
{
  "Authorization": "Bearer TOKEN",
  "X-User-Role": "admin",
  "X-User-Permission": "import.users",
  "Content-Type": "multipart/form-data"
}
```

### Body
```
FormData {
  file: File // Archivo .xlsx
}
```

### Respuesta Exitosa
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
    "errors": {...},
    "warnings": {...}
  }
}
```

## 3️⃣ Formato de Archivo Excel

### Orden de Columnas (EXACTO)
```
A         B          C       D             E          F
name      last_name  email   phone_number  birthdate  gender

G    H      I    J     K         L           M                N
curp street city state  zip_code blood_type  registration_date status

O         P        Q        R       S
career_id n_control semestre group  workshop
```

### Validaciones por Campo

| Campo | Validación |
|-------|-----------|
| email | Único, válido, formato correcto |
| curp | 18 caracteres exactos |
| phone_number | Debe empezar con +52 |
| birthdate | YYYY-MM-DD |
| gender | "hombre" o "mujer" |
| blood_type | A+, A-, B+, B-, O+, O-, AB+, AB- |
| semestre | 1-8 |
| career_id | Debe existir |

## 4️⃣ Flujo de Código

```javascript
// 1. Usuario abre modal
openImportModal() {
    this.showImportModal = true;
    this.importFile = null;
    this.importResult = null;
    this.importError = null;
}

// 2. Usuario selecciona archivo
handleFileSelect(event) {
    const file = event.target.files[0];
    // Validar tipo
    // Almacenar: this.importFile = file;
}

// 3. Usuario hace clic importar
async importUsersFromFile() {
    // 1. Obtener token
    // 2. Crear FormData
    // 3. Hacer POST al endpoint
    // 4. Procesar respuesta
    // 5. Mostrar resultados
    // 6. Recargar usuarios
    // 7. Cerrar modal
}

// 4. Modal muestra resultados
// - Si éxito: resumen + errores
// - Si error: mensaje + detalles
```

## 5️⃣ Testing

### Prueba Rápida (PowerShell)
```powershell
$token = "YOUR_TOKEN"
$file = "C:\usuarios.xlsx"

$headers = @{
    "Authorization" = "Bearer $token"
    "X-User-Role" = "admin"
    "X-User-Permission" = "import.users"
}

$form = @{ file = Get-Item -Path $file }

Invoke-WebRequest -Uri "https://nginx-production-728f.up.railway.app/api/v1/admin-actions/import-users" `
    -Method POST -Headers $headers -Form $form
```

### Prueba Completa
```powershell
.\test-import-users.ps1 -Token "YOUR_TOKEN" -FilePath "C:\usuarios.xlsx"
```

## 6️⃣ Estructura del Modal HTML

```html
<!-- Modal Principal -->
<div x-show="showImportModal">
    <!-- Overlay -->
    <!-- Contenedor Principal -->
    
    <!-- Si !importResult && !importError: Mostrar formulario -->
    <form @submit.prevent="importUsersFromFile()">
        <!-- Input File -->
        <!-- Info sobre columnas -->
        <!-- Botones: Cancelar, Importar -->
    </form>
    
    <!-- Si importResult: Mostrar éxito -->
    <div>
        <!-- Resumen con estadísticas -->
        <!-- Tabla de errores -->
        <!-- Botón Cerrar -->
    </div>
    
    <!-- Si importError: Mostrar error -->
    <div>
        <!-- Mensaje de error -->
        <!-- Detalles de validación -->
        <!-- Botón Cerrar -->
    </div>
</div>
```

## 7️⃣ Manejo de Errores

### Errores Comunes

| Error | Causa | Solución |
|-------|-------|----------|
| "Email inválido" | Formato incorrecto | Valida email@dominio.com |
| "CURP requerida" | Campo vacío o <18 chars | Usa 18 caracteres |
| "Career ID no existe" | ID no está en BD | Verifica IDs disponibles |
| "Semestre inválido" | Fuera de rango 1-8 | Usa 1-8 |
| "El archivo no es válido" | No es Excel | Usa .xlsx |

### Manejo en Código

```javascript
// Validación de archivo
if (!fileName.endsWith('.xlsx')) {
    this.showNotify('Solo .xlsx permitido', 'error');
    return;
}

// Validación de token
if (!token) {
    this.showNotify('No hay token', 'error');
    return;
}

// Manejo de respuesta
if (response.ok && result.success) {
    // Procesar éxito
    this.importResult = result.data.summary;
} else {
    // Procesar error
    this.importError = {
        message: result.message,
        errors: result.errors
    };
}
```

## 8️⃣ Variables Importantes

### Del Sistema
```javascript
this.apiBaseUrl           // URL base de API
this.users               // Lista de usuarios
this.selectedUsers       // IDs de usuarios seleccionados
```

### De Importación
```javascript
this.showImportModal     // Modal visible (true/false)
this.importFile          // Archivo File object
this.isImporting         // Importando (true/false)
this.importResult        // {summary, errors, warnings}
this.importError         // {message, errors}
```

### De UI
```javascript
showNotify(msg, type)    // Mostrar notificación
loadUsers()              // Recargar lista usuarios
```

## 9️⃣ Respuestas del Servidor

### 200 OK - Éxito
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
    }
  }
}
```

### 400 Bad Request - Validación
```json
{
  "success": false,
  "message": "Error descriptivo",
  "error_code": "VALIDATION_ERROR",
  "errors": {
    "file": ["No es un archivo válido"]
  }
}
```

### 422 Unprocessable Entity - Datos
```json
{
  "success": false,
  "message": "Hay errores en los datos",
  "errors": {
    "email": ["Email inválido"],
    "curp": ["CURP requerida"]
  }
}
```

### 500 Server Error
```json
{
  "success": false,
  "message": "Error interno del servidor",
  "error_code": "INTERNAL_ERROR"
}
```

## 🔟 Checklist de Implementación

- ✅ Estados agregados
- ✅ Funciones implementadas
- ✅ Modal HTML creado
- ✅ Validación de archivo
- ✅ Solicitud POST realizada
- ✅ Respuesta procesada
- ✅ Resultados mostrados
- ✅ Errores manejados
- ✅ Usuarios recargados
- ✅ Sin errores de compilación

## 📚 Documentación Relacionada

- [IMPORT_USERS_GUIDE.md](./IMPORT_USERS_GUIDE.md) - Guía completa
- [EXCEL_TEMPLATE_GUIDE.md](./EXCEL_TEMPLATE_GUIDE.md) - Formato Excel
- [IMPLEMENTATION_IMPORT_USERS.md](./IMPLEMENTATION_IMPORT_USERS.md) - Detalles implementación

## 🔗 Enlaces Útiles

- **Archivo Principal**: `Frond-end/src/pages/roles.astro`
- **Endpoint**: `/v1/admin-actions/import-users`
- **Test Script**: `test-import-users.ps1`

## 💡 Tips & Tricks

### 1. Debug
```javascript
console.log('File:', this.importFile);
console.log('Result:', this.importResult);
console.log('Error:', this.importError);
```

### 2. Recrear Modal
```javascript
// Para resetear completamente
this.closeImportModal();
this.openImportModal();
```

### 3. Verificar Permisos
```javascript
// En headers debe estar
'X-User-Permission': 'import.users'
```

### 4. Testing Local
1. Prepara Excel con datos de prueba
2. Abre página roles.astro
3. Haz clic "Importar"
4. Selecciona archivo
5. Revisa consola (F12) para logs
6. Verifica respuesta del servidor

## 🎯 Resumen

| Aspecto | Valor |
|--------|-------|
| Estado | ✅ Implementado |
| Errores | ✅ Ninguno |
| Documentación | ✅ Completa |
| Testing | ✅ Disponible |
| Producción | ✅ Listo |

