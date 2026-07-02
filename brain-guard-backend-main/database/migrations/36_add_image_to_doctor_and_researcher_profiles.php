<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('doctor_profiles', function (Blueprint $table) {
            $table->string('image', 500)->nullable()->after('email');
        });

        Schema::table('researcher_profiles', function (Blueprint $table) {
            $table->string('image', 500)->nullable()->after('email');
        });
    }

    public function down(): void
    {
        Schema::table('doctor_profiles', function (Blueprint $table) {
            $table->dropColumn('image');
        });

        Schema::table('researcher_profiles', function (Blueprint $table) {
            $table->dropColumn('image');
        });
    }
};
