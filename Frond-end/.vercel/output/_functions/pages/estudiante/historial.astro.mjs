import { e as createComponent, k as renderComponent, r as renderTemplate, m as maybeRenderHead, h as addAttribute } from '../../chunks/astro/server_6O5fLeT-.mjs';
import 'piccolore';
import { $ as $$LayoutEstu } from '../../chunks/LayoutEstu_B58GycIO.mjs';
/* empty css                                        */
export { renderers } from '../../renderers.mjs';

const $$Historial = createComponent(($$result, $$props, $$slots) => {
  const alumnoBackend = "Pedro Gonzalez Lopez";
  const title = "Historial de Pagos";
  const historialSemilla = [
    { id: 1, concepto: "Colegiatura Semestre II - 2024", monto: "1,218.00", fecha: "15 Nov, 2024", metodo: "Visa \u2022 4242", folio: "PAY-99283", categoria: "Acad\xE9mico" }
  ];
  return renderTemplate`${renderComponent($$result, "StudentLayout", $$LayoutEstu, { "title": title, "data-astro-cid-iu4463co": true }, { "default": ($$result2) => renderTemplate` ${maybeRenderHead()}<div class="page-wrapper"${addAttribute(`{
      search: '',
      pagos: [],
      
      init() {
        const guardados = localStorage.getItem('historial_pagos');
        if (guardados) {
          this.pagos = JSON.parse(guardados);
        } else {
          this.pagos = ${JSON.stringify(historialSemilla)};
          localStorage.setItem('historial_pagos', JSON.stringify(this.pagos));
        }
      },

      eliminarPago(id) {
        if(confirm('\xBFEst\xE1s seguro de que deseas eliminar este registro del historial?')) {
          this.pagos = this.pagos.filter(p => p.id !== id);
          localStorage.setItem('historial_pagos', JSON.stringify(this.pagos));
        }
      },

      get pagosFiltrados() {
        if(!this.search) return this.pagos;
        return this.pagos.filter(p => 
          p.concepto.toLowerCase().includes(this.search.toLowerCase()) || 
          p.folio.toLowerCase().includes(this.search.toLowerCase())
        );
      }
    }`, "x-data")} data-astro-cid-iu4463co> <header class="history-header" data-astro-cid-iu4463co> <div class="header-main" data-astro-cid-iu4463co> <div class="title-group" data-astro-cid-iu4463co> <p class="pre-title" data-astro-cid-iu4463co>Gestión Financiera</p> <h1 data-astro-cid-iu4463co>Mi Historial</h1> </div> <div class="user-pill" data-astro-cid-iu4463co> <div class="avatar-mini" data-astro-cid-iu4463co>PG</div> <span data-astro-cid-iu4463co>${alumnoBackend}</span> </div> </div> <div class="filter-bar" data-astro-cid-iu4463co> <div class="search-box" data-astro-cid-iu4463co> <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" data-astro-cid-iu4463co><circle cx="11" cy="11" r="8" data-astro-cid-iu4463co></circle><line x1="21" y1="21" x2="16.65" y2="16.65" data-astro-cid-iu4463co></line></svg> <input type="text" x-model="search" placeholder="Buscar por concepto o folio..." data-astro-cid-iu4463co> </div> </div> </header> <main class="history-content" data-astro-cid-iu4463co> <template x-if="pagosFiltrados.length === 0" data-astro-cid-iu4463co> <div class="empty-state" style="text-align: center; padding: 4rem 1rem; color: var(--text-muted);" data-astro-cid-iu4463co> <div style="font-size: 3rem; margin-bottom: 1rem;" data-astro-cid-iu4463co>🗑️</div> <h3 data-astro-cid-iu4463co>Historial vacío</h3> <p data-astro-cid-iu4463co>No se encontraron registros de pagos.</p> </div> </template> <div class="timeline" data-astro-cid-iu4463co> <template x-for="pago in pagosFiltrados" :key="pago.id" data-astro-cid-iu4463co> <div class="timeline-item" data-astro-cid-iu4463co> <div class="timeline-dot-wrapper" data-astro-cid-iu4463co> <div class="timeline-dot" data-astro-cid-iu4463co></div> <div class="timeline-line" data-astro-cid-iu4463co></div> </div> <div class="payment-card" data-astro-cid-iu4463co> <div class="payment-info" data-astro-cid-iu4463co> <div class="category-tag" x-text="pago.categoria" data-astro-cid-iu4463co></div> <h3 x-text="pago.concepto" style="margin: 4px 0; color: var(--primary); font-weight: 700;" data-astro-cid-iu4463co></h3> <div class="payment-meta" style="font-size: 0.85rem; color: var(--text-muted); margin-bottom: 12px;" data-astro-cid-iu4463co> <span x-text="pago.fecha" data-astro-cid-iu4463co></span> <span class="separator" style="margin: 0 6px;" data-astro-cid-iu4463co>•</span> <span class="folio" x-text="'ID: ' + pago.folio" data-astro-cid-iu4463co></span> </div> <div class="method-pill" data-astro-cid-iu4463co> <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" data-astro-cid-iu4463co><rect x="1" y="4" width="22" height="16" rx="2" ry="2" data-astro-cid-iu4463co></rect><line x1="1" y1="10" x2="23" y2="10" data-astro-cid-iu4463co></line></svg> <span x-text="pago.metodo" data-astro-cid-iu4463co></span> </div> </div> <div class="payment-action" data-astro-cid-iu4463co> <div class="amount-group" data-astro-cid-iu4463co> <span class="currency" style="font-size: 1rem; font-weight: 600; vertical-align: super; color: var(--primary);" data-astro-cid-iu4463co>$</span> <span class="amount" x-text="pago.monto.split('.')[0]" data-astro-cid-iu4463co></span> <span class="decimals" x-text="'.' + (pago.monto.split('.')[1] || '00')" style="font-size: 1rem; font-weight: 600; color: var(--primary);" data-astro-cid-iu4463co></span> </div> <button class="delete-btn" @click="eliminarPago(pago.id)" data-astro-cid-iu4463co> <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" data-astro-cid-iu4463co><polyline points="3 6 5 6 21 6" data-astro-cid-iu4463co></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2" data-astro-cid-iu4463co></path><line x1="10" y1="11" x2="10" y2="17" data-astro-cid-iu4463co></line><line x1="14" y1="11" x2="14" y2="17" data-astro-cid-iu4463co></line></svg> <span data-astro-cid-iu4463co>Eliminar</span> </button> </div> </div> </div> </template> </div> </main> </div> ` })} `;
}, "C:/Users/sarah/Documents/GitHub/CBTA/Frond-end/src/pages/Estudiante/Historial.astro", void 0);

const $$file = "C:/Users/sarah/Documents/GitHub/CBTA/Frond-end/src/pages/Estudiante/Historial.astro";
const $$url = "/Estudiante/Historial";

const _page = /*#__PURE__*/Object.freeze(/*#__PURE__*/Object.defineProperty({
  __proto__: null,
  default: $$Historial,
  file: $$file,
  url: $$url
}, Symbol.toStringTag, { value: 'Module' }));

const page = () => _page;

export { page };
