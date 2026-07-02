<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('emergency_recommendations', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->unsignedBigInteger('patient_id');
            $table->unsignedBigInteger('prediction_id');
            $table->text('advice_text');
            $table->timestamps();

            $table->foreign('patient_id')
                ->references('id')
                ->on('patient_profiles')
                ->onDelete('cascade');

            $table->foreign('prediction_id')
                ->references('id')
                ->on('stroke_risk_predictions')
                ->onDelete('cascade');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('emergency_recommendations');
    }
};

