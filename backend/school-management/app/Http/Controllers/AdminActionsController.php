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
}
