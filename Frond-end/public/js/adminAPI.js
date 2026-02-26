// adminAPI.js
// Reexporta el AdminAPI del src/utils para uso en el frontend
import { AdminAPI } from '/src/utils/adminAPI.js';
window.AdminAPI = AdminAPI;
window.__adminAPILoaded = true;