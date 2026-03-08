# Paso 2 — Diseño de arquitectura del sistema

Este documento define la arquitectura objetivo para la aplicación académica institucional con PHP 8 + MySQL 8 + Apache 2.4, siguiendo un enfoque modular y MVC simple.

## 1) Enfoque arquitectónico

- Patrón base: **MVC modular (HMVC ligero)**.
- Entrada única: `public/index.php` (Front Controller).
- Enrutamiento interno por módulo/controlador/acción.
- Renderizado servidor (PHP + Bootstrap) con apoyo de **AJAX/jQuery** para operaciones dinámicas.
- Acceso a datos exclusivamente con **PDO + Prepared Statements**.

## 2) Estructura de carpetas propuesta

```text
/colegio-app
├── app/
│   ├── Core/
│   │   ├── App.php
│   │   ├── Router.php
│   │   ├── Controller.php
│   │   ├── Model.php
│   │   ├── View.php
│   │   ├── Auth.php
│   │   ├── Csrf.php
│   │   ├── Validator.php
│   │   ├── UploadService.php
│   │   ├── AuditService.php
│   │   └── Response.php
│   ├── Config/
│   │   ├── app.php
│   │   ├── database.php
│   │   ├── mail.php
│   │   └── uploads.php
│   ├── Modules/
│   │   ├── Auth/
│   │   │   ├── Controllers/
│   │   │   ├── Models/
│   │   │   └── Views/
│   │   ├── Dashboard/
│   │   ├── Academico/
│   │   │   ├── Periodos/
│   │   │   ├── Guias/
│   │   │   └── Actividades/
│   │   ├── Entregas/
│   │   ├── Calificaciones/
│   │   ├── Retroalimentacion/
│   │   ├── Usuarios/
│   │   ├── Reportes/
│   │   └── Auditoria/
│   ├── Views/
│   │   ├── layouts/
│   │   ├── partials/
│   │   └── errors/
│   └── Storage/
│       ├── logs/
│       ├── cache/
│       └── temp/
├── bootstrap/
│   └── init.php
├── public/
│   ├── index.php
│   ├── assets/
│   │   ├── css/
│   │   ├── js/
│   │   └── img/
│   └── .htaccess
├── storage/
│   └── uploads/
│       ├── entregas/
│       └── retroalimentacion/
├── database/
│   ├── migrations/
│   ├── seeds/
│   └── sql/
├── routes/
│   ├── web.php
│   └── api.php
└── vendor/
```

## 3) Módulos funcionales

### 3.1 Auth
- Login estudiante: documento + captcha + validación en tiempo real contra `matricula`.
- Login docente/admin: credenciales locales.
- Recuperación de contraseña por correo (docente/admin).
- Gestión de sesión: expiración por inactividad de 10 minutos.

### 3.2 Academico
- Gestión de periodos (4 periodos, solapamiento permitido, bloqueo/desbloqueo de calificaciones).
- Gestión de guías por periodo y grupo.
- Gestión de actividades (con o sin guía), incluyendo estado (borrador/publicada/cerrada/calificada/archivada).

### 3.3 Entregas
- Subida de múltiples archivos.
- Reentregas con historial completo (fecha, IP, versión, usuario).
- Estados: `estado_entrega`, `estado_tiempo`, `estado_revision`.
- Regla de nota final basada en entrega marcada como `final`.

### 3.4 Calificaciones y retroalimentación
- Escala 0.0 a 10.0 (1 decimal).
- Rúbrica por criterios + opción de nota automática/manual.
- Publicación controlada por docente.
- Adjuntos de retroalimentación.

### 3.5 Usuarios y roles
- Tabla única de usuarios con múltiples roles.
- Asignación docente a múltiples grupos.
- Administración de permisos por rol + acción.

### 3.6 Auditoría
- Registro de eventos críticos: creación/edición/publicación/calificación/descargas.
- Log de cambios sensibles y trazabilidad por usuario y fecha.

## 4) Flujo de autenticación (alto nivel)

## 4.1 Estudiante
1. Ingresa documento + captcha.
2. Sistema valida captcha.
3. Consulta en tiempo real BD `matricula` (estado 1 o 17).
4. Si cumple, crea/actualiza sesión en sistema nuevo.
5. Carga dashboard con año, grado, grupo, periodos, actividades y entregas.

## 4.2 Docente / Administrador
1. Login con usuario/contraseña local.
2. Verificación con `password_hash()/password_verify()`.
3. Carga de roles y permisos en sesión.
4. Redirección a panel por rol principal.

## 5) Capas de seguridad obligatorias

- PDO + prepared statements en todas las consultas.
- Validación y sanitización de entrada (servidor).
- Tokens CSRF en formularios y endpoints AJAX mutables.
- Control de acceso por middleware de autenticación/rol.
- Subidas seguras:
  - validación MIME + extensión,
  - tamaño máximo configurable,
  - renombrado aleatorio,
  - almacenamiento fuera de `public/`,
  - descarga servida por controlador autorizado.
- Password hashing robusto para cuentas locales.
- Auditoría obligatoria de acciones sensibles.

## 6) Modelo de datos (vista macro)

- `usuarios`
- `roles`
- `usuario_roles`
- `docente_grupo`
- `anios_lectivos`
- `periodos`
- `guias`
- `actividades`
- `actividad_grupo`
- `entregas`
- `entrega_archivos`
- `retroalimentaciones`
- `calificaciones`
- `rubricas`
- `rubrica_criterios`
- `auditoria_eventos`
- `configuraciones`

> Integración externa: consultas de estudiante/estado académico desde BD legado `matricula`.

## 7) Estrategia AJAX (jQuery)

Usar AJAX para:
- consulta de actividades y entregas sin recargar página,
- subida de tareas con `FormData`,
- publicación de retroalimentación y nota,
- cambios de estado de actividad/entrega,
- filtros por periodo/grupo.

Buenas prácticas:
- respuestas JSON con estructura `{ok, message, data, errors}`,
- manejo centralizado de errores HTTP,
- spinner y mensajes de estado en UI.

## 8) Decisiones operativas

- Despliegue en servidor único (Apache).
- Sin ambientes separados en etapa inicial.
- Backups manuales (recomendación: definir checklist operativo).

## 9) Riesgos activos y mitigación recomendada

1. **Autenticación estudiante sin secreto** (solo documento + captcha):
   - Mitigar con captcha robusto + monitoreo + opción futura de PIN.
2. **Sin rate limiting**:
   - Mitigar con registro de intentos y bloqueo temporal configurable a futuro.
3. **Dependencia del legado en login**:
   - Mitigar con timeout controlado y mensajes de contingencia.
4. **Carga de archivos**:
   - Mitigar con validación estricta y almacenamiento no público.

## 10) Entregable siguiente (Paso 3.1)

Con esta arquitectura aprobada, el siguiente módulo será:

**Diseño de base de datos nueva (MySQL 8):**
- diagrama lógico,
- DDL de tablas,
- llaves foráneas,
- índices,
- reglas de integridad,
- tabla de usuarios/roles y tablas académicas.
