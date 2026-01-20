// API Configuration
export const API_BASE_URL = 'https://nginx-production-728f.up.railway.app/api';

// API Endpoints organizados por categoría
export const API_ENDPOINTS = {
  // Auth - Autenticación
  auth: {
    login: `${API_BASE_URL}/auth/login`,
    register: `${API_BASE_URL}/auth/register`,
    logout: `${API_BASE_URL}/auth/logout`,
    refresh: `${API_BASE_URL}/auth/refresh`,
    resetPassword: `${API_BASE_URL}/auth/reset-password`,
    verifyEmail: `${API_BASE_URL}/auth/verify-email`,
  },

  // Admin - Gestión administrativa
  admin: {
    assignUsers: `${API_BASE_URL}/admin/assign-users`,
    importUsers: `${API_BASE_URL}/admin/import-users`,
    users: `${API_BASE_URL}/admin/users`,
  },

  // Careers - Carreras
  careers: {
    list: `${API_BASE_URL}/careers`,
    create: `${API_BASE_URL}/careers`,
    update: (id) => `${API_BASE_URL}/careers/${id}`,
    delete: (id) => `${API_BASE_URL}/careers/${id}`,
  },

  // Students - Estudiantes
  students: {
    list: `${API_BASE_URL}/students`,
    get: (id) => `${API_BASE_URL}/students/${id}`,
    create: `${API_BASE_URL}/students`,
    update: (id) => `${API_BASE_URL}/students/${id}`,
    delete: (id) => `${API_BASE_URL}/students/${id}`,
    academicInfo: (id) => `${API_BASE_URL}/students/${id}/academic-info`,
  },

  // Payment Concepts - Conceptos de pago
  paymentConcepts: {
    list: `${API_BASE_URL}/payment-concepts`,
    get: (id) => `${API_BASE_URL}/payment-concepts/${id}`,
    create: `${API_BASE_URL}/payment-concepts`,
    update: (id) => `${API_BASE_URL}/payment-concepts/${id}`,
    delete: (id) => `${API_BASE_URL}/payment-concepts/${id}`,
    activate: (id) => `${API_BASE_URL}/payment-concepts/${id}/activate`,
    deactivate: (id) => `${API_BASE_URL}/payment-concepts/${id}/deactivate`,
  },

  // Debts - Adeudos y pagos pendientes
  debts: {
    list: `${API_BASE_URL}/debts`,
    get: (id) => `${API_BASE_URL}/debts/${id}`,
    validate: (id) => `${API_BASE_URL}/debts/${id}/validate`,
    pending: `${API_BASE_URL}/debts/pending`,
  },

  // Payments - Pagos registrados
  payments: {
    list: `${API_BASE_URL}/payments`,
    get: (id) => `${API_BASE_URL}/payments/${id}`,
    create: `${API_BASE_URL}/payments`,
    history: `${API_BASE_URL}/payments/history`,
    pending: `${API_BASE_URL}/payments/pending`,
  },

  // Cards - Métodos de pago
  cards: {
    list: `${API_BASE_URL}/cards`,
    get: (id) => `${API_BASE_URL}/cards/${id}`,
    create: `${API_BASE_URL}/cards`,
    delete: (id) => `${API_BASE_URL}/cards/${id}`,
  },

  // Dashboard - Panel de control
  dashboard: {
    stats: `${API_BASE_URL}/dashboard/stats`,
    payments: `${API_BASE_URL}/dashboard/payments`,
    summary: `${API_BASE_URL}/dashboard/summary`,
    staff: `${API_BASE_URL}/dashboard/staff`,
  },

  // Notifications - Notificaciones
  notifications: {
    list: `${API_BASE_URL}/notifications`,
    markAsRead: (id) => `${API_BASE_URL}/notifications/${id}/read`,
    markAllAsRead: `${API_BASE_URL}/notifications/read-all`,
  },

  // Parents - Padres de familia
  parents: {
    invite: `${API_BASE_URL}/parents/invite`,
    accept: `${API_BASE_URL}/parents/accept`,
    list: `${API_BASE_URL}/parents`,
  },

  // Users - Usuarios
  users: {
    profile: `${API_BASE_URL}/users/profile`,
    update: (id) => `${API_BASE_URL}/users/${id}`,
    list: `${API_BASE_URL}/users`,
  },

  // FindEntity - Búsqueda
  search: {
    users: `${API_BASE_URL}/search/users`,
    payments: `${API_BASE_URL}/search/payments`,
    concepts: `${API_BASE_URL}/search/concepts`,
  },

  // Payouts - Retiros
  payouts: {
    list: `${API_BASE_URL}/payouts`,
    create: `${API_BASE_URL}/payouts`,
    get: (id) => `${API_BASE_URL}/payouts/${id}`,
  },

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

