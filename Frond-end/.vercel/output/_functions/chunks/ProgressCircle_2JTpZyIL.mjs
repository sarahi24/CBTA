import { e as createComponent, f as createAstro, m as maybeRenderHead, h as addAttribute, r as renderTemplate } from './astro/server_6O5fLeT-.mjs';
import 'piccolore';
import 'clsx';

const $$Astro = createAstro();
const $$ProgressCircle = createComponent(($$result, $$props, $$slots) => {
  const Astro2 = $$result.createAstro($$Astro, $$props, $$slots);
  Astro2.self = $$ProgressCircle;
  const { percentage, label } = Astro2.props;
  const radius = 60;
  const circumference = 2 * Math.PI * radius;
  return renderTemplate`${maybeRenderHead()}<div class="bg-white border border-gray-200 p-4 md:p-8 rounded-3xl flex flex-col items-center justify-center relative min-h-[200px] md:min-h-[250px]"> <p class="absolute top-4 md:top-6 left-4 md:left-6 text-gray-400 font-bold text-xs uppercase">${label}</p> <div class="relative flex items-center justify-center h-24 md:h-36 w-24 md:w-36"> <svg class="h-full w-full transform -rotate-90"> <circle cx="48" cy="48"${addAttribute(radius, "r")} stroke="#f3f4f6" stroke-width="8" fill="transparent"></circle> <circle cx="48" cy="48"${addAttribute(radius, "r")} stroke="#2e594d" stroke-width="8" fill="transparent"${addAttribute(circumference, "stroke-dasharray")}${addAttribute(circumference - circumference * percentage / 100, "stroke-dashoffset")} stroke-linecap="round"></circle> </svg> <div class="absolute text-center"> <span class="text-2xl md:text-4xl font-black text-[#2e594d]">${percentage}%</span> </div> </div> </div>`;
}, "C:/Users/sarah/Documents/GitHub/CBTA/Frond-end/src/pages/Estudiante/components/ProgressCircle.astro", void 0);

const $$file = "C:/Users/sarah/Documents/GitHub/CBTA/Frond-end/src/pages/Estudiante/components/ProgressCircle.astro";
const $$url = "/Estudiante/components/ProgressCircle";

const _page = /*#__PURE__*/Object.freeze(/*#__PURE__*/Object.defineProperty({
  __proto__: null,
  default: $$ProgressCircle,
  file: $$file,
  url: $$url
}, Symbol.toStringTag, { value: 'Module' }));

export { $$ProgressCircle as $, _page as _ };
