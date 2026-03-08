<?php

declare(strict_types=1);

namespace App\Modules\Dashboard\Controllers;

use App\Core\AuthService;
use App\Core\Controller;
use App\Core\Response;

final class DashboardController extends Controller
{
    public function index(): void
    {
        if (!AuthService::check()) {
            Response::redirect('/login');
        }

        $this->view('Modules/Dashboard/Views/index', [
            'user' => AuthService::user(),
        ]);
    }
}
