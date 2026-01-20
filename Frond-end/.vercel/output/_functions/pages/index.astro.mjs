import { e as createComponent, r as renderTemplate, v as renderHead, o as renderScript } from '../chunks/astro/server_6O5fLeT-.mjs';
import 'piccolore';
import 'clsx';
/* empty css                                     */
/* empty css                                 */
export { renderers } from '../renderers.mjs';

var __freeze = Object.freeze;
var __defProp = Object.defineProperty;
var __template = (cooked, raw) => __freeze(__defProp(cooked, "raw", { value: __freeze(raw || cooked.slice()) }));
var _a;
const $$Index = createComponent(($$result, $$props, $$slots) => {
  const pageTitle = "Acceso al Sistema - SIGE";
  return renderTemplate(_a || (_a = __template(['<html lang="es" data-astro-cid-j7pv25f6> <head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>', '</title><link rel="icon" href="/cbta71_icon.png" type="image/png">', '<link href="https://fonts.googleapis.com/css2?family=Inter:wght@100..900&display=swap" rel="stylesheet">', `</head> <body class="min-h-screen antialiased font-inter relative" data-astro-cid-j7pv25f6> <section class="min-h-screen flex items-center justify-center p-4 relative z-20" x-data="{
        mode: 'login',
        email: '',
        password: '',
        error: '',
        message: '',
        isLoading: false,

        handleLogin() {
            this.error = '';
            this.isLoading = true;

            if (!this.email || !this.password) {
                this.error = '\u26A0\uFE0F Por favor completa todos los campos.';
                this.isLoading = false;
                return;
            }

            // --- BASE DE DATOS DE USUARIOS ---
            // Se actualiz\xF3 la ruta de redirecci\xF3n para el rol 'student'
            const users = [
                { email: 'admin@uni.edu', pass: '123456', role: 'admin', redirect: '/Dashboard' },
                { email: 'estudiante@uni.edu', pass: 'alumno123', role: 'student', redirect: '/Estudiante/PortalEstudiante' }
            ];

            const userFound = users.find(u => u.email === this.email && u.pass === this.password);

            setTimeout(() => {
                this.isLoading = false;

                if (userFound) {
                    this.error = \`\u2705 Bienvenido (\${userFound.role}). Redirigiendo...\`;
                    
                    localStorage.setItem('userRole', userFound.role);
                    
                    setTimeout(() => window.location.href = userFound.redirect, 800);
                } else {
                    this.error = '\u274C Credenciales incorrectas.';
                }
            }, 900);
        },

        handleRecovery() {
            this.message = '';
            this.isLoading = true;
            if (!this.email) {
                this.message = '\u26A0\uFE0F Ingresa un correo v\xE1lido.';
                this.isLoading = false;
                return;
            }
            setTimeout(() => {
                this.isLoading = false;
                this.message = '\u{1F4E9} Se ha enviado un enlace de recuperaci\xF3n a tu correo.';
            }, 900);
        }
    }" data-astro-cid-j7pv25f6> <div class="absolute top-8 left-1/2 transform -translate-x-1/2 translate-y-3 z-30" data-astro-cid-j7pv25f6> <img src="/Logo.png" alt="Logotipo SIGE" class="w-32 h-auto select-none pointer-events-none" data-astro-cid-j7pv25f6> </div> <div class="w-full max-w-md bg-white p-0 rounded-3xl overflow-hidden shadow-xl mt-28" data-astro-cid-j7pv25f6> <header class="space-y-4 pt-14 pb-6 border-b border-gray-100 text-center" data-astro-cid-j7pv25f6> <template x-if="mode === 'login'" data-astro-cid-j7pv25f6> <h1 class="text-3xl font-black text-gray-800 uppercase tracking-widest" data-astro-cid-j7pv25f6>SIGE</h1> </template> <template x-if="mode === 'recover'" data-astro-cid-j7pv25f6> <h1 class="text-2xl font-black text-gray-800 uppercase tracking-widest px-4" data-astro-cid-j7pv25f6>Recuperar Contrase\xF1a</h1> </template> <p class="text-sm text-gray-500 font-medium mt-1" data-astro-cid-j7pv25f6>Sistema Educativo</p> </header> <div class="p-8 space-y-7" data-astro-cid-j7pv25f6> <div x-show="error" :class="error.includes('\u2705') ? 'bg-green-100 border-green-400 text-green-700' : 'bg-red-100 border-red-400 text-red-700'" class="p-3 border rounded-xl text-xs font-medium shadow-inner" x-cloak data-astro-cid-j7pv25f6> <span x-text="error" data-astro-cid-j7pv25f6></span> </div> <div x-show="message" :class="message.includes('\u{1F4E9}') ? 'bg-green-100 border-green-400 text-green-700' : 'bg-red-100 border-red-400 text-red-700'" class="p-3 border rounded-xl text-xs font-medium shadow-inner" x-cloak data-astro-cid-j7pv25f6> <span x-text="message" data-astro-cid-j7pv25f6></span> </div> <form class="space-y-6" x-show="mode === 'login'" @submit.prevent="handleLogin" data-astro-cid-j7pv25f6> <div class="flex items-center rounded-xl p-3 input-inset-shadow" data-astro-cid-j7pv25f6> <input type="email" x-model="email" placeholder="Correo Electr\xF3nico" class="w-full bg-transparent placeholder-gray-500 text-sm border-none focus:ring-0" data-astro-cid-j7pv25f6> </div> <div class="flex items-center rounded-xl p-3 input-inset-shadow" data-astro-cid-j7pv25f6> <input type="password" x-model="password" placeholder="Contrase\xF1a" class="w-full bg-transparent placeholder-gray-500 text-sm border-none focus:ring-0" data-astro-cid-j7pv25f6> </div> <button type="submit" :disabled="isLoading" class="w-full py-3 px-4 mt-6 rounded-full shadow-xl text-base font-bold text-white bg-green-600 uppercase btn-hover-green disabled:opacity-50" data-astro-cid-j7pv25f6> <span x-text="isLoading ? 'Cargando...' : 'Entrar'" data-astro-cid-j7pv25f6></span> </button> <div class="text-center mt-4 text-xs space-y-2" data-astro-cid-j7pv25f6> <button type="button" @click="mode = 'recover'; error = ''; message = '';" class="text-sm font-medium text-blue-600 hover:text-blue-800 transition-colors" data-astro-cid-j7pv25f6>
\xBFOlvidaste tu contrase\xF1a?
</button> <p class="text-gray-400 italic" data-astro-cid-j7pv25f6>Prueba con: estudiante@uni.edu / alumno123</p> </div> </form> <form class="space-y-6" x-show="mode === 'recover'" @submit.prevent="handleRecovery" x-cloak data-astro-cid-j7pv25f6> <div class="flex items-center rounded-xl p-3 input-inset-shadow" data-astro-cid-j7pv25f6> <input type="email" x-model="email" placeholder="Ingresa tu correo" class="w-full bg-transparent placeholder-gray-500 text-sm border-none focus:ring-0" data-astro-cid-j7pv25f6> </div> <button type="submit" :disabled="isLoading" class="w-full py-3 px-4 rounded-full shadow-xl text-base font-bold text-white bg-green-600 uppercase btn-hover-green disabled:opacity-50" data-astro-cid-j7pv25f6> <span x-text="isLoading ? 'Enviando...' : 'Enviar Enlace'" data-astro-cid-j7pv25f6></span> </button> <div class="text-center mt-4" data-astro-cid-j7pv25f6> <button type="button" @click="mode = 'login'; message = '';" class="text-sm font-medium text-blue-600 hover:text-blue-800 transition-colors" data-astro-cid-j7pv25f6>
\u2190 Volver al inicio de sesi\xF3n
</button> </div> </form> </div> <footer class="text-center p-3 bg-gray-100 text-xs text-gray-500 border-t border-gray-200" data-astro-cid-j7pv25f6> <p data-astro-cid-j7pv25f6>2026 \xA9 SIGE</p> </footer> </div> </section> <script src="https://cdn.jsdelivr.net/npm/alpinejs@3.x.x/dist/cdn.min.js" defer><\/script> </body> </html>`], ['<html lang="es" data-astro-cid-j7pv25f6> <head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>', '</title><link rel="icon" href="/cbta71_icon.png" type="image/png">', '<link href="https://fonts.googleapis.com/css2?family=Inter:wght@100..900&display=swap" rel="stylesheet">', `</head> <body class="min-h-screen antialiased font-inter relative" data-astro-cid-j7pv25f6> <section class="min-h-screen flex items-center justify-center p-4 relative z-20" x-data="{
        mode: 'login',
        email: '',
        password: '',
        error: '',
        message: '',
        isLoading: false,

        handleLogin() {
            this.error = '';
            this.isLoading = true;

            if (!this.email || !this.password) {
                this.error = '\u26A0\uFE0F Por favor completa todos los campos.';
                this.isLoading = false;
                return;
            }

            // --- BASE DE DATOS DE USUARIOS ---
            // Se actualiz\xF3 la ruta de redirecci\xF3n para el rol 'student'
            const users = [
                { email: 'admin@uni.edu', pass: '123456', role: 'admin', redirect: '/Dashboard' },
                { email: 'estudiante@uni.edu', pass: 'alumno123', role: 'student', redirect: '/Estudiante/PortalEstudiante' }
            ];

            const userFound = users.find(u => u.email === this.email && u.pass === this.password);

            setTimeout(() => {
                this.isLoading = false;

                if (userFound) {
                    this.error = \\\`\u2705 Bienvenido (\\\${userFound.role}). Redirigiendo...\\\`;
                    
                    localStorage.setItem('userRole', userFound.role);
                    
                    setTimeout(() => window.location.href = userFound.redirect, 800);
                } else {
                    this.error = '\u274C Credenciales incorrectas.';
                }
            }, 900);
        },

        handleRecovery() {
            this.message = '';
            this.isLoading = true;
            if (!this.email) {
                this.message = '\u26A0\uFE0F Ingresa un correo v\xE1lido.';
                this.isLoading = false;
                return;
            }
            setTimeout(() => {
                this.isLoading = false;
                this.message = '\u{1F4E9} Se ha enviado un enlace de recuperaci\xF3n a tu correo.';
            }, 900);
        }
    }" data-astro-cid-j7pv25f6> <div class="absolute top-8 left-1/2 transform -translate-x-1/2 translate-y-3 z-30" data-astro-cid-j7pv25f6> <img src="/Logo.png" alt="Logotipo SIGE" class="w-32 h-auto select-none pointer-events-none" data-astro-cid-j7pv25f6> </div> <div class="w-full max-w-md bg-white p-0 rounded-3xl overflow-hidden shadow-xl mt-28" data-astro-cid-j7pv25f6> <header class="space-y-4 pt-14 pb-6 border-b border-gray-100 text-center" data-astro-cid-j7pv25f6> <template x-if="mode === 'login'" data-astro-cid-j7pv25f6> <h1 class="text-3xl font-black text-gray-800 uppercase tracking-widest" data-astro-cid-j7pv25f6>SIGE</h1> </template> <template x-if="mode === 'recover'" data-astro-cid-j7pv25f6> <h1 class="text-2xl font-black text-gray-800 uppercase tracking-widest px-4" data-astro-cid-j7pv25f6>Recuperar Contrase\xF1a</h1> </template> <p class="text-sm text-gray-500 font-medium mt-1" data-astro-cid-j7pv25f6>Sistema Educativo</p> </header> <div class="p-8 space-y-7" data-astro-cid-j7pv25f6> <div x-show="error" :class="error.includes('\u2705') ? 'bg-green-100 border-green-400 text-green-700' : 'bg-red-100 border-red-400 text-red-700'" class="p-3 border rounded-xl text-xs font-medium shadow-inner" x-cloak data-astro-cid-j7pv25f6> <span x-text="error" data-astro-cid-j7pv25f6></span> </div> <div x-show="message" :class="message.includes('\u{1F4E9}') ? 'bg-green-100 border-green-400 text-green-700' : 'bg-red-100 border-red-400 text-red-700'" class="p-3 border rounded-xl text-xs font-medium shadow-inner" x-cloak data-astro-cid-j7pv25f6> <span x-text="message" data-astro-cid-j7pv25f6></span> </div> <form class="space-y-6" x-show="mode === 'login'" @submit.prevent="handleLogin" data-astro-cid-j7pv25f6> <div class="flex items-center rounded-xl p-3 input-inset-shadow" data-astro-cid-j7pv25f6> <input type="email" x-model="email" placeholder="Correo Electr\xF3nico" class="w-full bg-transparent placeholder-gray-500 text-sm border-none focus:ring-0" data-astro-cid-j7pv25f6> </div> <div class="flex items-center rounded-xl p-3 input-inset-shadow" data-astro-cid-j7pv25f6> <input type="password" x-model="password" placeholder="Contrase\xF1a" class="w-full bg-transparent placeholder-gray-500 text-sm border-none focus:ring-0" data-astro-cid-j7pv25f6> </div> <button type="submit" :disabled="isLoading" class="w-full py-3 px-4 mt-6 rounded-full shadow-xl text-base font-bold text-white bg-green-600 uppercase btn-hover-green disabled:opacity-50" data-astro-cid-j7pv25f6> <span x-text="isLoading ? 'Cargando...' : 'Entrar'" data-astro-cid-j7pv25f6></span> </button> <div class="text-center mt-4 text-xs space-y-2" data-astro-cid-j7pv25f6> <button type="button" @click="mode = 'recover'; error = ''; message = '';" class="text-sm font-medium text-blue-600 hover:text-blue-800 transition-colors" data-astro-cid-j7pv25f6>
\xBFOlvidaste tu contrase\xF1a?
</button> <p class="text-gray-400 italic" data-astro-cid-j7pv25f6>Prueba con: estudiante@uni.edu / alumno123</p> </div> </form> <form class="space-y-6" x-show="mode === 'recover'" @submit.prevent="handleRecovery" x-cloak data-astro-cid-j7pv25f6> <div class="flex items-center rounded-xl p-3 input-inset-shadow" data-astro-cid-j7pv25f6> <input type="email" x-model="email" placeholder="Ingresa tu correo" class="w-full bg-transparent placeholder-gray-500 text-sm border-none focus:ring-0" data-astro-cid-j7pv25f6> </div> <button type="submit" :disabled="isLoading" class="w-full py-3 px-4 rounded-full shadow-xl text-base font-bold text-white bg-green-600 uppercase btn-hover-green disabled:opacity-50" data-astro-cid-j7pv25f6> <span x-text="isLoading ? 'Enviando...' : 'Enviar Enlace'" data-astro-cid-j7pv25f6></span> </button> <div class="text-center mt-4" data-astro-cid-j7pv25f6> <button type="button" @click="mode = 'login'; message = '';" class="text-sm font-medium text-blue-600 hover:text-blue-800 transition-colors" data-astro-cid-j7pv25f6>
\u2190 Volver al inicio de sesi\xF3n
</button> </div> </form> </div> <footer class="text-center p-3 bg-gray-100 text-xs text-gray-500 border-t border-gray-200" data-astro-cid-j7pv25f6> <p data-astro-cid-j7pv25f6>2026 \xA9 SIGE</p> </footer> </div> </section> <script src="https://cdn.jsdelivr.net/npm/alpinejs@3.x.x/dist/cdn.min.js" defer><\/script> </body> </html>`])), pageTitle, renderScript($$result, "C:/Users/sarah/Documents/GitHub/CBTA/Frond-end/src/pages/index.astro?astro&type=script&index=0&lang.ts"), renderHead());
}, "C:/Users/sarah/Documents/GitHub/CBTA/Frond-end/src/pages/index.astro", void 0);

const $$file = "C:/Users/sarah/Documents/GitHub/CBTA/Frond-end/src/pages/index.astro";
const $$url = "";

const _page = /*#__PURE__*/Object.freeze(/*#__PURE__*/Object.defineProperty({
    __proto__: null,
    default: $$Index,
    file: $$file,
    url: $$url
}, Symbol.toStringTag, { value: 'Module' }));

const page = () => _page;

export { page };
