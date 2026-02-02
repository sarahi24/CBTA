/**
 * Dashboard API Service
 * Funciones para interactuar con los endpoints del dashboard
 */

const API_BASE = 'https://nginx-production-728f.up.railway.app/api/v1';

export const DashboardAPI = {
  /**
   * Limpiar caché del dashboard
   */
  async refreshCache(token) {
    try {
      const response = await fetch(`${API_BASE}/dashboard/refresh`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-User-Role': 'student',
          'X-User-Permission': 'refresh.all.dashboard'
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
   * Obtener historial de pagos
   */
  async getPaymentHistory(userId, token, page = 1, perPage = 15, forceRefresh = false) {
    try {
      const url = new URL(`${API_BASE}/dashboard/history/${userId}`);
      url.searchParams.append('page', page);
      url.searchParams.append('perPage', perPage);
      if (forceRefresh) url.searchParams.append('forceRefresh', 'true');

      const response = await fetch(url.toString(), {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-User-Role': 'student',
          'X-User-Permission': 'view.payments.history'
        }
      });

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.message || 'Error al cargar historial');
      }

      return await response.json();
    } catch (err) {
      console.error('❌ Error fetching payment history:', err);
      throw err;
    }
  },

  /**
   * Obtener total de pagos vencidos
   */
  async getOverdueTotal(userId, token, forceRefresh = false) {
    try {
      const url = new URL(`${API_BASE}/dashboard/overdue/${userId}`);
      if (forceRefresh) url.searchParams.append('forceRefresh', 'true');

      const response = await fetch(url.toString(), {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-User-Role': 'student',
          'X-User-Permission': 'view.own.overdue.concepts.summary'
        }
      });

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.message || 'Error al cargar vencidos');
      }

      return await response.json();
    } catch (err) {
      console.error('❌ Error fetching overdue total:', err);
      throw err;
    }
  },

  /**
   * Obtener total de pagos realizados
   */
  async getPaidTotal(userId, token, forceRefresh = false) {
    try {
      const url = new URL(`${API_BASE}/dashboard/paid/${userId}`);
      if (forceRefresh) url.searchParams.append('forceRefresh', 'true');

      const response = await fetch(url.toString(), {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-User-Role': 'student',
          'X-User-Permission': 'view.own.paid.concepts.summary'
        }
      });

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.message || 'Error al cargar pagos realizados');
      }

      return await response.json();
    } catch (err) {
      console.error('❌ Error fetching paid total:', err);
      throw err;
    }
  },

  /**
   * Obtener total de pagos pendientes
   */
  async getPendingTotal(userId, token, forceRefresh = false) {
    try {
      const url = new URL(`${API_BASE}/dashboard/pending/${userId}`);
      if (forceRefresh) url.searchParams.append('forceRefresh', 'true');

      const response = await fetch(url.toString(), {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-User-Role': 'student',
          'X-User-Permission': 'view.own.pending.concepts.summary'
        }
      });

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.message || 'Error al cargar pendientes');
      }

      return await response.json();
    } catch (err) {
      console.error('❌ Error fetching pending total:', err);
      throw err;
    }
  },

  /**
   * Obtener todos los datos del dashboard
   */
  async getAllDashboardData(userId, token) {
    try {
      const [history, overdue, paid, pending] = await Promise.all([
        this.getPaymentHistory(userId, token),
        this.getOverdueTotal(userId, token),
        this.getPaidTotal(userId, token),
        this.getPendingTotal(userId, token)
      ]);

      return {
        history,
        overdue,
        paid,
        pending
      };
    } catch (err) {
      console.error('❌ Error fetching all dashboard data:', err);
      throw err;
    }
  }
};

export default DashboardAPI;
