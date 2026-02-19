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
| `/v1/admin-actions/show-users/{id}` | GET | ✅ **IMPLEMENTADA** | Obtener datos extra del usuario | admin\|financial staff |
| `/v1/admin-actions/register` | POST | ✅ **IMPLEMENTADA** | Crear nuevo usuario | admin\|financial staff |
| `/v1/admin-actions/update-user/{id}` | PUT | ✅ **IMPLEMENTADA** | Actualizar datos de usuario | admin\|financial staff |
| `/v1/admin-actions/delete-user/{id}` | DELETE | ✅ **IMPLEMENTADA** | Eliminar usuario (soft delete) | admin\|financial staff |
| `/v1/admin-actions/delete-users` | POST | ✅ **IMPLEMENTADA** | Eliminar múltiples usuarios | admin\|supervisor |
| `/v1/admin-actions/activate-users` | POST | ✅ **IMPLEMENTADA** | Activar múltiples usuarios | admin\|supervisor |
| `/v1/admin-actions/disable-users` | POST | ✅ **IMPLEMENTADA** | Desactivar múltiples usuarios | admin\|supervisor |
| `/v1/admin-actions/temporary-disable-users` | POST | ✅ **IMPLEMENTADA** | Desactivar temporal múltiples usuarios | admin\|supervisor |
| `/v1/admin-actions/updated-roles` | POST | ✅ **IMPLEMENTADA** | Sincronizar roles de múltiples usuarios | admin\|supervisor |
| `/v1/admin-actions/update-permissions` | POST | ✅ **IMPLEMENTADA** | Actualizar permisos a múltiples usuarios | admin\|supervisor |
| `/v1/admin-actions/find-permissions` | POST | ✅ **IMPLEMENTADA** | Mostrar permisos existentes | admin\|supervisor |
| `/v1/admin-actions/find-roles` | GET | ✅ **IMPLEMENTADA** | Mostrar roles existentes | admin\|supervisor |
| `/v1/admin-actions/roles/{id}` | GET | ✅ **IMPLEMENTADA** | Mostrar rol por ID | admin\|supervisor |
| `/v1/admin-actions/permissions/{id}` | GET | ✅ **IMPLEMENTADA** | Mostrar permiso por ID | admin\|supervisor |

### Ejemplos de Uso:

**POST /v1/admin-actions/register**
```json
{
  "name": "Juan",
  "last_name": "Pérez",
  "email": "juan@example.com",
  "phone_number": "5512345678",
  "birthdate": "2000-05-12",
  "gender": "hombre",
  "curp": "LOPA800101HDFRNL09",
  "address": ["Calle Hidalgo #123", "Col. Centro", "CDMX"],
  "blood_type": "O+",
  "registration_date": "2025-01-01",
  "status": "activo"
}
```

**PUT /v1/admin-actions/update-user/{id}**
```json
{
  "name": "Juan",
  "last_name": "Pérez",
  "email": "juan@example.com",
  "phone_number": "+5215512345678",
  "birthdate": "1995-06-15",
  "gender": "hombre",
  "curp": "PEMJ950615HDFRZN09",
  "address": ["Calle Falsa 123", "Colonia Centro"],
  "blood_type": "O+"
}
```

---

## 🎓 Carreras

| Endpoint | Método | Estado | Descripción | Permisos |
|----------|--------|--------|-------------|----------|
| `/v1/careers` | GET | ✅ **IMPLEMENTADA** | Listar carreras | admin\|supervisor |
| `/v1/careers` | POST | ✅ **IMPLEMENTADA** | Crear carrera | admin\|supervisor |
| `/v1/careers/{id}` | GET | ✅ **IMPLEMENTADA** | Obtener carrera por ID | admin\|supervisor |
| `/v1/careers/{id}` | PATCH | ✅ **IMPLEMENTADA** | Actualizar carrera | admin\|supervisor |
| `/v1/careers/{id}` | DELETE | ✅ **IMPLEMENTADA** | Eliminar carrera | admin\|supervisor |

**Respuesta GET /v1/careers**
```json
{
  "success": true,
  "message": "Carreras encontradas.",
  "data": {
    "careers": [
      {
        "id": 1,
        "career_name": "Matematicas"
      }
    ]
  }
}
```

---

## 📚 Detalles de Estudiante

| Endpoint | Método | Estado | Descripción | Permisos |
|----------|--------|--------|-------------|----------|
| `/v1/admin-actions/get-student/{id}` | GET | ✅ **IMPLEMENTADA** | Obtener detalles del estudiante | admin\|supervisor |
| `/v1/admin-actions/attach-student` | POST | ✅ **IMPLEMENTADA** | Asociar detalles al estudiante | admin\|supervisor |
| `/v1/admin-actions/update-student/{id}` | PATCH | ✅ **IMPLEMENTADA** | Actualizar detalles del estudiante | admin\|supervisor |
| `/v1/admin-actions/import-students` | POST | ✅ **IMPLEMENTADA** | Importar detalles estudiantiles desde Excel | admin\|supervisor |

**Payload POST /v1/admin-actions/attach-student**
```json
{
  "user_id": 4,
  "career_id": 1,
  "n_control": "2578900",
  "semestre": 1,
  "group": "A",
  "workshop": "Dibujo"
}
```

**Payload PATCH /v1/admin-actions/update-student/{id}**
```json
{
  "career_id": 1,
  "n_control": "2578900",
  "semestre": 1,
  "group": "A",
  "workshop": "Dibujo"
}
```

**Respuesta GET /v1/admin-actions/get-student/{id}**
```json
{
  "success": true,
  "message": "Operación completada exitosamente",
  "data": {
    "user": {
      "user_id": 123,
      "id": 1,
      "career_id": 10,
      "n_control": "20201234",
      "semestre": 5,
      "group": "A",
      "workshop": "Taller de programación"
    }
  }
}
```

---

## 📤 Importación Masiva

| Endpoint | Método | Estado | Descripción | Permisos |
|----------|--------|--------|-------------|----------|
| `/v1/admin-actions/import` | POST | ✅ **IMPLEMENTADA** | Importar usuarios desde Excel | admin\|supervisor |
| `/v1/admin-actions/promotion` | POST | ✅ **IMPLEMENTADA** | Promover semestre de estudiantes | admin |

**POST /v1/admin-actions/import** - Archivo Excel con columnas:
1. name, 2. last_name, 3. email, 4. password, 5. phone_number, 6. birthdate, 7. gender, 8. curp, 9. street, 10. city, 11. state, 12. zip_code, 13. stripe_customer_id, 14. blood_type, 15. registration_date, 16. status, 17. career_id, 18. n_control, 19. semestre, 20. group, 21. workshop

---

## 👤 Gestión de Usuarios (Propios)

| Endpoint | Método | Estado | Descripción |
|----------|--------|--------|-------------|
| `/v1/users/user` | GET | ✅ **IMPLEMENTADA** | Obtener usuario autenticado |
| `/v1/users/update` | PATCH | ✅ **IMPLEMENTADA** | Actualizar datos del usuario |
| `/v1/users/update/password` | PATCH | ✅ **IMPLEMENTADA** | Cambiar contraseña |

**Payload PATCH /v1/users/update**
```json
{
  "name": "Juan",
  "last_name": "Pérez",
  "email": "juan.perez@example.com",
  "phone_number": "+5215512345678",
  "birthdate": "1990-05-15",
  "gender": "hombre",
  "address": ["Calle 123"],
  "blood_type": "O+"
}
```

**Payload PATCH /v1/users/update/password**
```json
{
  "currentPassword": "oldPassword123",
  "newPassword": "newPassword456"
}
```


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
| `/v1/cards` | GET | ✅ **IMPLEMENTADA** | Listar tarjetas | student |
| `/v1/cards` | POST | ✅ **IMPLEMENTADA** | Registrar tarjeta | student |
| `/v1/cards/save` | GET | ✅ **IMPLEMENTADA** | Guardar tarjeta | student |
| `/v1/cards/{paymentMethodId}` | DELETE | ✅ **IMPLEMENTADA** | Eliminar tarjeta | student |

---

## 💰 Conceptos de Pago

| Endpoint | Método | Estado | Descripción | Permisos |
|----------|--------|--------|-------------|----------|
| `/v1/concepts` | GET | ✅ **IMPLEMENTADA** | Listar conceptos | financial staff |
| `/v1/concepts` | POST | ✅ **IMPLEMENTADA** | Crear concepto | financial staff |
| `/v1/concepts/{id}` | PUT/PATCH | ✅ **IMPLEMENTADA** | Actualizar concepto | financial staff |
| `/v1/concepts/{id}` | GET | ✅ **IMPLEMENTADA** | Obtener concepto por ID | financial staff |
| `/v1/concepts/{id}/finalize` | POST | ✅ **IMPLEMENTADA** | Finalizar concepto | financial staff |
| `/v1/concepts/{id}/disable` | POST | ✅ **IMPLEMENTADA** | Desactivar concepto | financial staff |
| `/v1/concepts/{id}/eliminate` | POST | ✅ **IMPLEMENTADA** | Eliminar concepto | financial staff |

---

## 📉 Deudas y Pagos

| Endpoint | Método | Estado | Descripción | Permisos |
|----------|--------|--------|-------------|----------|
| `/v1/debts` | GET | ✅ **IMPLEMENTADA** | Listar deudas | financial staff |
| `/v1/debts/validate` | POST | ✅ **IMPLEMENTADA** | Validar deuda | financial staff |
| `/v1/payments` | GET | ✅ **IMPLEMENTADA** | Listar pagos realizados | financial staff |

---

## 📈 Dashboard para Staff Financiero

| Endpoint | Método | Estado | Descripción | Permisos |
|----------|--------|--------|-------------|----------|
| `/v1/dashboard-staff/refresh` | POST | ✅ **IMPLEMENTADA** | Limpiar caché del dashboard | financial staff |
| `/v1/dashboard-staff/data` | GET | ✅ **IMPLEMENTADA** | Overview financiero | financial staff |
| `/v1/dashboard-staff/pending` | GET | ✅ **IMPLEMENTADA** | Pagos pendientes | financial staff |
| `/v1/dashboard-staff/students` | GET | ✅ **IMPLEMENTADA** | Número total de estudiantes | financial staff |
| `/v1/dashboard-staff/payments` | GET | ✅ **IMPLEMENTADA** | Monto total de pagos realizados | financial staff |
| `/v1/dashboard-staff/concepts` | GET | ✅ **IMPLEMENTADA** | Historial de conceptos | financial staff |
| `/v1/dashboard-staff/payout` | POST | ✅ **IMPLEMENTADA** | Crear payout (transferencia) | financial staff |

---

## 📍 Estudiantes (Listado para Staff)

| Endpoint | Método | Estado | Descripción | Permisos |
|----------|--------|--------|-------------|----------|
| `/v1/students` | GET | ✅ **IMPLEMENTADA** | Listar estudiantes paginados | financial staff |

**Parámetros GET /v1/students:**
- `search`: Filtro por email, CURP o número de control
- `perPage`: Resultados por página (default: 15)
- `page`: Número de página (default: 1)
- `forceRefresh`: Forzar actualización de caché (true/false)

**Respuesta:**
```json
{
  "success": true,
  "message": "Operación completada exitosamente",
  "data": {
    "payments": {
      "items": [
        {
          "userId": 1,
          "fullName": "Juan Pérez",
          "roles": ["student"],
          "semestre": 5,
          "career_name": "Ingeniería en Sistemas",
          "num_pending": 3,
          "num_expired": 1,
          "total_amount_pending": "4500.00",
          "total_paid": "7500.00",
          "expired_amount": "500.00",
          "num_paid": 1
        }
      ],
      "currentPage": 1,
      "lastPage": 5,
      "perPage": 15,
      "total": 72
    }
  }
}
```

---

## 💸 Pagos Pendientes

| Endpoint | Método | Estado | Descripción | Permisos |
|----------|--------|--------|-------------|----------|
| `/v1/pending-payments/{id}` | GET | ✅ **IMPLEMENTADA** | Obtener pagos pendientes | student\|parent |
| `/v1/pending-payments/overdue/{id}` | GET | ✅ **IMPLEMENTADA** | Obtener pagos vencidos | student\|parent |
| `/v1/pending-payments` | POST | ✅ **IMPLEMENTADA** | Generar intento de pago (Stripe) | student\|parent |

**Payload POST /v1/pending-payments**
```json
{
  "concept_id": 123
}
```

---

## 📜 Historial de Pagos

| Endpoint | Método | Estado | Descripción | Permisos |
|----------|--------|--------|-------------|----------|
| `/v1/history/{id}` | GET | ✅ **IMPLEMENTADA** | Obtener historial de pagos | student\|parent |
| `/v1/history/payment/{id}` | GET | ✅ **IMPLEMENTADA** | Obtener detalles de un pago | student\|parent |

---

## 🔗 Webhook

| Endpoint | Método | Estado | Descripción |
|----------|--------|--------|-------------|
| `/stripe/webhook` | POST | ✅ **IMPLEMENTADA** | Webhook para eventos de Stripe |

---

## 📋 Resumen General

### ✅ Completamente Implementadas:
- ✅ Autenticación (Login, User, Test-Auth)
- ✅ Gestión de Usuarios (Admin - CRUD Completo)
- ✅ Gestión de Carreras (CRUD Completo)
- ✅ Detalles de Estudiante (CRUD Completo)
- ✅ Importación Masiva de Usuarios
- ✅ Gestión de Permisos y Roles
- ✅ Dashboard para Estudiantes
- ✅ Dashboard para Staff Financiero
- ✅ Gestión de Tarjetas de Crédito
- ✅ Conceptos de Pago (CRUD Completo)
- ✅ Deudas y Pagos
- ✅ Historial de Pagos
- ✅ Pagos Pendientes
- ✅ Webhooks de Stripe
- ✅ Gestión de Usuarios Propios (Perfil, Contraseña)

---

## 🚨 Importante para el Frontend

### Endpoints de Update de Usuario:
- **PUT `/v1/admin-actions/update-user/{id}`** - Para admins actualizando otros usuarios
- **PATCH `/v1/users/update`** - Para que usuarios actualicen sus propios datos (sin {id} en URL)

El backend espera **PUT** (no PATCH) para `/v1/admin-actions/update-user/{id}`.

---

## 📌 Notas Importantes:

- Todos los endpoints autenticados requieren token Sanctum en header `Authorization: Bearer {token}`
- La mayoría de endpoints usan validación de permisos con Spatie Permission
- Los roles son: `admin`, `financial staff`, `student`, `parent`, `supervisor`
- Los soft deletes están implementados (no se eliminan físicamente registros)
- Los endpoints de carreras SÍ están implementados (contrario a lo que decía antes)
- El CRUD de detalles de estudiante está completamente funcional
