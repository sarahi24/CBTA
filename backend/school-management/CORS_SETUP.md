# 🔒 Configuración de CORS

## ⚠️ Problema Actual

La API Laravel está bloqueando las solicitudes desde el frontend desplegado en Vercel debido a la configuración de CORS.

**Error:**
```
Access-Control-Allow-Origin' header has a value 'http://localhost:3000' 
that is not equal to the supplied origin
```

## ✅ Solución

### 1. **Configurar Variables de Entorno**

En tu servidor de producción (Railway), agrega esta variable de entorno:

```bash
FRONTEND_URL=https://cbta-eight.vercel.app
```

### 2. **Verificar config/cors.php**

El archivo ya está actualizado para permitir múltiples orígenes:

```php
'allowed_origins' => [
    env('FRONTEND_URL', 'http://localhost:3000'),
    'http://localhost:3000',
    'http://localhost:4321',
    'https://cbta-eight.vercel.app',
    'https://*.vercel.app',
],

'allowed_origins_patterns' => [
    '/^https:\/\/cbta-.*\.vercel\.app$/',
    '/^https:\/\/.*\.vercel\.app$/',
],
```

### 3. **Aplicar Cambios en Railway**

#### Opción A: Desde la Web de Railway

1. Ve a tu proyecto en Railway
2. Selecciona el servicio del backend
3. Ve a **Variables**
4. Agrega: `FRONTEND_URL = https://cbta-eight.vercel.app`
5. **Redeploy** el servicio

#### Opción B: Desde Git

1. Haz commit de los cambios en `config/cors.php`
2. Push al repositorio
3. Railway se redespleará automáticamente

### 4. **Verificar que funcione**

Abre la consola del navegador en tu frontend y deberías ver:

```
✅ API Conectada
```

En lugar de:

```
❌ Error de CORS
```

## 🔍 Para Testing Local

Si estás probando localmente, crea un archivo `.env` en la raíz del backend:

```bash
# .env
FRONTEND_URL=http://localhost:4321
APP_URL=http://localhost:8000
```

## 📝 Dominios Permitidos

Actualmente la API acepta solicitudes desde:

- ✅ `http://localhost:3000` (desarrollo)
- ✅ `http://localhost:4321` (Astro dev)
- ✅ `https://cbta-eight.vercel.app` (producción)
- ✅ `https://*.vercel.app` (preview deployments de Vercel)

## ⚡ Comandos Útiles en Railway

```bash
# Ver logs del servicio
railway logs

# Listar variables de entorno
railway variables

# Agregar variable
railway variables set FRONTEND_URL=https://cbta-eight.vercel.app

# Redeploy
railway up
```

## 🆘 Si Aún No Funciona

1. **Verifica que la variable esté configurada:**
   ```bash
   railway variables | grep FRONTEND_URL
   ```

2. **Limpia la caché de Laravel:**
   ```bash
   php artisan config:clear
   php artisan cache:clear
   ```

3. **Verifica los logs:**
   ```bash
   railway logs --follow
   ```

4. **Prueba el endpoint con curl:**
   ```bash
   curl -X OPTIONS https://nginx-production-728f.up.railway.app/api/v1/auth/login \
     -H "Origin: https://cbta-eight.vercel.app" \
     -H "Access-Control-Request-Method: POST" \
     -v
   ```

## 📚 Documentación

- [Laravel CORS](https://laravel.com/docs/11.x/routing#cors)
- [Railway Environment Variables](https://docs.railway.app/develop/variables)
- [CORS MDN](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS)
