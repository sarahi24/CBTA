# 📖 Guía Visual: Booleanos de Control en Conceptos

Esta guía explica de forma visual cómo funcionan los tres booleanos de control al editar conceptos.

---

## 🔄 replaceRelations

### ¿Qué hace?
Controla si las nuevas relaciones (carreras/semestres) reemplazan o se agregan a las existentes.

### Visualización

#### Estado Inicial del Concepto
```
┌─────────────────────────────┐
│ Concepto: Inscripción 2025  │
├─────────────────────────────┤
│ Aplica a:                   │
│ • Semestre 1 ✓              │
│ • Semestre 2 ✓              │
└─────────────────────────────┘
```

#### Caso 1: replaceRelations = FALSE (Agregar)
```
📝 Edición:
   Agregar → Semestre 3
   
┌─────────────────────────────┐
│ ☐ Reemplazar Relaciones     │
└─────────────────────────────┘

➡️ RESULTADO:
┌─────────────────────────────┐
│ Concepto: Inscripción 2025  │
├─────────────────────────────┤
│ Aplica a:                   │
│ • Semestre 1 ✓ (anterior)   │
│ • Semestre 2 ✓ (anterior)   │
│ • Semestre 3 ✓ (nuevo)      │
└─────────────────────────────┘
```

#### Caso 2: replaceRelations = TRUE (Reemplazar)
```
📝 Edición:
   Agregar → Semestre 3
   
┌─────────────────────────────┐
│ ☑ Reemplazar Relaciones     │
└─────────────────────────────┘

➡️ RESULTADO:
┌─────────────────────────────┐
│ Concepto: Inscripción 2025  │
├─────────────────────────────┤
│ Aplica a:                   │
│ • Semestre 1 ✗ (eliminado)  │
│ • Semestre 2 ✗ (eliminado)  │
│ • Semestre 3 ✓ (nuevo)      │
└─────────────────────────────┘
```

### 💡 Casos de Uso Comunes

**Agregar (replaceRelations = false):**
- ✅ Expandir el alcance del concepto
- ✅ Agregar más semestres/carreras gradualmente
- ✅ Mantener configuración anterior

**Reemplazar (replaceRelations = true):**
- ✅ Cambiar completamente el alcance
- ✅ Corregir error de configuración anterior
- ✅ Redefinir a qué aplica el concepto

---

## 🚫 replaceExceptions

### ¿Qué hace?
Controla si las nuevas excepciones reemplazan o se agregan a las existentes.

### Visualización

#### Estado Inicial del Concepto
```
┌─────────────────────────────┐
│ Concepto: Colegiatura 2025  │
├─────────────────────────────┤
│ Excepciones:                │
│ • ID 11 (Juan Pérez) ✓      │
│ • ID 88 (María López) ✓     │
└─────────────────────────────┘
```

#### Caso 1: replaceExceptions = FALSE (Agregar)
```
📝 Edición:
   Agregar excepciones → ID 25, ID 90
   
┌─────────────────────────────┐
│ ☐ Reemplazar Excepciones    │
└─────────────────────────────┘

➡️ RESULTADO:
┌─────────────────────────────┐
│ Concepto: Colegiatura 2025  │
├─────────────────────────────┤
│ Excepciones:                │
│ • ID 11 ✓ (anterior)        │
│ • ID 88 ✓ (anterior)        │
│ • ID 25 ✓ (nuevo)           │
│ • ID 90 ✓ (nuevo)           │
└─────────────────────────────┘
```

#### Caso 2: replaceExceptions = TRUE (Reemplazar)
```
📝 Edición:
   Agregar excepciones → ID 25, ID 90
   
┌─────────────────────────────┐
│ ☑ Reemplazar Excepciones    │
└─────────────────────────────┘

➡️ RESULTADO:
┌─────────────────────────────┐
│ Concepto: Colegiatura 2025  │
├─────────────────────────────┤
│ Excepciones:                │
│ • ID 11 ✗ (eliminado)       │
│ • ID 88 ✗ (eliminado)       │
│ • ID 25 ✓ (nuevo)           │
│ • ID 90 ✓ (nuevo)           │
└─────────────────────────────┘
```

### 💡 Casos de Uso Comunes

**Agregar (replaceExceptions = false):**
- ✅ Agregar más estudiantes a excepciones
- ✅ Mantener lista de excepciones anterior
- ✅ Expandir gradualmente las excepciones

**Reemplazar (replaceExceptions = true):**
- ✅ Cambiar completamente la lista de excepciones
- ✅ Corregir errores en excepciones anteriores
- ✅ Redefinir quiénes están exceptuados

---

## ⚠️ removeAllExceptions

### ¿Qué hace?
Elimina TODAS las excepciones existentes del concepto, sin importar cuántas sean.

### Visualización

#### Estado Inicial del Concepto
```
┌─────────────────────────────┐
│ Concepto: Seguro Escolar    │
├─────────────────────────────┤
│ Excepciones:                │
│ • ID 11 ✓                   │
│ • ID 25 ✓                   │
│ • ID 88 ✓                   │
│ • ID 90 ✓                   │
│ • ID 100 ✓                  │
└─────────────────────────────┘
```

#### removeAllExceptions = TRUE
```
📝 Edición:
   
┌─────────────────────────────┐
│ ☑ Eliminar Todas las        │
│   Excepciones               │
│                             │
│ ⚠️ ¡ADVERTENCIA!            │
│ Esta acción eliminará       │
│ TODAS las excepciones       │
└─────────────────────────────┘

➡️ RESULTADO:
┌─────────────────────────────┐
│ Concepto: Seguro Escolar    │
├─────────────────────────────┤
│ Excepciones: NINGUNA        │
│                             │
│ ✅ El concepto ahora aplica │
│    a todos según filtros    │
└─────────────────────────────┘
```

### 💡 Casos de Uso Comunes

**Eliminar todas (removeAllExceptions = true):**
- ✅ Limpiar concepto de excepciones
- ✅ Aplicar concepto universalmente según filtros
- ✅ Corregir configuración incorrecta masiva

### ⚠️ ADVERTENCIA
Esta opción es **DESTRUCTIVA** y **NO SE PUEDE DESHACER** en la sesión actual.
Solo usar cuando estés seguro de eliminar todas las excepciones.

---

## 🔀 Combinación de Booleanos

Los tres booleanos pueden combinarse. Aquí algunos escenarios comunes:

### Escenario 1: Cambiar Todo Desde Cero
```
Estado Inicial:
• Aplica a semestres 1, 2
• Excepciones: ID 11, 88

Edición:
• Agregar semestres: 3, 4
• Agregar excepciones: ID 25, 90
• ☑ replaceRelations = TRUE
• ☑ removeAllExceptions = TRUE
• ☐ replaceExceptions = FALSE (no importa porque se eliminan todas)

Resultado:
• Aplica SOLO a semestres 3, 4
• SIN excepciones (se eliminaron todas)
```

### Escenario 2: Expandir Alcance y Excepciones
```
Estado Inicial:
• Aplica a semestres 1, 2
• Excepciones: ID 11, 88

Edición:
• Agregar semestres: 3, 4
• Agregar excepciones: ID 25
• ☐ replaceRelations = FALSE
• ☐ removeAllExceptions = FALSE
• ☐ replaceExceptions = FALSE

Resultado:
• Aplica a semestres 1, 2, 3, 4 (todos)
• Excepciones: ID 11, 88, 25 (todas)
```

### Escenario 3: Mantener Alcance, Cambiar Excepciones
```
Estado Inicial:
• Aplica a carreras TAG-E, TOF
• Excepciones: ID 11, 88, 90

Edición:
• NO cambiar carreras
• Agregar excepciones: ID 25
• ☐ replaceRelations = FALSE (no importa, no hay cambios)
• ☐ removeAllExceptions = FALSE
• ☑ replaceExceptions = TRUE

Resultado:
• Aplica a carreras TAG-E, TOF (sin cambios)
• Excepciones: SOLO ID 25 (reemplazó anteriores)
```

---

## 📊 Tabla de Decisión Rápida

| Quiero... | replaceRelations | removeAllExceptions | replaceExceptions |
|-----------|-----------------|---------------------|-------------------|
| Agregar semestres/carreras | ☐ FALSE | ☐ FALSE | ☐ FALSE |
| Cambiar completamente alcance | ☑ TRUE | ☐ FALSE | ☐ FALSE |
| Agregar excepciones nuevas | ☐ FALSE | ☐ FALSE | ☐ FALSE |
| Cambiar completamente excepciones | ☐ FALSE | ☐ FALSE | ☑ TRUE |
| Eliminar TODAS las excepciones | (cualquiera) | ☑ TRUE | (cualquiera) |
| Resetear todo (alcance + excepciones) | ☑ TRUE | ☑ TRUE | (cualquiera) |

---

## 🎯 Valores por Defecto Recomendados

Al abrir un concepto en modo edición, los valores por defecto son:

```javascript
{
  replaceRelations: false,       // Agregar sin eliminar
  removeAllExceptions: false,    // Mantener excepciones
  replaceExceptions: false       // Agregar excepciones nuevas
}
```

Esto asegura que por defecto se **agreguen** elementos sin eliminar lo anterior, minimizando el riesgo de pérdida accidental de configuración.

---

## ⚙️ Implementación Técnica

### En el Frontend (new.astro)
```javascript
// Valores iniciales en formData
formData: {
  replaceRelations: false,
  removeAllExceptions: false,
  replaceExceptions: false
}

// Solo se envían en modo edición y alcance restringido
if (this.formData.id && !this.formData.allStudents) {
  payload.replaceRelations = Boolean(this.formData.replaceRelations);
  payload.removeAllExceptions = Boolean(this.formData.removeAllExceptions);
  payload.replaceExceptions = Boolean(this.formData.replaceExceptions);
}
```

### En el API (Backend)
El endpoint `PATCH /v1/concepts/update-relations/{id}` recibe estos booleanos y los procesa:

```php
// Ejemplo de lógica esperada en el backend
if ($data['removeAllExceptions']) {
    // Eliminar TODAS las excepciones
    $concept->exceptionStudents()->detach();
}

if ($data['replaceRelations']) {
    // Reemplazar relaciones (sync en lugar de attach)
    $concept->semesters()->sync($newSemesters);
} else {
    // Agregar relaciones (attach o syncWithoutDetaching)
    $concept->semesters()->syncWithoutDetaching($newSemesters);
}

if ($data['replaceExceptions']) {
    // Reemplazar excepciones
    $concept->exceptionStudents()->sync($newExceptions);
} else {
    // Agregar excepciones
    $concept->exceptionStudents()->syncWithoutDetaching($newExceptions);
}
```

---

## 🧪 Pruebas Recomendadas

### Test 1: Agregar Semestres
```
1. Crear concepto con semestres 1, 2
2. Editar y agregar semestre 3
3. replaceRelations = FALSE
4. Verificar: Ahora tiene semestres 1, 2, 3
```

### Test 2: Reemplazar Semestres
```
1. Crear concepto con semestres 1, 2
2. Editar y agregar semestre 3
3. replaceRelations = TRUE
4. Verificar: Ahora SOLO tiene semestre 3
```

### Test 3: Eliminar Todas las Excepciones
```
1. Crear concepto con excepciones ID 11, 88
2. Editar y activar removeAllExceptions = TRUE
3. Guardar
4. Verificar: Concepto NO tiene excepciones
```

### Test 4: Reemplazar Excepciones
```
1. Crear concepto con excepciones ID 11, 88
2. Editar y agregar excepciones ID 25, 90
3. replaceExceptions = TRUE
4. Verificar: Ahora SOLO tiene excepciones ID 25, 90
```

---

**Recuerda:**
- Estos booleanos SOLO están disponibles en **modo edición**
- SOLO se muestran cuando el alcance es **"Alcance Restringido"**
- Los valores por defecto son **FALSE** para minimizar cambios accidentales
- Las descripciones y ejemplos están visibles en la interfaz para guiar al usuario

---

**Fecha:** 10 de febrero de 2026  
**Autor:** GitHub Copilot  
**Archivo relacionado:** `Frond-end/src/pages/new.astro`
