# Guía de puesta en marcha (estado actual del sistema)

Esta guía te permite levantar y probar el sistema **hasta el módulo implementado** (autenticación + dashboard básico).

## 1) Requisitos previos

- PHP 8.x con extensiones: `pdo`, `pdo_mysql`, `mbstring`, `openssl`.
- MySQL 8.x.
- Apache 2.4 (opcional para pruebas rápidas; puedes iniciar con servidor embebido de PHP).
- Base de datos legado `matricula` accesible con:
  - host: `127.0.0.1`
  - puerto: `3306`
  - usuario: `root`
  - contraseña: vacía (`""`)

## 2) Estructura importante del proyecto

- Front controller: `public/index.php`
- Configuración DB: `app/Config/database.php`
- Esquema MySQL nuevo: `database/sql/001_schema.sql`
- Login estudiante/docente: `app/Modules/Auth/Controllers/AuthController.php`

## 3) Crear base de datos nueva

Ejecuta el script de esquema:

```bash
mysql -u root -p < database/sql/001_schema.sql
```

Si tu root no tiene password:

```bash
mysql -u root < database/sql/001_schema.sql
```

Esto crea la BD `colegio_academico` y tablas iniciales.

## 4) Configurar conexión a BD

Revisa y ajusta `app/Config/database.php` según tu entorno.

Por defecto está:
- `main` => `colegio_academico`
- `legacy` => `matricula`

## 5) Crear un usuario de prueba (docente/admin)

El login staff usa `email + password_hash`. Inserta un usuario manualmente.

### Opción A: generar hash rápido

```bash
php -r "echo password_hash('Admin123*', PASSWORD_BCRYPT), PHP_EOL;"
```

Copia el hash y ejecuta (ajustando el hash):

```sql
USE colegio_academico;

INSERT INTO usuarios (documento, nombres, apellidos, email, password_hash, tipo_usuario, activo)
VALUES ('12345678', 'Admin', 'Prueba', 'admin@colegio.local', '$2y$10$REEMPLAZAR_HASH', 'admin', 1);
```

## 6) Arrancar el sistema (modo rápido)

Desde la raíz del proyecto:

```bash
php -S 0.0.0.0:8080 -t public
```

Luego abre:

- `http://TU_IP_O_LOCALHOST:8080/login`

## 7) Arrancar con Apache 2.4 (servidor institucional)

1. Apunta el VirtualHost al directorio `public/` del proyecto.
2. Habilita `mod_rewrite`.
3. Asegura `AllowOverride All` para que lea `public/.htaccess`.
4. Reinicia Apache.
5. Entra a `/login`.

Ejemplo base de VirtualHost:

```apache
<VirtualHost *:80>
    ServerName colegio.local
    DocumentRoot /ruta/al/proyecto/public

    <Directory /ruta/al/proyecto/public>
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
```

## 8) ¿Qué puedes probar hoy?

### Login estudiante
- Formulario: documento + captcha.
- Valida contra BD `matricula` (tabla `estudiante` + `matricula26`) y estados `1,17`.
- Si pasa validación, redirige a `/dashboard`.

### Login docente/admin
- Formulario: email + contraseña.
- Verifica `password_verify` contra `usuarios.password_hash`.
- Si es válido y activo, redirige a `/dashboard`.

### Dashboard
- Muestra nombre, rol y (en estudiante) grado-grupo.
- Permite cerrar sesión.

## 9) Errores comunes y solución

1. **404 en rutas (`/login`, `/dashboard`)**
   - Verifica que sirves desde `public/`.
   - En Apache, confirma `mod_rewrite` y `AllowOverride All`.

2. **Error de conexión MySQL**
   - Revisa host/puerto/usuario/password en `app/Config/database.php`.
   - Confirma que existen `colegio_academico` y `matricula`.

3. **Login estudiante siempre falla**
   - Verifica que el documento exista en `matricula.estudiante`.
   - Verifica que `matricula26.id_estactual` sea `1` o `17`.

4. **Login staff falla**
   - Confirma que el `password_hash` se generó correctamente.
   - Confirma `usuarios.activo = 1`.

5. **Sesión expira rápido**
   - Ajusta `session_idle_minutes` en `app/Config/app.php`.

## 10) Estado funcional actual (alcance real)

Implementado:
- Estructura MVC base.
- Autenticación estudiante/staff.
- CSRF en login.
- AJAX con jQuery en formularios de acceso.
- Dashboard básico.

Pendiente (siguientes módulos):
- panel completo estudiante,
- panel docente,
- carga de tareas,
- retroalimentación,
- calificaciones,
- administración académica.
