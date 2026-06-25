<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('research_alerts', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->unsignedBigInteger('researcher_id');
            $table->unsignedBigInteger('paper_id');
            $table->string('alert_type', 100);
            $table->timestamp('alert_time');
            $table->boolean('is_read')->default(false);
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
        Schema::dropIfExists('research_alerts');
    }
};

