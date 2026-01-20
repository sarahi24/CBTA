import { e as createComponent, f as createAstro, m as maybeRenderHead, h as addAttribute, p as renderSlot, r as renderTemplate } from './astro/server_6O5fLeT-.mjs';
import 'piccolore';
import 'clsx';
/* empty css                            */

const $$Astro = createAstro();
const $$StatCard = createComponent(($$result, $$props, $$slots) => {
  const Astro2 = $$result.createAstro($$Astro, $$props, $$slots);
  Astro2.self = $$StatCard;
  const { title, amount, subtitle, type = "default" } = Astro2.props;
  return renderTemplate`${maybeRenderHead()}<div${addAttribute(`card-container ${type}`, "class")} data-astro-cid-mujzxpny> <div class="card-header" data-astro-cid-mujzxpny> <span class="label" data-astro-cid-mujzxpny>${title}</span> <div class="icon-wrapper" data-astro-cid-mujzxpny> ${renderSlot($$result, $$slots["icon"])} </div> </div> <div class="card-body" data-astro-cid-mujzxpny> <h2 class="amount" data-astro-cid-mujzxpny>${amount}</h2> </div> <div class="card-footer" data-astro-cid-mujzxpny> <p class="subtitle" data-astro-cid-mujzxpny>${subtitle}</p> </div> </div> `;
}, "C:/Users/sarah/Documents/GitHub/CBTA/Frond-end/src/pages/Estudiante/components/StatCard.astro", void 0);

const $$file = "C:/Users/sarah/Documents/GitHub/CBTA/Frond-end/src/pages/Estudiante/components/StatCard.astro";
const $$url = "/Estudiante/components/StatCard";

const _page = /*#__PURE__*/Object.freeze(/*#__PURE__*/Object.defineProperty({
  __proto__: null,
  default: $$StatCard,
  file: $$file,
  url: $$url
}, Symbol.toStringTag, { value: 'Module' }));

export { $$StatCard as $, _page as _ };
