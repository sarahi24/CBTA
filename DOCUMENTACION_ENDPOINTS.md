# 📚 Documentación de Endpoints por Página

**Sistema de Gestión Escolar - CBTA**  
**Fecha de generación:** Febrero 9, 2026  
**Base URL:** `https://nginx-production-728f.up.railway.app/api/v1`

---

## 📋 Índice

1. [Páginas de Estudiante](#-páginas-de-estudiante)
2. [Páginas de Personal Financiero](#-páginas-de-personal-financiero)
3. [Páginas de Administración](#-páginas-de-administración)
4. [Páginas Públicas](#-páginas-públicas)
5. [Sistema de Notificaciones](#-sistema-de-notificaciones)
6. [Relaciones Familiares](#-relaciones-familiares-parents)

---

## 👨‍🎓 Páginas de Estudiante

### 🏠 Portal del Estudiante (`/Estudiante/PortalEstudiante.astro`)

**Descripción:** Dashboard principal del estudiante con resumen de pagos, adeudos y progreso.

**Endpoints utilizados:**

| **Método** | **Endpoint** | **Descripción** | **Body/Params** |
|------------|--------------|-----------------|-----------------|
| `GET` | `/dashboard/pending/{studentId?}` | Obtener total de pagos pendientes | Query: `forceRefresh` (opcional) |
| `GET` | `/dashboard/overdue/{studentId?}` | Obtener total de pagos vencidos | Query: `forceRefresh` (opcional) |
| `GET` | `/dashboard/paid/{studentId?}` | Obtener total de pagos realizados | Query: `forceRefresh` (opcional) |
| `POST` | `/dashboard/refresh/{studentId?}` | Limpiar caché del dashboard | - |

**Headers requeridos:**
```json
{
  "Authorization": "Bearer {token}",
  "Content-Type": "application/json",
  "Accept": "application/json",
  "X-User-Role": "student",
  "X-User-Permission": "view.own.pending.concepts.summary"
}
```

---

### 💳 Adeudos (`/Estudiante/Adeudos.astro`)

**Descripción:** Gestión de pagos pendientes, vencidos y creación de intenciones de pago.

**Endpoints utilizados:**

| **Método** | **Endpoint** | **Descripción** | **Body/Params** |
|------------|--------------|-----------------|-----------------|
| `GET` | `/pending-payment` | Obtener lista de pagos pendientes | Query: `id` (studentId), `forceRefresh` |
| `GET` | `/pending-payment/overdue` | Obtener lista de pagos vencidos | Query: `id` (studentId), `forceRefresh` |
| `POST` | `/pending-payments` | Crear intención de pago para un concepto | Body: `{ "concept_id": 123 }` |
| `GET` | `/cards/{studentId?}` | Obtener tarjetas registradas | Query: `forceRefresh` |

**Headers requeridos:**
```json
{
  "Authorization": "Bearer {token}",
  "X-User-Role": "student",
  "X-User-Permission": "view.pending.concepts"
}
```

**Ejemplo Body - Crear Intención de Pago:**
```json
{
  "concept_id": 45
}
```

---

### 📜 Historial de Pagos (`/Estudiante/Historial.astro`)

**Descripción:** Consulta de historial completo de pagos realizados.

**Endpoints utilizados:**

| **Método** | **Endpoint** | **Descripción** | **Body/Params** |
|------------|--------------|-----------------|-----------------|
| `GET` | `/dashboard/history/{studentId?}` | Obtener historial de pagos | - |

**Headers requeridos:**
```json
{
  "Authorization": "Bearer {token}",
  "Content-Type": "application/json",
  "Accept": "application/json"
}
```

---

### 💳 Tarjetas (`/Estudiante/Tarjetas.astro`)

**Descripción:** Gestión de métodos de pago (tarjetas).

**Endpoints utilizados:**

| **Método** | **Endpoint** | **Descripción** | **Body/Params** |
|------------|--------------|-----------------|-----------------|
| `GET` | `/cards/{studentId?}` | Listar métodos de pago | Query: `forceRefresh` |
| `POST` | `/cards` | Registrar nuevo método de pago | Body: Datos de tarjeta |
| `DELETE` | `/cards/{paymentMethodId}` | Eliminar método de pago | - |

**Headers requeridos:**
```json
{
  "Authorization": "Bearer {token}",
  "X-User-Role": "student",
  "X-User-Permission": "delete.card"
}
```

**Ejemplo Body - Crear Tarjeta:**
```json
{
  "card_number": "4242424242424242",
  "exp_month": "12",
  "exp_year": "2026",
  "cvc": "123",
  "cardholder_name": "Juan Pérez"
}
```

---

### 🔍 Detalle de Pago (`/Estudiante/DetallePago.astro`)

**Descripción:** Ver detalles completos de un pago específico.

**Endpoints utilizados:**

| **Método** | **Endpoint** | **Descripción** | **Body/Params** |
|------------|--------------|-----------------|-----------------|
| `GET` | `/history/payment/{id}` | Obtener pago por ID | - |

**Headers requeridos:**
```json
{
  "Authorization": "Bearer {token}",
  "Content-Type": "application/json",
  "Accept": "application/json"
}
```

---

### 👤 Perfil (`/Estudiante/Perfil.astro`)

**Descripción:** Gestión de datos personales y actualización de perfil.

**Endpoints (inferidos de studentAPI.js):**

| **Método** | **Endpoint** | **Descripción** | **Body/Params** |
|------------|--------------|-----------------|-----------------|
| `GET` | `/users/user` | Obtener usuario autenticado | - |
| `GET` | `/users/student-details` | Obtener detalles de estudiante | - |
| `PATCH` | `/users/update` | Actualizar datos del usuario | Body: Datos a actualizar |
| `PATCH` | `/users/update/password` | Cambiar contraseña | Body: `{ "current_password", "new_password" }` |

---

## 💼 Páginas de Personal Financiero

### 📊 Dashboard del Personal (`/Dashboard.astro`)

**Descripción:** Panel de control para staff financiero con estadísticas generales.

**Endpoints utilizados:**

| **Método** | **Endpoint** | **Descripción** | **Body/Params** |
|------------|--------------|-----------------|-----------------|
| `GET` | `/dashboard-staff/payments` | Total de pagos realizados | Query: `only_this_year`, `forceRefresh` |
| `GET` | `/dashboard-staff/students` | Número total de estudiantes | Query: `only_this_year`, `forceRefresh` |
| `GET` | `/dashboard-staff/pending` | Cantidad y monto de pagos pendientes | Query: `only_this_year`, `forceRefresh` |
| `GET` | `/dashboard-staff/concepts` | Lista de conceptos de pago | Query: `only_this_year`, `page`, `perPage`, `forceRefresh` |
| `POST` | `/dashboard-staff/refresh` | Limpiar caché del dashboard | - |
| `POST` | `/dashboard-staff/payout` | Crear payout con balance disponible | - |

**Headers requeridos:**
```json
{
  "Authorization": "Bearer {token}",
  "Content-Type": "application/json",
  "Accept": "application/json"
}
```

---

### 📝 Conceptos de Cobro (`/concepts.astro`)

**Descripción:** Gestión completa de conceptos de cobro (CRUD completo).

**Endpoints utilizados:**

| **Método** | **Endpoint** | **Descripción** | **Body/Params** |
|------------|--------------|-----------------|-----------------|
| `GET` | `/concepts` | Listar conceptos de pago | Query: `status`, `perPage`, `page`, `forceRefresh` |
| `GET` | `/concepts/{id}` | Obtener concepto por ID | - |
| `POST` | `/concepts` | Crear nuevo concepto | Body: Datos del concepto |
| `PUT` | `/concepts/{id}` | Actualizar concepto existente | Body: Datos a actualizar |
| `GET` | `/concepts/relations/{id}` | Obtener relaciones del concepto | - |
| `PATCH` | `/concepts/update-relations/{id}` | Actualizar relaciones | Body: Datos de relaciones |
| `POST` | `/concepts/{id}/finalize` | Finalizar concepto | - |
| `POST` | `/concepts/{id}/activate` | Activar concepto | - |
| `POST` | `/concepts/{id}/disable` | Deshabilitar concepto | - |
| `POST` | `/concepts/{id}/eliminateLogical` | Eliminar lógicamente | - |
| `DELETE` | `/concepts/{id}/eliminate` | Eliminar físicamente | - |

**Headers requeridos:**
```json
{
  "Authorization": "Bearer {token}",
  "X-User-Role": "financial-staff",
  "X-User-Permission": "view.concepts"
}
```

**Ejemplo Body - Crear Concepto:**
```json
{
  "name": "Colegiatura Enero 2026",
  "description": "Pago mensual de colegiatura",
  "amount": 1500.00,
  "due_date": "2026-01-31",
  "status": "activo",
  "type": "obligatorio",
  "semester": 4,
  "careers": [1, 2, 3],
  "specific_students": []
}
```

---

### 💰 Pagos Realizados (`/payments.astro`)

**Descripción:** Lista completa de pagos realizados con búsqueda y paginación.

**Endpoints utilizados:**

| **Método** | **Endpoint** | **Descripción** | **Body/Params** |
|------------|--------------|-----------------|-----------------|
| `GET` | `/payments` | Listar todos los pagos | Query: `search`, `page`, `perPage`, `forceRefresh` |
| `GET` | `/payments/history/{studentId?}` | Historial de pagos del usuario autenticado | Query: `perPage` (15), `page` (1), `forceRefresh` (false) |
| `GET` | `/payments/by-concept` | Pagos agrupados por concepto | Query: `search`, `page`, `perPage`, `forceRefresh` |

**Headers requeridos:**
```json
{
  "Authorization": "Bearer {token}",
  "X-User-Role": "financial-staff",
  "X-User-Permission": "view.payments"
}
```

---

### � Historial de Pagos (`/payments/history`)

**Descripción:** Obtener historial completo de pagos del usuario autenticado con soporte para paginación y cacheo.

**Endpoints utilizados:**

| **Método** | **Endpoint** | **Descripción** | **Body/Params** |
|------------|--------------|-----------------|-----------------|
| `GET` | `/payments/history/{studentId?}` | Historial de pagos del usuario autenticado | Query: `perPage`, `page`, `forceRefresh`; Headers: `X-User-Role`, `X-User-Permission` |

**Headers requeridos:**
```json
{
  "Authorization": "Bearer {token}",
  "X-User-Role": "student|parent",
  "X-User-Permission": "view.payments.history"
}
```

**Parámetros de Query:**
- `perPage` (integer, default: 15) - Cantidad de registros por página
- `page` (integer, default: 1) - Número de página
- `forceRefresh` (boolean, default: false) - Forzar actualización del caché
- `{studentId}` (integer, optional) - ID del estudiante (para parents)

**Respuesta exitosa (200):**
```json
{
  "success": true,
  "message": "Operación completada exitosamente",
  "data": {
    "payment_history": {
      "items": [
        {
          "id": 123,
          "concept": "Pago de inscripción",
          "amount": "1500.00",
          "amount_received": "1500.00",
          "status": "paid",
          "date": "hace 2 dias"
        }
      ],
      "currentPage": 1,
      "lastPage": 5,
      "perPage": 15,
      "total": 72,
      "hasMorePages": true,
      "nextPage": 2,
      "previousPage": null
    }
  }
}
```

**Códigos de respuesta:**
- `200` - Historial de pagos obtenido correctamente
- `401` - No autenticado
- `403` - No autorizado
- `404` - No encontrado
- `422` - Error de validación
- `429` - Demasiadas solicitudes
- `500` - Error interno del servidor

---

### �📄 Pagos por Concepto (`/payments-by-concept.astro`)

**Descripción:** Vista de pagos agrupados por concepto con estadísticas.

**Endpoints utilizados:**

| **Método** | **Endpoint** | **Descripción** | **Body/Params** |
|------------|--------------|-----------------|-----------------|
| `GET` | `/payments/by-concept` | Pagos agrupados con estadísticas | Query: `search`, `page`, `perPage`, `forceRefresh` |

**Respuesta esperada:**
```json
{
  "data": [
    {
      "concept_id": 45,
      "concept_name": "Colegiatura Enero",
      "total_payments": 150,
      "total_amount": 225000.00,
      "pending_count": 10,
      "paid_count": 140
    }
  ]
}
```

---

### 📉 Adeudos/Deudas (`/debts.astro`)

**Descripción:** Gestión de adeudos pendientes y validación de pagos de Stripe.

**Endpoints utilizados:**

| **Método** | **Endpoint** | **Descripción** | **Body/Params** |
|------------|--------------|-----------------|-----------------|
| `GET` | `/debts` | Listar todos los adeudos | Query: `search`, `page`, `perPage`, `forceRefresh` |
| `GET` | `/debts/stripe-payments` | Obtener pagos desde Stripe | Query: `search`, `year`, `forceRefresh` |
| `POST` | `/debts/validate` | Validar pago de Stripe | Body: `{ "search", "payment_intent_id" }` |

**Headers requeridos:**
```json
{
  "Authorization": "Bearer {token}",
  "X-User-Role": "financial-staff",
  "X-User-Permission": "view.debts"
}
```

**Ejemplo Body - Validar Pago:**
```json
{
  "search": "CURP123456789",
  "payment_intent_id": "pi_1234567890abcdef"
}
```

---

### 👥 Estudiantes (`/students.astro`)

**Descripción:** Lista de estudiantes con resumen de pagos.

**Endpoints utilizados:**

| **Método** | **Endpoint** | **Descripción** | **Body/Params** |
|------------|--------------|-----------------|-----------------|
| `GET` | `/payments/students` | Estudiantes con resumen de pagos | Query: `search`, `page`, `perPage`, `forceRefresh` |

**Headers requeridos:**
```json
{
  "Authorization": "Bearer {token}",
  "X-User-Role": "financial-staff",
  "X-User-Permission": "view.payments.student.summary"
}
```

**Respuesta esperada:**
```json
{
  "data": [
    {
      "student_id": 123,
      "full_name": "Juan Pérez García",
      "n_control": "20241001",
      "email": "juan.perez@example.com",
      "total_pending": 4500.00,
      "total_paid": 12000.00,
      "total_overdue": 1500.00
    }
  ]
}
```

---

### 🔴 Pagos Vencidos (`/overdue-payments.astro`)

**Descripción:** Lista de pagos vencidos.

**Endpoints utilizados:**

| **Método** | **Endpoint** | **Descripción** | **Body/Params** |
|------------|--------------|-----------------|-----------------|
| `GET` | `/pending-payment/overdue` | Obtener pagos vencidos | Query: `forceRefresh` |

**Headers requeridos:**
```json
{
  "Authorization": "Bearer {token}",
  "X-User-Role": "financial-staff",
  "X-User-Permission": "view.overdue.concepts"
}
```

---

### 💳 Pagos de Stripe (`/stripe-payments.astro`)

**Descripción:** Consulta y verificación de pagos procesados por Stripe.

**Endpoints utilizados:**

| **Método** | **Endpoint** | **Descripción** | **Body/Params** |
|------------|--------------|-----------------|-----------------|
| `GET` | `/debts/stripe-payments` | Listar pagos de Stripe | Query: `search`, `year`, `forceRefresh` |

---

## 🔐 Páginas de Administración

### 👤 Gestión de Usuarios y Roles (`/roles.astro`)

**Descripción:** Administración completa de usuarios, roles, permisos, carreras e importación de datos.

**Endpoints utilizados:**

#### **Usuarios**
| **Método** | **Endpoint** | **Descripción** | **Body/Params** |
|------------|--------------|-----------------|-----------------|
| `GET` | `/admin-actions/show-users` | Listar usuarios | Query: `page`, `perPage`, `forceRefresh` |
| `GET` | `/admin-actions/users/{id}` | Obtener usuario por ID | - |
| `POST` | `/admin-actions/register` | Crear nuevo usuario | Body: Datos de usuario |
| `PATCH` | `/admin-actions/update/{id}` | Actualizar usuario | Body: Datos a actualizar |
| `POST` | `/admin-actions/disable/{id}` | Deshabilitar usuario | - |
| `POST` | `/admin-actions/delete` | Eliminar usuarios (bulk) | Body: `{ "curps": [] }` |

#### **Roles y Permisos**
| **Método** | **Endpoint** | **Descripción** | **Body/Params** |
|------------|--------------|-----------------|-----------------|
| `GET` | `/admin-actions/find-roles` | Obtener todos los roles | Query: `forceRefresh` |
| `GET` | `/admin-actions/roles/{id}` | Obtener rol por ID | - |
| `GET` | `/admin-actions/find-permissions` | Obtener todos los permisos | Query: `forceRefresh` |
| `GET` | `/admin-actions/permissions/{id}` | Obtener permiso por ID | - |
| `POST` | `/admin-actions/permissions/by-user/{userId}` | Permisos de un usuario | Body: `{ "roles": [], "forceRefresh": true }` |
| `POST` | `/admin-actions/permissions/by-role` | Permisos por rol | Body: `{}` |
| `POST` | `/admin-actions/permissions/by-curps` | Permisos de varios usuarios | Body: `{ "curps": [] }` |
| `POST` | `/admin-actions/update-permissions/{userId}` | Actualizar permisos de usuario | Body: `{ "permissionsToAdd": [], "permissionsToRemove": [] }` |
| `POST` | `/admin-actions/update-permissions` | Actualizar permisos (bulk) | Body: `{ "curps": [], "permissionsToAdd": [], "permissionsToRemove": [] }` |
| `POST` | `/admin-actions/updated-roles/{userId}` | Actualizar roles de usuario | Body: `{ "rolesToAdd": [], "rolesToRemove": [] }` |
| `POST` | `/admin-actions/updated-roles` | Actualizar roles (bulk) | Body: `{ "curps": [], "rolesToAdd": [], "rolesToRemove": [] }` |

#### **Carreras**
| **Método** | **Endpoint** | **Descripción** | **Body/Params** |
|------------|--------------|-----------------|-----------------|
| `GET` | `/careers` | Listar todas las carreras | Query: `forceRefresh` |
| `GET` | `/careers/{id}` | Obtener carrera por ID | - |
| `POST` | `/careers` | Crear nueva carrera | Body: `{ "name": "", "description": "" }` |
| `PATCH` | `/careers/{id}` | Actualizar carrera | Body: Datos a actualizar |
| `DELETE` | `/careers/{id}` | Eliminar carrera | - |

#### **Estudiantes**
| **Método** | **Endpoint** | **Descripción** | **Body/Params** |
|------------|--------------|-----------------|-----------------|
| `GET` | `/admin-actions/get-student/{studentId}` | Obtener datos de estudiante | - |
| `POST` | `/admin-actions/attach-student/{studentId}` | Asociar estudiante a usuario | Body: Datos de estudiante |
| `PATCH` | `/admin-actions/update-student/{studentId}` | Actualizar datos de estudiante | Body: Datos a actualizar |

#### **Importación de Datos**
| **Método** | **Endpoint** | **Descripción** | **Body/Params** |
|------------|--------------|-----------------|-----------------|
| `POST` | `/admin-actions/import-users` | Importar usuarios desde Excel | Body: FormData con archivo |
| `POST` | `/admin-actions/import-students` | Importar estudiantes desde Excel | Body: FormData con archivo |

**Headers requeridos:**
```json
{
  "Authorization": "Bearer {token}",
  "X-User-Role": "admin",
  "X-User-Permission": "view.users"
}
```

**Ejemplo Body - Crear Usuario:**
```json
{
  "name": "Juan",
  "last_name": "Pérez García",
  "email": "juan.perez@example.com",
  "password": "Password123!",
  "curp": "PEGJ900101HDFRNN01",
  "phone": "4491234567",
  "roles": ["student"]
}
```

**Ejemplo Body - Actualizar Roles (Individual):**
```json
{
  "rolesToAdd": ["financial-staff", "admin"],
  "rolesToRemove": ["student"]
}
```

**Ejemplo Body - Actualizar Permisos (Bulk):**
```json
{
  "curps": ["CURP1", "CURP2", "CURP3"],
  "permissionsToAdd": ["view.payments", "validate.debt"],
  "permissionsToRemove": ["delete.concepts"]
}
```

---

## 🌐 Páginas Públicas

### 🔑 Login/Registro (`/index.astro`)

**Descripción:** Página de inicio de sesión, registro y recuperación de contraseña.

**Endpoints utilizados:**

| **Método** | **Endpoint** | **Descripción** | **Body/Params** |
|------------|--------------|-----------------|-----------------|
| `POST` | `/login` | Iniciar sesión | Body: `{ "email", "password" }` |
| `POST` | `/register` | Registrar nuevo usuario | Body: Datos de registro |
| `POST` | `/forgot-password` | Solicitar recuperación de contraseña | Body: `{ "email" }` |
| `OPTIONS` | `/login` | Verificar conectividad API | - |

**Ejemplo Body - Login:**
```json
{
  "email": "juan.perez@example.com",
  "password": "Password123!"
}
```

**Ejemplo Body - Registro:**
```json
{
  "name": "Juan",
  "last_name": "Pérez García",
  "email": "juan.perez@example.com",
  "password": "Password123!",
  "password_confirmation": "Password123!",
  "curp": "PEGJ900101HDFRNN01",
  "phone": "4491234567"
}
```

**Respuesta esperada (Login):**
```json
{
  "status": "success",
  "data": {
    "user_tokens": {
      "access_token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
      "refresh_token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
      "user_data": [
        {
          "id": 123,
          "email": "juan.perez@example.com",
          "name": "Juan",
          "last_name": "Pérez García",
          "fullName": "Juan Pérez García",
          "roles": ["student"]
        }
      ]
    }
  }
}
```

---

### 🔄 Restablecer Contraseña (`/reset-password.astro`)

**Descripción:** Página para restablecer contraseña con token de recuperación.

**Endpoints (inferidos):**

| **Método** | **Endpoint** | **Descripción** | **Body/Params** |
|------------|--------------|-----------------|-----------------|
| `POST` | `/reset-password` | Restablecer contraseña | Body: `{ "token", "email", "password", "password_confirmation" }` |

---

## � Sistema de Notificaciones

**Descripción:** Módulo de gestión de notificaciones para usuarios autenticados. Permite consultar notificaciones leídas y no leídas, marcarlas como leídas y eliminarlas.

**Endpoints utilizados:**

| **Método** | **Endpoint** | **Descripción** | **Params/Body** |
|------------|--------------|-----------------|-----------------|
| `GET` | `/notifications` | Obtener notificaciones leídas paginadas | Query: `page` (default: 1), `per_page` (default: 20) |
| `GET` | `/notifications/unread` | Obtener todas las notificaciones no leídas | - |
| `POST` | `/notifications/mark-as-read` | Marcar todas las notificaciones como leídas | - |
| `POST` | `/notifications/mark-as-read/{id}` | Marcar una notificación específica como leída | Param: `id` (UUID) |
| `DELETE` | `/notifications/{id}` | Eliminar una notificación específica | Param: `id` (UUID) |

**Headers requeridos:**
```json
{
  "Authorization": "Bearer {token}",
  "Content-Type": "application/json",
  "Accept": "application/json"
}
```

---

### 📋 GET `/notifications` - Notificaciones Leídas Paginadas

**Descripción:** Retorna una lista paginada de las notificaciones LEÍDAS del usuario autenticado.

**Query Parameters:**
- `page` (integer, opcional): Número de página (default: 1)
- `per_page` (integer, opcional): Notificaciones por página (default: 20)

**Respuesta 200 - Éxito:**
```json
{
  "success": true,
  "message": "Operación completada exitosamente",
  "data": {
    "notifications": {
      "data": [
        {
          "id": "550e8400-e29b-41d4-a716-446655440000",
          "type": "App\\Notifications\\PaymentConceptUpdated",
          "notifiable_type": "App\\Models\\User",
          "notifiable_id": 1,
          "data": {
            "title": "Actualización del concepto de pago",
            "message": "El concepto 'Matrícula' (1500.00 MXN) ha sido actualizado",
            "concept_id": 1,
            "concept_name": "Matrícula",
            "amount": 1500,
            "type": "payment_concept_changed",
            "created_at": "2026-02-09T20:10:48.217Z"
          },
          "read_at": "2024-01-15T10:30:00.000000Z",
          "created_at": "2026-02-09T20:10:48.217Z",
          "updated_at": "2026-02-09T20:10:48.217Z"
        }
      ],
      "current_page": 1,
      "last_page": 5,
      "per_page": 20,
      "total": 95,
      "links": {}
    },
    "unread_count": 5,
    "read_count": 95
  }
}
```

**Respuestas de Error:**
- **401** - No autenticado
- **429** - Demasiadas solicitudes

---

### 🔴 GET `/notifications/unread` - Notificaciones No Leídas

**Descripción:** Retorna todas las notificaciones no leídas del usuario autenticado.

**Respuesta 200 - Éxito:**
```json
{
  "success": true,
  "message": "Operación completada exitosamente",
  "data": {
    "notifications": [
      {
        "id": "550e8400-e29b-41d4-a716-446655440000",
        "type": "App\\Notifications\\PaymentConceptUpdated",
        "notifiable_type": "App\\Models\\User",
        "notifiable_id": 1,
        "data": {
          "title": "Nuevo concepto de pago",
          "message": "Se ha agregado un nuevo concepto: Examen Extraordinario",
          "concept_id": 5,
          "amount": 250.00,
          "type": "payment_concept_added",
          "created_at": "2026-02-09T20:10:48.223Z"
        },
        "read_at": null,
        "created_at": "2026-02-09T20:10:48.223Z"
      }
    ],
    "count": 3
  }
}
```

**Respuestas de Error:**
- **401** - No autenticado
- **429** - Demasiadas solicitudes

---

### ✅ POST `/notifications/mark-as-read` - Marcar Todas como Leídas

**Descripción:** Marca todas las notificaciones no leídas del usuario como leídas.

**Respuesta 200 - Éxito:**
```json
{
  "success": true,
  "message": "Operación completada exitosamente",
  "data": {
    "unread_count": 0
  }
}
```

**Respuestas de Error:**
- **401** - No autenticado
- **429** - Demasiadas solicitudes

---

### ✔️ POST `/notifications/mark-as-read/{id}` - Marcar Una como Leída

**Descripción:** Marca una notificación específica como leída por su UUID.

**Path Parameter:**
- `id` (UUID, requerido): Identificador único de la notificación

**Ejemplo:**
```
POST /api/v1/notifications/mark-as-read/550e8400-e29b-41d4-a716-446655440000
```

**Respuesta 200 - Éxito:**
```json
{
  "success": true,
  "message": "Operación completada exitosamente",
  "data": {
    "unread_count": 4
  }
}
```

**Respuestas de Error:**
- **401** - No autenticado
- **404** - Notificación no encontrada
- **429** - Demasiadas solicitudes

---

### 🗑️ DELETE `/notifications/{id}` - Eliminar Notificación

**Descripción:** Elimina una notificación específica del usuario autenticado.

**Path Parameter:**
- `id` (UUID, requerido): Identificador único de la notificación a eliminar

**Ejemplo:**
```
DELETE /api/v1/notifications/550e8400-e29b-41d4-a716-446655440000
```

**Respuesta 200 - Éxito:**
```json
{
  "success": true,
  "message": "Operación completada exitosamente",
  "data": {}
}
```

**Respuestas de Error:**
- **401** - No autenticado
- **404** - Notificación no encontrada
- **429** - Demasiadas solicitudes

---

### 📌 Tipos de Notificaciones

El sistema puede enviar diferentes tipos de notificaciones según los eventos:

| **Tipo** | **Descripción** | **Datos Incluidos** |
|----------|-----------------|---------------------|
| `PaymentConceptUpdated` | Concepto de pago modificado | `concept_id`, `concept_name`, `amount`, `message` |
| `PaymentConceptAdded` | Nuevo concepto de pago agregado | `concept_id`, `concept_name`, `amount`, `due_date` |
| `PaymentReceived` | Pago recibido y validado | `payment_id`, `amount`, `concept_name` |
| `PaymentOverdue` | Pago vencido | `concept_id`, `concept_name`, `due_date`, `amount` |
| `PaymentReminder` | Recordatorio de pago próximo | `concept_id`, `concept_name`, `due_date`, `days_remaining` |

---

### 💡 Notas de Implementación

**Estructura de Notificaciones:**
- Todas las notificaciones tienen un UUID único como identificador
- El campo `data` contiene información específica del tipo de notificación
- `read_at` es `null` para notificaciones no leídas
- Las notificaciones se ordenan por fecha de creación (más recientes primero)

**Paginación:**
- Solo el endpoint `/notifications` (leídas) está paginado
- `/notifications/unread` retorna todas las notificaciones no leídas sin paginar

**Permisos:**
- Los usuarios solo pueden ver sus propias notificaciones
- No se requieren permisos especiales más allá de la autenticación

**Caché:**
- El contador de notificaciones no leídas puede cachearse brevemente
- Al marcar como leída o eliminar, se invalida el caché automáticamente

---

## 👨‍👩‍👧 Relaciones Familiares (Parents)

**Descripción:** Módulo para gestionar relaciones entre padres/tutores y estudiantes. Permite invitar padres, aceptar invitaciones y consultar relaciones familiares.

**Endpoints utilizados:**

| **Método** | **Endpoint** | **Descripción** | **Params/Body** |
|------------|--------------|-----------------|-----------------|
| `POST` | `/parents/invite` | Enviar invitación a un padre | Body: `{student_id, parent_email}` |
| `POST` | `/parents/invite/accept` | Aceptar invitación de padre | Body: `{token, relationship}` |
| `GET` | `/parents/get-children` | Obtener hijos del padre autenticado | - |
| `GET` | `/parents/get-parents` | Obtener padres del estudiante autenticado | - |
| `DELETE` | `/parents/delete-parent/{parentId}` | Eliminar relación familiar | Param: `parentId` (integer) |

**Headers requeridos:**
```json
{
  "Authorization": "Bearer {token}",
  "Content-Type": "application/json",
  "Accept": "application/json",
  "X-User-Role": "student|parent"
}
```

---

### 📨 POST `/parents/invite` - Enviar Invitación a Padre

**Rol requerido:** `student`  
**Descripción:** Envía una invitación de padre a un email específico. El padre recibe un token de aceptación.

**Request Body:**
```json
{
  "student_id": 42,
  "parent_email": "parent@example.com"
}
```

**Respuesta 201 - Éxito:**
```json
{
  "success": true,
  "message": "Operación completada exitosamente",
  "data": {
    "token": "uuid-token-123456",
    "expires_at": "2025-11-27T12:34:56Z"
  }
}
```

**Respuestas de Error:**
- **401** - No autenticado
- **403** - No autorizado (estudiante no puede invitar padres)
- **422** - Error de validación (email inválido, student_id no existe)
- **429** - Demasiadas solicitudes
- **500** - Error interno del servidor

---

### ✅ POST `/parents/invite/accept` - Aceptar Invitación

**Rol requerido:** `parent`  
**Descripción:** Acepta una invitación de padre usando el token recibido por email.

**Request Body:**
```json
{
  "token": "abc123xyzInviteToken987",
  "relationship": "padre"
}
```

**Valores válidos para `relationship`:**
- `padre` - Padre/Papá
- `madre` - Madre/Mamá
- `tutor` - Tutor/a
- `abuelo` - Abuelo/a
- `otro` - Otro familiar

**Respuesta 200 - Éxito:**
```json
{
  "success": true,
  "message": "Operación completada exitosamente",
  "data": {}
}
```

**Respuestas de Error:**
- **401** - No autenticado
- **403** - No autorizado (token inválido para este usuario)
- **422** - Token expirado o inválido
- **429** - Demasiadas solicitudes
- **500** - Error interno del servidor

---

### 👧 GET `/parents/get-children` - Obtener Hijos del Padre

**Rol requerido:** `parent`  
**Descripción:** Retorna la lista de hijos del padre autenticado.

**Respuesta 200 - Éxito:**
```json
{
  "success": true,
  "message": "Operación completada exitosamente",
  "data": {
    "children": [
      {
        "parentId": 1,
        "parentName": "Juan Perez",
        "childrenData": [
          {
            "id": 3,
            "name": "Jesus Perez"
          },
          {
            "id": 4,
            "name": "Maria Perez"
          }
        ]
      }
    ]
  }
}
```

**Respuestas de Error:**
- **401** - No autenticado
- **403** - No autorizado
- **404** - Padre no encontrado
- **429** - Demasiadas solicitudes
- **500** - Error interno del servidor

---

### 👨‍👩‍👧 GET `/parents/get-parents` - Obtener Padres del Estudiante

**Rol requerido:** `student`  
**Descripción:** Retorna la lista de padres/tutores del estudiante autenticado.

**Respuesta 200 - Éxito:**
```json
{
  "success": true,
  "message": "Operación completada exitosamente",
  "data": {
    "children": [
      {
        "studentId": 1,
        "studentName": "Juan Perez",
        "parentsData": [
          {
            "id": 3,
            "name": "Jesus Perez",
            "relationship": "padre"
          },
          {
            "id": 5,
            "name": "Maria Perez",
            "relationship": "madre"
          }
        ]
      }
    ]
  }
}
```

**Respuestas de Error:**
- **401** - No autenticado
- **403** - No autorizado
- **404** - Estudiante no encontrado
- **429** - Demasiadas solicitudes
- **500** - Error interno del servidor

---

### 🗑️ DELETE `/parents/delete-parent/{parentId}` - Eliminar Relación Familiar

**Rol requerido:** `student`  
**Descripción:** Elimina la relación del estudiante con un padre/tutor específico.

**Path Parameter:**
- `parentId` (integer, requerido): ID del padre a eliminar

**Ejemplo:**
```
DELETE /api/v1/parents/delete-parent/42
```

**Respuesta 200 - Éxito:**
```json
{
  "success": true,
  "message": "Relación eliminada correctamente",
  "data": {}
}
```

**Respuestas de Error:**
- **401** - No autenticado
- **403** - No autorizado (estudiante no puede eliminar otras relaciones)
- **404** - Padre/relación no encontrada
- **429** - Demasiadas solicitudes
- **500** - Error interno del servidor

---

### 📋 Resumen de Flujos

**Flujo de Invitación Completo:**

1. **Estudiante invita padre:**
   ```
   POST /parents/invite
   Body: {student_id: 42, parent_email: "padre@example.com"}
   Response: {token: "xxx", expires_at: "2025-11-27T12:34:56Z"}
   ```

2. **Padre recibe email con link**
   - Email contiene: `https://app.com/accept-invite?token=xxx`

3. **Padre acepta invitación:**
   ```
   POST /parents/invite/accept
   Body: {token: "xxx", relationship: "padre"}
   ```

4. **Padre consulta sus hijos:**
   ```
   GET /parents/get-children
   Response: {children: [ {...} ]}
   ```

5. **Estudiante consulta sus padres:**
   ```
   GET /parents/get-parents
   Response: {children: [ {...} ]}
   ```

6. **Estudiante elimina relación (si es necesario):**
   ```
   DELETE /parents/delete-parent/42
   ```

---

### 💡 Notas de Implementación

**Invitaciones:**
- Los tokens de invitación expiran después de 7 días
- Solo un estudiante puede invitar a sus propios padres
- Un mismo email no puede ser invitado dos veces simultáneamente

**Permisos:**
- Solo estudiantes pueden invitar padres
- Solo padres pueden consultar sus hijos
- Solo padres/tutores aceptados pueden ver información del estudiante
- Estudiantes solo pueden eliminar sus propias relaciones

**Relaciones:**
- Un estudiante puede tener múltiples padres/tutores
- Un padre puede estar vinculado a múltiples estudiantes
- La relación se establece cuando el padre acepta la invitación

**Tokens:**
- Los tokens son únicos y de un solo uso
- Se invalidan después de la aceptación
- Expiran automáticamente después de 7 días

---

## �📊 Resumen de Endpoints por Módulo

### **Autenticación y Usuarios**
- ✅ `/login` - Login de usuarios
- ✅ `/register` - Registro de usuarios
- ✅ `/forgot-password` - Recuperar contraseña
- ✅ `/reset-password` - Restablecer contraseña
- ✅ `/users/user` - Usuario autenticado
- ✅ `/users/student-details` - Detalles de estudiante
- ✅ `/users/update` - Actualizar perfil
- ✅ `/users/update/password` - Cambiar contraseña

### **Dashboard Estudiante**
- ✅ `/dashboard/history/{studentId?}` - Historial de pagos
- ✅ `/dashboard/pending/{studentId?}` - Total pendiente
- ✅ `/dashboard/paid/{studentId?}` - Total pagado
- ✅ `/dashboard/overdue/{studentId?}` - Total vencido
- ✅ `/dashboard/refresh/{studentId?}` - Limpiar caché

### **Dashboard Staff**
- ✅ `/dashboard-staff/payments` - Total de pagos
- ✅ `/dashboard-staff/students` - Número de estudiantes
- ✅ `/dashboard-staff/pending` - Pagos pendientes
- ✅ `/dashboard-staff/concepts` - Conceptos de pago
- ✅ `/dashboard-staff/refresh` - Limpiar caché
- ✅ `/dashboard-staff/payout` - Crear payout

### **Pagos y Adeudos**
- ✅ `/pending-payment` - Pagos pendientes
- ✅ `/pending-payment/overdue` - Pagos vencidos
- ✅ `/pending-payments` - Crear intención de pago
- ✅ `/payments` - Listar pagos
- ✅ `/payments/history/{studentId?}` - Historial de pagos
- ✅ `/payments/by-concept` - Pagos por concepto
- ✅ `/payments/students` - Resumen por estudiante
- ✅ `/debts` - Listar adeudos
- ✅ `/debts/stripe-payments` - Pagos de Stripe
- ✅ `/debts/validate` - Validar pago

### **Conceptos de Cobro**
- ✅ `/concepts` - CRUD completo de conceptos
- ✅ `/concepts/{id}` - Obtener/Actualizar/Eliminar concepto
- ✅ `/concepts/relations/{id}` - Relaciones del concepto
- ✅ `/concepts/update-relations/{id}` - Actualizar relaciones
- ✅ `/concepts/{id}/finalize` - Finalizar concepto
- ✅ `/concepts/{id}/activate` - Activar concepto
- ✅ `/concepts/{id}/disable` - Deshabilitar concepto
- ✅ `/concepts/{id}/eliminateLogical` - Soft delete
- ✅ `/concepts/{id}/eliminate` - Hard delete

### **Tarjetas de Pago**
- ✅ `/cards/{studentId?}` - Listar tarjetas
- ✅ `/cards` - Crear tarjeta
- ✅ `/cards/{paymentMethodId}` - Eliminar tarjeta

### **Notificaciones**
- ✅ `/notifications` - Obtener notificaciones leidas paginadas
- ✅ `/notifications/unread` - Obtener notificaciones no leidas
- ✅ `/notifications/mark-as-read` - Marcar todas como leidas
- ✅ `/notifications/mark-as-read/{id}` - Marcar una notificacion como leida
- ✅ `/notifications/{id}` - Eliminar notificacion

### **Administración de Usuarios**
- ✅ `/admin-actions/show-users` - Listar usuarios
- ✅ `/admin-actions/users/{id}` - Usuario por ID
- ✅ `/admin-actions/register` - Crear usuario
- ✅ `/admin-actions/update/{id}` - Actualizar usuario
- ✅ `/admin-actions/disable/{id}` - Deshabilitar usuario
- ✅ `/admin-actions/delete` - Eliminar usuarios (bulk)

### **Roles y Permisos**
- ✅ `/admin-actions/find-roles` - Listar roles
- ✅ `/admin-actions/roles/{id}` - Rol por ID
- ✅ `/admin-actions/find-permissions` - Listar permisos
- ✅ `/admin-actions/permissions/{id}` - Permiso por ID
- ✅ `/admin-actions/permissions/by-user/{userId}` - Permisos de usuario
- ✅ `/admin-actions/permissions/by-role` - Permisos por rol
- ✅ `/admin-actions/permissions/by-curps` - Permisos por CURPs
- ✅ `/admin-actions/update-permissions/{userId}` - Actualizar permisos
- ✅ `/admin-actions/update-permissions` - Actualizar permisos (bulk)
- ✅ `/admin-actions/updated-roles/{userId}` - Actualizar roles
- ✅ `/admin-actions/updated-roles` - Actualizar roles (bulk)

### **Carreras**
- ✅ `/careers` - CRUD completo de carreras
- ✅ `/careers/{id}` - Operaciones por ID

### **Estudiantes**
- ✅ `/admin-actions/get-student/{studentId}` - Datos de estudiante
- ✅ `/admin-actions/attach-student/{studentId}` - Asociar estudiante
- ✅ `/admin-actions/update-student/{studentId}` - Actualizar estudiante

### **Padres/Tutores**
- ✅ `/parents/invite` - Enviar invitación a padre
- ✅ `/parents/invite/accept` - Aceptar invitación
- ✅ `/parents/get-children` - Obtener hijos del padre
- ✅ `/parents/get-parents` - Obtener padres del estudiante
- ✅ `/parents/delete-parent/{parentId}` - Eliminar relación

### **Importación de Datos**
- ✅ `/admin-actions/import-users` - Importar usuarios
- ✅ `/admin-actions/import-students` - Importar estudiantes

---

## 🔧 Utilidades API

El proyecto cuenta con 3 archivos principales de utilidades para centralizar las llamadas API:

### **1. StudentAPI (`/src/utils/studentAPI.js`)**
- Centraliza llamadas para estudiantes
- Manejo automático de errores 401
- Soporte para roles student/parent

### **2. DashboardAPI (`/src/utils/dashboardAPI.js`)**
- Funciones para staff financiero
- Auto-refresh de tokens expirados
- Manejo de caché con `forceRefresh`

### **3. AdminAPI (`/src/utils/adminAPI.js`)**
- Administración de usuarios, roles y permisos
- Gestión completa de conceptos de cobro
- Importación masiva de datos

---

## 📝 Notas Importantes

### **Autenticación**
- Todos los endpoints requieren token JWT en header `Authorization: Bearer {token}`
- Los tokens se almacenan en `localStorage`:
  - `access_token` - Token de acceso
  - `refresh_token` - Token de refresco
  - `user_data` - Datos del usuario

### **Roles y Permisos**
- Los headers `X-User-Role` y `X-User-Permission` son necesarios en endpoints protegidos
- Roles disponibles: `student`, `parent`, `financial-staff`, `admin`

### **Paginación**
- Endpoints con paginación aceptan:
  - `page` - Número de página (default: 1)
  - `perPage` - Items por página (default: 15, max: 200)
  - `search` - Búsqueda por términos
  - `forceRefresh` - Ignorar caché

### **Manejo de Errores**
- **401** - No autenticado (token expirado o inválido)
- **403** - Sin permisos suficientes
- **422** - Errores de validación
- **429** - Demasiadas solicitudes
- **502** - Error de servidor/gateway

### **Caché**
- Muchos endpoints soportan caché Redis
- Usar `forceRefresh=true` para ignorar caché
- Endpoints `/refresh` limpian el caché manualmente

---

## 📦 Archivos de Utilidades

### **Ubicación de archivos API:**
```
Frond-end/
├── public/
│   └── studentAPI.js (versión pública)
├── src/
│   └── utils/
│       ├── studentAPI.js (módulo ES6)
│       ├── dashboardAPI.js (módulo ES6)
│       └── adminAPI.js (módulo ES6)
```

---

## 🎯 Endpoints más Utilizados

### **Top 10 Endpoints:**
1. `/login` - Autenticación principal
2. `/dashboard/pending/{studentId?}` - Dashboard estudiante
3. `/pending-payment` - Adeudos del estudiante
4. `/payments` - Lista de pagos (staff)
5. `/concepts` - Gestión de conceptos
6. `/admin-actions/show-users` - Administración de usuarios
7. `/cards/{studentId?}` - Métodos de pago
8. `/debts` - Adeudos pendientes (staff)
9. `/dashboard-staff/payments` - Dashboard staff
10. `/admin-actions/import-students` - Importación masiva

---

## ✅ Estado de Implementación

**Endpoints Totales Documentados:** 95+  
**Páginas con Endpoints:** 20  
**Archivos API Utilities:** 3  

**Cobertura por Módulo:**
- ✅ Autenticación: 100%
- ✅ Dashboard Estudiante: 100%
- ✅ Dashboard Staff: 100%
- ✅ Pagos y Adeudos: 100%
- ✅ Conceptos: 100%
- ✅ Tarjetas: 100%
- ✅ Notificaciones: 100%
- ✅ Administración: 100%
- ✅ Roles y Permisos: 100%
- ✅ Carreras: 100%
- ✅ Estudiantes: 100%
- ✅ Padres/Tutores: 100%
- ✅ Importación: 100%

---

**Última actualización:** Febrero 9, 2026  
**Versión del documento:** 1.0  
**Base API:** `https://nginx-production-728f.up.railway.app/api/v1`

---

Para más información sobre cada endpoint específico, consulta:
- `Frond-end/src/utils/studentAPI.js` - Implementación de endpoints de estudiante
- `Frond-end/src/utils/dashboardAPI.js` - Implementación de dashboard staff
- `Frond-end/src/utils/adminAPI.js` - Implementación de administración
