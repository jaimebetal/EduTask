<?php

declare(strict_types=1);

namespace App\Modules\Auth\Models;

use App\Core\Database;
use PDO;

final class LegacyStudentModel
{
    private PDO $legacy;

    public function __construct()
    {
        $this->legacy = Database::connection('legacy');
    }

    public function findActiveByDocument(string $document): ?array
    {
        $sql = "SELECT
                    e.id_estudiante,
                    e.nrodocumento,
                    e.primernombre,
                    e.segundonombre,
                    e.primerapellido,
                    e.segundoapellido,
                    g.nom_grado,
                    gr.nom_grupo
                FROM estudiante e
                INNER JOIN matricula26 m ON m.id_estudiante = e.id_estudiante
                INNER JOIN grado g ON g.id_grado = m.id_grado
                INNER JOIN grupo gr ON gr.id_grupo = m.id_grupo
                WHERE e.nrodocumento = :documento
                  AND m.id_estactual IN (1,17)
                LIMIT 1";

        $stmt = $this->legacy->prepare($sql);
        $stmt->bindValue(':documento', $document);
        $stmt->execute();

        $row = $stmt->fetch();

        return $row ?: null;
    }
}
