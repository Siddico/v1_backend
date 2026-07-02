<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('ecg_ppg_signals', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->unsignedBigInteger('patient_id');
            $table->enum('signal_type', ['ECG', 'PPG', 'IMU', 'SpO2', 'BP']);
            $table->json('raw_data')->nullable();
            $table->string('file_url', 255)->nullable();
            $table->enum('source', ['upload', 'wearable'])->default('upload');
            $table->timestamp('uploaded_at');
            $table->timestamps();

            $table->foreign('patient_id')
                ->references('id')
                ->on('patient_profiles')
                ->onDelete('cascade');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('ecg_ppg_signals');
    }
};

