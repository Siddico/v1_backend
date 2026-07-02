<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('patient_profiles', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->unsignedBigInteger('user_id')->unique();
            $table->string('full_name', 255);
            $table->integer('age');
            $table->float('weight')->nullable();
            $table->text('medical_history')->nullable();
            $table->string('emergency_number', 20)->nullable();
            $table->string('phone', 20)->nullable();
            $table->enum('gender', ['male', 'female'])->nullable();
            $table->string('image', 255)->nullable();
            $table->timestamps();

            $table->foreign('user_id')
                ->references('id')
                ->on('users')
                ->onDelete('cascade');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('patient_profiles');
    }
};

