<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('paper_search_logs', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->unsignedBigInteger('researcher_id');
            $table->string('keyword', 255);
            $table->string('filter_field', 100)->nullable();
            $table->year('filter_year')->nullable();
            $table->string('filter_institution', 255)->nullable();
            $table->timestamp('searched_at');
            $table->timestamps();

            $table->foreign('researcher_id')
                ->references('id')
                ->on('researcher_profiles')
                ->onDelete('cascade');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('paper_search_logs');
    }
};

