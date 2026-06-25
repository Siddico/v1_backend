<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('radiology_imaging', function (Blueprint $table) {
            $table->text('description')->nullable()->after('imaging_type');
        });
    }

    public function down(): void
    {
        Schema::table('radiology_imaging', function (Blueprint $table) {
            $table->dropColumn('description');
        });
    }
};
