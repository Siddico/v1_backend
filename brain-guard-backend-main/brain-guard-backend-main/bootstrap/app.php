<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;
use Illuminate\Auth\AuthenticationException;
use App\Http\Middleware\RoleMiddleware;
use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Support\Facades\RateLimiter;

$app = Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__ . '/../routes/web.php',
        api: __DIR__ . '/../routes/api.php',
        commands: __DIR__ . '/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware): void {

        $middleware->alias([
            'role' => RoleMiddleware::class,
        ]);

    })
    ->withExceptions(function (Exceptions $exceptions): void {

        // Validation errors → JSON دايماً
        $exceptions->render(function (ValidationException $e, Request $request) {
            if ($request->expectsJson() || $request->is('api/*')) {
                return response()->json([
                    'success' => false,
                    'message' => 'Validation failed.',
                    'errors'  => $e->errors(),
                    'data'    => null,
                ], 422);
            }
        });

        // Unauthenticated → JSON
        $exceptions->render(function (AuthenticationException $e, Request $request) {
            if ($request->expectsJson() || $request->is('api/*')) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthenticated. Please login.',
                    'data'    => null,
                ], 401);
            }
        });

        // Force JSON for all exceptions to avoid view component crashes
        $exceptions->shouldRenderJsonWhen(function (Request $request, \Throwable $e) {
            return true;
        });

        // 404 +' JSON
        $exceptions->render(function (\Symfony\Component\HttpKernel\Exception\NotFoundHttpException $e, Request $request) {
            return response()->json([
                'success' => false,
                'message' => 'Endpoint not found.',
                'data'    => null,
            ], 404);
        });

        // 429 Too Many Requests → JSON
        $exceptions->render(function (\Illuminate\Http\Exceptions\ThrottleRequestsException $e, Request $request) {
            return response()->json([
                'success' => false,
                'message' => 'Too many requests. Please try again later.',
                'data'    => null,
            ], 429);
        });

    })->create();

// Vercel Serverless configuration: Use /tmp for storage as it's the only writable directory
if (isset($_SERVER['VERCEL']) || env('VERCEL')) {
    $app->useStoragePath('/tmp/storage');
    $storageDirs = [
        '/tmp/storage/app',
        '/tmp/storage/framework/cache/data',
        '/tmp/storage/framework/sessions',
        '/tmp/storage/framework/views',
        '/tmp/storage/logs',
    ];
    foreach ($storageDirs as $dir) {
        if (!is_dir($dir)) {
            mkdir($dir, 0777, true);
        }
    }
}

return $app;
