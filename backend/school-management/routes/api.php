<?php

use App\Http\Controllers\LoginController;
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

    // Careers Management
    Route::prefix('careers')->middleware('role:admin|supervisor')->group(function(){
        Route::get('/', function (Request $request) {
            try {
                $careers = \App\Models\Career::all();
                return response()->json([
                    'success' => true,
                    'message' => 'Carreras encontradas.',
                    'data' => [
                        'careers' => $careers
                    ]
                ]);
            } catch (\Exception $e) {
                return response()->json([
                    'success' => false,
                    'message' => 'Error al cargar carreras: ' . $e->getMessage()
                ], 500);
            }
        });

        Route::post('/', function (Request $request) {
            try {
                $validated = $request->validate([
                    'career_name' => 'required|string|max:255|unique:careers,career_name'
                ]);

                $career = \App\Models\Career::create($validated);

                return response()->json([
                    'success' => true,
                    'message' => 'Carrera creada exitosamente.',
                    'data' => [
                        'career' => $career
                    ]
                ], 201);
            } catch (\Illuminate\Validation\ValidationException $e) {
                return response()->json([
                    'success' => false,
                    'message' => 'Error de validación',
                    'errors' => $e->errors(),
                    'error_code' => 'VALIDATION_ERROR'
                ], 422);
            } catch (\Illuminate\Database\QueryException $e) {
                if ($e->getCode() === '23000') {
                    return response()->json([
                        'success' => false,
                        'message' => 'La carrera ya existe',
                        'error_code' => 'DUPLICATE_ENTRY'
                    ], 409);
                }
                return response()->json([
                    'success' => false,
                    'message' => 'Error en la base de datos: ' . $e->getMessage()
                ], 500);
            } catch (\Exception $e) {
                return response()->json([
                    'success' => false,
                    'message' => 'Error al crear carrera: ' . $e->getMessage()
                ], 500);
            }
        });

        Route::put('/{id}', function (Request $request, $id) {
            try {
                $validated = $request->validate([
                    'career_name' => 'required|string|max:255|unique:careers,career_name,' . $id
                ]);

                $career = \App\Models\Career::findOrFail($id);
                $career->update($validated);

                return response()->json([
                    'success' => true,
                    'message' => 'Carrera actualizada.',
                    'data' => [
                        'updated' => $career
                    ]
                ]);
            } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
                \Log::error('Career not found', ['career_id' => $id, 'error' => $e->getMessage()]);
                return response()->json([
                    'success' => false,
                    'message' => 'Carrera no encontrada'
                ], 404);
            } catch (\Illuminate\Validation\ValidationException $e) {
                return response()->json([
                    'success' => false,
                    'message' => 'Error de validación',
                    'errors' => $e->errors(),
                    'error_code' => 'VALIDATION_ERROR'
                ], 422);
            } catch (\Illuminate\Database\QueryException $e) {
                \Log::error('Database error updating career', ['career_id' => $id, 'error' => $e->getMessage()]);
                if ($e->getCode() === '23000') {
                    return response()->json([
                        'success' => false,
                        'message' => 'El nombre de carrera ya existe',
                        'error_code' => 'DUPLICATE_ENTRY'
                    ], 409);
                }
                return response()->json([
                    'success' => false,
                    'message' => 'Error en la base de datos: ' . $e->getMessage()
                ], 500);
            } catch (\Exception $e) {
                \Log::error('Error updating career', ['career_id' => $id, 'error' => $e->getMessage(), 'trace' => $e->getTraceAsString()]);
                return response()->json([
                    'success' => false,
                    'message' => 'Error al actualizar carrera: ' . $e->getMessage(),
                    'error_detail' => config('app.debug') ? $e->getTraceAsString() : null
                ], 500);
            }
        });

        Route::delete('/{id}', function (Request $request, $id) {
            try {
                $career = \App\Models\Career::findOrFail($id);
                $careerName = $career->career_name;
                $career->delete();

                return response()->json([
                    'success' => true,
                    'message' => "Carrera {$careerName} eliminada exitosamente."
                ]);
            } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
                return response()->json([
                    'success' => false,
                    'message' => 'Carrera no encontrada'
                ], 404);
            } catch (\Exception $e) {
                return response()->json([
                    'success' => false,
                    'message' => 'Error al eliminar carrera: ' . $e->getMessage()
                ], 500);
            }
        });
    });

    // Admin Actions - User Management
    // Allow both 'admin' and 'financial staff' roles to access
    Route::prefix('admin-actions')->middleware('role:admin|financial staff')->group(function(){
        Route::get('/show-users', function (Request $request) {
            try {
                $users = \App\Models\User::with('roles')->get()->map(function($user) {
                    $fullName = trim(($user->name ?? '') . ' ' . ($user->last_name ?? ''));
                    $firstRole = $user->roles->first();
                    
                    return [
                        'id' => $user->id,
                        'fullName' => $fullName ?: 'Sin nombre',
                        'email' => $user->email,
                        'curp' => $user->curp ?? 'N/A',
                        'role' => $firstRole ? $firstRole->name : 'Sin rol',
                        'roles_count' => $user->roles->count(),
                        'status' => $user->status === 'activo' ? 'active' : $user->status,
                        'created_at' => $user->created_at->format('Y-m-d H:i:s'),
                        'createdAtHuman' => $user->created_at->diffForHumans(),
                    ];
                });
                
                return response()->json([
                    'success' => true,
                    'message' => 'Usuarios encontrados.',
                    'data' => [
                        'users' => [
                            'items' => $users->values()->all(),
                            'currentPage' => 1,
                            'lastPage' => 1,
                            'perPage' => $users->count(),
                            'total' => $users->count(),
                            'hasMorePages' => false,
                            'nextPage' => null
                        ]
                    ]
                ]);
            } catch (\Exception $e) {
                return response()->json([
                    'success' => false,
                    'message' => 'Error loading users: ' . $e->getMessage()
                ], 500);
            }
        });

        Route::post('/register', function (Request $request) {
            try {
                $validated = $request->validate([
                    'name' => 'required|string|max:255',
                    'last_name' => 'nullable|string|max:255',
                    'email' => 'required|email|unique:users,email',
                    'password' => 'required|string|min:8',
                    'phone_number' => 'nullable|string|max:20',
                    'curp' => 'nullable|string|max:18',
                    'gender' => 'nullable|in:hombre,mujer,otro',
                ]);

                $user = \App\Models\User::create([
                    'name' => $validated['name'],
                    'last_name' => $validated['last_name'] ?? null,
                    'email' => $validated['email'],
                    'password' => bcrypt($validated['password']),
                    'phone_number' => $validated['phone_number'] ?? null,
                    'curp' => $validated['curp'] ?? null,
                    'gender' => $validated['gender'] ?? 'hombre',
                    'status' => 'activo'
                ]);

                // Asignar rol de estudiante por defecto
                $user->assignRole('student');
                
                return response()->json([
                    'success' => true,
                    'message' => 'Usuario creado correctamente',
                    'data' => [
                        'id' => $user->id,
                        'name' => $user->name,
                        'last_name' => $user->last_name,
                        'email' => $user->email,
                        'phone_number' => $user->phone_number,
                        'curp' => $user->curp,
                        'gender' => $user->gender,
                        'role' => 'student',
                        'status' => $user->status
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
            try {
                $validated = $request->validate([
                    'name' => 'sometimes|string|max:255',
                    'last_name' => 'sometimes|string|max:255',
                    'email' => 'sometimes|email|unique:users,email,' . $id,
                    'phone_number' => 'sometimes|string|max:20',
                    'curp' => 'sometimes|string|max:18',
                    'gender' => 'sometimes|in:hombre,mujer,otro',
                    'password' => 'sometimes|string|min:8',
                ]);

                $user = \App\Models\User::findOrFail($id);
                
                if (isset($validated['password'])) {
                    $validated['password'] = bcrypt($validated['password']);
                }
                
                $user->update($validated);
                
                return response()->json([
                    'success' => true,
                    'message' => 'Usuario actualizado correctamente',
                    'data' => $user
                ]);
            } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
                return response()->json([
                    'success' => false,
                    'message' => 'Usuario no encontrado'
                ], 404);
            } catch (\Illuminate\Validation\ValidationException $e) {
                return response()->json([
                    'success' => false,
                    'message' => 'Error de validación',
                    'errors' => $e->errors()
                ], 422);
            } catch (\Exception $e) {
                return response()->json([
                    'success' => false,
                    'message' => 'Error al actualizar usuario: ' . $e->getMessage()
                ], 500);
            }
        });
    });

});


