<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('stroke_risk_predictions', function (Blueprint $table) {
            $table->string('prediction_type', 50)->nullable()->after('model_version');
            $table->json('model_output')->nullable()->after('prediction_type');
            $table->json('probabilities')->nullable()->after('model_output');
            $table->json('recommendations')->nullable()->after('probabilities');
            $table->string('status', 20)->default('completed')->after('recommendations');
        });
    }

    public function down(): void
    {
        Schema::table('stroke_risk_predictions', function (Blueprint $table) {
            $table->dropColumn([
                'prediction_type',
                'model_output',
                'probabilities',
                'recommendations',
                'status',
            ]);
        });
    }
};
