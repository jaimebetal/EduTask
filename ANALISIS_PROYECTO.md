# Fase 1 — Requisitos confirmados del proyecto (sin código)

Este documento consolida las respuestas entregadas por el cliente para cerrar el levantamiento inicial.

## 1) Flujo académico
- Se maneja **un único año académico activo** por vez.
- Al iniciar un nuevo año, deben poder reutilizarse actividades del año anterior (activarlas o no).
- Jerarquía aprobada: **Año → Periodo → Guía → Actividad**.
- La plataforma inicia para el área de Tecnología e Informática, con **múltiples docentes** y grupos asignados por docente.
- Las actividades pueden existir:
  - asociadas a una guía, o
  - independientes (sin guía).
- Una guía puede no requerir entregas.
- Estados de actividad aceptados: **borrador, publicada, cerrada, calificada, archivada**.

## 2) Periodos académicos
- El año lectivo tendrá **4 periodos académicos**.
- Cada periodo tendrá fechas obligatorias de inicio/fin.
- Se permite solapamiento entre periodos (recuperaciones).
- Debe existir opción para **congelar / descongelar calificaciones** por periodo.

## 3) Guías y actividades
### Guías
Campos mínimos:
- título
- descripción
- archivos adjuntos
- fecha de publicación
- periodo
- grupo (grado-grupo)

> Nota clave: cada guía debe asociarse a periodo y grupo, porque puede variar entre grupos del mismo grado.

### Actividades
Campos mínimos:
- título
- instrucciones
- fecha límite
- ponderación
- rúbrica
- tipo de entrega: parcial o final
- periodo
- grupo (grado-grupo)

Reglas:
- Asignación por **grado-grupo** (no individual).
- Se requiere soportar **calificación manual y automática**.

## 4) Entregas y archivos
- Tamaño máximo de archivo: **configurable**.
- Tipos de archivo permitidos: **configurables**.
- Se permiten múltiples archivos por entrega.
- Se permiten múltiples intentos/reentregas con historial.
- Para nota final cuenta la entrega marcada como **final**.
- Se guarda historial completo: fecha, usuario, IP y versión.
- Antivirus/escaneo: deseable si es viable; si no, se implementa sin escaneo en primera etapa.

## 5) Tardanzas y estados
- Se aceptan entregas fuera de fecha con aprobación del docente.
- Las entregas tardías deben:
  - marcarse como extemporáneas,
  - aplicar penalización definida por docente.
- Excepciones de fecha: docente y administrador.
- Estados solicitados para entregas:

```sql
estado_entrega ENUM('pendiente','parcial','final') DEFAULT 'pendiente',
estado_tiempo ENUM('a_tiempo','extemporanea') NULL,
estado_revision ENUM('pendiente','revisada') DEFAULT 'pendiente'
```

## 6) Calificación y retroalimentación
- Escala de notas: **0.0 a 10.0**.
- Precisión: **1 decimal**.
- Actividades con ponderación dentro del periodo.
- Uso de rúbrica con criterios.
- El estudiante visualiza retroalimentación cuando el docente publique.
- Se permite adjuntar archivos en la retroalimentación docente.

## 7) Usuarios, roles y autenticación
- Estudiante: login con **documento + captcha**.
- Estudiantes no tendrán cuenta local clásica; autenticación consultando BD `matricula`.
- Relación entre BD nueva y legado usando identificador de matrícula/estudiante.
- Docentes y administradores: autogestión de contraseñas.
- Recuperación de contraseña por correo: requerida.
- Un usuario puede tener múltiples roles.
- Docente puede tener múltiples áreas y grupos.

## 8) Integración con `matricula`
- Validación de estudiante en **tiempo real** en cada login.
- Estados válidos para acceso: `1` y `17`.
- Cambios esperados de estado: a retirado (`4`) o desertor (`3`).
- No se requiere snapshot de grado/grupo al login.
- Concurrencia esperada en pico: ~40 estudiantes.

## 9) Seguridad, auditoría y cumplimiento
- Contraseñas con `password_hash()` (algoritmo recomendado por implementación).
- Sesión activa hasta logout, con cierre por inactividad de 10 minutos.
- No se exige rate limiting por intentos fallidos (decisión funcional actual).
- Auditoría obligatoria (creación, actualización, calificación, descarga).
- Acceso interno y externo (servidor en línea).
- Política de privacidad/consentimiento para menores: obligatoria.

## 10) Arquitectura y operación
- Preferencia por arquitectura **modular** (base MVC simple).
- Sin ambientes separados (desarrollo/pruebas/producción) en etapa inicial.
- Backups manuales.
- Despliegue en servidor único.

---

## Riesgos y decisiones técnicas que se deben aceptar explícitamente
1. **Documento + captcha** como autenticación de estudiante es más débil que documento + secreto; se recomienda segunda capa mínima (PIN o contraseña inicial).
2. **Sin rate limiting** incrementa riesgo de fuerza bruta contra login.
3. **Login en tiempo real contra legado** introduce dependencia operativa de `matricula` para disponibilidad.
4. **Sin snapshots** limita trazabilidad histórica de cambios de grado/grupo.
5. Para carga de archivos, se debe aplicar de forma estricta:
   - validación MIME + extensión,
   - límite de tamaño,
   - almacenamiento fuera de `public/`,
   - nombres aleatorios,
   - bloqueo de ejecución.

## Estado de la fase
- **Fase 1 cerrada** con requisitos levantados.
- Siguiente paso (cuando el cliente confirme): **Paso 2, diseño de arquitectura del sistema**.
