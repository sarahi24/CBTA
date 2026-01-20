import { e as createComponent, f as createAstro, k as renderComponent, r as renderTemplate, m as maybeRenderHead } from '../../chunks/astro/server_6O5fLeT-.mjs';
import 'piccolore';
import { $ as $$LayoutEstu } from '../../chunks/LayoutEstu_B58GycIO.mjs';
import { $ as $$StatCard } from '../../chunks/StatCard_BRdNCxQZ.mjs';
import { $ as $$ProgressCircle } from '../../chunks/ProgressCircle_2JTpZyIL.mjs';
import { $ as $$PaymentsTable } from '../../chunks/PaymentsTable_Ca_yDDdM.mjs';
/* empty css                                               */
export { renderers } from '../../renderers.mjs';

const $$Astro = createAstro();
const $$PortalEstudiante = createComponent(($$result, $$props, $$slots) => {
  const Astro2 = $$result.createAstro($$Astro, $$props, $$slots);
  Astro2.self = $$PortalEstudiante;
  const dashboardData = Astro2.props.dashboardData ?? {};
  return renderTemplate`${renderComponent($$result, "StudentLayout", $$LayoutEstu, { "title": "Panel de Estudiante", "data-astro-cid-2wricpoj": true }, { "default": ($$result2) => renderTemplate` ${maybeRenderHead()}<div class="main-container" data-astro-cid-2wricpoj> <header class="welcome-header" data-astro-cid-2wricpoj> <div class="header-left" data-astro-cid-2wricpoj> <div class="icon-box" data-astro-cid-2wricpoj> <svg xmlns="http://www.w3.org/2000/svg" class="header-icon-svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" data-astro-cid-2wricpoj> <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" data-astro-cid-2wricpoj></path> </svg> </div> <div data-astro-cid-2wricpoj> <p class="welcome-label" data-astro-cid-2wricpoj>Dashboard Académico</p> <h1 class="student-name" data-astro-cid-2wricpoj>Hola, ${dashboardData.alumnoNombre?.split(" ")[0] || "Estudiante"}</h1> </div> </div> <div class="header-right mobile-hide" data-astro-cid-2wricpoj> <span class="current-date" data-astro-cid-2wricpoj>${(/* @__PURE__ */ new Date()).toLocaleDateString("es-MX", { weekday: "long", day: "numeric", month: "long" })}</span> </div> </header> <section class="stats-scroll-container" data-astro-cid-2wricpoj> ${renderComponent($$result2, "StatCard", $$StatCard, { "title": "Pendientes", "amount": dashboardData?.pagosPendientes?.monto || "$0.00", "subtitle": dashboardData?.pagosPendientes?.info || "Sin adeudos", "type": "danger", "data-astro-cid-2wricpoj": true }, { "icon": ($$result3) => renderTemplate`<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" data-astro-cid-2wricpoj><circle cx="12" cy="12" r="10" data-astro-cid-2wricpoj></circle><path d="M12 8v4l3 3" data-astro-cid-2wricpoj></path></svg>` })} ${renderComponent($$result2, "StatCard", $$StatCard, { "title": "Realizados", "amount": dashboardData?.pagosRealizados?.monto || "$0.00", "subtitle": dashboardData?.pagosRealizados?.info || "0 Pagos", "type": "default", "data-astro-cid-2wricpoj": true }, { "icon": ($$result3) => renderTemplate`<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" data-astro-cid-2wricpoj><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14" data-astro-cid-2wricpoj></path><polyline points="22 4 12 14.01 9 11.01" data-astro-cid-2wricpoj></polyline></svg>` })} ${renderComponent($$result2, "StatCard", $$StatCard, { "title": "Total Inversi\xF3n", "amount": dashboardData?.totalPagado || "$0.00", "subtitle": "Monto acumulado", "type": "info", "data-astro-cid-2wricpoj": true }, { "icon": ($$result3) => renderTemplate`<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" data-astro-cid-2wricpoj><rect x="2" y="5" width="20" height="14" rx="2" data-astro-cid-2wricpoj></rect><line x1="2" y1="10" x2="22" y2="10" data-astro-cid-2wricpoj></line></svg>` })} </section> <div class="bottom-grid" data-astro-cid-2wricpoj> <div class="summary-card glass-effect" data-astro-cid-2wricpoj> <div class="card-header" data-astro-cid-2wricpoj> <h3 class="summary-title" data-astro-cid-2wricpoj>Balance de Cuenta</h3> <span class="status-badge" data-astro-cid-2wricpoj>Actualizado</span> </div> <div class="summary-row" data-astro-cid-2wricpoj> <div class="label-group" data-astro-cid-2wricpoj> <div class="dot green" data-astro-cid-2wricpoj></div> <span class="summary-label" data-astro-cid-2wricpoj>Monto Liquidado</span> </div> <span class="val-ok" data-astro-cid-2wricpoj>${dashboardData?.totalPagado}</span> </div> <div class="summary-row no-border" data-astro-cid-2wricpoj> <div class="label-group" data-astro-cid-2wricpoj> <div class="dot red" data-astro-cid-2wricpoj></div> <span class="summary-label" data-astro-cid-2wricpoj>Monto por Pagar</span> </div> <span class="val-alert" data-astro-cid-2wricpoj>${dashboardData?.totalPendiente}</span> </div> </div> <div class="progress-card glass-effect" data-astro-cid-2wricpoj> <div class="progress-inner" data-astro-cid-2wricpoj> ${renderComponent($$result2, "ProgressCircle", $$ProgressCircle, { "percentage": dashboardData?.porcentajeProgreso, "label": "Logro", "data-astro-cid-2wricpoj": true })} </div> </div> </div> <div class="payments-wrapper glass-effect" data-astro-cid-2wricpoj> <div class="table-header" data-astro-cid-2wricpoj> <h3 class="summary-title" data-astro-cid-2wricpoj>Historial Reciente</h3> </div> ${renderComponent($$result2, "PaymentsTable", $$PaymentsTable, { "pagos": dashboardData?.pagos, "data-astro-cid-2wricpoj": true })} </div> </div> ` })} `;
}, "C:/Users/sarah/Documents/GitHub/CBTA/Frond-end/src/pages/Estudiante/PortalEstudiante.astro", void 0);

const $$file = "C:/Users/sarah/Documents/GitHub/CBTA/Frond-end/src/pages/Estudiante/PortalEstudiante.astro";
const $$url = "/Estudiante/PortalEstudiante";

const _page = /*#__PURE__*/Object.freeze(/*#__PURE__*/Object.defineProperty({
  __proto__: null,
  default: $$PortalEstudiante,
  file: $$file,
  url: $$url
}, Symbol.toStringTag, { value: 'Module' }));

const page = () => _page;

export { page };
