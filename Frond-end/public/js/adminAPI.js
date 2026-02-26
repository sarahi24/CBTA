
// adminAPI.js (public version)
// Define AdminAPI en window sin import/export

window.AdminAPI = {
	async updateMultipleUsersRoles(curps, rolesToAdd, rolesToRemove, token) {
		// Lógica mínima para frontend, debe ser reemplazada por fetch real
		return fetch('/api/v1/admin-actions/updated-roles', {
			method: 'POST',
			headers: {
				'Content-Type': 'application/json',
				'Authorization': `Bearer ${token}`
			},
			body: JSON.stringify({ curps, roles: rolesToAdd })
		}).then(res => res.json());
	},
	async updateMultipleUsersPermissions(curps, permissionsToAdd, permissionsToRemove, token) {
		// Lógica mínima para frontend, debe ser reemplazada por fetch real
		return fetch('/api/v1/admin-actions/updated-permissions', {
			method: 'POST',
			headers: {
				'Content-Type': 'application/json',
				'Authorization': `Bearer ${token}`
			},
			body: JSON.stringify({ curps, permissions: permissionsToAdd })
		}).then(res => res.json());
	}
};
window.__adminAPILoaded = true;