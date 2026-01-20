// API Configuration
export const API_BASE_URL = 'https://nginx-production-728f.up.railway.app/api';

// API Endpoints
export const API_ENDPOINTS = {
  students: `${API_BASE_URL}/students`,
  payments: `${API_BASE_URL}/payments`,
  concepts: `${API_BASE_URL}/concepts`,
  debts: `${API_BASE_URL}/debts`,
  documentation: `${API_BASE_URL}/documentation`
};

// Helper function para hacer fetch con la base URL
export async function apiFetch(endpoint, options = {}) {
  const url = endpoint.startsWith('http') ? endpoint : `${API_BASE_URL}${endpoint}`;
  return fetch(url, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      ...options.headers
    }
  });
}
