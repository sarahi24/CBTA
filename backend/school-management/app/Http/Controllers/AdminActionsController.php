<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class AdminActionsController extends Controller
{
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
            Log::info('Usuario autenticado', ['user_id' => $user?->id ?? 'null']);
            
            if (!$user) {
                Log::error('Usuario no autenticado');
                return response()->json([
                    'success' => false,
                    'message' => 'User not authenticated',
                    'error_code' => 'NOT_AUTHENTICATED'
                ], 401);
            }

            Log::info('✅ Usuario autenticado');

            // Start a database transaction
            DB::beginTransaction();
            Log::info('✅ Transacción iniciada');

            // Get the student role
            $modelType = User::class;
            Log::info('Obteniendo estudiantes de la base de datos', ['model_type' => $modelType]);
            
            $studentRole = DB::table('roles')
                ->where('name', 'student')
                ->first();
            
            if (!$studentRole) {
                Log::error('Role "student" no encontrado en la base de datos');
                DB::rollBack();
                return response()->json([
                    'success' => false,
                    'message' => 'El rol "student" no existe en la base de datos',
                    'error_code' => 'ROLE_NOT_FOUND'
                ], 500);
            }

            Log::info('✅ Role de estudiante encontrado', ['role_id' => $studentRole->id]);

            // Get student IDs who have the 'student' role
            $studentIds = DB::table('model_has_roles')
                ->where('role_id', $studentRole->id)
                ->where('model_type', $modelType)
                ->pluck('model_id')
                ->toArray();

            Log::info('✅ IDs de estudiantes obtenidos', ['count' => count($studentIds)]);

            // Handle case where there are no students
            if (empty($studentIds)) {
                Log::info('No hay estudiantes para promover');
                DB::commit();
                return response()->json([
                    'success' => true,
                    'message' => 'Se ejecutó la promoción de usuarios correctamente.',
                    'data' => [
                        'affected' => [
                            'usuarios_promovidos' => 0,
                            'usuarios_baja' => 0
                        ]
                    ]
                ], 200);
            }

            // Fetch the students data in chunks to avoid memory issues
            $promovidos = 0;
            $baja = 0;
            
            $batchSize = 100;
            for ($i = 0; $i < count($studentIds); $i += $batchSize) {
                $batch = array_slice($studentIds, $i, $batchSize);
                
                $students = DB::table('users')
                    ->whereIn('id', $batch)
                    ->select('id', 'semestre')
                    ->get();

                Log::info('Procesando lote de estudiantes', ['batch' => ceil($i / $batchSize), 'count' => $students->count()]);

                foreach ($students as $student) {
                    try {
                        // Get current semester, default to 1 if null
                        $currentSemestre = $student->semestre ?? 1;
                        
                        // Increment semester
                        $newSemestre = $currentSemestre + 1;

                        Log::debug('Procesando estudiante', [
                            'student_id' => $student->id,
                            'semestre_actual' => $currentSemestre,
                            'semestre_nuevo' => $newSemestre
                        ]);

                        // If new semester exceeds 12, set status to "baja"
                        if ($newSemestre > 12) {
                            $updateResult = DB::table('users')
                                ->where('id', $student->id)
                                ->update([
                                    'status' => 'baja',
                                    'semestre' => 12
                                ]);
                            
                            if ($updateResult) {
                                $baja++;
                                Log::info('Estudiante dado de baja', ['student_id' => $student->id, 'semestre' => 12]);
                            } else {
                                Log::warning('Update retornó 0 para estudiante', ['student_id' => $student->id]);
                            }
                        } else {
                            // Otherwise, just increment semester
                            $updateResult = DB::table('users')
                                ->where('id', $student->id)
                                ->update([
                                    'semestre' => $newSemestre
                                ]);
                            
                            if ($updateResult) {
                                $promovidos++;
                                Log::info('Estudiante promovido', ['student_id' => $student->id, 'semestre' => $newSemestre]);
                            } else {
                                Log::warning('Update retornó 0 para estudiante', ['student_id' => $student->id]);
                            }
                        }
                    } catch (\Throwable $e) {
                        Log::error('Error al procesar estudiante', [
                            'student_id' => $student->id ?? 'unknown',
                            'error' => $e->getMessage(),
                            'line' => $e->getLine(),
                            'file' => $e->getFile()
                        ]);
                        throw $e;
                    }
                }
            }

            DB::commit();
            Log::info('✅ Transacción completada exitosamente', ['promovidos' => $promovidos, 'baja' => $baja]);

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
            try {
                DB::rollBack();
                Log::info('✅ Rollback de transacción ejecutado correctamente');
            } catch (\Throwable $rollbackError) {
                Log::error('Error al hacer rollback de transacción', [
                    'error' => $rollbackError->getMessage(),
                    'line' => $rollbackError->getLine()
                ]);
            }
            
            Log::error('❌ Error en promoción de estudiantes', [
                'error' => $e->getMessage(),
                'file' => $e->getFile(),
                'line' => $e->getLine()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Error al ejecutar la promoción de estudiantes: ' . $e->getMessage(),
                'error_code' => 'PROMOTION_ERROR'
            ], 500);
        }
    }
}
