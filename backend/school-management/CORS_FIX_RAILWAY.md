# ✅ SOLUCIÓN CORS - Frontend + Railway Backend

## 🔴 Problema
```
Access-Control-Allow-Origin header missing
Failed to fetch from API
```

## ✅ Solución: Configurar Variable de Entorno en Railway

### 1️⃣ Ve a [Railway Dashboard](https://railway.app)

### 2️⃣ Selecciona tu proyecto → Backend (PHP/Laravel)

### 3️⃣ Ve a **"Variables"** en el panel

### 4️⃣ Agrega esta variable de entorno:

```
FRONTEND_URL=https://cbta-eight.vercel.app
```

### 5️⃣ Presiona **"Save"** y espera a que se redeploy automáticamente

### 6️⃣ Una vez desplegado, prueba nuevamente en el frontend

---

## 🔍 Verificar que Funcionó

1. Abre **DevTools del navegador** (F12)
2. Ve a la pestaña **Console**
3. Deberías ver uno de estos:
   - ✅ **"✅ Usuarios cargados"** - significa que CORS funcionó
   - ❌ **"ERROR CORS"** - significa que necesitas revisar la variable

---

## 📝 Cambios Realizados en el Código

✅ Actualizado `config/cors.php`:
- Ahora usa la variable `FRONTEND_URL` de Railway
- Incluye patrones regex para Vercel preview deployments
- Mantiene soporte local para desarrollo

---

## ⚡ Si prefieres hacerlo por Terminal

Si tienes Railway CLI instalada:

```bash
# Navega a la carpeta del backend
cd backend/school-management

# Conecta a Railway
railway link

# Configura la variable
railway variables set FRONTEND_URL=https://cbta-eight.vercel.app

# Despliega
railway deploy
```

---

## 🆘 Si sigue sin funcionar

1. Verifica que `APP_ENV=production` en Railway
2. Limpia el caché del navegador (Ctrl+Shift+Delete)
3. Intenta desde una pestaña privada/incógnito
4. Revisa los logs de Railway: `railway logs`
