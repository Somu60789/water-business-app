<?php
namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\SendOtpRequest;
use App\Http\Requests\Auth\VerifyOtpRequest;
use App\Models\User;
use App\Services\OtpService;

class OtpController extends Controller
{
    public function __construct(private OtpService $otpService) {}

    public function sendOtp(SendOtpRequest $request): \Illuminate\Http\JsonResponse
    {
        User::firstOrCreate(
            ['phone' => $request->phone],
            ['name' => 'User', 'role' => 'customer', 'is_active' => true]
        );

        $otp = $this->otpService->generate();
        $this->otpService->store($request->phone, $otp);

        logger("OTP for {$request->phone}: {$otp}");

        return response()->json(['success' => true, 'message' => 'OTP sent']);
    }

    public function verifyOtp(VerifyOtpRequest $request): \Illuminate\Http\JsonResponse
    {
        if (! $this->otpService->verify($request->phone, $request->otp)) {
            return response()->json(['success' => false, 'message' => 'Invalid or expired OTP'], 422);
        }

        $user = User::where('phone', $request->phone)->first();
        if (! $user) {
            return response()->json(['success' => false, 'message' => 'User not found'], 404);
        }

        $token = $user->createToken('api')->plainTextToken;

        return response()->json([
            'success' => true,
            'data'    => ['token' => $token, 'user' => $user],
        ]);
    }

    public function updateProfile(\Illuminate\Http\Request $request): \Illuminate\Http\JsonResponse
    {
        $request->user()->update($request->only('name', 'email', 'fcm_token'));
        return response()->json(['success' => true, 'data' => $request->user()]);
    }
}
