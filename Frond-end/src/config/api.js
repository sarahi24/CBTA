// API Configuration
export const API_BASE_URL = 'https://nginx-production-728f.up.railway.app/api';

// API Endpoints organizados por categoría según la documentación oficial
export const API_ENDPOINTS = {
  // Auth - Autenticación
  auth: {
    login: `${API_BASE_URL}/v1/auth/login`,
    register: `${API_BASE_URL}/v1/auth/register`,
    logout: `${API_BASE_URL}/v1/logout`,
    refresh: `${API_BASE_URL}/v1/auth/refresh`,
    forgotPassword: `${API_BASE_URL}/forgot-password`,
    verifyEmail: (id, hash) => `${API_BASE_URL}/verify-email/${id}/${hash}`,
    resetPassword: `${API_BASE_URL}/reset-password`,
  },

  // Admin Actions - Acciones administrativas
  adminActions: {
    register: `${API_BASE_URL}/v1/admin-actions/register`,
    promotion: `${API_BASE_URL}/v1/admin-actions/promotion`,
    attachStudent: `${API_BASE_URL}/v1/admin-actions/attach-student`,
    getStudent: (id) => `${API_BASE_URL}/v1/admin-actions/get-student/${id}`,
    updateStudent: (id) => `${API_BASE_URL}/v1/admin-actions/update-student/${id}`,
    import: `${API_BASE_URL}/v1/admin-actions/import`,
    importStudents: `${API_BASE_URL}/v1/admin-actions/import-students`,
    showUsers: `${API_BASE_URL}/v1/admin-actions/showUsers`,
    deleteUsers: `${API_BASE_URL}/v1/admin-actions/delete-users`,
    disableUsers: `${API_BASE_URL}/v1/admin-actions/disable-users`,
    temporaryDisableUsers: `${API_BASE_URL}/v1/admin-actions/temporary-disable-users`,
    findPermissions: `${API_BASE_URL}/v1/admin-actions/find-permissions`,
    findRoles: `${API_BASE_URL}/v1/admin-actions/find-roles`,
    getRoleById: (id) => `${API_BASE_URL}/v1/admin-actions/roles/${id}`,
  },

  // Users - Usuarios
  users: {
    getAuthenticated: `${API_BASE_URL}/v1/users/user`,
    updatePassword: `${API_BASE_URL}/v1/users/update-password`,
    update: `${API_BASE_URL}/v1/users/update`,
    list: `${API_BASE_URL}/v1/admin-actions/showUsers`, // Alias
  },

  // Careers - Carreras
  careers: {
    list: `${API_BASE_URL}/v1/careers`,
    create: `${API_BASE_URL}/v1/careers`,
    get: (id) => `${API_BASE_URL}/v1/careers/${id}`,
    update: (id) => `${API_BASE_URL}/v1/careers/${id}`,
    delete: (id) => `${API_BASE_URL}/v1/careers/${id}`,
  },

  // Students - Estudiantes
  students: {
    list: `${API_BASE_URL}/v1/students`,
    get: (id) => `${API_BASE_URL}/v1/students/${id}`,
  },

  // Payment Concepts - Conceptos de pago
  concepts: {
    list: `${API_BASE_URL}/v1/concepts`,
    create: `${API_BASE_URL}/v1/concepts`,
    get: (id) => `${API_BASE_URL}/v1/concepts/${id}`,
    update: (id) => `${API_BASE_URL}/v1/concepts/${id}`,
    delete: (id) => `${API_BASE_URL}/v1/concepts/${id}`,
    updateRelations: (id) => `${API_BASE_URL}/v1/concepts/update-relations/${id}`,
    finalize: (conceptId) => `${API_BASE_URL}/v1/concepts/${conceptId}/finalize`,
    disable: (conceptId) => `${API_BASE_URL}/v1/concepts/${conceptId}/disable`,
    activate: (conceptId) => `${API_BASE_URL}/v1/concepts/${conceptId}/activate`,
    deleteLogical: (conceptId) => `${API_BASE_URL}/v1/concepts/${conceptId}/logical`,
  },

  // Payments - Pagos
  payments: {
    list: `${API_BASE_URL}/v1/payments`,
    byConcept: `${API_BASE_URL}/v1/payments/by-concept`,
  },

  // Debts - Deudas
  debts: {
    list: `${API_BASE_URL}/v1/debts`,
    stripePayments: `${API_BASE_URL}/v1/debts/stripe-payments`,
    validate: `${API_BASE_URL}/v1/debts/validate`,
  },

  // Pending Payments - Pagos pendientes
  pendingPayments: {
    getByUser: (id) => `${API_BASE_URL}/v1/pending-payments/${id}`,
    create: `${API_BASE_URL}/v1/pending-payments`,
    getOverdue: (id) => `${API_BASE_URL}/v1/pending-payments/overdue/${id}`,
  },

  // Payment History - Historial de pagos
  paymentHistory: {
    get: (id) => `${API_BASE_URL}/v1/history/${id}`,
    getPayment: (id) => `${API_BASE_URL}/v1/history/payment/${id}`,
  },

  // Dashboard - Panel de control del usuario
  dashboard: {
    refresh: `${API_BASE_URL}/v1/dashboard/refresh`,
    history: (id) => `${API_BASE_URL}/v1/dashboard/history/${id}`,
    overdue: (id) => `${API_BASE_URL}/v1/dashboard/overdue/${id}`,
    paid: (id) => `${API_BASE_URL}/v1/dashboard/paid/${id}`,
    pending: (id) => `${API_BASE_URL}/v1/dashboard/pending/${id}`,
  },

  // Dashboard Staff - Panel de control del personal
  dashboardStaff: {
    refreshCache: `${API_BASE_URL}/v1/cache/refresh`,
    concepts: `${API_BASE_URL}/v1/dashboard-staff/concepts`,
    payments: `${API_BASE_URL}/v1/dashboard-staff/payments`,
    students: `${API_BASE_URL}/v1/dashboard-staff/students`,
    pending: `${API_BASE_URL}/v1/dashboard-staff/pending`,
    payout: `${API_BASE_URL}/v1/dashboard-staff/payout`,
  },

  // Cards - Métodos de pago (tarjetas)
  cards: {
    list: (id) => `${API_BASE_URL}/v1/cards/${id}`,
    create: `${API_BASE_URL}/v1/cards`,
    delete: (paymentMethodId) => `${API_BASE_URL}/v1/cards/${paymentMethodId}`,
  },

  // Parents - Padres/Tutores
  parents: {
    invite: `${API_BASE_URL}/v1/parents/invite`,
    getChildren: `${API_BASE_URL}/v1/parents/get-children`,
    getParents: `${API_BASE_URL}/v1/parents/get-parents`,
    deleteRelation: (parentId) => `${API_BASE_URL}/v1/parents/delete-parent/${parentId}`,
  },

  // Notifications - Notificaciones
  notifications: {
    list: `${API_BASE_URL}/v1/notifications`,
    unread: `${API_BASE_URL}/v1/notifications/unread`,
    markAsRead: `${API_BASE_URL}/v1/notifications/mark-as-read`,
    delete: (id) => `${API_BASE_URL}/v1/notifications/${id}`,
  },
};

// Helper functions para manejar respuestas de la API
export const handleAPIResponse = async (response) => {
  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw {
      status: response.status,
      message: error.message || 'Error en la petición',
      code: error.code,
      errors: error.errors
    };
  }
  return response.json();
};

// Función para construir query strings
export const buildQueryString = (params) => {
  const query = new URLSearchParams();
  Object.entries(params).forEach(([key, value]) => {
    if (value !== undefined && value !== null && value !== '') {
      query.append(key, value);
    }
  });
  return query.toString() ? `?${query.toString()}` : '';
};

  // Documentation
  documentation: `${API_BASE_URL}/documentation`,
};

// Helper function para hacer fetch con la base URL
export async function apiFetch(endpoint, options = {}) {
  const url = endpoint.startsWith('http') ? endpoint : `${API_BASE_URL}${endpoint}`;
  
  const defaultOptions = {
    headers: {
      'Content-Type': 'application/json',
      ...options.headers
    }
  };

  // Si hay token en localStorage, agregarlo
  if (typeof window !== 'undefined') {
    const token = localStorage.getItem('auth_token');
    if (token) {
      defaultOptions.headers['Authorization'] = `Bearer ${token}`;
    }
  }

  return fetch(url, { ...defaultOptions, ...options });
}

// Helper para manejar respuestas de API
export async function apiResponse(response) {
  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(error.message || `Error ${response.status}`);
  }
  return response.json();
}

