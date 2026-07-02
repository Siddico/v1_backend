<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('doctor_follow_up', function (Blueprint $table) {
            $table->date('next_visit')->nullable()->after('description');
            $table->string('follow_up_type', 50)->nullable()->after('next_visit');
        });
    }

    public function down(): void
    {
        Schema::table('doctor_follow_up', function (Blueprint $table) {
            $table->dropColumn(['next_visit', 'follow_up_type']);
        });
    }
};
