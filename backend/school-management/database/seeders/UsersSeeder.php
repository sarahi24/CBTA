<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Spatie\Permission\Models\Role;

class UsersSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Verificar si los roles existen, si no, crearlos
        $this->ensureRolesExist();

        // Crear usuarios de prueba
        $this->createAdminUsers();
        $this->createFinancialStaffUsers();
        $this->createStudentUsers();
    }

    /**
     * Asegurar que los roles necesarios existan
     */
    private function ensureRolesExist(): void
    {
        $roles = ['admin', 'financial staff', 'student', 'parent'];

        foreach ($roles as $roleName) {
            Role::firstOrCreate(['name' => $roleName]);
        }

        $this->command->info('✅ Roles verificados/creados');
    }

    /**
     * Crear usuarios administradores
     */
    private function createAdminUsers(): void
    {
        $admins = [
            [
                'name' => 'Admin Principal',
                'email' => 'admin@uni.edu',
                'password' => 'password123',
                'role' => 'admin',
            ],
            [
                'name' => 'Super Admin',
                'email' => 'superadmin@cbta71.edu.mx',
                'password' => 'admin123',
                'role' => 'admin',
            ],
        ];

        foreach ($admins as $adminData) {
            $user = User::firstOrCreate(
                ['email' => $adminData['email']],
                [
                    'name' => $adminData['name'],
                    'password' => Hash::make($adminData['password']),
                    'email_verified_at' => now(),
                ]
            );

            if (!$user->hasRole($adminData['role'])) {
                $user->assignRole($adminData['role']);
            }

            $this->command->info("✅ Admin: {$adminData['email']} | Password: {$adminData['password']}");
        }
    }

    /**
     * Crear usuarios de personal financiero (caja)
     */
    private function createFinancialStaffUsers(): void
    {
        $staff = [
            [
                'name' => 'María González',
                'email' => 'caja@cbta71.edu.mx',
                'password' => 'caja123',
                'role' => 'financial staff',
            ],
            [
                'name' => 'Juan Pérez',
                'email' => 'finanzas@cbta71.edu.mx',
                'password' => 'finanzas123',
                'role' => 'financial staff',
            ],
        ];

        foreach ($staff as $staffData) {
            $user = User::firstOrCreate(
                ['email' => $staffData['email']],
                [
                    'name' => $staffData['name'],
                    'password' => Hash::make($staffData['password']),
                    'email_verified_at' => now(),
                ]
            );

            if (!$user->hasRole($staffData['role'])) {
                $user->assignRole($staffData['role']);
            }

            $this->command->info("✅ Staff: {$staffData['email']} | Password: {$staffData['password']}");
        }
    }

    /**
     * Crear usuarios estudiantes
     */
    private function createStudentUsers(): void
    {
        $students = [
            [
                'name' => 'Carlos Ramírez',
                'email' => 'carlos.ramirez@estudiante.cbta71.edu.mx',
                'password' => 'student123',
                'role' => 'student',
            ],
            [
                'name' => 'Ana Torres',
                'email' => 'ana.torres@estudiante.cbta71.edu.mx',
                'password' => 'student123',
                'role' => 'student',
            ],
            [
                'name' => 'Luis Martínez',
                'email' => 'luis.martinez@estudiante.cbta71.edu.mx',
                'password' => 'student123',
                'role' => 'student',
            ],
        ];

        foreach ($students as $studentData) {
            $user = User::firstOrCreate(
                ['email' => $studentData['email']],
                [
                    'name' => $studentData['name'],
                    'password' => Hash::make($studentData['password']),
                    'email_verified_at' => now(),
                ]
            );

            if (!$user->hasRole($studentData['role'])) {
                $user->assignRole($studentData['role']);
            }

            $this->command->info("✅ Student: {$studentData['email']} | Password: {$studentData['password']}");
        }
    }
}
