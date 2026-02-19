# Payment Validation UI Implementation Guide

## Overview
Complete UI implementation for Stripe payment validation in the financial staff dashboard (`debts.astro` page).

## Features Implemented

### 1. Validation Modal
Located at: [Frond-end/src/pages/debts.astro](Frond-end/src/pages/debts.astro)

**Components:**
- **Purple "Validar Pago" Button** - Added to header toolbar
- **Modal with 3 sections:**
  - Form Section: Search student + Payment Intent ID inputs
  - Result Section: Displays validation data when successful
  - Error Section: Shows error messages with retry option

### 2. Student Information Display
Displays:
- Full Name
- Student Control Number (No. Control)
- Email Address
- CURP (RFC)

### 3. Payment Details Display
Displays:
- Stripe Payment ID
- Amount (MXN)
- Amount Received (MXN)
- Payment Status (color-coded: succeeded=green, pending=yellow, failed=red)
- Payment Intent ID (clickable reference)

### 4. Reconciliation Status
Visual indicators showing:
- ✓ **Registro Creado** - Payment record created successfully
- ✓ **Registro Reconciliado** - Payment matched with student account
- ✓ **Estudiante Notificado** - Student notification sent

Color coding:
- **Green** (✓) = Success
- **Red** (✕) = Failed/Not processed

## Usage Instructions

### For Financial Staff

1. **Navigate to Debts Page**
   - Go to the "Estado de Adeudos" page
   - Look for purple "Validar Pago" button in header

2. **Open Validation Modal**
   - Click "Validar Pago" button
   - Modal opens with search fields

3. **Search for Student**
   - Enter one of: Email, No. Control, CURP, or Name
   - Examples:
     - Email: `juan.perez@example.com`
     - CURP: `SAQ890101HDFLRR99`
     - No. Control: `23001234`
     - Name: `Juan Perez`

4. **Enter Payment Intent ID**
   - Enter the Stripe Payment Intent ID
   - Format: `pi_3Lq5R52eZvKYlo2C1kYzYPpp`
   - Can be found in:
     - Stripe Dashboard
     - Student payment confirmation email
     - Payment receipt

5. **Validate Payment**
   - Click "Validar Pago" button
   - Loading spinner appears
   - Results display when ready

6. **Review Results**
   - Check Student Information
   - Verify Payment Details
   - Review Reconciliation Status
   - Check success message if available

7. **Actions After Validation**
   - **Success:** Click "Cerrar" to close modal
   - **Try Again:** Click "Nueva Validación" to search another payment
   - **Error:** Review error message and click "Intentar de nuevo"

## API Integration

The UI calls: `StudentAPI.validateStripePayment(search, paymentIntentId, token)`

### Request Parameters:
```javascript
{
  search: "juan.perez@example.com",        // Student identifier
  payment_intent_id: "pi_3Lq5R52eZvKYlo2C1kYzYPpp"  // Stripe payment intent
}
```

### Response Format:
```json
{
  "success": true,
  "data": {
    "student": {
      "id": "uuid",
      "fullName": "Juan Perez Garcia",
      "email": "juan.perez@example.com",
      "n_control": "23001234",
      "curp": "SAQ890101HDFLRR99"
    },
    "payment": {
      "id": "payment-uuid",
      "amount": 1500,
      "amount_received": 1500,
      "status": "succeeded",
      "payment_intent_id": "pi_3Lq5R52eZvKYlo2C1kYzYPpp"
    },
    "metadata": {
      "wasCreated": true,
      "wasReconciled": true,
      "message": "Payment processed and linked to student account"
    },
    "reconciliation": {
      "processed": 1,
      "updated": 1,
      "notified": 1,
      "failed": 0
    }
  }
}
```

## Testing

### Test Script Included:
[Frond-end/test-validate-payment.ps1](../../test-validate-payment.ps1)

### Manual Testing:
1. Open Firefox DevTools (F12) or Chrome DevTools
2. Go to Console tab
3. Test with:
   ```javascript
   // Test validation
   const result = await StudentAPI.validateStripePayment(
     "juan.perez@example.com",
     "pi_3Lq5R52eZvKYlo2C1kYzYPpp",
     localStorage.getItem('access_token')
   );
   console.log(result);
   ```

## UI Styling

**Color Scheme:**
- **Primary Purple:** `bg-purple-600` (buttons, accents)
- **Student Info:** Blue (`bg-blue-50` border)
- **Payment Info:** Emerald (`bg-emerald-50` border)
- **Reconciliation:** Amber (`bg-amber-50` border)
- **Success:** Green (`text-emerald-700`)
- **Error:** Red (`text-red-700`)

**Responsive:**
- Mobile: Full width modal
- Desktop: `max-w-2xl` (max 2xl width)
- Scrollable on small screens: `max-h-screen overflow-y-auto`

## File Locations

- **Main Component:** [debts.astro](Frond-end/src/pages/debts.astro) (lines ~150-250 HTML, ~400-600 JS)
- **API Method:** [studentAPI.js](Frond-end/src/utils/studentAPI.js) (validateStripePayment method)
- **Test Script:** [test-validate-payment.ps1](test-validate-payment.ps1)

## Permissions Required

Financial staff must have:
- Role: `financial-staff`
- Permission: `validate.debt`

These are automatically added to headers by StudentAPI when calling `validateStripePayment()`.

## Error Handling

**Common Errors:**
1. **"No hay sesión activa"** - User not logged in, need to login
2. **"Por favor ingresa un término de búsqueda"** - Empty search field
3. **"Por favor ingresa el Payment Intent ID"** - Empty payment intent field
4. **Payment not found** - Search term or Payment Intent doesn't match, verify spelling
5. **401 Unauthorized** - Session expired, need to re-login
6. **403 Forbidden** - User lacks required permissions
7. **422 Unprocessable Entity** - Invalid data, check formatting

## Future Enhancements

Possible additions:
1. **Batch Validation** - Upload CSV of payment intent IDs
2. **Validation History** - Log of all validations performed
3. **Auto-refresh** - Periodic polling for reconciliation updates
4. **Export Results** - Save validation results to Excel
5. **Webhook Integration** - Real-time updates from Stripe
6. **Payment Details Modal** - Link to full Stripe transaction details

## Integration Checklist

- [✅] Modal HTML added to debts.astro
- [✅] Button added to header
- [✅] JavaScript event handlers implemented
- [✅] API method exists in studentAPI.js
- [✅] Error handling implemented
- [✅] Result display formatting complete
- [✅] Color-coded status indicators
- [✅] Mobile responsive design
- [✅] Test script created

## Support

For issues or questions:
1. Check browser console (F12) for error messages
2. Verify user has correct role: `financial-staff`
3. Verify payment intent ID format (starts with `pi_`)
4. Verify student search term matches records
5. Check Stripe dashboard for payment status
6. Review API logs at `/api/v1/debts/validate` endpoint
