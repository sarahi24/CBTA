# 🧪 GUÍA DE TESTING - Página de Perfil

## Checklist de Validación

### ✅ Carga de Datos
- [ ] Al abrir la página, el nombre del usuario se muestra completo (nombre + apellido)
- [ ] Si no hay nombre, muestra "Sin nombre" en lugar de undefined/null
- [ ] El email se muestra correctamente
- [ ] El ID del usuario aparece
- [ ] Los roles se muestran como badges (o está vacío si no tiene)

### ✅ Sección "Datos Personales"
- [ ] Nombre Completo: Muestra el nombre + apellido
- [ ] Correo Electrónico: Muestra el email
- [ ] ID de Usuario: Muestra el ID del usuario

### ✅ Sección "Información de Acceso"
- [ ] Rol Actual: Muestra al menos un rol o "Usuario"
- [ ] Roles Asignados: Lista todos los roles en badges azules
- [ ] Si no hay roles, la sección está vacía
- [ ] Último Acceso: Muestra fecha y hora formateados en español

### ✅ Sección "Permisos"
- [ ] Si tiene permisos, muestra lista con checkmarks verdes
- [ ] Si no tiene permisos, muestra mensaje "No hay permisos asignados"
- [ ] Los permisos se muestran como texto legible

### ✅ Modal Editar Perfil
1. Haz click en "Editar Perfil"
   - [ ] Se abre modal de edición
   - [ ] Todos los campos están pre-poblados con datos actuales
   - [ ] Fechas se muestran en formato YYYY-MM-DD

2. Modifica un campo (ej: teléfono)
   - [ ] El campo se actualiza en tiempo real
   - [ ] No hay errores en la consola

3. Haz click en "Guardar Cambios"
   - [ ] Aparece indicador "Guardando..."
   - [ ] Recibes mensaje de éxito verde
   - [ ] Modal se cierra automáticamente después de 2 segundos
   - [ ] Los cambios aparecen reflejados en la página

4. Intenta guardar con email inválido
   - [ ] Aparece mensaje de error apropiado
   - [ ] Modal se mantiene abierto

### ✅ Modal Cambiar Contraseña
1. Haz click en "Cambiar Contraseña"
   - [ ] Se abre modal de cambio de contraseña
   - [ ] Los campos de contraseña están vacíos

2. Intenta cambiar con contraseña actual incorrecta
   - [ ] Error: "La contraseña actual es incorrecta"
   - [ ] Modal permanece abierto

3. Intenta cambiar con contraseña muy corta
   - [ ] Error: "La contraseña debe tener al menos 8 caracteres"

4. Intenta cambiar con passwords no coincidentes
   - [ ] Error: "Las contraseñas no coinciden"

5. Cambia correctamente
   - [ ] Aparece indicador "Procesando..."
   - [ ] Recibes mensaje de éxito verde
   - [ ] Modal se cierra automáticamente
   - [ ] Puedes volver a iniciar sesión con la nueva contraseña

### ✅ Recarga de Página
1. Carga la página de perfil
   - [ ] Los datos persisten después de recargar
   - [ ] En la consola ves: "✅ User data loaded from [API/localStorage]"

2. Si está offline
   - [ ] Carga datos desde localStorage sin errores
   - [ ] Muestra mensaje de loading mientras intenta desde API

### ✅ Errores y Edge Cases

#### Si no hay token:
- [ ] Debería redirigir a login o mostrar error

#### Si el email ya existe:
- [ ] Muestra error del servidor
- [ ] Modal permanece abierto para reintentar

#### Si hay problema de conexión:
- [ ] Ve mensaje: "Error de conexión con el servidor"
- [ ] Fallback a datos en localStorage

### ✅ Validación en Consola (F12 - Console)
Deberías ver logs como estos:

```
🔄 Fetching user data from API...
📥 API Response: {...}
✅ User data populated successfully: {
  name: "Juan García", 
  email: "juan@example.com",
  id: 1,
  roles: ["student"],
  permissions: 0
}
```

O si usa localStorage:
```
⚠️ No token found, using localStorage fallback
✅ User data loaded from localStorage
```

## Pasos de Testing Completos

### Prueba 1: Flujo Normal
```
1. Inicia sesión → 
2. Ve a Perfil → 
3. Verifica que los datos se cargan → 
4. Haz click en "Editar Perfil" →
5. Cambia un campo →
6. Guarda →
7. Verifica que el cambio aparece →
8. Recarga la página →
9. Verifica que el cambio persiste
```

### Prueba 2: Cambio de Contraseña
```
1. En Perfil, haz click en "Cambiar Contraseña" →
2. Ingresa contraseña actual incorrecta →
3. Intenta guardar → Verifica error →
4. Ingresa contraseña actual correcta →
5. Nueva contraseña de 8 caracteres →
6. Confirma contraseña →
7. Guarda →
8. Recibe confirmación →
9. Intenta iniciar sesión con nueva contraseña
```

### Prueba 3: Validaciones
```
1. Intenta guardar con email vacío → Error
2. Intenta guardar con email inválido → Error
3. Intenta guardar con teléfono vacío → OK (opcional)
4. Intenta cambiar a contraseña muy corta → Error
5. Intenta cambiar con passwords diferentes → Error
```

## URLs de Endpoints Utilizados

| Endpoint | Método | Propósito |
|----------|--------|-----------|
| `/v1/users/user` | GET | Obtener datos del usuario autenticado |
| `/v1/users/update` | PATCH | Actualizar datos del perfil |
| `/v1/users/update/password` | PATCH | Cambiar contraseña |

## Variables de Entorno Base
```
API_BASE_URL = https://nginx-production-728f.up.railway.app/api
```

## Debugging

### Si los datos no cargan:
1. Abre DevTools (F12)
2. Console → Ver logs con 🔄, 📥, ✅, ❌
3. Network → Busca llamadas a `/v1/users/user`
4. Verifica que el token sea válido en localStorage

### Si hay error al guardar:
1. Console → Ver logs con 📤 (envío), 📥 (respuesta)
2. Network → Busca llamada a `/v1/users/update`
3. Verifica que el status sea 200 OK
4. Lee el mensaje de error del servidor

### Si hay problema con permisos:
1. Verifica roles del usuario
2. Si no aparecen permisos, es normal (no todos tienen)
3. Algunos endpoints requieren permisos específicos

## Notas Finales
- Los datos se syncronizan automáticamente con localStorage
- El fallback a localStorage es automático si API falla
- Todos los errores se muestran al usuario en rojo
- Todos los éxitos se muestran al usuario en verde
- Los logs en consola ayudan a entender qué está pasando
