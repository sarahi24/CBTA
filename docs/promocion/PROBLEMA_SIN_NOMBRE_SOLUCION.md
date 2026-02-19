# 🔴 PROBLEMA: "Sin nombre" y datos incompletos en Perfil

## Lo que se ve en los logs
```
No token found, using localStorage fallback
Student data populated: {name: 'Sin nombre', email: 'No disponible', id: 34}
No token found, using localStorage fallback for student details
No student details found in storage
```

## ❌ Causa del Problema

El localStorage **NO tiene datos válidos** porque:

1. **No hay token en localStorage**
   - Sin token, no puede conectar a la API
   - Intenta cargar del localStorage pero está vacío o corrupto
   - Entonces muestra "Sin nombre" como valor por defecto

2. **El localStorage tiene datos incompletos**
   - Si hay 'user_data' pero faltan campos como `name`, `last_name`
   - El código usa valores por defecto inválidos

3. **El usuario NO está autenticado**
   - Necesita hacer login primero
   - Sin autenticación, no hay token, sin token no funciona nada

## ✅ SOLUCIÓN (3 Pasos)

### Paso 1: Verificar el Estado Actual

Abre DevTools (F12) en la página del perfil y ejecuta en la consola:

```javascript
console.log('Token:', localStorage.getItem('token') ? '✅' : '❌');
console.log('User data:', localStorage.getItem('user_data') ? '✅' : '❌');
```

### Paso 2: Si NO hay token o está vacío

**Inicia sesión primero:**
1. Ve a `/login` (o la página de autenticación)
2. Ingresa credenciales válidas
3. Espera a que se complete la autenticación
4. Verifica que localStorage ahora tenga 'token' (en DevTools)

### Paso 3: Vuelve al Perfil

1. Recarga la página de perfil (F5)
2. En la consola deberías ver:
   ```
   🔄 Starting user data load process...
   📋 Token status: ✅ Present
   🔄 Fetching user data from API...
   ✅ User data loaded and populated from API
   ```
3. El nombre debe aparecer completo (no "Sin nombre")

## 🧪 Verificar Qué Datos Hay

Ejecuta en la consola (F12):

```javascript
// Ver token
const token = localStorage.getItem('token');
console.log('Token existe:', !!token);
if (token) {
    console.log('Token (primeros 20 chars):', token.substring(0, 20) + '...');
}

// Ver datos de usuario
const userData = localStorage.getItem('user_data');
if (userData) {
    const user = JSON.parse(userData);
    console.log('Usuario en storage:', {
        id: user.id,
        nombre: user.name,
        apellido: user.last_name,
        email: user.email,
        completo: `${user.name} ${user.last_name}`
    });
} else {
    console.log('⚠️ No hay datos de usuario en localStorage');
}
```

## 📊 Posibles Estados

### Estado 1: TODO BIEN ✅
```
Token: ✅ Present
API Response: ✅ Success
User loaded: ✅ Juan García
```
→ **Qué ver:** Nombre completo en la página

### Estado 2: SIN TOKEN ❌
```
Token: ❌ Missing
API: (no se intenta)
Fallback: localStorage
ls user_data: ❌ Empty
```
→ **Solución:** Inicia sesión en /login

### Estado 3: TOKEN EXPIRADO ⚠️
```
Token: ✅ Present
API Response: 401 Unauthorized
Fallback: localStorage might work
```
→ **Solución:** Inicia sesión de nuevo

### Estado 4: API DOWN 🚨
```
Token: ✅ Present
API: ❌ Error/Timeout
Fallback: localStorage
ls user_data: ✅ Present
```
→ **Solución:** Espera a que API esté disponible

## 🔐 Qué es un Token Válido

- Se obtiene al iniciar sesión / login
- Se guarda en localStorage como 'token'
- Es requerido para TODAS las peticiones API
- Expira después de cierto tiempo (típicamente 24h)
- Si expira, necesita re-login
- Se envía en header: `Authorization: Bearer <token>`

## 📝 Cómo Saber si Estás Autenticado

En DevTools → Storage → Local Storage → busca 'token'

**Si está:**
- ✅ Estás autenticado
- Tienes acceso a endpoints de API
- El perfil debe cargar correctamente

**Si NO está:**
- ❌ No estás autenticado
- Necesitas iniciar sesión
- No se puede acceder a API
- El perfil no tendrá datos

## 🚀 Flujo Correcto

```
1. Usuario NO autenticado
   ↓
2. Va a /login
   ↓
3. Ingresa email y contraseña
   ↓
4. API autentica y retorna token
   ↓
5. Token se guarda en localStorage
   ↓
6. Usuario es redirigido a /perfil (o dashboard)
   ↓
7. Página de perfil carga
   ↓
8. Lee token de localStorage
   ↓
9. USA token para llamar a API /v1/users/user
   ↓
10. API retorna datos del usuario
    ↓
11. Datos se guardan en localStorage
    ↓
12. Datos se muestran en la página
    ↓
13. ✅ Perfil cargado correctamente
```

## 📞 Si Aún No Funciona

1. **Verifica en la consola (F12 > Console):**
   ```
   localStorage.getItem('token')  // Debe retornar un string largo
   ```

2. **Si retorna null:** Necesitas iniciar sesión

3. **Si retorna un string:** Copia el token y prueba:
   ```powershell
   .\test-perfil-api.ps1 "el_token_que_copiaste"
   ```

4. **Si el script de test falla:** El token es inválido o API está down

5. **Si tienes error "404":** La API no reconoce el endpoint

## 🎯 Resumen

| Problema | Causa | Solución |
|----------|-------|----------|
| "Sin nombre" | No hay datos en localStorage | Inicia sesión |
| "No disponible" | Datos incompletos | Recarga el perfil |
| Api error 401 | Token expirado | Inicia sesión otra vez |
| Api error 500 | API caída | Espera o contacta admin |
| No hay token | No autenticado | Ve a /login |

---

**Instrucciones rápidas:**
1. Abre DevTools (F12)
2. Verifica: `localStorage.getItem('token')`
3. Si es null → Inicia sesión
4. Si es string → Recarga el perfil
5. Si aún no funciona → Ejecuta test con token
