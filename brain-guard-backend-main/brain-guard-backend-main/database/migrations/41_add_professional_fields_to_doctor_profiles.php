<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('doctor_profiles', function (Blueprint $table) {
            $table->float('rating')->nullable()->default(0.0)->after('years_of_experience');
            $table->integer('total_reviews')->default(0)->after('rating');
            $table->string('working_hours', 255)->nullable()->after('total_reviews');
            $table->boolean('is_available')->default(true)->after('working_hours');
        });
    }

    public function down(): void
    {
        Schema::table('doctor_profiles', function (Blueprint $table) {
            $table->dropColumn(['rating', 'total_reviews', 'working_hours', 'is_available']);
        });
    }
};
