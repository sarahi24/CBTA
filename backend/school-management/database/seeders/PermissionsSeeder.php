<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Permission;
use Spatie\Permission\Models\Role;

class PermissionsSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Desactivar caché para evitar problemas
        app()['cache']->forget('spatie.permission.cache');

        // ==================== PERMISOS DE ADMIN (11) ====================
        $adminPermissions = [
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
        ];

        // ==================== PERMISOS DE FINANCIAL STAFF (16) ====================
        $staffPermissions = [
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
        ];

        // ==================== PERMISOS DE ESTUDIANTE (13) ====================
        $studentPermissions = [
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

        $allPermissions = array_merge($adminPermissions, $staffPermissions, $studentPermissions);
        $createdCount = 0;
        $skippedCount = 0;

        // Crear todos los permisos
        foreach ($allPermissions as $name => $description) {
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
                }
            } catch (\Exception $e) {
                $this->command->error("❌ Error creando permiso {$name}: " . $e->getMessage());
            }
        }

        // Asignar permisos a roles
        $this->command->info("\n📌 Asignando permisos a roles...\n");
        
        // Obtener roles
        $adminRole = Role::where('name', 'admin')->first();
        $staffRole = Role::where('name', 'financial staff')->first();
        $studentRole = Role::where('name', 'student')->first();

        // Asignar permisos de ADMIN
        if ($adminRole) {
            foreach ($adminPermissions as $permName => $description) {
                $perm = Permission::where('name', $permName)->first();
                if ($perm && !$adminRole->hasPermissionTo($perm)) {
                    $adminRole->givePermissionTo($perm);
                    $this->command->info("✅ Permiso '{$permName}' asignado a admin");
                } elseif ($perm) {
                    $this->command->warn("⏭️  Admin ya tiene permiso '{$permName}'");
                }
            }
        } else {
            $this->command->error("❌ Rol 'admin' no encontrado");
        }

        // Asignar permisos de FINANCIAL STAFF
        if ($staffRole) {
            foreach ($staffPermissions as $permName => $description) {
                $perm = Permission::where('name', $permName)->first();
                if ($perm && !$staffRole->hasPermissionTo($perm)) {
                    $staffRole->givePermissionTo($perm);
                    $this->command->info("✅ Permiso '{$permName}' asignado a financial staff");
                } elseif ($perm) {
                    $this->command->warn("⏭️  Financial staff ya tiene permiso '{$permName}'");
                }
            }
        } else {
            $this->command->error("❌ Rol 'financial staff' no encontrado");
        }

        // Asignar permisos de STUDENT
        if ($studentRole) {
            foreach ($studentPermissions as $permName => $description) {
                $perm = Permission::where('name', $permName)->first();
                if ($perm && !$studentRole->hasPermissionTo($perm)) {
                    $studentRole->givePermissionTo($perm);
                    $this->command->info("✅ Permiso '{$permName}' asignado a student");
                } elseif ($perm) {
                    $this->command->warn("⏭️  Student ya tiene permiso '{$permName}'");
                }
            }
        } else {
            $this->command->error("❌ Rol 'student' no encontrado");
        }

        // Resumen
        $this->command->info("\n" . str_repeat("=", 60));
        $this->command->info("✅ SEEDER COMPLETADO");
        $this->command->info(str_repeat("=", 60));
        $this->command->info("📊 Permisos:");
        $this->command->info("   Creados: {$createdCount}");
        $this->command->info("   Ya existían: {$skippedCount}");
        $this->command->info("   Total esperado: " . count($allPermissions));
        
        $totalInDB = Permission::count();
        $this->command->info("   Total en BD: {$totalInDB}");

        $this->command->info("\n👥 Asignaciones por rol:");
        if ($adminRole) {
            $adminPermsCount = $adminRole->permissions()->count();
            $this->command->info("   ✅ Admin: {$adminPermsCount} permisos (esperado: 11)");
        }
        if ($staffRole) {
            $staffPermsCount = $staffRole->permissions()->count();
            $this->command->info("   ✅ Financial Staff: {$staffPermsCount} permisos (esperado: 16)");
        }
        if ($studentRole) {
            $studentPermsCount = $studentRole->permissions()->count();
            $this->command->info("   ✅ Student: {$studentPermsCount} permisos (esperado: 13)");
        }

        $this->command->info("\n🚀 Para verificar, ejecuta:");
        $this->command->info("   GET /api/v1/admin-actions/debug/permissions-count");
        $this->command->info("\n");
    }
}
