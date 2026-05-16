<?php
namespace App\Services;

use Razorpay\Api\Api;

class RazorpayService
{
    private Api $api;

    public function __construct(
        private string $keyId,
        private string $keySecret,
    ) {
        $this->api = new Api($keyId, $keySecret);
    }

    public function createOrder(int $amountPaise, string $receiptId): array
    {
        $order = $this->api->order->create([
            'amount'          => $amountPaise,
            'currency'        => 'INR',
            'receipt'         => $receiptId,
            'payment_capture' => 1,
        ]);

        return ['razorpay_order_id' => $order->id, 'amount' => $amountPaise];
    }

    public function verifySignature(string $razorpayOrderId, string $razorpayPaymentId, string $signature): bool
    {
        $expected = hash_hmac('sha256', "{$razorpayOrderId}|{$razorpayPaymentId}", $this->keySecret);
        return hash_equals($expected, $signature);
    }
}
