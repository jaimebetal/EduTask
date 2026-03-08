<?php

declare(strict_types=1);

use App\Core\AuthService;
use App\Core\Router;
use App\Core\Session;
use App\Modules\Auth\Controllers\AuthController;
use App\Modules\Dashboard\Controllers\DashboardController;
use App\Modules\Estudiante\Controllers\StudentDashboardController;

require __DIR__ . '/../bootstrap/init.php';

Session::start();
$appConfig = require __DIR__ . '/../app/Config/app.php';
AuthService::enforceIdleTimeout((int) $appConfig['session_idle_minutes']);

$router = new Router();

$router->get('/', [AuthController::class, 'showLogin']);
$router->get('/login', [AuthController::class, 'showLogin']);
$router->post('/auth/student-login', [AuthController::class, 'studentLogin']);
$router->post('/auth/staff-login', [AuthController::class, 'staffLogin']);
$router->post('/auth/logout', [AuthController::class, 'logout']);
$router->get('/dashboard', [DashboardController::class, 'index']);
$router->get('/estudiante', [StudentDashboardController::class, 'index']);
$router->get('/estudiante/actividades', [StudentDashboardController::class, 'activitiesByPeriod']);

$path = parse_url($_SERVER['REQUEST_URI'] ?? '/', PHP_URL_PATH) ?: '/';
$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';

$router->dispatch($method, $path);
