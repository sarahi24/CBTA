/**
 * Student API Service - Public Global Script
 * Centraliza todas las llamadas API para páginas de estudiantes
 * Disponible como window.StudentAPI
 */

const API_BASE_URL = (window.__API_BASE_URL__ || 'https://nginx-production-b390.up.railway.app/api').replace(/\/$/, '');
const API_BASE = `${API_BASE_URL}/v1`;

function normalizeStudentPortalRole(role) {
  if (!role) return 'student';
  const roleLower = String(role).toLowerCase().trim();

  if (roleLower === 'student' || roleLower === 'estudiante') return 'student';
  if (roleLower === 'parent' || roleLower === 'padre') return 'parent';
  if (roleLower === 'applicant' || roleLower === 'solicitante' || roleLower === 'aspirante') return 'applicant';
  if (roleLower === 'unverified' || roleLower === 'nverified' || roleLower === 'not_verified' || roleLower === 'sin_verificar' || roleLower === 'sin verificar') return 'unverified';

  return roleLower;
}

function shouldUseStudentId(effectiveRole, studentId) {
  return Number.isInteger(studentId) && studentId > 0;
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
  const normalizedRoleArg = roleValue ? normalizeStudentPortalRole(roleValue) : '';
  const storageRole = getRoleFromStorage();
  if (normalizedRoleArg && normalizedRoleArg !== 'student') return normalizedRoleArg;
  if (storageRole) return storageRole;
  if (normalizedRoleArg) return normalizedRoleArg;
  return 'student';
}

function resolveApiAccessRole(effectiveRole) {
  if (effectiveRole === 'parent') return 'parent';
  if (effectiveRole === 'applicant') return 'applicant';
  if (effectiveRole === 'unverified') return 'unverified';
  return 'student';
}

function getApiRoleCandidates(effectiveRole) {
  const primaryRole = resolveApiAccessRole(effectiveRole);
  if (primaryRole === 'applicant' || primaryRole === 'unverified') {
    return [primaryRole, 'student'];
  }
  return [primaryRole];
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

function buildAuthHeaders(token, role, permission = '') {
  const headers = {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-User-Role': role
  };

  if (permission) {
    headers['X-User-Permission'] = permission;
  }

  return headers;
}

function isSkippableFallbackStatus(statusCode) {
  return statusCode === 400 || statusCode === 403 || statusCode === 404 || statusCode === 405;
}

function isRateLimitedStatus(statusCode) {
  return statusCode === 429;
}

async function parseErrorMessage(response, fallback = 'Error') {
  const errorText = await response.text().catch(() => '');
  if (!errorText) return fallback;

  try {
    const parsed = JSON.parse(errorText);
    return parsed?.message || fallback;
  } catch (_) {
    return errorText;
  }
}

function pickReceiptUrl(payload) {
  const search = (value) => {
    if (!value) return null;
    if (typeof value === 'string') {
      return (value.startsWith('http://') || value.startsWith('https://')) ? value : null;
    }
    if (Array.isArray(value)) {
      for (const item of value) {
        const found = search(item);
        if (found) return found;
      }
      return null;
    }
    if (typeof value === 'object') {
      const direct = value.url || value.receipt_url || value.signed_url || value.link || value.href;
      const directFound = search(direct);
      if (directFound) return directFound;

      const nested = [value.data, value.result, value.receipt, value.payload];
      for (const item of nested) {
        const found = search(item);
        if (found) return found;
      }
    }
    return null;
  };

  return search(payload);
}

window.StudentAPI = {
  async getPaymentHistory(studentId, token, forceRefresh = false, role = 'student', perPage = 15, page = 1) {
    try {
      const effectiveRole = resolveStudentPortalRole(role);
      const apiRole = resolveApiAccessRole(effectiveRole);
      const endpointCandidates = [];
      const useIdRoute = shouldUseStudentId(effectiveRole, studentId) && effectiveRole !== 'applicant';
      if (useIdRoute) {
        endpointCandidates.push(`${API_BASE}/payments/history/${studentId}`);
      }
      endpointCandidates.push(`${API_BASE}/payments/history`);

      const maxAttempts = 2;

      for (let endpointIndex = 0; endpointIndex < endpointCandidates.length; endpointIndex++) {
        const endpoint = endpointCandidates[endpointIndex];
        const url = new URL(endpoint);
        if (perPage) url.searchParams.append('perPage', String(perPage));
        if (page) url.searchParams.append('page', String(page));
        if (forceRefresh) url.searchParams.append('forceRefresh', 'true');

        for (let attempt = 1; attempt <= maxAttempts; attempt++) {
          const response = await fetch(url.toString(), {
            method: 'GET',
            headers: {
              'Authorization': `Bearer ${token}`,
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'X-User-Role': apiRole,
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

          if (response.ok) {
            return await response.json();
          }

          if ((response.status === 403 || response.status === 404) && endpointIndex < endpointCandidates.length - 1) {
            break;
          }

          if (response.status === 403 && effectiveRole === 'applicant') {
            console.warn('⚠️ Historial no disponible para solicitante (403). Regresando respuesta vacía controlada.');
            return {
              success: true,
              data: {
                payment_history: {
                  items: [],
                  currentPage: Number(page) || 1,
                  lastPage: 1,
                  perPage: Number(perPage) || 15,
                  total: 0,
                  hasMorePages: false,
                  nextPage: null,
                  previousPage: null
                }
              },
              message: 'Historial no disponible para solicitante'
            };
          }

          const errorData = await response.json().catch(() => ({}));
          throw new Error(errorData.message || 'Error al cargar historial de pagos');
        }
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
      const apiRole = resolveApiAccessRole(effectiveRole);
      const endpoint = `${API_BASE}/payments/history/payment/${paymentId}`;
      const response = await fetch(endpoint, {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-User-Role': apiRole,
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
      const apiRole = resolveApiAccessRole(effectiveRole);
      const endpoint = `/api/receipts/${paymentId}?_=${Date.now()}`;
      const response = await fetch(endpoint, {
        method: 'GET',
        cache: 'no-store',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Accept': 'application/json',
          'X-User-Role': apiRole,
          'X-User-Permission': 'view.receipt'
        }
      });

      if (response.status === 401) {
        handleAuthError(401);
        throw new Error('No autenticado - sesión expirada');
      }

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.message || 'Error al obtener el recibo');
      }

      const payload = await response.json().catch(() => ({}));
      const data = payload?.data || {};
      const receiptUrl = pickReceiptUrl(payload);

      if (!receiptUrl) {
        throw new Error(payload?.message || 'No se recibió URL del recibo');
      }

      return {
        url: receiptUrl,
        expiresIn: data.expires_in ?? null,
        contentType: data.content_type || null,
        message: payload?.message || ''
      };
    } catch (err) {
      console.warn('⚠️ StudentAPI.downloadPaymentReceipt fallback:', err?.message || err);
      throw err;
    }
  },

  async getPendingTotal(studentId, token, forceRefresh = false, role = 'student') {
    try {
      const effectiveRole = resolveStudentPortalRole(role);
      const apiRoles = getApiRoleCandidates(effectiveRole);
      const useIdRoute = shouldUseStudentId(effectiveRole, studentId);
      const endpointCandidates = [
        ...(useIdRoute ? [`${API_BASE}/dashboard/pending/${studentId}`] : []),
        `${API_BASE}/dashboard/pending`
      ];

      for (const endpoint of endpointCandidates) {
        const url = new URL(endpoint);
        if (forceRefresh) url.searchParams.append('forceRefresh', 'true');

        for (const apiRole of apiRoles) {

          const withPermission = await fetch(url.toString(), {
            method: 'GET',
            headers: buildAuthHeaders(token, apiRole, 'view.own.pending.concepts.summary')
          });

          if (isRateLimitedStatus(withPermission.status)) {
            console.warn('⚠️ getPendingTotal 429. Se devuelve total en 0 para evitar sobrecargar la API.');
            return { success: true, data: { total_pending: { totalAmount: '0.00', totalCount: 0 } } };
          }

          if (withPermission.status === 401) handleAuthError(401);
          if (withPermission.ok) return await withPermission.json();
          if (!isSkippableFallbackStatus(withPermission.status)) {
            throw new Error(await parseErrorMessage(withPermission, 'Error'));
          }

          const withoutPermission = await fetch(url.toString(), {
            method: 'GET',
            headers: buildAuthHeaders(token, apiRole)
          });

          if (isRateLimitedStatus(withoutPermission.status)) {
            console.warn('⚠️ getPendingTotal 429. Se devuelve total en 0 para evitar sobrecargar la API.');
            return { success: true, data: { total_pending: { totalAmount: '0.00', totalCount: 0 } } };
          }

          if (withoutPermission.status === 401) handleAuthError(401);
          if (withoutPermission.ok) return await withoutPermission.json();
          if (!isSkippableFallbackStatus(withoutPermission.status)) {
            throw new Error(await parseErrorMessage(withoutPermission, 'Error'));
          }
        }
      }

      console.warn(`⚠️ getPendingTotal 403 para rol ${effectiveRole}. Se devuelve total en 0.`);
      return { success: true, data: { total_pending: { totalAmount: '0.00', totalCount: 0 } } };
    } catch (err) {
      console.error('❌ StudentAPI.getPendingTotal:', err);
      throw err;
    }
  },

  async getPaidTotal(studentId, token, forceRefresh = false, role = 'student') {
    try {
      const effectiveRole = resolveStudentPortalRole(role);
      const apiRoles = getApiRoleCandidates(effectiveRole);
      const useIdRoute = shouldUseStudentId(effectiveRole, studentId);
      const endpointCandidates = [
        ...(useIdRoute ? [`${API_BASE}/dashboard/paid/${studentId}`] : []),
        `${API_BASE}/dashboard/paid`
      ];

      for (const endpoint of endpointCandidates) {
        const url = new URL(endpoint);
        if (forceRefresh) url.searchParams.append('forceRefresh', 'true');

        for (const apiRole of apiRoles) {

          const withPermission = await fetch(url.toString(), {
            method: 'GET',
            headers: buildAuthHeaders(token, apiRole, 'view.own.paid.concepts.summary')
          });

          if (isRateLimitedStatus(withPermission.status)) {
            console.warn('⚠️ getPaidTotal 429. Se devuelve total en 0 para evitar sobrecargar la API.');
            return { success: true, data: { paid_data: { totalPayments: '0.00', paymentsByMonth: {} } } };
          }

          if (withPermission.status === 401) handleAuthError(401);
          if (withPermission.ok) return await withPermission.json();
          if (!isSkippableFallbackStatus(withPermission.status)) {
            throw new Error(await parseErrorMessage(withPermission, 'Error'));
          }

          const withoutPermission = await fetch(url.toString(), {
            method: 'GET',
            headers: buildAuthHeaders(token, apiRole)
          });

          if (isRateLimitedStatus(withoutPermission.status)) {
            console.warn('⚠️ getPaidTotal 429. Se devuelve total en 0 para evitar sobrecargar la API.');
            return { success: true, data: { paid_data: { totalPayments: '0.00', paymentsByMonth: {} } } };
          }

          if (withoutPermission.status === 401) handleAuthError(401);
          if (withoutPermission.ok) return await withoutPermission.json();
          if (!isSkippableFallbackStatus(withoutPermission.status)) {
            throw new Error(await parseErrorMessage(withoutPermission, 'Error'));
          }
        }
      }

      console.warn(`⚠️ getPaidTotal 403 para rol ${effectiveRole}. Se devuelve total en 0.`);
      return { success: true, data: { paid_data: { totalPayments: '0.00', paymentsByMonth: {} } } };
    } catch (err) {
      console.error('❌ StudentAPI.getPaidTotal:', err);
      throw err;
    }
  },

  async getOverdueTotal(studentId, token, forceRefresh = false, role = 'student') {
    try {
      const effectiveRole = resolveStudentPortalRole(role);
      const apiRoles = getApiRoleCandidates(effectiveRole);
      const useIdRoute = shouldUseStudentId(effectiveRole, studentId);
      const endpointCandidates = [
        ...(useIdRoute ? [`${API_BASE}/dashboard/overdue/${studentId}`] : []),
        `${API_BASE}/dashboard/overdue`
      ];

      for (const endpoint of endpointCandidates) {
        const url = new URL(endpoint);
        if (forceRefresh) url.searchParams.append('forceRefresh', 'true');

        for (const apiRole of apiRoles) {

          const withPermission = await fetch(url.toString(), {
            method: 'GET',
            headers: buildAuthHeaders(token, apiRole, 'view.own.overdue.concepts.summary')
          });

          if (isRateLimitedStatus(withPermission.status)) {
            console.warn('⚠️ getOverdueTotal 429. Se devuelve total en 0 para evitar sobrecargar la API.');
            return { success: true, data: { total_overdue: { totalAmount: '0.00', totalCount: 0 } } };
          }

          if (withPermission.status === 401) handleAuthError(401);
          if (withPermission.ok) return await withPermission.json();
          if (!isSkippableFallbackStatus(withPermission.status)) {
            throw new Error(await parseErrorMessage(withPermission, 'Error'));
          }

          const withoutPermission = await fetch(url.toString(), {
            method: 'GET',
            headers: buildAuthHeaders(token, apiRole)
          });

          if (isRateLimitedStatus(withoutPermission.status)) {
            console.warn('⚠️ getOverdueTotal 429. Se devuelve total en 0 para evitar sobrecargar la API.');
            return { success: true, data: { total_overdue: { totalAmount: '0.00', totalCount: 0 } } };
          }

          if (withoutPermission.status === 401) handleAuthError(401);
          if (withoutPermission.ok) return await withoutPermission.json();
          if (!isSkippableFallbackStatus(withoutPermission.status)) {
            throw new Error(await parseErrorMessage(withoutPermission, 'Error'));
          }
        }
      }

      console.warn(`⚠️ getOverdueTotal 403 para rol ${effectiveRole}. Se devuelve total en 0.`);
      return { success: true, data: { total_overdue: { totalAmount: '0.00', totalCount: 0 } } };
    } catch (err) {
      console.error('❌ StudentAPI.getOverdueTotal:', err);
      throw err;
    }
  },

  async refreshDashboardCache(studentId, token, role = 'student') {
    try {
      const effectiveRole = resolveStudentPortalRole(role);
      const apiRole = resolveApiAccessRole(effectiveRole);

      const endpoint = shouldUseStudentId(effectiveRole, studentId) ? `${API_BASE}/dashboard/refresh/${studentId}` : `${API_BASE}/dashboard/refresh`;
      const response = await fetch(endpoint, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-User-Role': apiRole,
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
      const apiRole = resolveApiAccessRole(effectiveRole);
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
          'X-User-Role': apiRole,
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

      const apiRoles = getApiRoleCandidates(effectiveRole);
      const useIdRoute = shouldUseStudentId(effectiveRole, studentId);
      const endpointCandidates = [
        ...(useIdRoute ? [`${API_BASE}/pending-payments/${studentId}`] : []),
        `${API_BASE}/pending-payments`
      ];

      console.log(`🔍 [StudentAPI] getPendingPayments - roleArg: ${role}, effectiveRole: ${effectiveRole}, apiRoles: ${apiRoles.join(',')}, studentId: ${studentId}, forceRefresh: ${forceRefresh}`);

      for (const rawEndpoint of endpointCandidates) {
        const url = new URL(rawEndpoint);
        if (forceRefresh) url.searchParams.set('forceRefresh', 'true');

        console.log(`🔍 [StudentAPI] getPendingPayments probando: ${url.toString()}`);

        for (const apiRole of apiRoles) {

          const withPermission = await fetch(url.toString(), {
            method: 'GET',
            headers: buildAuthHeaders(token, apiRole, 'view.pending.concepts')
          });

          console.log(`📡 [StudentAPI] getPendingPayments status (perm:${apiRole}): ${withPermission.status}`);
          if (isRateLimitedStatus(withPermission.status)) {
            console.warn('⚠️ getPendingPayments 429. Se devuelve lista vacía para evitar sobrecargar la API.');
            return { success: true, data: { pending_payments: [] } };
          }
          if (withPermission.status === 401) handleAuthError(401);
          if (withPermission.ok) {
            const data = await withPermission.json();
            console.log(`✅ [StudentAPI] getPendingPayments Success (perm:${apiRole}):`, data);
            return data;
          }
          if (!isSkippableFallbackStatus(withPermission.status)) {
            throw new Error(await parseErrorMessage(withPermission, `Error ${withPermission.status}: ${withPermission.statusText}`));
          }

          const withoutPermission = await fetch(url.toString(), {
            method: 'GET',
            headers: buildAuthHeaders(token, apiRole)
          });

          console.log(`📡 [StudentAPI] getPendingPayments status (sin perm:${apiRole}): ${withoutPermission.status}`);
          if (isRateLimitedStatus(withoutPermission.status)) {
            console.warn('⚠️ getPendingPayments 429. Se devuelve lista vacía para evitar sobrecargar la API.');
            return { success: true, data: { pending_payments: [] } };
          }
          if (withoutPermission.status === 401) handleAuthError(401);
          if (withoutPermission.ok) {
            const data = await withoutPermission.json();
            console.log(`✅ [StudentAPI] getPendingPayments Success (sin perm:${apiRole}):`, data);
            return data;
          }
          if (!isSkippableFallbackStatus(withoutPermission.status)) {
            throw new Error(await parseErrorMessage(withoutPermission, `Error ${withoutPermission.status}: ${withoutPermission.statusText}`));
          }
        }
      }

      console.warn(`⚠️ getPendingPayments 403 para rol ${effectiveRole}. Se devuelve lista vacía.`);
      return { success: true, data: { pending_payments: [] } };
    } catch (err) {
      console.error('❌ StudentAPI.getPendingPayments:', err);
      throw err;
    }
  },

  async getOverduePayments(studentId, token, forceRefresh = false, role = 'student') {
    try {
      const effectiveRole = resolveStudentPortalRole(role);

      const apiRoles = getApiRoleCandidates(effectiveRole);
      const useIdRoute = shouldUseStudentId(effectiveRole, studentId);
      const endpointCandidates = [
        ...(useIdRoute ? [`${API_BASE}/pending-payments/overdue/${studentId}`] : []),
        `${API_BASE}/pending-payments/overdue`
      ];

      for (const rawEndpoint of endpointCandidates) {
        const url = new URL(rawEndpoint);
        if (forceRefresh) url.searchParams.set('forceRefresh', 'true');

        console.log('📡 Fetching overdue payments from:', url.toString());

        for (const apiRole of apiRoles) {

          const withPermission = await fetch(url.toString(), {
            method: 'GET',
            headers: buildAuthHeaders(token, apiRole, 'view.overdue.concepts')
          });

          if (isRateLimitedStatus(withPermission.status)) {
            console.warn('⚠️ getOverduePayments 429. Se devuelve lista vacía para evitar sobrecargar la API.');
            return { success: true, data: { overdue_payments: [] } };
          }

          if (withPermission.status === 401) handleAuthError(401);
          if (withPermission.ok) return await withPermission.json();
          if (!isSkippableFallbackStatus(withPermission.status)) {
            throw new Error(await parseErrorMessage(withPermission, 'Error'));
          }

          const withoutPermission = await fetch(url.toString(), {
            method: 'GET',
            headers: buildAuthHeaders(token, apiRole)
          });

          if (isRateLimitedStatus(withoutPermission.status)) {
            console.warn('⚠️ getOverduePayments 429. Se devuelve lista vacía para evitar sobrecargar la API.');
            return { success: true, data: { overdue_payments: [] } };
          }

          if (withoutPermission.status === 401) handleAuthError(401);
          if (withoutPermission.ok) return await withoutPermission.json();
          if (!isSkippableFallbackStatus(withoutPermission.status)) {
            throw new Error(await parseErrorMessage(withoutPermission, 'Error'));
          }
        }
      }

      console.warn(`⚠️ getOverduePayments 403 para rol ${effectiveRole}. Se devuelve lista vacía.`);
      return { success: true, data: { overdue_payments: [] } };
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

  async getPaymentMethods(studentId, token, forceRefresh = false, role = 'student') {
    try {
      const effectiveRole = resolveStudentPortalRole(role);

      const endpointCandidates = [
        `${API_BASE}/cards`,
        ...(studentId ? [`${API_BASE}/cards/${studentId}`] : [])
      ];

      for (const endpoint of endpointCandidates) {
        const url = new URL(endpoint);
        if (forceRefresh) url.searchParams.set('forceRefresh', 'true');

        const withPermission = await fetch(url.toString(), {
          method: 'GET',
          headers: buildAuthHeaders(token, effectiveRole, 'view.cards')
        });

        if (withPermission.status === 401) handleAuthError(401);
        if (withPermission.ok) return await withPermission.json();
        if (withPermission.status !== 403 && withPermission.status !== 404) {
          throw new Error(await parseErrorMessage(withPermission, 'Error'));
        }

        const withoutPermission = await fetch(url.toString(), {
          method: 'GET',
          headers: buildAuthHeaders(token, effectiveRole)
        });

        if (withoutPermission.status === 401) handleAuthError(401);
        if (withoutPermission.ok) return await withoutPermission.json();
        if (withoutPermission.status !== 403 && withoutPermission.status !== 404) {
          throw new Error(await parseErrorMessage(withoutPermission, 'Error'));
        }
      }

      return { success: true, data: { cards: [] } };
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

console.log('✅ StudentAPI cargado desde /public/studentAPI.js (v20260215r30)');
