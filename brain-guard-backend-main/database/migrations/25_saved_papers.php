<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('saved_papers', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->unsignedBigInteger('researcher_id');
            $table->unsignedBigInteger('paper_id');
            $table->boolean('is_favorite')->default(false);
            $table->timestamp('saved_at');
            $table->timestamps();

            $table->foreign('researcher_id')
                ->references('id')
                ->on('researcher_profiles')
                ->onDelete('cascade');

            $table->foreign('paper_id')
                ->references('id')
                ->on('research_papers')
                ->onDelete('cascade');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('saved_papers');
    }
};

