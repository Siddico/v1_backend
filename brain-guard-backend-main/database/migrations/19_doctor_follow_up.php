<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('doctor_follow_up', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->unsignedBigInteger('doctor_id');
            $table->unsignedBigInteger('patient_id');
            $table->text('suggestion_text');
            $table->text('description')->nullable();
            $table->enum('status', ['pending', 'seen', 'done'])->default('pending');
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
        Schema::dropIfExists('doctor_follow_up');
    }
};

