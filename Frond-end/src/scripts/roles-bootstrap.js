import { AdminAPI } from '../utils/adminAPI.js';
import AuthService from '../utils/authService.js';

window.AdminAPI = AdminAPI;
window.AuthService = AuthService;
window.__adminAPILoaded = true;
console.log('✅ AdminAPI cargada:', window.AdminAPI);
