<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class RoleSeeder extends Seeder
{
    public function run(): void
    {
        DB::table('roles')->upsert(
            [
                ['name_of_role' => 'patient'],
                ['name_of_role' => 'doctor'],
                ['name_of_role' => 'researcher'],
            ],
            ['name_of_role'],
            []
        );
    }
}

