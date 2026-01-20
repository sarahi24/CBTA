# CBTA 71 - Sistema Administrativo

## Estructura del Proyecto

```
CBTA/
├── Frond-end/          # Aplicación Astro (Frontend)
│   ├── src/
│   │   ├── pages/      # Páginas de la aplicación
│   │   ├── layouts/
│   │   └── components/
│   ├── package.json
│   └── astro.config.mjs
└── backend/            # API Laravel (Backend)
    └── school-management/
```

## Configuración de Vercel

**Root Directory:** `Frond-end`
**Framework:** Astro
**Build Command:** `npm run build`
**Output Directory:** `dist`
**Install Command:** `npm install`

## Desarrollo Local

```bash
cd Frond-end
npm install
npm run dev
```

## Deploy

El proyecto se despliega automáticamente en Vercel cuando se hace push a main.

Asegúrate de configurar el Root Directory en Vercel Dashboard:
Settings → General → Root Directory → `Frond-end`
