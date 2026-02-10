# 🔍 SCRIPT DE DIAGNÓSTICO - localStorage

# Este script te ayuda a verificar qué datos hay en localStorage
# Ejecútalo después de estar en la página del perfil

Write-Host "🔍 Diagnóstico de localStorage y Token" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Abre la página del perfil y ejecuta en DevTools (F12 > Console):" -ForegroundColor Yellow
Write-Host ""

$commands = @"
// 1. Ver si hay token
console.log('🔐 Token en localStorage:', localStorage.getItem('token') ? '✅ Presente' : '❌ No encontrado');

// 2. Ver datos de usuario en localStorage
const userData = localStorage.getItem('user_data');
console.log('📦 User data en localStorage:', userData ? '✅ Presente' : '❌ No encontrado');

// 3. Si existe, parsearlo y mostrarlo
if (userData) {
    try {
        const user = JSON.parse(userData);
        console.table({
            'ID': user.id,
            'Nombre': user.name,
            'Apellido': user.last_name,
            'Email': user.email,
            'Roles': user.roles ? user.roles.length : 0,
            'Permisos': user.permissions ? user.permissions.length : 0
        });
    } catch(e) {
        console.error('❌ Error parsing user data:', e);
    }
}

// 4. Ver todo el localStorage
console.log('📋 Todo en localStorage:');
console.table(localStorage);

// 5. Copiar para debugging (JSON válido)
if (userData) {
    console.log('📄 JSON de usuario (copia para debugging):');
    console.log(userData);
}
"@

Write-Host $commands -ForegroundColor Gray
Write-Host ""

Write-Host "📌 Si NO ves datos:" -ForegroundColor Yellow
Write-Host "   1. Verifica que estés AUTENTICADO" -ForegroundColor White
Write-Host "   2. Ve a /login y inicia sesión" -ForegroundColor White
Write-Host "   3. Después de login, localStorage debe tener 'token'" -ForegroundColor White
Write-Host "   4. Vuelve al perfil para que se carguen los datos" -ForegroundColor White
Write-Host ""

Write-Host "✅ Si SÍ ves datos:" -ForegroundColor Green
Write-Host "   1. user_data debe tener: id, name, last_name, email" -ForegroundColor White
Write-Host "   2. Si faltan campos, el API puede retornar datos incompletos" -ForegroundColor White
Write-Host "   3. Ejecuta el test con token para verificar API" -ForegroundColor White
Write-Host ""

Write-Host "🧪 Para probar API completo:" -ForegroundColor Cyan
Write-Host "   .\test-perfil-api.ps1 'tu_token_aqui'" -ForegroundColor Gray
Write-Host ""

Write-Host "💡 Pasos para solucionar:" -ForegroundColor Magenta
Write-Host "   1. Abre DevTools (F12)" -ForegroundColor White
Write-Host "   2. Console tab" -ForegroundColor White
Write-Host "   3. Copia los comandos de arriba" -ForegroundColor White
Write-Host "   4. Pega en la consola y presiona Enter" -ForegroundColor White
Write-Host "   5. Revisa la salida" -ForegroundColor White
