// @ts-check
import { defineConfig } from 'astro/config';
import tailwindcss from '@tailwindcss/vite';
import react from '@astrojs/react';
import alpinejs from '@astrojs/alpinejs';

// https://astro.build/config
// REBUILD TIMESTAMP: 2026-02-10 - Force Vercel clean build
export default defineConfig({
  integrations: [react(), alpinejs()],

  vite: {
    plugins: [tailwindcss()],
    build: {
      minify: 'terser', // Force terser minification
      sourcemap: false
    }
  },

  output: 'static'
});