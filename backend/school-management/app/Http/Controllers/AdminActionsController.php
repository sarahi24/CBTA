<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

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
        try {
            // Verify user has admin role
            $user = $request->user();
            
            if (!$user || !$user->hasRole('admin')) {
                return response()->json([
                    'success' => false,
                    'message' => 'Insufficient permissions. Admin role required.',
                    'error_code' => 'PERMISSION_DENIED'
                ], 403);
            }

            // Verify user has the promote.student permission
            if (!$user->hasPermissionTo('promote.student')) {
                return response()->json([
                    'success' => false,
                    'message' => 'Insufficient permissions. promote.student permission required.',
                    'error_code' => 'PERMISSION_DENIED'
                ], 403);
            }

            // Start a database transaction
            DB::beginTransaction();

            // Get all students (regardless of status)
            $students = User::whereHas('roles', function($query) {
                $query->where('name', 'student');
            })->get();

            $promovidos = 0;
            $baja = 0;

            foreach ($students as $student) {
                // Get current semester, default to 1 if null
                $currentSemestre = $student->semestre ?? 1;
                
                // Increment semester
                $newSemestre = $currentSemestre + 1;

                // If new semester exceeds 12, set status to "baja"
                if ($newSemestre > 12) {
                    $student->update([
                        'status' => 'baja',
                        'semestre' => 12  // Keep at 12 or set to null based on preference
                    ]);
                    $baja++;
                } else {
                    // Otherwise, just increment semester
                    $student->update([
                        'semestre' => $newSemestre
                    ]);
                    $promovidos++;
                }
            }

            DB::commit();

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
            
            \Log::error('Error en promoción de estudiantes', [
                'error' => $e->getMessage(),
                'file' => $e->getFile(),
                'line' => $e->getLine(),
                'trace' => $e->getTraceAsString()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Error al ejecutar la promoción de estudiantes',
                'error_code' => 'PROMOTION_ERROR'
            ], 500);
        }
    }
}
