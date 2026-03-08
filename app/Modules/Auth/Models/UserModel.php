<?php

declare(strict_types=1);

namespace App\Modules\Auth\Models;

use App\Core\Database;
use PDO;

final class UserModel
{
    private PDO $db;

    public function __construct()
    {
        $this->db = Database::connection('main');
    }

    public function findByEmail(string $email): ?array
    {
        $sql = 'SELECT id, documento, nombres, apellidos, email, password_hash, activo FROM usuarios WHERE email = :email LIMIT 1';
        $stmt = $this->db->prepare($sql);
        $stmt->bindValue(':email', $email);
        $stmt->execute();

        $row = $stmt->fetch();

        return $row ?: null;
    }
}
