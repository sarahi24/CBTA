# 📋 Implementación: Obtener Conceptos de Pago

## 📊 Endpoint Implementado

### GET `/api/v1/dashboard-staff/concepts`

Obtiene una lista paginada de conceptos de pago del personal financiero.

## 🎯 Headers Requeridos

```
Authorization: Bearer {token}
X-User-Role: financial-staff
X-User-Permission: view.concepts.history
Content-Type: application/json
Accept: application/json
```

## 📝 Parámetros de Query

| Parámetro | Tipo | Por Defecto | Descripción |
|-----------|------|-------------|-------------|
| `only_this_year` | boolean | `true` | Filtra conceptos del año actual |
| `page` | integer | `1` | Número de página |
| `perPage` | integer | `15` | Registros por página |
| `forceRefresh` | boolean | `false` | Fuerza actualización del caché |

## ✅ Respuesta Exitosa (200)

```json
{
  "success": true,
  "message": "Operación completada exitosamente",
  "data": {
    "concepts": {
      "items": [
        {
          "id": 1,
          "concept_name": "Pago de inscripción",
          "status": "activo",
          "amount": "1500.00",
          "applies_to": "todos",
          "start_date": "2025-11-01",
          "end_date": "2025-12-01"
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

## 🚀 Implementación en el Frontend

### 1. Servicio API (dashboardAPI.js)

Ya existe la función `getConcepts()` implementada:

```javascript
async getConcepts(token, onlyThisYear = true, page = 1, perPage = 15, forceRefresh = false)
```

### 2. Componente ConceptsTable.astro

**Actualizado para usar la API:**
- ✅ Llama a `DashboardAPI.getConcepts()` al cargar
- ✅ Muestra los primeros 5 conceptos en el dashboard
- ✅ Formatea montos en MXN
- ✅ Muestra estados con badges de colores
- ✅ Manejo de errores y estados de carga
- ✅ Enlace "Ver todos →" para ir a la lista completa

**Características:**
- Loading state con spinner
- Estado de error con botón de reintento
- Formato de moneda en pesos mexicanos
- Formato de fechas (YYYY-MM-DD)
- Estados visuales (activo/inactivo)

### 3. Ubicación en el Dashboard

El componente se muestra en:
- **Dashboard principal** → Sección "Conceptos Registrados"
- Muestra resumen de 5 conceptos más recientes
- Enlace directo a `/concepts` para gestión completa

## 🧪 Cómo Probar

### Desde PowerShell

```powershell
.\test-get-concepts.ps1
```

El script interactivo te permite:
- ✅ Especificar parámetros de búsqueda
- ✅ Filtrar por año actual o todos los años
- ✅ Configurar paginación (página, registros por página)
- ✅ Forzar actualización del caché
- ✅ Ver respuesta formateada
- ✅ Navegar entre páginas

### Desde la Interfaz Web

1. **Dashboard:**
   - Ve al Dashboard principal
   - La sección "Conceptos Registrados" mostrará los 5 más recientes
   - Haz clic en "Ver todos →" para ir a la gestión completa

2. **Página de Conceptos (existente):**
   - Navega a `/concepts`
   - Gestión completa de conceptos disponible

## 📊 Ejemplo de Uso Interactivo

### Filtros Disponibles:

```javascript
// Solo conceptos del año actual, página 1, 15 por página
DashboardAPI.getConcepts(token, true, 1, 15, false)

// Todos los conceptos, página 2, 25 por página, forzar refresh
DashboardAPI.getConcepts(token, false, 2, 25, true)
```

## 🎨 Estados Visuales

### Loading
```
┌─────────────────────────────┐
│     [Spinner animado]       │
│  Cargando conceptos...      │
└─────────────────────────────┘
```

### Sin Datos
```
┌─────────────────────────────┐
│ No hay conceptos registrados│
└─────────────────────────────┘
```

### Error
```
┌─────────────────────────────┐
│       [Icono error]         │
│ Error al cargar conceptos   │
│     [Botón Reintentar]      │
└─────────────────────────────┘
```

### Datos Cargados
```
┌──────────────────────────────────────────────────┐
│ Concepto  │ Monto    │ Estado │ Inicio │ Fin    │
├──────────────────────────────────────────────────┤
│ INSCR...  │ $1,500.00│ ACTIVO │ 2025.. │ 2025.. │
│ COLEGIAT..│ $2,000.00│ ACTIVO │ 2025.. │ 2025.. │
└──────────────────────────────────────────────────┘
│               Ver todos →                        │
└──────────────────────────────────────────────────┘
```

## ⚠️ Códigos de Respuesta

| Código | Descripción | Acción |
|--------|-------------|--------|
| 200 | Éxito | Conceptos obtenidos |
| 401 | No autenticado | Verificar token |
| 403 | No autorizado | Verificar rol y permisos |
| 429 | Demasiadas solicitudes | Esperar y reintentar |
| 500 | Error interno | Revisar logs del servidor |

## 🔐 Seguridad

**Permisos requeridos:**
- Rol: `financial-staff`
- Permiso: `view.concepts.history`

## 📁 Archivos Modificados/Creados

### Modificados:
- ✅ `Frond-end/src/components/ConceptsTable.astro` - Actualizado para usar API

### Creados:
- ✅ `test-get-concepts.ps1` - Script de prueba PowerShell
- ✅ `CONCEPTS_API_IMPLEMENTATION.md` - Esta documentación

### Sin Cambios (ya existían):
- ✅ `Frond-end/src/utils/dashboardAPI.js` - Ya tenía la función getConcepts
- ✅ `Frond-end/src/pages/Dashboard.astro` - Ya mostraba ConceptsTable
- ✅ `Frond-end/src/pages/concepts.astro` - Página de gestión completa

## 🔄 Flujo de Funcionamiento

```
Dashboard carga
       ↓
ConceptsTable.astro se monta
       ↓
Obtiene token de localStorage
       ↓
Llama a DashboardAPI.getConcepts(token, true, 1, 5, false)
       ↓
Muestra loading
       ↓
API responde
       ↓
Renderiza tabla con datos
       ↓
Usuario puede hacer clic en "Ver todos"
       ↓
Redirige a /concepts (gestión completa)
```

## 💡 Características Clave

1. **Caché Inteligente:** 
   - Por defecto usa caché para mejor rendimiento
   - Opción `forceRefresh` para actualizar cuando sea necesario

2. **Paginación:** 
   - Control total sobre página actual y registros por página
   - Información de total, páginas siguientes/anteriores

3. **Filtros:**
   - Filtrado por año actual o histórico completo
   - Fácil extensión para más filtros

4. **UX Optimizada:**
   - Estados de carga claros
   - Manejo de errores con reintentos
   - Vista previa en dashboard + gestión completa

## 📚 Ejemplos de Uso

### JavaScript en el Frontend

```javascript
import { DashboardAPI } from '../utils/dashboardAPI.js';

// Obtener conceptos básicos
const response = await DashboardAPI.getConcepts(token);

// Con paginación personalizada
const response = await DashboardAPI.getConcepts(
  token,
  true,  // solo este año
  2,     // página 2
  25,    // 25 por página
  false  // usar caché
);

// Acceder a los datos
if (response.success) {
  const concepts = response.data.concepts.items;
  const total = response.data.concepts.total;
  const hasMore = response.data.concepts.hasMorePages;
}
```

### PowerShell (API directa)

```powershell
$headers = @{
    "Authorization" = "Bearer $token"
    "X-User-Role" = "financial-staff"
    "X-User-Permission" = "view.concepts.history"
}

$url = "https://nginx-production-728f.up.railway.app/api/v1/dashboard-staff/concepts?only_this_year=true&page=1&perPage=15"

$response = Invoke-RestMethod -Uri $url -Method Get -Headers $headers
```

## ✨ Mejoras Futuras Sugeridas

1. Búsqueda por nombre de concepto
2. Filtros por estado (activo/inactivo)
3. Filtros por rango de monto
4. Filtros por rango de fechas
5. Exportar a Excel/PDF
6. Ordenamiento por columnas
7. Vista de detalles de concepto individual

---

**Estado:** ✅ Completado y funcional
**Fecha:** Febrero 2026
