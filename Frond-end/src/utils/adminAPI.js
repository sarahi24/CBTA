/**
 * Admin API Service
 * Centraliza todas las llamadas API para administración de usuarios, roles y permisos
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

export const AdminAPI = {
  /**
   * POST /api/v1/admin-actions/permissions/by-user/{userId}
   * Obtener permisos existentes para los roles del usuario
   */
  async getPermissionsByUser(userId, token, roles = []) {
    try {
      console.log('🔐🔐🔐 INICIANDO getPermissionsByUser 🔐🔐🔐');
      console.log('userId:', userId);
      console.log('token presente:', !!token);
      console.log('roles:', roles);
      
      if (!token) {
        throw new Error('No hay token de autenticación');
      }

      // El body debe estar vacío o simplemente con roles
      // Intentemos primero sin roles en el body
      const url = `${API_BASE}/admin-actions/permissions/by-user/${userId}`;
      console.log('URL:', url);

      const response = await fetch(url, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-User-Role': 'admin',
          'X-User-Permission': 'view.permissions'
        },
        body: JSON.stringify({
          roles: Array.isArray(roles) ? roles : [],
          forceRefresh: true
        })
      });

      console.log('STATUS:', response.status);

      if (response.status === 401) {
        const errorData = await response.json().catch(() => ({}));
        console.error('401 ERROR:', errorData);
        handleAuthError(401);
        throw new Error('Sesión expirada');
      }

      if (response.status === 422) {
        const errorData = await response.json().catch(() => ({}));
        console.error('❌❌❌ 422 VALIDATION ERROR:');
        console.error(JSON.stringify(errorData, null, 2));
        throw new Error(errorData.message || 'Errores de validación');
      }

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        console.error('OTRA ERROR:', response.status, errorData);
        throw new Error(errorData.message || `HTTP ${response.status}`);
      }

      const result = await response.json();
      console.log('✅ SUCCESS:', result);
      return result;
    } catch (err) {
      console.error('❌ AdminAPI.getPermissionsByUser ERROR:', err);
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

      console.log('🔐🔐🔐 updateMultipleUsersPermissions 🔐🔐🔐');
      console.log('isCurps:', isCurps);
      console.log('curpsOrRole:', curpsOrRole);
      console.log('permissionsToAdd:', permissionsToAdd);
      console.log('permissionsToRemove:', permissionsToRemove);
      console.log('Body completo a enviar:', JSON.stringify(body, null, 2));

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

      console.log('STATUS:', response.status);

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        console.error('❌❌❌ 422 VALIDATION ERROR:');
        console.error(JSON.stringify(errorData, null, 2));
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
  },

  /**
   * GET /api/v1/concepts
   * Obtener lista paginada de conceptos de pago
   */
  async getConcepts(token, { status = 'activo', perPage = 15, page = 1, forceRefresh = false } = {}) {
    try {
      const params = new URLSearchParams({
        status,
        perPage: perPage.toString(),
        page: page.toString(),
        forceRefresh: forceRefresh.toString()
      });

      const response = await fetch(`${API_BASE}/concepts?${params}`, {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-User-Role': 'financial-staff',
          'X-User-Permission': 'view.concepts'
        }
      });

      if (!response.ok) {
        handleAuthError(response.status);
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.message || 'Error al obtener conceptos');
      }

      return await response.json();
    } catch (err) {
      console.error('❌ AdminAPI.getConcepts:', err);
      throw err;
    }
  },

  /**
   * POST /api/v1/concepts
   * Crear un nuevo concepto de pago
   */
  async createConcept(token, conceptData) {
    try {
      const response = await fetch(`${API_BASE}/concepts`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-User-Role': 'financial-staff',
          'X-User-Permission': 'create.concepts'
        },
        body: JSON.stringify(conceptData)
      });

      if (!response.ok) {
        handleAuthError(response.status);
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.message || 'Error al crear concepto');
      }

      return await response.json();
    } catch (err) {
      console.error('❌ AdminAPI.createConcept:', err);
      throw err;
    }
  },

  /**
   * GET /api/v1/concepts/{id}
   * Obtener un concepto de pago por ID
   */
  async getConceptById(conceptId, token) {
    try {
      const response = await fetch(`${API_BASE}/concepts/${conceptId}`, {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-User-Role': 'financial-staff',
          'X-User-Permission': 'view.concepts'
        }
      });

      if (!response.ok) {
        handleAuthError(response.status);
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.message || 'Error al obtener concepto');
      }

      return await response.json();
    } catch (err) {
      console.error('❌ AdminAPI.getConceptById:', err);
      throw err;
    }
  },

  /**
   * PUT /api/v1/concepts/{id}
   * Actualizar un concepto de pago existente
   */
  async updateConcept(conceptId, token, updateData) {
    try {
      const response = await fetch(`${API_BASE}/concepts/${conceptId}`, {
        method: 'PUT',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-User-Role': 'financial-staff',
          'X-User-Permission': 'update.concepts'
        },
        body: JSON.stringify(updateData)
      });

      if (!response.ok) {
        handleAuthError(response.status);
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.message || 'Error al actualizar concepto');
      }

      return await response.json();
    } catch (err) {
      console.error('❌ AdminAPI.updateConcept:', err);
      throw err;
    }
  },

  /**
   * GET /api/v1/concepts/relations/{id}
   * Obtener relaciones de un concepto de pago (usuarios, carreras, semestres, etc.)
   */
  async getConceptRelations(conceptId, token) {
    try {
      const response = await fetch(`${API_BASE}/concepts/relations/${conceptId}`, {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-User-Role': 'financial-staff',
          'X-User-Permission': 'view.concepts'
        }
      });

      if (!response.ok) {
        handleAuthError(response.status);
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.message || 'Error al obtener relaciones del concepto');
      }

      return await response.json();
    } catch (err) {
      console.error('❌ AdminAPI.getConceptRelations:', err);
      throw err;
    }
  },

  /**
   * PATCH /api/v1/concepts/update-relations/{id}
   * Actualizar relaciones de un concepto de pago
   */
  async updateConceptRelations(conceptId, token, relationsData) {
    try {
      const response = await fetch(`${API_BASE}/concepts/update-relations/${conceptId}`, {
        method: 'PATCH',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-User-Role': 'financial-staff',
          'X-User-Permission': 'update.concepts'
        },
        body: JSON.stringify(relationsData)
      });

      if (!response.ok) {
        handleAuthError(response.status);
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.message || 'Error al actualizar relaciones del concepto');
      }

      return await response.json();
    } catch (err) {
      console.error('❌ AdminAPI.updateConceptRelations:', err);
      throw err;
    }
  },

  /**
   * POST /api/v1/concepts/{concept}/finalize
   * Finalizar un concepto de pago (cambiar status a finalizado)
   */
  async finalizeConcept(conceptId, token) {
    try {
      const response = await fetch(`${API_BASE}/concepts/${conceptId}/finalize`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-User-Role': 'financial-staff',
          'X-User-Permission': 'finalize.concepts'
        }
      });

      if (!response.ok) {
        handleAuthError(response.status);
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.message || 'Error al finalizar concepto');
      }

      return await response.json();
    } catch (err) {
      console.error('❌ AdminAPI.finalizeConcept:', err);
      throw err;
    }
  }
};
