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
     * Promote students to next semester and deactivate those exceeding semester 12
     * 
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function promoteStudents(Request $request)
    {
        Log::info('🔄 Iniciando promoción de estudiantes');
        
        try {
            // Verify user is authenticated
            $user = $request->user();
            if (!$user) {
                Log::error('Usuario no autenticado');
                return response()->json([
                    'success' => false,
                    'message' => 'User not authenticated',
                    'error_code' => 'NOT_AUTHENTICATED'
                ], 401);
            }
            
            Log::info('✅ Usuario autenticado', ['user_id' => $user->id]);

            // Start a database transaction
            DB::beginTransaction();
            Log::info('✅ Transacción iniciada');

            try {
                // Get the student role
                $modelType = User::class;
                Log::info('Buscando rol de estudiante');
                
                $studentRole = DB::table('roles')
                    ->where('name', 'student')
                    ->first();
                
                if (!$studentRole) {
                    Log::error('Role "student" no encontrado en roles table');
                    DB::rollBack();
                    return response()->json([
                        'success' => false,
                        'message' => 'El rol "student" no existe en la base de datos',
                        'error_code' => 'ROLE_NOT_FOUND'
                    ], 500);
                }

                Log::info('✅ Rol de estudiante encontrado', ['role_id' => $studentRole->id]);

                // Get student IDs
                Log::info('Obteniendo IDs de estudiantes');
                
                $studentIds = DB::table('model_has_roles')
                    ->where('role_id', $studentRole->id)
                    ->where('model_type', $modelType)
                    ->pluck('model_id')
                    ->toArray();

                Log::info('✅ IDs obtenidos', ['count' => count($studentIds)]);

                if (empty($studentIds)) {
                    Log::info('No hay estudiantes para promover');
                    DB::commit();
                    return response()->json([
                        'success' => true,
                        'message' => 'Se ejecutó la promoción de usuarios correctamente.',
                        'data' => ['affected' => ['usuarios_promovidos' => 0, 'usuarios_baja' => 0]]
                    ], 200);
                }

                // Process students
                $promovidos = 0;
                $baja = 0;
                $processedCount = 0;
                
                // Fetch all students at once (since we already have IDs)
                $students = DB::table('users')
                    ->whereIn('id', $studentIds)
                    ->select('id', 'semestre')
                    ->get();

                Log::info('Procesando estudiantes', ['total' => $students->count()]);

                foreach ($students as $student) {
                    $processedCount++;
                    
                    // Get current semester
                    $currentSemestre = (int)($student->semestre ?? 1);
                    $newSemestre = $currentSemestre + 1;

                    // Update student
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

                    if ($processedCount % 50 === 0) {
                        Log::info('Progreso', ['procesados' => $processedCount, 'total' => $students->count()]);
                    }
                }

                DB::commit();
                Log::info('✅ Transacción completada', ['promovidos' => $promovidos, 'baja' => $baja]);

                return response()->json([
                    'success' => true,
                    'message' => 'Se ejecutó la promoción de usuarios correctamente.',
                    'data' => [
                        'affected' => [
                            'usuarios_promovidos' => $promovidos,
                            'usuarios_baja' => $baja
                        ]
                    ]
                ], 200);

            } catch (\Throwable $e) {
                DB::rollBack();
                Log::error('Error durante procesamiento de estudiantes', [
                    'error' => $e->getMessage(),
                    'file' => $e->getFile(),
                    'line' => $e->getLine()
                ]);
                throw $e;
            }

        } catch (\Throwable $e) {
            Log::error('❌ Error en promoción de estudiantes', [
                'error' => $e->getMessage(),
                'file' => $e->getFile(),
                'line' => $e->getLine(),
                'trace' => $e->getTraceAsString()
            ]);

            $errorResponse = [
                'success' => false,
                'message' => $e->getMessage(),
                'error_code' => 'PROMOTION_ERROR'
            ];
            
            // Include trace in debug mode
            if (config('app.debug')) {
                $errorResponse['debug'] = [
                    'file' => $e->getFile(),
                    'line' => $e->getLine(),
                    'trace' => $e->getTraceAsString()
                ];
            }

            return response()->json($errorResponse, 500);
        }
    }
}
