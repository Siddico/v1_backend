<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (! Schema::hasColumn('otp_codes', 'email')) {
            Schema::table('otp_codes', function (Blueprint $table) {
                $table->string('email', 255)->nullable()->after('user_id');
            });
        }
    }

    public function down(): void
    {
        if (Schema::hasColumn('otp_codes', 'email')) {
            Schema::table('otp_codes', function (Blueprint $table) {
                $table->dropColumn('email');
            });
        }
    }
};
