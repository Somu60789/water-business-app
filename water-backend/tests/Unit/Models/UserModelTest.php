<?php

use App\Models\User;
use App\Models\Vendor;
use App\Models\Order;
use Illuminate\Database\Capsule\Manager as Capsule;

it('has correct fillable fields', function () {
    $user = new User();
    expect($user->getFillable())->toContain('name', 'phone', 'email', 'role', 'fcm_token');
});

it('has vendor relationship method', function () {
    $user = new User();
    expect(method_exists($user, 'vendor'))->toBeTrue();

    // Verify return type hint without invoking DB
    $reflection = new ReflectionMethod(User::class, 'vendor');
    $returnType = (string) $reflection->getReturnType();
    expect($returnType)->toBe('Illuminate\Database\Eloquent\Relations\HasOne');
});
