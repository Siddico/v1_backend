<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('reports', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->unsignedBigInteger('patient_id');
            $table->unsignedBigInteger('prediction_id')->nullable();
            $table->enum('report_format', ['pdf', 'summary', 'ecg', 'ppg']);
            $table->string('file_url', 255)->nullable();
            $table->boolean('is_encrypted')->default(false);
            $table->string('shared_to', 255)->nullable();
            $table->timestamp('generated_at');
            $table->timestamps();

            $table->foreign('patient_id')
                ->references('id')
                ->on('patient_profiles')
                ->onDelete('cascade');

            $table->foreign('prediction_id')
                ->references('id')
                ->on('stroke_risk_predictions')
                ->onDelete('set null');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('reports');
    }
};

