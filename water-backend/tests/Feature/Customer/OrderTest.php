<?php
use App\Models\User;
use App\Models\Vendor;
use App\Models\Product;
use App\Models\Address;
use App\Models\Order;

it('customer can place an order', function () {
    $customer = User::factory()->create(['role' => 'customer']);
    $vendor   = Vendor::factory()->create();
    $product  = Product::factory()->create(['vendor_id' => $vendor->id, 'price' => 50]);
    $address  = Address::create([
        'user_id' => $customer->id, 'label' => 'Home',
        'address_line' => '123 St', 'lat' => 12.97, 'lng' => 77.59,
    ]);

    $response = $this->actingAs($customer)->postJson('/api/orders', [
        'vendor_id'   => $vendor->id,
        'address_id'  => $address->id,
        'delivery_slot' => 'morning',
        'payment_mode'  => 'cod',
        'items' => [['product_id' => $product->id, 'qty' => 2]],
    ]);

    $response->assertCreated()->assertJsonFragment(['status' => 'pending']);
    $this->assertDatabaseHas('orders', ['customer_id' => $customer->id, 'total_amount' => 100]);
});

it('vendor can accept an order', function () {
    $vendorUser = User::factory()->vendor()->create();
    $vendor     = Vendor::factory()->create(['user_id' => $vendorUser->id]);
    $order      = Order::factory()->create(['vendor_id' => $vendor->id, 'status' => 'pending']);

    $response = $this->actingAs($vendorUser)
        ->putJson("/api/orders/{$order->id}/status", ['status' => 'accepted']);

    $response->assertOk()->assertJsonFragment(['status' => 'accepted']);
});

it('vendor cannot set invalid status', function () {
    $vendorUser = User::factory()->vendor()->create();
    $vendor     = Vendor::factory()->create(['user_id' => $vendorUser->id]);
    $order      = Order::factory()->create(['vendor_id' => $vendor->id, 'status' => 'pending']);

    $response = $this->actingAs($vendorUser)
        ->putJson("/api/orders/{$order->id}/status", ['status' => 'delivered']);

    $response->assertUnprocessable();
});
