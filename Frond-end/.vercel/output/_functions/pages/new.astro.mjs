import { e as createComponent, k as renderComponent, r as renderTemplate, m as maybeRenderHead } from '../chunks/astro/server_6O5fLeT-.mjs';
import 'piccolore';
import { $ as $$Layout } from '../chunks/Layout_CIeDwhMC.mjs';
/* empty css                               */
export { renderers } from '../renderers.mjs';

var __freeze = Object.freeze;
var __defProp = Object.defineProperty;
var __template = (cooked, raw) => __freeze(__defProp(cooked, "raw", { value: __freeze(raw || cooked.slice()) }));
var _a;
const $$New = createComponent(($$result, $$props, $$slots) => {
  return renderTemplate`${renderComponent($$result, "Layout", $$Layout, { "title": "Crear Concepto - CBTA 71", "data-astro-cid-h4ugnbzq": true }, { "default": ($$result2) => renderTemplate(_a || (_a = __template(['  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css"> <script src="https://cdn.jsdelivr.net/npm/alpinejs@3.x.x/dist/cdn.min.js" defer><\/script> ', `<div class="p-4 sm:p-6 min-h-screen font-sans" data-astro-cid-h4ugnbzq> <div x-data="{ 
        /* Variables de estado y datos */
        careers: [
            // LISTA DE CARRERAS FINAL
            { id: 'TAG-E', name: 'T\xE9cnico Agropecuario' },
            { id: 'TOF', name: 'T\xE9c. en Ofim\xE1tica' },
            { id: 'TEM', name: 'T\xE9c. en Adm\xF3n. de Emp.' },
            { id: 'TAG-M', name: 'T\xE9c. Agropecuario (Mixta)' },
            { id: 'TRH', name: 'T\xE9c. Adm\xF3n. R. Humanos (Mixta)' },
        ],
          
        // SEMESTRES MANTENIDOS EN 10:
        semesters: Array.from({length: 10}, (_, i) => ({ id: (i+1).toString(), name: (i+1) + '\xB0 Sem' })),

        allStudents: [],

        formData: {
            id: null,
            title: '',
            amount: 0,
            description: '',
            status: 'active',
            
            allStudents: true,
            selectedCareers: [],
            selectedSemesters: [],
            selectedSpecificStudents: []
        },
        searchTerm: '',
        errorMessage: '',
        
        // Funciones
        initPage() {
          this.loadStudents();
          const urlParams = new URLSearchParams(window.location.search);
          const rawConcept = localStorage.getItem('editingConcept');
          
          if (urlParams.has('edit') && rawConcept) {
              try {
                  const concept = JSON.parse(rawConcept);
                  this.populateForm(concept);
              } catch (e) {
                  console.error('Error cargando concepto de edici\xF3n:', e);
              }
          } else {
              localStorage.removeItem('editingConcept');
          }
        },

        loadStudents() {
          try {
            const raw = localStorage.getItem('studentsList');
            if (raw) {
              const parsed = JSON.parse(raw);
              this.allStudents = parsed.map(s => {
                  // 1. CONCATENAR NOMBRE COMPLETO
                  const fullName = [
                      String(s.nombre ?? '').trim(),
                      String(s.apellidoP ?? s.apellidoPaterno ?? '').trim(),
                      String(s.apellidoM ?? s.apellidoMaterno ?? '').trim()
                  ].filter(n => n).join(' '); 
                  
                  return {
                      // 2. CORRECCI\xD3N: PRIORIZAR numControl sobre el ID largo (s.id)
                      id: String(s.numControl ?? s.id ?? ''), 
                      // Nombre Completo
                      name: fullName, 
                      career: String(s.carrera ?? s.career ?? ''),
                      semester: String(s.semestre ?? s.semestre ?? '')
                  };
              }).filter(s => s.id);
              return;
            }
          } catch (e) { console.warn(e); }
          this.allStudents = [];
        },

        populateForm(concept) {
          this.formData.id = concept.id;
          this.formData.title = concept.title;
          this.formData.amount = concept.amount;
          this.formData.description = concept.description || '';
          this.formData.status = concept.status;

          if (concept.scopeRules) {
              this.formData.allStudents = concept.scopeRules.allStudents;
              this.formData.selectedCareers = concept.scopeRules.careers || [];
              this.formData.selectedSemesters = concept.scopeRules.semesters || [];
              
              if (Array.isArray(concept.scopeRules.specificStudents)) {
                  this.formData.selectedSpecificStudents = concept.scopeRules.specificStudents.map(id => {
                      const student = this.allStudents.find(s => String(s.id) === String(id));
                      return student ? {id: student.id, name: student.name} : {id: String(id), name: 'ID: ' + id};
                  });
              }
          }
        },
        
        toggleSpecificStudent(student) {
          const index = this.formData.selectedSpecificStudents.findIndex(s => s.id === student.id);
          if (index === -1) {
            this.formData.selectedSpecificStudents.push({id: student.id, name: student.name});
          } else {
            this.formData.selectedSpecificStudents.splice(index, 1);
          }
          this.searchTerm = '';
        },

        get filteredStudents() {
          if (!this.searchTerm) return [];
          const searchLower = this.searchTerm.toLowerCase();
          return this.allStudents.filter(student =>
            // Busca por Nombre Completo (student.name) o Matr\xEDcula (student.id)
            student.name.toLowerCase().includes(searchLower) ||
            student.id.includes(searchLower)
          ).slice(0, 5);
        },

        removeSpecificStudent(studentId) {
          this.formData.selectedSpecificStudents = this.formData.selectedSpecificStudents.filter(s => s.id !== studentId);
        },
        
        submitForm() {
          this.errorMessage = '';
          
          // Validaci\xF3n b\xE1sica
          if (!this.formData.title || !this.formData.amount || parseFloat(this.formData.amount) <= 0) {
            this.errorMessage = '\u26A0\uFE0F Rellene T\xEDtulo y Monto (mayor a $0).';
            return;
          }

          // Validaci\xF3n de alcance restringido
          if (!this.formData.allStudents) {
              const hasCareer = this.formData.selectedCareers.length > 0;
              const hasSemester = this.formData.selectedSemesters.length > 0;
              const hasSpecific = this.formData.selectedSpecificStudents.length > 0;

              if (!hasCareer && !hasSemester && !hasSpecific) {
                  this.errorMessage = '\u26A0\uFE0F Seleccione al menos una Carrera, Semestre o Alumno.';
                  return;
              }
          }
          
          const newConcept = {
            id: this.formData.id || Date.now().toString(),
            title: this.formData.title,
            amount: parseFloat(this.formData.amount),
            status: this.formData.status,
            description: this.formData.description,
            scopeRules: {
              allStudents: this.formData.allStudents,
              careers: this.formData.selectedCareers,
              semesters: this.formData.selectedSemesters,
              specificStudents: this.formData.selectedSpecificStudents.map(s => s.id)
            },
            createdAt: new Date().toISOString()
          };

          try {
            let stored = JSON.parse(localStorage.getItem('conceptsList') || '[]');
            if (this.formData.id) {
              stored = stored.map(c => c.id === this.formData.id ? newConcept : c);
            } else {
              stored.unshift(newConcept);
            }
            localStorage.setItem('conceptsList', JSON.stringify(stored));
            
            let assignationMessage = '';
            if (newConcept.status === 'active') {
                try {
                    const assignedCount = window.assignConceptToScope ? window.assignConceptToScope(newConcept) : 0;
                    assignationMessage = \`\u2713 Concepto guardado y aplicado a \${assignedCount} alumnos.\`;
                } catch (assignError) {
                    console.error('Error en cobro autom\xE1tico:', assignError);
                    assignationMessage = '\u2713 Concepto guardado pero hubo un error al aplicar el cobro.';
                }
            } else {
                assignationMessage = '\u2713 Concepto guardado como Inactivo.';
            }
            
            localStorage.removeItem('editingConcept');
            this.errorMessage = assignationMessage + ' Redirigiendo...';
            
            setTimeout(() => { window.location.href = '/concepts'; }, 2000);
          } catch(e) {
            this.errorMessage = '\u274C Error guardando el concepto.';
          }
        },
        
        cancel() {
          localStorage.removeItem('editingConcept');
          window.location.href = '/concepts';
        }
      }" x-init="initPage()" class="space-y-5 max-w-4xl mx-auto" data-astro-cid-h4ugnbzq> <header class="flex flex-col sm:flex-row items-start sm:items-center justify-between pb-3 gap-3 border-b border-gray-200" data-astro-cid-h4ugnbzq> <div class="flex items-center gap-4" data-astro-cid-h4ugnbzq> <div class="p-3 bg-white rounded-xl shadow-lg border border-gray-100 text-active bg-lightest" data-astro-cid-h4ugnbzq> <i class="fas fa-file-invoice-dollar text-2xl" data-astro-cid-h4ugnbzq></i> </div> <div data-astro-cid-h4ugnbzq> <h1 class="text-2xl font-extrabold text-gray-900 tracking-tight" data-astro-cid-h4ugnbzq> <span x-text="formData.id ? 'Editar' : 'Nuevo'" data-astro-cid-h4ugnbzq></span> Concepto
</h1> <p class="text-gray-500 text-xs mt-0.5" data-astro-cid-h4ugnbzq>Administraci\xF3n de cargos escolares obligatorios u opcionales.</p> </div> </div> <div class="flex gap-2 w-full sm:w-auto mt-2 sm:mt-0" data-astro-cid-h4ugnbzq> <button type="button" @click="cancel" class="flex-1 sm:flex-none px-3 py-2 rounded-full text-gray-700 bg-white border border-gray-300 hover:bg-gray-100 font-semibold text-sm transition shadow-sm" data-astro-cid-h4ugnbzq>
Cancelar
</button> <button type="submit" @click="submitForm" class="flex-1 sm:flex-none px-5 py-2 text-white rounded-full font-bold btn-primary-gradient text-sm flex items-center justify-center gap-2" data-astro-cid-h4ugnbzq> <i class="fas fa-save text-sm" data-astro-cid-h4ugnbzq></i> <span x-text="formData.id ? 'Actualizar Concepto' : 'Guardar Concepto'" data-astro-cid-h4ugnbzq></span> </button> </div> </header> <div x-cloak x-show="errorMessage" :class="errorMessage.includes('\u2713') ? 'bg-emerald-50 text-emerald-800 border-emerald-300' : 'bg-red-50 text-red-800 border-red-300'" class="p-4 rounded-xl font-medium text-sm flex items-start border shadow-md" data-astro-cid-h4ugnbzq> <i :class="errorMessage.includes('\u2713') ? 'fas fa-check-circle text-emerald-500' : 'fas fa-exclamation-triangle text-red-500'" class="text-xl mr-3 mt-0.5" data-astro-cid-h4ugnbzq></i> <span x-text="errorMessage" class="flex-1" data-astro-cid-h4ugnbzq></span> </div> <form @submit.prevent="submitForm" class="space-y-5" data-astro-cid-h4ugnbzq> <section class="bg-white p-5 rounded-2xl shadow-xl border border-gray-100 space-y-4" data-astro-cid-h4ugnbzq> <div class="flex items-center gap-3" data-astro-cid-h4ugnbzq> <span class="flex items-center justify-center w-7 h-7 rounded-full bg-lightest text-active font-extrabold text-xs border border-[var(--primary-lightest)]" data-astro-cid-h4ugnbzq> <i class="fas fa-edit text-sm" data-astro-cid-h4ugnbzq></i> </span> <h2 class="text-base font-bold text-gray-900 tracking-tight" data-astro-cid-h4ugnbzq>Datos del Cargo</h2> </div> <div class="space-y-4" data-astro-cid-h4ugnbzq> <div class="grid grid-cols-3 gap-4" data-astro-cid-h4ugnbzq> <div class="col-span-2" data-astro-cid-h4ugnbzq> <label for="title" class="block text-xs font-semibold text-gray-700 mb-1" data-astro-cid-h4ugnbzq>T\xEDtulo del Concepto</label> <input type="text" id="title" x-model="formData.title" placeholder="Ej. Inscripci\xF3n Semestre Feb-Jul" class="w-full px-3 py-2 border border-gray-300 rounded-xl input-focus-style transition duration-200 text-sm" required data-astro-cid-h4ugnbzq> </div> <div class="col-span-1" data-astro-cid-h4ugnbzq> <label for="amount" class="block text-xs font-semibold text-gray-700 mb-1" data-astro-cid-h4ugnbzq>Monto ($)</label> <div class="relative" data-astro-cid-h4ugnbzq> <span class="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 font-medium text-sm" data-astro-cid-h4ugnbzq>$</span> <input type="number" id="amount" x-model.number="formData.amount" min="0.01" step="0.01" placeholder="0.00" class="w-full px-3 py-2 pl-7 border border-gray-300 rounded-xl input-focus-style transition duration-200 text-sm" required data-astro-cid-h4ugnbzq> </div> </div> </div> <div data-astro-cid-h4ugnbzq> <label for="description" class="block text-xs font-semibold text-gray-700 mb-1" data-astro-cid-h4ugnbzq>Descripci\xF3n (Opcional)</label> <textarea id="description" x-model="formData.description" rows="2" placeholder="Notas relevantes sobre el destino o las condiciones del pago..." class="w-full px-3 py-2 border border-gray-300 rounded-xl input-focus-style transition duration-200 text-sm" data-astro-cid-h4ugnbzq></textarea> </div> </div> </section> <section class="bg-white p-5 rounded-2xl shadow-xl border border-gray-100 space-y-4" data-astro-cid-h4ugnbzq> <div class="flex items-center gap-3" data-astro-cid-h4ugnbzq> <span class="flex items-center justify-center w-7 h-7 rounded-full bg-lightest text-active font-extrabold text-xs border border-[var(--primary-lightest)]" data-astro-cid-h4ugnbzq> <i class="fas fa-filter text-sm" data-astro-cid-h4ugnbzq></i> </span> <h2 class="text-base font-bold text-gray-900 tracking-tight" data-astro-cid-h4ugnbzq>Reglas de Aplicaci\xF3n (Alcance)</h2> </div> <div class="grid grid-cols-2 gap-4" data-astro-cid-h4ugnbzq> <div @click="formData.allStudents = true" :class="formData.allStudents ? 'check-active' : 'border-gray-300 hover:border-gray-400'" class="border-2 rounded-xl p-4 cursor-pointer transition flex items-center gap-4 shadow-sm" data-astro-cid-h4ugnbzq> <div :class="formData.allStudents ? 'bg-active' : 'bg-gray-200 text-gray-500'" class="p-3 rounded-full transition" data-astro-cid-h4ugnbzq> <i class="fas fa-users-cog text-lg" data-astro-cid-h4ugnbzq></i> </div> <div data-astro-cid-h4ugnbzq> <p class="font-bold text-gray-950 text-sm" data-astro-cid-h4ugnbzq>Matr\xEDcula Completa</p> </div> </div> <div @click="formData.allStudents = false" :class="!formData.allStudents ? 'check-active' : 'border-gray-300 hover:border-gray-400'" class="border-2 rounded-xl p-4 cursor-pointer transition flex items-center gap-4 shadow-sm" data-astro-cid-h4ugnbzq> <div :class="!formData.allStudents ? 'bg-active' : 'bg-gray-200 text-gray-500'" class="p-3 rounded-full transition" data-astro-cid-h4ugnbzq> <i class="fas fa-lock text-lg" data-astro-cid-h4ugnbzq></i> </div> <div data-astro-cid-h4ugnbzq> <p class="font-bold text-gray-950 text-sm" data-astro-cid-h4ugnbzq>Alcance Restringido</p> </div> </div> </div> <div x-show="!formData.allStudents" x-cloak x-transition.opacity.duration.300ms class="space-y-4 pt-4" data-astro-cid-h4ugnbzq> <div class="grid grid-cols-1 md:grid-cols-2 gap-6 bg-gray-50 p-4 rounded-xl border border-gray-200" data-astro-cid-h4ugnbzq> <div data-astro-cid-h4ugnbzq> <label class="block text-xs font-bold text-gray-800 mb-2" data-astro-cid-h4ugnbzq>1. Filtrar por Programa(s)</label> <div class="grid grid-cols-2 gap-3" data-astro-cid-h4ugnbzq> <template x-for="career in careers" :key="career.id" data-astro-cid-h4ugnbzq> <label class="cursor-pointer" data-astro-cid-h4ugnbzq> <input type="checkbox" :value="career.id" x-model="formData.selectedCareers" class="sr-only peer" data-astro-cid-h4ugnbzq> <div class="p-2 rounded-xl border-2 border-gray-300 text-center flex items-center justify-center min-h-[35px] text-xs transition-all peer-checked:border-[var(--primary-solid)] peer-checked:bg-[var(--primary-lightest)] peer-checked:text-[var(--primary-text)] hover:shadow-md" data-astro-cid-h4ugnbzq> <span class="font-semibold" x-text="career.name" data-astro-cid-h4ugnbzq></span> </div> </label> </template> </div> </div> <div data-astro-cid-h4ugnbzq> <label class="block text-xs font-bold text-gray-800 mb-2" data-astro-cid-h4ugnbzq>2. Filtrar por Semestre(s)</label> <div class="flex flex-wrap gap-2" data-astro-cid-h4ugnbzq> <template x-for="sem in semesters" :key="sem.id" data-astro-cid-h4ugnbzq> <label class="cursor-pointer" data-astro-cid-h4ugnbzq> <input type="checkbox" :value="sem.id" x-model="formData.selectedSemesters" class="sr-only peer" data-astro-cid-h4ugnbzq> <div class="w-8 h-8 flex items-center justify-center rounded-xl border-2 border-gray-300 text-xs font-bold transition-all peer-checked:border-[var(--primary-solid)] peer-checked:bg-[var(--primary-lightest)] peer-checked:text-[var(--primary-text)] hover:shadow-md" data-astro-cid-h4ugnbzq> <span x-text="sem.id + '\xB0'" data-astro-cid-h4ugnbzq></span> </div> </label> </template> </div> </div> </div> <div class="border-t border-gray-300 pt-4 mt-4" data-astro-cid-h4ugnbzq> <label class="block text-xs font-bold text-gray-800 mb-2" data-astro-cid-h4ugnbzq>3. Alumnos Adicionales (Inclusi\xF3n forzada)</label> <div class="relative" x-data="{ open: false }" @click.away="open = false" data-astro-cid-h4ugnbzq> <input type="text" x-model="searchTerm" @focus="open = true" @input="open = true" placeholder="Buscar por nombre o matr\xEDcula..." class="w-full px-3 py-2 border border-gray-300 rounded-xl input-focus-style transition duration-200 text-sm" data-astro-cid-h4ugnbzq> <div x-show="open && searchTerm.length > 0 && filteredStudents.length > 0" x-cloak class="absolute z-20 w-full mt-1 bg-white border border-gray-200 rounded-xl shadow-2xl max-h-56 overflow-y-auto p-2 space-y-1" data-astro-cid-h4ugnbzq> <template x-for="student in filteredStudents" :key="student.id" data-astro-cid-h4ugnbzq> <div @click="toggleSpecificStudent(student); open = false" class="p-2 hover:bg-gray-50 rounded-lg cursor-pointer text-sm flex justify-between items-center transition" data-astro-cid-h4ugnbzq> <span x-text="student.name" class="text-gray-800 font-medium" data-astro-cid-h4ugnbzq></span> <span x-text="'Matr\xEDcula: ' + student.id" class="text-gray-500 text-xs" data-astro-cid-h4ugnbzq></span> <i x-show="formData.selectedSpecificStudents.some(s => s.id === student.id)" class="fas fa-check-circle text-active" data-astro-cid-h4ugnbzq></i> </div> </template> </div> </div> <div class="flex flex-wrap gap-2 mt-3" x-show="formData.selectedSpecificStudents.length > 0" x-transition.slide.up data-astro-cid-h4ugnbzq> <template x-for="student in formData.selectedSpecificStudents" :key="student.id" data-astro-cid-h4ugnbzq> <div class="flex items-center gap-2 bg-lightest text-active px-2 py-1 rounded-full text-xs font-semibold border border-[var(--primary-lightest)] shadow-sm" data-astro-cid-h4ugnbzq> <span x-text="student.name + ' (Matr\xEDcula: ' + (student.id.length > 10 ? '...' + student.id.slice(-5) : student.id) + ')'" data-astro-cid-h4ugnbzq></span> <button type="button" @click="removeSpecificStudent(student.id)" class="text-active hover:text-red-500 transition focus:outline-none" data-astro-cid-h4ugnbzq> <i class="fas fa-times-circle text-xs" data-astro-cid-h4ugnbzq></i> </button> </div> </template> </div> </div> </div> </section> <section class="bg-white p-5 rounded-2xl shadow-xl border border-gray-100 space-y-4" data-astro-cid-h4ugnbzq> <div class="flex items-center gap-3" data-astro-cid-h4ugnbzq> <span class="flex items-center justify-center w-7 h-7 rounded-full bg-lightest text-active font-extrabold text-xs border border-[var(--primary-lightest)]" data-astro-cid-h4ugnbzq> <i class="fas fa-toggle-on text-sm" data-astro-cid-h4ugnbzq></i> </span> <h2 class="text-base font-bold text-gray-900 tracking-tight" data-astro-cid-h4ugnbzq>Estado y Aplicaci\xF3n</h2> </div> <div class="grid grid-cols-2 gap-4" data-astro-cid-h4ugnbzq> <label class="cursor-pointer" data-astro-cid-h4ugnbzq> <input type="radio" name="status" value="active" x-model="formData.status" class="sr-only peer" data-astro-cid-h4ugnbzq> <div class="p-4 rounded-xl border-2 border-gray-300 peer-checked:border-[var(--primary-solid)] peer-checked:bg-[var(--primary-lightest)] transition text-center flex flex-col items-center gap-1 shadow-sm hover:shadow-md" data-astro-cid-h4ugnbzq> <i class="fas fa-check-circle text-2xl text-active transition" :class="formData.status === 'active' ? 'text-active' : 'text-active/50'" data-astro-cid-h4ugnbzq></i> <p class="font-bold text-gray-950 text-sm mt-1" data-astro-cid-h4ugnbzq>Activo</p> </div> </label> <label class="cursor-pointer" data-astro-cid-h4ugnbzq> <input type="radio" name="status" value="inactive" x-model="formData.status" class="sr-only peer" data-astro-cid-h4ugnbzq> <div class="p-4 rounded-xl border-2 border-gray-300 peer-checked:border-gray-500 peer-checked:bg-gray-100 transition text-center flex flex-col items-center gap-1 shadow-sm hover:shadow-md" data-astro-cid-h4ugnbzq> <i class="fas fa-pause-circle text-2xl text-gray-400 transition" :class="formData.status === 'inactive' ? 'text-gray-600' : 'text-gray-400/50'" data-astro-cid-h4ugnbzq></i> <p class="font-bold text-gray-950 text-sm mt-1" data-astro-cid-h4ugnbzq>Inactivo</p> </div> </label> </div> </section> </form> </div> </div> <script type="module" client:load>
    // Inicializaci\xF3n y utilidades de almacenamiento local (simulaci\xF3n de base de datos)
    (function () {
      
      window.getStudents = () => JSON.parse(localStorage.getItem('studentsList') || '[]');
      window.saveStudents = (students) => localStorage.setItem('studentsList', JSON.stringify(students));
      window.getConcepts = () => JSON.parse(localStorage.getItem('conceptsList') || '[]');
      window.getCharges = () => JSON.parse(localStorage.getItem('chargesList') || '[]');
      window.saveCharges = (charges) => localStorage.setItem('chargesList', JSON.stringify(charges));

      /**
       * Determina qu\xE9 estudiantes cumplen con las reglas de alcance del concepto.
       */
      window.getTargetStudentsForConcept = (concept) => {
        const students = window.getStudents();
        const activeStudents = students.filter(s => (s.status || '').toLowerCase() !== 'inactive' && (s.status || '').toLowerCase() !== 'inactivo');
        const rules = concept.scopeRules;

        if (rules.allStudents) return activeStudents;

        // L\xD3GICA CORREGIDA PARA EXCLUSIVIDAD
        // 1. Si hay estudiantes espec\xEDficos, devolver SOLO a esos.
        if (rules.specificStudents.length > 0) {
            return activeStudents.filter(alumno => {
                // *** CORRECCI\xD3N APLICADA AQU\xCD ***
                // Se usa la misma l\xF3gica de prioridad que en Alpine (numControl ?? id) para coincidir con la lista de IDs seleccionados.
                const alumnoId = String(alumno.numControl ?? alumno.id ?? ''); 
                return rules.specificStudents.includes(alumnoId);
            });
        }
        
        // 2. Si no hay estudiantes espec\xEDficos, aplicar los filtros de Carrera Y Semestre.
        return activeStudents.filter(alumno => {
            let cumpleCareers = true;
            let cumpleSemesters = true;
            
            const alumnoCareer = String(alumno.career ?? alumno.carrera ?? '');
            const alumnoSemester = String(alumno.semester ?? alumno.semestre ?? '');

            if (rules.careers.length > 0) {
                cumpleCareers = rules.careers.includes(alumnoCareer);
            }
            
            if (rules.semesters.length > 0) {
                cumpleSemesters = rules.semesters.includes(alumnoSemester);
            }
            
            // Debe cumplir AMBOS filtros (Carrera Y Semestre)
            return cumpleCareers && cumpleSemesters;
        });
      };

      /**
       * Recalcula el adeudo total pendiente de cada estudiante basado en chargesList.
       */
      window.recalcStudentAdeudosFromCharges = () => {
        const charges = window.getCharges();
        const students = window.getStudents();
        const pendingChargesByStudent = {};
        
        charges.forEach(ch => {
          if ((ch.status || '').toLowerCase() === 'pending' || (ch.status || '').toLowerCase() === 'pendiente') {
            const sid = String(ch.studentId);
            pendingChargesByStudent[sid] = (pendingChargesByStudent[sid] || 0) + Number(ch.amount || 0);
          }
        });

        const updated = students.map(s => {
          s.adeudo = parseFloat((pendingChargesByStudent[String(s.id)] || 0).toFixed(2));
          return s;
        });
        window.saveStudents(updated);
      };

      /**
       * Crea nuevos cargos pendientes para los estudiantes que cumplen con el alcance del concepto.
       */
      window.assignConceptToScope = (concept) => {
        const targets = window.getTargetStudentsForConcept(concept);
        if (!targets || targets.length === 0) return 0;

        const amount = Number(concept.amount) || 0;
        const existingCharges = window.getCharges();
        const nowIso = new Date().toISOString();

        const toAdd = targets.reduce((acc, s) => {
          const exists = existingCharges.some(ec =>
            ec.conceptId === concept.id &&
            String(ec.studentId) === String(s.id) &&
            ((ec.status || '').toLowerCase() === 'pending' || (ec.status || '').toLowerCase() === 'pendiente')
          );

          if (!exists) {
            acc.push({
              id: 'chg_' + (Date.now().toString(36) + Math.random().toString(36).slice(2,6)),
              studentId: s.id,
              conceptId: concept.id,
              amount,
              status: 'pending',
              title: concept.title,
              createdAt: nowIso
            });
          }
          return acc;
        }, []);

        if (toAdd.length === 0) return 0;

        window.saveCharges(existingCharges.concat(toAdd));
        window.recalcStudentAdeudosFromCharges();
        
        return toAdd.length;
      };
      
    })();
    <\/script> `], ['  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css"> <script src="https://cdn.jsdelivr.net/npm/alpinejs@3.x.x/dist/cdn.min.js" defer><\/script> ', `<div class="p-4 sm:p-6 min-h-screen font-sans" data-astro-cid-h4ugnbzq> <div x-data="{ 
        /* Variables de estado y datos */
        careers: [
            // LISTA DE CARRERAS FINAL
            { id: 'TAG-E', name: 'T\xE9cnico Agropecuario' },
            { id: 'TOF', name: 'T\xE9c. en Ofim\xE1tica' },
            { id: 'TEM', name: 'T\xE9c. en Adm\xF3n. de Emp.' },
            { id: 'TAG-M', name: 'T\xE9c. Agropecuario (Mixta)' },
            { id: 'TRH', name: 'T\xE9c. Adm\xF3n. R. Humanos (Mixta)' },
        ],
          
        // SEMESTRES MANTENIDOS EN 10:
        semesters: Array.from({length: 10}, (_, i) => ({ id: (i+1).toString(), name: (i+1) + '\xB0 Sem' })),

        allStudents: [],

        formData: {
            id: null,
            title: '',
            amount: 0,
            description: '',
            status: 'active',
            
            allStudents: true,
            selectedCareers: [],
            selectedSemesters: [],
            selectedSpecificStudents: []
        },
        searchTerm: '',
        errorMessage: '',
        
        // Funciones
        initPage() {
          this.loadStudents();
          const urlParams = new URLSearchParams(window.location.search);
          const rawConcept = localStorage.getItem('editingConcept');
          
          if (urlParams.has('edit') && rawConcept) {
              try {
                  const concept = JSON.parse(rawConcept);
                  this.populateForm(concept);
              } catch (e) {
                  console.error('Error cargando concepto de edici\xF3n:', e);
              }
          } else {
              localStorage.removeItem('editingConcept');
          }
        },

        loadStudents() {
          try {
            const raw = localStorage.getItem('studentsList');
            if (raw) {
              const parsed = JSON.parse(raw);
              this.allStudents = parsed.map(s => {
                  // 1. CONCATENAR NOMBRE COMPLETO
                  const fullName = [
                      String(s.nombre ?? '').trim(),
                      String(s.apellidoP ?? s.apellidoPaterno ?? '').trim(),
                      String(s.apellidoM ?? s.apellidoMaterno ?? '').trim()
                  ].filter(n => n).join(' '); 
                  
                  return {
                      // 2. CORRECCI\xD3N: PRIORIZAR numControl sobre el ID largo (s.id)
                      id: String(s.numControl ?? s.id ?? ''), 
                      // Nombre Completo
                      name: fullName, 
                      career: String(s.carrera ?? s.career ?? ''),
                      semester: String(s.semestre ?? s.semestre ?? '')
                  };
              }).filter(s => s.id);
              return;
            }
          } catch (e) { console.warn(e); }
          this.allStudents = [];
        },

        populateForm(concept) {
          this.formData.id = concept.id;
          this.formData.title = concept.title;
          this.formData.amount = concept.amount;
          this.formData.description = concept.description || '';
          this.formData.status = concept.status;

          if (concept.scopeRules) {
              this.formData.allStudents = concept.scopeRules.allStudents;
              this.formData.selectedCareers = concept.scopeRules.careers || [];
              this.formData.selectedSemesters = concept.scopeRules.semesters || [];
              
              if (Array.isArray(concept.scopeRules.specificStudents)) {
                  this.formData.selectedSpecificStudents = concept.scopeRules.specificStudents.map(id => {
                      const student = this.allStudents.find(s => String(s.id) === String(id));
                      return student ? {id: student.id, name: student.name} : {id: String(id), name: 'ID: ' + id};
                  });
              }
          }
        },
        
        toggleSpecificStudent(student) {
          const index = this.formData.selectedSpecificStudents.findIndex(s => s.id === student.id);
          if (index === -1) {
            this.formData.selectedSpecificStudents.push({id: student.id, name: student.name});
          } else {
            this.formData.selectedSpecificStudents.splice(index, 1);
          }
          this.searchTerm = '';
        },

        get filteredStudents() {
          if (!this.searchTerm) return [];
          const searchLower = this.searchTerm.toLowerCase();
          return this.allStudents.filter(student =>
            // Busca por Nombre Completo (student.name) o Matr\xEDcula (student.id)
            student.name.toLowerCase().includes(searchLower) ||
            student.id.includes(searchLower)
          ).slice(0, 5);
        },

        removeSpecificStudent(studentId) {
          this.formData.selectedSpecificStudents = this.formData.selectedSpecificStudents.filter(s => s.id !== studentId);
        },
        
        submitForm() {
          this.errorMessage = '';
          
          // Validaci\xF3n b\xE1sica
          if (!this.formData.title || !this.formData.amount || parseFloat(this.formData.amount) <= 0) {
            this.errorMessage = '\u26A0\uFE0F Rellene T\xEDtulo y Monto (mayor a $0).';
            return;
          }

          // Validaci\xF3n de alcance restringido
          if (!this.formData.allStudents) {
              const hasCareer = this.formData.selectedCareers.length > 0;
              const hasSemester = this.formData.selectedSemesters.length > 0;
              const hasSpecific = this.formData.selectedSpecificStudents.length > 0;

              if (!hasCareer && !hasSemester && !hasSpecific) {
                  this.errorMessage = '\u26A0\uFE0F Seleccione al menos una Carrera, Semestre o Alumno.';
                  return;
              }
          }
          
          const newConcept = {
            id: this.formData.id || Date.now().toString(),
            title: this.formData.title,
            amount: parseFloat(this.formData.amount),
            status: this.formData.status,
            description: this.formData.description,
            scopeRules: {
              allStudents: this.formData.allStudents,
              careers: this.formData.selectedCareers,
              semesters: this.formData.selectedSemesters,
              specificStudents: this.formData.selectedSpecificStudents.map(s => s.id)
            },
            createdAt: new Date().toISOString()
          };

          try {
            let stored = JSON.parse(localStorage.getItem('conceptsList') || '[]');
            if (this.formData.id) {
              stored = stored.map(c => c.id === this.formData.id ? newConcept : c);
            } else {
              stored.unshift(newConcept);
            }
            localStorage.setItem('conceptsList', JSON.stringify(stored));
            
            let assignationMessage = '';
            if (newConcept.status === 'active') {
                try {
                    const assignedCount = window.assignConceptToScope ? window.assignConceptToScope(newConcept) : 0;
                    assignationMessage = \\\`\u2713 Concepto guardado y aplicado a \\\${assignedCount} alumnos.\\\`;
                } catch (assignError) {
                    console.error('Error en cobro autom\xE1tico:', assignError);
                    assignationMessage = '\u2713 Concepto guardado pero hubo un error al aplicar el cobro.';
                }
            } else {
                assignationMessage = '\u2713 Concepto guardado como Inactivo.';
            }
            
            localStorage.removeItem('editingConcept');
            this.errorMessage = assignationMessage + ' Redirigiendo...';
            
            setTimeout(() => { window.location.href = '/concepts'; }, 2000);
          } catch(e) {
            this.errorMessage = '\u274C Error guardando el concepto.';
          }
        },
        
        cancel() {
          localStorage.removeItem('editingConcept');
          window.location.href = '/concepts';
        }
      }" x-init="initPage()" class="space-y-5 max-w-4xl mx-auto" data-astro-cid-h4ugnbzq> <header class="flex flex-col sm:flex-row items-start sm:items-center justify-between pb-3 gap-3 border-b border-gray-200" data-astro-cid-h4ugnbzq> <div class="flex items-center gap-4" data-astro-cid-h4ugnbzq> <div class="p-3 bg-white rounded-xl shadow-lg border border-gray-100 text-active bg-lightest" data-astro-cid-h4ugnbzq> <i class="fas fa-file-invoice-dollar text-2xl" data-astro-cid-h4ugnbzq></i> </div> <div data-astro-cid-h4ugnbzq> <h1 class="text-2xl font-extrabold text-gray-900 tracking-tight" data-astro-cid-h4ugnbzq> <span x-text="formData.id ? 'Editar' : 'Nuevo'" data-astro-cid-h4ugnbzq></span> Concepto
</h1> <p class="text-gray-500 text-xs mt-0.5" data-astro-cid-h4ugnbzq>Administraci\xF3n de cargos escolares obligatorios u opcionales.</p> </div> </div> <div class="flex gap-2 w-full sm:w-auto mt-2 sm:mt-0" data-astro-cid-h4ugnbzq> <button type="button" @click="cancel" class="flex-1 sm:flex-none px-3 py-2 rounded-full text-gray-700 bg-white border border-gray-300 hover:bg-gray-100 font-semibold text-sm transition shadow-sm" data-astro-cid-h4ugnbzq>
Cancelar
</button> <button type="submit" @click="submitForm" class="flex-1 sm:flex-none px-5 py-2 text-white rounded-full font-bold btn-primary-gradient text-sm flex items-center justify-center gap-2" data-astro-cid-h4ugnbzq> <i class="fas fa-save text-sm" data-astro-cid-h4ugnbzq></i> <span x-text="formData.id ? 'Actualizar Concepto' : 'Guardar Concepto'" data-astro-cid-h4ugnbzq></span> </button> </div> </header> <div x-cloak x-show="errorMessage" :class="errorMessage.includes('\u2713') ? 'bg-emerald-50 text-emerald-800 border-emerald-300' : 'bg-red-50 text-red-800 border-red-300'" class="p-4 rounded-xl font-medium text-sm flex items-start border shadow-md" data-astro-cid-h4ugnbzq> <i :class="errorMessage.includes('\u2713') ? 'fas fa-check-circle text-emerald-500' : 'fas fa-exclamation-triangle text-red-500'" class="text-xl mr-3 mt-0.5" data-astro-cid-h4ugnbzq></i> <span x-text="errorMessage" class="flex-1" data-astro-cid-h4ugnbzq></span> </div> <form @submit.prevent="submitForm" class="space-y-5" data-astro-cid-h4ugnbzq> <section class="bg-white p-5 rounded-2xl shadow-xl border border-gray-100 space-y-4" data-astro-cid-h4ugnbzq> <div class="flex items-center gap-3" data-astro-cid-h4ugnbzq> <span class="flex items-center justify-center w-7 h-7 rounded-full bg-lightest text-active font-extrabold text-xs border border-[var(--primary-lightest)]" data-astro-cid-h4ugnbzq> <i class="fas fa-edit text-sm" data-astro-cid-h4ugnbzq></i> </span> <h2 class="text-base font-bold text-gray-900 tracking-tight" data-astro-cid-h4ugnbzq>Datos del Cargo</h2> </div> <div class="space-y-4" data-astro-cid-h4ugnbzq> <div class="grid grid-cols-3 gap-4" data-astro-cid-h4ugnbzq> <div class="col-span-2" data-astro-cid-h4ugnbzq> <label for="title" class="block text-xs font-semibold text-gray-700 mb-1" data-astro-cid-h4ugnbzq>T\xEDtulo del Concepto</label> <input type="text" id="title" x-model="formData.title" placeholder="Ej. Inscripci\xF3n Semestre Feb-Jul" class="w-full px-3 py-2 border border-gray-300 rounded-xl input-focus-style transition duration-200 text-sm" required data-astro-cid-h4ugnbzq> </div> <div class="col-span-1" data-astro-cid-h4ugnbzq> <label for="amount" class="block text-xs font-semibold text-gray-700 mb-1" data-astro-cid-h4ugnbzq>Monto ($)</label> <div class="relative" data-astro-cid-h4ugnbzq> <span class="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 font-medium text-sm" data-astro-cid-h4ugnbzq>$</span> <input type="number" id="amount" x-model.number="formData.amount" min="0.01" step="0.01" placeholder="0.00" class="w-full px-3 py-2 pl-7 border border-gray-300 rounded-xl input-focus-style transition duration-200 text-sm" required data-astro-cid-h4ugnbzq> </div> </div> </div> <div data-astro-cid-h4ugnbzq> <label for="description" class="block text-xs font-semibold text-gray-700 mb-1" data-astro-cid-h4ugnbzq>Descripci\xF3n (Opcional)</label> <textarea id="description" x-model="formData.description" rows="2" placeholder="Notas relevantes sobre el destino o las condiciones del pago..." class="w-full px-3 py-2 border border-gray-300 rounded-xl input-focus-style transition duration-200 text-sm" data-astro-cid-h4ugnbzq></textarea> </div> </div> </section> <section class="bg-white p-5 rounded-2xl shadow-xl border border-gray-100 space-y-4" data-astro-cid-h4ugnbzq> <div class="flex items-center gap-3" data-astro-cid-h4ugnbzq> <span class="flex items-center justify-center w-7 h-7 rounded-full bg-lightest text-active font-extrabold text-xs border border-[var(--primary-lightest)]" data-astro-cid-h4ugnbzq> <i class="fas fa-filter text-sm" data-astro-cid-h4ugnbzq></i> </span> <h2 class="text-base font-bold text-gray-900 tracking-tight" data-astro-cid-h4ugnbzq>Reglas de Aplicaci\xF3n (Alcance)</h2> </div> <div class="grid grid-cols-2 gap-4" data-astro-cid-h4ugnbzq> <div @click="formData.allStudents = true" :class="formData.allStudents ? 'check-active' : 'border-gray-300 hover:border-gray-400'" class="border-2 rounded-xl p-4 cursor-pointer transition flex items-center gap-4 shadow-sm" data-astro-cid-h4ugnbzq> <div :class="formData.allStudents ? 'bg-active' : 'bg-gray-200 text-gray-500'" class="p-3 rounded-full transition" data-astro-cid-h4ugnbzq> <i class="fas fa-users-cog text-lg" data-astro-cid-h4ugnbzq></i> </div> <div data-astro-cid-h4ugnbzq> <p class="font-bold text-gray-950 text-sm" data-astro-cid-h4ugnbzq>Matr\xEDcula Completa</p> </div> </div> <div @click="formData.allStudents = false" :class="!formData.allStudents ? 'check-active' : 'border-gray-300 hover:border-gray-400'" class="border-2 rounded-xl p-4 cursor-pointer transition flex items-center gap-4 shadow-sm" data-astro-cid-h4ugnbzq> <div :class="!formData.allStudents ? 'bg-active' : 'bg-gray-200 text-gray-500'" class="p-3 rounded-full transition" data-astro-cid-h4ugnbzq> <i class="fas fa-lock text-lg" data-astro-cid-h4ugnbzq></i> </div> <div data-astro-cid-h4ugnbzq> <p class="font-bold text-gray-950 text-sm" data-astro-cid-h4ugnbzq>Alcance Restringido</p> </div> </div> </div> <div x-show="!formData.allStudents" x-cloak x-transition.opacity.duration.300ms class="space-y-4 pt-4" data-astro-cid-h4ugnbzq> <div class="grid grid-cols-1 md:grid-cols-2 gap-6 bg-gray-50 p-4 rounded-xl border border-gray-200" data-astro-cid-h4ugnbzq> <div data-astro-cid-h4ugnbzq> <label class="block text-xs font-bold text-gray-800 mb-2" data-astro-cid-h4ugnbzq>1. Filtrar por Programa(s)</label> <div class="grid grid-cols-2 gap-3" data-astro-cid-h4ugnbzq> <template x-for="career in careers" :key="career.id" data-astro-cid-h4ugnbzq> <label class="cursor-pointer" data-astro-cid-h4ugnbzq> <input type="checkbox" :value="career.id" x-model="formData.selectedCareers" class="sr-only peer" data-astro-cid-h4ugnbzq> <div class="p-2 rounded-xl border-2 border-gray-300 text-center flex items-center justify-center min-h-[35px] text-xs transition-all peer-checked:border-[var(--primary-solid)] peer-checked:bg-[var(--primary-lightest)] peer-checked:text-[var(--primary-text)] hover:shadow-md" data-astro-cid-h4ugnbzq> <span class="font-semibold" x-text="career.name" data-astro-cid-h4ugnbzq></span> </div> </label> </template> </div> </div> <div data-astro-cid-h4ugnbzq> <label class="block text-xs font-bold text-gray-800 mb-2" data-astro-cid-h4ugnbzq>2. Filtrar por Semestre(s)</label> <div class="flex flex-wrap gap-2" data-astro-cid-h4ugnbzq> <template x-for="sem in semesters" :key="sem.id" data-astro-cid-h4ugnbzq> <label class="cursor-pointer" data-astro-cid-h4ugnbzq> <input type="checkbox" :value="sem.id" x-model="formData.selectedSemesters" class="sr-only peer" data-astro-cid-h4ugnbzq> <div class="w-8 h-8 flex items-center justify-center rounded-xl border-2 border-gray-300 text-xs font-bold transition-all peer-checked:border-[var(--primary-solid)] peer-checked:bg-[var(--primary-lightest)] peer-checked:text-[var(--primary-text)] hover:shadow-md" data-astro-cid-h4ugnbzq> <span x-text="sem.id + '\xB0'" data-astro-cid-h4ugnbzq></span> </div> </label> </template> </div> </div> </div> <div class="border-t border-gray-300 pt-4 mt-4" data-astro-cid-h4ugnbzq> <label class="block text-xs font-bold text-gray-800 mb-2" data-astro-cid-h4ugnbzq>3. Alumnos Adicionales (Inclusi\xF3n forzada)</label> <div class="relative" x-data="{ open: false }" @click.away="open = false" data-astro-cid-h4ugnbzq> <input type="text" x-model="searchTerm" @focus="open = true" @input="open = true" placeholder="Buscar por nombre o matr\xEDcula..." class="w-full px-3 py-2 border border-gray-300 rounded-xl input-focus-style transition duration-200 text-sm" data-astro-cid-h4ugnbzq> <div x-show="open && searchTerm.length > 0 && filteredStudents.length > 0" x-cloak class="absolute z-20 w-full mt-1 bg-white border border-gray-200 rounded-xl shadow-2xl max-h-56 overflow-y-auto p-2 space-y-1" data-astro-cid-h4ugnbzq> <template x-for="student in filteredStudents" :key="student.id" data-astro-cid-h4ugnbzq> <div @click="toggleSpecificStudent(student); open = false" class="p-2 hover:bg-gray-50 rounded-lg cursor-pointer text-sm flex justify-between items-center transition" data-astro-cid-h4ugnbzq> <span x-text="student.name" class="text-gray-800 font-medium" data-astro-cid-h4ugnbzq></span> <span x-text="'Matr\xEDcula: ' + student.id" class="text-gray-500 text-xs" data-astro-cid-h4ugnbzq></span> <i x-show="formData.selectedSpecificStudents.some(s => s.id === student.id)" class="fas fa-check-circle text-active" data-astro-cid-h4ugnbzq></i> </div> </template> </div> </div> <div class="flex flex-wrap gap-2 mt-3" x-show="formData.selectedSpecificStudents.length > 0" x-transition.slide.up data-astro-cid-h4ugnbzq> <template x-for="student in formData.selectedSpecificStudents" :key="student.id" data-astro-cid-h4ugnbzq> <div class="flex items-center gap-2 bg-lightest text-active px-2 py-1 rounded-full text-xs font-semibold border border-[var(--primary-lightest)] shadow-sm" data-astro-cid-h4ugnbzq> <span x-text="student.name + ' (Matr\xEDcula: ' + (student.id.length > 10 ? '...' + student.id.slice(-5) : student.id) + ')'" data-astro-cid-h4ugnbzq></span> <button type="button" @click="removeSpecificStudent(student.id)" class="text-active hover:text-red-500 transition focus:outline-none" data-astro-cid-h4ugnbzq> <i class="fas fa-times-circle text-xs" data-astro-cid-h4ugnbzq></i> </button> </div> </template> </div> </div> </div> </section> <section class="bg-white p-5 rounded-2xl shadow-xl border border-gray-100 space-y-4" data-astro-cid-h4ugnbzq> <div class="flex items-center gap-3" data-astro-cid-h4ugnbzq> <span class="flex items-center justify-center w-7 h-7 rounded-full bg-lightest text-active font-extrabold text-xs border border-[var(--primary-lightest)]" data-astro-cid-h4ugnbzq> <i class="fas fa-toggle-on text-sm" data-astro-cid-h4ugnbzq></i> </span> <h2 class="text-base font-bold text-gray-900 tracking-tight" data-astro-cid-h4ugnbzq>Estado y Aplicaci\xF3n</h2> </div> <div class="grid grid-cols-2 gap-4" data-astro-cid-h4ugnbzq> <label class="cursor-pointer" data-astro-cid-h4ugnbzq> <input type="radio" name="status" value="active" x-model="formData.status" class="sr-only peer" data-astro-cid-h4ugnbzq> <div class="p-4 rounded-xl border-2 border-gray-300 peer-checked:border-[var(--primary-solid)] peer-checked:bg-[var(--primary-lightest)] transition text-center flex flex-col items-center gap-1 shadow-sm hover:shadow-md" data-astro-cid-h4ugnbzq> <i class="fas fa-check-circle text-2xl text-active transition" :class="formData.status === 'active' ? 'text-active' : 'text-active/50'" data-astro-cid-h4ugnbzq></i> <p class="font-bold text-gray-950 text-sm mt-1" data-astro-cid-h4ugnbzq>Activo</p> </div> </label> <label class="cursor-pointer" data-astro-cid-h4ugnbzq> <input type="radio" name="status" value="inactive" x-model="formData.status" class="sr-only peer" data-astro-cid-h4ugnbzq> <div class="p-4 rounded-xl border-2 border-gray-300 peer-checked:border-gray-500 peer-checked:bg-gray-100 transition text-center flex flex-col items-center gap-1 shadow-sm hover:shadow-md" data-astro-cid-h4ugnbzq> <i class="fas fa-pause-circle text-2xl text-gray-400 transition" :class="formData.status === 'inactive' ? 'text-gray-600' : 'text-gray-400/50'" data-astro-cid-h4ugnbzq></i> <p class="font-bold text-gray-950 text-sm mt-1" data-astro-cid-h4ugnbzq>Inactivo</p> </div> </label> </div> </section> </form> </div> </div> <script type="module" client:load>
    // Inicializaci\xF3n y utilidades de almacenamiento local (simulaci\xF3n de base de datos)
    (function () {
      
      window.getStudents = () => JSON.parse(localStorage.getItem('studentsList') || '[]');
      window.saveStudents = (students) => localStorage.setItem('studentsList', JSON.stringify(students));
      window.getConcepts = () => JSON.parse(localStorage.getItem('conceptsList') || '[]');
      window.getCharges = () => JSON.parse(localStorage.getItem('chargesList') || '[]');
      window.saveCharges = (charges) => localStorage.setItem('chargesList', JSON.stringify(charges));

      /**
       * Determina qu\xE9 estudiantes cumplen con las reglas de alcance del concepto.
       */
      window.getTargetStudentsForConcept = (concept) => {
        const students = window.getStudents();
        const activeStudents = students.filter(s => (s.status || '').toLowerCase() !== 'inactive' && (s.status || '').toLowerCase() !== 'inactivo');
        const rules = concept.scopeRules;

        if (rules.allStudents) return activeStudents;

        // L\xD3GICA CORREGIDA PARA EXCLUSIVIDAD
        // 1. Si hay estudiantes espec\xEDficos, devolver SOLO a esos.
        if (rules.specificStudents.length > 0) {
            return activeStudents.filter(alumno => {
                // *** CORRECCI\xD3N APLICADA AQU\xCD ***
                // Se usa la misma l\xF3gica de prioridad que en Alpine (numControl ?? id) para coincidir con la lista de IDs seleccionados.
                const alumnoId = String(alumno.numControl ?? alumno.id ?? ''); 
                return rules.specificStudents.includes(alumnoId);
            });
        }
        
        // 2. Si no hay estudiantes espec\xEDficos, aplicar los filtros de Carrera Y Semestre.
        return activeStudents.filter(alumno => {
            let cumpleCareers = true;
            let cumpleSemesters = true;
            
            const alumnoCareer = String(alumno.career ?? alumno.carrera ?? '');
            const alumnoSemester = String(alumno.semester ?? alumno.semestre ?? '');

            if (rules.careers.length > 0) {
                cumpleCareers = rules.careers.includes(alumnoCareer);
            }
            
            if (rules.semesters.length > 0) {
                cumpleSemesters = rules.semesters.includes(alumnoSemester);
            }
            
            // Debe cumplir AMBOS filtros (Carrera Y Semestre)
            return cumpleCareers && cumpleSemesters;
        });
      };

      /**
       * Recalcula el adeudo total pendiente de cada estudiante basado en chargesList.
       */
      window.recalcStudentAdeudosFromCharges = () => {
        const charges = window.getCharges();
        const students = window.getStudents();
        const pendingChargesByStudent = {};
        
        charges.forEach(ch => {
          if ((ch.status || '').toLowerCase() === 'pending' || (ch.status || '').toLowerCase() === 'pendiente') {
            const sid = String(ch.studentId);
            pendingChargesByStudent[sid] = (pendingChargesByStudent[sid] || 0) + Number(ch.amount || 0);
          }
        });

        const updated = students.map(s => {
          s.adeudo = parseFloat((pendingChargesByStudent[String(s.id)] || 0).toFixed(2));
          return s;
        });
        window.saveStudents(updated);
      };

      /**
       * Crea nuevos cargos pendientes para los estudiantes que cumplen con el alcance del concepto.
       */
      window.assignConceptToScope = (concept) => {
        const targets = window.getTargetStudentsForConcept(concept);
        if (!targets || targets.length === 0) return 0;

        const amount = Number(concept.amount) || 0;
        const existingCharges = window.getCharges();
        const nowIso = new Date().toISOString();

        const toAdd = targets.reduce((acc, s) => {
          const exists = existingCharges.some(ec =>
            ec.conceptId === concept.id &&
            String(ec.studentId) === String(s.id) &&
            ((ec.status || '').toLowerCase() === 'pending' || (ec.status || '').toLowerCase() === 'pendiente')
          );

          if (!exists) {
            acc.push({
              id: 'chg_' + (Date.now().toString(36) + Math.random().toString(36).slice(2,6)),
              studentId: s.id,
              conceptId: concept.id,
              amount,
              status: 'pending',
              title: concept.title,
              createdAt: nowIso
            });
          }
          return acc;
        }, []);

        if (toAdd.length === 0) return 0;

        window.saveCharges(existingCharges.concat(toAdd));
        window.recalcStudentAdeudosFromCharges();
        
        return toAdd.length;
      };
      
    })();
    <\/script> `])), maybeRenderHead()) })}`;
}, "C:/Users/sarah/Documents/GitHub/CBTA/Frond-end/src/pages/new.astro", void 0);

const $$file = "C:/Users/sarah/Documents/GitHub/CBTA/Frond-end/src/pages/new.astro";
const $$url = "/new";

const _page = /*#__PURE__*/Object.freeze(/*#__PURE__*/Object.defineProperty({
  __proto__: null,
  default: $$New,
  file: $$file,
  url: $$url
}, Symbol.toStringTag, { value: 'Module' }));

const page = () => _page;

export { page };
