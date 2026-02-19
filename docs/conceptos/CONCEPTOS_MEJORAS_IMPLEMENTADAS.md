# 📋 Mejoras Implementadas en Gestión de Conceptos

## 🎯 Resumen de Cambios

Se han implementado mejoras significativas en la página de creación/edición de conceptos de pago para cumplir con los requisitos del API y mejorar la experiencia del usuario.

---

## ✨ Nuevas Funcionalidades Implementadas

### 1️⃣ **Ocultación de Filtros en "Matrícula Completa"**

**Problema anterior:**
- Los filtros (carreras, semestres, estudiantes específicos) se mostraban incluso cuando se seleccionaba "Matrícula Completa"
- Esto podía causar confusión y que los usuarios intentaran crear conceptos con filtros que no funcionarían

**Solución implementada:**
- Los filtros de alcance restringido (carreras, semestres, estudiantes) SOLO se muestran cuando se selecciona "Alcance Restringido"
- Cuando se selecciona "Matrícula Completa", estos campos se ocultan completamente
- Los campos también se excluyen explícitamente del payload enviado al backend

**Ubicación en el código:**
- Archivo: `Frond-end/src/pages/new.astro`
- Líneas: ~297-340 (lógica de payload)
- Líneas: ~710-850 (sección de filtros con `x-show="!formData.allStudents"`)

---

### 2️⃣ **Gestión de Excepciones de Estudiantes**

**Nueva funcionalidad:**
- Permite definir estudiantes que **NO** deben recibir el concepto, incluso si cumplen con los filtros
- Útil para casos especiales donde un grupo debe aplicar excepto ciertos alumnos

**Características:**
- Búsqueda de estudiantes por nombre o matrícula
- Visualización de excepciones seleccionadas con badges
- Solo disponible en alcance restringido
- Los datos se envían en el campo `exceptionStudents` como array de IDs

**Campos agregados:**
```javascript
formData: {
  exceptionStudents: [],        // Array de objetos {id, name, control}
  searchTermException: '',      // Término de búsqueda para excepciones
  // ...otros campos
}
```

**Ubicación en el código:**
- Líneas: ~860-920 (nueva sección visual)
- Método: `toggleExceptionStudent()` 
- Método: `removeExceptionStudent()`
- Getter: `filteredExceptionStudents()`

---

### 3️⃣ **Etiquetas de Aplicación (Applicant Tags)**

**Nueva funcionalidad:**
- Define a qué tipo de usuarios aplica el concepto
- Actualmente soporta: "applicants" (Aplicantes/Aspirantes)
- Extensible para agregar más categorías en el futuro

**Campo agregado:**
```javascript
formData: {
  applicantTags: 'applicants',  // String con el tipo de aplicante
  // ...otros campos
}
```

**Ubicación en el código:**
- Líneas: ~922-940 (selector de tags)
- Se envía en el payload cuando está en alcance restringido

---

### 4️⃣ **Opciones de Actualización (Modo Edición)**

**Nuevos controles booleanos:**
Estos campos solo aparecen cuando se está **editando** un concepto existente y en **alcance restringido**.

#### a) **Reemplazar Relaciones** (`replaceRelations`)
- **Activo (true):** Reemplaza completamente las relaciones existentes
- **Inactivo (false):** Agrega las nuevas relaciones sin eliminar las anteriores

**Ejemplo:**
```
Concepto actual: aplica a semestres 1 y 2
Al editar se agregan: semestre 3

• Con replaceRelations = true:  → Solo aplicará al semestre 3
• Con replaceRelations = false: → Aplicará a semestres 1, 2 y 3
```

#### b) **Eliminar Todas las Excepciones** (`removeAllExceptions`)
- **Activo (true):** Elimina TODAS las excepciones existentes
- **Inactivo (false):** Mantiene las excepciones anteriores

**Advertencia:** Esta acción es irreversible en la sesión de edición actual.

#### c) **Reemplazar Excepciones** (`replaceExceptions`)
- **Activo (true):** Reemplaza las excepciones existentes con las nuevas
- **Inactivo (false):** Agrega las nuevas excepciones sin eliminar las anteriores

**Campos agregados:**
```javascript
formData: {
  replaceRelations: false,      // Boolean
  removeAllExceptions: false,   // Boolean
  replaceExceptions: false,     // Boolean
  // ...otros campos
}
```

**Ubicación en el código:**
- Líneas: ~942-1030 (sección de opciones de actualización)
- Solo visible cuando `formData.id` existe (modo edición)

---

## 🔧 Cambios Técnicos en el Código

### Modificaciones en el FormData
```javascript
formData: {
  // Campos originales
  id: null,
  title: '',
  amount: 0,
  description: '',
  status: 'active',
  startDate: '',
  endDate: '',
  allStudents: true,
  selectedCareers: [],
  selectedSemesters: [],
  selectedSpecificStudents: [],
  
  // ✨ NUEVOS CAMPOS
  exceptionStudents: [],          // Excepciones
  applicantTags: 'applicants',    // Tags de aplicantes
  replaceRelations: false,        // Booleano de control
  removeAllExceptions: false,     // Booleano de control
  replaceExceptions: false        // Booleano de control
}
```

### Nuevos Métodos Agregados
```javascript
// Gestión de excepciones
toggleExceptionStudent(student)     // Agrega/quita estudiante de excepciones
removeExceptionStudent(studentId)   // Elimina excepción específica

// Getter para búsqueda de excepciones
get filteredExceptionStudents()     // Filtra estudiantes para excepciones
```

### Modificaciones en el Payload del API

#### Para Creación (POST /v1/concepts):
```javascript
{
  concept_name: "...",
  description: "...",
  status: "activo",
  amount: 1500.00,
  start_date: "2025-01-15",
  end_date: "2025-03-01",
  is_global: false,
  applies_to: "carrera_semestre",
  careers: ["TAG-E", "TOF"],
  semestres: [1, 2],
  
  // ✨ NUEVOS CAMPOS (solo si aplica)
  exceptionStudents: ["13", "25", "89"],  // IDs de excepciones
  applicantTags: "applicants"              // Tags de aplicantes
}
```

#### Para Actualización de Relaciones (PATCH /v1/concepts/update-relations/{id}):
```javascript
{
  applies_to: "semestre",
  semestres: [3, 4],
  
  // ✨ NUEVOS CAMPOS
  exceptionStudents: ["11", "88", "90"],
  applicantTags: "applicants",
  replaceRelations: true,       // Reemplaza relaciones anteriores
  removeAllExceptions: false,   // No elimina excepciones anteriores
  replaceExceptions: false      // Agrega nuevas excepciones
}
```

---

## 🎨 Cambios Visuales en la Interfaz

### Nueva Sección: "Excepciones y Etiquetas Especiales"
- **Color temático:** Naranja/Rojo para advertencias
- **Icono:** `fa-user-slash` y `fa-ban`
- **Ubicación:** Entre "Reglas de Aplicación" y "Estado y Aplicación"
- **Condición de visualización:** Solo en alcance restringido

### Nueva Sección: "Opciones de Actualización"
- **Color temático:** Amarillo (advertencias)
- **Icono:** `fa-sync-alt`
- **Ubicación:** Entre "Excepciones" y "Estado y Aplicación"
- **Condición de visualización:** Solo en modo edición Y alcance restringido

---

## 📊 Flujo de Datos

### Creación de Concepto (Nuevo)
```
1. Usuario completa el formulario
2. Selecciona alcance (Completo o Restringido)
3. Si Restringido:
   - Selecciona filtros (carreras/semestres/estudiantes)
   - Opcionalmente agrega excepciones
   - Opcionalmente selecciona tags de aplicantes
4. submitForm() construye payload
5. POST /v1/concepts con todos los datos
```

### Edición de Concepto (Existente)
```
1. localStorage carga concepto al abrir la página
2. populateForm() llena todos los campos (incluyendo nuevos)
3. Usuario modifica datos
4. Si cambió el alcance:
   - Muestra/oculta secciones según corresponda
5. Si modo edición + alcance restringido:
   - Muestra opciones de actualización booleanas
6. submitForm() separa en dos peticiones:
   a) PUT /v1/concepts/{id} - Datos básicos
   b) PATCH /v1/concepts/update-relations/{id} - Relaciones + nuevos campos
```

---

## ✅ Validaciones Implementadas

### Validación en el Frontend
- ✅ Título y monto son obligatorios
- ✅ Fechas de inicio y fin son obligatorias
- ✅ En alcance restringido, al menos un filtro debe estar seleccionado
- ✅ Los campos de excepciones y tags solo se envían cuando corresponde
- ✅ Los booleanos de control solo se envían en modo edición

### Exclusión de Campos según Contexto
```javascript
// Si allStudents = true
delete payload.students;
delete payload.careers;
delete payload.semestres;
delete payload.exceptionStudents;
delete payload.applicantTags;
delete payload.replaceRelations;
delete payload.removeAllExceptions;
delete payload.replaceExceptions;
```

---

## 🧪 Casos de Prueba Sugeridos

### Caso 1: Crear Concepto con Matrícula Completa
1. Crear nuevo concepto
2. Seleccionar "Matrícula Completa"
3. **Verificar:** Los filtros NO deben ser visibles
4. Guardar
5. **Esperado:** Payload sin campos de filtro

### Caso 2: Crear Concepto con Excepciones
1. Crear nuevo concepto
2. Seleccionar "Alcance Restringido"
3. Seleccionar carreras/semestres
4. Agregar excepciones de estudiantes
5. Guardar
6. **Esperado:** Payload incluye `exceptionStudents` array

### Caso 3: Editar Concepto - Reemplazar Relaciones
1. Abrir concepto existente que aplica a semestres 1 y 2
2. Agregar semestre 3
3. Activar "Reemplazar Relaciones"
4. Guardar
5. **Esperado:** Concepto ahora solo aplica al semestre 3

### Caso 4: Editar Concepto - Agregar Relaciones
1. Abrir concepto existente que aplica a semestres 1 y 2
2. Agregar semestre 3
3. NO activar "Reemplazar Relaciones"
4. Guardar
5. **Esperado:** Concepto aplica a semestres 1, 2 y 3

### Caso 5: Editar Concepto - Eliminar Todas las Excepciones
1. Abrir concepto con excepciones existentes
2. Activar "Eliminar Todas las Excepciones"
3. Guardar
4. **Esperado:** Se eliminan todas las excepciones anteriores

---

## 📝 Documentación de la API

Según la documentación en: `https://nginx-production-728f.up.railway.app/api/documentation`

Los schemas completos están disponibles en la sección "Schemas" al final de la documentación de la API.

### Endpoints Utilizados

#### POST `/api/v1/concepts`
Crea un nuevo concepto con todos los campos en una sola petición.

#### PUT `/api/v1/concepts/{id}`
Actualiza los datos básicos del concepto (nombre, descripción, monto, fechas, estado).

#### PATCH `/api/v1/concepts/update-relations/{id}`
Actualiza las relaciones del concepto (carreras, semestres, estudiantes, excepciones, tags, booleanos de control).

---

## 🚀 Beneficios de las Mejoras

1. **Mejor UX:** Los usuarios no ven opciones que no pueden usar
2. **Prevención de errores:** Evita que se intenten crear conceptos con filtros inválidos
3. **Flexibilidad:** Permite manejar excepciones y casos especiales
4. **Control granular:** Los booleanos permiten decidir cómo actualizar relaciones
5. **Extensibilidad:** La estructura de tags permite agregar más categorías fácilmente
6. **Claridad:** Descripciones y ejemplos en la interfaz explican el comportamiento

---

## 🔄 Próximos Pasos Sugeridos

1. **Testing exhaustivo** de todos los casos de uso
2. **Validar con el backend** que los campos se reciben correctamente
3. **Documentar respuestas** del API para manejo de errores específicos
4. **Agregar más tags** de aplicantes si se requieren (ej: "regulares", "irregulares", etc.)
5. **Considerar feedback** de usuarios finales para mejoras adicionales

---

## 📞 Soporte

Para dudas sobre la implementación o el API, consultar:
- Documentación del API: https://nginx-production-728f.up.railway.app/api/documentation
- Sección de Schemas al final de la documentación
- Archivo modificado: `Frond-end/src/pages/new.astro`

---

**Fecha de implementación:** 10 de febrero de 2026  
**Desarrollador:** GitHub Copilot con Claude Sonnet 4.5  
**Estado:** ✅ Implementado y listo para testing
