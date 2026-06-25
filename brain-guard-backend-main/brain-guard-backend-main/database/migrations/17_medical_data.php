<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('medical_data', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->unsignedBigInteger('patient_id');
            $table->unsignedBigInteger('doctor_id');
            $table->text('diagnosis')->nullable();
            $table->float('heart_rate')->nullable();
            $table->string('blood_pressure', 20)->nullable();
            $table->float('blood_glucose')->nullable();
            $table->float('cholesterol')->nullable();
            $table->timestamp('last_ecg_ppg_upload')->nullable();
            $table->text('doctor_notes')->nullable();
            $table->float('hrv')->nullable();
            $table->timestamp('updated_at')->nullable();
            $table->timestamp('created_at')->nullable();

            $table->foreign('patient_id')
                ->references('id')
                ->on('patient_profiles')
                ->onDelete('cascade');

            $table->foreign('doctor_id')
                ->references('id')
                ->on('doctor_profiles')
                ->onDelete('cascade');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('medical_data');
    }
};

