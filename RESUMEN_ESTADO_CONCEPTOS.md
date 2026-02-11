# 📋 RESUMEN: ESTADO DEL SISTEMA DE CONCEPTOS

## ✅ COMPLETADO

### Frontend
- ✅ Interfaz de creación/edición de conceptos
- ✅ Selector de tipo de alcance (Todos, Carrera, Semestre, Carrera+Semestre, Estudiantes, Tags)
- ✅ Badge visual mostrando el tipo de alcance en lista
- ✅ Autocomplete de estudiantes
- ✅ Formulario con validaciones
- ✅ Llamada POST /api/v1/concepts para crear
- ✅ **NUEVO**: Llamada automática PATCH /api/v1/concepts/update-relations/{id} después de crear

### Backend (Según documentación oficial)
- ✅ POST /api/v1/concepts - Crea concepto
- ✅ PATCH /api/v1/concepts/update-relations/{id} - Actualiza relaciones
- ✅ PUT /api/v1/concepts/{id} - Actualiza datos básicos
- ✅ GET /api/v1/concepts - Lista conceptos
- ✅ GET /api/v1/concepts/{id} - Obtiene concepto por ID

---

## ❌ PROBLEMA IDENTIFICADO

### Cuando editas un concepto NO aparecen los datos guardados:

```
✅ Estudiantes específicos: 0  ← DEBERÍA MOSTRAR LOS GUARDADOS
✅ Carreras seleccionadas: []  ← DEBERÍA MOSTRAR LAS GUARDADAS
✅ Semestres seleccionados: []  ← DEBERÍA MOSTRAR LOS GUARDADOS
```

### Causas posibles:

1. **GET /api/v1/concepts/{id} NO devuelve scopeRules**
   - Endpoint devuelve solo datos básicos (nombre, monto, fechas)
   - NO devuelve: careers, semesters, students, applicantTags, applies_to

2. **No existe endpoint para obtener relaciones/scopeRules**
   - Se buscó en estos endpoints (SIN RESULTADO):
     - GET /concepts/{id}/relations → ❌
     - GET /concepts/{id}/scope-rules → ❌
     - GET /payment-concept-scopes?concept_id={id} → ❌

3. **PATCH update-relations tal vez NO está guardando**
   -  Si PATCH no funciona, las relaciones nunca se guardan en la BD

---

## 🎯 ACTION ITEMS PARA ÁNGEL

### Pregunta 1: ¿Dónde cargar los scopeRules?
```
Cuando edito un concepto, necesito cargar los datos guardados:
- ¿Cuál es el endpoint para obtener careers, semestres, students, applicantTags?
- ¿Debería venir en GET /concepts/{id}?
- ¿O existe /concepts/{id}/relations?
```

### Pregunta 2: ¿Funciona PATCH update-relations?
```
Estoy mandando:
POST /concepts → crea concepto (éxito)
PATCH /concepts/update-relations/{id} → guarda relaciones

¿Devuelve error? ¿O guarda correctamente?
¿Puedes verificar en Postman que PATCH funciona?
```

### Pregunta 3: ¿Dónde se guardan las relaciones?
```
Cuando edito concepto ID 52:
- scopes_to = ""  (vacío)
- scopeRules.specificStudents = []  (vacío)

¿Se guardan en tabla separada (payment_concept_scopes)?
¿O en la misma tabla (payment_concepts)?
```

---

## 📤 PAYLOAD ACTUAL

### Al CREAR concepto:
```json
POST /api/v1/concepts
{
  "concept_name": "Estudiantes Específicos1",
  "description": "",
  "status": "activo",
  "amount": 40,
  "start_date": "2026-02-11",
  "end_date": "2026-02-25",
  "is_global": false,
  "applies_to": "estudiantes"
}

LUEGO (si éxito):
PATCH /api/v1/concepts/update-relations/{id}
{
  "applies_to": "estudiantes",
  "students": ["123", "456"],  // IDs de control
  "replaceRelations": true
}
```

---

## 🔧 SIGUIENTE PASO

Una vez resuelta la carga de scopeRules, el formulario de edición mostrará:
- ✅ Las carreras guardadas
- ✅ Los semestres guardados  
- ✅ Los estudiantes guardados
- ✅ Las excepciones guardadas
- ✅ Los tags guardados

---

**Ultima actualización:** 11 de Febrero, 2026
**Estado general:** 80% completado - Bloqueado esperando clarificación del backend
