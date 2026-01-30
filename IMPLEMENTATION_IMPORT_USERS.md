# Implementación - Endpoint de Importación de Usuarios

## Resumen General

Se ha implementado completamente la funcionalidad de importación de usuarios desde archivos Excel en la interfaz frontend del sistema de gestión escolar. La implementación incluye:

✅ Funciones JavaScript para manejar la importación
✅ Modal interactivo para carga de archivos
✅ Validación de archivos en cliente
✅ Visualización de resultados detallados
✅ Manejo de errores y advertencias
✅ Documentación completa
✅ Script de prueba en PowerShell

## Archivos Modificados

### 1. **Frond-end/src/pages/roles.astro**

#### Estados Añadidos (Línea ~1130)
```javascript
// Estados para importación de usuarios
showImportModal: false,           // Controla la visibilidad del modal
importFile: null,                 // Archivo seleccionado
isImporting: false,               // Estado de carga (mostrar spinner)
importResult: null,               // Resultado exitoso (summary)
importError: null,                // Información de error
```

#### Funciones Implementadas (Línea ~3665)

1. **openImportModal()**
   - Abre el modal de importación
   - Resetea los estados
   - Limpia errores previos

2. **closeImportModal()**
   - Cierra el modal de importación
   - Limpia todos los estados
   - Resetea el archivo seleccionado

3. **handleFileSelect(event)**
   - Valida que sea archivo Excel (.xlsx o .xls)
   - Verifica el tipo MIME
   - Almacena el archivo seleccionado
   - Muestra notificaciones de error si aplica

4. **importUsersFromFile()**
   - Realiza validaciones previas
   - Crea FormData con el archivo
   - Realiza solicitud POST al endpoint
   - Procesa respuesta exitosa
   - Maneja errores de validación
   - Recarga la lista de usuarios
   - Cierra el modal automáticamente

#### UI Modal Añadido (Línea ~1005)

El modal incluye:
- Sección para seleccionar archivo Excel
- Validación de tipo de archivo
- Mostrador de resumen de importación exitosa
- Tabla con estadísticas:
  - Total de filas recibidas
  - Filas procesadas
  - Filas insertadas
  - Filas fallidas
  - Porcentaje de éxito
- Sección de errores detallados (filas con errores)
- Sección de advertencias
- Botones de acción (Cancelar, Importar, Cerrar)

#### Integración con Botón Existente

Se utilizó el botón "Importar" existente en la línea ~129:
```javascript
<button @click="openImportModal(); showImportMenu = false"
        class="w-full text-left px-4 py-3 hover:bg-emerald-50 transition-colors"
>
    <span class="text-2xl">👥</span>
    <div>
        <div class="font-semibold text-gray-800">Usuarios Completos</div>
        <div class="text-xs text-gray-500">Importar usuarios con todos sus datos</div>
    </div>
</button>
```

## Archivos de Documentación Creados

### 1. **IMPORT_USERS_GUIDE.md** (Guía Completa)

Contiene:
- Descripción general del endpoint
- Requisitos y headers necesarios
- Formato exacto del archivo Excel (tabla con 19 columnas)
- Validaciones por campo
- Respuestas exitosas y de error
- Ejemplos de implementación frontend
- Ejemplos de uso con cURL y PowerShell
- Mejores prácticas
- Requisitos de permisos
- Solución de problemas
- Historial de cambios

### 2. **EXCEL_TEMPLATE_GUIDE.md** (Plantilla y Ejemplos)

Contiene:
- Estructura exacta del archivo Excel
- Ejemplo con 2 usuarios
- Guía detallada de cada campo (19 campos)
- Formato de CURP explicado
- Formato de número de control típico
- Ejemplo de archivo completo
- Checklist de validación previa
- Errores comunes y soluciones
- Enlace para descargar plantilla

### 3. **test-import-users.ps1** (Script de Prueba)

Script PowerShell que:
- Acepta parámetros: FilePath, ApiBaseUrl, Token
- Valida existencia del archivo
- Realiza la solicitud POST
- Muestra resumen de importación
- Detalla errores encontrados
- Muestra advertencias
- Manejo de excepciones

## Endpoint API

**URL**: `POST /api/v1/admin-actions/import-users`

**Headers Requeridos**:
```
Authorization: Bearer {token}
X-User-Role: admin | supervisor
X-User-Permission: import.users
Content-Type: multipart/form-data
```

**Body**: FormData con campo `file`

**Respuesta Exitosa (200)**:
```json
{
  "success": true,
  "message": "Usuarios importados correctamente.",
  "data": {
    "summary": {
      "total_rows_received": 100,
      "rows_processed": 95,
      "rows_inserted": 90,
      "rows_failed": 5,
      "success_rate": 94.74
    },
    "errors": {
      "row_errors": [...],
      "global_errors": [...],
      "total_errors": 3
    },
    "warnings": {
      "list": [...],
      "total_warnings": 2
    }
  }
}
```

## Columnas del Archivo Excel (En Orden)

| # | Columna | Tipo | Ejemplo | Requerido |
|---|---------|------|---------|-----------|
| 1 | name | Texto | Juan | ✓ |
| 2 | last_name | Texto | García López | ✓ |
| 3 | email | Email | juan@example.com | ✓ |
| 4 | phone_number | Teléfono | +5215551234567 | ✓ |
| 5 | birthdate | YYYY-MM-DD | 1995-03-15 | ✓ |
| 6 | gender | hombre/mujer | hombre | ✓ |
| 7 | curp | Texto (18) | GARC950315HJLMNN00 | ✓ |
| 8 | street | Texto | Calle Principal 123 | ✓ |
| 9 | city | Texto | México | ✓ |
| 10 | state | Texto | CDMX | ✓ |
| 11 | zip_code | Código | 06500 | ✓ |
| 12 | blood_type | A+/A-/... | O+ | ✓ |
| 13 | registration_date | YYYY-MM-DD | 2024-01-15 | ○ |
| 14 | status | activo/inactivo | activo | ○ |
| 15 | career_id | Número | 5 | ✓ |
| 16 | n_control | Texto/Número | 202400001 | ✓ |
| 17 | semestre | Número (1-8) | 3 | ✓ |
| 18 | group | Texto | A | ✓ |
| 19 | workshop | Texto | Programación | ✓ |

## Validaciones Implementadas

### En Cliente (Frontend)
- ✓ Validación de tipo de archivo (.xlsx, .xls)
- ✓ Validación MIME type
- ✓ Verificación de token de autenticación
- ✓ Validación de usuario seleccionado

### En Servidor (Backend)
- ✓ Validación de estructura del Excel
- ✓ Validación de formato CURP (18 caracteres)
- ✓ Validación de email único
- ✓ Validación de formato de teléfono
- ✓ Validación de fechas (YYYY-MM-DD)
- ✓ Validación de género (hombre/mujer)
- ✓ Validación de tipo de sangre
- ✓ Validación de existencia de carrera
- ✓ Validación de rango de semestre (1-8)
- ✓ Detección de duplicados
- ✓ Manejo transaccional de errores

## Flujo de Importación

```
1. Usuario hace clic en "Importar" → "Usuarios Completos"
                        ↓
2. Se abre modal de importación
                        ↓
3. Usuario selecciona archivo Excel
                        ↓
4. Sistema valida tipo de archivo
                        ↓
5. Usuario hace clic en "Importar Usuarios"
                        ↓
6. Se envía FormData con archivo al servidor
        (header: X-User-Permission: import.users)
                        ↓
7. Servidor procesa el Excel
                        ↓
8. Sistema muestra resumen:
   - Total recibidas / procesadas / insertadas / fallidas
   - Porcentaje de éxito
   - Lista de errores detallados
   - Advertencias (si aplica)
                        ↓
9. Usuario puede cerrar modal
                        ↓
10. Lista de usuarios se recarga automáticamente
```

## Estados y Comportamiento de UI

### Estado: Sin Modal Abierto
- Botón "Importar" visible en toolbar
- Menú desplegable con opciones de importación

### Estado: Modal Abierto - Seleccionar Archivo
```
┌─ Modal de Importación ─────────────┐
│ 📥 Importar Usuarios              │
│                                    │
│ 📋 Selecciona un archivo Excel    │
│    [Seleccionar archivo]           │
│                                    │
│ 📋 Columnas Requeridas:           │
│    [Lista de 19 columnas]         │
│                                    │
│ [Cancelar] [Importar Usuarios]    │
└────────────────────────────────────┘
```

### Estado: Importando
- Botón "Importar Usuarios" muestra "Importando..."
- Spinner/indicador de carga
- Botones deshabilitados

### Estado: Importación Exitosa
```
┌─ Modal de Importación ─────────────┐
│ 📥 Importar Usuarios              │
│                                    │
│ ✓ Importación Completada          │
│ Total recibidas: 100              │
│ Filas procesadas: 95              │
│ Filas insertadas: 90              │
│ Filas fallidas: 5                 │
│ Tasa de éxito: 94.74%             │
│                                    │
│ ⚠️ Errores Encontrados:           │
│ • Fila 15: CURP requerida         │
│ • Fila 23: Email inválido         │
│ [... más errores]                 │
│                                    │
│                      [Cerrar]     │
└────────────────────────────────────┘
```

### Estado: Error en Importación
```
┌─ Modal de Importación ─────────────┐
│ 📥 Importar Usuarios              │
│                                    │
│ ❌ Error en la Importación        │
│ Mensaje: Error descriptivo        │
│                                    │
│ Errores de validación:            │
│ • email: El email es requerido    │
│ • curp: CURP inválida             │
│                                    │
│                      [Cerrar]     │
└────────────────────────────────────┘
```

## Notificaciones al Usuario

### Éxito
```
✓ Usuarios importados correctamente
(Toast verde con check)
```

### Error - Archivo no Seleccionado
```
❌ Por favor selecciona un archivo
(Toast rojo)
```

### Error - Tipo de Archivo Inválido
```
❌ Solo se permiten archivos Excel (.xlsx o .xls)
(Toast rojo)
```

### Error - No Autenticado
```
❌ No hay token de autenticación
(Toast rojo)
```

### Error - Validación
```
❌ Error: {mensaje de error del servidor}
(Toast rojo con detalles)
```

## Características Adicionales

### 1. Recarga Automática
- Después de importación exitosa, la lista de usuarios se recarga
- Demora: 1 segundo antes de recargar

### 2. Cierre Automático
- Modal se cierra automáticamente después de importación exitosa
- Demora: 3 segundos

### 3. Información Contextual
- Se muestra lista de columnas requeridas en el modal
- Se indica qué campos son obligatorios vs opcionales
- Se proporciona ejemplo de formato

### 4. Manejo de Errores Detallado
- Se muestran primeros 5 errores de filas
- Se agrupan errores por tipo
- Se muestran advertencias separadamente
- Se proporciona contexto (fila, valor problemático)

### 5. Indicadores Visuales
- Spinner/loader durante importación
- Colores según estado (verde=éxito, rojo=error, amarillo=advertencia)
- Iconos descriptivos (📥, ✓, ❌, ⚠️)

## Requisitos de Seguridad

### Headers Requeridos
```
Authorization: Bearer {token}     // Token JWT válido
X-User-Role: admin|supervisor     // Rol del usuario
X-User-Permission: import.users   // Permiso específico
```

### Validación de Permisos
- Solo usuarios con permiso `import.users` pueden importar
- Roles permitidos: admin, supervisor
- El sistema valida permisos antes de procesar

## Características de Respuesta

### Información de Éxito Mostrada

1. **Estadísticas Principales**
   - Total de filas recibidas
   - Filas procesadas exitosamente
   - Filas insertadas en BD
   - Filas que fallaron
   - Porcentaje de éxito

2. **Errores Detallados**
   - Número de fila
   - Mensaje de error específico
   - Contexto (valores problemáticos)
   - Timestamp del error

3. **Advertencias**
   - Tipo de advertencia
   - Mensaje descriptivo
   - Información del chunk procesado

## Testing

### Test con PowerShell
```powershell
.\test-import-users.ps1 -Token "your_token_here" -FilePath "C:\path\usuarios.xlsx"
```

### Test con cURL
```bash
curl -X POST "https://nginx-production-728f.up.railway.app/api/v1/admin-actions/import-users" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "X-User-Role: admin" \
  -H "X-User-Permission: import.users" \
  -F "file=@usuarios.xlsx"
```

## Mejores Prácticas para Usuarios

1. ✓ Validar datos antes de importar
2. ✓ Usar plantilla proporcionada
3. ✓ Verificar formato de CURP (18 caracteres)
4. ✓ Asegurar emails únicos
5. ✓ Revisar IDs de carrera disponibles
6. ✓ Usar formato de fecha YYYY-MM-DD
7. ✓ Dividir en múltiples archivos si >1000 usuarios
8. ✓ Guardar registro de importaciones para auditoría
9. ✓ Contactar admin si hay errores sistemáticos

## Integración con Sistema Existente

- Se integra con autenticación JWT existente
- Usa variable `this.apiBaseUrl` del sistema
- Reutiliza función `showNotify()` para notificaciones
- Compatible con estructura de permisos existente
- Se integra con método `loadUsers()` para recargar datos

## Próximos Pasos Recomendados

1. ✓ Crear plantilla Excel de ejemplo
2. ✓ Entrenar usuarios en formato de archivo
3. ✓ Establecer procedimiento de validación
4. ✓ Documentar errores comunes
5. ✓ Crear automatización si es necesario
6. ✓ Mantener auditoría de importaciones

## Conclusión

La implementación de importación de usuarios está **completamente funcional** y lista para ser utilizada. Proporciona:

- ✅ Interface intuitiva
- ✅ Validación robusta
- ✅ Feedback detallado
- ✅ Documentación completa
- ✅ Herramientas de testing
- ✅ Manejo seguro de errores
- ✅ Integración seamless con sistema

