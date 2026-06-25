<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('stroke_risk_predictions', function (Blueprint $table) {
            $table->json('symptoms')->nullable()->after('recommendations');
        });
    }

    public function down(): void
    {
        Schema::table('stroke_risk_predictions', function (Blueprint $table) {
            $table->dropColumn('symptoms');
        });
    }
};
