<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Spatie\Permission\Models\Permission;

class AdminActionsController extends Controller
{
    /**
     * Simple test endpoint
     */
    public function testPromotion(Request $request)
    {
        try {
            Log::info('TEST ENDPOINT CALLED');
            return response()->json([
                'success' => true,
                'message' => 'Test endpoint works',
                'user' => $request->user()?->id
            ]);
        } catch (\Exception $e) {
            Log::error('TEST ERROR', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Ensure the promote.student permission exists
     */
    private function ensurePromotePermissionExists()
    {
        try {
            Permission::firstOrCreate(
                ['name' => 'promote.student'],
                ['guard_name' => 'api']
            );
            Log::info('✅ promote.student permission ensured');
            return true;
        } catch (\Exception $e) {
            Log::warning('Could not create/verify permission', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);
            // Continue anyway - might already exist
            return true;
        }
    }
    /**
     * Debug endpoint to check roles and students
     */
    public function debugPromotion(Request $request)
    {
        try {
            Log::info('🔍 Debug endpoint called');
            
            // Check roles table
            $roles = DB::table('roles')->get();
            Log::info('Roles en BD', ['count' => $roles->count(), 'roles' => $roles->pluck('name')->toArray()]);
            
            // Check permissions table
            $permissions = DB::table('permissions')->pluck('name')->toArray();
            Log::info('Permisos en BD', ['count' => count($permissions)]);
            
            // Check student role ID
            $studentRoleId = DB::table('roles')->where('name', 'student')->first();
            Log::info('Student role', ['id' => $studentRoleId?->id ?? 'NOT_FOUND', 'role' => $studentRoleId]);
            
            // Check admin role ID
            $adminRoleId = DB::table('roles')->where('name', 'admin')->first();
            Log::info('Admin role', ['id' => $adminRoleId?->id ?? 'NOT_FOUND', 'role' => $adminRoleId]);
            
            // Check if promote.student permission exists
            $promotePermission = DB::table('permissions')->where('name', 'promote.student')->first();
            Log::info('promote.student permission', ['id' => $promotePermission?->id ?? 'NOT_FOUND', 'exists' => $promotePermission ? true : false]);
            
            // Check model_has_roles with correct model_type
            $modelType = User::class;
            Log::info('Buscando model_has_roles con model_type', ['model_type' => $modelType]);
            
            $modelHasRoles = DB::table('model_has_roles')
                ->where('model_type', $modelType)
                ->limit(10)
                ->get();
            Log::info('model_has_roles sample', ['count' => $modelHasRoles->count()]);
            
            // Check users with student role
            if ($studentRoleId) {
                $studentUsers = DB::table('users')
                    ->join('model_has_roles', 'users.id', '=', 'model_has_roles.model_id')
                    ->where('model_has_roles.role_id', $studentRoleId->id)
                    ->where('model_has_roles.model_type', $modelType)
                    ->select('users.id', 'users.semestre', 'users.name')
                    ->limit(10)
                    ->get();
                Log::info('Estudiantes encontrados', ['count' => $studentUsers->count()]);
            }
            
            // Check if admin role has promote.student permission
            $adminHasPromotePermission = false;
            if ($adminRoleId && $promotePermission) {
                $adminHasPromotePermission = DB::table('role_has_permissions')
                    ->where('role_id', $adminRoleId->id)
                    ->where('permission_id', $promotePermission->id)
                    ->exists();
            }
            
            return response()->json([
                'success' => true,
                'debug' => [
                    'total_roles' => $roles->count(),
                    'roles' => $roles->pluck('name')->toArray(),
                    'student_role_id' => $studentRoleId?->id ?? null,
                    'admin_role_id' => $adminRoleId?->id ?? null,
                    'promote_permission_exists' => $promotePermission ? true : false,
                    'admin_has_promote_permission' => $adminHasPromotePermission,
                    'model_type' => $modelType,
                    'model_has_roles_count' => DB::table('model_has_roles')->where('model_type', $modelType)->count(),
                    'students_count' => $studentRoleId ? DB::table('users')
                        ->join('model_has_roles', 'users.id', '=', 'model_has_roles.model_id')
                        ->where('model_has_roles.role_id', $studentRoleId->id)
                        ->where('model_has_roles.model_type', $modelType)
                        ->count() : 0,
                    'all_permissions' => $permissions
                ]
            ]);
        } catch (\Exception $e) {
            Log::error('Error en debug endpoint', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);
            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
                'trace' => config('app.debug') ? $e->getTraceAsString() : null
            ], 500);
        }
    }

    /**
     * Promote students to next semester
     */
    public function promoteStudents(Request $request)
    {
        $user = $request->user();
        
        if (!$user) {
            return response()->json(['success' => false, 'message' => 'Not authenticated'], 401);
        }

        DB::beginTransaction();

        try {
            // Fetch student role ID
            $studentRole = DB::table('roles')
                ->where('name', 'student')
                ->value('id');

            if (!$studentRole) {
                DB::rollBack();
                return response()->json([
                    'success' => false,
                    'message' => 'Student role not found'
                ], 500);
            }

            // Get all student IDs
            $studentIds = DB::table('model_has_roles')
                ->where('role_id', $studentRole)
                ->where('model_type', User::class)
                ->pluck('model_id');

            if ($studentIds->isEmpty()) {
                DB::rollBack();
                return response()->json([
                    'success' => true,
                    'message' => 'Se ejecutó la promoción de usuarios correctamente.',
                    'data' => ['affected' => ['usuarios_promovidos' => 0, 'usuarios_baja' => 0]]
                ]);
            }

            // Update students
            $promovidos = 0;
            $baja = 0;

            $students = DB::table('users')
                ->whereIn('id', $studentIds)
                ->get(['id', 'semestre']);

            foreach ($students as $student) {
                $semestre = intval($student->semestre ?? 1);
                $newSemestre = $semestre + 1;

                if ($newSemestre > 12) {
                    DB::table('users')
                        ->where('id', $student->id)
                        ->update(['status' => 'baja', 'semestre' => 12]);
                    $baja++;
                } else {
                    DB::table('users')
                        ->where('id', $student->id)
                        ->update(['semestre' => $newSemestre]);
                    $promovidos++;
                }
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Se ejecutó la promoción de usuarios correctamente.',
                'data' => ['affected' => ['usuarios_promovidos' => $promovidos, 'usuarios_baja' => $baja]]
            ]);

        } catch (\Exception $e) {
            DB::rollBack();
            Log::error('Promotion error: ' . $e->getMessage(), [
                'file' => $e->getFile(),
                'line' => $e->getLine()
            ]);
            
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
                'error_code' => 'PROMOTION_ERROR'
            ], 500);
        }
    }

    /**
     * Attach student details to an existing user
     */
    public function attachStudent(Request $request)
    {
        try {
            $validated = $request->validate([
                'user_id' => 'required|integer|exists:users,id',
                'career_id' => 'required|integer|exists:careers,id',
                'n_control' => 'required|string|max:50|unique:users,n_control',
                'semestre' => 'required|integer|min:1|max:12',
                'group' => 'required|string|max:10',
                'workshop' => 'required|string|max:100',
            ]);

            $user = User::findOrFail($validated['user_id']);

            // Check if user already has student details
            if ($user->n_control) {
                return response()->json([
                    'success' => false,
                    'message' => 'Este usuario ya tiene detalles de estudiante asignados.',
                    'error_code' => 'STUDENT_ALREADY_EXISTS'
                ], 422);
            }

            // Update user with student details
            $user->update([
                'career_id' => $validated['career_id'],
                'n_control' => $validated['n_control'],
                'semestre' => $validated['semestre'],
                'group' => $validated['group'],
                'workshop' => $validated['workshop'],
            ]);

            // Assign student role if not already assigned
            if (!$user->hasRole('student')) {
                $user->assignRole('student');
            }

            // Reload user with relationships
            $user->load('roles', 'career');

            return response()->json([
                'success' => true,
                'message' => 'Se asociaron correctamente los datos al estudiante.',
                'data' => [
                    'user' => [
                        'id' => $user->id,
                        'name' => $user->name,
                        'last_name' => $user->last_name,
                        'email' => $user->email,
                        'curp' => $user->curp,
                        'phone_number' => $user->phone_number,
                        'birthdate' => $user->birthdate,
                        'gender' => $user->gender,
                        'address' => $user->address,
                        'status' => $user->status,
                        'registration_date' => $user->registration_date,
                        'roles' => $user->roles->map(fn($role) => [
                            'id' => $role->id,
                            'name' => $role->name
                        ]),
                        'studentDetail' => [
                            'user_id' => $user->id,
                            'career_id' => $user->career_id,
                            'n_control' => $user->n_control,
                            'semestre' => $user->semestre,
                            'group' => $user->group,
                            'workshop' => $user->workshop,
                        ]
                    ]
                ]
            ]);

        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error en la validación de datos.',
                'error_code' => 'VALIDATION_ERROR',
                'errors' => $e->errors()
            ], 422);

        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Usuario o recurso no encontrado.',
                'error_code' => 'NOT_FOUND'
            ], 404);

        } catch (\Exception $e) {
            Log::error('Attach student error: ' . $e->getMessage(), [
                'file' => $e->getFile(),
                'line' => $e->getLine()
            ]);
            
            return response()->json([
                'success' => false,
                'message' => 'Error interno del servidor.',
                'error_code' => 'SERVER_ERROR'
            ], 500);
        }
    }

    /**
     * Get student details by user ID
     */
    public function getStudent(Request $request, $id)
    {
        try {
            $user = User::findOrFail($id);

            // Check if user has student details
            if (!$user->n_control) {
                return response()->json([
                    'success' => false,
                    'message' => 'Usuario no tiene detalles de estudiante asignados.',
                    'error_code' => 'STUDENT_DETAILS_NOT_FOUND'
                ], 404);
            }

            // Load career relationship if exists
            $user->load('career');

            return response()->json([
                'success' => true,
                'message' => 'Operación completada exitosamente',
                'data' => [
                    'user' => [
                        'user_id' => $user->id,
                        'id' => $user->id,
                        'career_id' => $user->career_id,
                        'n_control' => $user->n_control,
                        'semestre' => $user->semestre,
                        'group' => $user->group,
                        'workshop' => $user->workshop,
                        'career' => $user->career ? [
                            'id' => $user->career->id,
                            'name' => $user->career->career_name ?? $user->career->name
                        ] : null
                    ]
                ]
            ]);

        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Usuario no encontrado.',
                'error_code' => 'NOT_FOUND'
            ], 404);

        } catch (\Exception $e) {
            Log::error('Get student error: ' . $e->getMessage(), [
                'file' => $e->getFile(),
                'line' => $e->getLine()
            ]);
            
            return response()->json([
                'success' => false,
                'message' => 'Error interno del servidor.',
                'error_code' => 'SERVER_ERROR'
            ], 500);
        }
    }

    /**
     * Update student details for an existing user
     */
    public function updateStudent(Request $request, $id)
    {
        try {
            $validated = $request->validate([
                'career_id' => 'required|integer|exists:careers,id',
                'group' => 'nullable|string|max:10',
                'workshop' => 'nullable|string|max:100',
            ]);

            $user = User::findOrFail($id);

            // Check if user has student details
            if (!$user->n_control) {
                return response()->json([
                    'success' => false,
                    'message' => 'Usuario no tiene detalles de estudiante asignados. Use attach-student primero.',
                    'error_code' => 'STUDENT_DETAILS_NOT_FOUND'
                ], 404);
            }

            // Update only allowed fields
            $updateData = ['career_id' => $validated['career_id']];
            
            if (isset($validated['group'])) {
                $updateData['group'] = $validated['group'];
            }
            
            if (isset($validated['workshop'])) {
                $updateData['workshop'] = $validated['workshop'];
            }

            $user->update($updateData);

            // Reload user with relationships
            $user->load('roles', 'career');

            return response()->json([
                'success' => true,
                'message' => 'Se actualizaron correctamente los detalles de estudiante.',
                'data' => [
                    'user' => [
                        'id' => $user->id,
                        'name' => $user->name,
                        'last_name' => $user->last_name,
                        'email' => $user->email,
                        'curp' => $user->curp,
                        'phone_number' => $user->phone_number,
                        'birthdate' => $user->birthdate,
                        'gender' => $user->gender,
                        'address' => $user->address,
                        'status' => $user->status,
                        'registration_date' => $user->registration_date,
                        'roles' => $user->roles->map(fn($role) => [
                            'id' => $role->id,
                            'name' => $role->name
                        ]),
                        'studentDetail' => [
                            'user_id' => $user->id,
                            'id' => $user->id,
                            'career_id' => $user->career_id,
                            'n_control' => $user->n_control,
                            'semestre' => $user->semestre,
                            'group' => $user->group,
                            'workshop' => $user->workshop,
                        ]
                    ]
                ]
            ]);

        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error en la validación de datos.',
                'error_code' => 'VALIDATION_ERROR',
                'errors' => $e->errors()
            ], 422);

        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Usuario no encontrado.',
                'error_code' => 'NOT_FOUND'
            ], 404);

        } catch (\Exception $e) {
            Log::error('Update student error: ' . $e->getMessage(), [
                'file' => $e->getFile(),
                'line' => $e->getLine()
            ]);
            
            return response()->json([
                'success' => false,
                'message' => 'Error interno del servidor.',
                'error_code' => 'SERVER_ERROR'
            ], 500);
        }
    }

    /**
     * Update permissions for multiple users
     * Can filter by CURPs or by role (only one of them)
     */
    public function updatePermissions(Request $request)
    {
        try {
            // Log incoming data for debugging
            Log::info('updatePermissions - Datos recibidos:', [
                'curps' => $request->input('curps'),
                'role' => $request->input('role'),
                'permissionsToAdd' => $request->input('permissionsToAdd'),
                'permissionsToRemove' => $request->input('permissionsToRemove'),
            ]);

            $validated = $request->validate([
                'curps' => 'nullable|array',
                'curps.*' => 'string|size:18',
                'role' => 'nullable|string|max:50',
                'permissionsToAdd' => 'nullable|array',
                'permissionsToAdd.*' => 'string|exists:permissions,name',
                'permissionsToRemove' => 'nullable|array',
                'permissionsToRemove.*' => 'string|exists:permissions,name',
            ], [
                'curps.*.size' => 'Cada CURP debe tener exactamente 18 caracteres. CURPs recibidos: ' . json_encode($request->input('curps', [])),
                'role.string' => 'El role debe ser una cadena de texto.',
                'role.max' => 'El role no debe exceder 50 caracteres.',
                'permissionsToAdd.*.exists' => 'Uno o más permisos para agregar no existen. Permisos recibidos: ' . json_encode($request->input('permissionsToAdd', [])),
                'permissionsToRemove.*.exists' => 'Uno o más permisos para eliminar no existen. Permisos recibidos: ' . json_encode($request->input('permissionsToRemove', [])),
            ]);

            // Validate that either curps or role is provided, not both
            $hasCurps = !empty($validated['curps']);
            $hasRole = !empty($validated['role']);

            if (($hasCurps && $hasRole) || (!$hasCurps && !$hasRole)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Debe especificar CURP(s) O role, pero no ambos. Recibido: curps=' . json_encode($validated['curps']) . ', role=' . json_encode($validated['role']),
                    'error_code' => 'INVALID_FILTER'
                ], 422);
            }

            // Validate that at least one permission action is provided
            if (empty($validated['permissionsToAdd']) && empty($validated['permissionsToRemove'])) {
                return response()->json([
                    'success' => false,
                    'message' => 'Debe especificar permisos para agregar o eliminar.',
                    'error_code' => 'NO_PERMISSIONS'
                ], 422);
            }

            // Get users based on filter
            $query = User::query();
            if ($hasCurps) {
                $query->whereIn('curp', $validated['curps']);
            } else {
                $query->whereHas('roles', function ($q) use ($validated) {
                    $q->where('name', $validated['role']);
                });
            }

            $users = $query->with('roles')->get();

            if ($users->isEmpty()) {
                return response()->json([
                    'success' => false,
                    'message' => 'No se encontraron usuarios con los criterios especificados.',
                    'error_code' => 'NO_USERS_FOUND'
                ], 404);
            }

            // Process permissions
            $updatedUsers = [];
            $totalFound = $users->count();
            $totalUpdated = 0;
            $failedUsers = [];
            $permissionsAdded = [];
            $permissionsRemoved = [];

            DB::beginTransaction();

            foreach ($users as $user) {
                try {
                    // Remove permissions
                    if (!empty($validated['permissionsToRemove'])) {
                        foreach ($validated['permissionsToRemove'] as $perm) {
                            if ($user->hasPermissionTo($perm)) {
                                $user->revokePermissionTo($perm);
                                if (!in_array($perm, $permissionsRemoved)) {
                                    $permissionsRemoved[] = $perm;
                                }
                            }
                        }
                    }

                    // Add permissions
                    if (!empty($validated['permissionsToAdd'])) {
                        foreach ($validated['permissionsToAdd'] as $perm) {
                            if (!$user->hasPermissionTo($perm)) {
                                $user->givePermissionTo($perm);
                                if (!in_array($perm, $permissionsAdded)) {
                                    $permissionsAdded[] = $perm;
                                }
                            }
                        }
                    }

                    // Get updated permissions
                    $userPermissions = $user->getAllPermissions()->pluck('name')->toArray();

                    $updatedUsers[] = [
                        'fullName' => trim(($user->name ?? '') . ' ' . ($user->last_name ?? '')),
                        'curp' => $user->curp,
                        'role' => $user->roles->first()?->name ?? 'N/A',
                        'updatedPermissions' => $userPermissions,
                    ];

                    $totalUpdated++;
                } catch (\Exception $e) {
                    Log::warning("Failed to update permissions for user {$user->id}: " . $e->getMessage());
                    $failedUsers[] = $user->id;
                }
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Permisos actualizados correctamente.',
                'data' => [
                    'users_permissions' => $updatedUsers,
                    'metadata' => [
                        'totalFound' => $totalFound,
                        'totalUpdated' => $totalUpdated,
                        'failed' => count($failedUsers),
                        'failedUsers' => $failedUsers,
                        'operations' => [
                            'permissions_removed' => $permissionsRemoved,
                            'permissions_added' => $permissionsAdded,
                        ]
                    ]
                ]
            ]);

        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error en la validación de datos.',
                'error_code' => 'VALIDATION_ERROR',
                'errors' => $e->errors()
            ], 422);

        } catch (\Exception $e) {
            DB::rollBack();
            Log::error('Update permissions error: ' . $e->getMessage(), [
                'file' => $e->getFile(),
                'line' => $e->getLine()
            ]);
            
            return response()->json([
                'success' => false,
                'message' => 'Error interno del servidor.',
                'error_code' => 'SERVER_ERROR'
            ], 500);
        }
    }

    /**
     * Get all users with filtering and pagination
     */
    public function showUsers(Request $request)
    {
        try {
            $perPage = $request->query('perPage', 15);
            $page = $request->query('page', 1);
            $status = $request->query('status', 'activo');
            $forceRefresh = $request->query('forceRefresh', false);

            // Validate pagination params
            $perPage = max(1, min(100, (int)$perPage));
            $page = max(1, (int)$page);

            // Build query
            $query = User::with('roles', 'permissions');

            // Filter by status
            if ($status && $status !== 'all') {
                $query->where('status', $status);
            }

            // Get paginated results
            $paginated = $query->paginate($perPage, ['*'], 'page', $page);

            // Format users
            $users = $paginated->items();
            $formattedUsers = collect($users)->map(function($user) {
                $fullName = trim(($user->name ?? '') . ' ' . ($user->last_name ?? ''));
                
                return [
                    'id' => $user->id,
                    'fullName' => $fullName ?: 'Sin nombre',
                    'email' => $user->email ?? '',
                    'curp' => $user->curp ?? 'N/A',
                    'status' => $user->status,
                    'roles_count' => $user->roles->count(),
                    'created_at' => $user->created_at->format('Y-m-d H:i:s'),
                    'createdAtHuman' => $user->created_at->diffForHumans(),
                ];
            })->toArray();

            return response()->json([
                'success' => true,
                'message' => 'Usuarios encontrados.',
                'data' => [
                    'users' => [
                        'items' => $formattedUsers,
                        'currentPage' => $paginated->currentPage(),
                        'lastPage' => $paginated->lastPage(),
                        'perPage' => $paginated->perPage(),
                        'total' => $paginated->total(),
                        'hasMorePages' => $paginated->hasMorePages(),
                        'nextPage' => $paginated->hasMorePages() ? $paginated->currentPage() + 1 : null,
                    ]
                ]
            ]);

        } catch (\Exception $e) {
            Log::error('Show users error: ' . $e->getMessage(), [
                'file' => $e->getFile(),
                'line' => $e->getLine()
            ]);
            
            return response()->json([
                'success' => false,
                'message' => 'Error interno del servidor.',
                'error_code' => 'SERVER_ERROR'
            ], 500);
        }
    }

    /**
     * Get detailed user information by ID
     */
    public function showUserById(Request $request, $id)
    {
        try {
            $user = User::with('roles', 'permissions', 'career')->findOrFail($id);

            // Basic info
            $basicInfo = [
                'phone_number' => $user->phone_number ?? '',
                'address' => $user->address ?? '',
                'blood_type' => $user->blood_type ?? '',
            ];

            // Roles
            $roles = $user->roles->pluck('name')->toArray();

            // Permissions
            $permissions = $user->permissions->pluck('name')->toArray();

            // Student detail (if applicable)
            $studentDetail = null;
            if ($user->n_control) {
                $studentDetail = [
                    'nControl' => $user->n_control,
                    'semestre' => $user->semestre,
                    'group' => $user->group,
                    'workshop' => $user->workshop,
                    'careerName' => $user->career?->career_name ?? $user->career?->name ?? 'N/A',
                ];
            }

            return response()->json([
                'success' => true,
                'message' => 'Usuario encontrado.',
                'data' => [
                    'user' => [
                        'id' => $user->id,
                        'name' => $user->name,
                        'last_name' => $user->last_name,
                        'email' => $user->email,
                        'curp' => $user->curp,
                        'birthdate' => $user->birthdate,
                        'gender' => $user->gender,
                        'status' => $user->status,
                        'created_at' => $user->created_at,
                        'basicInfo' => $basicInfo,
                        'roles' => $roles,
                        'permissions' => $permissions,
                        'studentDetail' => $studentDetail,
                    ]
                ]
            ]);

        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Usuario no encontrado.',
                'error_code' => 'NOT_FOUND'
            ], 404);

        } catch (\Exception $e) {
            Log::error('Show user by ID error: ' . $e->getMessage(), [
                'file' => $e->getFile(),
                'line' => $e->getLine()
            ]);
            
            return response()->json([
                'success' => false,
                'message' => 'Error interno del servidor.',
                'error_code' => 'SERVER_ERROR'
            ], 500);
        }
    }

    /**
     * Sincroniza roles de múltiples usuarios
     * POST /api/v1/admin-actions/updated-roles
     */
    public function updateRoles(Request $request)
    {
        // Validación
        try {
            $validated = $request->validate([
                'curps' => 'required|array|min:1',
                'curps.*' => 'string|size:18',
                'rolesToAdd' => 'array',
                'rolesToAdd.*' => 'string|exists:roles,name',
                'rolesToRemove' => 'array',
                'rolesToRemove.*' => 'string|exists:roles,name',
            ], [
                'curps.required' => 'El campo curps es requerido.',
                'curps.array' => 'El campo curps debe ser un array.',
                'curps.min' => 'Debe proporcionar al menos un CURP.',
                'curps.*.string' => 'Cada CURP debe ser un texto.',
                'curps.*.size' => 'Cada CURP debe tener exactamente 18 caracteres. Encontrados: ' . 
                    implode(', ', array_map(fn($c) => strlen($c) . ' chars', $request->input('curps', []))),
                'rolesToAdd.*.exists' => 'Uno o más roles para agregar no existen en la base de datos. Roles disponibles: admin, student, financial staff',
                'rolesToRemove.*.exists' => 'Uno o más roles para eliminar no existen en la base de datos. Roles disponibles: admin, student, financial staff',
            ]);
        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error de validación.',
                'error_code' => 'VALIDATION_ERROR',
                'errors' => $e->errors(),
            ], 422);
        }

        try {
            $curps = $validated['curps'];
            $rolesToAdd = $validated['rolesToAdd'] ?? [];
            $rolesToRemove = $validated['rolesToRemove'] ?? [];

            // Buscar usuarios por CURP
            $users = User::whereIn('curp', $curps)->get();
            $totalFound = $users->count();
            $totalUpdated = 0;
            $failed = 0;
            $fullNames = [];
            $processedCurps = [];
            $chunksProcessed = 0;

            // Procesar en chunks para operaciones masivas
            $users->chunk(50)->each(function ($chunk) use (
                $rolesToAdd, 
                $rolesToRemove, 
                &$totalUpdated, 
                &$failed, 
                &$fullNames, 
                &$processedCurps, 
                &$chunksProcessed
            ) {
                foreach ($chunk as $user) {
                    try {
                        // Agregar roles
                        if (!empty($rolesToAdd)) {
                            foreach ($rolesToAdd as $role) {
                                if (!$user->hasRole($role)) {
                                    $user->assignRole($role);
                                }
                            }
                        }

                        // Remover roles
                        if (!empty($rolesToRemove)) {
                            foreach ($rolesToRemove as $role) {
                                if ($user->hasRole($role)) {
                                    $user->removeRole($role);
                                }
                            }
                        }

                        $totalUpdated++;
                        $fullNames[] = $user->name . ' ' . $user->last_name;
                        $processedCurps[] = $user->curp;
                    } catch (\Exception $e) {
                        $failed++;
                        Log::error('Error al actualizar roles para usuario ' . $user->curp . ': ' . $e->getMessage());
                    }
                }
                $chunksProcessed++;
            });

            return response()->json([
                'success' => true,
                'message' => 'Roles actualizados correctamente.',
                'data' => [
                    'users_roles' => [
                        'fullNames' => $fullNames,
                        'curps' => $processedCurps,
                        'updatedRoles' => [
                            'added' => $rolesToAdd,
                            'removed' => $rolesToRemove,
                        ],
                        'metadata' => [
                            'totalFound' => $totalFound,
                            'totalUpdated' => $totalUpdated,
                            'failed' => $failed,
                            'operations' => [
                                'roles_removed' => $rolesToRemove,
                                'roles_added' => $rolesToAdd,
                                'chunks_processed' => $chunksProcessed,
                            ]
                        ]
                    ]
                ]
            ], 200);

        } catch (\Exception $e) {
            Log::error('Error al actualizar roles: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Error interno del servidor.',
                'error_code' => 'SERVER_ERROR',
            ], 500);
        }
    }

    /**
     * Elimina múltiples usuarios (soft delete - cambia status a 'eliminado')
     * POST /api/v1/admin-actions/delete-users
     */
    public function deleteUsers(Request $request)
    {
        // Validación
        $validated = $request->validate([
            'ids' => 'required|array|min:1',
            'ids.*' => 'integer|exists:users,id',
        ]);

        try {
            $ids = $validated['ids'];

            // Actualizar status a 'eliminado'
            $totalUpdated = User::whereIn('id', $ids)
                ->update(['status' => 'eliminado']);

            return response()->json([
                'success' => true,
                'message' => 'Estatus de usuarios actualizados correctamente.',
                'data' => [
                    'concept' => [
                        'newStatus' => 'eliminado',
                        'totalUpdated' => $totalUpdated,
                    ]
                ]
            ], 200);

        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error de validación.',
                'error_code' => 'VALIDATION_ERROR',
                'errors' => $e->errors(),
            ], 422);
        } catch (\Exception $e) {
            Log::error('Error al eliminar usuarios: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Error interno del servidor.',
                'error_code' => 'SERVER_ERROR',
            ], 500);
        }
    }

    /**
     * Da de baja múltiples usuarios (cambia status a 'baja')
     * POST /api/v1/admin-actions/disable-users
     */
    public function disableUsers(Request $request)
    {
        // Validación
        $validated = $request->validate([
            'ids' => 'required|array|min:1',
            'ids.*' => 'integer|exists:users,id',
        ]);

        try {
            $ids = $validated['ids'];

            // Actualizar status a 'baja'
            $totalUpdated = User::whereIn('id', $ids)
                ->update(['status' => 'baja']);

            return response()->json([
                'success' => true,
                'message' => 'Estatus de usuarios actualizados correctamente.',
                'data' => [
                    'concept' => [
                        'newStatus' => 'baja',
                        'totalUpdated' => $totalUpdated,
                    ]
                ]
            ], 200);

        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error de validación.',
                'error_code' => 'VALIDATION_ERROR',
                'errors' => $e->errors(),
            ], 422);
        } catch (\Exception $e) {
            Log::error('Error al dar de baja usuarios: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Error interno del servidor.',
                'error_code' => 'SERVER_ERROR',
            ], 500);
        }
    }

    /**
     * Da de baja temporal a múltiples usuarios (cambia status a 'baja-temporal')
     * POST /api/v1/admin-actions/temporary-disable-users
     */
    public function temporaryDisableUsers(Request $request)
    {
        // Validación
        $validated = $request->validate([
            'ids' => 'required|array|min:1',
            'ids.*' => 'integer|exists:users,id',
        ]);

        try {
            $ids = $validated['ids'];

            // Actualizar status a 'baja-temporal'
            $totalUpdated = User::whereIn('id', $ids)
                ->update(['status' => 'baja-temporal']);

            return response()->json([
                'success' => true,
                'message' => 'Estatus de usuarios actualizados correctamente.',
                'data' => [
                    'concept' => [
                        'newStatus' => 'baja-temporal',
                        'totalUpdated' => $totalUpdated,
                    ]
                ]
            ], 200);

        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error de validación.',
                'error_code' => 'VALIDATION_ERROR',
                'errors' => $e->errors(),
            ], 422);
        } catch (\Exception $e) {
            Log::error('Error al dar de baja temporal usuarios: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Error interno del servidor.',
                'error_code' => 'SERVER_ERROR',
            ], 500);
        }
    }

    /**
     * Muestra permisos existentes filtrados por rol o usuarios
     * POST /api/v1/admin-actions/find-permissions
     */
    public function findPermissions(Request $request)
    {
        // Validación
        $validated = $request->validate([
            'curps' => 'sometimes|array',
            'curps.*' => 'string|size:18',
            'role' => 'sometimes|string|exists:roles,name',
        ]);

        try {
            $curps = $validated['curps'] ?? [];
            $roleName = $validated['role'] ?? null;

            // Si se especifica un rol
            if ($roleName) {
                $role = Role::with('permissions')->where('name', $roleName)->first();
                
                if (!$role) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Rol no encontrado.',
                        'error_code' => 'ROLE_NOT_FOUND',
                    ], 404);
                }

                // Obtener usuarios con este rol
                $users = User::whereHas('roles', function ($query) use ($roleName) {
                    $query->where('name', $roleName);
                })
                ->when(!empty($curps), function ($query) use ($curps) {
                    return $query->whereIn('curp', $curps);
                })
                ->get(['id', 'name', 'last_name', 'curp'])
                ->map(function ($user) {
                    return [
                        'id' => $user->id,
                        'fullName' => $user->name . ' ' . $user->last_name,
                        'curp' => $user->curp,
                    ];
                })
                ->toArray();

                $permissions = $role->permissions
                    ->map(function ($perm) use ($roleName) {
                        return [
                            'id' => $perm->id,
                            'name' => $perm->name,
                            'type' => $perm->guard_name ?? 'model',
                            'belongsTo' => strtoupper($roleName),
                        ];
                    })
                    ->toArray();

                return response()->json([
                    'success' => true,
                    'message' => 'Operación completada exitosamente',
                    'data' => [
                        'permissions' => [
                            'role' => $roleName,
                            'users' => $users,
                            'permissions' => $permissions,
                        ]
                    ]
                ], 200);
            }

            // Si se especifican CURPs
            if (!empty($curps)) {
                $users = User::whereIn('curp', $curps)->get(['id', 'name', 'last_name', 'curp']);
                
                $result = [];
                foreach ($users as $user) {
                    $userRoles = $user->roles->pluck('name')->toArray();
                    $userPermissions = $user->permissions->map(function ($perm) {
                        return [
                            'id' => $perm->id,
                            'name' => $perm->name,
                            'type' => $perm->guard_name ?? 'model',
                        ];
                    })->toArray();

                    $result[] = [
                        'id' => $user->id,
                        'fullName' => $user->name . ' ' . $user->last_name,
                        'curp' => $user->curp,
                        'roles' => $userRoles,
                        'permissions' => $userPermissions,
                    ];
                }

                return response()->json([
                    'success' => true,
                    'message' => 'Operación completada exitosamente',
                    'data' => [
                        'permissions' => [
                            'users' => $result,
                        ]
                    ]
                ], 200);
            }

            // Si no hay filtros, retornar todos los permisos
            $allPermissions = Permission::all()
                ->map(function ($perm) {
                    return [
                        'id' => $perm->id,
                        'name' => $perm->name,
                        'type' => $perm->guard_name ?? 'model',
                    ];
                })
                ->toArray();

            return response()->json([
                'success' => true,
                'message' => 'Operación completada exitosamente',
                'data' => [
                    'permissions' => [
                        'total' => count($allPermissions),
                        'permissions' => $allPermissions,
                    ]
                ]
            ], 200);

        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error de validación.',
                'error_code' => 'VALIDATION_ERROR',
                'errors' => $e->errors(),
            ], 422);
        } catch (\Exception $e) {
            Log::error('Error al obtener permisos: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Error interno del servidor.',
                'error_code' => 'SERVER_ERROR',
            ], 500);
        }
    }

    /**
     * Muestra todos los roles existentes en el sistema
     * GET /api/v1/admin-actions/find-roles?forceRefresh=false
     */
    public function findRoles(Request $request)
    {
        try {
            // Validación del parámetro forceRefresh
            $forceRefresh = $request->query('forceRefresh', 'false') === 'true';
            $cacheKey = 'admin_roles_list';

            // Si forceRefresh es true, limpiar cache
            if ($forceRefresh) {
                Cache::forget($cacheKey);
                Log::info('Admin: Cache de roles actualizado forzadamente');
            }

            // Obtener roles del cache o de la BD
            $roles = Cache::rememberForever($cacheKey, function () {
                return Role::all(['id', 'name'])
                    ->map(function ($role) {
                        return [
                            'id' => $role->id,
                            'name' => $role->name,
                        ];
                    })
                    ->toArray();
            });

            return response()->json([
                'success' => true,
                'message' => 'Operación completada exitosamente',
                'data' => [
                    'roles' => $roles,
                ]
            ], 200);

        } catch (\Exception $e) {
            Log::error('Error al obtener roles: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Error interno del servidor.',
                'error_code' => 'SERVER_ERROR',
            ], 500);
        }
    }

    /**
     * Obtiene un rol específico por su ID
     * GET /api/v1/admin-actions/roles/{id}
     */
    public function getRoleById($id)
    {
        try {
            $role = Role::find($id);

            if (!$role) {
                return response()->json([
                    'success' => false,
                    'message' => 'Rol no encontrado.',
                    'error_code' => 'ROLE_NOT_FOUND',
                ], 404);
            }

            return response()->json([
                'success' => true,
                'message' => 'Operación completada exitosamente',
                'data' => [
                    'role' => [
                        'id' => $role->id,
                        'name' => $role->name,
                    ]
                ]
            ], 200);

        } catch (\Exception $e) {
            Log::error('Error al obtener rol por ID: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Error interno del servidor.',
                'error_code' => 'SERVER_ERROR',
            ], 500);
        }
    }

    /**
     * Obtiene un permiso específico por su ID
     * GET /api/v1/admin-actions/permissions/{id}
     */
    public function getPermissionById($id)
    {
        try {
            $permission = Permission::find($id);

            if (!$permission) {
                return response()->json([
                    'success' => false,
                    'message' => 'Permiso no encontrado.',
                    'error_code' => 'PERMISSION_NOT_FOUND',
                ], 404);
            }

            // Determinar el type basado en guard_name
            $type = $permission->guard_name ?? 'model';
            
            // Determinar belongsTo (simplificado - se puede mejorar con lógica más específica)
            $belongsTo = 'SYSTEM';
            if (strpos($permission->name, 'student') !== false) {
                $belongsTo = 'STUDENT';
            } elseif (strpos($permission->name, 'concept') !== false) {
                $belongsTo = 'CONCEPT';
            } elseif (strpos($permission->name, 'debt') !== false) {
                $belongsTo = 'DEBT';
            } elseif (strpos($permission->name, 'payment') !== false) {
                $belongsTo = 'PAYMENT';
            } elseif (strpos($permission->name, 'user') !== false) {
                $belongsTo = 'USER';
            } elseif (strpos($permission->name, 'permission') !== false || strpos($permission->name, 'role') !== false) {
                $belongsTo = 'ADMIN';
            }

            return response()->json([
                'success' => true,
                'message' => 'Operación completada exitosamente',
                'data' => [
                    'permission' => [
                        'id' => $permission->id,
                        'name' => $permission->name,
                        'type' => $type,
                        'belongsTo' => $belongsTo,
                    ]
                ]
            ], 200);

        } catch (\Exception $e) {
            Log::error('Error al obtener permiso por ID: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Error interno del servidor.',
                'error_code' => 'SERVER_ERROR',
            ], 500);
        }
    }

    /**
     * Promueve a los estudiantes incrementando su semestre
     * Los estudiantes que sobrepasan semestre 12 son dados de baja
     */
    public function promotion(Request $request)
    {
        try {
            Log::info('📋 Iniciando promoción de estudiantes');

            // Obtener todos los estudiantes con rol 'student'
            $students = User::whereHas('roles', function ($query) {
                $query->where('name', 'student');
            })
            ->where('status', '!=', 'baja')  // Excluir ya dados de baja
            ->get();

            Log::info('👥 Estudiantes encontrados: ' . $students->count());

            $usuariosPromovidos = 0;
            $usuariosBaja = 0;

            DB::beginTransaction();

            foreach ($students as $student) {
                try {
                    // Incrementar semestre
                    $newSemester = ($student->semestre ?? 1) + 1;
                    
                    if ($newSemester > 12) {
                        // Dar de baja si sobrepasa semestre 12
                        $student->update(['status' => 'baja', 'semestre' => $newSemester]);
                        Log::info("📋 Usuario {$student->id} ({$student->email}) dado de baja - semestre {$newSemester}");
                        $usuariosBaja++;
                    } else {
                        // Actualizar semestre
                        $student->update(['semestre' => $newSemester]);
                        Log::info("📚 Usuario {$student->id} ({$student->email}) promovido a semestre {$newSemester}");
                        $usuariosPromovidos++;
                    }
                } catch (\Exception $e) {
                    Log::error("Error al procesar estudiante {$student->id}: " . $e->getMessage());
                    throw $e;
                }
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Se ejecutó la promoción de usuarios correctamente.',
                'data' => [
                    'affected' => [
                        'usuarios_promovidos' => $usuariosPromovidos,
                        'usuarios_baja' => $usuariosBaja
                    ]
                ]
            ], 200);

        } catch (\Exception $e) {
            DB::rollBack();
            Log::error('Error en promoción de estudiantes: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Error al ejecutar la promoción de estudiantes.',
                'error_code' => 'PROMOTION_ERROR',
            ], 500);
        }
    }
}
