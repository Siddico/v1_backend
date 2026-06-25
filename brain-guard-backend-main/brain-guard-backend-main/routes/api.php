<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Auth\AuthController;
use App\Http\Controllers\Auth\OtpController;
use App\Http\Controllers\Auth\PasswordResetController;
use App\Http\Controllers\Patient\PatientProfileController;
use App\Http\Controllers\Patient\HealthDataController;
use App\Http\Controllers\Patient\SignalController;
use App\Http\Controllers\Patient\PredictionController;
use App\Http\Controllers\Patient\NotificationController;
use App\Http\Controllers\Patient\ReportController;
use App\Http\Controllers\Patient\EmergencyController;
use App\Http\Controllers\Patient\ChatController as PatientChatController;
use App\Http\Controllers\Patient\RadiologyController;
use App\Http\Controllers\Patient\QrController;
use App\Http\Controllers\Patient\RelationshipRequestController as PatientRelationshipRequestController;
use App\Http\Controllers\Patient\AppointmentController as PatientAppointmentController;
use App\Http\Controllers\Patient\MedicationController;
use App\Http\Controllers\Patient\ChatbotController;
use App\Http\Controllers\Doctor\DoctorProfileController;
use App\Http\Controllers\Doctor\DoctorListController;
use App\Http\Controllers\Doctor\DoctorPatientDetailController;
use App\Http\Controllers\Doctor\PatientListController;
use App\Http\Controllers\Doctor\DoctorAlertController;
use App\Http\Controllers\Doctor\FollowUpController;
use App\Http\Controllers\Doctor\MedicalDataController;
use App\Http\Controllers\Doctor\LabDocumentController;
use App\Http\Controllers\Doctor\RadiologyImagingController;
use App\Http\Controllers\Doctor\ChatController as DoctorChatController;
use App\Http\Controllers\Doctor\RelationshipRequestController as DoctorRelationshipRequestController;
use App\Http\Controllers\Doctor\AppointmentController as DoctorAppointmentController;
use App\Http\Controllers\Researcher\ResearcherProfileController;
use App\Http\Controllers\Researcher\ResearchPaperController;
use App\Http\Controllers\Researcher\PaperSectionController;
use App\Http\Controllers\Researcher\SavedPaperController;
use App\Http\Controllers\Researcher\PaperInteractionController;
use App\Http\Controllers\Researcher\ResearchAlertController;
use App\Http\Controllers\AI\DeviceController;

use App\Http\Controllers\Patient\PatientFileController;
use App\Http\Controllers\Patient\PatientRecordController;
use App\Http\Controllers\Patient\PatientChartController;
use App\Http\Controllers\Patient\MyDoctorController;
use App\Http\Controllers\Patient\QrScanController;
use App\Http\Controllers\Patient\DoctorProfileController as PatientDoctorProfileController;
use App\Http\Controllers\Patient\AboutUsController;

Route::prefix('v1')->group(function () {

    Route::get('doctors', [DoctorListController::class, 'index']);
    Route::get('about-us', [AboutUsController::class, 'index']);

    // Auth Routes (Public)
    Route::prefix('auth')->group(function () {
        Route::post('register', [AuthController::class, 'register']);
        Route::post('login', [AuthController::class, 'login']);
        Route::post('otp/send', [OtpController::class, 'sendOtp']);
        Route::post('otp/verify', [OtpController::class, 'verifyOtp']);
        Route::post('password/reset', [PasswordResetController::class, 'resetPassword']);
    });

    // Auth Routes (Protected)
    Route::middleware('auth:sanctum')->group(function () {
        Route::post('auth/logout', [AuthController::class, 'logout']);
        Route::get('auth/me', [AuthController::class, 'me']);
        Route::post('auth/fcm-token', [AuthController::class, 'updateFcmToken']);
    });

    // Patient Routes
    Route::middleware(['auth:sanctum', 'role:patient'])->prefix('patient')->group(function () {
        Route::get('profile', [PatientProfileController::class, 'show']);
        Route::post('profile', [PatientProfileController::class, 'update']);
        Route::get('health-data', [HealthDataController::class, 'index']);
        Route::post('health-data', [HealthDataController::class, 'store']);
        Route::get('signals', [SignalController::class, 'index']);
        Route::post('signals', [SignalController::class, 'store']);
        Route::post('predict', [PredictionController::class, 'predict']);
        Route::get('predictions', [PredictionController::class, 'index']);
        Route::get('notifications', [NotificationController::class, 'index']);
        Route::patch('notifications/{id}', [NotificationController::class, 'markAsRead']);
        Route::delete('notifications/{id}', [NotificationController::class, 'destroy']);
        Route::get('reports', [ReportController::class, 'index']);
        Route::get('emergency', [EmergencyController::class, 'index']);
        Route::get('chat', [PatientChatController::class, 'index']);
        Route::post('chat', [PatientChatController::class, 'store']);
        Route::post('chat/read', [PatientChatController::class, 'markAsRead']);
        Route::post('radiology', [RadiologyController::class, 'store']);
        Route::post('qr', [QrController::class, 'store']);
        Route::post('qr/scan', [QrScanController::class, 'verifyDoctor']);
        Route::get('doctors/{id}', [PatientDoctorProfileController::class, 'show']);
        Route::get('my-doctors', [MyDoctorController::class, 'index']);
        Route::post('files', [PatientFileController::class, 'store']);
        Route::get('records', [PatientRecordController::class, 'index']);
        Route::get('charts-dashboard', [PatientChartController::class, 'index']);
        Route::get('relationship-requests', [PatientRelationshipRequestController::class, 'index']);
        Route::post('relationship-requests', [PatientRelationshipRequestController::class, 'store']);
        Route::delete('relationship-requests/{id}', [PatientRelationshipRequestController::class, 'destroy']);
        Route::get('appointments', [PatientAppointmentController::class, 'index']);
        Route::post('appointments', [PatientAppointmentController::class, 'store']);
        Route::get('appointments/{id}', [PatientAppointmentController::class, 'show']);
        Route::put('appointments/{id}', [PatientAppointmentController::class, 'update']);
        Route::get('medications', [MedicationController::class, 'index']);
        Route::post('medications', [MedicationController::class, 'store']);
        Route::put('medications/{id}', [MedicationController::class, 'update']);
        Route::delete('medications/{id}', [MedicationController::class, 'destroy']);
        Route::get('chatbot/sessions', [ChatbotController::class, 'sessions']);
        Route::post('chatbot/sessions', [ChatbotController::class, 'createSession']);
        Route::delete('chatbot/sessions/{id}', [ChatbotController::class, 'destroySession']);
        Route::get('chatbot/sessions/{id}/messages', [ChatbotController::class, 'messages']);
        Route::post('chatbot/sessions/{id}/messages', [ChatbotController::class, 'sendMessage']);
    });

    // Doctor Routes
    Route::middleware(['auth:sanctum', 'role:doctor'])->prefix('doctor')->group(function () {
        Route::get('profile', [DoctorProfileController::class, 'show']);
        Route::post('profile', [DoctorProfileController::class, 'update']);
        Route::get('patients', [PatientListController::class, 'index']);
        Route::get('patients/{id}', [DoctorPatientDetailController::class, 'show']);
        Route::post('patients', [PatientListController::class, 'store']);
        Route::get('alerts', [DoctorAlertController::class, 'index']);
        Route::put('alerts/{id}', [DoctorAlertController::class, 'update']);
        Route::get('follow-up', [FollowUpController::class, 'index']);
        Route::post('follow-up', [FollowUpController::class, 'store']);
        Route::get('medical-data', [MedicalDataController::class, 'index']);
        Route::post('medical-data', [MedicalDataController::class, 'store']);
        Route::get('lab-documents', [LabDocumentController::class, 'index']);
        Route::post('lab-documents', [LabDocumentController::class, 'store']);
        Route::get('radiology', [RadiologyImagingController::class, 'index']);
        Route::post('radiology', [RadiologyImagingController::class, 'store']);
        Route::get('chat', [DoctorChatController::class, 'index']);
        Route::post('chat', [DoctorChatController::class, 'store']);
        Route::get('relationship-requests', [DoctorRelationshipRequestController::class, 'index']);
        Route::put('relationship-requests/{id}', [DoctorRelationshipRequestController::class, 'update']);
        Route::get('appointments', [DoctorAppointmentController::class, 'index']);
        Route::put('appointments/{id}', [DoctorAppointmentController::class, 'update']);
    });

    // Researcher Routes
    Route::middleware(['auth:sanctum', 'role:researcher'])->prefix('researcher')->group(function () {
        Route::get('profile', [ResearcherProfileController::class, 'show']);
        Route::post('profile', [ResearcherProfileController::class, 'update']);
        Route::get('papers', [ResearchPaperController::class, 'index']);
        Route::post('papers', [ResearchPaperController::class, 'store']);
        Route::get('papers/search', [ResearchPaperController::class, 'search']);
        Route::get('papers/{id}', [ResearchPaperController::class, 'show']);
        Route::put('papers/{id}', [ResearchPaperController::class, 'update']);
        Route::post('papers/{id}/sections', [PaperSectionController::class, 'store']);
        Route::post('papers/{id}/save', [SavedPaperController::class, 'store']);
        Route::post('papers/{id}/interact', [PaperInteractionController::class, 'store']);
        Route::get('alerts', [ResearchAlertController::class, 'index']);
    });

    // Device/IoT Routes
    Route::middleware('auth:sanctum')->group(function () {
        Route::post('device/data', [DeviceController::class, 'ingest']);
    });
});
