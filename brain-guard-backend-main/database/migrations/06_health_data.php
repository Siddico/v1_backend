<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('health_data', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->unsignedBigInteger('patient_id');
            $table->float('heart_rate')->nullable();
            $table->string('blood_pressure', 20)->nullable();
            $table->float('blood_glucose')->nullable();
            $table->float('cholesterol')->nullable();
            $table->float('spo2_level')->nullable();
            $table->float('stability_index')->nullable();
            $table->timestamp('recorded_at');
            $table->timestamps();

            $table->foreign('patient_id')
                ->references('id')
                ->on('patient_profiles')
                ->onDelete('cascade');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('health_data');
    }
};

