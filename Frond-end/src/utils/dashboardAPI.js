/**
 * Dashboard API Service - Staff Version
 * Funciones para interactuar con los endpoints del dashboard del personal financiero
 */

const API_BASE = 'https://nginx-production-728f.up.railway.app/api/v1';

export const DashboardAPI = {
  /**
   * Limpiar caché del dashboard
   */
  async refreshCache(token) {
    try {
      const response = await fetch(`${API_BASE}/dashboard-staff/refresh`, {
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
      console.error('❌ Error refreshing dashboard cache:', err);
      throw err;
    }
  },

  /**
   * Obtener todos los conceptos de pago
   */
  async getConcepts(token, onlyThisYear = true, page = 1, perPage = 15, forceRefresh = false) {
    try {
      const url = new URL(`${API_BASE}/dashboard-staff/concepts`);
      url.searchParams.append('only_this_year', onlyThisYear);
      url.searchParams.append('page', page);
      url.searchParams.append('perPage', perPage);
      if (forceRefresh) url.searchParams.append('forceRefresh', 'true');

      const response = await fetch(url.toString(), {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        }
      });

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.message || 'Error al cargar conceptos');
      }

      return await response.json();
    } catch (err) {
      console.error('❌ Error fetching concepts:', err);
      throw err;
    }
  },

  /**
   * Obtener monto total de pagos realizados
   */
  async getPaymentsMade(token, onlyThisYear = true, forceRefresh = false) {
    try {
      const url = new URL(`${API_BASE}/dashboard-staff/payments`);
      url.searchParams.append('only_this_year', onlyThisYear);
      if (forceRefresh) url.searchParams.append('forceRefresh', 'true');

      const response = await fetch(url.toString(), {
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
      console.error('❌ Error fetching payments made:', err);
      throw err;
    }
  },

  /**
   * Obtener el número total de estudiantes
   */
  async getStudentsCount(token, onlyThisYear = true, forceRefresh = false) {
    try {
      const url = new URL(`${API_BASE}/dashboard-staff/students`);
      url.searchParams.append('only_this_year', onlyThisYear);
      if (forceRefresh) url.searchParams.append('forceRefresh', 'true');

      const response = await fetch(url.toString(), {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        }
      });

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.message || 'Error al cargar total de estudiantes');
      }

      return await response.json();
    } catch (err) {
      console.error('❌ Error fetching students count:', err);
      throw err;
    }
  },

  /**
   * Obtener cantidad y monto total de pagos pendientes
   */
  async getPendingPayments(token, onlyThisYear = true, forceRefresh = false) {
    try {
      const url = new URL(`${API_BASE}/dashboard-staff/pending`);
      url.searchParams.append('only_this_year', onlyThisYear);
      if (forceRefresh) url.searchParams.append('forceRefresh', 'true');

      const response = await fetch(url.toString(), {
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
      console.error('❌ Error fetching pending payments:', err);
      throw err;
    }
  },

  /**
   * Crear un payout con todo el balance disponible
   */
  async createPayout(token) {
    try {
      const response = await fetch(`${API_BASE}/dashboard-staff/payout`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        }
      });

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.message || 'Error al crear payout');
      }

      return await response.json();
    } catch (err) {
      console.error('❌ Error creating payout:', err);
      throw err;
    }
  },

  /**
   * Obtener todos los datos del dashboard
   */
  async getAllDashboardData(token, onlyThisYear = true) {
    try {
      const [concepts, payments, students, pending] = await Promise.all([
        this.getConcepts(token, onlyThisYear),
        this.getPaymentsMade(token, onlyThisYear),
        this.getStudentsCount(token, onlyThisYear),
        this.getPendingPayments(token, onlyThisYear)
      ]);

      return {
        concepts,
        payments,
        students,
        pending
      };
    } catch (err) {
      console.error('❌ Error fetching all dashboard data:', err);
      throw err;
    }
  }
};

export default DashboardAPI;
