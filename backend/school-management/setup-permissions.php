<?php
/**
 * Script to ensure permissions are created and assigned to roles
 * Run this in the Laravel environment: php artisan tinker
 * Then paste the contents of this file
 */

use Spatie\Permission\Models\Permission;
use Spatie\Permission\Models\Role;

// Clear cached permissions
app(Spatie\Permission\PermissionRegistrar::class)->forgetCachedPermissions();

echo "🔧 Setting up permissions...\n";

// Student permissions
$studentPermissions = [
    'view own financial overview',
    'view own pending concepts summary',
    'view own paid concepts summary',
    'view own overdue concepts summary',
    'view payments history',
    'view cards',
    'create setup',
    'create and view card',
    'delete card',
    'view payment history',
    'view pending concepts',
    'create payment',
    'view overdue concepts',
];

foreach ($studentPermissions as $perm) {
    Permission::firstOrCreate(['name' => $perm]);
}
echo "✅ Student permissions created\n";

// Staff permissions
$staffPermissions = [
    'view all financial overview',
    'view all pending concepts summary',
    'view all students summary',
    'view all paid concepts summary',
    'view concepts history',
    'view concepts',
    'create concepts',
    'update concepts',
    'finalize concepts',
    'disable concepts',
    'eliminate concepts',
    'view debts',
    'validate debt',
    'view payments',
    'view students',
];

foreach ($staffPermissions as $perm) {
    Permission::firstOrCreate(['name' => $perm]);
}
echo "✅ Staff permissions created\n";

// Admin permissions
$adminPermissions = [
    'promote.student',
];

foreach ($adminPermissions as $perm) {
    Permission::firstOrCreate(['name' => $perm]);
}
echo "✅ Admin permissions created\n";

// Assign permissions to roles
$studentRole = Role::firstOrCreate(['name' => 'student']);
$studentRole->syncPermissions($studentPermissions);
echo "✅ Student role permissions assigned\n";

$staffRole = Role::firstOrCreate(['name' => 'financial staff']);
$staffRole->syncPermissions($staffPermissions);
echo "✅ Staff role permissions assigned\n";

$adminRole = Role::firstOrCreate(['name' => 'admin']);
$adminRole->syncPermissions(array_merge($staffPermissions, $adminPermissions));
echo "✅ Admin role permissions assigned\n";

echo "\n✨ All permissions and roles are configured!\n";
