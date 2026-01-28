# Cache Clearing Instructions for Railway Deployment

Si después de hacer push sigues recibiendo errores 500, probablemente sea porque Laravel está cacheando la configuración.

## Opción 1: Limpiar cache automáticamente (Recomendado)

Ejecuta esto en tu servidor Railway o localmente en la carpeta `backend/school-management`:

```bash
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

## Opción 2: Deshabilitar cache (Para desarrollo)

En tu archivo `.env`:
```
CONFIG_CACHE=false
ROUTE_CACHE=false
VIEW_CACHE=false
```

## Opción 3: Comando de limpieza completa

```bash
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear
```

## Para Railway específicamente

Si estás usando Railway, puedes:

1. Ir a tu proyecto en Railway.app
2. Ir a la pestaña "Logs"
3. Buscar errores relacionados a `promotion` endpoint
4. Los logs te mostrarán exactamente qué está fallando

## Verificar que el endpoint existe

Después de deployar, puedes verificar en la consola de dev del navegador (F12):

```javascript
// Prueba si el endpoint está disponible
fetch('https://nginx-production-728f.up.railway.app/api/v1/admin-actions/promotion', {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer YOUR_TOKEN',
    'Content-Type': 'application/json'
  }
}).then(r => r.json()).then(console.log).catch(console.error)
```

El token lo puedes obtener de localStorage en la consola:
```javascript
console.log(localStorage.getItem('access_token'))
```
