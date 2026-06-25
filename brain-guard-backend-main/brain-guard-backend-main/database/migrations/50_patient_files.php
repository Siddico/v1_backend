<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('patient_files', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('patient_id');
            $table->string('file_name')->nullable();
            $table->string('file_url');
            $table->string('category', 50)->nullable(); // e.g., 'prescription', 'ai_mat'
            $table->string('extension', 10)->nullable(); // e.g., 'pdf', 'png', 'mat'
            $table->timestamps();

            $table->foreign('patient_id')
                ->references('id')
                ->on('patient_profiles')
                ->onDelete('cascade');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('patient_files');
    }
};
