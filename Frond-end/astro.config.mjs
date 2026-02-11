// @ts-check
import { defineConfig } from 'astro/config';
import tailwindcss from '@tailwindcss/vite';
import react from '@astrojs/react';
import alpinejs from '@astrojs/alpinejs';

// https://astro.build/config
// REBUILD TIMESTAMP: 2026-02-10T20:54 - Force Vercel clean build v2
export default defineConfig({
  integrations: [react(), alpinejs()],

  vite: {
    plugins: [tailwindcss()],
    build: {
      minify: 'esbuild', // Use esbuild minification (default)
      sourcemap: false,
      rollupOptions: {
        output: {
          manualChunks: undefined // Disable code splitting to avoid cache issues
        }
      }
    }
  },

  output: 'static'
});