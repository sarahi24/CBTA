# 👥 Seeder de Usuarios de Prueba

Este seeder crea automáticamente usuarios de prueba para desarrollo y testing.

## 🚀 Cómo ejecutar el seeder

### Opción 1: Ejecutar todos los seeders (recomendado)
```bash
php artisan db:seed
```

### Opción 2: Ejecutar solo el seeder de usuarios
```bash
php artisan db:seed --class=UsersSeeder
```

### Opción 3: Refrescar la base de datos y ejecutar seeders
```bash
php artisan migrate:fresh --seed
```

## 👤 Usuarios creados

### Administradores
| Nombre | Email | Password | Rol |
|--------|-------|----------|-----|
| Admin Principal | `admin@uni.edu` | `password123` | admin |
| Super Admin | `superadmin@cbta71.edu.mx` | `admin123` | admin |

### Personal Financiero (Caja)
| Nombre | Email | Password | Rol |
|--------|-------|----------|-----|
| María González | `caja@cbta71.edu.mx` | `caja123` | financial staff |
| Juan Pérez | `finanzas@cbta71.edu.mx` | `finanzas123` | financial staff |

### Estudiantes
| Nombre | Email | Password | Rol |
|--------|-------|----------|-----|
| Carlos Ramírez | `carlos.ramirez@estudiante.cbta71.edu.mx` | `student123` | student |
| Ana Torres | `ana.torres@estudiante.cbta71.edu.mx` | `student123` | student |
| Luis Martínez | `luis.martinez@estudiante.cbta71.edu.mx` | `student123` | student |

## 🔐 Credenciales para Testing Rápido

### Login como Admin:
- **Email:** `admin@uni.edu`
- **Password:** `password123`

### Login como Staff:
- **Email:** `caja@cbta71.edu.mx`
- **Password:** `caja123`

### Login como Estudiante:
- **Email:** `carlos.ramirez@estudiante.cbta71.edu.mx`
- **Password:** `student123`

## ⚙️ Configuración en Producción

### Railway

1. Conéctate por SSH o usa el CLI:
```bash
railway run php artisan db:seed
```

2. O desde el dashboard:
- Variables → Run Command → `php artisan db:seed`

### Importante ⚠️

**NO ejecutes este seeder en producción** con datos reales. Las contraseñas son débiles y conocidas públicamente.

Para producción:
1. Crea usuarios manualmente con contraseñas seguras
2. O modifica el seeder con contraseñas desde variables de entorno
3. Ejecuta solo una vez y luego elimina el seeder

## 🛠️ Personalización

Para agregar más usuarios, edita el archivo:
```
database/seeders/UsersSeeder.php
```

### Ejemplo de agregar un nuevo admin:
```php
[
    'name' => 'Nuevo Admin',
    'email' => 'nuevo@cbta71.edu.mx',
    'password' => 'password_seguro',
    'role' => 'admin',
],
```

## 🔄 Resetear usuarios

Si necesitas volver a crear los usuarios:

```bash
# Eliminar solo usuarios (cuidado en producción)
php artisan tinker
>>> User::truncate();
>>> exit

# Ejecutar el seeder de nuevo
php artisan db:seed --class=UsersSeeder
```

## ✅ Verificar usuarios creados

```bash
php artisan tinker
>>> User::with('roles')->get(['id', 'name', 'email'])
```

## 🐛 Troubleshooting

### Error: "Role does not exist"
```bash
php artisan permission:cache-reset
php artisan db:seed --class=UsersSeeder
```

### Error: "Duplicate entry for email"
Los usuarios ya existen. Usa `firstOrCreate` o elimina los usuarios existentes.

### Error: "Class 'Spatie\Permission\Models\Role' not found"
```bash
composer require spatie/laravel-permission
php artisan vendor:publish --provider="Spatie\Permission\PermissionServiceProvider"
php artisan migrate
```
