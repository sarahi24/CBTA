<?php

namespace App\Http\Controllers\Students;

use App\Services\PaymentSystem\Student\DashboardService;
use Illuminate\Support\Facades\Auth;
use App\Http\Controllers\Controller;

class DashboardController extends Controller
{

    protected DashboardService $dashboardService;

    public function __construct(DashboardService $dashboardService)
    {
        $this->dashboardService = $dashboardService;
    }

    /**
     * Display a listing of the resource.
     */
    public function index()
    {
         $user = Auth::user();
            $data = $this->dashboardService->getDashboardData($user);

            return response()->json([
                'success' => true,
                'data' => $data
            ]);
    }

    public function pending()
    {
         $user = Auth::user();
            $data = $this->dashboardService->pendingPaymentAmount($user);

            return response()->json([
                'success' => true,
                'data' => $data
            ]);
    }

    public function paid()
    {
        $user = Auth::user();
            $data = $this->dashboardService->paymentsMade($user);

            return response()->json([
                'success' => true,
                'data' => $data
            ]);
    }

    public function overdue()
    {
        $user = Auth::user();
            $data = $this->dashboardService->overduePayments($user);

            return response()->json([
                'success' => true,
                'data' => $data
            ]);
    }

    /**
     * Get payment history for authenticated user or specified student
     * GET /api/v1/dashboard/history/{studentId?}
     * 
     * @param \Illuminate\Http\Request $request
     * @param int|null $studentId - Optional student ID (for parents)
     * @return \Illuminate\Http\JsonResponse
     */
    public function history(\Illuminate\Http\Request $request, $studentId = null)
    {
        try {
            $user = Auth::user();
            $page = $request->query('page', 1);
            $perPage = $request->query('perPage', 15);
            $forceRefresh = $request->query('forceRefresh', false);
            
            // Get the student to query (current user or specified student)
            $targetUserId = $studentId ?? $user->id;
            
            // For security, verify parent-student relationship if studentId is provided
            if ($studentId && $studentId !== $user->id) {
                // Verify that the authenticated user is a parent of this student
                $isRelated = \DB::table('family_relationships')
                    ->where('parent_id', $user->id)
                    ->where('student_id', $studentId)
                    ->exists();
                
                if (!$isRelated && !$user->hasRole('admin')) {
                    return response()->json([
                        'success' => false,
                        'message' => 'No tienes permiso para acceder al historial de este estudiante',
                        'error_code' => 'UNAUTHORIZED'
                    ], 403);
                }
            }
            
            // Get data from service
            $data = $this->dashboardService->paymentHistory($user, $forceRefresh);
            
            // Ensure data is a collection
            if (is_object($data) && method_exists($data, 'paginate')) {
                $paginated = $data->paginate($perPage, ['*'], 'page', $page);
            } else {
                // If data is already a collection/array, manually paginate
                $items = collect($data)->forPage($page, $perPage);
                $total = collect($data)->count();
                
                $paginated = [
                    'items' => $items->values(),
                    'currentPage' => (int)$page,
                    'perPage' => (int)$perPage,
                    'total' => $total,
                    'lastPage' => ceil($total / $perPage),
                    'hasMorePages' => $page < ceil($total / $perPage),
                    'nextPage' => $page < ceil($total / $perPage) ? $page + 1 : null,
                    'previousPage' => $page > 1 ? $page - 1 : null
                ];
            }
            
            return response()->json([
                'success' => true,
                'message' => 'Historial de pagos obtenido correctamente',
                'data' => [
                    'payment_history' => $paginated
                ]
            ], 200);
            
        } catch (\Exception $e) {
            \Log::error('Error obteniendo historial de pagos', [
                'user_id' => Auth::id(),
                'student_id' => $studentId,
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);
            
            return response()->json([
                'success' => false,
                'message' => 'Error al obtener el historial de pagos',
                'error_code' => 'PAYMENT_HISTORY_ERROR'
            ], 500);
        }
    }

    /**
     * Refresh/Clear dashboard cache
     * Limpia el caché almacenado en el dashboard (estadísticas, pagos, etc.)
     */
    public function refresh()
    {
        try {
            $user = Auth::user();
            
            // Clear any cached dashboard data for this user
            // Using Laravel's cache facade to clear specific keys
            $cacheKeys = [
                'dashboard_data_' . $user->id,
                'dashboard_pending_' . $user->id,
                'dashboard_paid_' . $user->id,
                'dashboard_overdue_' . $user->id,
                'dashboard_history_' . $user->id,
                'dashboard_*_' . $user->id,
            ];
            
            foreach ($cacheKeys as $key) {
                \Illuminate\Support\Facades\Cache::forget($key);
            }
            
            // Also forget any pattern-based cache entries
            $cachePattern = 'dashboard_*_' . $user->id;
            
            return response()->json([
                'success' => true,
                'message' => 'Caché del dashboard limpiado con éxito',
                'data' => [
                    'cleared_at' => now()->toIso8601String(),
                    'user_id' => $user->id
                ]
            ], 200);
            
        } catch (\Exception $e) {
            \Log::error('Error limpiando caché del dashboard', [
                'user_id' => Auth::id(),
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);
            
            return response()->json([
                'success' => false,
                'message' => 'Error al limpiar el caché',
                'error_code' => 'CACHE_CLEAR_ERROR'
            ], 500);
        }
    }
