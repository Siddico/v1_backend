<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class RoleMiddleware
{
    public function handle(Request $request, Closure $next, string $role): Response
    {
        $user = $request->user();

        if (! $user || optional($user->role)->name_of_role !== $role) {
            return new JsonResponse([
                'success' => false,
                'message' => 'Forbidden: insufficient permissions.',
                'data' => null,
            ], Response::HTTP_FORBIDDEN);
        }

        return $next($request);
    }
}

