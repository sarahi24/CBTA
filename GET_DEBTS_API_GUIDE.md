# GET /api/v1/debts - List All Pending Payments

## Endpoint Overview

**GET /api/v1/debts** - Retrieve a paginated list of all pending payments across the institution.

### Purpose
Financial staff can view all pending student debts with search, filtering, and pagination capabilities. The endpoint returns user names and concept names directly, eliminating the need for separate API calls.

## API Specification

### Request

**Method:** GET  
**URL:** `https://nginx-production-728f.up.railway.app/api/v1/debts`

### Headers (Required)
```
Authorization: Bearer {token}
X-User-Role: financial-staff
X-User-Permission: view.debts
Content-Type: application/json
Accept: application/json
```

### Query Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `search` | string | No | - | Search by email, CURP, or n_control |
| `page` | integer | No | 1 | Page number for pagination |
| `perPage` | integer | No | 15 | Items per page (max typically 100) |
| `forceRefresh` | boolean | No | false | Force cache update |

### Response (200 OK)

```json
{
  "success": true,
  "message": "Operación completada exitosamente",
  "data": {
    "pending_payments": {
      "items": [
        {
          "user_name": "Juan Pérez García",
          "concept_name": "Pago de inscripción",
          "amount": "1500.00"
        },
        {
          "user_name": "María López Rodríguez",
          "concept_name": "Cuota mensual",
          "amount": "2500.00"
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

### Response Fields

**Pagination Info:**
- `currentPage` - Current page number (integer)
- `lastPage` - Last available page number (integer)
- `perPage` - Items per page (integer)
- `total` - Total number of pending payments (integer)
- `hasMorePages` - Boolean indicating more pages available
- `nextPage` - Next page number (integer or null)
- `previousPage` - Previous page number (integer or null)

**Item Fields:**
- `user_name` - Full name of student (string)
- `concept_name` - Name of the payment concept/charge (string)
- `amount` - Amount owed in MXN (string, decimal format)

## Error Responses

### 401 Unauthorized
```json
{
  "success": false,
  "message": "No autenticado. Por favor inicia sesión.",
  "error_code": "UNAUTHENTICATED",
  "errors": {}
}
```

### 403 Forbidden
```json
{
  "success": false,
  "message": "No tienes permiso para ver los adeudos.",
  "error_code": "FORBIDDEN",
  "errors": {}
}
```

### 422 Validation Error
```json
{
  "success": false,
  "message": "Error de validación",
  "error_code": "VALIDATION_ERROR",
  "errors": {
    "page": ["El campo deben ser números positivos"],
    "perPage": ["El campo perPage debe ser entre 1 y 100"]
  }
}
```

### 429 Rate Limited
```json
{
  "success": false,
  "message": "Demasiadas solicitudes. Intenta más tarde.",
  "error_code": "TOO_MANY_REQUESTS",
  "errors": {}
}
```

### 500 Server Error
```json
{
  "success": false,
  "message": "Error interno del servidor",
  "error_code": "SERVER_ERROR",
  "errors": {}
}
```

## Implementation

### JavaScript/Astro Integration

**Method in StudentAPI:**
```javascript
async getAllPendingDebts(token, options = {}) {
  const {
    search = '',
    page = 1,
    perPage = 15,
    forceRefresh = false
  } = options;
  
  // Construir URL con parámetros
  const params = new URL(`${API_BASE}/debts`);
  if (search) params.searchParams.append('search', search);
  params.searchParams.append('page', page);
  params.searchParams.append('perPage', perPage);
  if (forceRefresh) params.searchParams.append('forceRefresh', 'true');
  
  // Request con headers de autenticación
  const response = await fetch(params.toString(), {
    method: 'GET',
    headers: {
      'Authorization': `Bearer ${token}`,
      'X-User-Role': 'financial-staff',
      'X-User-Permission': 'view.debts'
    }
  });
  
  return await response.json();
}
```

**Usage in Astro Component:**
```javascript
// Load all pending debts
const response = await StudentAPI.getAllPendingDebts(token, {
  search: searchTerm,
  page: 1,
  perPage: 50,
  forceRefresh: true
});

if (response.success) {
  const debts = response.data.pending_payments.items;
  const pagination = {
    current: response.data.pending_payments.currentPage,
    last: response.data.pending_payments.lastPage,
    total: response.data.pending_payments.total
  };
}
```

## PowerShell Testing

**Test Script:** `test-get-all-debts.ps1`

### Basic Usage
```powershell
.\test-get-all-debts.ps1 -Token "your-bearer-token"
```

### With Search
```powershell
# Search by email
.\test-get-all-debts.ps1 -Token "your-token" -Search "juan.perez@example.com"

# Search by CURP
.\test-get-all-debts.ps1 -Token "your-token" -Search "SAQ890101HDFLRR99"

# Search by No. Control
.\test-get-all-debts.ps1 -Token "your-token" -Search "23001234"
```

### With Pagination
```powershell
# Get page 2 with 25 items per page
.\test-get-all-debts.ps1 -Token "your-token" -Page 2 -PerPage 25

# Force cache refresh
.\test-get-all-debts.ps1 -Token "your-token" -ForceRefresh $true
```

### Combined Example
```powershell
.\test-get-all-debts.ps1 `
  -Token "your-token" `
  -Search "juan" `
  -Page 1 `
  -PerPage 50 `
  -ForceRefresh $true
```

## Usage Examples

### Get First Page of All Debts
```bash
curl -X GET "https://nginx-production-728f.up.railway.app/api/v1/debts?page=1&perPage=15" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "X-User-Role: financial-staff" \
  -H "X-User-Permission: view.debts" \
  -H "Content-Type: application/json"
```

### Search Student by Email
```bash
curl -X GET "https://nginx-production-728f.up.railway.app/api/v1/debts?search=juan.perez@example.com" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "X-User-Role: financial-staff" \
  -H "X-User-Permission: view.debts"
```

### Get Second Page with Custom Pagination
```bash
curl -X GET "https://nginx-production-728f.up.railway.app/api/v1/debts?page=2&perPage=50&forceRefresh=true" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "X-User-Role: financial-staff" \
  -H "X-User-Permission: view.debts"
```

## Frontend Integration

### Modified debts.astro Page
The debts.astro page now uses `getAllPendingDebts()` to fetch all pending payments:

**Data Flow:**
1. Page loads and calls `loadPendingPayments()`
2. `loadPendingPayments()` calls `StudentAPI.getAllPendingDebts(token, options)`
3. API returns paginated list with pagination metadata
4. Data is displayed in table with 50 items per page
5. Client-side pagination for navigation
6. Search filters results locally
7. Export to Excel functionality included

**Features:**
- ✅ Paginated display (50 items per page client-side)
- ✅ Real-time search filtering
- ✅ Refresh button with cache force option
- ✅ Export to Excel
- ✅ Payment validation modal
- ✅ Manual payment registration
- ✅ Error handling with user-friendly messages

### Key Changes from Previous Implementation
| Before | After |
|--------|-------|
| getPendingPayments(null, ...) | getAllPendingDebts(token, {...}) |
| Local student/concept lookups | Direct user_name/concept_name |
| Less pagination metadata | Full pagination info |
| Limited search capability | Server-side + client-side search |

## Best Practices

### Performance
- **Use `forceRefresh: true` sparingly** - Only when cache might be stale
- **Adjust `perPage` parameter** - Use 50-100 for large result sets to reduce requests
- **Implement local caching** - Store response in localStorage for offline access
- **Paginate strategically** - Load current page + preload next page

### Security
- **Always include X-User-Role and X-User-Permission headers**
- **Validate token expiration before requests**
- **Handle 401/403 errors appropriately** - Redirect to login on auth failure
- **Never expose tokens in URL** - Use Authorization header
- **Sanitize search input** - Prevent injection attacks

### Error Handling
```javascript
try {
  const response = await StudentAPI.getAllPendingDebts(token, {
    search: userInput,
    page: 1,
    perPage: 50
  });
  
  if (!response.success) {
    // Handle API errors
    throw new Error(response.message);
  }
  
  // Process data
} catch (error) {
  if (error.message.includes('autenticado')) {
    // Redirect to login
  } else if (error.message.includes('permiso')) {
    // Show access denied message
  } else {
    // Show generic error
  }
}
```

## Rate Limiting

- **Limit:** 100 requests per minute per user
- **Headers:** 
  - `X-RateLimit-Limit: 100`
  - `X-RateLimit-Remaining: 95`
  - `X-RateLimit-Reset: 1707193200`
- **Response:** Receive 429 when exceeded
- **Throttle:** Wait for reset time before retrying

## Caching

- **Default TTL:** 5 minutes
- **Force Refresh:** Set `forceRefresh=true` to bypass cache
- **Cache Key:** `debts:{user_role}:{search_term}:{page}:{perPage}`
- **Invalidation:** On successful payment, user creation, or manual cache flush

## Related Endpoints

- **GET /api/v1/pending-payments** - Get payments for specific student
- **POST /api/v1/pending-payments** - Create payment intent for checkout
- **GET /api/v1/pending-payments/overdue** - Get overdue payments only
- **GET /api/v1/debts/stripe-payments** - Get Stripe payment history
- **POST /api/v1/debts/validate** - Validate Stripe payment

## Changelog

### Version 1.0 (Current)
- ✅ Initial implementation
- ✅ Pagination support
- ✅ Search by email, CURP, n_control
- ✅ Cache management
- ✅ Rate limiting
- ✅ Comprehensive error handling

### Future Enhancements
- Filter by date range
- Filter by concept type
- Sort by amount, name, date
- Bulk operations support
- Export to PDF format
- Real-time updates via WebSocket
