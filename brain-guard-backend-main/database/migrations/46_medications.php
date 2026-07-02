<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('medications', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->unsignedBigInteger('patient_id');
            $table->string('name', 255);
            $table->string('dosage', 100)->nullable();
            $table->string('frequency', 100)->nullable();
            $table->time('reminder_time')->nullable();
            $table->string('image_url', 500)->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamps();

            $table->foreign('patient_id')
                ->references('id')
                ->on('patient_profiles')
                ->onDelete('cascade');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('medications');
    }
};
