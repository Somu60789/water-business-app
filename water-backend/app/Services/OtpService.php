<?php
namespace App\Services;

use Illuminate\Support\Facades\Cache;

class OtpService
{
    private int $ttlMinutes = 5;

    public function generate(): string
    {
        return str_pad((string) random_int(0, 999999), 6, '0', STR_PAD_LEFT);
    }

    public function store(string $phone, string $otp): void
    {
        Cache::put("otp:{$phone}", $otp, now()->addMinutes($this->ttlMinutes));
    }

    public function verify(string $phone, string $otp): bool
    {
        $stored = Cache::get("otp:{$phone}");
        if ($stored === null) {
            return false;
        }
        if (hash_equals($stored, $otp)) {
            Cache::forget("otp:{$phone}");
            return true;
        }
        return false;
    }
}
