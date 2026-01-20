import { e as createComponent, f as createAstro, m as maybeRenderHead, r as renderTemplate } from '../../../chunks/astro/server_6O5fLeT-.mjs';
import 'piccolore';
import 'clsx';
/* empty css                                                  */
export { renderers } from '../../../renderers.mjs';

const $$Astro = createAstro();
const $$ResumenAcademico = createComponent(($$result, $$props, $$slots) => {
  const Astro2 = $$result.createAstro($$Astro, $$props, $$slots);
  Astro2.self = $$ResumenAcademico;
  const {
    periodo,
    totalPagado,
    totalPendiente
  } = Astro2.props;
  return renderTemplate`${maybeRenderHead()}<div class="summary-card" data-astro-cid-ihd72f2f> <h3 class="summary-title" data-astro-cid-ihd72f2f>
Resumen Académico ${periodo} </h3> <div class="summary-row" data-astro-cid-ihd72f2f> <span data-astro-cid-ihd72f2f>Total Pagado</span> <span class="val-ok" data-astro-cid-ihd72f2f>${totalPagado}</span> </div> <div class="summary-row no-border" data-astro-cid-ihd72f2f> <span data-astro-cid-ihd72f2f>Total Pendiente</span> <span class="val-alert" data-astro-cid-ihd72f2f>${totalPendiente}</span> </div> </div> `;
}, "C:/Users/sarah/Documents/GitHub/CBTA/Frond-end/src/pages/Estudiante/components/ResumenAcademico.astro", void 0);

const $$file = "C:/Users/sarah/Documents/GitHub/CBTA/Frond-end/src/pages/Estudiante/components/ResumenAcademico.astro";
const $$url = "/Estudiante/components/ResumenAcademico";

const _page = /*#__PURE__*/Object.freeze(/*#__PURE__*/Object.defineProperty({
  __proto__: null,
  default: $$ResumenAcademico,
  file: $$file,
  url: $$url
}, Symbol.toStringTag, { value: 'Module' }));

const page = () => _page;

export { page };
