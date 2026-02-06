# 💳 ÍNDICE MAESTRO: Sistema Completo de Pagos

## 📚 Documentación de Referencia Rápida

Este índice centraliza toda la información sobre los endpoints, páginas, scripts y guías relacionadas con el sistema de pagos del CBTA 71.

---

## 🎯 Endpoints API de Pagos (8 en total)

### 1️⃣ **GET /api/v1/payments/pending/:user_id**
- **Descripción**: Obtener pagos pendientes de un estudiante específico
- **Rol requerido**: `financial-staff`
- **Permiso**: `view.debts`
- **Respuesta**: Lista de pagos sin liquidar
- **Método API**: `StudentAPI.getPendingPayments(userId, token)`
- **Test**: *(integrado en debts.astro)*

### 2️⃣ **GET /api/v1/payments/overdue/:user_id**
- **Descripción**: Obtener pagos vencidos de un estudiante
- **Rol requerido**: `financial-staff`
- **Permiso**: `view.debts`
- **Respuesta**: Pagos pendientes con `due_date` pasada
- **Método API**: `StudentAPI.getOverduePayments(userId, token)`
- **Test**: *(integrado en debts.astro)*

### 3️⃣ **POST /api/v1/payments/attempt**
- **Descripción**: Crear intento de pago con Stripe
- **Rol requerido**: `student`
- **Permiso**: `create.payment`
- **Body**: `{ "payment_ids": [1, 2, 3] }`
- **Respuesta**: `{ "checkout_url": "https://..." }`
- **Método API**: `StudentAPI.createPaymentAttempt(paymentIds)`
- **Test**: *(integrado en pending-payments.astro)*

### 4️⃣ **GET /api/v1/payments/stripe/:user_id**
- **Descripción**: Obtener historial de pagos de Stripe de un estudiante
- **Rol requerido**: `financial-staff` o `student` (propio historial)
- **Permiso**: `view.payments`
- **Respuesta**: Lista de pagos procesados con Stripe
- **Método API**: `StudentAPI.getStripePayments(userId, token)`
- **Test**: *(integrado en stripe-payments.astro)*

### 5️⃣ **POST /api/v1/payments/validate-stripe**
- **Descripción**: Validar y reconciliar un pago de Stripe manualmente
- **Rol requerido**: `financial-staff`
- **Permiso**: `validate.debt`
- **Body**: `{ "search": "CST-XXX", "payment_intent": "pi_XXX" }`
- **Respuesta**: Detalles de estudiante, pago y resultado de reconciliación
- **Método API**: `StudentAPI.validateStripePayment(search, paymentIntent, token)`
- **Test**: *(integrado en debts.astro modal)*
- **Guía**: [PAYMENT_VALIDATION_UI_GUIDE.md](./PAYMENT_VALIDATION_UI_GUIDE.md)

### 6️⃣ **GET /api/v1/debts** ⭐ NUEVO
- **Descripción**: Listar TODOS los pagos pendientes (todos los estudiantes)
- **Rol requerido**: `financial-staff`
- **Permiso**: `view.debts`
- **Parámetros**: `search`, `page`, `perPage`, `forceRefresh`
- **Respuesta**: Lista paginada con `user_name`, `concept_name`, `amount`, etc.
- **Método API**: `StudentAPI.getAllPendingDebts(token, options)`
- **Test**: [test-get-all-debts.ps1](./test-get-all-debts.ps1)
- **Guía**: [GET_DEBTS_API_GUIDE.md](./GET_DEBTS_API_GUIDE.md)
- **Página**: [debts.astro](./Frond-end/src/pages/debts.astro) con fallback

### 7️⃣ **GET /api/v1/payments** ⭐ NUEVO
- **Descripción**: Listar TODOS los pagos registrados (todos los estudiantes)
- **Rol requerido**: `financial-staff`
- **Permiso**: `view.payments`
- **Parámetros**: `search`, `page`, `perPage`, `forceRefresh`
- **Respuesta**: Lista paginada con `id`, `date`, `concept`, `amount`, `amount_received`, `method`, `fullName`
- **Método API**: `StudentAPI.getAllPayments(token, options)`
- **Test**: [test-get-all-payments.ps1](./test-get-all-payments.ps1)
- **Guía**: [GET_PAYMENTS_API_GUIDE.md](./GET_PAYMENTS_API_GUIDE.md)
- **Página**: [payments.astro](./Frond-end/src/pages/payments.astro) refactorizada

### 8️⃣ **GET /api/v1/payments/by-concept** ⭐ NUEVO
- **Descripción**: Obtener pagos agrupados por concepto con estadísticas
- **Rol requerido**: `financial-staff`
- **Permiso**: `view.payments`
- **Parámetros**: `search`, `page`, `perPage`, `forceRefresh`
- **Respuesta**: Agregaciones con `concept_name`, `amount_total`, `amount_received_total`, `collection_rate`, `first_payment_date`, `last_payment_date`
- **Método API**: `StudentAPI.getPaymentsByConcept(token, options)`
- **Test**: [test-payments-by-concept.ps1](./test-payments-by-concept.ps1)
- **Página**: [payments-by-concept.astro](./Frond-end/src/pages/payments-by-concept.astro) ⭐ NUEVO
- **Guía**: [PAYMENTS_BY_CONCEPT_PAGE_GUIDE.md](./PAYMENTS_BY_CONCEPT_PAGE_GUIDE.md)

---

## 📄 Páginas Web (Astro)

### 🔴 Páginas para Estudiantes

#### pending-payments.astro
- **URL**: `/pending-payments`
- **Descripción**: Ver pagos pendientes propios y pagar con Stripe
- **Permisos**: `student` role
- **Features**: 
  - Lista de pagos pendientes con fechas de vencimiento
  - Selección múltiple de pagos
  - Botón "PAGAR CON STRIPE" → genera checkout
  - Total calculado dinámicamente
- **API usada**: `getPendingPayments()`, `createPaymentAttempt()`

#### stripe-payments.astro
- **URL**: `/stripe-payments`
- **Descripción**: Ver historial de pagos realizados con Stripe
- **Permisos**: `student` role (o `financial-staff` con user_id)
- **Features**:
  - Tabla de pagos con fecha, concepto, monto, estado
  - Badges de color según estado (completed, pending, failed)
  - Exportar a Excel
- **API usada**: `getStripePayments()`

### 🟢 Páginas para Personal Financiero

#### debts.astro
- **URL**: `/debts`
- **Descripción**: Dashboard de pagos pendientes (todos los estudiantes)
- **Permisos**: `financial-staff` role, `view.debts` permission
- **Features**:
  - Tabla con nombre estudiante, concepto, monto, fecha vencimiento
  - Modal de validación púrpura (buscar + payment_intent)
  - Botón "Actualizar" para forzar refresh
  - Exportar a Excel
  - **Fallback inteligente**: Intenta `getAllPendingDebts()` → si 404, usa `getPendingPayments()` → localStorage
- **API usada**: `getAllPendingDebts()`, `getPendingPayments()` (fallback), `validateStripePayment()`
- **Guía**: [PAYMENT_VALIDATION_UI_GUIDE.md](./PAYMENT_VALIDATION_UI_GUIDE.md), [GET_DEBTS_API_GUIDE.md](./GET_DEBTS_API_GUIDE.md)

#### payments.astro
- **URL**: `/payments`
- **Descripción**: Dashboard de pagos registrados (todos los estudiantes)
- **Permisos**: `financial-staff` role, `view.payments` permission
- **Features**:
  - Tabla con ID, fecha, estudiante, concepto, monto, monto recibido, método
  - Búsqueda dinámica (cliente-side)
  - Filtro por método de pago (todos/stripe/manual/transfer/cash)
  - Paginación (50 por página)
  - Exportar a Excel
  - **Fallback**: localStorage si API falla
- **API usada**: `getAllPayments()`
- **Guía**: [GET_PAYMENTS_API_GUIDE.md](./GET_PAYMENTS_API_GUIDE.md)

#### payments-by-concept.astro ⭐ NUEVO
- **URL**: `/payments-by-concept`
- **Descripción**: Análisis estadístico de pagos agrupados por concepto
- **Permisos**: `financial-staff` role, `view.payments` permission
- **Features**:
  - 3 tarjetas resumen: Total a Cobrar, Total Recibido, Tasa Global
  - Tabla con concepto, monto total, recibido, tasa cobranza (badge coloreado), rango fechas
  - Búsqueda por nombre de concepto
  - Paginación (20 por página)
  - Exportar a Excel con 7 columnas
  - Badges de cobranza:
    - 🟢 Verde ≥90%
    - 🟡 Amarillo ≥70%
    - 🔴 Rojo <70%
- **API usada**: `getPaymentsByConcept()`
- **Guía**: [PAYMENTS_BY_CONCEPT_PAGE_GUIDE.md](./PAYMENTS_BY_CONCEPT_PAGE_GUIDE.md)

---

## 🧪 Scripts de Prueba (PowerShell)

### test-get-all-debts.ps1
- **Endpoint**: GET /api/v1/debts
- **Parámetros**: `-BaseUrl`, `-Token`, `-Search`, `-Page`, `-PerPage`, `-ForceRefresh`
- **Output**: Tabla coloreada con paginación, detalles de deudas, JSON completo
- **Ejemplos**: 7 casos de uso (buscar por email, CURP, n_control, paginación)

### test-get-all-payments.ps1
- **Endpoint**: GET /api/v1/payments
- **Parámetros**: `-BaseUrl`, `-Token`, `-Search`, `-Page`, `-PerPage`, `-ForceRefresh`
- **Output**: Tabla coloreada con ID, fecha, concepto, montos, método, nombre completo
- **Ejemplos**: 7 casos de uso (buscar por email, nombre, concepto, paginación)

### test-payments-by-concept.ps1 ⭐ NUEVO
- **Endpoint**: GET /api/v1/payments/by-concept
- **Parámetros**: `-BaseUrl`, `-Token`, `-Search`, `-Page`, `-PerPage`, `-ForceRefresh`
- **Output**: 
  - Estadísticas por concepto (coloreadas según tasa)
  - Resumen general con totales
  - Tasa global de cobranza calculada
- **Ejemplos**: 6 casos de uso (buscar "inscripción", "mensual", "cuota", paginación)
- **Helper**: `Format-Currency` para formato mexicano

---

## 📘 Archivos de Código

### studentAPI.js
**Ubicación**: `Frond-end/src/utils/studentAPI.js`

**Métodos de Pagos** (8 métodos):
```javascript
1. getPendingPayments(userId, token)
2. getOverduePayments(userId, token)
3. createPaymentAttempt(paymentIds)
4. getStripePayments(userId, token)
5. validateStripePayment(search, paymentIntent, token)
6. getAllPendingDebts(token, options)      // ⭐ NUEVO
7. getAllPayments(token, options)          // ⭐ NUEVO
8. getPaymentsByConcept(token, options)    // ⭐ NUEVO
```

**Características comunes**:
- Todos usan `API_BASE` constante
- Headers: `Authorization: Bearer ${token}`, `X-User-Role`, `X-User-Permission`
- Query params con `URLSearchParams`
- Try-catch con console logging
- Retornan objeto con `{ success, message, data }`

---

## 📚 Documentación

### Guías de Endpoints Nuevos
1. [GET_DEBTS_API_GUIDE.md](./GET_DEBTS_API_GUIDE.md)
   - Endpoint GET /api/v1/debts
   - Ejemplos de respuesta
   - Casos de uso
   - Integración en debts.astro

2. [GET_PAYMENTS_API_GUIDE.md](./GET_PAYMENTS_API_GUIDE.md)
   - Endpoint GET /api/v1/payments
   - Estructura de datos
   - Ejemplos de filtrado
   - Integración en payments.astro

3. [PAYMENTS_BY_CONCEPT_PAGE_GUIDE.md](./PAYMENTS_BY_CONCEPT_PAGE_GUIDE.md) ⭐ NUEVO
   - Endpoint GET /api/v1/payments/by-concept
   - Explicación de estadísticas agrupadas
   - Uso de badges coloreados
   - Casos de uso para reportes ejecutivos

### Guías Existentes
4. [PAYMENT_VALIDATION_UI_GUIDE.md](./PAYMENT_VALIDATION_UI_GUIDE.md)
   - Modal de validación de pagos de Stripe
   - Endpoint POST /api/v1/payments/validate-stripe
   - Búsqueda por correo/CURP/n_control
   - Secciones de resultado (estudiante/pago/reconciliación)

---

## 🎨 Patrones de Diseño UI

### Paleta de Colores por Rol

**Estudiantes (Verde)**:
- Primary: `#2E594D` (verde CBTA)
- Botones: `bg-green-700`
- Hover: `hover:bg-green-800`

**Personal Financiero**:
- **Deudas**: Gradientes naranja/rojo/coral
- **Pagos**: Gradientes azul/cian
- **Análisis**: Gradientes púrpura/índigo/rosa
- **Validación modal**: Púrpura `#9333ea`

### Componentes Reutilizables

**Badges de Estado**:
```html
<!-- Cobranza alta -->
<span class="collection-badge collection-high">95%</span>

<!-- Cobranza media -->
<span class="collection-badge collection-medium">75%</span>

<!-- Cobranza baja -->
<span class="collection-badge collection-low">45%</span>
```

**Botones de Acción**:
- Actualizar: Azul `bg-blue-600`
- Exportar: Verde `bg-emerald-700`
- Pagar: Verde CBTA `bg-[#2E594D]`
- Validar: Púrpura `bg-purple-600`

**Iconos SVG**:
- 🔍 Búsqueda (lupa)
- 🔄 Actualizar (flechas circular)
- 📥 Exportar (flecha abajo)
- 💳 Pagar (tarjeta)
- ✅ Validar (check)
- 📊 Estadísticas (gráfico)

---

## 🚀 Flujo de Trabajo Completo

### Para Estudiantes

1. **Ver pagos pendientes** → `/pending-payments`
2. **Seleccionar pagos** → Click checkbox
3. **Pagar con Stripe** → Botón "PAGAR CON STRIPE"
4. **Redirigir a Stripe Checkout** → Completar pago
5. **Ver historial** → `/stripe-payments`

### Para Personal Financiero

#### Dashboard de Deudas
1. **Ver todas las deudas** → `/debts`
2. **Buscar estudiante** → Input búsqueda
3. **Exportar reporte** → Botón EXPORTAR
4. **Validar pago manual** → Modal púrpura → Buscar + Payment Intent

#### Dashboard de Pagos
1. **Ver todos los pagos** → `/payments`
2. **Filtrar por método** → Dropdown (stripe/manual/transfer/cash)
3. **Buscar por término** → Input búsqueda
4. **Exportar listado** → Botón EXPORTAR

#### Análisis Estadístico ⭐ NUEVO
1. **Ver análisis por concepto** → `/payments-by-concept`
2. **Revisar tasas de cobranza** → Badges coloreados
3. **Buscar concepto específico** → Input búsqueda
4. **Identificar conceptos problemáticos** → Badges rojos (<70%)
5. **Exportar reporte ejecutivo** → Botón EXPORTAR

---

## 🔐 Matriz de Permisos

| Endpoint | Rol | Permiso | Página |
|----------|-----|---------|--------|
| GET /payments/pending/:id | student | view.debts | pending-payments.astro |
| GET /payments/overdue/:id | financial-staff | view.debts | debts.astro |
| POST /payments/attempt | student | create.payment | pending-payments.astro |
| GET /payments/stripe/:id | student / financial-staff | view.payments | stripe-payments.astro |
| POST /payments/validate-stripe | financial-staff | validate.debt | debts.astro (modal) |
| **GET /debts** | **financial-staff** | **view.debts** | **debts.astro** |
| **GET /payments** | **financial-staff** | **view.payments** | **payments.astro** |
| **GET /payments/by-concept** | **financial-staff** | **view.payments** | **payments-by-concept.astro** |

---

## 🛠️ Checklist de Implementación Backend

### Endpoints Pendientes de Implementar

- [ ] **GET /api/v1/debts**
  - Query params: search, page, perPage, forceRefresh
  - Join con users y payment_concepts
  - Retornar: user_name, email, concept_name, amount, due_date
  - Paginación con total/page/perPage

- [ ] **GET /api/v1/payments**
  - Query params: search, page, perPage, forceRefresh
  - Filtros: búsqueda por email, nombre, concepto
  - Retornar: id, date, concept, amount, amount_received, method, fullName
  - Paginación con total/page/perPage

- [ ] **GET /api/v1/payments/by-concept**
  - Query params: search, page, perPage, forceRefresh
  - GROUP BY concept_name
  - Calcular: SUM(amount), SUM(amount_received), MIN(date), MAX(date)
  - Calculated field: collection_rate = (received/total)*100
  - Retornar: concept_name, amount_total, amount_received_total, collection_rate, first_payment_date, last_payment_date
  - Incluir general_summary con totales globales

### Verificación Post-Implementación

- [ ] Probar con scripts PowerShell
- [ ] Verificar fallback logic en debts.astro
- [ ] Verificar integración en payments.astro
- [ ] Verificar nueva página payments-by-concept.astro
- [ ] Probar exportación a Excel en todas las páginas
- [ ] Verificar headers X-User-Role y X-User-Permission
- [ ] Probar búsqueda y paginación
- [ ] Probar forceRefresh para limpiar caché

---

## 📊 Estadísticas del Sistema

### Endpoints Implementados
- **Total**: 8 endpoints de pagos
- **Nuevos en esta sesión**: 3 endpoints (debts, payments, payments-by-concept)
- **Métodos**: 5 GET, 2 POST

### Páginas Web
- **Total**: 5 páginas de pagos
- **Nuevas en esta sesión**: 1 página (payments-by-concept.astro)
- **Estudiantes**: 2 páginas
- **Personal financiero**: 3 páginas

### Scripts de Prueba
- **Total**: 3 scripts PowerShell
- **Todos nuevos en esta sesión**
- **Líneas de código**: ~1000 líneas combinadas
- **Ejemplos de uso**: 20 ejemplos totales

### Documentación
- **Total**: 4 guías markdown
- **Nuevas en esta sesión**: 2 guías (GET_PAYMENTS_API_GUIDE, PAYMENTS_BY_CONCEPT_PAGE_GUIDE)
- **Páginas de docs**: ~500 líneas combinadas

---

## 🎯 Casos de Uso Principales

### 1. Identificar Estudiantes Morosos
- Ir a `/debts`
- Buscar por fecha de vencimiento pasada
- Exportar lista de morosos
- Contactar estudiantes

### 2. Reconciliar Pago de Stripe
- Ir a `/debts`
- Click en botón púrpura "Validar Pago de Stripe"
- Buscar estudiante por email/CURP/n_control
- Pegar payment_intent de Stripe Dashboard
- Verificar resultado de reconciliación

### 3. Generar Reporte de Ingresos
- Ir a `/payments`
- Filtrar por fecha (cliente-side)
- Exportar a Excel
- Calcular totales en Excel

### 4. Analizar Conceptos Problemáticos
- Ir a `/payments-by-concept` ⭐ NUEVO
- Revisar badges rojos (<70% cobranza)
- Buscar concepto específico
- Exportar reporte ejecutivo
- Presentar a dirección

### 5. Seguimiento de Pagos de Estudiante
- Ir a `/stripe-payments` (como estudiante)
- Ver historial completo
- Verificar estados (completed/pending/failed)
- Exportar historial personal

---

## 🔄 Patrón de Fallback

### Arquitectura de Recuperación

```javascript
// 1. Intentar nuevo endpoint
try {
    const response = await StudentAPI.getAllPendingDebts(token, options);
    if (response.success) {
        pendingPayments = response.data.payments.items;
        console.log('✅ Endpoint nuevo exitoso');
        return;
    }
} catch (error) {
    console.warn('⚠️ Endpoint nuevo falló, usando fallback');
}

// 2. Usar endpoint antiguo
try {
    const response = await StudentAPI.getPendingPayments(userId, token);
    if (response.success) {
        pendingPayments = response.data;
        console.log('✅ Endpoint fallback exitoso');
        return;
    }
} catch (error) {
    console.warn('⚠️ Endpoint fallback también falló');
}

// 3. Usar localStorage
const cached = localStorage.getItem('pendingPaymentsList');
if (cached) {
    pendingPayments = JSON.parse(cached);
    console.log('✅ Datos cargados desde localStorage');
}
```

**Beneficios**:
- Sin downtime durante despliegue
- Datos siempre disponibles (offline-first)
- Transición suave para usuarios
- Console logs para debugging

---

## 🎓 Conclusión

El sistema de pagos del CBTA 71 ahora incluye:

✅ **Endpoints completos** para estudiantes y personal financiero  
✅ **Páginas web modernas** con búsqueda, filtrado y exportación  
✅ **Scripts de prueba robustos** con ejemplos y color-coding  
✅ **Documentación exhaustiva** con guías paso a paso  
✅ **Análisis estadístico** con tasas de cobranza y reportes ejecutivos ⭐  
✅ **Fallback inteligente** para transición sin interrupciones  
✅ **Diseño consistente** con paleta de colores por rol  

**Estado actual**: Frontend 100% implementado y listo. Backend pendiente de implementar 3 endpoints nuevos (debts, payments, payments-by-concept).

**Próximos pasos**:
1. Backend implementa endpoints usando test scripts como referencia
2. Frontend detecta automáticamente y usa nuevos endpoints
3. Personal financiero usa nueva página de análisis por concepto para reportes ejecutivos

---

## 📞 Soporte

Para preguntas o problemas:
- Revisar logs de consola (F12 en navegador)
- Probar endpoints con scripts PowerShell
- Verificar token y permisos en localStorage
- Consultar guías específicas para cada endpoint

---

**Última actualización**: Enero 2024  
**Versión**: 2.0 (Sistema completo con análisis estadístico)
