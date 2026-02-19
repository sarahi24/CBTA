# ⚡ GUÍA RÁPIDA - Qué Hacer Ahora

## 🎯 El Problema en 10 Segundos

Tu página de perfil muestra "Sin nombre" porque **NO estás autenticado** (no hay token en localStorage).

## ✅ Solución en 3 Pasos

### Paso 1: Abre DevTools
- Presiona **F12** en tu navegador
- Ve a la pestaña **Console**
- Ejecuta esto:

```javascript
console.log('Token:', localStorage.getItem('token') ? '✅' : '❌');
```

### Paso 2: Verifica el Resultado
- Si dice **✅**: Hay token (ve al Paso 3b)
- Si dice **❌**: No hay token (ve al Paso 3a)

### Paso 3a: Si No Hay Token (❌)
```
1. Cierra DevTools (F12)
2. Ve a /login (o donde esté la página de autenticación)
3. Inicia sesión con tus credenciales
4. Deberías ver un dashboard o confirmación
5. Vuelve a DevTools y verifica que ahora dice ✅
6. Recarga la página de perfil (F5)
```

### Paso 3b: Si Hay Token (✅)
```
1. Ejecuta en la consola:
   localStorage.getItem('user_data') ? 'Hay datos' : 'No hay datos'
   
2. Si dice "Hay datos": Recarga página (F5)
   
3. Si dice "No hay datos":
   - Recarga (F5)
   - Si sigue igual: Contacta admin (API puede estar caída)
```

---

## 🧪 Verificación Visual

Después de seguir los pasos, deberías ver en la página:

### ❌ INCORRECTO (Lo que ves ahora)
```
Encabezado: Sin nombre
Email: No disponible
ID: 34
```

### ✅ CORRECTO (Lo que deberías ver)
```
Encabezado: Juan García (o tu nombre real)
Email: juan@example.com (tu email)
ID: 34
Roles: [estudiante/admin/etc]
```

---

## 🔍 Debugging Visual en Console

Si aún no funciona, mira los logs en la consola. Busca estos emojis:

| Emoji | Significa | Qué Hacer |
|-------|-----------|-----------|
| ✅ | Éxito | Todo está bien |
| ❌ | Error | Algo falló |
| ⚠️ | Advertencia | Usando fallback |
| 🔄 | Cargando | Espera a terminar |
| 📥 | Datos recibidos | Se está procesando |
| 🚨 | ERROR CRÍTICO | Contacta admin |

---

## 📊 En la Consola Deberías Ver

**Si funciona bien:**
```
✅ Starting user data load process...
✅ Token status: ✅ Present
✅ Fetching user data from API...
✅ User data loaded and populated from API
✅ User data population complete: {...}
```

**Si hay problema:**
```
⚠️ No token found, attempting to load from localStorage...
🚨 ERROR STATE: Token no encontrado...
```

---

## 💻 Comandos Útiles

### Ver si hay token:
```javascript
localStorage.getItem('token')
```

### Ver datos del usuario:
```javascript
JSON.parse(localStorage.getItem('user_data'))
```

### Limpiar todo y reiniciar:
```javascript
localStorage.clear();
location.reload();
```

### Copiar token:
```javascript
navigator.clipboard.writeText(localStorage.getItem('token'))
  .then(() => console.log('✅ Token copiado'))
```

---

## 📞 Si Aún No Funciona

Ejecuta en la consola y reporta lo que ves:

```javascript
// 1. Token?
console.log('1. Token:', localStorage.getItem('token') ? 'Sí' : 'No');

// 2. Datos?
console.log('2. Datos:', localStorage.getItem('user_data') ? 'Sí' : 'No');

// 3. Nombre en datos?
try {
  const u = JSON.parse(localStorage.getItem('user_data'));
  console.log('3. Nombre:', u.name + ' ' + u.last_name);
} catch(e) {
  console.log('3. Error al leer datos:', e.message);
}
```

Copia TODO lo que aparece (incluyendo errores) y envía.

---

## ✨ Resumen

```
ANTES      →  SOLUCIÓN     →  RESULTADO
Sin nombre →  Inicia sesión → Nombre real
No disponible →  Recarga página → Email correcto
Error     →  Limpia storage → Todo funciona
```

---

## 🚀 Próximo Paso

Una vez que esté funcionando el perfil:
- [ ] Prueba editar datos (botón "Editar Perfil")
- [ ] Prueba cambiar contraseña
- [ ] Prueba recargar la página (F5)
- [ ] Verifica que datos persisten

---

**¿Preguntas?** Abre DevTools (F12) → Console → Copia logs → Reporta

**¡Éxito! 🎉**
