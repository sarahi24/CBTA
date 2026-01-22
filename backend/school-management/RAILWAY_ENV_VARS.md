# Variables de Entorno para Railway

Para que el backend funcione correctamente en Railway, necesitas configurar estas variables de entorno:

## Variables Requeridas

```env
# Frontend URL (Vercel)
FRONTEND_URL=https://cbta-eight.vercel.app

# Sanctum Stateful Domains
SANCTUM_STATEFUL_DOMAINS=cbta-eight.vercel.app,*.vercel.app

# Session Domain (opcional, para cookies)
SESSION_DOMAIN=.vercel.app

# App URL (Railway)
APP_URL=https://nginx-production-728f.up.railway.app
```

## Cómo Configurar en Railway

1. Ve a tu proyecto en Railway
2. Click en el servicio backend
3. Ve a la pestaña "Variables"
4. Agrega las variables listadas arriba
5. Click en "Deploy" para aplicar los cambios

## Verificación

Después de configurar, verifica que:
- El endpoint `/api/v1/login` responde con headers CORS
- Puedes hacer login desde Vercel sin errores de CORS
