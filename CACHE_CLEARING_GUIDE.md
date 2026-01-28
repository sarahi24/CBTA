# Guía de Solución del Error 500 en el Endpoint de Promoción

El error que ves (`500 Internal Server Error`) en el endpoint `/api/v1/admin-actions/promotion` es causado probablemente por el cacheo de rutas en Laravel.

## ✅ Lo que ya hice

1. **Mejoré el controlador** con mejor manejo de errores y logging
2. **Actualicé el Dockerfile** para que limpie el cache automáticamente en cada deploy
3. **Creé un comando artisan** para limpiar cache: `php artisan cache:clear-all`

## 🚀 Próximos Pasos (Elige uno)

### Opción 1: Forzar redeploy en Railway (Recomendado)

1. Ve a https://railway.app
2. Selecciona tu proyecto CBTA
3. En tu servicio, abre el menú de opciones (los tres puntitos)
4. Selecciona "Redeploy" o "Trigger Deploy"
5. Espera a que termine el deploy (verás los logs en tiempo real)
6. Una vez completado, recarga la página de tu aplicación

**¿Por qué?** El Docker build ahora ejecutará automáticamente los comandos de limpieza de cache.

---

### Opción 2: Ejecutar comando manualmente en Railway

Si el redeploy no funciona, puedes ejecutar el comando manualmente:

1. En https://railway.app, abre tu proyecto
2. Abre la terminal SSH de tu servicio (Railway Shell)
3. Ejecuta:
```bash
cd /var/www/backend/school-management
php artisan cache:clear-all
```

---

### Opción 3: Limpiar via SSH local (Si tienes acceso)

```bash
ssh your-railway-connection
cd /var/www/backend/school-management
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear
```

---

## 🔍 Verificar que el error se solucionó

Después de cualquiera de los pasos anteriores:

1. **Abre la Consola del Navegador** (F12 → Console)
2. Copia y ejecuta esto:
```javascript
// Obtén tu token
const token = localStorage.getItem('access_token');
console.log('Token:', token);

// Prueba el endpoint
fetch('https://nginx-production-728f.up.railway.app/api/v1/admin-actions/promotion', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  }
})
.then(r => {
  console.log('Status:', r.status);
  return r.json();
})
.then(data => console.log('Response:', data))
.catch(err => console.error('Error:', err));
```

3. **Si ves una respuesta con `"success": true`** → ✅ El endpoint funciona
4. **Si ves `403 Forbidden`** → Necesitas un usuario con rol `admin`
5. **Si ves `500`** → Aún hay un problema de cache, repite los pasos

---

## 📋 Cambios Realizados

### Controlador Mejorado
- ✅ Mejor logging de errores
- ✅ Validación de usuario más robusta
- ✅ Mensajes de error descriptivos
- ✅ Logs de cada paso del proceso

### Dockerfile Actualizado
- ✅ Automáticamente limpia cache en cada build
- ✅ Ejecuta `config:clear`, `route:clear`, `view:clear`, `cache:clear`

### Archivos Creados
- ✅ `ClearAllCache.php` - Comando artisan personalizado
- ✅ `clear-cache.sh` - Script de shell para limpiar cache

---

## 📝 Próxima Vez

La próxima vez que modifiques rutas o controladores en production, el Dockerfile se encargará automáticamente de limpiar el cache. Si aún así tienes problemas, puedes ejecutar:

```bash
php artisan cache:clear-all
```

---

## 💡 Nota

El error 500 es común después de deployar cambios en rutas o controladores de Laravel. El cache es bueno para performance pero a veces causa problemas durante el desarrollo. Los comandos que agregué se encargan de esto automáticamente.

