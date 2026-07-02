<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('relationship_requests', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->unsignedBigInteger('patient_id');
            $table->unsignedBigInteger('doctor_id');
            $table->text('message')->nullable();
            $table->enum('status', ['pending', 'accepted', 'rejected'])->default('pending');
            $table->timestamp('requested_at')->useCurrent();
            $table->timestamp('responded_at')->nullable();
            $table->timestamps();

            $table->foreign('patient_id')
                ->references('id')
                ->on('patient_profiles')
                ->onDelete('cascade');

            $table->foreign('doctor_id')
                ->references('id')
                ->on('doctor_profiles')
                ->onDelete('cascade');

            $table->unique(['patient_id', 'doctor_id', 'status'], 'relationship_requests_patient_doctor_pending_unique');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('relationship_requests');
    }
};
