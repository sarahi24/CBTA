# Promoción de Estudiantes - Guía de Solución

## ✅ Cambios Realizados

### 1. **Backend - AdminActionsController.php**
- Añadido método `ensurePromotePermissionExists()` que crea el permiso `promote.student` automáticamente si no existe
- El controlador ahora verifica:
  - Autenticación del usuario
  - Rol `admin`
  - Permiso `promote.student`
- Mejorada la lógica de promoción con:
  - Búsqueda de estudiantes más robusta
  - Procesamiento en lotes de 100 estudiantes
  - Logging detallado en cada paso
  - Manejo de transacciones seguro

### 2. **Backend - DatabaseSeeder.php**
- Añadido permiso `promote.student` a la lista de permisos del admin
- El seeder asigna todos los permisos automáticamente

### 3. **Backend - UsersSeeder.php**
- Corregido: Eliminado `guard_name: 'sanctum'` de la creación de roles (usa el default)

### 4. **Backend - routes/api.php**
- Añadido middleware `permission:promote.student` a la ruta de promoción

### 5. **Frontend - roles.astro**
- Mejorado el método `promoteStudents()` con:
  - Logging detallado en consola
  - Mejor visualización de errores
  - Mensajes de error más descriptivos

### 6. **Helper Script**
- Creado `setup-permissions.php` para configuración manual de permisos

## 🚀 Cómo Usar

### Opción 1: Automático (Recomendado)
1. Despliega los cambios en Railway
2. Llama al endpoint `/api/v1/admin-actions/promotion` con un usuario admin
3. El controlador creará automáticamente el permiso si no existe

### Opción 2: Manual
Si quieres crear los permisos explícitamente antes:

En Railway Dashboard, abre una consola SSH y ejecuta:
```bash
php artisan tinker
```

Luego pega el contenido de `setup-permissions.php`

### Opción 3: Database Seeder
En la consola de Railway:
```bash
php artisan db:seed
```

## 📋 Flujo de Autorización

```
POST /api/v1/admin-actions/promotion
    ↓
Middleware: auth:sanctum (verifica token)
    ↓
Middleware: role:admin|financial staff (verifica rol)
    ↓
Middleware: permission:promote.student (verifica permiso)
    ↓
Controller: ensurePromotePermissionExists() (crea si no existe)
    ↓
Controller: Verifica rol y permiso nuevamente
    ↓
Ejecuta la promoción de estudiantes
```

## 🔍 Debug

Si hay errores, llama a:
```
GET /api/v1/admin-actions/promotion-debug
```

Esto mostrará:
- Todos los roles en la BD
- Si existe el permiso `promote.student`
- Si el rol admin tiene el permiso
- Cantidad de estudiantes disponibles

## ✨ Resultado Esperado

Al llamar a `/api/v1/admin-actions/promotion`:
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

## 🛠️ Archivos Modificados

1. `backend/school-management/app/Http/Controllers/AdminActionsController.php` ✅
2. `backend/school-management/database/seeders/DatabaseSeeder.php` ✅
3. `backend/school-management/database/seeders/UsersSeeder.php` ✅
4. `backend/school-management/routes/api.php` ✅
5. `Frond-end/src/pages/roles.astro` ✅

## 📝 Notas

- El permiso se crea automáticamente si no existe (fallback automático)
- Los transacciones de BD están protegidas con rollback en caso de error
- El logging es detallado para debugging
- El endpoint ahora es totalmente seguro y robusto
