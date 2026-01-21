// authService.js - Servicio de autenticación y manejo de tokens
import { API_ENDPOINTS, handleAPIResponse } from '../config/api.js';

// Almacenamiento de tokens
const TOKEN_KEY = 'access_token';
const REFRESH_TOKEN_KEY = 'refresh_token';
const USER_DATA_KEY = 'user_data';

export const AuthService = {
  // Login
  async login(email, password) {
    try {
      const response = await fetch(API_ENDPOINTS.auth.login, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: JSON.stringify({ email, password }),
      });

      const data = await handleAPIResponse(response);
      
      // Guardar tokens
      if (data.data?.access_token) {
        this.setToken(data.data.access_token);
      }
      if (data.data?.refresh_token) {
        this.setRefreshToken(data.data.refresh_token);
      }
      if (data.data?.user_data) {
        this.setUserData(data.data.user_data);
      }

      return data;
    } catch (error) {
      console.error('Login error:', error);
      throw error;
    }
  },

  // Register
  async register(userData) {
    try {
      const response = await fetch(API_ENDPOINTS.auth.register, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: JSON.stringify(userData),
      });

      return await handleAPIResponse(response);
    } catch (error) {
      console.error('Register error:', error);
      throw error;
    }
  },

  // Logout
  async logout() {
    const refreshToken = this.getRefreshToken();
    
    try {
      await fetch(API_ENDPOINTS.auth.logout, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${this.getToken()}`,
          'x-refresh-token': refreshToken,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      });
    } catch (error) {
      console.error('Logout error:', error);
    } finally {
      // Limpiar datos locales siempre
      this.clearAuth();
    }
  },

  // Refresh token
  async refreshToken() {
    const refreshToken = this.getRefreshToken();
    if (!refreshToken) {
      throw new Error('No refresh token available');
    }

    try {
      const response = await fetch(API_ENDPOINTS.auth.refresh, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: JSON.stringify({ refresh_token: refreshToken }),
      });

      const data = await handleAPIResponse(response);
      
      if (data.data?.access_token) {
        this.setToken(data.data.access_token);
      }
      if (data.data?.refresh_token) {
        this.setRefreshToken(data.data.refresh_token);
      }

      return data;
    } catch (error) {
      console.error('Refresh token error:', error);
      this.clearAuth();
      throw error;
    }
  },

  // Forgot password
  async forgotPassword(email) {
    try {
      const response = await fetch(API_ENDPOINTS.auth.forgotPassword, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: JSON.stringify({ email }),
      });

      return await handleAPIResponse(response);
    } catch (error) {
      console.error('Forgot password error:', error);
      throw error;
    }
  },

  // Get authenticated user
  async getAuthenticatedUser() {
    try {
      const response = await this.authenticatedFetch(API_ENDPOINTS.users.getAuthenticated);
      return await handleAPIResponse(response);
    } catch (error) {
      console.error('Get user error:', error);
      throw error;
    }
  },

  // Fetch con autenticación automática
  async authenticatedFetch(url, options = {}) {
    const token = this.getToken();
    
    if (!token) {
      throw new Error('No authentication token available');
    }

    const headers = {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...options.headers,
    };

    try {
      const response = await fetch(url, {
        ...options,
        headers,
      });

      // Si el token expiró (401), intentar refresh
      if (response.status === 401) {
        try {
          await this.refreshToken();
          // Reintentar con el nuevo token
          const newToken = this.getToken();
          headers['Authorization'] = `Bearer ${newToken}`;
          return await fetch(url, { ...options, headers });
        } catch (refreshError) {
          // Si el refresh falla, limpiar y redirigir al login
          this.clearAuth();
          window.location.href = '/';
          throw refreshError;
        }
      }

      return response;
    } catch (error) {
      console.error('Authenticated fetch error:', error);
      throw error;
    }
  },

  // Token management
  getToken() {
    return localStorage.getItem(TOKEN_KEY);
  },

  setToken(token) {
    localStorage.setItem(TOKEN_KEY, token);
  },

  getRefreshToken() {
    return localStorage.getItem(REFRESH_TOKEN_KEY);
  },

  setRefreshToken(token) {
    localStorage.setItem(REFRESH_TOKEN_KEY, token);
  },

  getUserData() {
    const data = localStorage.getItem(USER_DATA_KEY);
    return data ? JSON.parse(data) : null;
  },

  setUserData(userData) {
    localStorage.setItem(USER_DATA_KEY, JSON.stringify(userData));
  },

  clearAuth() {
    localStorage.removeItem(TOKEN_KEY);
    localStorage.removeItem(REFRESH_TOKEN_KEY);
    localStorage.removeItem(USER_DATA_KEY);
  },

  isAuthenticated() {
    return !!this.getToken();
  },

  // Get user role
  getUserRole() {
    const userData = this.getUserData();
    if (!userData || !Array.isArray(userData)) return null;
    
    // userData es un array de objetos con roles
    const firstUser = userData[0];
    if (firstUser && firstUser.roles && Array.isArray(firstUser.roles)) {
      return firstUser.roles[0]; // Retornar el primer rol
    }
    return null;
  },

  // Check if user has specific role
  hasRole(role) {
    const userRole = this.getUserRole();
    return userRole === role;
  },
};

// Export default
export default AuthService;
