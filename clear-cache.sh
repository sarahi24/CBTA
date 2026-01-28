#!/bin/bash

# Script para limpiar cache en Railway
# Ejecutar en el directorio backend/school-management

echo "🔄 Limpiando cache de Laravel..."

php artisan cache:clear && \
php artisan config:clear && \
php artisan route:clear && \
php artisan view:clear && \
php artisan config:cache && \
php artisan route:cache

echo "✅ Cache limpiado exitosamente!"
echo ""
echo "Para ejecutar esto en Railway:"
echo "1. Ve a https://railway.app"
echo "2. Abre tu proyecto CBTA"
echo "3. En la pestaña de tu app (nginx-production), ve a 'Logs'"
echo "4. Abre una terminal SSH o conecta por CLI"
echo "5. Ejecuta: cd backend/school-management && php artisan cache:clear-all"
