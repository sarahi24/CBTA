# Endpoint: POST /api/v1/admin-actions/promotion

## Descripción
Incrementa el semestre de todos los estudiantes y da de baja a quienes sobrepasan el semestre 12.

## Funcionalidad
- Se hace un incremento en el semestre de todos los alumnos sin importar su estado actual
- Se da de baja automáticamente a los estudiantes que sobrepasan el semestre 12
- Todos los cambios se realizan dentro de una transacción de base de datos

## Requisitos de Autorización

### Headers Requeridos
- `Authorization: Bearer {token}` - Token de autenticación Sanctum
- `Content-Type: application/json`

### Permisos Requeridos
- **Rol**: `admin`
- **Permiso**: `promote.student`

## Request

### Método
```
POST /api/v1/admin-actions/promotion
```

### URL Completa
```
https://nginx-production-728f.up.railway.app/api/v1/admin-actions/promotion
```

### Headers Ejemplo
```
Authorization: Bearer {your_access_token}
Content-Type: application/json
```

### Body
```json
{
  // No requiere body
}
```

## Response

### Success (200 OK)
```json
{
  "success": true,
  "message": "Se ejecutó la promoción de usuarios correctamente.",
  "data": {
    "affected": {
      "usuarios_promovidos": 27,
      "usuarios_baja": 5
    }
  }
}
```

### Error de Validación (422)
```json
{
  "success": false,
  "message": "Error descriptivo para el usuario",
  "error_code": "VALIDATION_ERROR",
  "errors": {
    "email": [
      "El campo email es requerido",
      "El email debe ser válido"
    ]
  }
}
```

### Error de Servidor (500)
```json
{
  "success": false,
  "message": "Error descriptivo para el usuario",
  "error_code": "PROMOTION_ERROR"
}
```

### Error de Permisos (403)
```json
{
  "success": false,
  "message": "Insufficient permissions. promote.student permission required.",
  "error_code": "PERMISSION_DENIED"
}
```

## Implementación en el Proyecto

### Backend - Laravel

**Controller**: `app/Http/Controllers/AdminActionsController.php`

```php
<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AdminActionsController extends Controller
{
    public function promoteStudents(Request $request)
    {
        try {
            // Verify user has admin role
            $user = $request->user();
            
            if (!$user || !$user->hasRole('admin')) {
                return response()->json([
                    'success' => false,
                    'message' => 'Insufficient permissions. Admin role required.',
                    'error_code' => 'PERMISSION_DENIED'
                ], 403);
            }

            // Verify user has the promote.student permission
            if (!$user->hasPermissionTo('promote.student')) {
                return response()->json([
                    'success' => false,
                    'message' => 'Insufficient permissions. promote.student permission required.',
                    'error_code' => 'PERMISSION_DENIED'
                ], 403);
            }

            // Start a database transaction
            DB::beginTransaction();

            // Get all students (regardless of status)
            $students = User::whereHas('roles', function($query) {
                $query->where('name', 'student');
            })->get();

            $promovidos = 0;
            $baja = 0;

            foreach ($students as $student) {
                // Get current semester, default to 1 if null
                $currentSemestre = $student->semestre ?? 1;
                
                // Increment semester
                $newSemestre = $currentSemestre + 1;

                // If new semester exceeds 12, set status to "baja"
                if ($newSemestre > 12) {
                    $student->update([
                        'status' => 'baja',
                        'semestre' => 12
                    ]);
                    $baja++;
                } else {
                    // Otherwise, just increment semester
                    $student->update([
                        'semestre' => $newSemestre
                    ]);
                    $promovidos++;
                }
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Se ejecutó la promoción de usuarios correctamente.',
                'data' => [
                    'affected' => [
                        'usuarios_promovidos' => $promovidos,
                        'usuarios_baja' => $baja
                    ]
                ]
            ], 200);

        } catch (\Exception $e) {
            DB::rollBack();
            
            \Log::error('Error en promoción de estudiantes', [
                'error' => $e->getMessage(),
                'file' => $e->getFile(),
                'line' => $e->getLine(),
                'trace' => $e->getTraceAsString()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Error al ejecutar la promoción de estudiantes',
                'error_code' => 'PROMOTION_ERROR'
            ], 500);
        }
    }
}
```

**Ruta**: `routes/api.php`

```php
Route::post('/promotion', [AdminActionsController::class, 'promoteStudents'])
    ->middleware('permission:promote.student');
```

### Frontend - Astro/JavaScript

**Configuración**: `src/config/api.js`

```javascript
export const API_ENDPOINTS = {
  adminActions: {
    promotion: `${API_BASE_URL}/v1/admin-actions/promotion`,
    // ... otros endpoints
  }
}
```

**Página**: `src/pages/roles.astro`

```javascript
async promoteStudents() {
    if (!confirm('¿Estás seguro de promover a TODOS los estudiantes? Se incrementará el semestre y se darán de baja los que sobrepasen el semestre 12.')) {
        return;
    }

    const token = localStorage.getItem('access_token');
    if (!token) {
        this.showNotify('No hay token de autenticación', 'error');
        return;
    }

    try {
        this.isLoadingUsers = true;
        const response = await this.authenticatedFetch(
            `${this.apiBaseUrl}/v1/admin-actions/promotion`,
            { method: 'POST' }
        );

        const result = await response.json();
        if (response.ok && result.success) {
            const affected = result.data?.affected;
            this.showNotify(
                `✅ Promoción completada: ${affected?.usuarios_promovidos || 0} promovidos, ${affected?.usuarios_baja || 0} dados de baja`,
                'success'
            );
            await this.loadUsers(token);
        } else {
            this.showNotify(result.message || 'Error al promover estudiantes', 'error');
        }
    } catch (error) {
        console.error('❌ Error en promoteStudents:', error);
        this.showNotify('Error al promover estudiantes', 'error');
    } finally {
        this.isLoadingUsers = false;
    }
}
```

## Llamada desde cURL

```bash
curl -X POST \
  https://nginx-production-728f.up.railway.app/api/v1/admin-actions/promotion \
  -H "Authorization: Bearer {access_token}" \
  -H "Content-Type: application/json"
```

## Llamada desde JavaScript/Fetch

```javascript
const response = await fetch('https://nginx-production-728f.up.railway.app/api/v1/admin-actions/promotion', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${accessToken}`,
    'Content-Type': 'application/json'
  }
});

const data = await response.json();
console.log(data);
```

## Consideraciones Importantes

1. **Transacción de Base de Datos**: Todos los cambios se realizan dentro de una transacción. Si algo falla, se revierte todo.

2. **Validación de Permisos**: Se verifica que el usuario tenga:
   - Rol: `admin`
   - Permiso: `promote.student`

3. **Lógica de Promoción**:
   - Se incrementa el semestre en 1 para todos los estudiantes
   - Los estudiantes cuyo nuevo semestre sea mayor a 12 se dan de baja automáticamente
   - Se contabilizan por separado los promovidos y los dados de baja

4. **Estatus de Base de Datos**:
   - Después de la promoción, los estudiantes dados de baja tendrán `status = 'baja'`
   - Los demás mantendrán su estatus actual (activo, inactivo, etc.) pero con el semestre incrementado

## Uso en la Interfaz

En la página `roles.astro` hay un botón que desencadena esta acción. El usuario debe confirmar antes de proceder.

## Testing

Para probar este endpoint:

1. Asegúrate de tener un token de autenticación válido con rol `admin`
2. Verifica que el usuario tenga el permiso `promote.student`
3. Realiza un POST a `/api/v1/admin-actions/promotion`
4. Verifica la respuesta y que los semestres de los estudiantes se hayan incrementado
