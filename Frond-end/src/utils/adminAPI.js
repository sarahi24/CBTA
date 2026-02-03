/**
 * Admin API Service
 * Centraliza todas las llamadas API para administración de usuarios, roles y permisos
 */

const API_BASE = 'https://nginx-production-728f.up.railway.app/api/v1';

/**
 * Helper: Detecta errores de autenticación (401) y redirige al login
 */
function handleAuthError(statusCode) {
  if (statusCode === 401) {
    // Mostrar alerta
    alert('⚠️ Tu sesión ha expirado. Por favor, vuelve a iniciar sesión.');
    // Limpiar token
    localStorage.removeItem('access_token');
    localStorage.removeItem('user_id');
    // Redirigir a login
    window.location.href = '/login';
    return true;
  }
  return false;
}

export const AdminAPI = {
  /**
   * POST /api/v1/admin-actions/permissions/by-user/{userId}
   * Obtener permisos existentes para los roles del usuario
   */
  async getPermissionsByUser(userId, token, roles = []) {
    try {
      const response = await fetch(`${API_BASE}/admin-actions/permissions/by-user/${userId}`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-User-Role': 'admin',
          'X-User-Permission': 'view.permissions'
        },
        body: JSON.stringify({
          roles: roles,
          forceRefresh: true
        })
      });

      // Detectar error de autenticación
      if (response.status === 401) {
        handleAuthError(401);
        throw new Error('No autenticado - sesión expirada');
      }

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.message || 'Error al cargar permisos del usuario');
      }

      return await response.json();
    } catch (err) {
      console.error('❌ AdminAPI.getPermissionsByUser:', err);
      throw err;
    }
  },

  /**
   * POST /api/v1/admin-actions/permissions/by-role
   * Obtener permisos existentes por role
   */
  async getPermissionsByRole(token) {
    try {
      const response = await fetch(`${API_BASE}/admin-actions/permissions/by-role`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-User-Role': 'admin',
          'X-User-Permission': 'view.permissions'
        },
        body: JSON.stringify({})
      });

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.message || 'Error al cargar permisos por rol');
      }

      return await response.json();
    } catch (err) {
      console.error('❌ AdminAPI.getPermissionsByRole:', err);
      throw err;
    }
  },

  /**
   * POST /api/v1/admin-actions/permissions/by-curps
   * Obtener permisos existentes para usuarios específicos
   */
  async getPermissionsByCurps(curps, token) {
    try {
      const response = await fetch(`${API_BASE}/admin-actions/permissions/by-curps`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-User-Role': 'admin',
          'X-User-Permission': 'view.permissions'
        },
        body: JSON.stringify({
          curps: curps
        })
      });

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.message || 'Error al cargar permisos por CURPs');
      }

      return await response.json();
    } catch (err) {
      console.error('❌ AdminAPI.getPermissionsByCurps:', err);
      throw err;
    }
  },

  /**
   * POST /api/v1/admin-actions/update-permissions/{userId}
   * Actualizar permisos a un usuario
   */
  async updateUserPermissions(userId, permissionsToAdd, permissionsToRemove, token) {
    try {
      const response = await fetch(`${API_BASE}/admin-actions/update-permissions/${userId}`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-User-Role': 'admin',
          'X-User-Permission': 'sync.permissions'
        },
        body: JSON.stringify({
          permissionsToAdd: permissionsToAdd,
          permissionsToRemove: permissionsToRemove
        })
      });

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.message || 'Error al actualizar permisos');
      }

      return await response.json();
    } catch (err) {
      console.error('❌ AdminAPI.updateUserPermissions:', err);
      throw err;
    }
  },

  /**
   * POST /api/v1/admin-actions/update-permissions
   * Actualizar permisos a múltiples usuarios
   */
  async updateMultipleUsersPermissions(curpsOrRole, permissionsToAdd, permissionsToRemove, token, isCurps = true) {
    try {
      const body = {
        permissionsToAdd: permissionsToAdd,
        permissionsToRemove: permissionsToRemove
      };

      if (isCurps) {
        body.curps = curpsOrRole;
      } else {
        body.role = curpsOrRole;
      }

      const response = await fetch(`${API_BASE}/admin-actions/update-permissions`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-User-Role': 'admin',
          'X-User-Permission': 'sync.permissions'
        },
        body: JSON.stringify(body)
      });

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.message || 'Error al actualizar permisos de múltiples usuarios');
      }

      return await response.json();
    } catch (err) {
      console.error('❌ AdminAPI.updateMultipleUsersPermissions:', err);
      throw err;
    }
  },

  /**
   * POST /api/v1/admin-actions/updated-roles/{userId}
   * Sincronizar roles de un usuario
   */
  async updateUserRoles(userId, rolesToAdd, rolesToRemove, token) {
    try {
      const response = await fetch(`${API_BASE}/admin-actions/updated-roles/${userId}`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-User-Role': 'admin',
          'X-User-Permission': 'sync.roles'
        },
        body: JSON.stringify({
          rolesToAdd: rolesToAdd,
          rolesToRemove: rolesToRemove
        })
      });

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.message || 'Error al actualizar roles');
      }

      return await response.json();
    } catch (err) {
      console.error('❌ AdminAPI.updateUserRoles:', err);
      throw err;
    }
  },

  /**
   * POST /api/v1/admin-actions/updated-roles
   * Sincronizar roles de múltiples usuarios
   */
  async updateMultipleUsersRoles(curps, rolesToAdd, rolesToRemove, token) {
    try {
      const response = await fetch(`${API_BASE}/admin-actions/updated-roles`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-User-Role': 'admin',
          'X-User-Permission': 'sync.roles'
        },
        body: JSON.stringify({
          curps: curps,
          rolesToAdd: rolesToAdd,
          rolesToRemove: rolesToRemove
        })
      });

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.message || 'Error al actualizar roles de múltiples usuarios');
      }

      return await response.json();
    } catch (err) {
      console.error('❌ AdminAPI.updateMultipleUsersRoles:', err);
      throw err;
    }
  },

  /**
   * GET /api/v1/admin-actions/find-roles
   * Obtener todos los roles registrados
   */
  async getAllRoles(token, forceRefresh = false) {
    try {
      let url = `${API_BASE}/admin-actions/find-roles`;
      if (forceRefresh) url += '?forceRefresh=true';

      const response = await fetch(url, {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-User-Role': 'admin',
          'X-User-Permission': 'view.roles'
        }
      });

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.message || 'Error al cargar roles');
      }

      return await response.json();
    } catch (err) {
      console.error('❌ AdminAPI.getAllRoles:', err);
      throw err;
    }
  },

  /**
   * GET /api/v1/admin-actions/roles/{id}
   * Obtener rol por ID
   */
  async getRoleById(roleId, token) {
    try {
      const response = await fetch(`${API_BASE}/admin-actions/roles/${roleId}`, {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-User-Role': 'admin',
          'X-User-Permission': 'view.roles'
        }
      });

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.message || 'Error al cargar rol');
      }

      return await response.json();
    } catch (err) {
      console.error('❌ AdminAPI.getRoleById:', err);
      throw err;
    }
  },

  /**
   * GET /api/v1/admin-actions/permissions/{id}
   * Obtener permiso por ID
   */
  async getPermissionById(permissionId, token) {
    try {
      const response = await fetch(`${API_BASE}/admin-actions/permissions/${permissionId}`, {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-User-Role': 'admin',
          'X-User-Permission': 'view.permissions'
        }
      });

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.message || 'Error al cargar permiso');
      }

      return await response.json();
    } catch (err) {
      console.error('❌ AdminAPI.getPermissionById:', err);
      throw err;
    }
  }
};
