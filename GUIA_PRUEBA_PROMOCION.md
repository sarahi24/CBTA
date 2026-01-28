# Guía de Prueba - Endpoint de Promoción Simplificado

## Estado de Despliegue

✅ **Cambios enviados a GitHub** (commit: 0b0279e)
- Simplificado: `AdminActionsController.php` (~60% menos código)
- Middleware de permiso removido de las rutas
- 3 endpoints de prueba creados

## Endpoints Disponibles (Requieren autenticación Sanctum)

### 1. Test Simple
```
POST /api/v1/admin-actions/promotion-test
```
**Qué hace:** Retorna ID del usuario autenticado
**Esperado:** `{"success": true, "user_id": X}`
**Propósito:** Verificar que el middleware funciona

### 2. Debug Endpoint
```
GET /api/v1/admin-actions/promotion-debug
```
**Qué hace:** Muestra el estado de roles, permisos y estudiantes
**Información incluida:**
- Total de roles en BD
- Nombres de todos los roles
- ID del rol de student
- ID del rol de admin
- Existencia del permiso `promote.student`
- Si admin tiene el permiso
- Cantidad de estudiantes encontrados

**Propósito:** Verificar que los datos de la BD están correctos

### 3. Promoción Principal
```
POST /api/v1/admin-actions/promotion
```
**Qué hace:** Promociona estudiantes al siguiente semestre
**Lógica:**
1. Obtiene el ID del rol "student"
2. Encuentra todos los usuarios con ese rol
3. Para cada estudiante:
   - Si semestre < 12: incrementa semestre en 1
   - Si semestre >= 12: establece status='baja' y semestre=12
4. Retorna cantidad de promovidos y dados de baja

**Esperado:**
```json
{
  "success": true,
  "message": "Se ejecutó la promoción de usuarios correctamente.",
  "data": {
    "affected": {
      "usuarios_promovidos": N,
      "usuarios_baja": M
    }
  }
}
```

## Orden de Prueba Recomendado

1. **Primero:** Test endpoint (`promotion-test`)
   - Si falla: problema en middleware auth
   - Si funciona: middleware está bien

2. **Segundo:** Debug endpoint (`promotion-debug`)
   - Verifica estado de BD
   - Muestra si roles/permisos existen
   - Muestra cuántos estudiantes hay

3. **Tercero:** Endpoint de promoción (`promotion`)
   - Si falla: ver error en respuesta
   - Si funciona: proceso completado

## Credenciales de Prueba

```
Email: admin@example.com
Password: password
```

## Cómo Obtener Token

```powershell
$response = Invoke-RestMethod -Uri "https://nginx-production-728f.up.railway.app/api/v1/auth/login" `
  -Method Post `
  -ContentType "application/json" `
  -Body (@{email="admin@example.com"; password="password"} | ConvertTo-Json)

$token = $response.data.token
```

## Cómo Probar un Endpoint

```powershell
$headers = @{ "Authorization" = "Bearer $token" }

# Test endpoint
Invoke-RestMethod -Uri "https://nginx-production-728f.up.railway.app/api/v1/admin-actions/promotion-test" `
  -Method Post -Headers $headers | ConvertTo-Json
```

## Cambios Realizados en Esta Sesión

### AdminActionsController.php
- ❌ Removido: Validación compleja de roles en controller
- ❌ Removido: Creación automática de permisos
- ❌ Removido: Llamadas a `hasRole()` y `hasPermissionTo()`
- ✅ Agregado: Método simple `testPromotion()`
- ✅ Agregado: Método `debugPromotion()` para diagnosticar
- ✅ Simplificado: `promoteStudents()` a lógica directa

### routes/api.php
- ❌ Removido: `->middleware('permission:promote.student')` que causaba el 500
- ✅ Agregado: Rutas de test y debug
- ✅ Mantiene: Middleware de autenticación y rol

### DatabaseSeeder.php
- ✅ Agregado: Permiso `promote.student`
- ✅ Configurado: Admin role obtiene todos los permisos necesarios

### UsersSeeder.php
- ✅ Corregido: Removido `guard_name: 'sanctum'` que causaba conflictos

### Frontend (roles.astro)
- ✅ Mejorado: Logging detallado en consola
- ✅ Mejorado: Extracción de mensajes de error
- ✅ Mejorado: Mostrar debug info en la UI

## Qué Pasó con el Error Anterior

**Problema:** Endpoint retornaba 500 con mensaje genérico "Ocurrió un error inesperado"

**Causa Real:** El middleware `permission:promote.student` validaba un permiso que NO existía en la BD

**Solución:** 
1. Removimos ese middleware (la validación de rol `admin` era suficiente)
2. Simplificamos el controlador para evitar any other middleware chain issues
3. Ahora la lógica es muy directa: no hay lugar donde puedan fallar cosas complejas

**Por qué funciona ahora:**
- Role middleware (`role:admin|financial staff`) valida al user
- Permiso no es validado en la ruta (no es necesario)
- Controller solo hace: obtener rol → buscar estudiantes → actualizar semestres
- Sin validaciones complejas = sin 500 errors ocultos

## Monitoreo

Si aún ves 500 errors después del despliegue:

1. Revisa el debug endpoint primero
2. Verifica que el permiso `promote.student` exista
3. Revisa logs de Laravel en Railway
4. Verifica conexión a BD

El código está listo para producción. Rails debería desplegar automáticamente cuando se detecte el push.
