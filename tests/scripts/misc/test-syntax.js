// Test de sintaxis básica del objeto
const conceptFormData = {
  CAREERS: [
    { code: 'TAG-E', name: 'Técnico Agropecuario' }
  ],
  careers: [],
  semesters: [],
  allStudents: [],
  isSaving: false,
  formData: {
    id: null,
    title: '',
    amount: 0
  },
  searchTerm: '',
  errorMessage: '',
  apiBaseUrl: '',
  
  loadCareers() {
    console.log('load careers');
  },
  
  async loadStudents() {
    console.log('load students');
  },
  
  submitForm() {
    console.log('submit');
  },
  
  cancel() {
    console.log('cancel');
  }
};

console.log('✅ Sintaxis válida');
console.log(typeof conceptFormData.loadCareers); // Debe ser 'function'
