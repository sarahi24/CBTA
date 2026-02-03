<?php

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use App\Models\User;
use Illuminate\Support\Facades\DB;

echo "═══════════════════════════════════════════════════════════\n";
echo "   CHECKING USER ROLES IN DATABASE\n";
echo "═══════════════════════════════════════════════════════════\n\n";

// Check roles table
echo "📊 Checking roles table...\n";
$roles = DB::table('roles')->get();
echo "   Found " . $roles->count() . " roles:\n";
foreach ($roles as $role) {
    echo "   - {$role->name} (ID: {$role->id}, Guard: {$role->guard_name})\n";
}
echo "\n";

// Check model_has_roles table
echo "📊 Checking model_has_roles table...\n";
$modelType = User::class;
$roleAssignments = DB::table('model_has_roles')
    ->where('model_type', $modelType)
    ->get();
echo "   Found " . $roleAssignments->count() . " role assignments for model_type: {$modelType}\n";
echo "\n";

// Check a few users WITH their roles using Eloquent
echo "📊 Checking users with roles (via Eloquent ->with('roles'))...\n";
$users = User::with('roles')->take(5)->get();
echo "   Checking first 5 users:\n\n";

foreach ($users as $user) {
    echo "   User: {$user->name} {$user->last_name} (ID: {$user->id}, Email: {$user->email})\n";
    echo "      relationLoaded('roles'): " . ($user->relationLoaded('roles') ? 'YES' : 'NO') . "\n";
    echo "      \$user->roles exists: " . (isset($user->roles) ? 'YES' : 'NO') . "\n";
    echo "      \$user->roles count: " . ($user->roles ? $user->roles->count() : 'NULL/0') . "\n";
    
    if ($user->roles && $user->roles->count() > 0) {
        echo "      Roles: " . $user->roles->pluck('name')->implode(', ') . "\n";
    } else {
        echo "      ⚠️  NO ROLES ASSIGNED\n";
    }
    echo "\n";
}

// Check if role assignments exist with different model_type formats
echo "📊 Checking model_has_roles with different model_type formats...\n";
$formats = [
    'App\\Models\\User',
    'App\Models\User',
    User::class,
];

foreach ($formats as $format) {
    $count = DB::table('model_has_roles')->where('model_type', $format)->count();
    echo "   model_type = '{$format}': {$count} assignments\n";
}
echo "\n";

echo "═══════════════════════════════════════════════════════════\n";
echo "   DONE\n";
echo "═══════════════════════════════════════════════════════════\n";
