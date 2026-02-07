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

    public function history()
    {
         $user = Auth::user();
            $data = $this->dashboardService->paymentHistory($user);

            return response()->json([
                'success' => true,
                'data' => $data,
                'message' => $data->isEmpty()?'No hay pagos registrados en el historial':null

            ]);
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
