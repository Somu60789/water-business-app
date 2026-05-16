<?php
use App\Services\OtpService;
use Illuminate\Support\Facades\Cache;

beforeEach(function () {
    Cache::flush();
});

it('generates a 6-digit OTP', function () {
    $service = new OtpService();
    $otp = $service->generate();
    expect($otp)->toMatch('/^\d{6}$/');
});

it('stores and verifies OTP correctly', function () {
    $service = new OtpService();
    $phone = '9876543210';
    $otp = $service->generate();

    $service->store($phone, $otp);
    expect($service->verify($phone, '000000'))->toBeFalse(); // wrong OTP, cache still present
    expect($service->verify($phone, $otp))->toBeTrue();      // correct OTP clears cache
    expect($service->verify($phone, $otp))->toBeFalse();     // cache now gone
});

it('returns false for expired/missing OTP', function () {
    $service = new OtpService();
    expect($service->verify('9999999999', '123456'))->toBeFalse();
});
