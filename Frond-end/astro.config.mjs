// @ts-check
import { defineConfig } from 'astro/config';
import tailwindcss from '@tailwindcss/vite';
import react from '@astrojs/react';
import alpinejs from '@astrojs/alpinejs';
import vercel from '@astrojs/vercel/static';

// https://astro.build/config
export default defineConfig({
  integrations: [react(), alpinejs()],

  vite: {
    plugins: [tailwindcss()]
  },

  output: 'static',
  adapter: vercel()
});