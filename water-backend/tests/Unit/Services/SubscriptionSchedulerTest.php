<?php
use App\Services\SubscriptionSchedulerService;
use App\Models\Subscription;
use App\Models\User;
use App\Models\Vendor;
use App\Models\Product;
use App\Models\Address;
use Carbon\Carbon;

it('calculates next daily delivery date as tomorrow', function () {
    $service = new SubscriptionSchedulerService();
    $next    = $service->calculateNextDate('daily', null, null, Carbon::today());
    expect($next->toDateString())->toBe(Carbon::tomorrow()->toDateString());
});

it('calculates next weekly delivery date', function () {
    $service = new SubscriptionSchedulerService();
    $next = $service->calculateNextDate('weekly', 1, null, Carbon::parse('2026-05-18'));
    expect($next->toDateString())->toBe('2026-05-25');
});

it('generates subscription orders for due subscriptions', function () {
    $customer = User::factory()->create(['role' => 'customer']);
    $vendor   = Vendor::factory()->create();
    $product  = Product::factory()->create(['vendor_id' => $vendor->id]);
    $address  = Address::create([
        'user_id' => $customer->id, 'label' => 'Home',
        'address_line' => '1 Main St', 'lat' => 12.97, 'lng' => 77.59,
    ]);

    Subscription::create([
        'customer_id'        => $customer->id,
        'vendor_id'          => $vendor->id,
        'product_id'         => $product->id,
        'qty'                => 1,
        'frequency'          => 'daily',
        'delivery_slot'      => 'morning',
        'address_id'         => $address->id,
        'payment_mode'       => 'cod',
        'is_active'          => true,
        'next_delivery_date' => Carbon::today(),
    ]);

    $service = new SubscriptionSchedulerService();
    $count   = $service->generateDueOrders(Carbon::today());

    expect($count)->toBe(1);
    $this->assertDatabaseHas('orders', ['customer_id' => $customer->id]);
});
