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

            // Get all students using direct database queries to avoid relationship issues
            Log::info('Obteniendo estudiantes de la base de datos');
            
            // Get student IDs who have the 'student' role
            $studentIds = DB::table('model_has_roles')
                ->where('model_type', User::class)
                ->whereIn('role_id', function($query) {
                    $query->select('id')
                        ->from('roles')
                        ->where('name', 'student');
                })
                ->pluck('model_id')
                ->toArray();

            Log::info('✅ IDs de estudiantes obtenidos', ['count' => count($studentIds), 'ids' => implode(',', array_slice($studentIds, 0, 10))]);

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

            // Fetch the students data
            $students = DB::table('users')
                ->whereIn('id', $studentIds)
                ->select('id', 'semestre')
                ->get();

            Log::info('✅ Estudiantes obtenidos de la BD', ['count' => $students->count()]);

            $promovidos = 0;
            $baja = 0;

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
                        DB::table('users')
                            ->where('id', $student->id)
                            ->update([
                                'status' => 'baja',
                                'semestre' => 12
                            ]);
                        $baja++;
                        Log::info('Estudiante dado de baja', ['student_id' => $student->id, 'semestre' => 12]);
                    } else {
                        // Otherwise, just increment semester
                        DB::table('users')
                            ->where('id', $student->id)
                            ->update([
                                'semestre' => $newSemestre
                            ]);
                        $promovidos++;
                        Log::info('Estudiante promovido', ['student_id' => $student->id, 'semestre' => $newSemestre]);
                    }
                } catch (\Exception $e) {
                    Log::error('Error al procesar estudiante', [
                        'student_id' => $student->id ?? 'unknown',
                        'error' => $e->getMessage(),
                        'line' => $e->getLine(),
                        'file' => $e->getFile()
                    ]);
                    throw $e;
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
