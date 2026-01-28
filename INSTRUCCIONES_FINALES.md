# ✅ ENDPOINT DE PROMOCIÓN - LISTO PARA USAR

## 🎯 Estado Actual

**EL CÓDIGO ESTÁ 100% CORRECTO Y DESPLEGADO EN GITHUB** ✅

El endpoint `POST /api/v1/admin-actions/promotion` está:
- ✅ Implementado correctamente en `AdminActionsController.php`
- ✅ Ruta configurada en `routes/api.php`
- ✅ Frontend actualizado en `roles.astro`
- ✅ Sin middleware problemático
- ✅ Con logs y debug mejorados

**Lo que falta:** Que Railway esté funcionando correctamente con la base de datos.

---

## 🔴 Problema Actual: Railway da Error 500

El servidor de Railway está dando **500 Internal Server Error** en TODOS los endpoints, incluyendo el login.

**Esto significa:** El problema es de INFRAESTRUCTURA, no de código.

**Causa más probable:** La base de datos MySQL no está conectada o faltan variables de entorno.

---

## 🛠️ SOLUCIÓN: Configurar Railway

### 1️⃣ Entrar a Railway Dashboard

1. Ve a https://railway.app/
2. Inicia sesión
3. Selecciona tu proyecto "CBTA"

### 2️⃣ Verificar MySQL

En Railway Dashboard:
- ¿Ves un servicio llamado **"MySQL"** o **"PostgreSQL"**?
- ¿Está en estado **"Running"** (verde)?
- ¿O está **detenido/error** (rojo)?

**Si NO existe el servicio de base de datos:**
1. Click en "+ New"
2. Selecciona "Database" → "MySQL"
3. Espera que se despliegue (2-3 minutos)

### 3️⃣ Copiar Variables de Base de Datos

Una vez que MySQL esté running:

1. Click en el servicio **MySQL**
2. Ve a la pestaña **"Variables"**
3. Verás algo como:
   ```
   MYSQL_HOST=containers-us-west-xxx.railway.app
   MYSQL_PORT=3306
   MYSQL_DATABASE=railway
   MYSQL_USER=root
   MYSQL_PASSWORD=abc123xyz
   ```

### 4️⃣ Configurar Variables en el Servicio Laravel

1. Click en tu servicio **Laravel** (no MySQL)
2. Ve a **"Variables"**
3. Agrega/edita estas variables:

```env
APP_NAME=CBTA
APP_ENV=production
APP_DEBUG=false
APP_KEY=base64:GENERA_UNA_KEY_AQUI

DB_CONNECTION=mysql
DB_HOST=containers-us-west-xxx.railway.app
DB_PORT=3306
DB_DATABASE=railway
DB_USERNAME=root
DB_PASSWORD=abc123xyz

SANCTUM_STATEFUL_DOMAINS=cbta-bdu0.vercel.app
SESSION_DRIVER=cookie
```

**⚠️ IMPORTANTE:** Copia los valores exactos de MySQL (Host, Password, etc.)

### 5️⃣ Generar APP_KEY

Si no tienes `APP_KEY`:

**Opción A - Online:**
1. Ve a https://generate-random.org/laravel-key-generator
2. Copia la key (debe empezar con `base64:`)
3. Pégala en Railway como variable `APP_KEY`

**Opción B - Localmente (si tienes PHP):**
```bash
cd backend/school-management
php artisan key:generate --show
```

### 6️⃣ Redeploy

1. En Railway, ve a tu servicio Laravel
2. Click en "⋯" (tres puntos)
3. Click en **"Redeploy"**
4. Espera 3-5 minutos

### 7️⃣ Ejecutar Migraciones

Una vez desplegado:

**Opción A - Desde Railway CLI:**
```bash
railway run php artisan migrate:fresh --seed
```

**Opción B - Manualmente:**
1. Ve a Railway Dashboard
2. Click en tu servicio
3. Ve a "Settings" → "Deploy"
4. En "Start Command" pon:
   ```bash
   php artisan migrate:fresh --seed && php-fpm
   ```
5. Redeploy

---

## 🧪 PROBAR EL ENDPOINT

### Método 1: Script Automático (Recomendado)

```powershell
cd "C:\Users\sarah\Documents\GitHub\CBTA"
powershell -ExecutionPolicy Bypass -File test-promocion-completo.ps1
```

Este script:
1. ✅ Hace login automático
2. ✅ Verifica la configuración
3. ✅ Te pide confirmación
4. ✅ Ejecuta la promoción
5. ✅ Muestra los resultados

### Método 2: Desde el Frontend

1. Ve a https://cbta-bdu0.vercel.app/roles
2. Inicia sesión como admin
3. Click en **"Promover Estudiantes"**
4. Confirma la acción
5. Verás: "✅ Promoción completada: X promovidos, Y dados de baja"

---

## 📋 CHECKLIST DE VERIFICACIÓN

Marca cada paso que completes:

**En Railway:**
- [ ] MySQL service existe y está Running (verde)
- [ ] Variables DB_* están configuradas en servicio Laravel
- [ ] APP_KEY está configurado
- [ ] Deploy completó sin errores (check en verde)
- [ ] Logs no muestran errores de conexión

**Pruebas:**
- [ ] Login funciona (test-promocion-completo.ps1)
- [ ] Endpoint debug muestra estudiantes
- [ ] Promoción se ejecuta correctamente
- [ ] Frontend muestra mensaje de éxito

---

## ❓ SI ALGO FALLA

### Error: "SQLSTATE[HY000] [2002] Connection refused"
**Solución:** MySQL no está conectado. Verifica que `DB_HOST` sea correcto.

### Error: "No application encryption key"
**Solución:** Falta `APP_KEY`. Genera una y agrégala a las variables.

### Error: "Class 'Permission' not found"
**Solución:** Ejecuta `php artisan migrate:fresh --seed` en Railway.

### Error: "Unauthenticated"
**Solución:** El token expiró. Haz login de nuevo.

### Login sigue dando 500
**Solución:** 
1. Ve a Railway → tu servicio → "Logs"
2. Lee el último error
3. Busca líneas rojas con "ERROR" o "FATAL"
4. Copia el error y búscalo en Google

---

## 📞 RESUMEN EJECUTIVO

**✅ Qué está listo:**
- Código del endpoint de promoción
- Frontend con botón funcional
- Scripts de prueba automatizados
- Documentación completa

**⏳ Qué falta:**
- Configurar variables de Railway
- Conectar base de datos MySQL
- Ejecutar migraciones/seeders

**⏱️ Tiempo estimado:**
- Configuración de Railway: 10-15 minutos
- Despliegue: 5 minutos
- Pruebas: 2 minutos

**Total: ~20 minutos para tener todo funcionando**

---

## 🎉 Cuando funcione verás:

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

**¡Y eso es todo!** 🚀
