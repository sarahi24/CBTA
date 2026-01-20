import { renderers } from './renderers.mjs';
import { c as createExports, s as serverEntrypointModule } from './chunks/_@astrojs-ssr-adapter_ByA-hEx9.mjs';
import { manifest } from './manifest_DabUsDrp.mjs';

const serverIslandMap = new Map();;

const _page0 = () => import('./pages/_image.astro.mjs');
const _page1 = () => import('./pages/concepts.astro.mjs');
const _page2 = () => import('./pages/dashboard.astro.mjs');
const _page3 = () => import('./pages/debts.astro.mjs');
const _page4 = () => import('./pages/estudiante/adeudos.astro.mjs');
const _page5 = () => import('./pages/estudiante/components/paymentstable.astro.mjs');
const _page6 = () => import('./pages/estudiante/components/progresscircle.astro.mjs');
const _page7 = () => import('./pages/estudiante/components/resumenacademico.astro.mjs');
const _page8 = () => import('./pages/estudiante/components/statcard.astro.mjs');
const _page9 = () => import('./pages/estudiante/historial.astro.mjs');
const _page10 = () => import('./pages/estudiante/portalestudiante.astro.mjs');
const _page11 = () => import('./pages/estudiante/tarjetas.astro.mjs');
const _page12 = () => import('./pages/estudiante_lista.astro.mjs');
const _page13 = () => import('./pages/new.astro.mjs');
const _page14 = () => import('./pages/payments.astro.mjs');
const _page15 = () => import('./pages/roles.astro.mjs');
const _page16 = () => import('./pages/students.astro.mjs');
const _page17 = () => import('./pages/index.astro.mjs');
const pageMap = new Map([
    ["node_modules/astro/dist/assets/endpoint/generic.js", _page0],
    ["src/pages/concepts.astro", _page1],
    ["src/pages/Dashboard.astro", _page2],
    ["src/pages/debts.astro", _page3],
    ["src/pages/Estudiante/Adeudos.astro", _page4],
    ["src/pages/Estudiante/components/PaymentsTable.astro", _page5],
    ["src/pages/Estudiante/components/ProgressCircle.astro", _page6],
    ["src/pages/Estudiante/components/ResumenAcademico.astro", _page7],
    ["src/pages/Estudiante/components/StatCard.astro", _page8],
    ["src/pages/Estudiante/Historial.astro", _page9],
    ["src/pages/Estudiante/PortalEstudiante.astro", _page10],
    ["src/pages/Estudiante/Tarjetas.astro", _page11],
    ["src/pages/estudiante_lista.astro", _page12],
    ["src/pages/new.astro", _page13],
    ["src/pages/payments.astro", _page14],
    ["src/pages/roles.astro", _page15],
    ["src/pages/students.astro", _page16],
    ["src/pages/index.astro", _page17]
]);

const _manifest = Object.assign(manifest, {
    pageMap,
    serverIslandMap,
    renderers,
    actions: () => import('./noop-entrypoint.mjs'),
    middleware: () => import('./_noop-middleware.mjs')
});
const _args = {
    "middlewareSecret": "75d97d84-6b40-48ca-9df8-eea26a48c0e2",
    "skewProtection": false
};
const _exports = createExports(_manifest, _args);
const __astrojsSsrVirtualEntry = _exports.default;
const _start = 'start';
if (Object.prototype.hasOwnProperty.call(serverEntrypointModule, _start)) ;

export { __astrojsSsrVirtualEntry as default, pageMap };
