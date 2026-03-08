<?php

declare(strict_types=1);

namespace App\Core;

abstract class Controller
{
    protected function view(string $view, array $data = []): void
    {
        extract($data, EXTR_SKIP);
        require __DIR__ . '/../Views/layouts/header.php';
        require __DIR__ . '/../' . $view . '.php';
        require __DIR__ . '/../Views/layouts/footer.php';
    }
}
