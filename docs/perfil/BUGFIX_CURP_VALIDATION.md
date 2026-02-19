# Bug Fix: 422 Unprocessable Content Error in updateRoles Endpoint

## Issue Summary
The frontend was receiving a **422 (Unprocessable Content)** error when attempting to call the `POST /v1/admin-actions/updated-roles` endpoint for bulk role management.

## Root Cause Analysis

### Problem 1: Invalid CURP Values (Critical)
The frontend `mapUser()` function was setting CURP to `'N/A'` (3 characters) when a user didn't have a CURP:
```javascript
// Line 1530 in roles.astro - PROBLEMATIC
curp: raw.curp || 'N/A',  // ❌ Returns 'N/A' if curp is falsy
```

However, the backend validation requires **exactly 18 characters**:
```php
// Line 815 in AdminActionsController.php
'curps.*' => 'string|size:18',  // ✓ Requires exactly 18 chars
```

When `updateRoles()` collected CURPs from selected users (line 2975-2976 in roles.astro):
```javascript
const curps = this.users
    .filter(u => this.selectedUsers.includes(u.id))
    .map(u => u.curp);  // ❌ Could include 'N/A' values
```

This resulted in a validation error: **`curps.*.size: Cada CURP debe tener exactamente 18 caracteres`**

### Problem 2: Weak Error Messages
The validation errors weren't helpful for debugging, making it hard to identify the root cause.

## Solutions Implemented

### Fix 1: Frontend CURP Validation (roles.astro)
Added filtering to exclude invalid CURPs before sending to the backend:

```javascript
// Lines 2975-2980 - FIXED
const curps = this.users
    .filter(u => this.selectedUsers.includes(u.id))
    .map(u => u.curp)
    .filter(curp => curp && curp !== 'N/A' && curp.length === 18);  // ✓ Only valid CURPs

if (curps.length === 0) {
    this.showNotify('Los usuarios seleccionados no tienen CURP válido (18 caracteres)', 'error');
    this.isSaving = false;
    return;
}
```

### Fix 2: Enhanced Backend Error Messages (AdminActionsController.php)
Added descriptive custom error messages to the validation:

```php
// Lines 815-825 - IMPROVED
$validated = $request->validate([
    'curps' => 'required|array|min:1',
    'curps.*' => 'string|size:18',
    'rolesToAdd' => 'array',
    'rolesToAdd.*' => 'string|exists:roles,name',
    'rolesToRemove' => 'array',
    'rolesToRemove.*' => 'string|exists:roles,name',
], [
    'curps.*.size' => 'Cada CURP debe tener exactamente 18 caracteres.',
    'rolesToAdd.*.exists' => 'Roles disponibles: admin, student, financial staff',
    'rolesToRemove.*.exists' => 'Roles disponibles: admin, student, financial staff',
]);
```

### Fix 3: Additional Debugging Output
Added console logging to help troubleshoot future issues:

```javascript
console.log('📤 updateRoles - Enviando:');
console.log('  CURPs válidos:', curps);
console.log('  Roles para agregar:', this.rolesToAdd);
console.log('  Roles para eliminar:', this.rolesToRemove);
```

## Testing the Fix

### Method 1: Manual Testing in Browser Console
```javascript
// Before role management:
// 1. Open Admin Panel → Roles Management
// 2. Select only users with valid 18-character CURPs
// 3. Check browser console: should see log messages confirming CURPs
// 4. Select roles and click "Actualizar Roles"
// 5. Should receive success message (✅) instead of 422 error
```

### Method 2: Automated Testing (PowerShell)
```powershell
# Use the existing test script with valid data
.\test-updated-roles.ps1

# Expected output: ✓ Roles added successfully!
```

## Data Requirements
Before using the role management feature, ensure:
- All users have a **valid CURP** (exactly 18 characters)
- All selected users have CURPs (not 'N/A' or empty)
- Role names exist in database: `admin`, `student`, `financial staff`

## Files Modified
1. **Frond-end/src/pages/roles.astro** (Line 2956-3015)
   - Fixed `updateRoles()` function to filter invalid CURPs
   - Added user-friendly error messages

2. **backend/school-management/app/Http/Controllers/AdminActionsController.php** (Line 809-885)
   - Enhanced validation error messages
   - Moved ValidationException handling to validate() call

## Commit Information
- **Commit Hash**: `98fb943`
- **Message**: `Fix: Validación mejorada de CURP en updateRoles y filtrado de CURPs 'N/A'`
- **Changes**: 
  - 2 files modified
  - 53 insertions(+)
  - 19 deletions(-)

## Related Documentation
- [API_STATUS.md](API_STATUS.md) - Admin Actions API Status
- [roles.astro Test Cases](test-updated-roles.ps1) - PowerShell test script
- [Database Seeder](backend/school-management/database/seeders/DatabaseSeeder.php) - Available roles configuration
