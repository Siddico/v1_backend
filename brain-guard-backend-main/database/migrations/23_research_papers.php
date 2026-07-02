<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('research_papers', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->unsignedBigInteger('researcher_id');
            $table->string('paper_name', 255);
            $table->string('publisher_name', 255)->nullable();
            $table->string('category_topic', 255)->nullable();
            $table->date('date')->nullable();
            $table->text('description')->nullable();
            $table->enum('upload_type', ['manual', 'direct'])->default('manual');
            $table->string('file_path', 255)->nullable();
            $table->boolean('is_verified')->default(false);
            $table->enum('status', ['pending', 'approved', 'rejected'])->default('pending');
            $table->timestamps();

            $table->foreign('researcher_id')
                ->references('id')
                ->on('researcher_profiles')
                ->onDelete('cascade');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('research_papers');
    }
};

