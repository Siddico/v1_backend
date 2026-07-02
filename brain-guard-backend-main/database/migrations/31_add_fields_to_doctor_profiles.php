<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('doctor_profiles', function (Blueprint $table) {
            $table->string('hospital', 255)->nullable()->after('specialty');
            $table->integer('years_of_experience')->nullable()->after('hospital');
        });
    }

    public function down(): void
    {
        Schema::table('doctor_profiles', function (Blueprint $table) {
            $table->dropColumn(['hospital', 'years_of_experience']);
        });
    }
};
