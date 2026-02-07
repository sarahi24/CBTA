<?php

namespace App\Http\Controllers\Students;

use App\Http\Controllers\Controller;
use App\Services\PaymentSystem\Student\PendingPaymentService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;


class PendingPaymentController extends Controller
{

    protected PendingPaymentService $pendingPaymentService;

    public function __construct(PendingPaymentService $pendingPaymentService)
    {
        $this->pendingPaymentService= $pendingPaymentService;

    }

    public function index()
    {
        $user = Auth::user();
        $pending=$this->pendingPaymentService->showPendingPayments($user);
        return response()->json([
            'success' => true,
            'data' => $pending,
            'message' => $pending->isEmpty() ? 'No hay pagos pendientes para el usuario.':null
        ]);

    }

    public function overdue()
    {
        $user = Auth::user();
        $pending=$this->pendingPaymentService->showOverduePayments($user);
        return response()->json([
            'success' => true,
            'data' => $pending,
            'message' => $pending->isEmpty() ? 'No hay pagos vencidos para el usuario.':null
        ]);

    }

    public function store(Request $request)
    {
        $user = Auth::user();
        $payment= $this->pendingPaymentService->payConcept(
                $user,
                $request->integer('concept_id')
            );


        return response()->json([
            'success'=>true,
            'data'=>$payment,
            'message' => 'El intento de pago se genero con exito.',
        ], 201);

    }

    public function getAllPending(Request $request, $studentId = null)
    {
        $user = Auth::user();
        $targetUserId = $studentId ?? $user->id;

        // Verify parent-student relationship if accessing different user's data
        if ($targetUserId != $user->id) {
            $isParent = $user->hasRole('parent') && 
                       $user->children()
                            ->where('children.id', $targetUserId)
                            ->exists();
            
            if (!$isParent && !$user->hasRole('admin')) {
                return response()->json([
                    'success' => false,
                    'message' => 'No autorizado',
                    'error_code' => 'UNAUTHORIZED'
                ], 403);
            }
        }

        $targetUser = \App\Models\User::findOrFail($targetUserId);
        
        try {
            $pendingPayments = \App\Models\PaymentConcept::pendingPaymentConcept($targetUser)
                ->select('id', 'concept_name', 'description', 'amount', 'start_date', 'end_date')
                ->get()
                ->map(fn($concept) => [
                    'id' => $concept->id,
                    'concept_name' => $concept->concept_name,
                    'description' => $concept->description,
                    'amount' => $concept->amount,
                    'start_date' => $concept->start_date,
                    'end_date' => $concept->end_date,
                ]);

            return response()->json([
                'success' => true,
                'message' => 'Operación completada exitosamente',
                'data' => [
                    'pending_payments' => $pendingPayments
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error al obtener pagos pendientes',
                'error_code' => 'FETCH_ERROR'
            ], 500);
        }
    }

}
