# 📋 Estado de APIs - Sistema de Gestión Escolar CBTA

## 🔐 Autenticación

| Endpoint | Método | Estado | Descripción |
|----------|--------|--------|-------------|
| `/v1/login` | POST | ✅ **IMPLEMENTADA** | Login y obtener token Sanctum |
| `/user` | GET | ✅ **IMPLEMENTADA** | Obtener usuario actual autenticado |
| `/v1/test-auth` | GET | ✅ **IMPLEMENTADA** | Verificar autenticación y roles |

---

## 👥 Gestión de Usuarios (Admin)

| Endpoint | Método | Estado | Descripción | Permisos |
|----------|--------|--------|-------------|----------|
| `/v1/admin-actions/show-users` | GET | ✅ **IMPLEMENTADA** | Listar todos los usuarios | admin\|financial staff |
| `/v1/admin-actions/register` | POST | ✅ **IMPLEMENTADA** | Crear nuevo usuario | admin\|financial staff |
| `/v1/admin-actions/update-user/{id}` | PUT | ✅ **IMPLEMENTADA** | Actualizar datos de usuario | admin\|financial staff |
| `/v1/admin-actions/delete-user/{id}` | DELETE | ✅ **IMPLEMENTADA** | Eliminar usuario (soft delete) | admin\|financial staff |

### Ejemplos de Uso:

**POST /v1/admin-actions/register**
```json
{
  "name": "Juan",
  "last_name": "Pérez",
  "email": "juan@example.com",
  "password": "password123",
  "phone_number": "1234567890",
  "curp": "PEPJ800101HDFMRR09",
  "gender": "hombre"
}
```

---

## 🎓 Carreras (Modelos Disponibles)

| Campo | Tipo | Notas |
|-------|------|-------|
| id | integer | Primary Key |
| name | string | Nombre de la carrera |
| created_at | timestamp | Fecha de creación |

**⚠️ Estado: FALTA IMPLEMENTAR ENDPOINTS DE CARRERAS**

Se necesitan crear los siguientes endpoints:

```
✗ GET /v1/careers - Listar carreras
✗ POST /v1/careers - Crear carrera
✗ PUT /v1/careers/{id} - Actualizar carrera
✗ DELETE /v1/careers/{id} - Eliminar carrera
```

---

## 📚 Detalles de Estudiante

| Endpoint | Método | Estado | Descripción | Permisos |
|----------|--------|--------|-------------|----------|
| `/v1/admin-actions/get-student/{id}` | GET | ⚠️ **PARCIAL** | Obtener detalles del estudiante | admin\|financial staff |
| `/v1/admin-actions/attach-student` | POST | ⚠️ **PARCIAL** | Asociar detalles al estudiante (crear) | admin\|financial staff |
| `/v1/admin-actions/update-student/{id}` | PATCH | ⚠️ **PARCIAL** | Actualizar detalles del estudiante | admin\|financial staff |

### Modelos de Solicitud/Respuesta:

**Payload POST /v1/admin-actions/attach-student**
```json
{
  "user_id": 1,
  "career_id": 1,
  "n_control": "2023001",
  "semestre": 1,
  "group": "A",
  "workshop": "Taller1"
}
```

**Payload PATCH /v1/admin-actions/update-student/{id}**
```json
{
  "career_id": 1,
  "group": "B",
  "workshop": "Taller2"
}
```

**⚠️ Nota:** Los endpoints PARCIALES existen pero pueden necesitar ajustes en:
- Validaciones
- Estructura de respuesta
- Manejo de errores

---

## 📊 Dashboard para Estudiantes

| Endpoint | Método | Estado | Descripción | Permisos |
|----------|--------|--------|-------------|----------|
| `/v1/dashboard/data` | GET | ✅ **IMPLEMENTADA** | Resumen financiero | student |
| `/v1/dashboard/pending` | GET | ✅ **IMPLEMENTADA** | Conceptos pendientes | student |
| `/v1/dashboard/paid` | GET | ✅ **IMPLEMENTADA** | Conceptos pagados | student |
| `/v1/dashboard/overdue` | GET | ✅ **IMPLEMENTADA** | Conceptos vencidos | student |
| `/v1/dashboard/history` | GET | ✅ **IMPLEMENTADA** | Historial de pagos | student |

---

## 💳 Gestión de Tarjetas de Crédito

| Endpoint | Método | Estado | Descripción | Permisos |
|----------|--------|--------|-------------|----------|
| `/v1/cards/` | GET | ✅ **IMPLEMENTADA** | Listar tarjetas | student |
| `/v1/cards/` | POST | ✅ **IMPLEMENTADA** | Registrar tarjeta | student |
| `/v1/cards/save` | GET | ✅ **IMPLEMENTADA** | Guardar tarjeta | student |
| `/v1/cards/{paymentMethodId}` | DELETE | ✅ **IMPLEMENTADA** | Eliminar tarjeta | student |

---

## 💰 Pagos y Conceptos

| Endpoint | Método | Estado | Descripción | Permisos |
|----------|--------|--------|-------------|----------|
| `/v1/concepts/` | GET | ✅ **IMPLEMENTADA** | Listar conceptos | financial staff |
| `/v1/concepts/` | POST | ✅ **IMPLEMENTADA** | Crear concepto | financial staff |
| `/v1/concepts/{id}` | PUT/PATCH | ✅ **IMPLEMENTADA** | Actualizar concepto | financial staff |
| `/v1/concepts/{id}/finalize` | POST | ✅ **IMPLEMENTADA** | Finalizar concepto | financial staff |
| `/v1/concepts/{id}/disable` | POST | ✅ **IMPLEMENTADA** | Desactivar concepto | financial staff |
| `/v1/concepts/{id}/eliminate` | POST | ✅ **IMPLEMENTADA** | Eliminar concepto | financial staff |
| `/v1/debts/` | GET | ✅ **IMPLEMENTADA** | Listar deudas | financial staff |
| `/v1/debts/validate` | POST | ✅ **IMPLEMENTADA** | Validar deuda | financial staff |
| `/v1/payments/` | GET | ✅ **IMPLEMENTADA** | Listar pagos | financial staff |

---

## 📈 Dashboard para Staff Financiero

| Endpoint | Método | Estado | Descripción | Permisos |
|----------|--------|--------|-------------|----------|
| `/v1/dashboard-staff/data` | GET | ✅ **IMPLEMENTADA** | Overview financiero | financial staff |
| `/v1/dashboard-staff/pending` | GET | ✅ **IMPLEMENTADA** | Pagos pendientes | financial staff |
| `/v1/dashboard-staff/students` | GET | ✅ **IMPLEMENTADA** | Resumen de estudiantes | financial staff |
| `/v1/dashboard-staff/payments` | GET | ✅ **IMPLEMENTADA** | Pagos realizados | financial staff |
| `/v1/dashboard-staff/concepts` | GET | ✅ **IMPLEMENTADA** | Historial de conceptos | financial staff |

---

## 📍 Estudiantes (Staff)

| Endpoint | Método | Estado | Descripción | Permisos |
|----------|--------|--------|-------------|----------|
| `/v1/students/` | GET | ✅ **IMPLEMENTADA** | Listar estudiantes | financial staff |

---

## 🔗 Webhook

| Endpoint | Método | Estado | Descripción |
|----------|--------|--------|-------------|
| `/stripe/webhook` | POST | ✅ **IMPLEMENTADA** | Webhook para eventos de Stripe |

---

## 📋 Resumen General

### ✅ Completamente Implementadas:
- Autenticación (Login, User)
- Gestión de Usuarios (Admin)
- Dashboard para Estudiantes
- Dashboard para Staff Financiero
- Gestión de Tarjetas de Crédito
- Conceptos de Pago
- Deudas y Pagos
- Listado de Estudiantes
- Webhooks de Stripe

### ⚠️ Parcialmente Implementadas:
- Detalles de Estudiante (GET, POST, PATCH) - Existen pero pueden necesitar validación

### ✗ Falta Implementar:
- **Gestión de Carreras (CRUD Completo)**
  - GET /v1/careers
  - POST /v1/careers
  - PUT /v1/careers/{id}
  - DELETE /v1/careers/{id}

---

## 🚀 Próximas Acciones Recomendadas:

1. **Crear endpoints de Carreras** si el frontend los necesita para el crud completo
2. **Validar completamente** los endpoints de detalles de estudiante
3. **Agregar documentación OpenAPI/Swagger** para facilitar uso
4. **Implementar paginación** en GET /v1/students si es necesario
5. **Agregar búsqueda y filtros** en listados

---

## 📌 Notas Importantes:

- Todos los endpoints autenticados requieren token Sanctum en header `Authorization: Bearer {token}`
- La mayoría de endpoints usan validación de permisos con Spatie Permission
- Los roles son: `admin`, `financial staff`, `student`
- Los soft deletes están implementados (no se eliminan físicamente registros)
