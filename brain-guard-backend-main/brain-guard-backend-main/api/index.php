<?php

// Forward all Vercel requests to the main Laravel entry point
try {
    require __DIR__ . '/../public/index.php';
} catch (\Throwable $e) {
    echo '<h1>Laravel Boot Error</h1>';
    echo '<pre>' . $e->getMessage() . '</pre>';
    echo '<pre>' . $e->getTraceAsString() . '</pre>';
}
