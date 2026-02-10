# 🧪 COMANDOS DE DEBUGGING RÁPIDO

## Cómo usar:
1. Abre la página de perfil
2. Presiona F12 (DevTools)
3. Ve a la pestaña "Console"
4. Copia y pega los comandos de abajo
5. Presiona Enter

---

## 1️⃣ VERIFICAR AUTENTICACIÓN

```javascript
// ¿Hay token?
const token = localStorage.getItem('token');
console.log('Token presente:', !!token);
console.log('Token válido:', token?.length > 10 ? '✅' : '❌');
if (token) console.log('Token (primeros 30 chars):', token.substring(0, 30) + '...');
```

---

## 2️⃣ VERIFICAR DATOS DE USUARIO EN STORAGE

```javascript
// Ver datos crudos
const userData = localStorage.getItem('user_data');
console.log('Has user_data:', !!userData);

if (userData) {
    try {
        const user = JSON.parse(userData);
        console.log('=== USUARIO ===');
        console.table({
            'ID': user.id,
            'Nombre': user.name,
            'Apellido': user.last_name,
            'Email': user.email,
            'Roles': Array.isArray(user.roles) ? user.roles.length : 'N/A',
            'Permisos': Array.isArray(user.permissions) ? user.permissions.length : 'N/A',
            'Completo': `${user.name} ${user.last_name}`
        });
    } catch (e) {
        console.error('Error al parsear user_data:', e);
    }
} else {
    console.warn('⚠️ NO HAY user_data EN STORAGE');
}
```

---

## 3️⃣ TEST API MANUAL (sin PowerShell)

```javascript
// Necesitas token válido
const token = localStorage.getItem('token');
const API_BASE_URL = 'https://nginx-production-728f.up.railway.app/api';

if (!token) {
    console.error('❌ No hay token. Debes autenticarte primero.');
} else {
    fetch(API_BASE_URL + '/v1/users/user', {
        method: 'GET',
        headers: {
            'Authorization': 'Bearer ' + token,
            'Accept': 'application/json'
        }
    })
    .then(res => {
        console.log('Status:', res.status);
        return res.json();
    })
    .then(data => {
        console.log('Response:', data);
        if (data.success && data.data?.user) {
            console.log('✅ API funcionando');
            console.table({
                'ID': data.data.user.id,
                'Nombre': data.data.user.name,
                'Apellido': data.data.user.last_name,
                'Email': data.data.user.email
            });
        }
    })
    .catch(err => {
        console.error('❌ Error en API:', err);
    });
}
```

---

## 4️⃣ LIMPIAR STORAGE Y REINICIAR

```javascript
// ⚠️ CUIDADO: Esto borra TODO
if (confirm('¿Borrar token y datos? Tendrás que iniciar sesión de nuevo.')) {
    localStorage.removeItem('token');
    localStorage.removeItem('user_data');
    console.log('✅ Storage limpiado. Recarga la página (F5)');
    location.reload();
}
```

---

## 5️⃣ VER LOGS RECIENTES (si el browser lo permite)

```javascript
// Ver algunos logs del console
// Nota: Esto solo funciona si los logs están en memoria
console.log('📋 Ver logs en la consola arriba');
console.log('Busca logs que comiencen con: ✅, ❌, ⚠️, 📤, 📥, 🔐, 🔄');
```

---

## 6️⃣ FORZAR RECARGA DE PERFIL (Desde JavaScript Alpine)

```javascript
// Si Alpine está disponible (típicamente sí en esta app)
// Esto recarga los datos del usuario
if (window.Alpine && window.Alpine.data) {
    const perfilComponent = document.querySelector('[x-data="perfilData"]')?.__x;
    if (perfilComponent) {
        console.log('🔄 Forzando recarga de datos...');
        perfilComponent.loadUserData();
        console.log('✅ Recarga iniciada');
    } else {
        console.warn('⚠️ No se encontró el componente Alpine');
    }
}
```

---

## 7️⃣ VER TODO EL STORAGE

```javascript
// Debug: Ver TODO lo que hay en localStorage
console.log('=== TODO EN LOCALSTORAGE ===');
for (let i = 0; i < localStorage.length; i++) {
    const key = localStorage.key(i);
    const value = localStorage.getItem(key);
    console.log(`${key}:`, value?.length > 100 ? value.substring(0, 100) + '...' : value);
}
```

---

## 8️⃣ COPIAR TOKEN PARA USAR CON PowerShell

```javascript
// Copiar token al portapapeles
const token = localStorage.getItem('token');
if (token) {
    // Copiar
    navigator.clipboard.writeText(token).then(() => {
        console.log('✅ Token copiado al portapapeles');
        console.log('Usa: .\test-perfil-api.ps1 "' + token.substring(0, 20) + '..."');
    });
} else {
    console.error('❌ No hay token para copiar');
}
```

---

## 🎯 FLUJO DE DEBUG RECOMENDADO

1. **Primero:** Ejecuta comando 1️⃣ para ver si hay token
2. **Si hay token:** Ejecuta 2️⃣ para ver datos en storage
3. **Si los datos SON:**  Recarga la página (F5)
4. **Si los datos NO son:** Ejecuta 3️⃣ para probar API
5. **Si API falla:** Usa 8️⃣ para copiar token y prueba con PowerShell
6. **Si todo falla:** Usa 4️⃣ para limpiar y vuelve a iniciar sesión

---

## ✅ CHECKLIST DE VERIFICACIÓN

- [ ] Token existe en localStorage
- [ ] Token no es vacío (> 10 caracteres)
- [ ] user_data existe en localStorage
- [ ] user_data se puede parsear como JSON
- [ ] User tiene: id, name, last_name, email
- [ ] API responde con status 200
- [ ] API retorna data.success = true
- [ ] Página muestra nombre completo (no "Sin nombre")

---

## 💡 TIPS

- Si ves muchos errores: Abre DevTools → Console → busca errores rojos
- Si nada funciona: Limpia storage (comando 4️⃣) y vuelve a iniciar sesión
- Si la API no responde: Revisa que la URL sea correcta en el script
- Si ves "401": El token expiró, necesita volver a iniciar sesión

---

**¡Éxito con el debugging! 🚀**
