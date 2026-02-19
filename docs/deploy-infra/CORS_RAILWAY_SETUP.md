# 🔧 Configurar CORS en Railway - URGENTE

## 🔴 Error Actual
```
Access to fetch at 'https://nginx-production-728f.up.railway.app/api/v1/login' 
from origin 'https://cbta-eight.vercel.app' has been blocked by CORS policy
```

## ✅ Solución: 3 Pasos

### 1️⃣ Ir a Railway Dashboard

1. Abre **https://railway.app**
2. Inicia sesión con tu cuenta
3. Selecciona tu proyecto (el que tiene el backend PHP/Laravel)

---

### 2️⃣ Configurar Variable de Entorno

1. Haz clic en el **servicio del backend** (el que tiene PHP)
2. Ve a la pestaña **"Variables"**
3. Busca si ya existe `FRONTEND_URL`
   - ✅ **Si existe:** Cambia su valor a `https://cbta-eight.vercel.app`
   - ➕ **Si NO existe:** Haz clic en **"New Variable"**

4. Agrega:
   ```
   Variable name: FRONTEND_URL
   Variable value: https://cbta-eight.vercel.app
   ```

5. Haz clic en **"Add"** o **"Save"**

---

### 3️⃣ Hacer Redeploy (IMPORTANTE)

Railway NO aplica cambios automáticamente cuando cambias variables.

**Opción A - Desde el Dashboard:**
1. Ve a la pestaña **"Deployments"**
2. Haz clic en los **3 puntos (⋮)** del último deployment
3. Selecciona **"Redeploy"**
4. Espera 2-3 minutos a que termine

**Opción B - Push desde Git:**
```bash
cd c:\Users\sarah\Documents\GitHub\CBTA
git add -A
git commit -m "CORS config"
git push
```
Railway detectará el push y hará redeploy automáticamente.

---

## 🧪 Verificar que Funcionó

1. Abre **https://cbta-eight.vercel.app**
2. Abre DevTools (F12) → Console
3. Intenta iniciar sesión
4. Deberías ver:
   ```
   ✅ Login exitoso
   ✅ Token guardado
   ```

En lugar de:
```
❌ CORS policy error
```

---

## 📋 Checklist

- [ ] Railway → Backend service → Variables
- [ ] Variable `FRONTEND_URL` = `https://cbta-eight.vercel.app`
- [ ] Guardado
- [ ] Redeploy completado
- [ ] Esperar 2-3 minutos
- [ ] Probar login en Vercel

---

## 🆘 Si Sigue Sin Funcionar

### Verificar que la variable se guardó:
1. Railway → Backend Service → Variables
2. Debes ver:
   ```
   FRONTEND_URL = https://cbta-eight.vercel.app
   ```

### Ver logs del backend:
1. Railway → Backend Service → Deployments
2. Click en el último deployment
3. Ve a **"View Logs"**
4. Busca líneas que mencionen CORS

### Verificar que el deployment terminó:
1. Railway → Deployments
2. El último debe tener un **✅ verde** (Success)
3. No debe estar en proceso (🔄 azul)

---

## 💡 Nota Importante

El archivo `config/cors.php` YA está configurado correctamente en el código.
Solo falta agregar la variable de entorno en Railway.

Una vez que agregues la variable y hagas redeploy, el CORS funcionará inmediatamente.
