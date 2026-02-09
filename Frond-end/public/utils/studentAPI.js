/**
 * Student API Service
 * Centraliza todas las llamadas API para páginas de estudiantes
 * Endpoints: Dashboard, Adeudos, Historial, Tarjetas, Perfil
 * 
 * Este archivo se carga como script global y expone StudentAPI en window
 */

const API_BASE = 'https://nginx-production-728f.up.railway.app/api/v1';

/**
 * Helper: Detecta errores de autenticación (401)
 */
function handleAuthError(statusCode) {
  if (statusCode === 401) {
    const currentToken = localStorage.getItem('access_token');
    
    // Log para debugging
    console.warn('⚠️ 401 Unauthorized');
    console.warn('Token en localStorage:', currentToken ? 'SÍ (presente)' : 'NO (no encontrado)');
    
    // Mostrar opciones al usuario
    const choice = confirm(
      '❌ Error de autenticación (401 - No autorizado)\n\n' +
      'Tu token puede estar:\n' +
      '• Expirado\n' +
      '• Inválido\n' +
      '• Revocado por el servidor\n\n' +
      '¿Deseas ir al login para re-autenticarte?\n\n' +
      'Sí = Ir a login\n' +
      'No = Reintentar (cierra esta ventana y actualiza la página)'
    );
    
    if (choice) {
      // Limpiar token
      localStorage.removeItem('access_token');
      localStorage.removeItem('user_id');
      // Redirigir a login
      window.location.href = '/login';
    }
    return true;
  }
  return false;
}

export const StudentAPI = {
  /**
   * DASHBOARD - GET /api/v1/dashboard/history/{studentId?}
   * Obtener historial de pagos del usuario autenticado
   */
  async getPaymentHistory(studentId, token) {
    try {
      const endpoint = studentId ? `${API_BASE}/dashboard/history/${studentId}` : `${API_BASE}/dashboard/history`;
      const response = await fetch(endpoint, {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        }
      });

      // Detectar error de autenticación
      if (response.status === 401) {
        handleAuthError(401);
        throw new Error('No autenticado - sesión expirada');
      }

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.message || 'Error al cargar historial de pagos');
      }

      return await response.json();
    } catch (err) {
      console.error('❌ StudentAPI.getPaymentHistory:', err);
      throw err;
    }
  },

  /**
   * DASHBOARD - GET /api/v1/dashboard/pending/{studentId?}
   * Obtener total de pagos pendientes del usuario
   * @param {number|null} studentId - ID del estudiante (opcional para padres)
   * @param {string} token - Token de autenticación
   * @param {boolean} forceRefresh - Forzar actualización del caché
   * @param {string} role - Rol del usuario (student|parent)
   */
  async getPendingTotal(studentId, token, forceRefresh = false, role = 'student') {
    try {
      const url = new URL(studentId ? `${API_BASE}/dashboard/pending/${studentId}` : `${API_BASE}/dashboard/pending`);
      if (forceRefresh) {
        url.searchParams.append('forceRefresh', 'true');
      }

      const response = await fetch(url.toString(), {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-User-Role': role,
          'X-User-Permission': 'view.own.pending.concepts.summary'
        }
      });

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.message || 'Error al cargar pagos pendientes');
      }

      return await response.json();
    } catch (err) {
      console.error('❌ StudentAPI.getPendingTotal:', err);
      throw err;
    }
  },

  /**
   * DASHBOARD - GET /api/v1/dashboard/paid/{studentId?}
   * Obtener total de pagos realizados por el usuario
   * @param {number|null} studentId - ID del estudiante (opcional para padres)
   * @param {string} token - Token de autenticación
   * @param {boolean} forceRefresh - Forzar actualización del caché
   * @param {string} role - Rol del usuario (student|parent)
   */
  async getPaidTotal(studentId, token, forceRefresh = false, role = 'student') {
    try {
      const url = new URL(studentId ? `${API_BASE}/dashboard/paid/${studentId}` : `${API_BASE}/dashboard/paid`);
      if (forceRefresh) {
        url.searchParams.append('forceRefresh', 'true');
      }

      const response = await fetch(url.toString(), {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-User-Role': role,
          'X-User-Permission': 'view.own.paid.concepts.summary'
        }
      });

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.message || 'Error al cargar pagos realizados');
      }

      return await response.json();
    } catch (err) {
      console.error('❌ StudentAPI.getPaidTotal:', err);
      throw err;
    }
  },

  /**
   * DASHBOARD - GET /api/v1/dashboard/overdue/{studentId?}
   * Obtener total de pagos vencidos del usuario
   * @param {number|null} studentId - ID del estudiante (opcional para padres)
   * @param {string} token - Token de autenticación
   * @param {boolean} forceRefresh - Forzar actualización del caché
   * @param {string} role - Rol del usuario (student|parent)
   */
  async getOverdueTotal(studentId, token, forceRefresh = false, role = 'student') {
    try {
      const url = new URL(studentId ? `${API_BASE}/dashboard/overdue/${studentId}` : `${API_BASE}/dashboard/overdue`);
      if (forceRefresh) {
        url.searchParams.append('forceRefresh', 'true');
      }

      const response = await fetch(url.toString(), {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-User-Role': role,
          'X-User-Permission': 'view.own.overdue.concepts.summary'
        }
      });

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.message || 'Error al cargar pagos vencidos');
      }

      return await response.json();
    } catch (err) {
      console.error('❌ StudentAPI.getOverdueTotal:', err);
      throw err;
    }
  },

  /**
   * ADEUDOS - GET /api/v1/pending-payments
   * Obtener pagos pendientes del usuario autenticado
   * NOTA: NO se usa /{studentId} porque causa 400 en producción
   * @param {number|null} studentId - ID del estudiante (opcional para padres con múltiples hijos)
   * @param {string} token - Token de autenticación
   * @param {boolean} forceRefresh - Forzar actualización del caché
   * @param {string} role - Rol del usuario (student|parent)
   */
  async getPendingPayments(studentId, token, forceRefresh = false, role = 'student') {
    try {
      // Construir URL base
      const url = new URL(studentId ? `${API_BASE}/pending-payments/${studentId}` : `${API_BASE}/pending-payments`);
      
      // Agregar query parameters
      if (forceRefresh) {
        url.searchParams.append('forceRefresh', 'true');
      }
      
      console.log(`🔍 [StudentAPI] getPendingPayments URL: ${url.toString()}`);
      
      const response = await fetch(url.toString(), {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-User-Role': role,
          'X-User-Permission': 'view.pending.concepts'
        }
      });

      console.log(`📡 [StudentAPI] getPendingPayments Response Status: ${response.status}`);

      if (!response.ok) {
        const errorText = await response.text();
        console.error(`❌ [StudentAPI] getPendingPayments Error Response:`, errorText);
        const errorData = JSON.parse(errorText || '{}');
        throw new Error(errorData.message || errorData.error || 'Error al cargar pagos pendientes');
      }

      const data = await response.json();
      console.log(`✅ [StudentAPI] getPendingPayments Success:`, data);
      return data;
    } catch (err) {
      console.error('❌ StudentAPI.getPendingPayments:', err);
      throw err;
    }
  },

  /**
   * ADEUDOS - GET /api/v1/pending-payments/overdue/{studentId?}
   * Obtener pagos vencidos del usuario autenticado
   * @param {number|null} studentId - ID del estudiante (opcional para padres con múltiples hijos)
   * @param {string} token - Token de autenticación
   * @param {boolean} forceRefresh - Forzar actualización del caché
   * @param {string} role - Rol del usuario (student|parent)
   */
  async getOverduePayments(studentId, token, forceRefresh = false, role = 'student') {
    try {
      // Construir URL base
      const url = new URL(studentId ? `${API_BASE}/pending-payments/overdue/${studentId}` : `${API_BASE}/pending-payments/overdue`);
      
      // Agregar query parameters
      if (forceRefresh) {
        url.searchParams.append('forceRefresh', 'true');
      }
      
      console.log(`🔍 [StudentAPI] getOverduePayments URL: ${url.toString()}`);
      
      const response = await fetch(url.toString(), {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-User-Role': role,
          'X-User-Permission': 'view.overdue.concepts'
        }
      });

      console.log(`📡 [StudentAPI] getOverduePayments Response Status: ${response.status}`);

      if (!response.ok) {
        const errorText = await response.text();
        console.error(`❌ [StudentAPI] getOverduePayments Error Response:`, errorText);
        const errorData = JSON.parse(errorText || '{}');
        throw new Error(errorData.message || errorData.error || 'Error al cargar pagos vencidos');
      }

      const data = await response.json();
      console.log(`✅ [StudentAPI] getOverduePayments Success:`, data);
      return data;
    } catch (err) {
      console.error('❌ StudentAPI.getOverduePayments:', err);
      throw err;
    }
  },

  /**
   * TARJETAS - GET /api/v1/cards
   * Listar métodos de pago del usuario autenticado
   * NOTA: NO se usa /{studentId} porque causa 400 en producción
   */
  async getPaymentMethods(studentId, token, forceRefresh = false) {
    try {
      // Construir URL base SIN el parámetro studentId en el path
      const url = new URL(`${API_BASE}/cards`);
      
      // Si se proporciona studentId (caso de padres), agregarlo como query parameter
      if (studentId) {
        url.searchParams.append('id', studentId);
      }
      
      if (forceRefresh) {
        url.searchParams.append('forceRefresh', 'true');
      }
      
      console.log(`🔍 [StudentAPI] getPaymentMethods URL: ${url.toString()}`);
      
      const response = await fetch(url.toString(), {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-User-Role': 'student',
          'X-User-Permission': 'delete.card'
        }
      });

      console.log(`📡 [StudentAPI] getPaymentMethods Response Status: ${response.status}`);

      if (!response.ok) {
        const errorText = await response.text();
        console.error(`❌ [StudentAPI] getPaymentMethods Error Response:`, errorText);
        const errorData = JSON.parse(errorText || '{}');
        throw new Error(errorData.message || errorData.error || 'Error al cargar métodos de pago');
      }

      const data = await response.json();
      console.log(`✅ [StudentAPI] getPaymentMethods Success:`, data);
      return data;
    } catch (err) {
      console.error('❌ StudentAPI.getPaymentMethods:', err);
      throw err;
    }
  },

  /**
   * PERFIL - GET /api/v1/users/user
   * Obtener usuario autenticado
   */
  async getAuthenticatedUser(token) {
    try {
      const response = await fetch(`${API_BASE}/users/user`, {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        }
      });

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.message || 'Error al cargar usuario');
      }

      return await response.json();
    } catch (err) {
      console.error('❌ StudentAPI.getAuthenticatedUser:', err);
      throw err;
    }
  },

  /**
   * PERFIL - GET /api/v1/users/student-details
   * Obtener detalles de estudiante del usuario autenticado
   */
  async getStudentDetails(token) {
    try {
      const response = await fetch(`${API_BASE}/users/student-details`, {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        }
      });

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.message || 'Error al cargar detalles de estudiante');
      }

      return await response.json();
    } catch (err) {
      console.error('❌ StudentAPI.getStudentDetails:', err);
      throw err;
    }
  },

  /**
   * CREAR INTENTO DE PAGO - POST /api/v1/pending-payments
   * Generar intento de pago para un concepto pendiente
   * @param {number} conceptId - ID del concepto a pagar
   * @param {string} token - Token de autenticación
   */
  async createPaymentIntent(conceptId, token) {
    try {
      const url = `${API_BASE}/pending-payments`;
      
      const response = await fetch(url, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-User-Role': 'student',
          'X-User-Permission': 'create.payment'
        },
        body: JSON.stringify({
          concept_id: conceptId
        })
      });

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        if (response.status === 429) {
          throw new Error('Demasiadas solicitudes. Intenta de nuevo en unos momentos.');
        }
        if (response.status === 422) {
          throw new Error('Concepto inválido o no disponible');
        }
        if (response.status === 502) {
          throw new Error('Error al procesar el pago. Por favor intenta de nuevo.');
        }
        throw new Error(errorData.message || 'Error al crear el intento de pago');
      }

      return await response.json();
    } catch (err) {
      console.error('❌ StudentAPI.createPaymentIntent:', err);
      throw err;
    }
  },

  /**
   * PAYMENTS - GET /api/v1/payments
   * Listar todos los pagos registrados con paginación
   * @param {string} token - Token de autenticación
   * @param {object} options - Opciones de búsqueda y paginación
   * @param {string} options.search - Búsqueda por email, CURP, n_control o concepto
   * @param {number} options.page - Página número (default: 1)
   * @param {number} options.perPage - Items por página (default: 15)
   * @param {boolean} options.forceRefresh - Forzar actualización del caché
   */
  async getAllPayments(token, options = {}) {
    try {
      const {
        search = '',
        page = 1,
        perPage = 15,
        forceRefresh = false
      } = options;

      const params = new URL(`${API_BASE}/payments`);
      if (search) params.searchParams.append('search', search);
      params.searchParams.append('page', page);
      params.searchParams.append('perPage', perPage);
      if (forceRefresh) params.searchParams.append('forceRefresh', 'true');

      const response = await fetch(params.toString(), {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-User-Role': 'financial-staff',
          'X-User-Permission': 'view.payments'
        }
      });

      if (!response.ok) {
        if (response.status === 401) {
          throw new Error('No autenticado. Por favor inicia sesión.');
        }
        if (response.status === 403) {
          throw new Error('No tienes permiso para ver los pagos.');
        }
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.message || 'Error al obtener pagos');
      }

      return await response.json();
    } catch (err) {
      console.error('❌ StudentAPI.getAllPayments:', err);
      throw err;
    }
  },

  /**
   * PAYMENTS - GET /api/v1/payments/by-concept
   * Listar pagos agrupados por concepto con estadísticas
   * @param {string} token - Token de autenticación
   * @param {object} options - Opciones de búsqueda y paginación
   * @param {string} options.search - Búsqueda por nombre de concepto
   * @param {number} options.page - Página número (default: 1)
   * @param {number} options.perPage - Items por página (default: 15)
   * @param {boolean} options.forceRefresh - Forzar actualización del caché
   */
  async getPaymentsByConcept(token, options = {}) {
    try {
      const {
        search = '',
        page = 1,
        perPage = 15,
        forceRefresh = false
      } = options;

      const params = new URL(`${API_BASE}/payments/by-concept`);
      if (search) params.searchParams.append('search', search);
      params.searchParams.append('page', page);
      params.searchParams.append('perPage', perPage);
      if (forceRefresh) params.searchParams.append('forceRefresh', 'true');

      const response = await fetch(params.toString(), {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-User-Role': 'financial-staff',
          'X-User-Permission': 'view.payments'
        }
      });

      if (!response.ok) {
        if (response.status === 401) {
          throw new Error('No autenticado. Por favor inicia sesión.');
        }
        if (response.status === 403) {
          throw new Error('No tienes permiso para ver los pagos por concepto.');
        }
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.message || 'Error al obtener pagos por concepto');
      }

      return await response.json();
    } catch (err) {
      console.error('❌ StudentAPI.getPaymentsByConcept:', err);
      throw err;
    }
  },

  /**
   * STUDENTS - GET /api/v1/payments/students
   * Listar estudiantes con resumen de sus pagos (para financial staff)
   * @param {string} token - Token de autenticación
   * @param {object} options - Opciones de búsqueda y paginación
   * @param {string} options.search - Búsqueda por email, CURP o n_control
   * @param {number} options.page - Página número (default: 1)
   * @param {number} options.perPage - Items por página (default: 15)
   * @param {boolean} options.forceRefresh - Forzar actualización del caché
   * @param {string} options.role - Rol del usuario
   * @param {string} options.permission - Permiso del usuario
   */
  async getPaymentStudents(token, options = {}) {
    try {
      const {
        search = '',
        page = 1,
        perPage = 15,
        forceRefresh = false,
        role = 'financial-staff',
        permission = 'view.payments.student.summary'
      } = options;

      const params = new URL(`${API_BASE}/payments/students`);
      if (search) params.searchParams.append('search', search);
      params.searchParams.append('page', page);
      params.searchParams.append('perPage', perPage);
      if (forceRefresh) params.searchParams.append('forceRefresh', 'true');

      console.log(`🔍 [StudentAPI] getPaymentStudents URL: ${params.toString()}`);

      const response = await fetch(params.toString(), {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-User-Role': role,
          'X-User-Permission': permission
        }
      });

      console.log(`📡 [StudentAPI] getPaymentStudents Response Status: ${response.status}`);

      if (!response.ok) {
        if (response.status === 401) {
          handleAuthError(401);
          throw new Error('No autenticado. Por favor inicia sesión.');
        }
        if (response.status === 403) {
          throw new Error('No tienes permiso para ver el resumen de estudiantes.');
        }
        const errorText = await response.text();
        console.error(`❌ [StudentAPI] getPaymentStudents Error Response:`, errorText);
        const errorData = JSON.parse(errorText || '{}');
        throw new Error(errorData.message || 'Error al obtener estudiantes');
      }

      const data = await response.json();
      console.log(`✅ [StudentAPI] getPaymentStudents Success:`, data);
      return data;
    } catch (err) {
      console.error('❌ StudentAPI.getPaymentStudents:', err);
      throw err;
    }
  },

  /**
   * DEBTS - GET /api/v1/debts/stripe-payments
   * Obtener pagos desde Stripe
   * @param {string} token - Token de autenticacion
   * @param {string} search - Email, CURP o n_control (requerido)
   * @param {number|null} year - Ano especifico (opcional)
   * @param {boolean} forceRefresh - Forzar actualizacion del cache
   */
  async getStripePayments(token, search = '', year = null, forceRefresh = false) {
    try {
      const url = new URL(`${API_BASE}/debts/stripe-payments`);
      if (search) url.searchParams.append('search', search);
      if (year) url.searchParams.append('year', year);
      if (forceRefresh) url.searchParams.append('forceRefresh', 'true');

      console.log(`🔍 [StudentAPI] getStripePayments URL: ${url.toString()}`);

      const response = await fetch(url.toString(), {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-User-Role': 'financial-staff',
          'X-User-Permission': 'view.stripe.payments'
        }
      });

      console.log(`📡 [StudentAPI] getStripePayments Response Status: ${response.status}`);

      if (!response.ok) {
        const errorText = await response.text();
        console.error(`❌ [StudentAPI] getStripePayments Error Response:`, errorText);
        const errorData = JSON.parse(errorText || '{}');
        throw new Error(errorData.message || 'Error al cargar pagos de Stripe');
      }

      const data = await response.json();
      console.log(`✅ [StudentAPI] getStripePayments Success:`, data);
      return data;
    } catch (err) {
      console.error('❌ StudentAPI.getStripePayments:', err);
      throw err;
    }
  },

  /**
   * DEBTS - POST /api/v1/debts/validate
   * Validar un pago de Stripe
   * @param {string} search - Email, CURP o n_control del estudiante
   * @param {string} paymentIntentId - Payment Intent ID de Stripe
   * @param {string} token - Token de autenticacion
   */
  async validateStripePayment(search, paymentIntentId, token) {
    try {
      const response = await fetch(`${API_BASE}/debts/validate`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-User-Role': 'financial-staff',
          'X-User-Permission': 'validate.debt'
        },
        body: JSON.stringify({
          search,
          payment_intent_id: paymentIntentId
        })
      });

      if (!response.ok) {
        const errorText = await response.text();
        const errorData = JSON.parse(errorText || '{}');
        throw new Error(errorData.message || 'Error al validar pago');
      }

      return await response.json();
    } catch (err) {
      console.error('❌ StudentAPI.validateStripePayment:', err);
      throw err;
    }
  },

  /**
   * DEBTS - GET /api/v1/debts
   * Listar todos los pagos pendientes con paginación (para financial staff)
   * @param {string} token - Token de autenticación
   * @param {object} options - Opciones de búsqueda y paginación
   * @param {string} options.search - Búsqueda por CURP, email o n_control
   * @param {number} options.page - Página número (default: 1)
   * @param {number} options.perPage - Items por página (default: 15)
   * @param {boolean} options.forceRefresh - Forzar actualización del caché
   */
  async getAllPendingDebts(token, options = {}) {
    try {
      const {
        search = '',
        page = 1,
        perPage = 15,
        forceRefresh = false
      } = options;

      const params = new URL(`${API_BASE}/debts`);
      if (search) params.searchParams.append('search', search);
      params.searchParams.append('page', page);
      params.searchParams.append('perPage', perPage);
      if (forceRefresh) params.searchParams.append('forceRefresh', 'true');

      console.log(`🔍 [StudentAPI] getAllPendingDebts URL: ${params.toString()}`);

      const response = await fetch(params.toString(), {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-User-Role': 'financial-staff',
          'X-User-Permission': 'view.debts'
        }
      });

      console.log(`📡 [StudentAPI] getAllPendingDebts Response Status: ${response.status}`);

      if (!response.ok) {
        if (response.status === 401) {
          handleAuthError(401);
          throw new Error('No autenticado. Por favor inicia sesión.');
        }
        if (response.status === 403) {
          throw new Error('No tienes permiso para ver los adeudos.');
        }
        const errorText = await response.text();
        console.error(`❌ [StudentAPI] getAllPendingDebts Error Response:`, errorText);
        const errorData = JSON.parse(errorText || '{}');
        throw new Error(errorData.message || 'Error al obtener adeudos');
      }

      const data = await response.json();
      console.log(`✅ [StudentAPI] getAllPendingDebts Success:`, data);
      return data;
    } catch (err) {
      console.error('❌ StudentAPI.getAllPendingDebts:', err);
      throw err;
    }
  },

  /**
   * CAREERS - GET /api/v1/careers
   * Obtener lista de todas las carreras disponibles
   * @param {string} token - Token de autenticación
   * @param {object} options - Opciones
   * @param {boolean} options.forceRefresh - Forzar actualización del caché
   * @param {string} options.role - Rol del usuario
   * @param {string} options.permission - Permiso del usuario
   */
  async getCareers(token, options = {}) {
    try {
      const {
        forceRefresh = false,
        role = 'financial-staff',
        permission = 'view.careers'
      } = options;

      const params = new URL(`${API_BASE}/careers`);
      if (forceRefresh) params.searchParams.append('forceRefresh', 'true');

      console.log(`🔍 [StudentAPI] getCareers URL: ${params.toString()}`);

      const response = await fetch(params.toString(), {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-User-Role': role,
          'X-User-Permission': permission
        }
      });

      console.log(`📡 [StudentAPI] getCareers Response Status: ${response.status}`);

      if (!response.ok) {
        if (response.status === 401) {
          handleAuthError(401);
          throw new Error('No autenticado. Por favor inicia sesión.');
        }
        if (response.status === 403) {
          throw new Error('No tienes permiso para ver las carreras.');
        }
        const errorText = await response.text();
        console.error(`❌ [StudentAPI] getCareers Error Response:`, errorText);
        const errorData = JSON.parse(errorText || '{}');
        throw new Error(errorData.message || 'Error al obtener carreras');
      }

      const data = await response.json();
      console.log(`✅ [StudentAPI] getCareers Success:`, data);
      return data;
    } catch (err) {
      console.error('❌ StudentAPI.getCareers:', err);
      throw err;
    }
  }
};

// También disponible globalmente como window.StudentAPI para compatibilidad
window.StudentAPI = StudentAPI;
console.log('✅ StudentAPI cargado desde /public/studentAPI.js');
