/**
 * Student API Service - Public Global Script
 * Centraliza todas las llamadas API para páginas de estudiantes
 * Disponible como window.StudentAPI
 */

const API_BASE = 'https://nginx-production-728f.up.railway.app/api/v1';

function normalizeStudentPortalRole(role) {
  if (!role) return 'student';
  const roleLower = String(role).toLowerCase().trim();

  if (roleLower === 'student' || roleLower === 'estudiante') return 'student';
  if (roleLower === 'parent' || roleLower === 'padre') return 'parent';
  if (roleLower === 'applicant' || roleLower === 'solicitante') return 'student';

  return roleLower;
}

function shouldUseStudentId(effectiveRole, studentId) {
  return effectiveRole === 'parent' && !!studentId;
}

function getRoleFromStorage() {
  try {
    const rawUserData = localStorage.getItem('user_data');
    if (!rawUserData) return null;

    const parsedUser = JSON.parse(rawUserData);
    const roles = [];

    if (Array.isArray(parsedUser?.roles)) {
      roles.push(...parsedUser.roles);
    } else if (parsedUser?.roles) {
      roles.push(parsedUser.roles);
    }

    if (parsedUser?.role) roles.push(parsedUser.role);
    if (parsedUser?.role_name) roles.push(parsedUser.role_name);
    if (parsedUser?.type) roles.push(parsedUser.type);

    const firstValidRole = roles
      .map((item) => (typeof item === 'string' ? item : item?.name))
      .find(Boolean);

    return firstValidRole ? normalizeStudentPortalRole(firstValidRole) : null;
  } catch (error) {
    console.warn('No se pudo detectar rol desde user_data:', error);
    return null;
  }
}

function resolveStudentPortalRole(role) {
  const roleValue = typeof role === 'string' ? role.trim() : role;
  if (roleValue) {
    return normalizeStudentPortalRole(roleValue);
  }

  const storageRole = getRoleFromStorage();
  if (storageRole) return storageRole;
  return 'student';
}

function handleAuthError(statusCode) {
  if (statusCode === 401) {
    const currentToken = localStorage.getItem('access_token');
    console.warn('⚠️ 401 Unauthorized - Token:', currentToken ? 'present' : 'missing');
    const choice = confirm('❌ Error de autenticación (401)\n\n¿Deseas ir al login para re-autenticarte?');
    if (choice) {
      localStorage.removeItem('access_token');
      localStorage.removeItem('user_id');
      window.location.href = '/login';
    }
    return true;
  }
  return false;
}

function parseRetryAfterMs(retryAfterHeader) {
  const fallbackMs = 2000;
  if (!retryAfterHeader) return fallbackMs;

  const asNumber = Number(retryAfterHeader);
  if (!Number.isNaN(asNumber) && asNumber > 0) {
    return Math.max(500, Math.min(asNumber * 1000, 10000));
  }

  const asDate = Date.parse(retryAfterHeader);
  if (!Number.isNaN(asDate)) {
    const diff = asDate - Date.now();
    return Math.max(500, Math.min(diff, 10000));
  }

  return fallbackMs;
}

function wait(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

window.StudentAPI = {
  async getPaymentHistory(studentId, token, forceRefresh = false, role = 'student', perPage = 15, page = 1) {
    try {
      const effectiveRole = resolveStudentPortalRole(role);
      const url = new URL(shouldUseStudentId(effectiveRole, studentId) ? `${API_BASE}/payments/history/${studentId}` : `${API_BASE}/payments/history`);
      if (perPage) url.searchParams.append('perPage', String(perPage));
      if (page) url.searchParams.append('page', String(page));
      if (forceRefresh) url.searchParams.append('forceRefresh', 'true');

      const maxAttempts = 2;
      for (let attempt = 1; attempt <= maxAttempts; attempt++) {
        const response = await fetch(url.toString(), {
          method: 'GET',
          headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'X-User-Role': effectiveRole,
            'X-User-Permission': 'view.payments.history'
          }
        });

        if (response.status === 401) {
          handleAuthError(401);
          throw new Error('No autenticado - sesión expirada');
        }

        if (response.status === 429) {
          const retryAfterMs = parseRetryAfterMs(response.headers.get('Retry-After'));
          if (attempt < maxAttempts) {
            console.warn(`⚠️ 429 en historial. Reintentando en ${retryAfterMs}ms (intento ${attempt + 1}/${maxAttempts})`);
            await wait(retryAfterMs);
            continue;
          }
          throw new Error('Has excedido el límite de solicitudes, intenta nuevamente en unos segundos');
        }

        if (!response.ok) {
          const errorData = await response.json().catch(() => ({}));
          throw new Error(errorData.message || 'Error al cargar historial de pagos');
        }

        return await response.json();
      }

      throw new Error('No se pudo cargar el historial de pagos');
    } catch (err) {
      console.error('❌ StudentAPI.getPaymentHistory:', err);
      throw err;
    }
  },

  async getPaymentById(paymentId, token, role = 'student') {
    try {
      const effectiveRole = resolveStudentPortalRole(role);
      const endpoint = `${API_BASE}/payments/history/payment/${paymentId}`;
      const response = await fetch(endpoint, {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-User-Role': effectiveRole,
          'X-User-Permission': 'view.payments.history'
        }
      });
      if (response.status === 401) handleAuthError(401);
      if (!response.ok) throw new Error((await response.json()).message || 'Error');
      return await response.json();
    } catch (err) {
      console.error('❌ StudentAPI.getPaymentById:', err);
      throw err;
    }
  },

  async downloadPaymentReceipt(paymentId, token, role = 'student') {
    try {
      const effectiveRole = resolveStudentPortalRole(role);
      const endpoint = `${API_BASE}/payments/history/receipt/${paymentId}`;
      const response = await fetch(endpoint, {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Accept': 'application/pdf',
          'X-User-Role': effectiveRole,
          'X-User-Permission': 'view.receipt'
        }
      });

      if (response.status === 401) {
        handleAuthError(401);
        throw new Error('No autenticado - sesión expirada');
      }

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.message || 'Error al descargar el recibo');
      }

      const blob = await response.blob();
      const contentDisposition = response.headers.get('Content-Disposition') || '';
      const fileNameMatch = contentDisposition.match(/filename\*?=(?:UTF-8''|\")?([^\";]+)/i);
      const rawFileName = fileNameMatch?.[1] || `recibo-${paymentId}.pdf`;
      const fileName = decodeURIComponent(rawFileName).replace(/^\"|\"$/g, '');

      return {
        blob,
        fileName,
        contentType: response.headers.get('Content-Type') || 'application/pdf'
      };
    } catch (err) {
      console.warn('⚠️ StudentAPI.downloadPaymentReceipt fallback:', err?.message || err);
      throw err;
    }
  },

  async getPendingTotal(studentId, token, forceRefresh = false, role = 'student') {
    try {
      const effectiveRole = resolveStudentPortalRole(role);
      const url = new URL(shouldUseStudentId(effectiveRole, studentId) ? `${API_BASE}/dashboard/pending/${studentId}` : `${API_BASE}/dashboard/pending`);
      if (forceRefresh) url.searchParams.append('forceRefresh', 'true');
      const response = await fetch(url.toString(), {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-User-Role': effectiveRole,
          'X-User-Permission': 'view.own.pending.concepts.summary'
        }
      });
      if (!response.ok) throw new Error((await response.json()).message || 'Error');
      return await response.json();
    } catch (err) {
      console.error('❌ StudentAPI.getPendingTotal:', err);
      throw err;
    }
  },

  async getPaidTotal(studentId, token, forceRefresh = false, role = 'student') {
    try {
      const effectiveRole = resolveStudentPortalRole(role);
      const url = new URL(shouldUseStudentId(effectiveRole, studentId) ? `${API_BASE}/dashboard/paid/${studentId}` : `${API_BASE}/dashboard/paid`);
      if (forceRefresh) url.searchParams.append('forceRefresh', 'true');
      const response = await fetch(url.toString(), {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-User-Role': effectiveRole,
          'X-User-Permission': 'view.own.paid.concepts.summary'
        }
      });
      if (!response.ok) throw new Error((await response.json()).message || 'Error');
      return await response.json();
    } catch (err) {
      console.error('❌ StudentAPI.getPaidTotal:', err);
      throw err;
    }
  },

  async getOverdueTotal(studentId, token, forceRefresh = false, role = 'student') {
    try {
      const effectiveRole = resolveStudentPortalRole(role);
      const url = new URL(shouldUseStudentId(effectiveRole, studentId) ? `${API_BASE}/dashboard/overdue/${studentId}` : `${API_BASE}/dashboard/overdue`);
      if (forceRefresh) url.searchParams.append('forceRefresh', 'true');
      const response = await fetch(url.toString(), {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-User-Role': effectiveRole,
          'X-User-Permission': 'view.own.overdue.concepts.summary'
        }
      });
      if (!response.ok) throw new Error((await response.json()).message || 'Error');
      return await response.json();
    } catch (err) {
      console.error('❌ StudentAPI.getOverdueTotal:', err);
      throw err;
    }
  },

  async refreshDashboardCache(studentId, token, role = 'student') {
    try {
      const effectiveRole = resolveStudentPortalRole(role);
      const endpoint = shouldUseStudentId(effectiveRole, studentId) ? `${API_BASE}/dashboard/refresh/${studentId}` : `${API_BASE}/dashboard/refresh`;
      const response = await fetch(endpoint, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-User-Role': effectiveRole,
          'X-User-Permission': 'refresh.all.dashboard'
        }
      });
      if (!response.ok) throw new Error((await response.json()).message || 'Error');
      return await response.json();
    } catch (err) {
      console.error('❌ StudentAPI.refreshDashboardCache:', err);
      throw err;
    }
  },

  async getDashboardHistory(studentId, token, page = 1, perPage = 15, forceRefresh = false, role = 'student') {
    try {
      const effectiveRole = resolveStudentPortalRole(role);
      const endpoint = shouldUseStudentId(effectiveRole, studentId) ? `${API_BASE}/dashboard/history/${studentId}` : `${API_BASE}/dashboard/history`;
      const url = new URL(endpoint);
      url.searchParams.append('page', String(page));
      url.searchParams.append('perPage', String(perPage));
      if (forceRefresh) url.searchParams.append('forceRefresh', 'true');
      
      const response = await fetch(url.toString(), {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-User-Role': effectiveRole,
          'X-User-Permission': 'view.payments.summary'
        }
      });
      if (!response.ok) throw new Error((await response.json()).message || 'Error');
      return await response.json();
    } catch (err) {
      console.error('❌ StudentAPI.getDashboardHistory:', err);
      throw err;
    }
  },

  async getPendingPayments(studentId, token, forceRefresh = false, role = 'student') {
    try {
      const effectiveRole = resolveStudentPortalRole(role);
      const useStudentId = shouldUseStudentId(effectiveRole, studentId);
      // If studentId provided, use /pending-payments/{studentId}
      // Otherwise use /pending-payments for current user
      const endpoint = useStudentId ? `${API_BASE}/pending-payments/${studentId}` : `${API_BASE}/pending-payments`;
      console.log(`🔍 [StudentAPI] getPendingPayments - roleArg: ${role}, effectiveRole: ${effectiveRole}, useStudentId: ${useStudentId}, studentId: ${studentId}, forceRefresh: ${forceRefresh}`);
      console.log(`🔍 [StudentAPI] getPendingPayments - Endpoint: ${endpoint}, forceRefresh: ${forceRefresh}`);
      
      const url = new URL(endpoint);
      
      if (forceRefresh) {
        url.searchParams.append('forceRefresh', 'true');
      }
      
      console.log(`🔍 [StudentAPI] getPendingPayments URL final: ${url.toString()}`);
      
      const response = await fetch(url.toString(), {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-User-Role': effectiveRole,
          'X-User-Permission': 'view.pending.concepts'
        }
      });

      console.log(`📡 [StudentAPI] getPendingPayments Response Status: ${response.status}`);

      if (!response.ok) {
        const errorText = await response.text().catch(() => '');
        console.error(`❌ [StudentAPI] getPendingPayments Error Response (${response.status}):`, errorText);
        const errorData = errorText ? JSON.parse(errorText) : {};
        throw new Error(errorData.message || `Error ${response.status}: ${response.statusText}`);
      }

      const data = await response.json();
      console.log(`✅ [StudentAPI] getPendingPayments Success:`, data);
      return data;
    } catch (err) {
      console.error('❌ StudentAPI.getPendingPayments:', err);
      throw err;
    }
  },

  async getOverduePayments(studentId, token, forceRefresh = false, role = 'student') {
    try {
      const effectiveRole = resolveStudentPortalRole(role);
      // If studentId provided, use /pending-payments/overdue/{studentId}
      // Otherwise use /pending-payments/overdue for current user
      const endpoint = shouldUseStudentId(effectiveRole, studentId) ? `${API_BASE}/pending-payments/overdue/${studentId}` : `${API_BASE}/pending-payments/overdue`;
      console.log('📡 Fetching overdue payments from:', endpoint);
      
      const url = new URL(endpoint);
      if (forceRefresh) url.searchParams.append('forceRefresh', 'true');
      
      const response = await fetch(url.toString(), {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-User-Role': effectiveRole
        }
      });
      if (!response.ok) throw new Error((await response.json()).message || 'Error');
      return await response.json();
    } catch (err) {
      console.error('❌ StudentAPI.getOverduePayments:', err);
      throw err;
    }
  },

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
      if (!response.ok) throw new Error((await response.json()).message || 'Error');
      return await response.json();
    } catch (err) {
      console.error('❌ StudentAPI.getPaymentHistoryFull:', err);
      throw err;
    }
  },

  async getPaymentMethods(studentId, token, forceRefresh = false) {
    try {
      const effectiveRole = resolveStudentPortalRole('student');
      let endpoint = shouldUseStudentId(effectiveRole, studentId) ? `${API_BASE}/cards/${studentId}` : `${API_BASE}/cards`;
      if (forceRefresh) endpoint += (studentId ? '?' : '?') + 'forceRefresh=true';
      const response = await fetch(endpoint, {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-User-Role': effectiveRole
        }
      });
      if (!response.ok) throw new Error((await response.json()).message || 'Error');
      return await response.json();
    } catch (err) {
      console.error('❌ StudentAPI.getPaymentMethods:', err);
      throw err;
    }
  },

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
      if (!response.ok) throw new Error((await response.json()).message || 'Error');
      return await response.json();
    } catch (err) {
      console.error('❌ StudentAPI.getAuthenticatedUser:', err);
      throw err;
    }
  },

  async createPaymentIntent(conceptId, token) {
    try {
      const effectiveRole = resolveStudentPortalRole('student');
      const response = await fetch(`${API_BASE}/pending-payments`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-User-Role': effectiveRole
        },
        body: JSON.stringify({ concept_id: conceptId })
      });
      if (!response.ok) throw new Error((await response.json()).message || 'Error');
      return await response.json();
    } catch (err) {
      console.error('❌ StudentAPI.createPaymentIntent:', err);
      throw err;
    }
  },

  async getCareers(token, options = {}) {
    try {
      const { role = 'financial-staff', permission = 'view.careers' } = options;
      const response = await fetch(`${API_BASE}/careers`, {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-User-Role': role,
          'X-User-Permission': permission
        }
      });
      if (!response.ok) throw new Error((await response.json()).message || 'Error');
      return await response.json();
    } catch (err) {
      console.error('❌ StudentAPI.getCareers:', err);
      throw err;
    }
  },

  async getPaymentStudents(token, options = {}) {
    try {
      const { search = '', page = 1, perPage = 15, forceRefresh = false, role = 'financial-staff', permission = 'view.payments.student.summary' } = options;
      const params = new URL(`${API_BASE}/payments/students`);
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
          'X-User-Role': role,
          'X-User-Permission': permission
        }
      });
      if (!response.ok) throw new Error((await response.json()).message || 'Error');
      return await response.json();
    } catch (err) {
      console.error('❌ StudentAPI.getPaymentStudents:', err);
      throw err;
    }
  },

  async getAllPendingDebts(token, options = {}) {
    try {
      const { search = '', page = 1, perPage = 15, forceRefresh = false } = options;
      const params = new URL(`${API_BASE}/debts`);
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
          'X-User-Permission': 'view.debts'
        }
      });
      if (!response.ok) throw new Error((await response.json()).message || 'Error');
      return await response.json();
    } catch (err) {
      console.error('❌ StudentAPI.getAllPendingDebts:', err);
      throw err;
    }
  },

  async getStripePayments(token, search = '', year = null, forceRefresh = false) {
    try {
      const url = new URL(`${API_BASE}/debts/stripe-payments`);
      if (search) url.searchParams.append('search', search);
      if (year) url.searchParams.append('year', year);
      if (forceRefresh) url.searchParams.append('forceRefresh', 'true');
      
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
      if (!response.ok) throw new Error((await response.json()).message || 'Error');
      return await response.json();
    } catch (err) {
      console.error('❌ StudentAPI.getStripePayments:', err);
      throw err;
    }
  },

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
        body: JSON.stringify({ search, payment_intent_id: paymentIntentId })
      });
      if (!response.ok) throw new Error((await response.json()).message || 'Error');
      return await response.json();
    } catch (err) {
      console.error('❌ StudentAPI.validateStripePayment:', err);
      throw err;
    }
  },

  async getAllPayments(token, options = {}) {
    try {
      const { search = '', page = 1, perPage = 15, forceRefresh = false } = options;
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
      if (!response.ok) throw new Error((await response.json()).message || 'Error');
      return await response.json();
    } catch (err) {
      console.error('❌ StudentAPI.getAllPayments:', err);
      throw err;
    }
  },

  async getPaymentsByConcept(token, options = {}) {
    try {
      const { search = '', page = 1, perPage = 15, forceRefresh = false } = options;
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
      if (!response.ok) throw new Error((await response.json()).message || 'Error');
      return await response.json();
    } catch (err) {
      console.error('❌ StudentAPI.getPaymentsByConcept:', err);
      throw err;
    }
  }
};

console.log('✅ StudentAPI cargado desde /public/studentAPI.js (v20260215r6)');
