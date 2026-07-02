<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('lab_documents', function (Blueprint $table) {
            $table->string('file_url', 255)->nullable()->change();
        });

        Schema::table('radiology_imaging', function (Blueprint $table) {
            $table->string('file_url', 255)->nullable()->change();
        });
    }

    public function down(): void
    {
        Schema::table('lab_documents', function (Blueprint $table) {
            $table->string('file_url', 255)->nullable(false)->change();
        });

        Schema::table('radiology_imaging', function (Blueprint $table) {
            $table->string('file_url', 255)->nullable(false)->change();
        });
    }
};
