<?php

namespace App\Http\Controllers\Staff;

use App\Http\Controllers\Controller;
use App\Services\PaymentSystem\Staff\PaymentsService;
use Illuminate\Http\Request;

class PaymentsController extends Controller
{

    protected PaymentsService $paymentsService;

    public function __construct(PaymentsService $paymentsService)
    {
        $this->paymentsService = $paymentsService;
    }

    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        $search = $request->query('search');

        $payments = $this->paymentsService->showAllPayments($search);

        return response()->json([
            'success' => true,
            'data' => $payments,
            'message' => $payments->isEmpty() ? 'No hay pagos registrados.':null
        ]);
    }

    /**
     * Get students with payment summary
     * Endpoint: GET /api/v1/payments/students
     */
    public function students(Request $request)
    {
        $search = $request->query('search', '');
        $page = (int) $request->query('page', 1);
        $perPage = (int) $request->query('perPage', 15);
        $forceRefresh = $request->query('forceRefresh', 'false') === 'true';

        try {
            $students = $this->paymentsService->getStudentsWithPaymentSummary(
                $search,
                $page,
                $perPage,
                $forceRefresh
            );

            return response()->json([
                'success' => true,
                'data' => $students,
                'message' => null
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error_code' => 'INTERNAL_SERVER_ERROR',
                'message' => 'Ocurrió un error al obtener los estudiantes: ' . $e->getMessage()
            ], 500);
        }
    }


}
