/**
 * Student API Service
 * Centraliza todas las llamadas API para páginas de estudiantes
 * Endpoints: Dashboard, Adeudos, Historial, Tarjetas, Perfil
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
   */
  async getPendingTotal(studentId, token) {
    try {
      const endpoint = studentId ? `${API_BASE}/dashboard/pending/${studentId}` : `${API_BASE}/dashboard/pending`;
      const response = await fetch(endpoint, {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
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
   */
  async getPaidTotal(studentId, token) {
    try {
      const endpoint = studentId ? `${API_BASE}/dashboard/paid/${studentId}` : `${API_BASE}/dashboard/paid`;
      const response = await fetch(endpoint, {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
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
   */
  async getOverdueTotal(studentId, token) {
    try {
      const endpoint = studentId ? `${API_BASE}/dashboard/overdue/${studentId}` : `${API_BASE}/dashboard/overdue`;
      const response = await fetch(endpoint, {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
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
   * DASHBOARD - POST /api/v1/dashboard/refresh/{studentId?}
   * Limpiar caché del dashboard
   */
  async refreshDashboardCache(studentId, token) {
    try {
      const endpoint = studentId ? `${API_BASE}/dashboard/refresh/${studentId}` : `${API_BASE}/dashboard/refresh`;
      const response = await fetch(endpoint, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        }
      });

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.message || 'Error al limpiar caché');
      }

      return await response.json();
    } catch (err) {
      console.error('❌ StudentAPI.refreshDashboardCache:', err);
      throw err;
    }
  },

  /**
   * ADEUDOS - GET /api/v1/pending-payments/{studentId?}
   * Obtener pagos pendientes del usuario autenticado
   * @param {number|null} studentId - ID del estudiante (opcional para padres con múltiples hijos)
   * @param {string} token - Token de autenticación
   * @param {boolean} forceRefresh - Forzar actualización del caché
   * @param {string} role - Rol del usuario (student|parent)
   */
  async getPendingPayments(studentId, token, forceRefresh = false, role = 'student') {
    try {
      const url = new URL(studentId ? `${API_BASE}/pending-payments/${studentId}` : `${API_BASE}/pending-payments`);
      
      // Agregar query parameters
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
          'X-User-Permission': 'view.pending.concepts'
        }
      });

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.message || 'Error al cargar pagos pendientes');
      }

      return await response.json();
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
      const url = new URL(studentId ? `${API_BASE}/pending-payments/overdue/${studentId}` : `${API_BASE}/pending-payments/overdue`);
      
      // Agregar query parameters
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
          'X-User-Permission': 'view.overdue.concepts'
        }
      });

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.message || 'Error al cargar pagos vencidos');
      }

      return await response.json();
    } catch (err) {
      console.error('❌ StudentAPI.getOverduePayments:', err);
      throw err;
    }
  },

  /**
   * ADEUDOS - POST /api/v1/pending-payments
   * Generar intento de pago para un concepto pendiente
   * @param {number} conceptId - ID del concepto a pagar
   * @param {string} token - Token de autenticación
   * @param {string} role - Rol del usuario (student|parent)
   */
  async createPaymentAttempt(conceptId, token, role = 'student') {
    try {
      const response = await fetch(`${API_BASE}/pending-payments`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-User-Role': role,
          'X-User-Permission': 'create.payment'
        },
        body: JSON.stringify({ concept_id: conceptId })
      });

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.message || 'Error al crear intento de pago');
      }

      return await response.json();
    } catch (err) {
      console.error('❌ StudentAPI.createPaymentAttempt:', err);
      throw err;
    }
  },

  /**
   * HISTORIAL - GET /api/v1/history/{studentId?}
   * Obtener historial de pagos del usuario autenticado
   */
  async getPaymentHistoryFull(studentId, token) {
    try {
      const endpoint = studentId ? `${API_BASE}/history/${studentId}` : `${API_BASE}/history`;
      const response = await fetch(endpoint, {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        }
      });

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.message || 'Error al cargar historial completo');
      }

      return await response.json();
    } catch (err) {
      console.error('❌ StudentAPI.getPaymentHistoryFull:', err);
      throw err;
    }
  },

  /**
   * HISTORIAL - GET /api/v1/history/payment/{id}
   * Buscar pago por ID
   */
  async getPaymentById(paymentId, token) {
    try {
      const response = await fetch(`${API_BASE}/history/payment/${paymentId}`, {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        }
      });

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.message || 'Error al cargar pago');
      }

      return await response.json();
    } catch (err) {
      console.error('❌ StudentAPI.getPaymentById:', err);
      throw err;
    }
  },

  /**
   * TARJETAS - GET /api/v1/cards/{studentId?}
   * Listar métodos de pago del usuario autenticado
   */
  async getPaymentMethods(studentId, token, forceRefresh = false) {
    try {
      let endpoint = studentId ? `${API_BASE}/cards/${studentId}` : `${API_BASE}/cards`;
      if (forceRefresh) {
        endpoint += (studentId ? '?' : '?') + 'forceRefresh=true';
      }
      const response = await fetch(endpoint, {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-User-Role': 'student',
          'X-User-Permission': 'delete.card'
        }
      });

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.message || 'Error al cargar métodos de pago');
      }

      return await response.json();
    } catch (err) {
      console.error('❌ StudentAPI.getPaymentMethods:', err);
      throw err;
    }
  },

  /**
   * TARJETAS - POST /api/v1/cards
   * Registrar un nuevo método de pago
   */
  async createPaymentMethod(cardData, token) {
    try {
      const response = await fetch(`${API_BASE}/cards`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: JSON.stringify(cardData)
      });

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.message || 'Error al registrar método de pago');
      }

      return await response.json();
    } catch (err) {
      console.error('❌ StudentAPI.createPaymentMethod:', err);
      throw err;
    }
  },

  /**
   * TARJETAS - DELETE /api/v1/cards/{paymentMethodId}
   * Eliminar un método de pago
   */
  async deletePaymentMethod(paymentMethodId, token) {
    try {
      const response = await fetch(`${API_BASE}/cards/${paymentMethodId}`, {
        method: 'DELETE',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        }
      });

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.message || 'Error al eliminar método de pago');
      }

      return await response.json();
    } catch (err) {
      console.error('❌ StudentAPI.deletePaymentMethod:', err);
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
   * PERFIL - PATCH /api/v1/users/update
   * Actualizar datos generales del usuario
   */
  async updateUserProfile(userData, token) {
    try {
      const response = await fetch(`${API_BASE}/users/update`, {
        method: 'PATCH',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: JSON.stringify(userData)
      });

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.message || 'Error al actualizar perfil');
      }

      return await response.json();
    } catch (err) {
      console.error('❌ StudentAPI.updateUserProfile:', err);
      throw err;
    }
  },

  /**
   * PERFIL - PATCH /api/v1/users/update/password
   * Actualizar contraseña del usuario
   */
  async updatePassword(passwordData, token) {
    try {
      const response = await fetch(`${API_BASE}/users/update/password`, {
        method: 'PATCH',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: JSON.stringify(passwordData)
      });

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.message || 'Error al actualizar contraseña');
      }

      return await response.json();
    } catch (err) {
      console.error('❌ StudentAPI.updatePassword:', err);
      throw err;
    }
  },

  /**
   * ADDITIONAL - GET /api/v1/payments
   * Obtener lista de pagos
   */
  async getAllPayments(token) {
    try {
      const response = await fetch(`${API_BASE}/payments`, {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        }
      });

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.message || 'Error al cargar pagos');
      }

      return await response.json();
    } catch (err) {
      console.error('❌ StudentAPI.getAllPayments:', err);
      throw err;
    }
  },

  /**
   * ADDITIONAL - GET /api/v1/payments/by-concept
   * Obtener lista de pagos por concepto
   */
  async getPaymentsByConcept(token) {
    try {
      const response = await fetch(`${API_BASE}/payments/by-concept`, {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        }
      });

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.message || 'Error al cargar pagos por concepto');
      }

      return await response.json();
    } catch (err) {
      console.error('❌ StudentAPI.getPaymentsByConcept:', err);
      throw err;
    }
  }
};
