# 📊 Guía: Página de Análisis de Pagos por Concepto

## 📋 Resumen General

La página **payments-by-concept.astro** proporciona un análisis estadístico de los pagos agrupados por concepto (inscripción, mensualidad, cuota especial, etc.), mostrando tasas de cobranza, rangos de fechas y totales por concepto.

---

## 🎯 Características Principales

### 1. **Tarjetas de Resumen Global**

Tres tarjetas con gradientes morados/rosas/azules mostrando:
- **Total a Cobrar**: Suma de todos los montos de pagos (amount_total)
- **Total Recibido**: Suma de todos los montos efectivamente recibidos (amount_received_total)
- **Tasa Global**: Porcentaje de cobranza global calculado como (Recibido/Cobrar) * 100

### 2. **Tabla de Conceptos**

Cada fila muestra:
- **Concepto**: Nombre del concepto de pago (INSCRIPCIÓN, MENSUALIDAD ENERO, etc.)
- **Monto Total**: Total acumulado a cobrar para ese concepto
- **Recibido**: Total acumulado recibido para ese concepto
- **Cobranza**: Badge circular con color según porcentaje:
  - 🟢 Verde (≥90%): Cobranza excelente
  - 🟡 Amarillo (≥70%): Cobranza media
  - 🔴 Rojo (<70%): Cobranza baja
- **Fechas**: Rango desde el primer pago hasta el último pago registrado

### 3. **Búsqueda en Tiempo Real**

Input de búsqueda que filtra conceptos por nombre, con actualización instantánea de:
- Tabla filtrada
- Resumen global recalculado
- Paginación ajustada

### 4. **Exportación a Excel**

Botón verde que genera archivo `.xlsx` con 7 columnas:
- No. | Concepto | Monto Total | Recibido | Tasa Cobranza (%) | Primera Fecha | Última Fecha

---

## 🔧 Endpoints Utilizados

### GET /api/v1/payments/by-concept

**Headers requeridos:**
```javascript
Authorization: Bearer <token>
X-User-Role: financial-staff
X-User-Permission: view.payments
```

**Parámetros opcionales:**
- `search`: Filtrar por nombre de concepto
- `page`: Número de página (default: 1)
- `perPage`: Registros por página (default: 15)
- `forceRefresh`: Forzar actualización de caché (default: false)

**Respuesta esperada:**
```json
{
  "success": true,
  "message": "Pagos agrupados por concepto obtenidos exitosamente",
  "data": {
    "payments": {
      "items": [
        {
          "concept_name": "INSCRIPCIÓN",
          "amount_total": 5000.00,
          "amount_received_total": 4500.00,
          "collection_rate": 90.00,
          "first_payment_date": "2024-01-15",
          "last_payment_date": "2024-01-30"
        }
      ],
      "total": 12,
      "page": 1,
      "perPage": 15
    },
    "general_summary": {
      "amount_total": 120000.00,
      "amount_received_total": 108000.00,
      "global_collection_rate": 90.00
    }
  }
}
```

---

## 🎨 Diseño y Estilos

### Paleta de Colores

- **Encabezados tabla**: Gradiente púrpura-índigo (#667eea → #764ba2)
- **Tarjetas resumen**:
  - Total a Cobrar: Púrpura-Morado (#667eea → #764ba2)
  - Total Recibido: Rosa-Rojo (#f093fb → #f5576c)
  - Tasa Global: Azul-Cian (#4facfe → #00f2fe)
- **Badges cobranza**:
  - Verde: `#d1fae5` con texto `#065f46`
  - Amarillo: `#fef3c7` con texto `#92400e`
  - Rojo: `#fee2e2` con texto `#991b1b`

### Iconos

- 📊 Gráfico de barras (header)
- 🔄 Actualizar (botón refresh)
- 📥 Descargar (botón exportar)
- 🔍 Lupa (input búsqueda)

---

## 💻 Flujo de Operación

### 1. Carga Inicial

```javascript
loadConcepts() → fetch API → allConcepts = [] → render()
```

### 2. Búsqueda

```javascript
searchInput.oninput → filtrar allConcepts → currentPage=1 → render()
```

### 3. Actualización Manual

```javascript
refreshBtn.click → loadConcepts(forceRefresh=true) → render()
```

### 4. Exportación

```javascript
exportBtn.click → XLSX.utils.json_to_sheet(filteredConcepts) → download .xlsx
```

### 5. Paginación

```javascript
pageButton.click → currentPage = X → render() → scroll to top
```

---

## 🔐 Permisos Requeridos

Para acceder a esta página, el usuario debe tener:

1. **Token válido** en localStorage (`access_token`)
2. **Rol**: `financial-staff`
3. **Permiso**: `view.payments`

Si falta alguno, la API responderá:
- **401**: Token inválido o expirado
- **403**: Sin permisos suficientes

---

## 🧪 Pruebas

### Caso 1: Búsqueda por Concepto

1. Cargar página
2. Escribir "INSCRIPCIÓN" en búsqueda
3. Verificar que tabla muestre solo conceptos con "inscripción"
4. Verificar que tarjetas resumen se recalculen

### Caso 2: Exportación Filtrada

1. Buscar "MENSUALIDAD"
2. Click en botón EXPORTAR
3. Verificar que archivo Excel contenga solo conceptos filtrados
4. Verificar 7 columnas correctas

### Caso 3: Paginación

1. Cargar página con >20 conceptos
2. Verificar que aparezcan botones de paginación
3. Click en página 2
4. Verificar que tabla muestre ítems 21-40
5. Verificar scroll automático al top

### Caso 4: Actualización Forzada

1. Click en botón ACTUALIZAR
2. Verificar spinner de carga
3. Verificar que botón esté deshabilitado durante carga
4. Verificar parámetro `forceRefresh=true` en llamada API

---

## 📂 Estructura del Código

### Variables de Estado

```javascript
let currentPage = 1;           // Página actual de paginación
const itemsPerPage = 20;       // 20 conceptos por página
let allConcepts = [];          // Todos los conceptos desde API
let filteredConcepts = [];     // Conceptos después de buscar
let isLoading = false;         // Flag prevenir doble carga
```

### Funciones Principales

1. **loadConcepts(forceRefresh)**
   - Llama a `StudentAPI.getPaymentsByConcept()`
   - Maneja spinner de carga
   - Actualiza `allConcepts`
   - Llama a `render()`

2. **render()**
   - Filtra conceptos por búsqueda
   - Calcula resumen global (3 tarjetas)
   - Pagina resultados
   - Renderiza filas de tabla
   - Llama a `renderPagination()`

3. **renderPagination(totalPages)**
   - Genera botones numerados
   - Resalta página activa
   - Configura event listeners

4. **fmt(amount)**
   - Formatea números como moneda: `$1,234.56`

5. **getCollectionClass(rate)**
   - Retorna clase CSS según porcentaje:
     - `collection-high` (≥90%)
     - `collection-medium` (≥70%)
     - `collection-low` (<70%)

---

## 🚀 Casos de Uso

### Para Personal Financiero

1. **Identificar conceptos con baja cobranza**
   - Buscar badges rojos en columna "Cobranza"
   - Ordenar mentalmente por porcentaje
   - Tomar acciones de cobranza en conceptos <70%

2. **Analizar rangos de pago**
   - Revisar columna "Fechas"
   - Identificar conceptos activos (rango reciente)
   - Identificar conceptos obsoletos (sin pagos recientes)

3. **Generar reportes ejecutivos**
   - Exportar tabla a Excel
   - Usar tarjetas resumen para presentaciones
   - Calcular tasa global de cobranza

4. **Búsqueda específica**
   - Buscar "ENERO" para ver mensualidades de enero
   - Buscar "INSCRIPCIÓN" para análisis de ingresos iniciales
   - Buscar "LABORATORIO" para pagos de talleres

---

## 🐛 Manejo de Errores

### No hay token
```javascript
if (!token) {
    console.warn('⚠️ No hay token de autenticación');
    render(); // Renderiza vacío
}
```

### Error de API
```javascript
catch (error) {
    console.error('❌ Error al cargar conceptos:', error);
    alert('Error al cargar datos: ' + error.message);
}
```

### Sin datos para exportar
```javascript
if (filteredConcepts.length === 0) {
    return alert('No hay datos para exportar');
}
```

---

## 🔄 Integración con Sistema

### Navegación Recomendada

Agregar enlace en menú principal para personal financiero:

```html
<a href="/payments-by-concept" class="menu-link">
    📊 Análisis por Concepto
</a>
```

### Permisos de Acceso

Proteger ruta en middleware/layout:
```javascript
const allowedRoles = ['financial-staff', 'admin'];
const allowedPermissions = ['view.payments'];
```

---

## 📊 Visualización de Datos

### Ejemplo de Tabla Renderizada

```
┌─────────────────┬─────────────┬────────────┬──────────┬──────────────────┐
│ Concepto        │ Monto Total │ Recibido   │ Cobranza │ Fechas           │
├─────────────────┼─────────────┼────────────┼──────────┼──────────────────┤
│ INSCRIPCIÓN     │ $5,000.00   │ $4,800.00  │ [96% 🟢] │ 2024-01-15       │
│                 │             │            │          │ a 2024-01-30     │
├─────────────────┼─────────────┼────────────┼──────────┼──────────────────┤
│ MENSUALIDAD ENE │ $12,000.00  │ $9,600.00  │ [80% 🟡] │ 2024-02-01       │
│                 │             │            │          │ a 2024-02-15     │
├─────────────────┼─────────────┼────────────┼──────────┼──────────────────┤
│ CUOTA LAB       │ $3,200.00   │ $1,920.00  │ [60% 🔴] │ 2024-03-01       │
│                 │             │            │          │ a 2024-03-10     │
└─────────────────┴─────────────┴────────────┴──────────┴──────────────────┘
```

---

## 🎯 Mejoras Futuras Sugeridas

### 1. Gráficos Interactivos

- Chart.js para gráfico de barras de cobranza
- Pie chart con distribución de conceptos
- Línea de tiempo de cobranza mensual

### 2. Ordenamiento

- Click en encabezados de columna para ordenar
- Ascendente/descendente por monto, tasa, fecha

### 3. Filtros Avanzados

- Selector de rango de fechas
- Filtro por tasa mínima/máxima
- Filtro por monto mínimo

### 4. Detalle por Concepto

- Modal con lista de pagos individuales
- Click en fila para ver desglose
- Gráfico de tendencia por concepto

---

## 📝 Notas Importantes

1. **Paginación**: 20 conceptos por página (ajustable en `itemsPerPage`)
2. **Carga inicial**: Solicita 1000 registros para evitar múltiples llamadas
3. **Búsqueda**: Filtra localmente sin llamar API (mejor UX)
4. **Formato moneda**: Usa `toLocaleString('es-MX')` para formato mexicano
5. **Export filename**: Incluye fecha actual: `Pagos_Por_Concepto_DD-MM-YYYY.xlsx`

---

## 🔗 Archivos Relacionados

- **API Client**: [src/utils/studentAPI.js](../Frond-end/src/utils/studentAPI.js) → Método `getPaymentsByConcept()`
- **Test Script**: [test-payments-by-concept.ps1](../test-payments-by-concept.ps1)
- **Documentación endpoints**: API_REFERENCE_COMPLETE.md
- **Páginas relacionadas**:
  - [payments.astro](../Frond-end/src/pages/payments.astro) - Lista individual de pagos
  - [debts.astro](../Frond-end/src/pages/debts.astro) - Lista de pagos pendientes

---

## ✅ Checklist de Implementación Backend

Cuando el backend implemente el endpoint, verificar:

- [ ] Endpoint responde en `/api/v1/payments/by-concept`
- [ ] Acepta parámetros: search, page, perPage, forceRefresh
- [ ] Retorna estructura con `items[]` y `general_summary`
- [ ] Cada item incluye: concept_name, amount_total, amount_received_total, collection_rate, first_payment_date, last_payment_date
- [ ] Respeta headers X-User-Role y X-User-Permission
- [ ] Maneja errores 401, 403, 500 correctamente
- [ ] Paginación funciona con page/perPage
- [ ] Búsqueda filtra por concepto (case-insensitive)
- [ ] collection_rate calculado correctamente: (received/total)*100

---

## 🎓 Conclusión

Esta página de análisis por concepto proporciona una vista estratégica de la salud financiera del CBTA 71, permitiendo al personal financiero identificar rápidamente áreas problemáticas, generar reportes ejecutivos y tomar decisiones informadas sobre estrategias de cobranza.

**Página lista para usar** cuando el backend implemente el endpoint correspondiente. Frontend incluye manejo robusto de errores y experiencia de usuario fluida. 🚀
