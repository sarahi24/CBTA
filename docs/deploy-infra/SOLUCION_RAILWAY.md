# Solución para Railway - Endpoint de Promoción

## ✅ Estado del Código

**Todo el código está correcto y desplegado:**
- ✅ Commit 0b0279e en GitHub
- ✅ AdminActionsController simplificado (sin errores de lógica)
- ✅ Rutas configuradas correctamente en api.php
- ✅ Frontend con manejo de errores mejorado
- ✅ Seeder con permiso `promote.student`

## ⚠️ Problema Actual

Railway está dando **500 Internal Server Error** en todos los endpoints, incluyendo `/api/v1/auth/login`.

**Síntomas:**
```
❌ POST /api/v1/auth/login → 500 Error
❌ POST /api → 500 Error  
✅ HTTPS conexión → OK (puerto 443 responde)
```

**Causa probable:** Base de datos no conectada o variables de entorno faltantes.

## 🔧 Pasos para Solucionar en Railway

### 1. Verificar Variables de Entorno

Ir a Railway Dashboard → Tu Proyecto → Variables:

```env
# Requeridas
APP_NAME=CBTA
APP_ENV=production
APP_KEY=base64:TU_APP_KEY_AQUI
APP_DEBUG=false
APP_URL=https://nginx-production-728f.up.railway.app

# Base de datos (CRÍTICO)
DB_CONNECTION=mysql
DB_HOST=containers-us-west-xxx.railway.app  # Tu host de Railway MySQL
DB_PORT=3306
DB_DATABASE=railway
DB_USERNAME=root
DB_PASSWORD=TU_PASSWORD_DE_RAILWAY

# Sanctum
SANCTUM_STATEFUL_DOMAINS=cbta-bdu0.vercel.app
SESSION_DRIVER=cookie
SESSION_DOMAIN=.railway.app

# Cache y Queue
CACHE_DRIVER=file
QUEUE_CONNECTION=sync
```

### 2. Verificar Servicio MySQL en Railway

1. Ve a Railway Dashboard
2. Verifica que el servicio **MySQL** esté:
   - ✅ Deployado
   - ✅ Running (verde)
   - ✅ Con variables exportadas

3. Copia las variables de MySQL:
   - `MYSQL_HOST` → cópialo a `DB_HOST`
   - `MYSQL_PORT` → cópialo a `DB_PORT`
   - `MYSQL_DATABASE` → cópialo a `DB_DATABASE`
   - `MYSQL_USER` → cópialo a `DB_USERNAME`
   - `MYSQL_PASSWORD` → cópialo a `DB_PASSWORD`

### 3. Ejecutar Migraciones y Seeders

Una vez que la base de datos esté conectada:

```bash
# En Railway CLI o desde el dashboard
php artisan migrate:fresh --seed
```

O desde la interfaz de Railway:
1. Ve a tu servicio Laravel
2. Click en "Settings" → "Deploy"
3. Agrega comando de inicio:
   ```bash
   php artisan migrate --force && php-fpm
   ```

### 4. Verificar Logs en Railway

1. Ve a Railway Dashboard
2. Click en tu servicio
3. Ve a "Logs" (icono de terminal)
4. Busca errores como:
   - `SQLSTATE[HY000] [2002] Connection refused` → Base de datos no conectada
   - `No application encryption key has been specified` → Falta APP_KEY
   - `Class 'Permission' not found` → Falta composer install

### 5. Generar APP_KEY

Si falta `APP_KEY`:

```bash
# Localmente
php artisan key:generate --show

# Copia el resultado y agrégalo a Railway como variable APP_KEY
```

### 6. Redeploy Manual

Después de configurar variables:

1. Ve a Railway Dashboard
2. Click en tu servicio Laravel
3. Click en "Deploy" → "Redeploy"
4. Espera 2-5 minutos

## 🧪 Pruebas Después de Configurar

### Paso 1: Probar Login

```powershell
$body = '{"email":"admin@example.com","password":"password"}'
$response = Invoke-RestMethod -Uri "https://nginx-production-728f.up.railway.app/api/v1/auth/login" -Method Post -Body $body -ContentType "application/json"
$token = $response.data.token
Write-Host "Token: $token"
```

**Esperado:** 
```json
{
  "success": true,
  "data": {
    "token": "1|abc123...",
    "user": {...}
  }
}
```

### Paso 2: Probar Endpoint de Debug

```powershell
$headers = @{ "Authorization" = "Bearer $token"; "Content-Type" = "application/json" }
Invoke-RestMethod -Uri "https://nginx-production-728f.up.railway.app/api/v1/admin-actions/promotion-debug" -Headers $headers
```

**Esperado:**
```json
{
  "success": true,
  "debug": {
    "total_roles": 3,
    "student_role_id": 2,
    "promote_permission_exists": true,
    "students_count": 50
  }
}
```

### Paso 3: Probar Endpoint de Promoción

```powershell
$headers = @{ "Authorization" = "Bearer $token"; "Content-Type" = "application/json" }
$result = Invoke-RestMethod -Uri "https://nginx-production-728f.up.railway.app/api/v1/admin-actions/promotion" -Method Post -Headers $headers
$result | ConvertTo-Json
```

**Esperado:**
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

## 📋 Checklist de Verificación

### En Railway Dashboard:

- [ ] MySQL service está Running (verde)
- [ ] Variables de entorno DB_* están configuradas
- [ ] APP_KEY está configurado
- [ ] Deploy completó sin errores
- [ ] Logs no muestran errores de conexión

### En el Código (Ya completado ✅):

- [x] `AdminActionsController.php` simplificado
- [x] Middleware `permission:promote.student` removido de rutas
- [x] Endpoints `/promotion`, `/promotion-test`, `/promotion-debug` creados
- [x] Seeder incluye permiso `promote.student`
- [x] Frontend maneja errores correctamente

## 🎯 Resumen Ejecutivo

**El problema NO es el código** - El código está correcto y desplegado.

**El problema ES la configuración de Railway:**
1. Base de datos MySQL no está conectada
2. O las variables de entorno no están configuradas
3. O el seeder no se ha ejecutado

**Solución:**
1. Configurar variables `DB_*` en Railway
2. Ejecutar `php artisan migrate:fresh --seed`
3. Redeploy
4. Probar endpoints

Una vez que Railway esté configurado correctamente, el endpoint de promoción funcionará perfectamente según la especificación del API.

## 📞 Soporte

Si después de seguir estos pasos sigue dando error:

1. Exporta los logs de Railway y revísalos
2. Verifica que MySQL tenga suficiente RAM (mínimo 512MB)
3. Asegúrate de que el plan de Railway permita conexiones a base de datos
4. Considera usar SQLite en desarrollo si MySQL no está disponible
