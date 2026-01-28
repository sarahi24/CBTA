<?php

use App\Http\Controllers\LoginController;
use App\Http\Controllers\CareersController;
use App\Http\Controllers\AdminActionsController;
use App\Http\Controllers\Staff\ConceptsController;
use App\Http\Controllers\Staff\DashboardController as StaffDashboardController;
use App\Http\Controllers\Staff\DebtsController;
use App\Http\Controllers\Staff\PaymentsController;
use App\Http\Controllers\Staff\StudentsController;
use App\Http\Controllers\Students\DashboardController;
use App\Http\Controllers\Students\CardsController;
use App\Http\Controllers\Students\PaymentHistoryController;
use App\Http\Controllers\Students\PendingPaymentController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Students\WebhookController;
use App\Models\PaymentConcept;

// ===== ABSOLUTE SIMPLEST TEST ENDPOINT =====
Route::middleware([\App\Http\Middleware\CorsMiddleware::class])->group(function () {
    Route::get('/test-simple', function () {
        return response()->json(['success' => true, 'message' => 'Simple test works']);
    });

    Route::put('/test-simple', function (Request $request) {
        return response()->json(['success' => true, 'message' => 'Simple PUT works']);
    });
});

// ===== AUTHENTICATED & PROTECTED ROUTES =====
Route::middleware(['auth:sanctum'])->get('/user', function (Request $request) {
    return $request->user();
});

// Test endpoint to debug authentication
Route::middleware(['auth:sanctum'])->get('/v1/test-auth', function (Request $request) {
    $user = $request->user();
    return response()->json([
        'success' => true,
        'message' => 'Authentication working!',
        'user' => [
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'roles' => $user->roles->pluck('name')
        ]
    ]);
});

Route::prefix('v1')->middleware('throttle:10,1')->group(function () {
    Route::post('/login', [LoginController::class, 'login']);
    
    // Test endpoint para debug
    Route::get('/test-endpoint', function () {
        return response()->json(['success' => true, 'message' => 'Test endpoint working']);
    });
    
    // ===== PUBLIC TEST ENDPOINTS =====
    Route::get('/test', function () {
        return response()->json(['success' => true, 'message' => 'GET works']);
    });

    Route::put('/test', function (Request $request) {
        return response()->json(['success' => true, 'message' => 'PUT works']);
    });
});
Route::post('/stripe/webhook', [WebhookController::class, 'handle']);


Route::prefix('v1')->middleware(['auth:sanctum'])->group(function (){
    Route::prefix('dashboard')->middleware('role:student')->group(function (){
        Route::middleware('permission:view own financial overview')->get('/data',[DashboardController::class,'index']);
        Route::middleware('permission:view own pending concepts summary')->get('/pending',[DashboardController::class,'pending']);
        Route::middleware('permission:view own paid concepts summary')->get('/paid',[DashboardController::class,'paid']);
        Route::middleware('permission:view own overdue concepts summary')->get('/overdue',[DashboardController::class,'overdue']);
        Route::middleware('permission:view payments history')->get('/history',[DashboardController::class,'history']);

    });
    Route::prefix('cards')->middleware('role:student')->group(function(){
        Route::middleware('permission:view cards')->get('/',[CardsController::class,'index']);
        Route::middleware('permission:create setup')->post('/',[CardsController::class,'store']);
        Route::middleware('permission:create and view card')->get('/save', [CardsController::class, 'save']);
        Route::middleware('permission:delete card')->delete('/{paymentMethodId}',[CardsController::class,'destroy']);
    });
    Route::prefix('history')->middleware('role:student')->group(function(){
        Route::middleware('permission:view payment history')->get('/',[PaymentHistoryController::class,'index']);
    });
    Route::prefix('pending-payment')->middleware('role:student')->group(function(){
        Route::middleware('permission:view pending concepts')->get('/',[PendingPaymentController::class,'index']);
        Route::middleware('permission:create payment','throttle:5,1')->post('/',[PendingPaymentController::class,'store']);
        Route::middleware('permission:view overdue concepts')->get('/overdue',[PendingPaymentController::class,'overdue']);

    });

    Route::prefix('dashboard-staff')->middleware('role:financial staff')->group(function(){
        Route::middleware('permission:view all financial overview')->get('/data',[StaffDashboardController::class,'getData']);
        Route::middleware('permission:view all pending concepts summary')->get('/pending',[StaffDashboardController::class,'pendingPayments']);
        Route::middleware('permission:view all students summary')->get('/students',[StaffDashboardController::class,'allStudents']);
        Route::middleware('permission:view all paid concepts summary')->get('/payments',[StaffDashboardController::class,'paymentsMade']);
        Route::middleware('permission:view concepts history')->get('/concepts',[StaffDashboardController::class,'allConcepts']);
    });
    Route::prefix('concepts')->middleware('role:financial staff','throttle:60,1')->group(function(){
        Route::middleware('permission:view concepts')->get('/', [ConceptsController::class, 'index']);
        Route::middleware('permission:create concepts')->post('/', [ConceptsController::class, 'store']);
        Route::middleware('permission:update concepts')->put('/{concept}', [ConceptsController::class, 'update']);
        Route::middleware('permission:update concepts')->patch('/{concept}', [ConceptsController::class, 'update']);
        Route::middleware('permission:finalize concepts')->post('/{concept}/finalize', [ConceptsController::class, 'finalize']);
        Route::middleware('permission:disable concepts')->post('/{concept}/disable', [ConceptsController::class, 'disable']);
        Route::middleware('permission:eliminate concepts')->post('/{concept}/eliminate', [ConceptsController::class, 'eliminate']);

    });

    Route::prefix('debts')->middleware('role:financial staff','throttle:60,1')->group(function(){
        Route::middleware('permission:view debts')->get('/', [DebtsController::class, 'index']);
        Route::middleware('permission:validate debt')->post('/validate', [DebtsController::class, 'validatePayment']);
    });

    Route::prefix('payments')->middleware('role:financial staff')->group(function(){
        Route::middleware('permission:view payments')->get('/', [PaymentsController::class, 'index']);
    });

     Route::prefix('students')->middleware('role:financial staff')->group(function(){
        Route::middleware('permission:view students')->get('/', [StudentsController::class, 'index']);
    });

    // Careers Management - All operations use 'careers' per API documentation
    Route::prefix('careers')->middleware('role:admin|supervisor')->group(function(){
        Route::get('/', [CareersController::class, 'index']);
        Route::post('/', [CareersController::class, 'store']);
        Route::get('/{career}', [CareersController::class, 'show']);
        Route::patch('/{career}', [CareersController::class, 'update']);
        Route::delete('/{career}', [CareersController::class, 'destroy']);
    });

    // Admin Actions - User Management
    // Allow both 'admin' and 'financial staff' roles to access
    
    Route::prefix('admin-actions')->middleware('auth:sanctum')->group(function(){
        // Debug endpoint without role requirement
        Route::put('/update-user-debug/{id}', function (Request $request, $id) {
            try {
                return response()->json([
                    'success' => true,
                    'message' => 'Debug endpoint works',
                    'received_id' => $id
                ]);
            } catch (\Exception $e) {
                return response()->json(['success' => false, 'error' => $e->getMessage()], 500);
            }
        });
        
        // CORS preflight
        Route::options('/{path?}', function () {
            return response()->json([]);
        })->where('path', '.*');
    });
    
    // Production endpoints with role restriction
    Route::prefix('admin-actions')->middleware(['auth:sanctum', 'role:admin|financial staff', \App\Http\Middleware\CorsMiddleware::class])->group(function(){
        Route::get('/show-users', [AdminActionsController::class, 'showUsers']);
        Route::get('/show-users/{id}', [AdminActionsController::class, 'showUserById']);
        Route::post('/updated-roles', [AdminActionsController::class, 'updateRoles']);
        Route::post('/delete-users', [AdminActionsController::class, 'deleteUsers']);
        Route::post('/disable-users', [AdminActionsController::class, 'disableUsers']);
        Route::post('/temporary-disable-users', [AdminActionsController::class, 'temporaryDisableUsers']);
        Route::post('/find-permissions', [AdminActionsController::class, 'findPermissions']);
        Route::get('/find-roles', [AdminActionsController::class, 'findRoles']);
        Route::get('/roles/{id}', [AdminActionsController::class, 'getRoleById']);
        Route::get('/permissions/{id}', [AdminActionsController::class, 'getPermissionById']);

        Route::post('/register', function (Request $request) {
            try {
                $validated = $request->validate([
                    'name' => 'required|string|max:255',
                    'last_name' => 'nullable|string|max:255',
                    'email' => 'required|email|unique:users,email',
                    'password' => 'nullable|string|min:8',
                    'phone_number' => 'nullable|string|max:20',
                    'birthdate' => 'nullable|date_format:Y-m-d',
                    'gender' => 'nullable|in:hombre,mujer,otro',
                    'curp' => 'nullable|string|max:18|unique:users,curp',
                    'registration_date' => 'nullable|date_format:Y-m-d',
                    'address' => 'nullable|array',
                    'address.*' => 'nullable|string',
                    'blood_type' => 'nullable|string',
                    'status' => 'nullable|in:activo,baja,eliminado',
                ]);

                // Generar password si no se proporciona
                $password = $validated['password'] ?? \Illuminate\Support\Str::random(12);
                
                // Convertir address array a string si es necesario
                $address = '';
                if (is_array($validated['address'] ?? null)) {
                    $address = implode(', ', array_filter($validated['address']));
                }

                $user = \App\Models\User::create([
                    'name' => $validated['name'],
                    'last_name' => $validated['last_name'] ?? null,
                    'email' => $validated['email'],
                    'password' => bcrypt($password),
                    'phone_number' => $validated['phone_number'] ?? null,
                    'birthdate' => $validated['birthdate'] ?? null,
                    'gender' => $validated['gender'] ?? 'Hombre',
                    'curp' => $validated['curp'] ?? null,
                    'address' => $address,
                    'registration_date' => $validated['registration_date'] ?? now()->format('Y-m-d'),
                    'status' => $validated['status'] ?? 'activo',
                    'state' => 'N/A',
                    'municipality' => 'N/A'
                ]);

                // Asignar rol de estudiante por defecto
                $user->assignRole('student');
                
                return response()->json([
                    'success' => true,
                    'message' => 'Usuario creado correctamente',
                    'data' => [
                        'user' => [
                            'id' => $user->id,
                            'name' => $user->name ?? '',
                            'last_name' => $user->last_name ?? '',
                            'email' => $user->email ?? '',
                            'phone_number' => $user->phone_number ?? '',
                            'birthdate' => $user->birthdate ? (is_string($user->birthdate) ? $user->birthdate : $user->birthdate->format('Y-m-d')) : '',
                            'gender' => $user->gender ?? '',
                            'curp' => $user->curp ?? '',
                            'address' => $user->address ? explode(', ', $user->address) : ['', '', ''],
                            'blood_type' => 'O+',
                            'registration_date' => $user->registration_date ? (is_string($user->registration_date) ? $user->registration_date : $user->registration_date->format('Y-m-d')) : '',
                            'status' => $user->status ?? 'activo',
                            'role' => 'student'
                        ]
                    ]
                ], 201);
            } catch (\Illuminate\Validation\ValidationException $e) {
                return response()->json([
                    'success' => false,
                    'message' => 'Error de validación',
                    'errors' => $e->errors()
                ], 422);
            } catch (\Exception $e) {
                return response()->json([
                    'success' => false,
                    'message' => 'Error al crear usuario: ' . $e->getMessage()
                ], 500);
            }
        });

        Route::delete('/delete-user/{id}', function (Request $request, $id) {
            try {
                $user = \App\Models\User::findOrFail($id);
                $userName = ($user->name ?? '') . ' ' . ($user->last_name ?? '');
                $userName = trim($userName) ?: 'Usuario';
                
                // Cambiar status a "eliminado" (soft delete lógico)
                // En lugar de eliminar físicamente para evitar problemas con relaciones
                $user->status = 'eliminado';
                $user->save();
                
                return response()->json([
                    'success' => true,
                    'message' => "Usuario {$userName} eliminado correctamente"
                ]);
            } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
                return response()->json([
                    'success' => false,
                    'message' => 'Usuario no encontrado'
                ], 404);
            } catch (\Exception $e) {
                \Log::error('Error al eliminar usuario', [
                    'user_id' => $id,
                    'error' => $e->getMessage(),
                    'trace' => $e->getTraceAsString()
                ]);
                return response()->json([
                    'success' => false,
                    'message' => 'Error al eliminar usuario: ' . $e->getMessage(),
                    'error_detail' => config('app.debug') ? $e->getTraceAsString() : null
                ], 500);
            }
        });

        Route::put('/update-user/{id}', function (Request $request, $id) {
            \Log::info('🔄 Iniciando actualización de usuario', ['user_id' => $id, 'data' => $request->all()]);
            
            try {
                $validated = $request->validate([
                    'name' => 'sometimes|string|max:255',
                    'last_name' => 'sometimes|string|max:255',
                    'email' => 'sometimes|email|unique:users,email,' . $id,
                    'phone_number' => 'sometimes|string|max:20',
                    'birthdate' => 'sometimes|date_format:Y-m-d',
                    'gender' => 'sometimes|in:hombre,mujer,otro',
                    'curp' => 'sometimes|string|max:18|unique:users,curp,' . $id,
                    'address' => 'sometimes|array',
                    'address.*' => 'nullable|string',
                    'password' => 'sometimes|string|min:8',
                ]);
                
                \Log::info('✅ Validación exitosa', ['validated' => $validated]);

                $user = \App\Models\User::findOrFail($id);
                \Log::info('✅ Usuario encontrado', ['user_id' => $user->id]);
                
                // Convertir address array a string si es necesario
                if (isset($validated['address']) && is_array($validated['address'])) {
                    $validated['address'] = implode(', ', array_filter($validated['address']));
                    \Log::info('✅ Dirección convertida', ['address' => $validated['address']]);
                }
                
                if (isset($validated['password'])) {
                    $validated['password'] = bcrypt($validated['password']);
                    \Log::info('✅ Contraseña encriptada');
                }
                
                // Remover campos que no existen en la tabla users
                unset($validated['blood_type']);
                
                \Log::info('📝 Intentando actualizar usuario con datos', ['validated' => $validated]);
                $user->update($validated);
                \Log::info('✅ Usuario actualizado en base de datos');
                
                // Recargar usuario para obtener datos frescos
                $user = \App\Models\User::with('roles')->find($id);
                \Log::info('✅ Usuario recargado de BD');
                
                // Formatear birthdate para respuesta
                $birthdate = '';
                if ($user->birthdate) {
                    $birthdate = is_string($user->birthdate) ? $user->birthdate : $user->birthdate->format('Y-m-d');
                }
                \Log::info('✅ Birthdate formateada', ['birthdate' => $birthdate]);
                
                // Formatear registration_date para respuesta
                $registration_date = '';
                if ($user->registration_date) {
                    $registration_date = is_string($user->registration_date) ? $user->registration_date : $user->registration_date->format('Y-m-d');
                }
                \Log::info('✅ Registration_date formateada', ['registration_date' => $registration_date]);
                
                // Parsear dirección
                $address = ['', '', ''];
                if ($user->address) {
                    if (is_array($user->address)) {
                        $address = $user->address;
                    } else if (is_string($user->address)) {
                        $parts = explode(', ', $user->address);
                        $address = [
                            $parts[0] ?? '',
                            $parts[1] ?? '',
                            $parts[2] ?? ''
                        ];
                    }
                }
                \Log::info('✅ Address parseada', ['address' => $address]);
                
                // Obtener rol
                $role = 'Sin rol';
                if ($user->roles && $user->roles->count() > 0) {
                    $role = $user->roles->first()->name;
                }
                \Log::info('✅ Rol obtenido', ['role' => $role]);
                
                $response = [
                    'success' => true,
                    'message' => 'Usuario actualizado correctamente',
                    'data' => [
                        'user' => [
                            'id' => $user->id,
                            'name' => $user->name ?? '',
                            'last_name' => $user->last_name ?? '',
                            'email' => $user->email ?? '',
                            'phone_number' => $user->phone_number ?? '',
                            'birthdate' => $birthdate,
                            'gender' => $user->gender ?? '',
                            'curp' => $user->curp ?? 'N/A',
                            'address' => $address,
                            'blood_type' => 'O+',
                            'registration_date' => $registration_date,
                            'status' => $user->status ?? 'activo',
                            'role' => $role
                        ]
                    ]
                ];
                
                \Log::info('✅ Respuesta exitosa construida');
                return response()->json($response);
                
            } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
                \Log::error('❌ Usuario no encontrado', ['user_id' => $id]);
                return response()->json([
                    'success' => false,
                    'message' => 'Usuario no encontrado'
                ], 404);
            } catch (\Illuminate\Validation\ValidationException $e) {
                \Log::error('❌ Error de validación', ['errors' => $e->errors()]);
                return response()->json([
                    'success' => false,
                    'message' => 'Error de validación',
                    'errors' => $e->errors()
                ], 422);
            } catch (\Exception $e) {
                \Log::error('❌ Error general en update-user', [
                    'error' => $e->getMessage(),
                    'file' => $e->getFile(),
                    'line' => $e->getLine(),
                    'trace' => $e->getTraceAsString()
                ]);
                return response()->json([
                    'success' => false,
                    'message' => 'Error al actualizar usuario: ' . $e->getMessage(),
                    'error_code' => 'INTERNAL_SERVER_ERROR'
                ], 500);
            }
        });

        Route::post('/promotion-test', [AdminActionsController::class, 'testPromotion']);
        Route::post('/promotion', [AdminActionsController::class, 'promoteStudents']);
        Route::get('/promotion-debug', [AdminActionsController::class, 'debugPromotion']);
        Route::post('/attach-student', [AdminActionsController::class, 'attachStudent']);
        Route::get('/get-student/{id}', [AdminActionsController::class, 'getStudent']);
        Route::patch('/update-student/{id}', [AdminActionsController::class, 'updateStudent']);
        Route::post('/update-permissions', [AdminActionsController::class, 'updatePermissions']);
});
    });

});

