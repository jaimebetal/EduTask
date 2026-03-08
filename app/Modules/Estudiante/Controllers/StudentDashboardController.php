<?php

declare(strict_types=1);

namespace App\Modules\Estudiante\Controllers;

use App\Core\AuthService;
use App\Core\Controller;
use App\Core\Response;
use App\Modules\Estudiante\Models\StudentDashboardModel;

final class StudentDashboardController extends Controller
{
    public function index(): void
    {
        if (!AuthService::check()) {
            Response::redirect('/login');
        }

        $user = AuthService::user();
        if (($user['role'] ?? '') !== 'estudiante') {
            Response::redirect('/dashboard');
        }

        $model = new StudentDashboardModel();
        $activeYear = $model->getActiveYear();
        $periods = $activeYear ? $model->getPeriodsByYear((int) $activeYear['id']) : [];

        $this->view('Modules/Estudiante/Views/index', [
            'user' => $user,
            'activeYear' => $activeYear,
            'periods' => $periods,
        ]);
    }

    public function activitiesByPeriod(): void
    {
        if (!AuthService::check()) {
            Response::json(['ok' => false, 'message' => 'Sesión no válida.'], 401);
        }

        $user = AuthService::user();
        if (($user['role'] ?? '') !== 'estudiante') {
            Response::json(['ok' => false, 'message' => 'No autorizado.'], 403);
        }

        $periodId = (int) ($_GET['periodo_id'] ?? 0);
        if ($periodId <= 0) {
            Response::json(['ok' => false, 'message' => 'Periodo inválido.'], 422);
        }

        $model = new StudentDashboardModel();
        $groupId = $model->resolveGroupIdByLabel((string) ($user['grado_grupo'] ?? ''));
        if (!$groupId) {
            Response::json(['ok' => true, 'message' => 'Grupo no configurado en el sistema nuevo.', 'data' => []]);
        }

        $activities = $model->getActivitiesByGroupAndPeriod($groupId, $periodId, (int) ($user['id_estudiante_legacy'] ?? 0));

        Response::json(['ok' => true, 'data' => $activities]);
    }
}
