import { e as createComponent, k as renderComponent, r as renderTemplate, m as maybeRenderHead, h as addAttribute } from '../../chunks/astro/server_6O5fLeT-.mjs';
import 'piccolore';
import { $ as $$LayoutEstu } from '../../chunks/LayoutEstu_B58GycIO.mjs';
/* empty css                                       */
export { renderers } from '../../renderers.mjs';

const $$Tarjetas = createComponent(($$result, $$props, $$slots) => {
  const tarjetasIniciales = [
    { id: 1, tipo: "Mastercard", terminacion: "5080", vencimiento: "05/27", logo: "https://upload.wikimedia.org/wikipedia/commons/2/2a/Mastercard-logo.svg" },
    { id: 2, tipo: "Visa", terminacion: "4242", vencimiento: "12/26", logo: "https://upload.wikimedia.org/wikipedia/commons/5/5e/Visa_Inc._logo.svg" }
  ];
  const alumnoBackend = "Pedro Gonzalez Lopez";
  const title = "Mis M\xE9todos de Pago";
  return renderTemplate`${renderComponent($$result, "StudentLayout", $$LayoutEstu, { "title": title, "data-astro-cid-r363qbm5": true }, { "default": ($$result2) => renderTemplate` ${maybeRenderHead()}<div class="page-wrapper"${addAttribute(`{ 
      showModal: false,
      alumno: '${alumnoBackend}',
      tarjetas: [],
      form: { numero: '', titular: '', mes: '', anio: '', cvv: '' },

      // 1. Cargar tarjetas al iniciar
      init() {
        const guardadas = localStorage.getItem('mis_tarjetas');
        if (guardadas) {
          this.tarjetas = JSON.parse(guardadas);
        } else {
          this.tarjetas = ${JSON.stringify(tarjetasIniciales)};
          this.actualizarStorage();
        }
      },

      actualizarStorage() {
        localStorage.setItem('mis_tarjetas', JSON.stringify(this.tarjetas));
      },

      formatCardNumber(value) {
        return value.replace(/\\D/g, '').replace(/(.{4})/g, '$1 ').trim();
      },

      get cardType() {
        const num = this.form.numero.replace(/\\s/g, '');
        if (num.startsWith('4')) return 'Visa';
        if (num.startsWith('5')) return 'Mastercard';
        return '';
      },

      guardarTarjeta() {
        const numLimpio = this.form.numero.replace(/\\s/g, '');
        if (numLimpio.length < 15) return alert('N\xFAmero de tarjeta no v\xE1lido');
        
        const nueva = {
          id: Date.now(),
          tipo: this.cardType || 'Tarjeta',
          terminacion: numLimpio.slice(-4),
          vencimiento: this.form.mes + '/' + this.form.anio,
          logo: this.cardType === 'Visa' 
            ? 'https://upload.wikimedia.org/wikipedia/commons/5/5e/Visa_Inc._logo.svg' 
            : 'https://upload.wikimedia.org/wikipedia/commons/2/2a/Mastercard-logo.svg'
        };
        
        this.tarjetas.push(nueva);
        this.actualizarStorage(); // 2. Guardar permanentemente
        this.showModal = false;
        this.form = { numero: '', titular: '', mes: '', anio: '', cvv: '' };
      },

      eliminarTarjeta(id) {
        this.tarjetas = this.tarjetas.filter(t => t.id !== id);
        this.actualizarStorage(); // 3. Actualizar despu\xE9s de eliminar
      }
    }`, "x-data")} data-astro-cid-r363qbm5> <header class="main-header" data-astro-cid-r363qbm5> <div class="header-content" data-astro-cid-r363qbm5> <div class="user-profile" data-astro-cid-r363qbm5> <div class="avatar" data-astro-cid-r363qbm5> <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" class="svg-icon" data-astro-cid-r363qbm5> <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" data-astro-cid-r363qbm5></path> <circle cx="12" cy="7" r="4" data-astro-cid-r363qbm5></circle> </svg> </div> <div class="welcome-text" data-astro-cid-r363qbm5> <span class="greeting" data-astro-cid-r363qbm5>Métodos de Pago</span> <h1 x-text="'Hola, ' + alumno.split(' ')[0]" data-astro-cid-r363qbm5></h1> </div> </div> <div class="balance-summary" data-astro-cid-r363qbm5> <span class="label" data-astro-cid-r363qbm5>Tarjetas Vinculadas</span> <span class="amount" x-text="tarjetas.length" data-astro-cid-r363qbm5></span> </div> </div> </header> <main class="content-grid" data-astro-cid-r363qbm5> <section class="section-container" data-astro-cid-r363qbm5> <div class="section-header" data-astro-cid-r363qbm5> <h2 class="section-title" data-astro-cid-r363qbm5>Mis Tarjetas</h2> <button @click="showModal = true" class="add-inline-btn" data-astro-cid-r363qbm5>
+ Añadir Nueva
</button> </div> <div class="cards-stack" data-astro-cid-r363qbm5> <template x-for="tarjeta in tarjetas" :key="tarjeta.id" data-astro-cid-r363qbm5> <div class="modern-card" data-astro-cid-r363qbm5> <div class="card-left" data-astro-cid-r363qbm5> <div class="bank-logo-container" data-astro-cid-r363qbm5> <img :src="tarjeta.logo" alt="logo" class="bank-logo" data-astro-cid-r363qbm5> </div> <div class="details" data-astro-cid-r363qbm5> <h3 x-text="'•••• ' + tarjeta.terminacion" data-astro-cid-r363qbm5></h3> <p class="date" data-astro-cid-r363qbm5> <span x-text="tarjeta.tipo" data-astro-cid-r363qbm5></span> | Exp: <span x-text="tarjeta.vencimiento" data-astro-cid-r363qbm5></span> </p> </div> </div> <button @click="eliminarTarjeta(tarjeta.id)" class="delete-btn" data-astro-cid-r363qbm5> <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" data-astro-cid-r363qbm5><path d="M3 6h18m-2 0v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2" data-astro-cid-r363qbm5></path></svg> </button> </div> </template> <template x-if="tarjetas.length === 0" data-astro-cid-r363qbm5> <div class="empty-state" @click="showModal = true" style="text-align: center; padding: 3rem; background: white; border-radius: 24px; cursor: pointer; border: 2px dashed #e2e8f0;" data-astro-cid-r363qbm5> <p style="color: #64748b; font-weight: 600;" data-astro-cid-r363qbm5>No tienes tarjetas registradas. Toca para añadir una.</p> </div> </template> </div> </section> </main> <div x-show="showModal" x-cloak class="modal-overlay" data-astro-cid-r363qbm5> <div class="modal-backdrop" @click="showModal = false" x-show="showModal" x-transition.opacity data-astro-cid-r363qbm5></div> <div class="modal-sheet" x-show="showModal" x-transition:enter="transition ease-out duration-300 transform" x-transition:enter-start="translate-y-full md:translate-y-4 md:opacity-0" x-transition:enter-end="translate-y-0 md:translate-y-0 md:opacity-100" data-astro-cid-r363qbm5> <div class="sheet-handle" data-astro-cid-r363qbm5></div> <div class="sheet-body" data-astro-cid-r363qbm5> <div class="payment-header" data-astro-cid-r363qbm5> <h2 class="grand-total" data-astro-cid-r363qbm5>Nueva Tarjeta</h2> <p class="subtitle" data-astro-cid-r363qbm5>Ingresa los datos de tu método de pago</p> </div> <div class="card-form-grid" data-astro-cid-r363qbm5> <div class="input-field" data-astro-cid-r363qbm5> <label data-astro-cid-r363qbm5>Número de Tarjeta</label> <div class="input-wrapper" data-astro-cid-r363qbm5> <input type="text" x-model="form.numero" @input="form.numero = formatCardNumber($event.target.value)" maxlength="19" inputmode="numeric" placeholder="0000 0000 0000 0000" data-astro-cid-r363qbm5> <span class="card-hint" x-text="cardType" data-astro-cid-r363qbm5></span> </div> </div> <div class="input-field" data-astro-cid-r363qbm5> <label data-astro-cid-r363qbm5>Titular</label> <input type="text" x-model="form.titular" placeholder="NOMBRE COMPLETO" class="uppercase" data-astro-cid-r363qbm5> </div> <div class="input-row" data-astro-cid-r363qbm5> <div class="input-field" data-astro-cid-r363qbm5> <label data-astro-cid-r363qbm5>Vencimiento</label> <div class="expiry-group" data-astro-cid-r363qbm5> <input type="text" x-model="form.mes" placeholder="MM" maxlength="2" inputmode="numeric" data-astro-cid-r363qbm5> <span class="sep" data-astro-cid-r363qbm5>/</span> <input type="text" x-model="form.anio" placeholder="AA" maxlength="2" inputmode="numeric" data-astro-cid-r363qbm5> </div> </div> <div class="input-field" data-astro-cid-r363qbm5> <label data-astro-cid-r363qbm5>CVV</label> <input type="password" x-model="form.cvv" placeholder="***" maxlength="3" inputmode="numeric" data-astro-cid-r363qbm5> </div> </div> <div class="button-group" data-astro-cid-r363qbm5> <button @click="guardarTarjeta()" class="btn-primary-action" data-astro-cid-r363qbm5>VINCULAR TARJETA</button> <button @click="showModal = false" class="btn-secondary-action" data-astro-cid-r363qbm5>Cancelar</button> </div> </div> </div> </div> </div> </div> ` })} `;
}, "C:/Users/sarah/Documents/GitHub/CBTA/Frond-end/src/pages/Estudiante/Tarjetas.astro", void 0);

const $$file = "C:/Users/sarah/Documents/GitHub/CBTA/Frond-end/src/pages/Estudiante/Tarjetas.astro";
const $$url = "/Estudiante/Tarjetas";

const _page = /*#__PURE__*/Object.freeze(/*#__PURE__*/Object.defineProperty({
  __proto__: null,
  default: $$Tarjetas,
  file: $$file,
  url: $$url
}, Symbol.toStringTag, { value: 'Module' }));

const page = () => _page;

export { page };
