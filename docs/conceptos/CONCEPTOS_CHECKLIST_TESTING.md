# ✅ Checklist de Testing - Mejoras en Conceptos

## 📋 Pre-requisitos

- [ ] Backend actualizado con endpoints que soporten los nuevos campos
- [ ] Token de acceso válido (access_token)
- [ ] Al menos 10 estudiantes en el sistema para pruebas
- [ ] Al menos 2 carreras configuradas
- [ ] Navegador con DevTools disponible para revisar Network

---

## 🧪 Pruebas de Creación de Conceptos

### Test 1: Crear Concepto - Matrícula Completa
**Objetivo:** Verificar que los filtros NO se muestran ni se envían

- [ ] Abrir `/new` (crear nuevo concepto)
- [ ] Completar campos básicos (título, monto, fechas)
- [ ] Seleccionar "Matrícula Completa"
- [ ] **VERIFICAR:** Sección de filtros (carreras/semestres) NO es visible
- [ ] **VERIFICAR:** Sección de excepciones NO es visible
- [ ] **VERIFICAR:** Sección de tags NO es visible
- [ ] Abrir DevTools > Network
- [ ] Guardar concepto
- [ ] **VERIFICAR en Network:** Payload NO contiene:
  - [ ] `students`
  - [ ] `careers`
  - [ ] `semestres`
  - [ ] `exceptionStudents`
  - [ ] `applicantTags`
  - [ ] `replaceRelations`
  - [ ] `removeAllExceptions`
  - [ ] `replaceExceptions`
- [ ] **VERIFICAR:** Concepto creado exitosamente
- [ ] **VERIFICAR:** Aplica a todos los estudiantes

**Resultado esperado:** ✅ Concepto creado con `applies_to: "todos"`, sin campos de filtro

---

### Test 2: Crear Concepto - Alcance Restringido (Solo Semestres)
**Objetivo:** Verificar creación con filtros de semestres

- [ ] Abrir `/new`
- [ ] Completar campos básicos
- [ ] Seleccionar "Alcance Restringido"
- [ ] **VERIFICAR:** Sección de filtros ES visible
- [ ] Seleccionar semestres 1 y 2
- [ ] NO seleccionar carreras
- [ ] NO agregar estudiantes específicos
- [ ] Abrir DevTools > Network
- [ ] Guardar
- [ ] **VERIFICAR en Network:** Payload contiene:
  - [ ] `applies_to: "semestre"`
  - [ ] `semestres: [1, 2]`
  - [ ] NO contiene `careers`
  - [ ] NO contiene `students`
- [ ] **VERIFICAR:** Concepto creado exitosamente

**Resultado esperado:** ✅ Concepto aplica solo a semestres 1 y 2

---

### Test 3: Crear Concepto - Con Excepciones
**Objetivo:** Verificar que las excepciones se envían correctamente

- [ ] Abrir `/new`
- [ ] Completar campos básicos
- [ ] Seleccionar "Alcance Restringido"
- [ ] Seleccionar al menos una carrera o semestre
- [ ] **VERIFICAR:** Sección "Excepciones y Etiquetas Especiales" ES visible
- [ ] Buscar un estudiante en el campo de excepciones
- [ ] Agregar 3 estudiantes como excepciones
- [ ] **VERIFICAR:** Los 3 estudiantes aparecen como badges
- [ ] Abrir DevTools > Network
- [ ] Guardar
- [ ] **VERIFICAR en Network:** Payload contiene:
  - [ ] `exceptionStudents: ["id1", "id2", "id3"]`
  - [ ] Los IDs corresponden a los estudiantes seleccionados
- [ ] **VERIFICAR:** Concepto creado exitosamente
- [ ] **VERIFICAR:** Los estudiantes exceptuados NO reciben el concepto

**Resultado esperado:** ✅ Concepto creado con excepciones funcionando

---

### Test 4: Crear Concepto - Con Tags de Aplicantes
**Objetivo:** Verificar que los tags se envían correctamente

- [ ] Abrir `/new`
- [ ] Completar campos básicos
- [ ] Seleccionar "Alcance Restringido"
- [ ] Seleccionar filtros (carrera o semestre)
- [ ] Verificar que tag "Aplicantes/Aspirantes" está seleccionado por defecto
- [ ] Abrir DevTools > Network
- [ ] Guardar
- [ ] **VERIFICAR en Network:** Payload contiene:
  - [ ] `applicantTags: "applicants"`
- [ ] **VERIFICAR:** Concepto creado exitosamente

**Resultado esperado:** ✅ Concepto creado con tags de aplicantes

---

## 🔄 Pruebas de Edición de Conceptos

### Test 5: Editar - Cambiar de Matrícula Completa a Restringido
**Objetivo:** Verificar transición correcta de alcances

- [ ] Crear concepto con "Matrícula Completa"
- [ ] Ir a `/concepts` y hacer clic en "Editar"
- [ ] **VERIFICAR:** Formulario muestra "Matrícula Completa" seleccionado
- [ ] **VERIFICAR:** Sección de filtros NO es visible
- [ ] Cambiar a "Alcance Restringido"
- [ ] **VERIFICAR:** Sección de filtros SE MUESTRA
- [ ] **VERIFICAR:** Sección de excepciones SE MUESTRA
- [ ] **VERIFICAR:** Sección "Opciones de Actualización" SE MUESTRA
- [ ] Seleccionar carrera y semestre
- [ ] Guardar
- [ ] **VERIFICAR:** Concepto actualizado correctamente

**Resultado esperado:** ✅ Concepto cambia de alcance completo a restringido

---

### Test 6: Editar - Agregar Relaciones (replaceRelations = FALSE)
**Objetivo:** Verificar que nuevas relaciones se AGREGAN sin eliminar anteriores

**Preparación:**
- [ ] Crear concepto con semestres 1 y 2

**Prueba:**
- [ ] Editar el concepto
- [ ] **VERIFICAR:** Semestres 1 y 2 están marcados
- [ ] Marcar también semestre 3
- [ ] **VERIFICAR:** Sección "Opciones de Actualización" ES visible
- [ ] **VERIFICAR:** "Reemplazar Relaciones" NO está activado (☐)
- [ ] Abrir DevTools > Network
- [ ] Guardar
- [ ] **VERIFICAR en Network (PATCH update-relations):** Payload contiene:
  - [ ] `replaceRelations: false`
  - [ ] `semestres: [1, 2, 3]` o `[3]` (depende de implementación backend)
- [ ] Recargar página de conceptos
- [ ] Editar de nuevo el concepto
- [ ] **VERIFICAR:** Semestres 1, 2 Y 3 están marcados

**Resultado esperado:** ✅ Concepto tiene semestres 1, 2 y 3 (agregado sin reemplazar)

---

### Test 7: Editar - Reemplazar Relaciones (replaceRelations = TRUE)
**Objetivo:** Verificar que nuevas relaciones REEMPLAZAN a las anteriores

**Preparación:**
- [ ] Crear concepto con semestres 1 y 2

**Prueba:**
- [ ] Editar el concepto
- [ ] **VERIFICAR:** Semestres 1 y 2 están marcados
- [ ] DESMARCAR semestres 1 y 2
- [ ] Marcar semestre 3
- [ ] **ACTIVAR** checkbox "Reemplazar Relaciones" (☑)
- [ ] **VERIFICAR:** Descripción del checkbox explica el comportamiento
- [ ] Abrir DevTools > Network
- [ ] Guardar
- [ ] **VERIFICAR en Network (PATCH update-relations):** Payload contiene:
  - [ ] `replaceRelations: true`
  - [ ] `semestres: [3]`
- [ ] Recargar página de conceptos
- [ ] Editar de nuevo el concepto
- [ ] **VERIFICAR:** SOLO semestre 3 está marcado
- [ ] **VERIFICAR:** Semestres 1 y 2 NO están marcados

**Resultado esperado:** ✅ Concepto SOLO tiene semestre 3 (reemplazó anteriores)

---

### Test 8: Editar - Agregar Excepciones (replaceExceptions = FALSE)
**Objetivo:** Verificar que nuevas excepciones se AGREGAN

**Preparación:**
- [ ] Crear concepto con alcance restringido
- [ ] Agregar 2 excepciones: ID 11, ID 88

**Prueba:**
- [ ] Editar el concepto
- [ ] **VERIFICAR:** Las 2 excepciones aparecen como badges
- [ ] Agregar 2 excepciones más: ID 25, ID 90
- [ ] **VERIFICAR:** "Reemplazar Excepciones" NO está activado (☐)
- [ ] Abrir DevTools > Network
- [ ] Guardar
- [ ] **VERIFICAR en Network:** Payload contiene:
  - [ ] `replaceExceptions: false`
  - [ ] `exceptionStudents: ["11", "88", "25", "90"]` o `["25", "90"]`
- [ ] Recargar y editar de nuevo
- [ ] **VERIFICAR:** Las 4 excepciones están presentes

**Resultado esperado:** ✅ Concepto tiene 4 excepciones (agregadas)

---

### Test 9: Editar - Reemplazar Excepciones (replaceExceptions = TRUE)
**Objetivo:** Verificar que nuevas excepciones REEMPLAZAN a las anteriores

**Preparación:**
- [ ] Crear concepto con excepciones: ID 11, ID 88

**Prueba:**
- [ ] Editar el concepto
- [ ] **VERIFICAR:** Excepciones ID 11, 88 aparecen
- [ ] Eliminar las excepciones anteriores (hacer clic en X)
- [ ] Agregar nuevas excepciones: ID 25, ID 90
- [ ] **ACTIVAR** checkbox "Reemplazar Excepciones" (☑)
- [ ] Abrir DevTools > Network
- [ ] Guardar
- [ ] **VERIFICAR en Network:** Payload contiene:
  - [ ] `replaceExceptions: true`
  - [ ] `exceptionStudents: ["25", "90"]`
- [ ] Recargar y editar de nuevo
- [ ] **VERIFICAR:** SOLO excepciones ID 25, 90 están presentes
- [ ] **VERIFICAR:** Excepciones ID 11, 88 NO están

**Resultado esperado:** ✅ Concepto SOLO tiene excepciones nuevas (reemplazó)

---

### Test 10: Editar - Eliminar Todas las Excepciones
**Objetivo:** Verificar que removeAllExceptions elimina todas

**Preparación:**
- [ ] Crear concepto con 5 excepciones

**Prueba:**
- [ ] Editar el concepto
- [ ] **VERIFICAR:** Las 5 excepciones aparecen
- [ ] **ACTIVAR** checkbox "Eliminar Todas las Excepciones" (☑)
- [ ] **VERIFICAR:** Mensaje de advertencia visible
- [ ] Abrir DevTools > Network
- [ ] Guardar
- [ ] **VERIFICAR en Network:** Payload contiene:
  - [ ] `removeAllExceptions: true`
- [ ] Recargar y editar de nuevo
- [ ] **VERIFICAR:** NO hay excepciones en el concepto

**Resultado esperado:** ✅ Todas las excepciones fueron eliminadas

---

## 🎨 Pruebas de Interfaz Visual

### Test 11: Visibilidad Condicional - Matrícula Completa
- [ ] Crear concepto, seleccionar "Matrícula Completa"
- [ ] **VERIFICAR:** Sección de filtros NO visible
- [ ] **VERIFICAR:** Sección de excepciones NO visible
- [ ] **VERIFICAR:** Sección de tags NO visible
- [ ] **VERIFICAR:** Sección "Opciones de Actualización" NO visible
- [ ] Cambiar a "Alcance Restringido"
- [ ] **VERIFICAR:** Sección de filtros SE MUESTRA
- [ ] **VERIFICAR:** Sección de excepciones SE MUESTRA
- [ ] **VERIFICAR:** Sección de tags SE MUESTRA

**Resultado esperado:** ✅ Visibilidad condicional funciona correctamente

---

### Test 12: Visibilidad Condicional - Opciones de Actualización
- [ ] Crear concepto nuevo con alcance restringido
- [ ] **VERIFICAR:** Sección "Opciones de Actualización" NO visible (no es edición)
- [ ] Guardar concepto
- [ ] Editar el concepto
- [ ] **VERIFICAR:** Sección "Opciones de Actualización" ES visible (modo edición)
- [ ] Cambiar a "Matrícula Completa"
- [ ] **VERIFICAR:** Sección "Opciones de Actualización" NO visible
- [ ] Cambiar a "Alcance Restringido"
- [ ] **VERIFICAR:** Sección "Opciones de Actualización" ES visible

**Resultado esperado:** ✅ Opciones solo visibles en edición + alcance restringido

---

### Test 13: Búsqueda de Estudiantes para Excepciones
- [ ] Crear concepto con alcance restringido
- [ ] Ir a sección de excepciones
- [ ] Escribir nombre parcial de estudiante en búsqueda
- [ ] **VERIFICAR:** Dropdown aparece con resultados
- [ ] **VERIFICAR:** Máximo 8 resultados mostrados
- [ ] Hacer clic en un estudiante
- [ ] **VERIFICAR:** Dropdown se cierra
- [ ] **VERIFICAR:** Estudiante aparece como badge
- [ ] **VERIFICAR:** Campo de búsqueda se limpia
- [ ] Hacer clic en X del badge
- [ ] **VERIFICAR:** Estudiante se elimina de excepciones

**Resultado esperado:** ✅ Búsqueda y selección funcionan correctamente

---

### Test 14: Descripciones y Tooltips
- [ ] Editar concepto con alcance restringido
- [ ] **VERIFICAR:** Checkbox "Reemplazar Relaciones" tiene descripción clara
- [ ] **VERIFICAR:** Descripción incluye ejemplo con semestres
- [ ] **VERIFICAR:** Checkbox "Eliminar Todas las Excepciones" tiene advertencia visible
- [ ] **VERIFICAR:** Checkbox "Reemplazar Excepciones" tiene descripción clara
- [ ] **VERIFICAR:** Todos los textos son legibles y comprensibles

**Resultado esperado:** ✅ Todas las descripciones son claras y útiles

---

## 🔌 Pruebas de Integración con Backend

### Test 15: Verificar Respuesta del API en Creación
- [ ] Crear concepto con todos los campos nuevos
- [ ] Abrir DevTools > Network > POST /v1/concepts
- [ ] **VERIFICAR:** Status Code 201 Created
- [ ] **VERIFICAR:** Respuesta incluye:
  - [ ] `success: true`
  - [ ] `data` con el concepto creado
  - [ ] Campo `id` del nuevo concepto
- [ ] **VERIFICAR en base de datos (si es posible):**
  - [ ] Excepciones se guardaron correctamente
  - [ ] Tags se guardaron correctamente

**Resultado esperado:** ✅ Backend procesa correctamente todos los campos

---

### Test 16: Verificar Respuesta del API en Actualización
- [ ] Editar concepto existente
- [ ] Modificar relaciones con booleanos
- [ ] Abrir DevTools > Network
- [ ] Guardar
- [ ] **VERIFICAR:** 2 peticiones:
  - [ ] PUT /v1/concepts/{id} (datos básicos) - Status 200
  - [ ] PATCH /v1/concepts/update-relations/{id} - Status 200
- [ ] **VERIFICAR:** Ambas respuestas incluyen `success: true`
- [ ] **VERIFICAR:** Los cambios se reflejan al recargar

**Resultado esperado:** ✅ Actualización en dos pasos funciona correctamente

---

## 🚨 Pruebas de Validación y Errores

### Test 17: Validación - Campos Obligatorios
- [ ] Intentar guardar concepto sin título
- [ ] **VERIFICAR:** Mensaje de error aparece
- [ ] Intentar guardar sin monto
- [ ] **VERIFICAR:** Mensaje de error aparece
- [ ] Intentar guardar sin fechas
- [ ] **VERIFICAR:** Mensaje de error aparece

**Resultado esperado:** ✅ Validaciones funcionan correctamente

---

### Test 18: Validación - Alcance Restringido Sin Filtros
- [ ] Seleccionar "Alcance Restringido"
- [ ] NO seleccionar ningún filtro (ni carrera, ni semestre, ni estudiante)
- [ ] Intentar guardar
- [ ] **VERIFICAR:** Mensaje de error: "Seleccione al menos una Carrera, Semestre o Alumno"

**Resultado esperado:** ✅ No permite guardar alcance restringido sin filtros

---

### Test 19: Manejo de Errores del Backend
- [ ] Provocar un error del backend (ej: token inválido)
- [ ] **VERIFICAR:** Mensaje de error claro aparece
- [ ] **VERIFICAR:** Mensaje incluye detalles del error
- [ ] **VERIFICAR:** Usuario puede corregir y reintentar

**Resultado esperado:** ✅ Errores del backend se manejan correctamente

---

## 📊 Pruebas con Scripts PowerShell

### Test 20: Script de Creación con Excepciones
- [ ] Ejecutar `.\test-create-concept-with-exceptions.ps1`
- [ ] Ingresar token válido
- [ ] Confirmar envío
- [ ] **VERIFICAR:** Script muestra payload antes de enviar
- [ ] **VERIFICAR:** Respuesta exitosa del API
- [ ] **VERIFICAR:** Concepto creado correctamente
- [ ] Verificar en interfaz web que concepto existe

**Resultado esperado:** ✅ Script crea concepto correctamente

---

### Test 21: Script de Actualización con Booleanos
- [ ] Crear un concepto con semestres 1, 2
- [ ] Ejecutar `.\test-update-relations-with-booleans.ps1`
- [ ] Ingresar token e ID del concepto
- [ ] Seleccionar opción 1 (Agregar)
- [ ] **VERIFICAR:** Script muestra payload
- [ ] **VERIFICAR:** Respuesta exitosa
- [ ] **VERIFICAR:** Concepto tiene semestres 1, 2, 3
- [ ] Ejecutar script de nuevo con opción 2 (Reemplazar)
- [ ] **VERIFICAR:** Concepto SOLO tiene los nuevos semestres

**Resultado esperado:** ✅ Script actualiza relaciones correctamente

---

## ✅ Resumen Final

### Pruebas de Creación
- [ ] Test 1: Matrícula Completa
- [ ] Test 2: Alcance Restringido
- [ ] Test 3: Con Excepciones
- [ ] Test 4: Con Tags

### Pruebas de Edición
- [ ] Test 5: Cambio de Alcance
- [ ] Test 6: Agregar Relaciones
- [ ] Test 7: Reemplazar Relaciones
- [ ] Test 8: Agregar Excepciones
- [ ] Test 9: Reemplazar Excepciones
- [ ] Test 10: Eliminar Todas Excepciones

### Pruebas de Interfaz
- [ ] Test 11: Visibilidad - Matrícula Completa
- [ ] Test 12: Visibilidad - Opciones Actualización
- [ ] Test 13: Búsqueda de Estudiantes
- [ ] Test 14: Descripciones

### Pruebas de Integración
- [ ] Test 15: API Creación
- [ ] Test 16: API Actualización

### Pruebas de Validación
- [ ] Test 17: Campos Obligatorios
- [ ] Test 18: Alcance Sin Filtros
- [ ] Test 19: Errores Backend

### Pruebas con Scripts
- [ ] Test 20: Script Creación
- [ ] Test 21: Script Actualización

---

## 📝 Notas de Testing

**Fecha inicio:** ___________  
**Fecha fin:** ___________  
**Tester:** ___________  
**Notas adicionales:**
```
[Espacio para anotaciones durante las pruebas]
```

---

**Bugs encontrados:**
1. 
2. 
3. 

**Mejoras sugeridas:**
1. 
2. 
3. 

---

**Estado Final:** [ ] Aprobado  [ ] Requiere cambios  [ ] Rechazado
