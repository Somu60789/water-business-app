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

    // Customer orders
    Route::middleware('role:customer')->group(function () {
        Route::post('/orders',        [\App\Http\Controllers\Customer\OrderController::class, 'store']);
        Route::get('/orders',         [\App\Http\Controllers\Customer\OrderController::class, 'index']);
        Route::get('/orders/{order}', [\App\Http\Controllers\Customer\OrderController::class, 'show']);
    });

    // Vendor order management
    Route::middleware('role:vendor')->group(function () {
        Route::get('/vendor/orders',           [\App\Http\Controllers\Vendor\OrderController::class, 'index']);
        Route::put('/orders/{order}/status',   [\App\Http\Controllers\Vendor\OrderController::class, 'updateStatus']);
    });
});
