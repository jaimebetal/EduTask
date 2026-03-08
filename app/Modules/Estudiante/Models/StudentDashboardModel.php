<?php

declare(strict_types=1);

namespace App\Modules\Estudiante\Models;

use App\Core\Database;
use PDO;

final class StudentDashboardModel
{
    private PDO $db;

    public function __construct()
    {
        $this->db = Database::connection('main');
    }

    public function getActiveYear(): ?array
    {
        $stmt = $this->db->prepare('SELECT id, anio FROM anios_lectivos WHERE activo = 1 LIMIT 1');
        $stmt->execute();
        $row = $stmt->fetch();

        return $row ?: null;
    }

    public function getPeriodsByYear(int $idAnio): array
    {
        $stmt = $this->db->prepare('SELECT id, numero, nombre, fecha_inicio, fecha_fin, bloqueado FROM periodos WHERE id_anio = :id_anio ORDER BY numero ASC');
        $stmt->bindValue(':id_anio', $idAnio, PDO::PARAM_INT);
        $stmt->execute();

        return $stmt->fetchAll();
    }

    public function getActivitiesByGroupAndPeriod(int $idGrupo, int $idPeriodo, int $idEstudianteLegacy): array
    {
        $sql = "SELECT
                    a.id,
                    a.titulo,
                    a.fecha_limite,
                    a.estado,
                    a.ponderacion,
                    a.tipo_entrega,
                    g.titulo AS guia_titulo,
                    e.id AS entrega_id,
                    e.estado_entrega,
                    e.estado_tiempo,
                    c.nota_final,
                    c.publicada AS nota_publicada,
                    r.comentario,
                    r.publicada AS retro_publicada
                FROM actividades a
                LEFT JOIN guias g ON g.id = a.id_guia
                LEFT JOIN entregas e ON e.id_actividad = a.id AND e.id_estudiante_legacy = :id_estudiante_legacy
                LEFT JOIN calificaciones c ON c.id_entrega = e.id
                LEFT JOIN retroalimentaciones r ON r.id_entrega = e.id
                WHERE a.id_grupo = :id_grupo
                  AND a.id_periodo = :id_periodo
                  AND a.estado IN ('publicada','cerrada','calificada')
                ORDER BY a.fecha_limite ASC";

        $stmt = $this->db->prepare($sql);
        $stmt->bindValue(':id_grupo', $idGrupo, PDO::PARAM_INT);
        $stmt->bindValue(':id_periodo', $idPeriodo, PDO::PARAM_INT);
        $stmt->bindValue(':id_estudiante_legacy', $idEstudianteLegacy, PDO::PARAM_INT);
        $stmt->execute();

        return $stmt->fetchAll();
    }

    public function resolveGroupIdByLabel(string $label): ?int
    {
        $parts = explode('-', $label);
        if (count($parts) !== 2) {
            return null;
        }

        $grado = trim($parts[0]);
        $grupo = trim($parts[1]);

        $stmt = $this->db->prepare('SELECT id FROM grupos_academicos WHERE nombre_grado = :grado AND nombre_grupo = :grupo AND activo = 1 LIMIT 1');
        $stmt->bindValue(':grado', $grado);
        $stmt->bindValue(':grupo', $grupo);
        $stmt->execute();
        $row = $stmt->fetch();

        return $row ? (int) $row['id'] : null;
    }
}
