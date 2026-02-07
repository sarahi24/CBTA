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

    public function createPaymentIntent(Request $request)
    {
        try {
            // Validar concepto_id
            $validated = $request->validate([
                'concept_id' => 'required|integer|exists:payment_concepts,id'
            ]);

            $user = Auth::user();
            $conceptId = $validated['concept_id'];

            // Crear sesión de pago
            $checkoutUrl = $this->pendingPaymentService->payConcept($user, $conceptId);

            return response()->json([
                'success' => true,
                'message' => 'Operación completada exitosamente',
                'data' => [
                    'url_checkout' => $checkoutUrl
                ]
            ], 201);
        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error de validación',
                'error_code' => 'VALIDATION_ERROR',
                'errors' => $e->errors()
            ], 422);
        } catch (\Exception $e) {
            \Log::error('Error creating payment intent: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Error al crear el intento de pago',
                'error_code' => 'STRIPE_ERROR'
            ], 502);
        }
    }

    public function getOverduePayments(Request $request, $studentId = null)
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
            $overduePayments = \App\Models\PaymentConcept::where('status', 'finalizado')
                ->whereDoesntHave('payments', fn($q) => $q->where('user_id', $targetUser->id))
                ->where(function($q) use ($targetUser) {
                    $q->where('is_global', true)
                      ->orWhereHas('users', fn($q) => $q->where('users.id', $targetUser->id))
                      ->orWhereHas('careers', fn($q) => $q->where('careers.id', $targetUser->career_id))
                      ->orWhereHas('paymentConceptSemesters', fn($q) => $q->where('semestre', $targetUser->semestre));
                })
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
                    'pending_payments' => $overduePayments
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error al obtener pagos vencidos',
                'error_code' => 'FETCH_ERROR'
            ], 500);
        }
    }

}
