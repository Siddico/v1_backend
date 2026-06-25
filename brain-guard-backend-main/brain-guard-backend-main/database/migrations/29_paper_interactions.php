<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('paper_interactions', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->unsignedBigInteger('researcher_id');
            $table->unsignedBigInteger('paper_id');
            $table->boolean('is_liked')->default(false);
            $table->integer('view_count')->default(0);
            $table->timestamp('interacted_at');
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
        Schema::dropIfExists('paper_interactions');
    }
};

