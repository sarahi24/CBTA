import { e as createComponent, f as createAstro, m as maybeRenderHead, r as renderTemplate } from './astro/server_6O5fLeT-.mjs';
import 'piccolore';
import 'clsx';
/* empty css                                 */

const $$Astro = createAstro();
const $$PaymentsTable = createComponent(($$result, $$props, $$slots) => {
  const Astro2 = $$result.createAstro($$Astro, $$props, $$slots);
  Astro2.self = $$PaymentsTable;
  const { pagos = [] } = Astro2.props;
  return renderTemplate`${maybeRenderHead()}<div class="payments-section" data-astro-cid-yjbdthf6> <h3 class="payments-title" data-astro-cid-yjbdthf6>Mis Pagos</h3> <div class="payments-table-wrapper" data-astro-cid-yjbdthf6> <table class="payments-table" data-astro-cid-yjbdthf6> <thead data-astro-cid-yjbdthf6> <tr data-astro-cid-yjbdthf6> <th data-astro-cid-yjbdthf6>Concepto</th> <th data-astro-cid-yjbdthf6>Monto</th> <th data-astro-cid-yjbdthf6>Fecha</th> </tr> </thead> <tbody data-astro-cid-yjbdthf6> ${pagos.length ? pagos.map((pago) => renderTemplate`<tr data-astro-cid-yjbdthf6> <td data-astro-cid-yjbdthf6>${pago.concepto}</td> <td class="monto" data-astro-cid-yjbdthf6>${pago.monto}</td> <td class="fecha-celda" data-astro-cid-yjbdthf6>${pago.fecha ?? "\u2014"}</td> </tr>`) : renderTemplate`<tr data-astro-cid-yjbdthf6> <td colspan="3" class="empty-row" data-astro-cid-yjbdthf6>
No hay registros de pagos
</td> </tr>`} </tbody> </table> </div> </div> `;
}, "C:/Users/sarah/Documents/GitHub/CBTA/Frond-end/src/pages/Estudiante/components/PaymentsTable.astro", void 0);

const $$file = "C:/Users/sarah/Documents/GitHub/CBTA/Frond-end/src/pages/Estudiante/components/PaymentsTable.astro";
const $$url = "/Estudiante/components/PaymentsTable";

const _page = /*#__PURE__*/Object.freeze(/*#__PURE__*/Object.defineProperty({
  __proto__: null,
  default: $$PaymentsTable,
  file: $$file,
  url: $$url
}, Symbol.toStringTag, { value: 'Module' }));

export { $$PaymentsTable as $, _page as _ };
