import { e as createComponent, f as createAstro, q as defineStyleVars, r as renderTemplate, p as renderSlot, h as addAttribute, v as renderHead } from './astro/server_6O5fLeT-.mjs';
/* empty css                             */
/* empty css                             */
import 'clsx';

var __freeze = Object.freeze;
var __defProp = Object.defineProperty;
var __template = (cooked, raw) => __freeze(__defProp(cooked, "raw", { value: __freeze(raw || cooked.slice()) }));
var _a;
const $$Astro = createAstro();
const $$Layout = createComponent(($$result, $$props, $$slots) => {
  const Astro2 = $$result.createAstro($$Astro, $$props, $$slots);
  Astro2.self = $$Layout;
  const { title } = Astro2.props;
  const PRIMARY_COLOR = "#2e594d";
  const ACCENT_COLOR = "#86efad";
  const BACKGROUND_COLOR = "#d9dde2";
  const TEXT_COLOR_DARK = "#374151";
  const $$definedVars = defineStyleVars([{ PRIMARY_COLOR, ACCENT_COLOR, BACKGROUND_COLOR, TEXT_COLOR_DARK }]);
  return renderTemplate(_a || (_a = __template(['<html lang="es" data-astro-cid-sckkx6r4', '> <head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>', ' | CBTA 71</title><link rel="icon" href="/Logo.png" type="image/png"><link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700;800&display=swap" rel="stylesheet">', '</head> <body class="flex min-h-screen antialiased" data-astro-cid-sckkx6r4', '> <nav id="sidebar-menu"', " data-astro-cid-sckkx6r4", '>  <button id="close-sidebar-button" class="md:hidden absolute top-3 right-3 p-2 rounded-full bg-white/20 hover:bg-white/40 z-50 transition text-white" aria-label="Cerrar men\xFA lateral" data-astro-cid-sckkx6r4', '> <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round" data-astro-cid-sckkx6r4', '><path stroke="none" d="M0 0h24v24H0z" fill="none" data-astro-cid-sckkx6r4', '></path><path d="M18 6l-12 12" data-astro-cid-sckkx6r4', '></path><path d="M6 6l12 12" data-astro-cid-sckkx6r4', '></path></svg> </button>  <div class="flex items-center gap-4 mb-10 pt-3 border-b border-white/10 pb-4" data-astro-cid-sckkx6r4', '> <div class="h-10 w-10" data-astro-cid-sckkx6r4', '> <img src="/Logo.png" alt="Logo CBTA 71" class="w-full h-full object-contain" data-astro-cid-sckkx6r4', "> </div> <div data-astro-cid-sckkx6r4", '> <h1 class="text-xl font-extrabold tracking-wide" data-astro-cid-sckkx6r4', '>CBTA 71</h1> <p class="text-xs opacity-80" data-astro-cid-sckkx6r4', '>Sistema Administrativo</p> </div> </div>  <div class="flex-grow overflow-y-auto pr-2" data-astro-cid-sckkx6r4', '> <ul id="main-navigation" class="space-y-2" data-astro-cid-sckkx6r4', ">  <li data-astro-cid-sckkx6r4", '> <a href="/Dashboard" data-path="/Dashboard" class="nav-link nav-inactive flex items-center gap-4 py-3 px-4 rounded-lg transition-all duration-200" data-astro-cid-sckkx6r4', '> <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round" data-astro-cid-sckkx6r4', '><path stroke="none" d="M0 0h24v24H0z" fill="none" data-astro-cid-sckkx6r4', '></path><path d="M3 3v18h18" data-astro-cid-sckkx6r4', '></path><path d="M18 17v-4" data-astro-cid-sckkx6r4', '></path><path d="M12 17v-8" data-astro-cid-sckkx6r4', '></path><path d="M6 17v-2" data-astro-cid-sckkx6r4', "></path></svg>\nDashboard\n</a> </li>  <li data-astro-cid-sckkx6r4", '> <a href="/concepts" data-path="/concepts" class="nav-link nav-inactive flex items-center gap-4 py-3 px-4 rounded-lg transition-all duration-200" data-astro-cid-sckkx6r4', '> <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round" data-astro-cid-sckkx6r4', '><path stroke="none" d="M0 0h24v24H0z" fill="none" data-astro-cid-sckkx6r4', '></path><path d="M4 20h4l10.5 -10.5a2.828 2.828 0 1 0 -4 -4l-10.5 10.5v4" data-astro-cid-sckkx6r4', '></path><path d="M13.5 6.5l4 4" data-astro-cid-sckkx6r4', '></path><path d="M19 16v3h-3" data-astro-cid-sckkx6r4', "></path></svg>\nConceptos\n</a> </li>  <li data-astro-cid-sckkx6r4", '> <a href="/students" data-path="/students" class="nav-link nav-inactive flex items-center gap-4 py-3 px-4 rounded-lg transition-all duration-200" data-astro-cid-sckkx6r4', '> <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round" data-astro-cid-sckkx6r4', '><path stroke="none" d="M0 0h24v24H0z" fill="none" data-astro-cid-sckkx6r4', '></path><path d="M9 7m-4 0a4 4 0 1 0 8 0a4 4 0 1 0 -8 0" data-astro-cid-sckkx6r4', '></path><path d="M3 21v-2a4 4 0 0 1 4 -4h4a4 4 0 0 1 4 4v2" data-astro-cid-sckkx6r4', '></path><path d="M16 3.125a4 4 0 1 1 0 7.75" data-astro-cid-sckkx6r4', '></path><path d="M21 21v-2a4 4 0 0 0 -3 -3.85" data-astro-cid-sckkx6r4', "></path></svg>\nEstudiantes\n</a> </li>  <li data-astro-cid-sckkx6r4", '> <a href="/payments" data-path="/payments" class="nav-link nav-inactive flex items-center gap-4 py-3 px-4 rounded-lg transition-all duration-200" data-astro-cid-sckkx6r4', '> <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round" data-astro-cid-sckkx6r4', '><path stroke="none" d="M0 0h24v24H0z" fill="none" data-astro-cid-sckkx6r4', '></path><path d="M9 14h-2a2 2 0 0 1 -2 -2v-6a2 2 0 0 1 2 -2h10a2 2 0 0 1 2 2v6a2 2 0 0 1 -2 2h-2" data-astro-cid-sckkx6r4', '></path><path d="M12 17v-1h-3a1 1 0 0 0 -1 1v2a1 1 0 0 0 1 1h3v1" data-astro-cid-sckkx6r4', "></path></svg>\nPagos\n</a> </li>  <li data-astro-cid-sckkx6r4", '> <a href="/debts" data-path="/debts" class="nav-link nav-inactive flex items-center gap-4 py-3 px-4 rounded-lg transition-all duration-200" data-astro-cid-sckkx6r4', '> <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round" data-astro-cid-sckkx6r4', '><path stroke="none" d="M0 0h24v24H0z" fill="none" data-astro-cid-sckkx6r4', '></path><path d="M14 3v4a1 1 0 0 0 1 1h4" data-astro-cid-sckkx6r4', '></path><path d="M17 21h-10a2 2 0 0 1 -2 -2v-14a2 2 0 0 1 2 -2h7l5 5v11a2 2 0 0 1 -2 2z" data-astro-cid-sckkx6r4', '></path><path d="M10 12l4 4m0 -4l-4 4" data-astro-cid-sckkx6r4', "></path></svg>\nAdeudos\n</a> </li>  <li data-astro-cid-sckkx6r4", '> <a href="/roles" data-path="/roles" class="nav-link nav-inactive flex items-center gap-4 py-3 px-4 rounded-lg transition-all duration-200" data-astro-cid-sckkx6r4', '> <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round" data-astro-cid-sckkx6r4', '><path stroke="none" d="M0 0h24v24H0z" fill="none" data-astro-cid-sckkx6r4', '></path><path d="M12 12m-9 0a9 9 0 1 0 18 0a9 9 0 1 0 -18 0" data-astro-cid-sckkx6r4', '></path><path d="M12 10a2 2 0 0 1 2 2a2 2 0 0 1 2 2a2 2 0 0 1 -2 2h-4a2 2 0 0 1 -2 -2a2 2 0 0 1 2 -2a2 2 0 0 1 2 -2z" data-astro-cid-sckkx6r4', '></path></svg>\nRoles y Usuarios\n</a> </li> </ul> </div>  <div class="mt-auto pt-4 border-t border-white/10" data-astro-cid-sckkx6r4', '> <ul class="space-y-2" data-astro-cid-sckkx6r4', "> <li data-astro-cid-sckkx6r4", '> <a href="/logout" class="flex items-center gap-4 py-3 px-4 rounded-lg text-white hover:bg-white/10 transition-colors duration-200" data-astro-cid-sckkx6r4', '> <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round" data-astro-cid-sckkx6r4', '><path stroke="none" d="M0 0h24v24H0z" fill="none" data-astro-cid-sckkx6r4', '></path><path d="M14 8v-2a2 2 0 0 0 -2 -2h-7a2 2 0 0 0 -2 2v12a2 2 0 0 0 2 2h7a2 2 0 0 0 2 -2v-2" data-astro-cid-sckkx6r4', '></path><path d="M7 12h14l-3 -3m0 6l3 -3" data-astro-cid-sckkx6r4', '></path></svg>\nSalir\n</a> </li> </ul> </div> </nav>  <main class="flex-1 p-4 md:p-8 overflow-y-auto md:ml-[250px] relative" data-astro-cid-sckkx6r4', '>  <button id="open-sidebar-button" class="md:hidden fixed top-4 left-4 p-3 rounded-xl bg-[${PRIMARY_COLOR}] text-white shadow-xl z-40 transition hover:bg-[#256d5e]" aria-label="Abrir men\xFA lateral" data-astro-cid-sckkx6r4', '> <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round" data-astro-cid-sckkx6r4', '><path stroke="none" d="M0 0h24v24H0z" fill="none" data-astro-cid-sckkx6r4', '></path><path d="M4 6l16 0" data-astro-cid-sckkx6r4', '></path><path d="M4 12l16 0" data-astro-cid-sckkx6r4', '></path><path d="M4 18l16 0" data-astro-cid-sckkx6r4', '></path></svg> </button> <div class="h-16 md:hidden" data-astro-cid-sckkx6r4', '></div>  <div class="bg-white p-6 md:p-8 rounded-xl shadow-2xl content-fade-in min-h-[calc(100vh-4rem)]" data-astro-cid-sckkx6r4', "> ", ` </div> </main> <script>
		const sidebar = document.getElementById('sidebar-menu');
		const openButton = document.getElementById('open-sidebar-button');
		const closeButton = document.getElementById('close-sidebar-button');
		const navLinks = document.querySelectorAll('.nav-link');
		const activeClass = 'nav-active';
		const inactiveClass = 'nav-inactive';


		function setActiveLink() {
			// Normaliza la ruta actual: / o /Dashboard
			let currentPath = window.location.pathname.replace(/\\/$/, "");
			if (currentPath === "") currentPath = "/Dashboard";
			
			navLinks.forEach(link => {
				const linkPath = link.getAttribute('data-path');
				
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
			if (window.innerWidth < 768) {
				sidebar.classList.remove('hidden');
				sidebar.classList.add('fixed', 'inset-0');
			}
		}

		function closeSidebar() {
			sidebar.classList.add('sidebar-closed');
			// Usamos setTimeout solo para acciones despu\xE9s de la transici\xF3n
			setTimeout(() => {
				if (window.innerWidth < 768) {
					sidebar.classList.add('hidden');
					sidebar.classList.remove('fixed', 'inset-0');
					openButton.style.display = 'block';
				}
				document.body.style.overflow = '';
			}, 300); // 300ms = duraci\xF3n de la transici\xF3n CSS
		}


		openButton?.addEventListener('click', openSidebar);
		closeButton?.addEventListener('click', closeSidebar);
		
		// Cerrar sidebar en m\xF3vil al hacer click en un enlace
		navLinks.forEach(link => link.addEventListener('click', (e) => {
			if (window.innerWidth < 768) closeSidebar();
			// No llamar setActiveLink aqu\xED, sino dejar que Astro lo maneje o window.load
		}));


		const handleResize = () => {
			if (window.innerWidth >= 768) {
				// Desktop: Sidebar siempre visible y abierto
				sidebar.classList.remove('hidden', 'sidebar-closed', 'inset-0');
				openButton.style.display = 'none';
				document.body.style.overflow = '';
			} else {
				// Mobile: Ocultar si est\xE1 cerrado
				if (sidebar.classList.contains('sidebar-closed')) {
                    sidebar.classList.add('hidden');
                    openButton.style.display = 'block';
                } else {
                    openButton.style.display = 'none';
                }
			}
		};


		window.addEventListener('resize', handleResize);
		window.addEventListener('load', () => { handleResize(); setActiveLink(); });
		document.addEventListener("astro:after-swap", setActiveLink);
	<\/script> </body> </html>`], ['<html lang="es" data-astro-cid-sckkx6r4', '> <head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>', ' | CBTA 71</title><link rel="icon" href="/Logo.png" type="image/png"><link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700;800&display=swap" rel="stylesheet">', '</head> <body class="flex min-h-screen antialiased" data-astro-cid-sckkx6r4', '> <nav id="sidebar-menu"', " data-astro-cid-sckkx6r4", '>  <button id="close-sidebar-button" class="md:hidden absolute top-3 right-3 p-2 rounded-full bg-white/20 hover:bg-white/40 z-50 transition text-white" aria-label="Cerrar men\xFA lateral" data-astro-cid-sckkx6r4', '> <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round" data-astro-cid-sckkx6r4', '><path stroke="none" d="M0 0h24v24H0z" fill="none" data-astro-cid-sckkx6r4', '></path><path d="M18 6l-12 12" data-astro-cid-sckkx6r4', '></path><path d="M6 6l12 12" data-astro-cid-sckkx6r4', '></path></svg> </button>  <div class="flex items-center gap-4 mb-10 pt-3 border-b border-white/10 pb-4" data-astro-cid-sckkx6r4', '> <div class="h-10 w-10" data-astro-cid-sckkx6r4', '> <img src="/Logo.png" alt="Logo CBTA 71" class="w-full h-full object-contain" data-astro-cid-sckkx6r4', "> </div> <div data-astro-cid-sckkx6r4", '> <h1 class="text-xl font-extrabold tracking-wide" data-astro-cid-sckkx6r4', '>CBTA 71</h1> <p class="text-xs opacity-80" data-astro-cid-sckkx6r4', '>Sistema Administrativo</p> </div> </div>  <div class="flex-grow overflow-y-auto pr-2" data-astro-cid-sckkx6r4', '> <ul id="main-navigation" class="space-y-2" data-astro-cid-sckkx6r4', ">  <li data-astro-cid-sckkx6r4", '> <a href="/Dashboard" data-path="/Dashboard" class="nav-link nav-inactive flex items-center gap-4 py-3 px-4 rounded-lg transition-all duration-200" data-astro-cid-sckkx6r4', '> <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round" data-astro-cid-sckkx6r4', '><path stroke="none" d="M0 0h24v24H0z" fill="none" data-astro-cid-sckkx6r4', '></path><path d="M3 3v18h18" data-astro-cid-sckkx6r4', '></path><path d="M18 17v-4" data-astro-cid-sckkx6r4', '></path><path d="M12 17v-8" data-astro-cid-sckkx6r4', '></path><path d="M6 17v-2" data-astro-cid-sckkx6r4', "></path></svg>\nDashboard\n</a> </li>  <li data-astro-cid-sckkx6r4", '> <a href="/concepts" data-path="/concepts" class="nav-link nav-inactive flex items-center gap-4 py-3 px-4 rounded-lg transition-all duration-200" data-astro-cid-sckkx6r4', '> <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round" data-astro-cid-sckkx6r4', '><path stroke="none" d="M0 0h24v24H0z" fill="none" data-astro-cid-sckkx6r4', '></path><path d="M4 20h4l10.5 -10.5a2.828 2.828 0 1 0 -4 -4l-10.5 10.5v4" data-astro-cid-sckkx6r4', '></path><path d="M13.5 6.5l4 4" data-astro-cid-sckkx6r4', '></path><path d="M19 16v3h-3" data-astro-cid-sckkx6r4', "></path></svg>\nConceptos\n</a> </li>  <li data-astro-cid-sckkx6r4", '> <a href="/students" data-path="/students" class="nav-link nav-inactive flex items-center gap-4 py-3 px-4 rounded-lg transition-all duration-200" data-astro-cid-sckkx6r4', '> <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round" data-astro-cid-sckkx6r4', '><path stroke="none" d="M0 0h24v24H0z" fill="none" data-astro-cid-sckkx6r4', '></path><path d="M9 7m-4 0a4 4 0 1 0 8 0a4 4 0 1 0 -8 0" data-astro-cid-sckkx6r4', '></path><path d="M3 21v-2a4 4 0 0 1 4 -4h4a4 4 0 0 1 4 4v2" data-astro-cid-sckkx6r4', '></path><path d="M16 3.125a4 4 0 1 1 0 7.75" data-astro-cid-sckkx6r4', '></path><path d="M21 21v-2a4 4 0 0 0 -3 -3.85" data-astro-cid-sckkx6r4', "></path></svg>\nEstudiantes\n</a> </li>  <li data-astro-cid-sckkx6r4", '> <a href="/payments" data-path="/payments" class="nav-link nav-inactive flex items-center gap-4 py-3 px-4 rounded-lg transition-all duration-200" data-astro-cid-sckkx6r4', '> <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round" data-astro-cid-sckkx6r4', '><path stroke="none" d="M0 0h24v24H0z" fill="none" data-astro-cid-sckkx6r4', '></path><path d="M9 14h-2a2 2 0 0 1 -2 -2v-6a2 2 0 0 1 2 -2h10a2 2 0 0 1 2 2v6a2 2 0 0 1 -2 2h-2" data-astro-cid-sckkx6r4', '></path><path d="M12 17v-1h-3a1 1 0 0 0 -1 1v2a1 1 0 0 0 1 1h3v1" data-astro-cid-sckkx6r4', "></path></svg>\nPagos\n</a> </li>  <li data-astro-cid-sckkx6r4", '> <a href="/debts" data-path="/debts" class="nav-link nav-inactive flex items-center gap-4 py-3 px-4 rounded-lg transition-all duration-200" data-astro-cid-sckkx6r4', '> <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round" data-astro-cid-sckkx6r4', '><path stroke="none" d="M0 0h24v24H0z" fill="none" data-astro-cid-sckkx6r4', '></path><path d="M14 3v4a1 1 0 0 0 1 1h4" data-astro-cid-sckkx6r4', '></path><path d="M17 21h-10a2 2 0 0 1 -2 -2v-14a2 2 0 0 1 2 -2h7l5 5v11a2 2 0 0 1 -2 2z" data-astro-cid-sckkx6r4', '></path><path d="M10 12l4 4m0 -4l-4 4" data-astro-cid-sckkx6r4', "></path></svg>\nAdeudos\n</a> </li>  <li data-astro-cid-sckkx6r4", '> <a href="/roles" data-path="/roles" class="nav-link nav-inactive flex items-center gap-4 py-3 px-4 rounded-lg transition-all duration-200" data-astro-cid-sckkx6r4', '> <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round" data-astro-cid-sckkx6r4', '><path stroke="none" d="M0 0h24v24H0z" fill="none" data-astro-cid-sckkx6r4', '></path><path d="M12 12m-9 0a9 9 0 1 0 18 0a9 9 0 1 0 -18 0" data-astro-cid-sckkx6r4', '></path><path d="M12 10a2 2 0 0 1 2 2a2 2 0 0 1 2 2a2 2 0 0 1 -2 2h-4a2 2 0 0 1 -2 -2a2 2 0 0 1 2 -2a2 2 0 0 1 2 -2z" data-astro-cid-sckkx6r4', '></path></svg>\nRoles y Usuarios\n</a> </li> </ul> </div>  <div class="mt-auto pt-4 border-t border-white/10" data-astro-cid-sckkx6r4', '> <ul class="space-y-2" data-astro-cid-sckkx6r4', "> <li data-astro-cid-sckkx6r4", '> <a href="/logout" class="flex items-center gap-4 py-3 px-4 rounded-lg text-white hover:bg-white/10 transition-colors duration-200" data-astro-cid-sckkx6r4', '> <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round" data-astro-cid-sckkx6r4', '><path stroke="none" d="M0 0h24v24H0z" fill="none" data-astro-cid-sckkx6r4', '></path><path d="M14 8v-2a2 2 0 0 0 -2 -2h-7a2 2 0 0 0 -2 2v12a2 2 0 0 0 2 2h7a2 2 0 0 0 2 -2v-2" data-astro-cid-sckkx6r4', '></path><path d="M7 12h14l-3 -3m0 6l3 -3" data-astro-cid-sckkx6r4', '></path></svg>\nSalir\n</a> </li> </ul> </div> </nav>  <main class="flex-1 p-4 md:p-8 overflow-y-auto md:ml-[250px] relative" data-astro-cid-sckkx6r4', '>  <button id="open-sidebar-button" class="md:hidden fixed top-4 left-4 p-3 rounded-xl bg-[\\${PRIMARY_COLOR}] text-white shadow-xl z-40 transition hover:bg-[#256d5e]" aria-label="Abrir men\xFA lateral" data-astro-cid-sckkx6r4', '> <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round" data-astro-cid-sckkx6r4', '><path stroke="none" d="M0 0h24v24H0z" fill="none" data-astro-cid-sckkx6r4', '></path><path d="M4 6l16 0" data-astro-cid-sckkx6r4', '></path><path d="M4 12l16 0" data-astro-cid-sckkx6r4', '></path><path d="M4 18l16 0" data-astro-cid-sckkx6r4', '></path></svg> </button> <div class="h-16 md:hidden" data-astro-cid-sckkx6r4', '></div>  <div class="bg-white p-6 md:p-8 rounded-xl shadow-2xl content-fade-in min-h-[calc(100vh-4rem)]" data-astro-cid-sckkx6r4', "> ", ` </div> </main> <script>
		const sidebar = document.getElementById('sidebar-menu');
		const openButton = document.getElementById('open-sidebar-button');
		const closeButton = document.getElementById('close-sidebar-button');
		const navLinks = document.querySelectorAll('.nav-link');
		const activeClass = 'nav-active';
		const inactiveClass = 'nav-inactive';


		function setActiveLink() {
			// Normaliza la ruta actual: / o /Dashboard
			let currentPath = window.location.pathname.replace(/\\\\/$/, "");
			if (currentPath === "") currentPath = "/Dashboard";
			
			navLinks.forEach(link => {
				const linkPath = link.getAttribute('data-path');
				
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
			if (window.innerWidth < 768) {
				sidebar.classList.remove('hidden');
				sidebar.classList.add('fixed', 'inset-0');
			}
		}

		function closeSidebar() {
			sidebar.classList.add('sidebar-closed');
			// Usamos setTimeout solo para acciones despu\xE9s de la transici\xF3n
			setTimeout(() => {
				if (window.innerWidth < 768) {
					sidebar.classList.add('hidden');
					sidebar.classList.remove('fixed', 'inset-0');
					openButton.style.display = 'block';
				}
				document.body.style.overflow = '';
			}, 300); // 300ms = duraci\xF3n de la transici\xF3n CSS
		}


		openButton?.addEventListener('click', openSidebar);
		closeButton?.addEventListener('click', closeSidebar);
		
		// Cerrar sidebar en m\xF3vil al hacer click en un enlace
		navLinks.forEach(link => link.addEventListener('click', (e) => {
			if (window.innerWidth < 768) closeSidebar();
			// No llamar setActiveLink aqu\xED, sino dejar que Astro lo maneje o window.load
		}));


		const handleResize = () => {
			if (window.innerWidth >= 768) {
				// Desktop: Sidebar siempre visible y abierto
				sidebar.classList.remove('hidden', 'sidebar-closed', 'inset-0');
				openButton.style.display = 'none';
				document.body.style.overflow = '';
			} else {
				// Mobile: Ocultar si est\xE1 cerrado
				if (sidebar.classList.contains('sidebar-closed')) {
                    sidebar.classList.add('hidden');
                    openButton.style.display = 'block';
                } else {
                    openButton.style.display = 'none';
                }
			}
		};


		window.addEventListener('resize', handleResize);
		window.addEventListener('load', () => { handleResize(); setActiveLink(); });
		document.addEventListener("astro:after-swap", setActiveLink);
	<\/script> </body> </html>`])), addAttribute($$definedVars, "style"), title, renderHead(), addAttribute($$definedVars, "style"), addAttribute(`bg-[${PRIMARY_COLOR}] text-white flex-col p-5 shadow-2xl z-50 overflow-y-auto
		fixed inset-0 w-full max-w-[250px] h-full transition-transform-fast sidebar-closed
		md:fixed md:top-0 md:flex md:h-screen md:w-[250px] md:shadow-lg md:rounded-r-xl`, "class"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), addAttribute($$definedVars, "style"), renderSlot($$result, $$slots["default"]));
}, "C:/Users/sarah/Documents/GitHub/CBTA/Frond-end/src/layouts/Layout.astro", void 0);

export { $$Layout as $ };
