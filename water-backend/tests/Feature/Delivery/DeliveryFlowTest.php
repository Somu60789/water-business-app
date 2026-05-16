<?php
use App\Models\User;
use App\Models\Order;
use App\Models\Vendor;
use App\Models\DeliveryBoyLocation;

it('delivery boy can see assigned orders', function () {
    $db        = User::factory()->deliveryBoy()->create();
    $vendor    = Vendor::factory()->create();
    $order     = Order::factory()->create(['delivery_boy_id' => $db->id, 'vendor_id' => $vendor->id, 'status' => 'assigned']);

    $response = $this->actingAs($db)->getJson('/api/delivery/orders');
    $response->assertOk()->assertJsonFragment(['id' => $order->id]);
});

it('delivery boy can update location', function () {
    $db = User::factory()->deliveryBoy()->create();

    $response = $this->actingAs($db)->postJson('/api/location', ['lat' => 12.97, 'lng' => 77.59]);
    $response->assertOk();
    $this->assertDatabaseHas('delivery_boy_locations', ['user_id' => $db->id, 'lat' => 12.97]);
});

it('delivery boy confirms OTP to complete delivery', function () {
    $db    = User::factory()->deliveryBoy()->create();
    $vendor = Vendor::factory()->create();
    $order = Order::factory()->create([
        'delivery_boy_id' => $db->id,
        'vendor_id'       => $vendor->id,
        'status'          => 'out_for_delivery',
        'otp'             => '654321',
    ]);

    $response = $this->actingAs($db)
        ->postJson("/api/orders/{$order->id}/verify-otp", ['otp' => '654321']);

    $response->assertOk()->assertJsonFragment(['status' => 'delivered']);
});

it('rejects wrong OTP', function () {
    $db    = User::factory()->deliveryBoy()->create();
    $vendor = Vendor::factory()->create();
    $order = Order::factory()->create([
        'delivery_boy_id' => $db->id,
        'vendor_id'       => $vendor->id,
        'status'          => 'out_for_delivery',
        'otp'             => '654321',
    ]);

    $response = $this->actingAs($db)
        ->postJson("/api/orders/{$order->id}/verify-otp", ['otp' => '000000']);

    $response->assertUnprocessable();
});
