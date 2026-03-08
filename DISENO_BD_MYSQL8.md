# Paso 3.1 — Diseño de base de datos nueva (MySQL 8)

Este documento define el diseño lógico y físico inicial para la base de datos del nuevo sistema académico.

## 1) Principios de diseño

- Motor objetivo: **MySQL 8** (InnoDB, UTF8MB4).
- Integridad referencial con claves foráneas.
- Trazabilidad de acciones con tabla de auditoría.
- Configuración flexible para tipos de archivo y tamaño máximo.
- Soporte para roles múltiples por usuario.
- Integración con `matricula` por referencia de estudiante externo (`id_estudiante_legacy`).

## 2) Entidades principales

### Seguridad y usuarios
- `usuarios`
- `roles`
- `usuario_roles`
- `password_resets`
- `sesiones`

### Estructura académica
- `anios_lectivos`
- `periodos`
- `grupos_academicos` (grado-grupo del sistema legado referenciado)
- `docente_grupo`
- `guias`
- `actividades`

### Entregas y evaluación
- `entregas`
- `entrega_archivos`
- `rubricas`
- `rubrica_criterios`
- `calificaciones`
- `retroalimentaciones`
- `retroalimentacion_archivos`

### Operación
- `configuraciones`
- `auditoria_eventos`

## 3) Reglas funcionales mapeadas a BD

1. Un solo año activo (`anios_lectivos.activo` con restricción lógica por aplicación).
2. 4 periodos por año (validación en capa de negocio).
3. Actividad puede pertenecer o no a guía (`actividades.id_guia` nullable).
4. Entregas múltiples por actividad/estudiante con versión incremental.
5. Nota final asociada a entrega marcada `estado_entrega='final'`.
6. Escala 0.0 a 10.0 con 1 decimal (`DECIMAL(3,1)`).
7. Estados de entrega según definición acordada:
   - `estado_entrega`: pendiente | parcial | final
   - `estado_tiempo`: a_tiempo | extemporanea
   - `estado_revision`: pendiente | revisada
8. Auditoría obligatoria de operaciones críticas.

## 4) Índices recomendados

- `usuarios(email)` UNIQUE
- `usuarios(documento)` INDEX
- `periodos(id_anio, fecha_inicio, fecha_fin)`
- `guias(id_periodo, id_grupo, estado)`
- `actividades(id_periodo, id_grupo, estado, fecha_limite)`
- `entregas(id_actividad, id_estudiante_legacy, version)` UNIQUE
- `entrega_archivos(id_entrega)`
- `calificaciones(id_entrega)` UNIQUE
- `auditoria_eventos(tabla, registro_id, fecha_evento)`

## 5) Consideraciones de seguridad

- Contraseñas docentes/admin con `password_hash` (Bcrypt/Argon2id).
- Token de recuperación en `password_resets` con expiración.
- No almacenar rutas públicas de archivos ejecutables.
- Registrar IP y agente de usuario en eventos de sesión/auditoría.

## 6) DDL inicial

El script DDL inicial se entrega en: `database/sql/001_schema.sql`

Incluye:
- creación de base `colegio_academico`,
- tablas con PK/FK,
- restricciones CHECK en campos críticos,
- índices principales.

## 7) Próximo módulo (si se aprueba)

**Paso 3.2 — Sistema de autenticación**
- login estudiante (documento + captcha + consulta `matricula`),
- login docente/admin,
- gestión de sesión e inactividad,
- recuperación de contraseña.
