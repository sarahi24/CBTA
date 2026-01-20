import { e as createComponent, f as createAstro, r as renderTemplate, l as defineScriptVars, h as addAttribute, u as unescapeHTML, m as maybeRenderHead, k as renderComponent, n as Fragment, o as renderScript } from '../chunks/astro/server_6O5fLeT-.mjs';
import 'piccolore';
import { $ as $$Layout } from '../chunks/Layout_CIeDwhMC.mjs';
import 'clsx';
export { renderers } from '../renderers.mjs';

var __freeze$3 = Object.freeze;
var __defProp$3 = Object.defineProperty;
var __template$3 = (cooked, raw) => __freeze$3(__defProp$3(cooked, "raw", { value: __freeze$3(raw || cooked.slice()) }));
var _a$3;
const $$Astro = createAstro();
const $$CardInfo = createComponent(($$result, $$props, $$slots) => {
  const Astro2 = $$result.createAstro($$Astro, $$props, $$slots);
  Astro2.self = $$CardInfo;
  const { title, value, description, icon, href } = Astro2.props;
  let displayValue = value || "0";
  if ((icon === "pending" || icon === "recaudado") && !value) {
    displayValue = "$0.00";
  }
  const iconColors = {
    students: "text-[#3b7666]",
    pending: "text-red-600",
    recaudado: "text-blue-600",
    concepts: "text-purple-600"
  };
  const getIconSvg = (iconName, sizeClass) => {
    switch (iconName) {
      case "students":
        return `<svg xmlns="http://www.w3.org/2000/svg" class="${sizeClass}" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" /></svg>`;
      case "concepts":
        return `<svg xmlns="http://www.w3.org/2000/svg" class="${sizeClass}" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-6 9l2 2 4-4" /></svg>`;
      case "pending":
        return `<svg xmlns="http://www.w3.org/2000/svg" class="${sizeClass}" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8V6m0 4v2m0 2v2m0 0V4m-7 8a7 7 0 1114 0 7 7 0 01-14 0z" /></svg>`;
      case "recaudado":
        return `<svg xmlns="http://www.w3.org/2000/svg" class="${sizeClass}" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path d="M17 9V7a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2m2 4h10a2 2 0 002-2v-6a2 2 0 00-2-2H9a2 2 0 00-2 2v6a2 2 0 002 2zm7-5a2 2 0 11-4 0 2 2 0 014 0z" /></svg>`;
      default:
        return "";
    }
  };
  return renderTemplate(_a$3 || (_a$3 = __template$3(["", "<a", ' class="bg-white px-4 py-3 rounded-xl border border-gray-200 shadow-lg flex flex-col items-center justify-between h-auto w-full text-center transition-all duration-200 hover:shadow-xl focus:outline-none cursor-pointer"> <div class="flex justify-between items-start w-full mb-1"> <h3 class="text-sm font-medium text-gray-700">', "</h3> <span", ">", '</span> </div> <div class="flex flex-col items-center justify-center w-full my-2"> <p', "", "> ", ' </p> <p class="text-xs text-gray-500 mt-1"', "> ", " </p> </div> </a> <script>(function(){", "\n    const updateCard = () => {\n        const elVal = document.getElementById(`count-${icon}`);\n        const elDesc = document.getElementById(`desc-${icon}`);\n        if (!elVal) return;\n\n        const formatMX = (n) => new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(n);\n\n        if (icon === 'concepts') {\n            const list = JSON.parse(localStorage.getItem('conceptsList') || '[]');\n            elVal.textContent = String(list.length);\n            if (elDesc) elDesc.textContent = list.length === 1 ? \"1 Concepto\" : `${list.length} Conceptos`;\n        }\n\n        if (icon === 'pending' || icon === 'recaudado') {\n            const charges = JSON.parse(localStorage.getItem('chargesList') || '[]');\n            if (icon === 'recaudado') {\n                const paid = charges.filter(c => ['paid', 'pagado'].includes(String(c.status).toLowerCase()));\n                elVal.textContent = formatMX(paid.reduce((s, c) => s + (parseFloat(c.amount) || 0), 0));\n                if (elDesc) elDesc.textContent = `${paid.length} Pagos`;\n            } else {\n                const pending = charges.filter(c => !['paid', 'pagado'].includes(String(c.status).toLowerCase()));\n                elVal.textContent = formatMX(pending.reduce((s, c) => s + (parseFloat(c.amount) || 0), 0));\n                if (elDesc) elDesc.textContent = `${pending.length} Adeudos`;\n            }\n        }\n\n        if (icon === 'students') {\n            const students = JSON.parse(localStorage.getItem('studentsList') || '[]');\n            elVal.textContent = String(students.length);\n            const hoy = new Date();\n            if (elDesc) elDesc.textContent = hoy.toLocaleDateString('es-MX');\n        }\n    };\n\n    updateCard();\n    window.addEventListener('storage', updateCard);\n    window.addEventListener('conceptsUpdated', updateCard);\n    window.addEventListener('chargesUpdated', updateCard);\n})();<\/script>"], ["", "<a", ' class="bg-white px-4 py-3 rounded-xl border border-gray-200 shadow-lg flex flex-col items-center justify-between h-auto w-full text-center transition-all duration-200 hover:shadow-xl focus:outline-none cursor-pointer"> <div class="flex justify-between items-start w-full mb-1"> <h3 class="text-sm font-medium text-gray-700">', "</h3> <span", ">", '</span> </div> <div class="flex flex-col items-center justify-center w-full my-2"> <p', "", "> ", ' </p> <p class="text-xs text-gray-500 mt-1"', "> ", " </p> </div> </a> <script>(function(){", "\n    const updateCard = () => {\n        const elVal = document.getElementById(\\`count-\\${icon}\\`);\n        const elDesc = document.getElementById(\\`desc-\\${icon}\\`);\n        if (!elVal) return;\n\n        const formatMX = (n) => new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(n);\n\n        if (icon === 'concepts') {\n            const list = JSON.parse(localStorage.getItem('conceptsList') || '[]');\n            elVal.textContent = String(list.length);\n            if (elDesc) elDesc.textContent = list.length === 1 ? \"1 Concepto\" : \\`\\${list.length} Conceptos\\`;\n        }\n\n        if (icon === 'pending' || icon === 'recaudado') {\n            const charges = JSON.parse(localStorage.getItem('chargesList') || '[]');\n            if (icon === 'recaudado') {\n                const paid = charges.filter(c => ['paid', 'pagado'].includes(String(c.status).toLowerCase()));\n                elVal.textContent = formatMX(paid.reduce((s, c) => s + (parseFloat(c.amount) || 0), 0));\n                if (elDesc) elDesc.textContent = \\`\\${paid.length} Pagos\\`;\n            } else {\n                const pending = charges.filter(c => !['paid', 'pagado'].includes(String(c.status).toLowerCase()));\n                elVal.textContent = formatMX(pending.reduce((s, c) => s + (parseFloat(c.amount) || 0), 0));\n                if (elDesc) elDesc.textContent = \\`\\${pending.length} Adeudos\\`;\n            }\n        }\n\n        if (icon === 'students') {\n            const students = JSON.parse(localStorage.getItem('studentsList') || '[]');\n            elVal.textContent = String(students.length);\n            const hoy = new Date();\n            if (elDesc) elDesc.textContent = hoy.toLocaleDateString('es-MX');\n        }\n    };\n\n    updateCard();\n    window.addEventListener('storage', updateCard);\n    window.addEventListener('conceptsUpdated', updateCard);\n    window.addEventListener('chargesUpdated', updateCard);\n})();<\/script>"])), maybeRenderHead(), addAttribute(href, "href"), title, addAttribute(["flex-shrink-0", [iconColors[icon]]], "class:list"), unescapeHTML(getIconSvg(icon, "w-5 h-5")), addAttribute(["text-2xl md:text-3xl font-bold", iconColors[icon]], "class:list"), addAttribute(`count-${icon}`, "id"), displayValue, addAttribute(`desc-${icon}`, "id"), description, defineScriptVars({ icon }));
}, "C:/Users/sarah/Documents/GitHub/CBTA/Frond-end/src/components/CardInfo.astro", void 0);

var __freeze$2 = Object.freeze;
var __defProp$2 = Object.defineProperty;
var __template$2 = (cooked, raw) => __freeze$2(__defProp$2(cooked, "raw", { value: __freeze$2(cooked.slice()) }));
var _a$2;
const $$ChartLine = createComponent(($$result, $$props, $$slots) => {
  return renderTemplate`${renderComponent($$result, "Fragment", Fragment, {}, { "default": ($$result2) => renderTemplate(_a$2 || (_a$2 = __template$2(["", '<div class="relative h-96 w-full"><canvas id="chartLine"></canvas></div>', `<script>
    // Funci\xF3n global para que pueda ser llamada desde fuera si es necesario
    window.updateChartLine = function() {
      const ctx = document.getElementById('chartLine');
      if (!ctx) return;

      const currentYear = 2025;
      const months = ["Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sep", "Oct", "Nov", "Dic"];
      const recaudado = new Array(12).fill(0);
      const pendientes = new Array(12).fill(0);
      const estudiantes = new Array(12).fill(0);

      try {
        const charges = JSON.parse(localStorage.getItem('chargesList') || '[]');

        charges.forEach(c => {
          const date = new Date(c.createdAt || c.date);
          if (date.getFullYear() === currentYear) {
            const m = date.getMonth();
            const amount = parseFloat(c.amount) || 0;
            const status = String(c.status).toLowerCase();

            if (['paid', 'pagado'].includes(status)) {
              recaudado[m] += amount;
            } else {
              pendientes[m] += amount;
            }
            estudiantes[m] += 1;
          }
        });

        if (window.myLineChart) window.myLineChart.destroy();

        window.myLineChart = new Chart(ctx, {
          type: 'line',
          data: {
            labels: months,
            datasets: [
              {
                label: 'Recaudado ($)',
                data: recaudado,
                borderColor: '#2E584C',
                backgroundColor: 'rgba(46, 88, 76, 0.1)',
                tension: 0,
                fill: true,
                yAxisID: 'y'
              },
              {
                label: 'Pendiente ($)',
                data: pendientes,
                borderColor: '#dc2626',
                borderDash: [5, 5],
                tension: 0,
                yAxisID: 'y'
              }
            ]
          },
          options: {
            responsive: true,
            maintainAspectRatio: false,
            scales: {
              y: { beginAtZero: true, ticks: { callback: v => '$' + v.toLocaleString() } }
            }
          }
        });
      } catch (e) { console.error(e); }
    };

    // Ejecuci\xF3n inmediata y tras carga
    document.addEventListener('DOMContentLoaded', window.updateChartLine);
    window.addEventListener('storage', window.updateChartLine);
    // Escuchar eventos personalizados de tus tarjetas
    window.addEventListener('chargesUpdated', window.updateChartLine);
  <\/script>`])), maybeRenderHead(), renderScript($$result2, "C:/Users/sarah/Documents/GitHub/CBTA/Frond-end/src/components/ChartLine.astro?astro&type=script&index=0&lang.ts")) })}`;
}, "C:/Users/sarah/Documents/GitHub/CBTA/Frond-end/src/components/ChartLine.astro", void 0);

var __freeze$1 = Object.freeze;
var __defProp$1 = Object.defineProperty;
var __template$1 = (cooked, raw) => __freeze$1(__defProp$1(cooked, "raw", { value: __freeze$1(raw || cooked.slice()) }));
var _a$1;
const $$ChartDonut = createComponent(($$result, $$props, $$slots) => {
  return renderTemplate`${renderComponent($$result, "Fragment", Fragment, {}, { "default": ($$result2) => renderTemplate(_a$1 || (_a$1 = __template$1(["", `<div id="donut-wrapper" class="w-full flex flex-col items-center"><div id="donut-container" class="relative w-full max-w-xs aspect-square"><canvas id="chartDonut"></canvas><div class="absolute inset-0 flex flex-col justify-center items-center pointer-events-none"><span id="donut-pct" class="text-4xl font-extrabold text-[#2e594d]">0%</span><span class="text-sm font-medium text-gray-500">Recaudado</span></div></div><div id="meta-total-container" class="mt-4 py-2 border-t border-gray-200 w-full text-center"><p class="text-lg font-semibold text-gray-700">
Meta Total: <span id="meta-monto-dinamico" class="text-[#3b7666] font-bold">$0.00</span></p></div><div id="donut-empty" class="hidden text-gray-400 italic py-10">
Sin datos de cargos registrados
</div></div><script>
    window.updateChartDonut = function() {
      const ctx = document.getElementById('chartDonut');
      const metaEl = document.getElementById('meta-monto-dinamico');
      if (!ctx) return;

      try {
        // 1. Obtener la lista de cargos (la misma fuente que tus tarjetas)
        const charges = JSON.parse(localStorage.getItem('chargesList') || '[]');
        
        // 2. Calcular totales
        // Sumamos TODO (pagado y pendiente) para la Meta Total
        const totalMeta = charges.reduce((s, c) => s + (parseFloat(c.amount) || 0), 0);
        
        const paid = charges
          .filter(c => ['paid', 'pagado'].includes(String(c.status).toLowerCase()))
          .reduce((s, c) => s + (parseFloat(c.amount) || 0), 0);

        const pending = totalMeta - paid;

        // 3. Actualizar el texto de Meta Total con formato de moneda
        if (metaEl) {
          metaEl.textContent = new Intl.NumberFormat('es-MX', { 
            style: 'currency', 
            currency: 'MXN' 
          }).format(totalMeta);
        }

        // 4. Manejo de estados visuales
        const container = document.getElementById('donut-container');
        const empty = document.getElementById('donut-empty');
        const metaContainer = document.getElementById('meta-total-container');

        if (totalMeta === 0) {
          container.classList.add('hidden');
          metaContainer.classList.add('hidden');
          empty.classList.remove('hidden');
          return;
        } else {
          container.classList.remove('hidden');
          metaContainer.classList.remove('hidden');
          empty.classList.add('hidden');
        }

        // 5. Actualizar porcentaje central
        const pct = ((paid / totalMeta) * 100).toFixed(1);
        document.getElementById('donut-pct').textContent = pct + '%';

        // 6. Dibujar o refrescar la gr\xE1fica
        if (window.myDonutChart) window.myDonutChart.destroy();

        window.myDonutChart = new Chart(ctx, {
          type: 'doughnut',
          data: {
            labels: ['Recaudado (Pagado)', 'Pendiente (Adeudo)'],
            datasets: [{
              data: [paid, pending],
              backgroundColor: ['#2E584C', '#dc2626'], // Verde y Rojo
              borderWidth: 0,
              hoverOffset: 10
            }]
          },
          options: {
            cutout: '80%',
            plugins: { 
              legend: { position: 'bottom', labels: { usePointStyle: true } },
              tooltip: {
                callbacks: {
                  label: (context) => {
                    const val = context.parsed.toLocaleString('es-MX', { style: 'currency', currency: 'MXN' });
                    return \`\${context.label}: \${val}\`;
                  }
                }
              }
            }
          }
        });
      } catch (e) { 
        console.error("Error en Donut Din\xE1mico:", e); 
      }
    };

    // Ejecuci\xF3n inicial y escucha de cambios
    document.addEventListener('DOMContentLoaded', () => setTimeout(window.updateChartDonut, 150));
    window.addEventListener('storage', window.updateChartDonut);
    window.addEventListener('chargesUpdated', window.updateChartDonut);
  <\/script>`], ["", `<div id="donut-wrapper" class="w-full flex flex-col items-center"><div id="donut-container" class="relative w-full max-w-xs aspect-square"><canvas id="chartDonut"></canvas><div class="absolute inset-0 flex flex-col justify-center items-center pointer-events-none"><span id="donut-pct" class="text-4xl font-extrabold text-[#2e594d]">0%</span><span class="text-sm font-medium text-gray-500">Recaudado</span></div></div><div id="meta-total-container" class="mt-4 py-2 border-t border-gray-200 w-full text-center"><p class="text-lg font-semibold text-gray-700">
Meta Total: <span id="meta-monto-dinamico" class="text-[#3b7666] font-bold">$0.00</span></p></div><div id="donut-empty" class="hidden text-gray-400 italic py-10">
Sin datos de cargos registrados
</div></div><script>
    window.updateChartDonut = function() {
      const ctx = document.getElementById('chartDonut');
      const metaEl = document.getElementById('meta-monto-dinamico');
      if (!ctx) return;

      try {
        // 1. Obtener la lista de cargos (la misma fuente que tus tarjetas)
        const charges = JSON.parse(localStorage.getItem('chargesList') || '[]');
        
        // 2. Calcular totales
        // Sumamos TODO (pagado y pendiente) para la Meta Total
        const totalMeta = charges.reduce((s, c) => s + (parseFloat(c.amount) || 0), 0);
        
        const paid = charges
          .filter(c => ['paid', 'pagado'].includes(String(c.status).toLowerCase()))
          .reduce((s, c) => s + (parseFloat(c.amount) || 0), 0);

        const pending = totalMeta - paid;

        // 3. Actualizar el texto de Meta Total con formato de moneda
        if (metaEl) {
          metaEl.textContent = new Intl.NumberFormat('es-MX', { 
            style: 'currency', 
            currency: 'MXN' 
          }).format(totalMeta);
        }

        // 4. Manejo de estados visuales
        const container = document.getElementById('donut-container');
        const empty = document.getElementById('donut-empty');
        const metaContainer = document.getElementById('meta-total-container');

        if (totalMeta === 0) {
          container.classList.add('hidden');
          metaContainer.classList.add('hidden');
          empty.classList.remove('hidden');
          return;
        } else {
          container.classList.remove('hidden');
          metaContainer.classList.remove('hidden');
          empty.classList.add('hidden');
        }

        // 5. Actualizar porcentaje central
        const pct = ((paid / totalMeta) * 100).toFixed(1);
        document.getElementById('donut-pct').textContent = pct + '%';

        // 6. Dibujar o refrescar la gr\xE1fica
        if (window.myDonutChart) window.myDonutChart.destroy();

        window.myDonutChart = new Chart(ctx, {
          type: 'doughnut',
          data: {
            labels: ['Recaudado (Pagado)', 'Pendiente (Adeudo)'],
            datasets: [{
              data: [paid, pending],
              backgroundColor: ['#2E584C', '#dc2626'], // Verde y Rojo
              borderWidth: 0,
              hoverOffset: 10
            }]
          },
          options: {
            cutout: '80%',
            plugins: { 
              legend: { position: 'bottom', labels: { usePointStyle: true } },
              tooltip: {
                callbacks: {
                  label: (context) => {
                    const val = context.parsed.toLocaleString('es-MX', { style: 'currency', currency: 'MXN' });
                    return \\\`\\\${context.label}: \\\${val}\\\`;
                  }
                }
              }
            }
          }
        });
      } catch (e) { 
        console.error("Error en Donut Din\xE1mico:", e); 
      }
    };

    // Ejecuci\xF3n inicial y escucha de cambios
    document.addEventListener('DOMContentLoaded', () => setTimeout(window.updateChartDonut, 150));
    window.addEventListener('storage', window.updateChartDonut);
    window.addEventListener('chargesUpdated', window.updateChartDonut);
  <\/script>`])), maybeRenderHead()) })}`;
}, "C:/Users/sarah/Documents/GitHub/CBTA/Frond-end/src/components/ChartDonut.astro", void 0);

var __freeze = Object.freeze;
var __defProp = Object.defineProperty;
var __template = (cooked, raw) => __freeze(__defProp(cooked, "raw", { value: __freeze(raw || cooked.slice()) }));
var _a;
const $$ConceptsTable = createComponent(($$result, $$props, $$slots) => {
  return renderTemplate(_a || (_a = __template(["", `<div class="overflow-x-auto bg-white rounded-2xl shadow-sm border border-gray-100"> <table class="min-w-full divide-y divide-gray-200"> <thead class="bg-[#2E594D]"> <tr> <th class="px-6 py-4 text-left text-xs font-bold text-white uppercase tracking-wider">Concepto</th> <th class="px-6 py-4 text-left text-xs font-bold text-white uppercase tracking-wider">Monto</th> <th class="px-6 py-4 text-left text-xs font-bold text-white uppercase tracking-wider">Estado</th> <th class="px-6 py-4 text-left text-xs font-bold text-white uppercase tracking-wider">Fecha Inicio</th> <th class="px-6 py-4 text-left text-xs font-bold text-white uppercase tracking-wider">Fecha Fin</th> </tr> </thead> <tbody id="dashboard-concepts-body" class="bg-white divide-y divide-gray-100"></tbody> </table> </div> <script>
  function updateDashboardTable() {
    const tbody = document.getElementById('dashboard-concepts-body');
    if (!tbody) return;

    try {
      const concepts = JSON.parse(localStorage.getItem('conceptsList') || '[]');
      const formatCurrency = (n) => new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(n);

      const formatDate = (dateStr) => {
        if (!dateStr || dateStr === '---') return '---';
        return dateStr.split('T')[0];
      };

      if (concepts.length === 0) {
        tbody.innerHTML = \`<tr><td colspan="5" class="px-6 py-10 text-center text-gray-400">No hay conceptos registrados</td></tr>\`;
        return;
      }

      tbody.innerHTML = concepts.map(concept => {
        const isInactive = concept.status === 'inactive' || concept.status === 'Finalizado';
        // Badge de estado din\xE1mico
        const badgeClass = isInactive 
          ? 'bg-red-50 text-red-600 border border-red-100' 
          : 'bg-green-50 text-green-600 border border-green-100';
        
        const rawInicio = concept.fechaInicio || concept.fecha || concept.startDate || concept.createdAt || '---';
        const rawFin = concept.fechaFin || concept.endDate || '---';
        
        return \`
          <tr class="hover:bg-gray-50/50 transition-colors">
            <td class="px-6 py-4 whitespace-nowrap text-sm font-bold text-[#2E594D] uppercase">
              \${concept.title || concept.name || 'S/N'}
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-sm font-semibold text-gray-700">
              \${formatCurrency(concept.amount || 0)}
            </td>
            <td class="px-6 py-4 whitespace-nowrap">
              <span class="px-3 py-1 text-[10px] font-extrabold rounded-full \${badgeClass}">
                \${isInactive ? 'FINALIZADO' : 'ACTIVO'}
              </span>
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
              \${formatDate(rawInicio)}
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
              \${formatDate(rawFin)}
            </td>
          </tr>
        \`;
      }).join('');

    } catch (e) {
      console.error("Error al actualizar tabla:", e);
    }
  }

  document.addEventListener('DOMContentLoaded', updateDashboardTable);
  window.addEventListener('storage', updateDashboardTable);
  window.addEventListener('conceptsUpdated', updateDashboardTable);
<\/script>`], ["", `<div class="overflow-x-auto bg-white rounded-2xl shadow-sm border border-gray-100"> <table class="min-w-full divide-y divide-gray-200"> <thead class="bg-[#2E594D]"> <tr> <th class="px-6 py-4 text-left text-xs font-bold text-white uppercase tracking-wider">Concepto</th> <th class="px-6 py-4 text-left text-xs font-bold text-white uppercase tracking-wider">Monto</th> <th class="px-6 py-4 text-left text-xs font-bold text-white uppercase tracking-wider">Estado</th> <th class="px-6 py-4 text-left text-xs font-bold text-white uppercase tracking-wider">Fecha Inicio</th> <th class="px-6 py-4 text-left text-xs font-bold text-white uppercase tracking-wider">Fecha Fin</th> </tr> </thead> <tbody id="dashboard-concepts-body" class="bg-white divide-y divide-gray-100"></tbody> </table> </div> <script>
  function updateDashboardTable() {
    const tbody = document.getElementById('dashboard-concepts-body');
    if (!tbody) return;

    try {
      const concepts = JSON.parse(localStorage.getItem('conceptsList') || '[]');
      const formatCurrency = (n) => new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(n);

      const formatDate = (dateStr) => {
        if (!dateStr || dateStr === '---') return '---';
        return dateStr.split('T')[0];
      };

      if (concepts.length === 0) {
        tbody.innerHTML = \\\`<tr><td colspan="5" class="px-6 py-10 text-center text-gray-400">No hay conceptos registrados</td></tr>\\\`;
        return;
      }

      tbody.innerHTML = concepts.map(concept => {
        const isInactive = concept.status === 'inactive' || concept.status === 'Finalizado';
        // Badge de estado din\xE1mico
        const badgeClass = isInactive 
          ? 'bg-red-50 text-red-600 border border-red-100' 
          : 'bg-green-50 text-green-600 border border-green-100';
        
        const rawInicio = concept.fechaInicio || concept.fecha || concept.startDate || concept.createdAt || '---';
        const rawFin = concept.fechaFin || concept.endDate || '---';
        
        return \\\`
          <tr class="hover:bg-gray-50/50 transition-colors">
            <td class="px-6 py-4 whitespace-nowrap text-sm font-bold text-[#2E594D] uppercase">
              \\\${concept.title || concept.name || 'S/N'}
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-sm font-semibold text-gray-700">
              \\\${formatCurrency(concept.amount || 0)}
            </td>
            <td class="px-6 py-4 whitespace-nowrap">
              <span class="px-3 py-1 text-[10px] font-extrabold rounded-full \\\${badgeClass}">
                \\\${isInactive ? 'FINALIZADO' : 'ACTIVO'}
              </span>
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
              \\\${formatDate(rawInicio)}
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
              \\\${formatDate(rawFin)}
            </td>
          </tr>
        \\\`;
      }).join('');

    } catch (e) {
      console.error("Error al actualizar tabla:", e);
    }
  }

  document.addEventListener('DOMContentLoaded', updateDashboardTable);
  window.addEventListener('storage', updateDashboardTable);
  window.addEventListener('conceptsUpdated', updateDashboardTable);
<\/script>`])), maybeRenderHead());
}, "C:/Users/sarah/Documents/GitHub/CBTA/Frond-end/src/components/ConceptsTable.astro", void 0);

const $$Dashboard = createComponent(($$result, $$props, $$slots) => {
  const pageTitle = "Dashboard - SIGE";
  return renderTemplate`${renderComponent($$result, "Layout", $$Layout, { "title": pageTitle }, { "default": ($$result2) => renderTemplate` ${maybeRenderHead()}<div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8"> <header class="flex items-center gap-4 mb-6 md:mb-8 border-b pb-4 mt-6"> <svg xmlns="http://www.w3.org/2000/svg" class="text-gray-700" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"> <path d="M4 4h8v4h-8zM4 12h8v8h-8zM16 4h4v8h-4zM16 16h4v4h-4z"></path> </svg> <h1 class="text-2xl md:text-3xl font-bold text-gray-800">Resumen General</h1> </header>  <section class="flex flex-row space-x-4 mb-8 overflow-x-auto pb-4"> ${renderComponent($$result2, "CardInfo", $$CardInfo, { "title": "Total Estudiantes", "icon": "students", "href": "/estudiante_lista" })} ${renderComponent($$result2, "CardInfo", $$CardInfo, { "title": "Pagos Pendientes", "icon": "pending", "href": "/concepts" })} ${renderComponent($$result2, "CardInfo", $$CardInfo, { "title": "Total Recaudado", "icon": "recaudado", "href": "/payments" })} </section>  <section class="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-8"> <div class="bg-white p-6 rounded-xl shadow-lg border border-gray-100 lg:col-span-2"> <h2 class="text-xl font-bold text-gray-800 mb-4 border-b pb-3">Evolución de Pagos</h2> ${renderComponent($$result2, "ChartLine", $$ChartLine, {})} </div> <div class="bg-white p-6 rounded-xl shadow-lg border border-gray-100 lg:col-span-1"> <h2 class="text-xl font-bold text-gray-800 mb-4 text-center border-b pb-3">Estado de Cobros</h2> ${renderComponent($$result2, "ChartDonut", $$ChartDonut, {})} </div> </section>  <section class="bg-white p-6 rounded-xl shadow-lg border border-gray-100 mb-8"> <h2 class="text-xl font-bold text-gray-800 mb-6 border-b pb-3">Conceptos Registrados</h2> ${renderComponent($$result2, "ConceptsTable", $$ConceptsTable, {})} </section> </div> ` })}`;
}, "C:/Users/sarah/Documents/GitHub/CBTA/Frond-end/src/pages/Dashboard.astro", void 0);

const $$file = "C:/Users/sarah/Documents/GitHub/CBTA/Frond-end/src/pages/Dashboard.astro";
const $$url = "/Dashboard";

const _page = /*#__PURE__*/Object.freeze(/*#__PURE__*/Object.defineProperty({
    __proto__: null,
    default: $$Dashboard,
    file: $$file,
    url: $$url
}, Symbol.toStringTag, { value: 'Module' }));

const page = () => _page;

export { page };
