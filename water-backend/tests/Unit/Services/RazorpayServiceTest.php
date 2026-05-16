<?php
use App\Services\RazorpayService;

it('instantiates correctly', function () {
    $service = new RazorpayService(
        keyId: 'rzp_test_key',
        keySecret: 'test_secret'
    );
    expect($service)->toBeInstanceOf(RazorpayService::class);
});

it('verifies correct signature', function () {
    $service = new RazorpayService('key', 'secret');

    $orderId   = 'order_123';
    $paymentId = 'pay_abc';
    $signature = hash_hmac('sha256', "{$orderId}|{$paymentId}", 'secret');

    expect($service->verifySignature($orderId, $paymentId, $signature))->toBeTrue();
    expect($service->verifySignature($orderId, $paymentId, 'wrong'))->toBeFalse();
});
