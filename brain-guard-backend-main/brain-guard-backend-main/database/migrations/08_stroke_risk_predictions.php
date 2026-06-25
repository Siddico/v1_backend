<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('stroke_risk_predictions', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->unsignedBigInteger('patient_id');
            $table->unsignedBigInteger('health_data_id')->nullable();
            $table->float('score');
            $table->enum('risk_level', ['low', 'moderate', 'high']);
            $table->text('overview')->nullable();
            $table->boolean('predict_based_on_files')->default(false);
            $table->string('model_version', 50)->nullable();
            $table->timestamp('predicted_at');
            $table->timestamps();

            $table->foreign('patient_id')
                ->references('id')
                ->on('patient_profiles')
                ->onDelete('cascade');

            $table->foreign('health_data_id')
                ->references('id')
                ->on('health_data')
                ->onDelete('set null');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('stroke_risk_predictions');
    }
};

