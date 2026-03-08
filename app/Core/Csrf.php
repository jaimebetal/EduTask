<?php

declare(strict_types=1);

namespace App\Core;

final class Csrf
{
    public static function token(): string
    {
        $token = Session::get('csrf_token');
        if (!$token) {
            $token = bin2hex(random_bytes(32));
            Session::set('csrf_token', $token);
        }

        return $token;
    }

    public static function validate(?string $token): bool
    {
        $sessionToken = Session::get('csrf_token');
        return is_string($token) && is_string($sessionToken) && hash_equals($sessionToken, $token);
    }
}
