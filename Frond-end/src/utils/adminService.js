// adminService.js - Servicio para operaciones administrativas
import { API_ENDPOINTS, handleAPIResponse, buildQueryString } from '../config/api.js';

// Obtener el token de autenticación
const getAuthHeaders = () => {
  const token = localStorage.getItem('access_token');
  return {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': `Bearer ${token}`,
    'X-User-Role': 'admin',
  };
};

export const AdminService = {
  /**
   * CRUD de Usuarios
   */
  
  // Obtener lista de usuarios con paginación y filtros
  async getUsers({ page = 1, perPage = 15, status = 'activo', forceRefresh = false } = {}) {
    try {
      const queryParams = buildQueryString({ page, perPage, status, forceRefresh });
      const url = `${API_ENDPOINTS.adminActions.showUsers}${queryParams}`;
      
      const response = await fetch(url, {
        method: 'GET',
        headers: getAuthHeaders(),
      });

      return await handleAPIResponse(response);
    } catch (error) {
      console.error('Error al obtener usuarios:', error);
      throw error;
    }
  },

  // Obtener detalles de un usuario específico
  async getUserById(userId, forceRefresh = false) {
    try {
      const queryParams = buildQueryString({ forceRefresh });
      const url = `${API_ENDPOINTS.adminActions.showUserById(userId)}${queryParams}`;
      
      const response = await fetch(url, {
        method: 'GET',
        headers: getAuthHeaders(),
      });

      return await handleAPIResponse(response);
    } catch (error) {
      console.error(`Error al obtener usuario ${userId}:`, error);
      throw error;
    }
  },

  // Registrar nuevo usuario (Admin)
  async registerUser(userData) {
    try {
      const response = await fetch(API_ENDPOINTS.adminActions.register, {
        method: 'POST',
        headers: {
          ...getAuthHeaders(),
          'X-User-Permission': 'create.user',
        },
        body: JSON.stringify(userData),
      });

      return await handleAPIResponse(response);
    } catch (error) {
      console.error('Error al registrar usuario:', error);
      throw error;
    }
  },

  // Actualizar usuario
  async updateUser(userId, userData) {
    try {
      const response = await fetch(API_ENDPOINTS.adminActions.updateUser(userId), {
        method: 'PATCH',
        headers: getAuthHeaders(),
        body: JSON.stringify(userData),
      });

      return await handleAPIResponse(response);
    } catch (error) {
      console.error(`Error al actualizar usuario ${userId}:`, error);
      throw error;
    }
  },

  // Eliminar usuario
  async deleteUser(userId) {
    try {
      const response = await fetch(API_ENDPOINTS.adminActions.deleteUser(userId), {
        method: 'DELETE',
        headers: getAuthHeaders(),
      });

      return await handleAPIResponse(response);
    } catch (error) {
      console.error(`Error al eliminar usuario ${userId}:`, error);
      throw error;
    }
  },

  // Eliminar múltiples usuarios
  async deleteUsers(userIds) {
    try {
      const response = await fetch(API_ENDPOINTS.adminActions.deleteUsers, {
        method: 'DELETE',
        headers: getAuthHeaders(),
        body: JSON.stringify({ user_ids: userIds }),
      });

      return await handleAPIResponse(response);
    } catch (error) {
      console.error('Error al eliminar usuarios:', error);
      throw error;
    }
  },

  // Deshabilitar usuarios
  async disableUsers(userIds) {
    try {
      const response = await fetch(API_ENDPOINTS.adminActions.disableUsers, {
        method: 'POST',
        headers: getAuthHeaders(),
        body: JSON.stringify({ user_ids: userIds }),
      });

      return await handleAPIResponse(response);
    } catch (error) {
      console.error('Error al deshabilitar usuarios:', error);
      throw error;
    }
  },

  // Deshabilitar temporalmente usuarios
  async temporaryDisableUsers(userIds) {
    try {
      const response = await fetch(API_ENDPOINTS.adminActions.temporaryDisableUsers, {
        method: 'POST',
        headers: getAuthHeaders(),
        body: JSON.stringify({ user_ids: userIds }),
      });

      return await handleAPIResponse(response);
    } catch (error) {
      console.error('Error al deshabilitar temporalmente usuarios:', error);
      throw error;
    }
  },

  /**
   * Gestión de Estudiantes
   */

  // Asociar detalles de estudiante a un usuario
  async attachStudent(studentData) {
    try {
      const response = await fetch(API_ENDPOINTS.adminActions.attachStudent, {
        method: 'POST',
        headers: {
          ...getAuthHeaders(),
          'X-User-Permission': 'attach.student',
        },
        body: JSON.stringify(studentData),
      });

      return await handleAPIResponse(response);
    } catch (error) {
      console.error('Error al asociar estudiante:', error);
      throw error;
    }
  },

  // Obtener detalles de estudiante
  async getStudent(studentId) {
    try {
      const response = await fetch(API_ENDPOINTS.adminActions.getStudent(studentId), {
        method: 'GET',
        headers: {
          ...getAuthHeaders(),
          'X-User-Permission': 'view.student',
        },
      });

      return await handleAPIResponse(response);
    } catch (error) {
      console.error(`Error al obtener estudiante ${studentId}:`, error);
      throw error;
    }
  },

  // Actualizar detalles de estudiante
  async updateStudent(studentId, studentData) {
    try {
      const response = await fetch(API_ENDPOINTS.adminActions.updateStudent(studentId), {
        method: 'PATCH',
        headers: {
          ...getAuthHeaders(),
          'X-User-Permission': 'update.student',
        },
        body: JSON.stringify(studentData),
      });

      return await handleAPIResponse(response);
    } catch (error) {
      console.error(`Error al actualizar estudiante ${studentId}:`, error);
      throw error;
    }
  },

  // Promoción de estudiantes (incrementar semestre)
  async promoteStudents() {
    try {
      const response = await fetch(API_ENDPOINTS.adminActions.promotion, {
        method: 'POST',
        headers: {
          ...getAuthHeaders(),
          'X-User-Permission': 'promote.student',
        },
      });

      return await handleAPIResponse(response);
    } catch (error) {
      console.error('Error al promover estudiantes:', error);
      throw error;
    }
  },

  /**
   * Gestión de Permisos y Roles
   */

  // Actualizar permisos de usuarios
  async updatePermissions(permissionsData) {
    try {
      const response = await fetch(API_ENDPOINTS.adminActions.updatePermissions, {
        method: 'POST',
        headers: {
          ...getAuthHeaders(),
          'X-User-Permission': 'sync.permissions',
        },
        body: JSON.stringify(permissionsData),
      });

      return await handleAPIResponse(response);
    } catch (error) {
      console.error('Error al actualizar permisos:', error);
      throw error;
    }
  },

  // Obtener permisos disponibles
  async getPermissions() {
    try {
      const response = await fetch(API_ENDPOINTS.adminActions.findPermissions, {
        method: 'GET',
        headers: getAuthHeaders(),
      });

      return await handleAPIResponse(response);
    } catch (error) {
      console.error('Error al obtener permisos:', error);
      throw error;
    }
  },

  // Obtener roles disponibles
  async getRoles() {
    try {
      const response = await fetch(API_ENDPOINTS.adminActions.findRoles, {
        method: 'GET',
        headers: getAuthHeaders(),
      });

      return await handleAPIResponse(response);
    } catch (error) {
      console.error('Error al obtener roles:', error);
      throw error;
    }
  },

  // Obtener rol por ID
  async getRoleById(roleId) {
    try {
      const response = await fetch(API_ENDPOINTS.adminActions.getRoleById(roleId), {
        method: 'GET',
        headers: getAuthHeaders(),
      });

      return await handleAPIResponse(response);
    } catch (error) {
      console.error(`Error al obtener rol ${roleId}:`, error);
      throw error;
    }
  },

  /**
   * Importación de Datos
   */

  // Importar usuarios desde Excel
  async importUsers(file) {
    try {
      const formData = new FormData();
      formData.append('file', file);

      const token = localStorage.getItem('access_token');
      const response = await fetch(API_ENDPOINTS.adminActions.import, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Accept': 'application/json',
          'X-User-Role': 'admin',
          'X-User-Permission': 'import.users',
        },
        body: formData,
      });

      return await handleAPIResponse(response);
    } catch (error) {
      console.error('Error al importar usuarios:', error);
      throw error;
    }
  },

  // Importar detalles de estudiantes desde Excel
  async importStudents(file) {
    try {
      const formData = new FormData();
      formData.append('file', file);

      const token = localStorage.getItem('access_token');
      const response = await fetch(API_ENDPOINTS.adminActions.importStudents, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Accept': 'application/json',
          'X-User-Role': 'admin',
          'X-User-Permission': 'import.users',
        },
        body: formData,
      });

      return await handleAPIResponse(response);
    } catch (error) {
      console.error('Error al importar estudiantes:', error);
      throw error;
    }
  },
};

export default AdminService;
