<?php

declare(strict_types=1);

namespace App\Core;

final class AuthService
{
    public static function check(): bool
    {
        return (bool) Session::get('auth');
    }

    public static function user(): array
    {
        return Session::get('auth_user', []);
    }

    public static function login(array $user): void
    {
        Session::regenerate();
        Session::set('auth', true);
        Session::set('auth_user', $user);
        Session::set('last_activity', time());
    }

    public static function logout(): void
    {
        Session::destroy();
    }

    public static function enforceIdleTimeout(int $minutes): void
    {
        $lastActivity = (int) Session::get('last_activity', time());
        if ((time() - $lastActivity) > ($minutes * 60)) {
            self::logout();
            return;
        }

        Session::set('last_activity', time());
    }
}
