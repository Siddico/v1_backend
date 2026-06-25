<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('paper_sections', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->unsignedBigInteger('paper_id');
            $table->text('abstract')->nullable();
            $table->text('keywords')->nullable();
            $table->text('appendices')->nullable();
            $table->text('introduction')->nullable();
            $table->text('methodology')->nullable();
            $table->text('result')->nullable();
            $table->text('discussion')->nullable();
            $table->text('conclusion')->nullable();
            $table->text('references')->nullable();
            $table->timestamps();

            $table->foreign('paper_id')
                ->references('id')
                ->on('research_papers')
                ->onDelete('cascade');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('paper_sections');
    }
};

