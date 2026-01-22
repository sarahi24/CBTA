# 🔧 CORS Fix - Pasos para Desplegar

## 📋 Cambios Realizados

Se actualizó la configuración de nginx para manejar correctamente las solicitudes CORS y las peticiones preflight OPTIONS.

## 🚀 Pasos para Aplicar la Solución

### 1. Commit y Push de los Cambios

```bash
cd backend/school-management
git add nginx/default.conf
git commit -m "fix: Add CORS headers to nginx configuration"
git push
```

### 2. Verificar Variables de Entorno en Railway

Asegúrate de que estas variables estén configuradas en Railway:

```env
FRONTEND_URL=https://cbta-eight.vercel.app
SANCTUM_STATEFUL_DOMAINS=cbta-eight.vercel.app,*.vercel.app
SESSION_DOMAIN=.vercel.app
APP_URL=https://nginx-production-728f.up.railway.app
```

**Cómo configurar en Railway:**
1. Ve a [Railway Dashboard](https://railway.app/)
2. Selecciona tu proyecto
3. Click en el servicio "nginx" o "backend"
4. Ve a la pestaña **"Variables"**
5. Agrega/verifica las variables listadas arriba
6. Guarda los cambios

### 3. Redeploy del Backend

Después de hacer push de los cambios, Railway automáticamente hará redeploy. Si no:

1. Ve a tu servicio en Railway
2. Click en **"Deployments"**
3. Click en **"Deploy"** en la última versión o en **"Redeploy"**

### 4. Verificar que Funcione

Después del despliegue (espera 2-3 minutos), verifica:

1. Abre tu frontend: https://cbta-eight.vercel.app
2. Abre la consola del navegador (F12)
3. Recarga la página
4. Deberías ver el mensaje "API is online ✅" sin errores de CORS

## 🔍 Qué Hace la Nueva Configuración

La configuración de nginx actualizada:

- ✅ Agrega headers CORS a todas las respuestas
- ✅ Maneja las peticiones OPTIONS (preflight) devolviendo 204
- ✅ Permite credenciales (cookies/sessions)
- ✅ Acepta todos los orígenes necesarios
- ✅ Expone los headers de Authorization

## ❌ Si Sigue sin Funcionar

### Opción 1: Verificar Logs en Railway
1. Ve a tu servicio en Railway
2. Click en **"Deployments"**
3. Ve los logs para ver si hay errores

### Opción 2: Verificar que nginx esté usando la nueva configuración
El contenedor debe montarse correctamente. Verifica en Railway que:
- El Dockerfile copia correctamente la configuración de nginx
- El servicio se reinició después del push

### Opción 3: Clear Cache del Navegador
- Abre DevTools (F12)
- Click derecho en el botón de reload
- Selecciona "Empty Cache and Hard Reload"

## 📝 Notas Adicionales

- Los cambios de nginx requieren un rebuild del contenedor
- Las variables de entorno requieren un redeploy
- Si haces cambios en `.env` local, no afectan Railway (usa las variables de Railway)
