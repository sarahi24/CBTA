/// <reference types="astro/client" />

declare global {
    interface Window {
        AdminAPI: any;
        __adminAPILoaded: boolean;
        __API_BASE_URL__: string;
        __rolesDataRegistered__: boolean;
    }
}

export {};
