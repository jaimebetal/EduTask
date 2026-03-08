CREATE DATABASE IF NOT EXISTS colegio_academico
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;

USE colegio_academico;

-- =========================
-- Usuarios, roles y sesión
-- =========================
CREATE TABLE roles (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(50) NOT NULL UNIQUE,
  descripcion VARCHAR(255) NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE usuarios (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  documento VARCHAR(30) NULL,
  nombres VARCHAR(100) NOT NULL,
  apellidos VARCHAR(100) NOT NULL,
  email VARCHAR(150) NULL,
  password_hash VARCHAR(255) NULL,
  tipo_usuario ENUM('admin','docente','estudiante') NOT NULL,
  activo TINYINT(1) NOT NULL DEFAULT 1,
  id_estudiante_legacy BIGINT UNSIGNED NULL,
  ultimo_login_at DATETIME NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_usuarios_email (email),
  KEY idx_usuarios_documento (documento),
  KEY idx_usuarios_legacy (id_estudiante_legacy)
) ENGINE=InnoDB;

CREATE TABLE usuario_roles (
  id_usuario BIGINT UNSIGNED NOT NULL,
  id_rol BIGINT UNSIGNED NOT NULL,
  PRIMARY KEY (id_usuario, id_rol),
  CONSTRAINT fk_usuario_roles_usuario
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id)
    ON DELETE CASCADE,
  CONSTRAINT fk_usuario_roles_rol
    FOREIGN KEY (id_rol) REFERENCES roles(id)
    ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE password_resets (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_usuario BIGINT UNSIGNED NOT NULL,
  token_hash VARCHAR(255) NOT NULL,
  expira_at DATETIME NOT NULL,
  usado TINYINT(1) NOT NULL DEFAULT 0,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_password_resets_usuario
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id)
    ON DELETE CASCADE,
  KEY idx_password_resets_usuario (id_usuario),
  KEY idx_password_resets_expira (expira_at)
) ENGINE=InnoDB;

CREATE TABLE sesiones (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_usuario BIGINT UNSIGNED NOT NULL,
  token VARCHAR(255) NOT NULL,
  ip VARCHAR(45) NULL,
  user_agent VARCHAR(255) NULL,
  ultimo_movimiento_at DATETIME NOT NULL,
  expira_at DATETIME NOT NULL,
  activa TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_sesiones_usuario
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id)
    ON DELETE CASCADE,
  UNIQUE KEY uq_sesiones_token (token),
  KEY idx_sesiones_usuario (id_usuario, activa)
) ENGINE=InnoDB;

-- =========================
-- Estructura académica
-- =========================
CREATE TABLE anios_lectivos (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  anio SMALLINT UNSIGNED NOT NULL,
  activo TINYINT(1) NOT NULL DEFAULT 0,
  fecha_inicio DATE NOT NULL,
  fecha_fin DATE NOT NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_anio (anio),
  CONSTRAINT chk_anio_fechas CHECK (fecha_fin >= fecha_inicio)
) ENGINE=InnoDB;

CREATE TABLE periodos (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_anio BIGINT UNSIGNED NOT NULL,
  numero TINYINT UNSIGNED NOT NULL,
  nombre VARCHAR(80) NOT NULL,
  fecha_inicio DATE NOT NULL,
  fecha_fin DATE NOT NULL,
  bloqueado TINYINT(1) NOT NULL DEFAULT 0,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_periodos_anio
    FOREIGN KEY (id_anio) REFERENCES anios_lectivos(id)
    ON DELETE CASCADE,
  UNIQUE KEY uq_periodo_anio_numero (id_anio, numero),
  KEY idx_periodos_rango (id_anio, fecha_inicio, fecha_fin),
  CONSTRAINT chk_periodos_fechas CHECK (fecha_fin >= fecha_inicio),
  CONSTRAINT chk_periodo_numero CHECK (numero BETWEEN 1 AND 4)
) ENGINE=InnoDB;

CREATE TABLE grupos_academicos (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_grado_legacy BIGINT UNSIGNED NOT NULL,
  id_grupo_legacy BIGINT UNSIGNED NOT NULL,
  nombre_grado VARCHAR(50) NOT NULL,
  nombre_grupo VARCHAR(50) NOT NULL,
  etiqueta VARCHAR(30) GENERATED ALWAYS AS (CONCAT(nombre_grado, '-', nombre_grupo)) STORED,
  activo TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_grupo_legacy (id_grado_legacy, id_grupo_legacy),
  KEY idx_grupo_activo (activo)
) ENGINE=InnoDB;

CREATE TABLE docente_grupo (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_docente BIGINT UNSIGNED NOT NULL,
  id_grupo BIGINT UNSIGNED NOT NULL,
  area VARCHAR(100) NOT NULL DEFAULT 'Tecnología e Informática',
  anio SMALLINT UNSIGNED NOT NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_docente_grupo_docente
    FOREIGN KEY (id_docente) REFERENCES usuarios(id)
    ON DELETE CASCADE,
  CONSTRAINT fk_docente_grupo_grupo
    FOREIGN KEY (id_grupo) REFERENCES grupos_academicos(id)
    ON DELETE CASCADE,
  UNIQUE KEY uq_docente_grupo_anio (id_docente, id_grupo, anio)
) ENGINE=InnoDB;

CREATE TABLE guias (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_periodo BIGINT UNSIGNED NOT NULL,
  id_grupo BIGINT UNSIGNED NOT NULL,
  id_docente BIGINT UNSIGNED NOT NULL,
  titulo VARCHAR(200) NOT NULL,
  descripcion TEXT NULL,
  fecha_publicacion DATETIME NOT NULL,
  requiere_entrega TINYINT(1) NOT NULL DEFAULT 1,
  estado ENUM('borrador','publicada','archivada') NOT NULL DEFAULT 'borrador',
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_guias_periodo
    FOREIGN KEY (id_periodo) REFERENCES periodos(id)
    ON DELETE RESTRICT,
  CONSTRAINT fk_guias_grupo
    FOREIGN KEY (id_grupo) REFERENCES grupos_academicos(id)
    ON DELETE RESTRICT,
  CONSTRAINT fk_guias_docente
    FOREIGN KEY (id_docente) REFERENCES usuarios(id)
    ON DELETE RESTRICT,
  KEY idx_guias_filtro (id_periodo, id_grupo, estado)
) ENGINE=InnoDB;

CREATE TABLE actividades (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_periodo BIGINT UNSIGNED NOT NULL,
  id_grupo BIGINT UNSIGNED NOT NULL,
  id_docente BIGINT UNSIGNED NOT NULL,
  id_guia BIGINT UNSIGNED NULL,
  titulo VARCHAR(200) NOT NULL,
  instrucciones TEXT NOT NULL,
  fecha_publicacion DATETIME NOT NULL,
  fecha_limite DATETIME NOT NULL,
  ponderacion DECIMAL(5,2) NOT NULL DEFAULT 0.00,
  tipo_entrega ENUM('parcial','final') NOT NULL DEFAULT 'final',
  modo_calificacion ENUM('manual','automatica','mixta') NOT NULL DEFAULT 'manual',
  estado ENUM('borrador','publicada','cerrada','calificada','archivada') NOT NULL DEFAULT 'borrador',
  permite_extemporanea TINYINT(1) NOT NULL DEFAULT 1,
  penalizacion_porcentaje DECIMAL(5,2) NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_actividades_periodo
    FOREIGN KEY (id_periodo) REFERENCES periodos(id)
    ON DELETE RESTRICT,
  CONSTRAINT fk_actividades_grupo
    FOREIGN KEY (id_grupo) REFERENCES grupos_academicos(id)
    ON DELETE RESTRICT,
  CONSTRAINT fk_actividades_docente
    FOREIGN KEY (id_docente) REFERENCES usuarios(id)
    ON DELETE RESTRICT,
  CONSTRAINT fk_actividades_guia
    FOREIGN KEY (id_guia) REFERENCES guias(id)
    ON DELETE SET NULL,
  KEY idx_actividades_filtro (id_periodo, id_grupo, estado, fecha_limite),
  CONSTRAINT chk_ponderacion CHECK (ponderacion >= 0 AND ponderacion <= 100),
  CONSTRAINT chk_penalizacion CHECK (penalizacion_porcentaje IS NULL OR (penalizacion_porcentaje >= 0 AND penalizacion_porcentaje <= 100)),
  CONSTRAINT chk_fechas_actividad CHECK (fecha_limite >= fecha_publicacion)
) ENGINE=InnoDB;

-- =========================
-- Entregas y archivos
-- =========================
CREATE TABLE entregas (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_actividad BIGINT UNSIGNED NOT NULL,
  id_estudiante_legacy BIGINT UNSIGNED NOT NULL,
  id_usuario_estudiante BIGINT UNSIGNED NULL,
  version INT UNSIGNED NOT NULL DEFAULT 1,
  estado_entrega ENUM('pendiente','parcial','final') NOT NULL DEFAULT 'pendiente',
  estado_tiempo ENUM('a_tiempo','extemporanea') NULL,
  estado_revision ENUM('pendiente','revisada') NOT NULL DEFAULT 'pendiente',
  observacion_estudiante TEXT NULL,
  fecha_entrega DATETIME NULL,
  ip_entrega VARCHAR(45) NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_entregas_actividad
    FOREIGN KEY (id_actividad) REFERENCES actividades(id)
    ON DELETE CASCADE,
  CONSTRAINT fk_entregas_usuario_estudiante
    FOREIGN KEY (id_usuario_estudiante) REFERENCES usuarios(id)
    ON DELETE SET NULL,
  UNIQUE KEY uq_entrega_version (id_actividad, id_estudiante_legacy, version),
  KEY idx_entregas_estudiante (id_estudiante_legacy),
  KEY idx_entregas_revision (estado_revision, estado_tiempo)
) ENGINE=InnoDB;

CREATE TABLE entrega_archivos (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_entrega BIGINT UNSIGNED NOT NULL,
  nombre_original VARCHAR(255) NOT NULL,
  nombre_guardado VARCHAR(255) NOT NULL,
  ruta_relativa VARCHAR(500) NOT NULL,
  mime_type VARCHAR(120) NOT NULL,
  tamanio_bytes BIGINT UNSIGNED NOT NULL,
  hash_sha256 CHAR(64) NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_entrega_archivos_entrega
    FOREIGN KEY (id_entrega) REFERENCES entregas(id)
    ON DELETE CASCADE,
  KEY idx_entrega_archivos_entrega (id_entrega)
) ENGINE=InnoDB;

-- =========================
-- Rúbricas, calificaciones y retroalimentación
-- =========================
CREATE TABLE rubricas (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_actividad BIGINT UNSIGNED NOT NULL,
  nombre VARCHAR(150) NOT NULL,
  descripcion TEXT NULL,
  puntaje_maximo DECIMAL(5,2) NOT NULL DEFAULT 10.00,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_rubricas_actividad
    FOREIGN KEY (id_actividad) REFERENCES actividades(id)
    ON DELETE CASCADE,
  UNIQUE KEY uq_rubrica_actividad (id_actividad)
) ENGINE=InnoDB;

CREATE TABLE rubrica_criterios (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_rubrica BIGINT UNSIGNED NOT NULL,
  criterio VARCHAR(200) NOT NULL,
  descripcion TEXT NULL,
  puntaje_maximo DECIMAL(5,2) NOT NULL,
  orden SMALLINT UNSIGNED NOT NULL DEFAULT 1,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_criterios_rubrica
    FOREIGN KEY (id_rubrica) REFERENCES rubricas(id)
    ON DELETE CASCADE,
  KEY idx_criterios_rubrica (id_rubrica, orden)
) ENGINE=InnoDB;

CREATE TABLE calificaciones (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_entrega BIGINT UNSIGNED NOT NULL,
  id_docente BIGINT UNSIGNED NOT NULL,
  nota_final DECIMAL(3,1) NOT NULL,
  nota_antes_penalizacion DECIMAL(3,1) NULL,
  porcentaje_penalizacion DECIMAL(5,2) NULL,
  publicada TINYINT(1) NOT NULL DEFAULT 0,
  fecha_publicacion DATETIME NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_calificaciones_entrega
    FOREIGN KEY (id_entrega) REFERENCES entregas(id)
    ON DELETE CASCADE,
  CONSTRAINT fk_calificaciones_docente
    FOREIGN KEY (id_docente) REFERENCES usuarios(id)
    ON DELETE RESTRICT,
  UNIQUE KEY uq_calificacion_entrega (id_entrega),
  CONSTRAINT chk_nota_final CHECK (nota_final >= 0.0 AND nota_final <= 10.0),
  CONSTRAINT chk_nota_antes CHECK (nota_antes_penalizacion IS NULL OR (nota_antes_penalizacion >= 0.0 AND nota_antes_penalizacion <= 10.0))
) ENGINE=InnoDB;

CREATE TABLE retroalimentaciones (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_entrega BIGINT UNSIGNED NOT NULL,
  id_docente BIGINT UNSIGNED NOT NULL,
  comentario TEXT NOT NULL,
  publicada TINYINT(1) NOT NULL DEFAULT 0,
  fecha_publicacion DATETIME NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_retro_entrega
    FOREIGN KEY (id_entrega) REFERENCES entregas(id)
    ON DELETE CASCADE,
  CONSTRAINT fk_retro_docente
    FOREIGN KEY (id_docente) REFERENCES usuarios(id)
    ON DELETE RESTRICT,
  KEY idx_retro_entrega (id_entrega)
) ENGINE=InnoDB;

CREATE TABLE retroalimentacion_archivos (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_retroalimentacion BIGINT UNSIGNED NOT NULL,
  nombre_original VARCHAR(255) NOT NULL,
  nombre_guardado VARCHAR(255) NOT NULL,
  ruta_relativa VARCHAR(500) NOT NULL,
  mime_type VARCHAR(120) NOT NULL,
  tamanio_bytes BIGINT UNSIGNED NOT NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_retro_archivos_retro
    FOREIGN KEY (id_retroalimentacion) REFERENCES retroalimentaciones(id)
    ON DELETE CASCADE,
  KEY idx_retro_archivos_retro (id_retroalimentacion)
) ENGINE=InnoDB;

-- =========================
-- Configuración y auditoría
-- =========================
CREATE TABLE configuraciones (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  clave VARCHAR(120) NOT NULL,
  valor TEXT NULL,
  descripcion VARCHAR(255) NULL,
  updated_by BIGINT UNSIGNED NULL,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_config_clave (clave),
  CONSTRAINT fk_config_user
    FOREIGN KEY (updated_by) REFERENCES usuarios(id)
    ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE auditoria_eventos (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_usuario BIGINT UNSIGNED NULL,
  modulo VARCHAR(80) NOT NULL,
  accion VARCHAR(80) NOT NULL,
  tabla VARCHAR(80) NOT NULL,
  registro_id BIGINT UNSIGNED NULL,
  detalle JSON NULL,
  ip VARCHAR(45) NULL,
  user_agent VARCHAR(255) NULL,
  fecha_evento DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_auditoria_usuario
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id)
    ON DELETE SET NULL,
  KEY idx_auditoria_tabla (tabla, registro_id, fecha_evento),
  KEY idx_auditoria_usuario (id_usuario, fecha_evento)
) ENGINE=InnoDB;

-- =========================
-- Datos base mínimos
-- =========================
INSERT INTO roles (nombre, descripcion) VALUES
('administrador', 'Gestión integral del sistema'),
('docente', 'Gestión académica y evaluación'),
('estudiante', 'Consulta y entrega de actividades')
ON DUPLICATE KEY UPDATE descripcion = VALUES(descripcion);

INSERT INTO configuraciones (clave, valor, descripcion) VALUES
('max_upload_mb', '20', 'Tamaño máximo por archivo en MB'),
('allowed_extensions', 'pdf,doc,docx,xls,xlsx,ppt,pptx,jpg,jpeg,png,zip', 'Extensiones permitidas para carga'),
('session_idle_minutes', '10', 'Minutos de inactividad para cerrar sesión')
ON DUPLICATE KEY UPDATE valor = VALUES(valor), descripcion = VALUES(descripcion);
