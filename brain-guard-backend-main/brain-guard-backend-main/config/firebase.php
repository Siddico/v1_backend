<?php

return [
    'project_id'   => env('FIREBASE_PROJECT_ID', ''),
    'client_email' => env('FIREBASE_CLIENT_EMAIL', ''),
    'private_key'  => str_replace('\\n', "\n", env('FIREBASE_PRIVATE_KEY', '')),
    'fcm_url'      => 'https://fcm.googleapis.com/v1/projects/%s/messages:send',
    'token_url'    => 'https://oauth2.googleapis.com/token',
];
