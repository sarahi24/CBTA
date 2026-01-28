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
}
