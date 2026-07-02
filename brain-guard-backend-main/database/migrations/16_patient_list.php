<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('patient_list', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->unsignedBigInteger('doctor_id');
            $table->unsignedBigInteger('patient_id');
            $table->text('diagnoses')->nullable();
            $table->enum('status', ['active', 'inactive', 'critical'])->default('active');
            $table->timestamp('last_review')->nullable();
            $table->timestamps();

            $table->foreign('doctor_id')
                ->references('id')
                ->on('doctor_profiles')
                ->onDelete('cascade');

            $table->foreign('patient_id')
                ->references('id')
                ->on('patient_profiles')
                ->onDelete('cascade');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('patient_list');
    }
};

