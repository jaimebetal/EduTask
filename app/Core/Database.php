<?php

declare(strict_types=1);

namespace App\Core;

use PDO;

final class Database
{
    private static array $connections = [];

    public static function connection(string $name = 'main'): PDO
    {
        if (isset(self::$connections[$name])) {
            return self::$connections[$name];
        }

        $config = require __DIR__ . '/../Config/database.php';
        $db = $config[$name];

        $pdo = new PDO($db['dsn'], $db['username'], $db['password'], [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false,
        ]);

        self::$connections[$name] = $pdo;

        return $pdo;
    }
}
