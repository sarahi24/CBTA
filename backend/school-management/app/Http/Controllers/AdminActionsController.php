<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class AdminActionsController extends Controller
{
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
            // Verify user has admin role
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

            if (!$user->hasRole('admin')) {
                Log::error('Usuario sin rol admin', ['user_id' => $user->id, 'roles' => $user->roles->pluck('name')]);
                return response()->json([
                    'success' => false,
                    'message' => 'Insufficient permissions. Admin role required.',
                    'error_code' => 'PERMISSION_DENIED'
                ], 403);
            }

            Log::info('✅ Usuario autenticado con rol admin');

            // Start a database transaction
            DB::beginTransaction();
            Log::info('✅ Transacción iniciada');

            // Get all students (regardless of status)
            $students = User::whereHas('roles', function($query) {
                $query->where('name', 'student');
            })->get();

            Log::info('✅ Estudiantes obtenidos', ['count' => $students->count()]);

            $promovidos = 0;
            $baja = 0;

            foreach ($students as $student) {
                try {
                    // Get current semester, default to 1 if null
                    $currentSemestre = $student->semestre ?? 1;
                    
                    // Increment semester
                    $newSemestre = $currentSemestre + 1;

                    // If new semester exceeds 12, set status to "baja"
                    if ($newSemestre > 12) {
                        $student->update([
                            'status' => 'baja',
                            'semestre' => 12
                        ]);
                        $baja++;
                        Log::info('Estudiante dado de baja', ['student_id' => $student->id, 'semestre' => 12]);
                    } else {
                        // Otherwise, just increment semester
                        $student->update([
                            'semestre' => $newSemestre
                        ]);
                        $promovidos++;
                        Log::info('Estudiante promovido', ['student_id' => $student->id, 'semestre' => $newSemestre]);
                    }
                } catch (\Exception $e) {
                    Log::error('Error al procesar estudiante', [
                        'student_id' => $student->id,
                        'error' => $e->getMessage(),
                        'trace' => $e->getTraceAsString()
                    ]);
                    throw $e;
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

        } catch (\Exception $e) {
            DB::rollBack();
            
            Log::error('❌ Error en promoción de estudiantes', [
                'error' => $e->getMessage(),
                'file' => $e->getFile(),
                'line' => $e->getLine(),
                'trace' => $e->getTraceAsString()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Error al ejecutar la promoción de estudiantes: ' . $e->getMessage(),
                'error_code' => 'PROMOTION_ERROR'
            ], 500);
        }
    }
}
