<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('medical_data', function (Blueprint $table) {
            $table->text('treatment_plan')->nullable()->after('diagnosis');
        });
    }

    public function down(): void
    {
        Schema::table('medical_data', function (Blueprint $table) {
            $table->dropColumn('treatment_plan');
        });
    }
};
