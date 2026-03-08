<?php

declare(strict_types=1);

namespace App\Modules\Auth\Controllers;

use App\Core\AuthService;
use App\Core\Controller;
use App\Core\Csrf;
use App\Core\Response;
use App\Core\Session;
use App\Modules\Auth\Models\LegacyStudentModel;
use App\Modules\Auth\Models\UserModel;

final class AuthController extends Controller
{
    public function showLogin(): void
    {
        $captchaA = random_int(1, 9);
        $captchaB = random_int(1, 9);
        Session::set('captcha_result', $captchaA + $captchaB);

        $this->view('Modules/Auth/Views/login', [
            'csrfToken' => Csrf::token(),
            'captchaQuestion' => "{$captchaA} + {$captchaB}",
        ]);
    }

    public function studentLogin(): void
    {
        if (!Csrf::validate($_POST['csrf_token'] ?? null)) {
            Response::json(['ok' => false, 'message' => 'Token CSRF inválido.'], 422);
        }

        $document = trim((string) ($_POST['documento'] ?? ''));
        $captcha = (int) ($_POST['captcha'] ?? 0);
        $expectedCaptcha = (int) Session::get('captcha_result', -1);

        if ($document === '' || !ctype_digit($document)) {
            Response::json(['ok' => false, 'message' => 'Documento inválido.'], 422);
        }

        if ($captcha !== $expectedCaptcha) {
            Response::json(['ok' => false, 'message' => 'Captcha incorrecto.'], 422);
        }

        $legacyModel = new LegacyStudentModel();
        $student = $legacyModel->findActiveByDocument($document);

        if (!$student) {
            Response::json(['ok' => false, 'message' => 'No autorizado o sin matrícula activa.'], 401);
        }

        AuthService::login([
            'role' => 'estudiante',
            'id_estudiante_legacy' => $student['id_estudiante'],
            'nombre' => trim($student['primernombre'] . ' ' . $student['segundonombre'] . ' ' . $student['primerapellido'] . ' ' . $student['segundoapellido']),
            'documento' => $student['nrodocumento'],
            'grado_grupo' => $student['nom_grado'] . '-' . $student['nom_grupo'],
        ]);

        Response::json(['ok' => true, 'message' => 'Bienvenido estudiante.', 'redirect' => '/dashboard']);
    }

    public function staffLogin(): void
    {
        if (!Csrf::validate($_POST['csrf_token'] ?? null)) {
            Response::json(['ok' => false, 'message' => 'Token CSRF inválido.'], 422);
        }

        $email = filter_var(trim((string) ($_POST['email'] ?? '')), FILTER_VALIDATE_EMAIL);
        $password = (string) ($_POST['password'] ?? '');

        if (!$email || $password === '') {
            Response::json(['ok' => false, 'message' => 'Credenciales inválidas.'], 422);
        }

        $userModel = new UserModel();
        $user = $userModel->findByEmail($email);

        if (!$user || !(bool) $user['activo'] || !password_verify($password, (string) $user['password_hash'])) {
            Response::json(['ok' => false, 'message' => 'Usuario o contraseña incorrectos.'], 401);
        }

        AuthService::login([
            'role' => 'staff',
            'id' => $user['id'],
            'nombre' => trim($user['nombres'] . ' ' . $user['apellidos']),
            'email' => $user['email'],
        ]);

        Response::json(['ok' => true, 'message' => 'Bienvenido.', 'redirect' => '/dashboard']);
    }

    public function logout(): void
    {
        AuthService::logout();
        Response::redirect('/login');
    }
}
