<?php
use App\Http\Controllers\Auth\OtpController;
use App\Http\Controllers\Customer\VendorController as CustomerVendorController;
use App\Http\Controllers\Customer\ProductController as CustomerProductController;
use App\Http\Controllers\Vendor\ProductController as VendorProductController;
use Illuminate\Support\Facades\Route;

Route::prefix('auth')->group(function () {
    Route::post('/send-otp',   [OtpController::class, 'sendOtp']);
    Route::post('/verify-otp', [OtpController::class, 'verifyOtp']);
    Route::middleware('auth:sanctum')->put('/profile', [OtpController::class, 'updateProfile']);
});

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/vendors',                          [CustomerVendorController::class, 'index']);
    Route::get('/vendors/{vendor}/products',        [CustomerProductController::class, 'index']);

    Route::middleware('role:vendor')->group(function () {
        Route::post('/products',                    [VendorProductController::class, 'store']);
        Route::put('/products/{product}',           [VendorProductController::class, 'update']);
        Route::delete('/products/{product}',        [VendorProductController::class, 'destroy']);
    });
});
