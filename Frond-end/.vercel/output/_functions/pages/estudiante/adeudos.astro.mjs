import { e as createComponent, k as renderComponent, r as renderTemplate, m as maybeRenderHead, h as addAttribute } from '../../chunks/astro/server_6O5fLeT-.mjs';
import 'piccolore';
import { $ as $$LayoutEstu } from '../../chunks/LayoutEstu_B58GycIO.mjs';
/* empty css                                      */
export { renderers } from '../../renderers.mjs';

const $$Adeudos = createComponent(($$result, $$props, $$slots) => {
  const title = "Finanzas Estudiantiles";
  const adeudosExistentes = [
    { id: 1, concepto: "Colegiatura Semestre I - 2024", monto: "1,218.00", fecha: "20 Dic, 2024", status: "Pendiente" },
    { id: 2, concepto: "Inscripci\xF3n Curso Ingl\xE9s", monto: "450.00", fecha: "15 Ene, 2025", status: "Pr\xF3ximo" },
    { id: 3, concepto: "Seguro Estudiantil Anual", monto: "285.00", fecha: "05 Feb, 2025", status: "Pr\xF3ximo" }
  ];
  const tarjetasPorDefecto = [
    { id: 1, tipo: "Visa", terminacion: "4242", logo: "https://upload.wikimedia.org/wikipedia/commons/5/5e/Visa_Inc._logo.svg" },
    { id: 2, tipo: "Mastercard", terminacion: "8812", logo: "https://upload.wikimedia.org/wikipedia/commons/2/2a/Mastercard-logo.svg" }
  ];
  return renderTemplate`${renderComponent($$result, "StudentLayout", $$LayoutEstu, { "title": title, "data-astro-cid-vbivu3ot": true }, { "default": ($$result2) => renderTemplate` ${maybeRenderHead()}<div class="page-wrapper"${addAttribute(`{ 
      showModal: false,
      step: 'select-method', 
      loading: false,
      selectedItem: null,
      selectedCard: null,
      adeudos: [],
      tarjetas: [],

      init() {
        const guardadas = localStorage.getItem('mis_tarjetas');
        this.tarjetas = guardadas ? JSON.parse(guardadas) : ${JSON.stringify(tarjetasPorDefecto)};
        
        const adeudosGuardados = localStorage.getItem('mis_adeudos');
        this.adeudos = adeudosGuardados ? JSON.parse(adeudosGuardados) : ${JSON.stringify(adeudosExistentes)};
        if(!adeudosGuardados) localStorage.setItem('mis_adeudos', JSON.stringify(this.adeudos));
      },

      openPayment(item) {
        this.selectedItem = item;
        this.step = 'select-method';
        this.showModal = true;
      },

      processPayment(isReference = false) {
        this.loading = true;
        
        const nuevoPago = {
          id: Date.now(),
          concepto: this.selectedItem.concepto,
          monto: this.selectedItem.monto,
          fecha: new Date().toLocaleDateString('es-MX', { day: '2-digit', month: 'short', year: 'numeric' }),
          metodo: isReference ? 'Referencia / Efectivo' : (this.selectedCard.tipo + ' \u2022 ' + this.selectedCard.terminacion),
          folio: 'PAY-' + Math.floor(Math.random() * 90000 + 10000),
          categoria: isReference ? 'Tr\xE1mite' : 'Acad\xE9mico'
        };

        setTimeout(() => {
          // 1. Guardar en Historial
          const historial = JSON.parse(localStorage.getItem('historial_pagos') || '[]');
          historial.unshift(nuevoPago);
          localStorage.setItem('historial_pagos', JSON.stringify(historial));

          // 2. Borrar de Pendientes
          this.adeudos = this.adeudos.filter(a => a.id !== this.selectedItem.id);
          localStorage.setItem('mis_adeudos', JSON.stringify(this.adeudos));

          this.loading = false;
          // 3. Redirigir a la ruta exacta
          window.location.href = '/Estudiante/Historial'; 
        }, 2000);
      }
    }`, "x-data")} data-astro-cid-vbivu3ot> <header class="main-header" data-astro-cid-vbivu3ot> <div class="header-content" data-astro-cid-vbivu3ot> <div class="user-profile" data-astro-cid-vbivu3ot> <div class="avatar" data-astro-cid-vbivu3ot>PG</div> <div class="welcome-text" data-astro-cid-vbivu3ot> <span class="greeting" data-astro-cid-vbivu3ot>Estado de Cuenta</span> <h1 x-text="'Hola, ' + '\${alumnoBackend}'.split(' ')[0]" data-astro-cid-vbivu3ot></h1> </div> </div> <div class="balance-summary" data-astro-cid-vbivu3ot> <span class="label" data-astro-cid-vbivu3ot>Total por Pagar</span> <span class="amount" x-text="'$' + adeudos.reduce((acc, item) => acc + parseFloat(item.monto.replace(',','')), 0).toLocaleString('en-US', {minimumFractionDigits: 2})" data-astro-cid-vbivu3ot></span> </div> </div> </header> <main class="content-grid" data-astro-cid-vbivu3ot> <section class="section-container" data-astro-cid-vbivu3ot> <h2 class="section-title" data-astro-cid-vbivu3ot>Pagos Pendientes</h2> <template x-if="adeudos.length === 0" data-astro-cid-vbivu3ot> <div style="text-align: center; padding: 4rem; background: white; border-radius: 24px; border: 2px dashed #e2e8f0;" data-astro-cid-vbivu3ot> <p style="color: var(--text-muted); font-weight: 600;" data-astro-cid-vbivu3ot>✨ No tienes pagos pendientes por ahora.</p> </div> </template> <div class="cards-stack" data-astro-cid-vbivu3ot> <template x-for="item in adeudos" :key="item.id" data-astro-cid-vbivu3ot> <div class="modern-card" data-astro-cid-vbivu3ot> <div class="card-left" data-astro-cid-vbivu3ot> <div class="status-indicator" :class="item.status === 'Pendiente' ? 'urgent' : 'upcoming'" data-astro-cid-vbivu3ot></div> <div class="card-details-text" data-astro-cid-vbivu3ot> <h3 x-text="item.concepto" data-astro-cid-vbivu3ot></h3> <div class="date-row" data-astro-cid-vbivu3ot> <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" data-astro-cid-vbivu3ot><rect x="3" y="4" width="18" height="18" rx="2" ry="2" data-astro-cid-vbivu3ot></rect><line x1="16" y1="2" x2="16" y2="6" data-astro-cid-vbivu3ot></line><line x1="8" y1="2" x2="8" y2="6" data-astro-cid-vbivu3ot></line><line x1="3" y1="10" x2="21" y2="10" data-astro-cid-vbivu3ot></line></svg> <span data-astro-cid-vbivu3ot>Vence el <strong x-text="item.fecha" data-astro-cid-vbivu3ot></strong></span> </div> </div> </div> <div class="card-right" data-astro-cid-vbivu3ot> <span class="price" x-text="'$' + item.monto" data-astro-cid-vbivu3ot></span> <button @click="openPayment(item)" class="pay-button" data-astro-cid-vbivu3ot>Pagar</button> </div> </div> </template> </div> </section> </main> <div x-show="showModal" x-cloak class="modal-overlay" data-astro-cid-vbivu3ot> <div class="modal-backdrop" @click="!loading && (showModal = false)" x-show="showModal" x-transition.opacity data-astro-cid-vbivu3ot></div> <div class="modal-sheet" x-show="showModal" x-transition:enter="modal-anim-enter" x-transition:enter-start="modal-anim-start" x-transition:enter-end="modal-anim-end" data-astro-cid-vbivu3ot> <div class="sheet-handle" data-astro-cid-vbivu3ot></div> <div class="sheet-body" data-astro-cid-vbivu3ot> <div x-show="step === 'select-method'" data-astro-cid-vbivu3ot> <div class="payment-header-visual" data-astro-cid-vbivu3ot> <h2 class="grand-total-display" x-text="'$' + selectedItem?.monto" data-astro-cid-vbivu3ot></h2> <span class="concept-tag" x-text="selectedItem?.concepto" data-astro-cid-vbivu3ot></span> </div> <div class="modern-options-list" data-astro-cid-vbivu3ot> <button @click="step = 'card-list'" class="modern-option-item" data-astro-cid-vbivu3ot> <div class="m-option-icon blue-grad" data-astro-cid-vbivu3ot>💳</div> <div class="m-option-info" data-astro-cid-vbivu3ot><strong data-astro-cid-vbivu3ot>Tarjetas Guardadas</strong><span data-astro-cid-vbivu3ot>Usa tus tarjetas registradas</span></div> </button> <button @click="step = 'reference'" class="modern-option-item" data-astro-cid-vbivu3ot> <div class="m-option-icon gold-grad" data-astro-cid-vbivu3ot>🏦</div> <div class="m-option-info" data-astro-cid-vbivu3ot><strong data-astro-cid-vbivu3ot>Referencia Bancaria</strong><span data-astro-cid-vbivu3ot>Pago en efectivo / OXXO</span></div> </button> </div> </div> <div x-show="step === 'card-list'" data-astro-cid-vbivu3ot> <div class="modal-step-header" style="display: flex; align-items: center; gap: 1rem; margin-bottom: 1.5rem;" data-astro-cid-vbivu3ot> <button @click="step = 'select-method'" style="background: #f1f5f9; border: none; width: 35px; height: 35px; border-radius: 50%; cursor: pointer;" data-astro-cid-vbivu3ot>←</button> <h3 style="margin: 0;" data-astro-cid-vbivu3ot>Selecciona tarjeta</h3> </div> <div class="cards-scroller" style="max-height: 300px; overflow-y: auto;" data-astro-cid-vbivu3ot> <template x-for="tarjeta in tarjetas" :key="tarjeta.id" data-astro-cid-vbivu3ot> <div @click="selectedCard = tarjeta; step = 'confirm'" class="modern-card-pill" data-astro-cid-vbivu3ot> <img :src="tarjeta.logo" style="width: 40px;" data-astro-cid-vbivu3ot> <div style="text-align: left; margin-left: 1rem;" data-astro-cid-vbivu3ot> <strong x-text="'•••• ' + tarjeta.terminacion" style="font-size: 1.1rem; color: var(--primary);" data-astro-cid-vbivu3ot></strong> </div> </div> </template> </div> </div> <div x-show="step === 'confirm' || (loading && selectedCard)" data-astro-cid-vbivu3ot> <template x-if="loading" data-astro-cid-vbivu3ot> <div style="padding: 2rem 0;" data-astro-cid-vbivu3ot> <div class="custom-loader" data-astro-cid-vbivu3ot></div> <p data-astro-cid-vbivu3ot>Procesando pago seguro...</p> </div> </template> <template x-if="!loading" data-astro-cid-vbivu3ot> <div class="confirm-summary-ui" data-astro-cid-vbivu3ot> <div class="check-icon-ring" data-astro-cid-vbivu3ot>✓</div> <h3 data-astro-cid-vbivu3ot>Confirmar pago</h3> <div class="summary-box" data-astro-cid-vbivu3ot> <div class="summary-row" data-astro-cid-vbivu3ot><span data-astro-cid-vbivu3ot>Total:</span><strong x-text="'$' + selectedItem?.monto" data-astro-cid-vbivu3ot></strong></div> <div class="summary-row" data-astro-cid-vbivu3ot><span data-astro-cid-vbivu3ot>Método:</span><span x-text="selectedCard?.tipo + ' •' + selectedCard?.terminacion" data-astro-cid-vbivu3ot></span></div> </div> <button @click="processPayment(false)" class="btn-primary-action" data-astro-cid-vbivu3ot>CONFIRMAR</button> <button @click="step = 'card-list'" class="btn-link-action" data-astro-cid-vbivu3ot>Regresar</button> </div> </template> </div> <div x-show="step === 'reference' || (loading && !selectedCard)" data-astro-cid-vbivu3ot> <template x-if="loading" data-astro-cid-vbivu3ot> <div style="padding: 2rem 0;" data-astro-cid-vbivu3ot><div class="custom-loader" data-astro-cid-vbivu3ot></div><p data-astro-cid-vbivu3ot>Generando registro...</p></div> </template> <template x-if="!loading" data-astro-cid-vbivu3ot> <div data-astro-cid-vbivu3ot> <div class="reference-visual-card" data-astro-cid-vbivu3ot> <p class="ref-label" data-astro-cid-vbivu3ot>REFERENCIA DE PAGO</p> <div class="ref-number-box" data-astro-cid-vbivu3ot> <span data-astro-cid-vbivu3ot>0123 4567 8910 1112</span> <div class="barcode-sim" data-astro-cid-vbivu3ot></div> </div> <div class="ref-footer" data-astro-cid-vbivu3ot> <span data-astro-cid-vbivu3ot>Convenio: <strong data-astro-cid-vbivu3ot>CIE 163721</strong></span> <span data-astro-cid-vbivu3ot>Banco: <strong data-astro-cid-vbivu3ot>BBVA</strong></span> </div> </div> <button @click="processPayment(true)" class="btn-primary-action" data-astro-cid-vbivu3ot>GUARDAR Y FINALIZAR</button> <button @click="step = 'select-method'" class="btn-link-action" data-astro-cid-vbivu3ot>Volver</button> </div> </template> </div> </div> </div> </div> </div> ` })} `;
}, "C:/Users/sarah/Documents/GitHub/CBTA/Frond-end/src/pages/Estudiante/Adeudos.astro", void 0);

const $$file = "C:/Users/sarah/Documents/GitHub/CBTA/Frond-end/src/pages/Estudiante/Adeudos.astro";
const $$url = "/Estudiante/Adeudos";

const _page = /*#__PURE__*/Object.freeze(/*#__PURE__*/Object.defineProperty({
  __proto__: null,
  default: $$Adeudos,
  file: $$file,
  url: $$url
}, Symbol.toStringTag, { value: 'Module' }));

const page = () => _page;

export { page };
