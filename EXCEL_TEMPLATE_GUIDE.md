# Plantilla de Importación de Usuarios

## Descripción

Esta documentación proporciona ejemplos de cómo preparar un archivo Excel para importar usuarios al sistema.

## Ejemplo de Archivo Excel

A continuación se muestra la estructura exacta que debe tener tu archivo Excel:

### Encabezados (Fila 1)

| A | B | C | D | E | F | G | H | I | J | K | L | M | N | O | P | Q | R | S |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| name | last_name | email | phone_number | birthdate | gender | curp | street | city | state | zip_code | blood_type | registration_date | status | career_id | n_control | semestre | group | workshop |

### Datos de Ejemplo (Filas 2+)

#### Fila 2 - Usuario Completo
| A | B | C | D | E | F | G | H | I | J | K | L | M | N | O | P | Q | R | S |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Juan | García López | juan.garcia@example.com | +5215551234567 | 1995-03-15 | hombre | GARC950315HJLMNN00 | Calle Principal 123 | México | CDMX | 06500 | O+ | 2024-01-15 | activo | 5 | 202400001 | 3 | A | Programación |

#### Fila 3 - Usuario Simplificado
| A | B | C | D | E | F | G | H | I | J | K | L | M | N | O | P | Q | R | S |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| María | López Sánchez | maria.lopez@example.com | +5215559876543 | 1998-07-22 | mujer | LOPS980722HJLNNRA5 | Avenida Secundaria 456 | Ciudad de México | CDMX | 04000 | A+ | 2024-01-20 | activo | 3 | 202400002 | 2 | B | Diseño |

## Guía Detallada de Campos

### 1. **name** (Nombre)
- **Tipo**: Texto
- **Límite**: Máximo 255 caracteres
- **Ejemplo**: `Juan`, `María`, `Carlos Alberto`
- **Validación**: Obligatorio, no puede estar vacío

### 2. **last_name** (Apellidos)
- **Tipo**: Texto
- **Límite**: Máximo 255 caracteres
- **Ejemplo**: `García López`, `López Sánchez`, `Pérez García`
- **Validación**: Obligatorio, puede incluir múltiples apellidos

### 3. **email** (Correo Electrónico)
- **Tipo**: Email
- **Formato**: usuario@dominio.com
- **Ejemplo**: `juan.garcia@example.com`
- **Validación**: 
  - Obligatorio
  - Debe ser válido
  - Debe ser único en el sistema
  - No se permiten duplicados

### 4. **phone_number** (Teléfono)
- **Tipo**: Texto
- **Formato**: +52 + código de área + número
- **Ejemplo**: `+5215551234567`
- **Validación**:
  - Obligatorio
  - Debe comenzar con +52
  - Máximo 15 caracteres
  - Solo números y +

### 5. **birthdate** (Fecha de Nacimiento)
- **Tipo**: Fecha
- **Formato**: YYYY-MM-DD
- **Ejemplo**: `1995-03-15`
- **Validación**:
  - Obligatorio
  - Debe ser una fecha válida
  - No puede ser fecha futura
  - La edad debe ser razonable (generalmente 16+)

### 6. **gender** (Género)
- **Tipo**: Opciones predefinidas
- **Valores válidos**:
  - `hombre` (minúsculas)
  - `mujer` (minúsculas)
- **Ejemplo**: `hombre`, `mujer`
- **Validación**:
  - Obligatorio
  - Solo estos dos valores
  - Sensible a mayúsculas

### 7. **curp** (CURP)
- **Tipo**: Texto
- **Longitud**: Exactamente 18 caracteres
- **Ejemplo**: `GARC950315HJLMNN00`
- **Validación**:
  - Obligatorio
  - Exactamente 18 caracteres
  - Debe cumplir formato oficial de CURP
  - Debe ser único en el sistema

**Formato de CURP:**
```
GARC950315HJLMNN00
├─ GARC = Primeras 4 letras del apellido y nombre
├─ 95 = Año de nacimiento (dos últimos dígitos)
├─ 03 = Mes de nacimiento (01-12)
├─ 15 = Día de nacimiento (01-31)
├─ H = Género (H=hombre, M=mujer)
├─ JLM = Consonantes del segundo apellido, primer apellido, nombre
├─ NN = Consonantes internas
└─ 00 = Números de secuencia y verificación
```

### 8. **street** (Calle/Dirección)
- **Tipo**: Texto
- **Límite**: Máximo 255 caracteres
- **Ejemplo**: `Calle Principal 123`, `Avenida Paseo 456 Apto 7B`
- **Validación**: Obligatorio

### 9. **city** (Ciudad)
- **Tipo**: Texto
- **Límite**: Máximo 100 caracteres
- **Ejemplo**: `México`, `Ciudad de México`, `Guadalajara`
- **Validación**: Obligatorio

### 10. **state** (Estado/Provincia)
- **Tipo**: Texto
- **Límite**: Máximo 100 caracteres
- **Ejemplo**: `CDMX`, `Estado de México`, `Jalisco`
- **Validación**: Obligatorio

### 11. **zip_code** (Código Postal)
- **Tipo**: Texto/Número
- **Formato**: Generalmente 5-6 dígitos
- **Ejemplo**: `06500`, `28001`, `44100`
- **Validación**:
  - Obligatorio
  - Debe ser válido para la ciudad/estado

### 12. **blood_type** (Tipo de Sangre)
- **Tipo**: Opciones predefinidas
- **Valores válidos**:
  - `A+`, `A-`
  - `B+`, `B-`
  - `O+`, `O-`
  - `AB+`, `AB-`
- **Ejemplo**: `O+`, `A-`, `AB+`
- **Validación**:
  - Obligatorio
  - Solo valores predefinidos
  - Sensible a mayúsculas

### 13. **registration_date** (Fecha de Registro)
- **Tipo**: Fecha
- **Formato**: YYYY-MM-DD
- **Ejemplo**: `2024-01-15`, `2024-06-30`
- **Validación**:
  - Opcional (se usa fecha actual si no se especifica)
  - Debe ser una fecha válida
  - Debe ser anterior o igual a hoy

### 14. **status** (Estado del Usuario)
- **Tipo**: Opciones predefinidas
- **Valores válidos**:
  - `activo`
  - `inactivo`
- **Ejemplo**: `activo`
- **Validación**:
  - Opcional (predeterminado: `activo`)
  - Solo estos valores

### 15. **career_id** (ID de Carrera)
- **Tipo**: Número
- **Rango**: Debe existir en el sistema
- **Ejemplo**: `5`, `10`, `15`
- **Validación**:
  - Obligatorio
  - Debe corresponder a una carrera existente
  - Contacta al administrador para validar IDs

**Carreras Disponibles (Ejemplo):**
| ID | Nombre |
|----|--------|
| 1 | Ingeniería en Sistemas |
| 2 | Administración de Empresas |
| 3 | Derecho |
| 4 | Contabilidad |
| 5 | Psicología |

### 16. **n_control** (Número de Control)
- **Tipo**: Texto/Número
- **Formato**: Generalmente AAAABBBBCC
- **Ejemplo**: `202400001`, `202300456`
- **Validación**:
  - Obligatorio
  - Debe ser único
  - Formato según institución

**Formato Típico:**
```
202400001
├─ 2024 = Año de ingreso
└─ 00001 = Número secuencial
```

### 17. **semestre** (Semestre/Período)
- **Tipo**: Número
- **Rango**: 1-8
- **Ejemplo**: `1`, `3`, `8`
- **Validación**:
  - Obligatorio
  - Número entre 1 y 8
  - Debe ser entero

### 18. **group** (Grupo)
- **Tipo**: Texto
- **Longitud**: Generalmente 1-2 caracteres
- **Ejemplo**: `A`, `B`, `C`, `01`, `02`
- **Validación**:
  - Obligatorio
  - Máximo 10 caracteres

### 19. **workshop** (Taller/Asignatura)
- **Tipo**: Texto
- **Límite**: Máximo 255 caracteres
- **Ejemplo**: `Programación`, `Base de Datos`, `Análisis Matemático`
- **Validación**: Obligatorio

## Ejemplo de Archivo Completo

```
name          | last_name        | email                    | phone_number      | birthdate   | gender | curp              | street                   | city         | state | zip_code | blood_type | registration_date | status | career_id | n_control | semestre | group | workshop
Juan          | García López     | juan.garcia@example.com  | +5215551234567    | 1995-03-15  | hombre | GARC950315HJLMNN00 | Calle Principal 123      | México       | CDMX  | 06500    | O+         | 2024-01-15        | activo | 5         | 202400001 | 3        | A     | Programación
María         | López Sánchez    | maria.lopez@example.com | +5215559876543    | 1998-07-22  | mujer  | LOPS980722HJLNNRA5 | Avenida Secundaria 456   | Ciudad México| CDMX  | 04000    | A+         | 2024-01-20        | activo | 3         | 202400002 | 2        | B     | Diseño
Carlos        | Pérez García     | carlos.perez@example.com| +5215552468101    | 1996-11-08  | hombre | PEGC961108HJLPRRA3 | Calle Tertiary 789       | Toluca       | EdoMéx| 50000    | B-         | 2024-02-05        | activo | 1         | 202400003 | 4        | A     | Bases de Datos
```

## Validación Previa al Importar

Antes de importar, verifica:

### ✓ Checklist

- [ ] El archivo es .xlsx (Excel 2007+)
- [ ] Todas las columnas están en el orden correcto
- [ ] No hay columnas adicionales antes de los datos
- [ ] La fila 1 contiene los encabezados
- [ ] Los datos comienzan en la fila 2
- [ ] No hay filas vacías entre datos
- [ ] CURPs son válidos (18 caracteres exactos)
- [ ] Emails son únicos y válidos
- [ ] Números de teléfono tienen formato +52
- [ ] Fechas tienen formato YYYY-MM-DD
- [ ] Semestre está entre 1 y 8
- [ ] Género es "hombre" o "mujer" (minúsculas)
- [ ] Tipo de sangre es válido (A+, A-, B+, B-, O+, O-, AB+, AB-)
- [ ] Career IDs existen en el sistema
- [ ] Números de control son únicos

## Errores Comunes

### ❌ Error: "Email inválido"
**Causa**: Email no tiene @ o formato incorrecto
**Solución**: Valida el formato usuario@dominio.com

### ❌ Error: "CURP requerida"
**Causa**: Campo CURP vacío o con menos de 18 caracteres
**Solución**: Completa con CURP válido de 18 caracteres

### ❌ Error: "Career ID no existe"
**Causa**: El ID de carrera no está en el sistema
**Solución**: Verifica IDs disponibles con administrador

### ❌ Error: "Semestre inválido"
**Causa**: Valor fuera de rango 1-8
**Solución**: Usa solo números 1, 2, 3, 4, 5, 6, 7 u 8

### ❌ Error: "Género inválido"
**Causa**: Valor no es "hombre" o "mujer"
**Solución**: Usa exactamente "hombre" o "mujer" en minúsculas

## Descargar Plantilla

[Descargar plantilla Excel vacía](./plantilla-usuarios.xlsx)

## Soporte

Si encuentras problemas con la importación:
1. Revisa esta guía
2. Contacta al administrador del sistema
3. Proporciona el archivo Excel y los errores reportados

