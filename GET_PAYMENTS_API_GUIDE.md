# GET /api/v1/payments - List All Payments

## Endpoint Overview

**GET /api/v1/payments** - Retrieve a paginated list of all registered payments across the institution.

### Purpose
Financial staff can view all recorded student payments with search, filtering, and pagination capabilities. The endpoint returns complete payment information including student names, payment methods, amounts, and dates.

## API Specification

### Request

**Method:** GET  
**URL:** `https://nginx-production-728f.up.railway.app/api/v1/payments`

### Headers (Required)
```
Authorization: Bearer {token}
X-User-Role: financial-staff
X-User-Permission: view.payments
Content-Type: application/json
Accept: application/json
```

### Query Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `search` | string | No | - | Search by email, CURP, name, or payment concept |
| `page` | integer | No | 1 | Page number for pagination |
| `perPage` | integer | No | 15 | Items per page (max typically 100) |
| `forceRefresh` | boolean | No | false | Force cache update |

### Response (200 OK)

```json
{
  "success": true,
  "message": "Operación completada exitosamente",
  "data": {
    "payments": {
      "items": [
        {
          "id": 10,
          "date": "2025-11-04",
          "concept": "Pago de inscripción",
          "amount": "1500.00",
          "amount_received": "1500.00",
          "method": "Tarjeta de crédito",
          "fullName": "Juan Pérez García"
        },
        {
          "id": 11,
          "date": "2025-11-05",
          "concept": "Cuota mensual",
          "amount": "2500.00",
          "amount_received": "2500.00",
          "method": "Transferencia",
          "fullName": "María López Rodríguez"
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
- `total` - Total number of payments (integer)
- `hasMorePages` - Boolean indicating more pages available
- `nextPage` - Next page number (integer or null)
- `previousPage` - Previous page number (integer or null)

**Item Fields:**
- `id` - Payment record ID (integer)
- `date` - Payment date (string, YYYY-MM-DD format)
- `concept` - Name of the payment concept/charge (string)
- `amount` - Amount charged in MXN (string, decimal format)
- `amount_received` - Amount actually received in MXN (string, decimal format)
- `method` - Payment method used (string: "Tarjeta de crédito", "Transferencia", "Depósito", etc.)
- `fullName` - Full name of student (string)

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
  "message": "No tienes permiso para ver los pagos.",
  "error_code": "FORBIDDEN",
  "errors": {}
}
```

### 409 Conflict
```json
{
  "success": false,
  "message": "Error de conflicto",
  "error_code": "CONFLICT",
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
async getAllPayments(token, options = {}) {
  const {
    search = '',
    page = 1,
    perPage = 15,
    forceRefresh = false
  } = options;
  
  // Construir URL con parámetros
  const params = new URL(`${API_BASE}/payments`);
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
      'X-User-Permission': 'view.payments'
    }
  });
  
  return await response.json();
}
```

**Usage in Astro Component:**
```javascript
// Load all payments
const response = await StudentAPI.getAllPayments(token, {
  search: searchTerm,
  page: 1,
  perPage: 50,
  forceRefresh: true
});

if (response.success) {
  const payments = response.data.payments.items;
  const pagination = {
    current: response.data.payments.currentPage,
    last: response.data.payments.lastPage,
    total: response.data.payments.total
  };
}
```

## PowerShell Testing

**Test Script:** `test-get-all-payments.ps1`

### Basic Usage
```powershell
.\test-get-all-payments.ps1 -Token "your-bearer-token"
```

### With Search
```powershell
# Search by email
.\test-get-all-payments.ps1 -Token "your-token" -Search "juan.perez@example.com"

# Search by name
.\test-get-all-payments.ps1 -Token "your-token" -Search "juan perez"

# Search by concept
.\test-get-all-payments.ps1 -Token "your-token" -Search "inscripción"
```

### With Pagination
```powershell
# Get page 2 with 25 items per page
.\test-get-all-payments.ps1 -Token "your-token" -Page 2 -PerPage 25

# Force cache refresh
.\test-get-all-payments.ps1 -Token "your-token" -ForceRefresh $true
```

### Combined Example
```powershell
.\test-get-all-payments.ps1 `
  -Token "your-token" `
  -Search "juan" `
  -Page 1 `
  -PerPage 50 `
  -ForceRefresh $true
```

## Usage Examples

### Get First Page of All Payments
```bash
curl -X GET "https://nginx-production-728f.up.railway.app/api/v1/payments?page=1&perPage=15" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "X-User-Role: financial-staff" \
  -H "X-User-Permission: view.payments" \
  -H "Content-Type: application/json"
```

### Search Student by Email
```bash
curl -X GET "https://nginx-production-728f.up.railway.app/api/v1/payments?search=juan.perez@example.com" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "X-User-Role: financial-staff" \
  -H "X-User-Permission: view.payments"
```

### Search by Payment Concept
```bash
curl -X GET "https://nginx-production-728f.up.railway.app/api/v1/payments?search=inscripción" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "X-User-Role: financial-staff" \
  -H "X-User-Permission: view.payments"
```

### Get Second Page with Custom Pagination
```bash
curl -X GET "https://nginx-production-728f.up.railway.app/api/v1/payments?page=2&perPage=50&forceRefresh=true" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "X-User-Role: financial-staff" \
  -H "X-User-Permission: view.payments"
```

## Frontend Integration

### Updated payments.astro Page
The payments.astro page now uses `getAllPayments()` to fetch all registered payments:

**Data Flow:**
1. Page loads and calls `loadPayments()`
2. `loadPayments()` calls `StudentAPI.getAllPayments(token, options)`
3. API returns paginated list with payment details
4. Data is stored in localStorage for offline access
5. Client-side pagination (50 items per page)
6. Real-time search filtering
7. Export to Excel functionality

**Features:**
- ✅ Paginated display (50 items per page)
- ✅ Real-time search by name, email, or concept
- ✅ Filter by payment method
- ✅ Export to Excel with formatting
- ✅ Comprehensive error handling
- ✅ Fallback to localStorage

### Key Improvements Over Previous Implementation
| Feature | Before | After |
|---------|--------|-------|
| **Data Source** | Only localStorage | API with localStorage fallback |
| **Search** | Name/control only | Email, name, concept, CURP |
| **Pagination Info** | Limited | Full metadata provided |
| **Performance** | Multiple local lookups | Direct from API |
| **Export** | Per-career | Unified sheet |

## Best Practices

### Performance
- **Use `forceRefresh: true` sparingly** - Only when cache might be stale
- **Adjust `perPage` parameter** - Use 50-100 for large result sets
- **Implement local caching** - Store response in localStorage
- **Paginate strategically** - Load current page rather than all data

### Security
- **Always include X-User-Role and X-User-Permission headers**
- **Validate token expiration before requests**
- **Handle 401/403 errors appropriately** - redirect to login
- **Never expose tokens in URL** - Use Authorization header only
- **Sanitize search input** - Prevent injection attacks

### Error Handling
```javascript
try {
  const response = await StudentAPI.getAllPayments(token, {
    search: userInput,
    page: 1,
    perPage: 50
  });
  
  if (!response.success) {
    throw new Error(response.message);
  }
  
  // Process payments
} catch (error) {
  if (error.message.includes('autenticado')) {
    // Redirect to login
  } else if (error.message.includes('permiso')) {
    // Show access denied
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
- **Retry:** Wait for reset time before retrying

## Caching

- **Default TTL:** 5 minutes
- **Force Refresh:** Set `forceRefresh=true` to bypass cache
- **Cache Key:** `payments:{user_role}:{search_term}:{page}:{perPage}`
- **Invalidation:** On new payment registration or manual cache flush

## Related Endpoints

- **GET /api/v1/debts** - Get all pending payments
- **GET /api/v1/pending-payments** - Get pending payments for student
- **POST /api/v1/pending-payments** - Create payment intent
- **GET /api/v1/pending-payments/overdue** - Get overdue payments
- **GET /api/v1/debts/stripe-payments** - Get Stripe payment history
- **POST /api/v1/debts/validate** - Validate Stripe payment

## Changelog

### Version 1.0 (Current)
- ✅ Initial implementation
- ✅ Pagination support
- ✅ Search by email, name, concept
- ✅ Cache management
- ✅ Rate limiting
- ✅ Complete error handling

### Future Enhancements
- Filter by date range
- Filter by payment method
- Sort by amount, date, name
- Download receipts
- Payment statistics
- Real-time updates via WebSocket
