<?php
use App\Http\Controllers\Auth\OtpController;
use Illuminate\Support\Facades\Route;

Route::prefix('auth')->group(function () {
    Route::post('/send-otp',   [OtpController::class, 'sendOtp']);
    Route::post('/verify-otp', [OtpController::class, 'verifyOtp']);
    Route::middleware('auth:sanctum')->put('/profile', [OtpController::class, 'updateProfile']);
});
