<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('patient_profiles', function (Blueprint $table) {
            $table->float('height')->nullable()->after('weight');
            $table->float('bmi')->nullable()->after('height');
            $table->string('blood_type', 10)->nullable()->after('bmi');
            $table->text('allergies')->nullable()->after('blood_type');
            $table->text('current_medications')->nullable()->after('allergies');
            $table->string('residence_type', 50)->nullable()->after('current_medications');
            $table->string('work_type', 50)->nullable()->after('residence_type');
            $table->boolean('ever_married')->nullable()->after('work_type');
            $table->string('smoking_status', 50)->nullable()->after('ever_married');
            $table->boolean('hypertension')->default(false)->after('smoking_status');
            $table->boolean('heart_disease')->default(false)->after('hypertension');
            $table->float('avg_glucose_level')->nullable()->after('heart_disease');
            $table->float('ai_risk_stroke_rate')->nullable()->after('avg_glucose_level');
            $table->timestamp('last_prediction_time')->nullable()->after('ai_risk_stroke_rate');
            $table->string('status', 50)->nullable()->default('normal')->after('last_prediction_time');
        });
    }

    public function down(): void
    {
        Schema::table('patient_profiles', function (Blueprint $table) {
            $table->dropColumn([
                'height',
                'bmi',
                'blood_type',
                'allergies',
                'current_medications',
                'residence_type',
                'work_type',
                'ever_married',
                'smoking_status',
                'hypertension',
                'heart_disease',
                'avg_glucose_level',
                'ai_risk_stroke_rate',
                'last_prediction_time',
                'status',
            ]);
        });
    }
};
