<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Permission;

class PermissionsSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Desactivar caché para evitar problemas
        app()['cache']->forget('spatie.permission.cache');

        // Lista completa de permisos del sistema
        $permissions = [
            // ==================== PERMISOS DE ADMIN ====================
            'promote.student' => 'Promover Estudiante',
            'attach.student' => 'Asociar Estudiante',
            'view.student' => 'Ver Detalles del Estudiante',
            'update.student' => 'Actualizar Estudiante',
            'sync.permissions' => 'Sincronizar Permisos',
            'view.users' => 'Ver Usuarios',
            'sync.roles' => 'Sincronizar Roles',
            'delete.users' => 'Eliminar Usuarios',
            'disable.users' => 'Deshabilitar Usuarios',
            'view.permissions' => 'Ver Permisos',
            'view.roles' => 'Ver Roles',

            // ==================== PERMISOS DE FINANCIAL STAFF ====================
            'view all financial overview' => 'Ver Resumen Financiero General',
            'view all pending concepts summary' => 'Ver Resumen de Conceptos Pendientes',
            'view all students summary' => 'Ver Resumen General de Estudiantes',
            'view all paid concepts summary' => 'Ver Resumen de Conceptos Pagados',
            'view concepts history' => 'Ver Historial de Conceptos',
            'view concepts' => 'Ver Conceptos de Cobro',
            'create concepts' => 'Crear Conceptos de Cobro',
            'update concepts' => 'Actualizar Conceptos de Cobro',
            'finalize concepts' => 'Finalizar Conceptos de Cobro',
            'disable concepts' => 'Deshabilitar Conceptos de Cobro',
            'eliminate concepts' => 'Eliminar Conceptos de Cobro',
            'eliminate.logical.concepts' => 'Eliminar Conceptos (Borrado Lógico)',
            'view debts' => 'Ver Deudas de Estudiantes',
            'validate debt' => 'Validar Deudas',
            'view payments' => 'Ver Pagos Realizados',
            'view students' => 'Ver Lista de Estudiantes',

            // ==================== PERMISOS DE ESTUDIANTE ====================
            'view own financial overview' => 'Ver Mi Resumen Financiero',
            'view own pending concepts summary' => 'Ver Mis Conceptos Pendientes',
            'view own paid concepts summary' => 'Ver Mis Conceptos Pagados',
            'view own overdue concepts summary' => 'Ver Mis Conceptos Vencidos',
            'view payments history' => 'Ver Historial de Pagos',
            'view cards' => 'Ver Tarjetas Guardadas',
            'create setup' => 'Crear Nuevo Método de Pago',
            'create and view card' => 'Crear y Ver Tarjetas',
            'delete card' => 'Eliminar Tarjeta',
            'view payment history' => 'Ver Historial de Pagos',
            'view pending concepts' => 'Ver Conceptos Pendientes',
            'create payment' => 'Realizar Pago',
            'view overdue concepts' => 'Ver Conceptos Vencidos',
        ];

        $createdCount = 0;
        $skippedCount = 0;

        foreach ($permissions as $name => $description) {
            try {
                $permission = Permission::where('name', $name)->first();
                
                if (!$permission) {
                    Permission::create([
                        'name' => $name,
                        'guard_name' => 'api',
                        'description' => $description,
                    ]);
                    $createdCount++;
                    $this->command->info("✅ Permiso creado: {$name}");
                } else {
                    $skippedCount++;
                    $this->command->warn("⏭️  Permiso ya existe: {$name}");
                }
            } catch (\Exception $e) {
                $this->command->error("❌ Error creando permiso {$name}: " . $e->getMessage());
            }
        }

        $this->command->info("\n✅ Seeder completado:");
        $this->command->info("   Creados: {$createdCount}");
        $this->command->info("   Ya existían: {$skippedCount}");
        $this->command->info("   Total esperado: " . count($permissions));

        // Verificar total en BD
        $totalInDB = Permission::count();
        $this->command->info("   Total en BD: {$totalInDB}");
    }
}
