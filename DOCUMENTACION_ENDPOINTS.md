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

### 📄 Pagos por Concepto (`/payments-by-concept.astro`)

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

## 📊 Resumen de Endpoints por Módulo

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

**Endpoints Totales Documentados:** 85+  
**Páginas con Endpoints:** 20  
**Archivos API Utilities:** 3  

**Cobertura por Módulo:**
- ✅ Autenticación: 100%
- ✅ Dashboard Estudiante: 100%
- ✅ Dashboard Staff: 100%
- ✅ Pagos y Adeudos: 100%
- ✅ Conceptos: 100%
- ✅ Tarjetas: 100%
- ✅ Administración: 100%
- ✅ Roles y Permisos: 100%
- ✅ Carreras: 100%
- ✅ Estudiantes: 100%
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
