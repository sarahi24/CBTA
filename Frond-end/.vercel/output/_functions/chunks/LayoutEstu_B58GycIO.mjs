import { e as createComponent, f as createAstro, q as defineStyleVars, r as renderTemplate, p as renderSlot, h as addAttribute, v as renderHead } from './astro/server_6O5fLeT-.mjs';
/* empty css                             */
/* empty css                           */
import 'clsx';

var __freeze = Object.freeze;
var __defProp = Object.defineProperty;
var __template = (cooked, raw) => __freeze(__defProp(cooked, "raw", { value: __freeze(raw || cooked.slice()) }));
var _a;
const $$Astro = createAstro();
const $$LayoutEstu = createComponent(($$result, $$props, $$slots) => {
  const Astro2 = $$result.createAstro($$Astro, $$props, $$slots);
  Astro2.self = $$LayoutEstu;
  const { title } = Astro2.props;
  const PRIMARY_COLOR = "#2e594d";
  const ACCENT_COLOR = "#86efad";
  const BACKGROUND_COLOR = "#d9dde2";
  const TEXT_COLOR_DARK = "#374151";
  const $$definedVars = defineStyleVars([{ PRIMARY_COLOR, ACCENT_COLOR, BACKGROUND_COLOR, TEXT_COLOR_DARK }]);
  return renderTemplate(_a || (_a = __template(['<html lang="es" data-astro-cid-iysahtsw', '> <head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>', ' | Estudiante CBTA 71</title><link rel="icon" href="/Logo.png" type="image/png"><link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700;800&display=swap" rel="stylesheet">', '</head> <body class="flex min-h-screen antialiased relative" data-astro-cid-iysahtsw', '> <nav id="sidebar-menu" class="bg-[#2e594d] text-white flex flex-col p-5 shadow-2xl z-50 overflow-y-auto\n        fixed inset-0 w-full max-w-[250px] h-full transition-transform-fast sidebar-closed\n        md:fixed md:top-0 md:flex md:h-screen md:w-[250px] md:shadow-lg md:rounded-r-xl" data-astro-cid-iysahtsw', '> <button id="close-sidebar-button" class="md:hidden absolute top-3 right-3 p-2 rounded-full bg-white/20 text-white" data-astro-cid-iysahtsw', '> <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" data-astro-cid-iysahtsw', '><path d="M18 6l-12 12M6 6l12 12" data-astro-cid-iysahtsw', '></path></svg> </button> <div class="flex items-center gap-4 mb-10 pt-3 border-b border-white/10 pb-4" data-astro-cid-iysahtsw', '> <div class="h-10 w-10" data-astro-cid-iysahtsw', '> <img src="/Logo.png" alt="Logo" class="w-full h-full object-contain" data-astro-cid-iysahtsw', "> </div> <div data-astro-cid-iysahtsw", '> <h1 class="text-xl font-extrabold tracking-wide" data-astro-cid-iysahtsw', '>CBTA 71</h1> <p class="text-[9px] opacity-80 uppercase font-bold" data-astro-cid-iysahtsw', '>Portal Estudiante</p> </div> </div> <div class="flex-grow overflow-y-auto pr-2" data-astro-cid-iysahtsw', '> <ul id="main-navigation" class="space-y-2" data-astro-cid-iysahtsw', "> <li data-astro-cid-iysahtsw", '> <a href="/Estudiante/PortalEstudiante" data-path="/Estudiante/PortalEstudiante" class="nav-link nav-inactive flex items-center gap-4 py-3 px-4 rounded-lg transition-all" data-astro-cid-iysahtsw', '> <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" data-astro-cid-iysahtsw', '><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" data-astro-cid-iysahtsw', "></path></svg>\nDashboard\n</a> </li> <li data-astro-cid-iysahtsw", '> <a href="/Estudiante/Tarjetas" data-path="/Estudiante/Tarjetas" class="nav-link nav-inactive flex items-center gap-4 py-3 px-4 rounded-lg transition-all" data-astro-cid-iysahtsw', '> <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" data-astro-cid-iysahtsw', '><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 10h18M7 15h1m4 0h1m-7 4h12a2 2 0 002-2V7a2 2 0 00-2-2H6a2 2 0 00-2 2v10a2 2 0 002 2z" data-astro-cid-iysahtsw', "></path></svg>\nMis Tarjetas\n</a> </li> <li data-astro-cid-iysahtsw", '> <a href="/Estudiante/Adeudos" data-path="/Estudiante/Adeudos" class="nav-link nav-inactive flex items-center gap-4 py-3 px-4 rounded-lg transition-all" data-astro-cid-iysahtsw', '> <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" data-astro-cid-iysahtsw', '><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" data-astro-cid-iysahtsw', "></path></svg>\nPagos Pendientes\n</a> </li> <li data-astro-cid-iysahtsw", '> <a href="/Estudiante/Historial" data-path="/Estudiante/Historial" class="nav-link nav-inactive flex items-center gap-4 py-3 px-4 rounded-lg transition-all" data-astro-cid-iysahtsw', '> <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" data-astro-cid-iysahtsw', '><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" data-astro-cid-iysahtsw', '></path></svg>\nHistorial\n</a> </li> </ul> </div> <div class="mt-auto pt-4 border-t border-white/10" data-astro-cid-iysahtsw', '> <a href="/logout" class="flex items-center gap-4 py-3 px-4 rounded-lg text-white hover:bg-white/10 transition-colors font-bold" data-astro-cid-iysahtsw', '> <div class="logout-icon-circle" data-astro-cid-iysahtsw', '> <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" data-astro-cid-iysahtsw', '><path d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" data-astro-cid-iysahtsw', '></path></svg> </div>\nSalir\n</a> </div> </nav> <main class="flex-1 p-4 md:p-8 md:ml-[250px] relative" data-astro-cid-iysahtsw', '> <button id="open-sidebar-button" class="md:hidden fixed top-4 left-4 p-3 rounded-xl bg-[#2e594d] text-white shadow-xl z-40" data-astro-cid-iysahtsw', '> <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" data-astro-cid-iysahtsw', '><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" data-astro-cid-iysahtsw', '></path></svg> </button> <div class="h-16 md:hidden" data-astro-cid-iysahtsw', '></div> <div class="bg-white p-6 md:p-10 rounded-[2rem] shadow-2xl content-fade-in min-h-[calc(100vh-4rem)]" data-astro-cid-iysahtsw', "> ", ` </div> </main> <script>
        const sidebar = document.getElementById('sidebar-menu');
        const openButton = document.getElementById('open-sidebar-button');
        const closeButton = document.getElementById('close-sidebar-button');
        const navLinks = document.querySelectorAll('.nav-link');
        const activeClass = 'nav-active';
        const inactiveClass = 'nav-inactive';

        function setActiveLink() {
            // Normalizar la ruta actual quitando la barra final
            let currentPath = window.location.pathname.replace(/\\/$/, "");
            
            navLinks.forEach(link => {
                const linkPath = link.getAttribute('data-path').replace(/\\/$/, "");
                link.classList.remove(activeClass, inactiveClass);
                
                if (linkPath === currentPath) {
                    link.classList.add(activeClass);
                } else {
                    link.classList.add(inactiveClass);
                }
            });
        }

        function openSidebar() {
            sidebar.classList.remove('sidebar-closed', 'hidden');
            openButton.style.display = 'none';
            document.body.style.overflow = 'hidden';
            if (window.innerWidth < 768) sidebar.classList.add('fixed', 'inset-0');
        }

        function closeSidebar() {
            sidebar.classList.add('sidebar-closed');
            setTimeout(() => {
                if (window.innerWidth < 768) {
                    sidebar.classList.add('hidden');
                    openButton.style.display = 'block';
                }
                document.body.style.overflow = '';
            }, 300);
        }

        openButton?.addEventListener('click', openSidebar);
        closeButton?.addEventListener('click', closeSidebar);
        
        navLinks.forEach(link => link.addEventListener('click', () => { 
            if (window.innerWidth < 768) closeSidebar(); 
        }));

        const handleResize = () => {
            if (window.innerWidth >= 768) {
                sidebar.classList.remove('hidden', 'sidebar-closed', 'inset-0');
                openButton.style.display = 'none';
                document.body.style.overflow = '';
            } else if (sidebar.classList.contains('sidebar-closed')) {
                sidebar.classList.add('hidden');
                openButton.style.display = 'block';
            }
        };

        window.addEventListener('resize', handleResize);
        window.addEventListener('load', () => { 
            handleResize(); 
            setActiveLink(); 
        });
        
        // Importante para Astro con transiciones de p\xE1gina
        document.addEventListener("astro:after-swap", setActiveLink);
    <\/script> </body> </html>`], ['<html lang="es" data-astro-cid-iysahtsw', '> <head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>', ' | Estudiante CBTA 71</title><link rel="icon" href="/Logo.png" type="image/png"><link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700;800&display=swap" rel="stylesheet">', '</head> <body class="flex min-h-screen antialiased relative" data-astro-cid-iysahtsw', '> <nav id="sidebar-menu" class="bg-[#2e594d] text-white flex flex-col p-5 shadow-2xl z-50 overflow-y-auto\n        fixed inset-0 w-full max-w-[250px] h-full transition-transform-fast sidebar-closed\n        md:fixed md:top-0 md:flex md:h-screen md:w-[250px] md:shadow-lg md:rounded-r-xl" data-astro-cid-iysahtsw', '> <button id="close-sidebar-button" class="md:hidden absolute top-3 right-3 p-2 rounded-full bg-white/20 text-white" data-astro-cid-iysahtsw', '> <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" data-astro-cid-iysahtsw', '><path d="M18 6l-12 12M6 6l12 12" data-astro-cid-iysahtsw', '></path></svg> </button> <div class="flex items-center gap-4 mb-10 pt-3 border-b border-white/10 pb-4" data-astro-cid-iysahtsw', '> <div class="h-10 w-10" data-astro-cid-iysahtsw', '> <img src="/Logo.png" alt="Logo" class="w-full h-full object-contain" data-astro-cid-iysahtsw', "> </div> <div data-astro-cid-iysahtsw", '> <h1 class="text-xl font-extrabold tracking-wide" data-astro-cid-iysahtsw', '>CBTA 71</h1> <p class="text-[9px] opacity-80 uppercase font-bold" data-astro-cid-iysahtsw', '>Portal Estudiante</p> </div> </div> <div class="flex-grow overflow-y-auto pr-2" data-astro-cid-iysahtsw', '> <ul id="main-navigation" class="space-y-2" data-astro-cid-iysahtsw', "> <li data-astro-cid-iysahtsw", '> <a href="/Estudiante/PortalEstudiante" data-path="/Estudiante/PortalEstudiante" class="nav-link nav-inactive flex items-center gap-4 py-3 px-4 rounded-lg transition-all" data-astro-cid-iysahtsw', '> <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" data-astro-cid-iysahtsw', '><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" data-astro-cid-iysahtsw', "></path></svg>\nDashboard\n</a> </li> <li data-astro-cid-iysahtsw", '> <a href="/Estudiante/Tarjetas" data-path="/Estudiante/Tarjetas" class="nav-link nav-inactive flex items-center gap-4 py-3 px-4 rounded-lg transition-all" data-astro-cid-iysahtsw', '> <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" data-astro-cid-iysahtsw', '><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 10h18M7 15h1m4 0h1m-7 4h12a2 2 0 002-2V7a2 2 0 00-2-2H6a2 2 0 00-2 2v10a2 2 0 002 2z" data-astro-cid-iysahtsw', "></path></svg>\nMis Tarjetas\n</a> </li> <li data-astro-cid-iysahtsw", '> <a href="/Estudiante/Adeudos" data-path="/Estudiante/Adeudos" class="nav-link nav-inactive flex items-center gap-4 py-3 px-4 rounded-lg transition-all" data-astro-cid-iysahtsw', '> <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" data-astro-cid-iysahtsw', '><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" data-astro-cid-iysahtsw', "></path></svg>\nPagos Pendientes\n</a> </li> <li data-astro-cid-iysahtsw", '> <a href="/Estudiante/Historial" data-path="/Estudiante/Historial" class="nav-link nav-inactive flex items-center gap-4 py-3 px-4 rounded-lg transition-all" data-astro-cid-iysahtsw', '> <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" data-astro-cid-iysahtsw', '><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" data-astro-cid-iysahtsw', '></path></svg>\nHistorial\n</a> </li> </ul> </div> <div class="mt-auto pt-4 border-t border-white/10" data-astro-cid-iysahtsw', '> <a href="/logout" class="flex items-center gap-4 py-3 px-4 rounded-lg text-white hover:bg-white/10 transition-colors font-bold" data-astro-cid-iysahtsw', '> <div class="logout-icon-circle" data-astro-cid-iysahtsw', '> <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" data-astro-cid-iysahtsw', '><path d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" data-astro-cid-iysahtsw', '></path></svg> </div>\nSalir\n</a> </div> </nav> <main class="flex-1 p-4 md:p-8 md:ml-[250px] relative" data-astro-cid-iysahtsw', '> <button id="open-sidebar-button" class="md:hidden fixed top-4 left-4 p-3 rounded-xl bg-[#2e594d] text-white shadow-xl z-40" data-astro-cid-iysahtsw', '> <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" data-astro-cid-iysahtsw', '><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" data-astro-cid-iysahtsw', '></path></svg> </button> <div class="h-16 md:hidden" data-astro-cid-iysahtsw', '></div> <div class="bg-white p-6 md:p-10 rounded-[2rem] shadow-2xl content-fade-in min-h-[calc(100vh-4rem)]" data-astro-cid-iysahtsw', "> ", ` </div> </main> <script>
        const sidebar = document.getElementById('sidebar-menu');
        const openButton = document.getElementById('open-sidebar-button');
        const closeButton = document.getElementById('close-sidebar-button');
        const navLinks = document.querySelectorAll('.nav-link');
        const activeClass = 'nav-active';
        const inactiveClass = 'nav-inactive';

        function setActiveLink() {
            // Normalizar la ruta actual quitando la barra final
            let currentPath = window.location.pathname.replace(/\\\\/$/, "");
            
            navLinks.forEach(link => {
                const linkPath = link.getAttribute('data-path').replace(/\\\\/$/, "");
                link.classList.remove(activeClass, inactiveClass);
                
                if (linkPath === currentPath) {
                    link.classList.add(activeClass);
                } else {
                    link.classList.add(inactiveClass);
                }
            });
        }

        function openSidebar() {
            sidebar.classList.remove('sidebar-closed', 'hidden');
            openButton.style.display = 'none';
            document.body.style.overflow = 'hidden';
            if (window.innerWidth < 768) sidebar.classList.add('fixed', 'inset-0');
        }

        function closeSidebar() {
            sidebar.classList.add('sidebar-closed');
            setTimeout(() => {
                if (window.innerWidth < 768) {
                    sidebar.classList.add('hidden');
                    openButton.style.display = 'block';
                }
                document.body.style.overflow = '';
            }, 300);
        }

        openButton?.addEventListener('click', openSidebar);
        closeButton?.addEventListener('click', closeSidebar);
        
        navLinks.forEach(link => link.addEventListener('click', () => { 
            if (window.innerWidth < 768) closeSidebar(); 
        }));

        const handleResize = () => {
            if (window.innerWidth >= 768) {
                sidebar.classList.remove('hidden', 'sidebar-closed', 'inset-0');
                openButton.style.display = 'none';
                document.body.style.overflow = '';
            } else if (sidebar.classList.contains('sidebar-closed')) {
                sidebar.classList.add('hidden');
                openButton.style.display = 'block';
            }
        };

        window.addEventListener('resize', handleResize);
        window.addEventListener('load', () => { 
            handleResize(); 
            setActiveLink(); 
        });
        
        // Importante para Astro con transiciones de p\xE1gina
        document.addEventListener("astro:after-swap", setActiveLink);
    <\/script> </body> </html>`])), addAttribute($$definedVars, "style"), title, renderHead(), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), renderSlot($$result, $$slots["default"]));
}, "C:/Users/sarah/Documents/GitHub/CBTA/Frond-end/src/layouts/LayoutEstu.astro", void 0);

export { $$LayoutEstu as $ };
