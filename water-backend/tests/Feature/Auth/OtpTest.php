<?php
use App\Models\User;
use App\Services\OtpService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Cache;

uses(RefreshDatabase::class);

it('sends OTP for new phone and creates user', function () {
    $response = $this->postJson('/api/auth/send-otp', ['phone' => '9876543210']);
    $response->assertOk()->assertJson(['success' => true]);
    $this->assertDatabaseHas('users', ['phone' => '9876543210']);
});

it('returns 422 if phone is missing', function () {
    $response = $this->postJson('/api/auth/send-otp', []);
    $response->assertUnprocessable();
});

it('verifies OTP and returns token', function () {
    $phone = '9123456789';
    $user  = User::factory()->create(['phone' => $phone]);
    Cache::put("otp:{$phone}", '123456', now()->addMinutes(5));

    $response = $this->postJson('/api/auth/verify-otp', ['phone' => $phone, 'otp' => '123456']);
    $response->assertOk()->assertJsonStructure(['success', 'data' => ['token', 'user']]);
});

it('rejects wrong OTP', function () {
    $phone = '9111111111';
    User::factory()->create(['phone' => $phone]);
    Cache::put("otp:{$phone}", '999999', now()->addMinutes(5));

    $response = $this->postJson('/api/auth/verify-otp', ['phone' => $phone, 'otp' => '000000']);
    $response->assertUnprocessable()->assertJsonFragment(['success' => false]);
});
