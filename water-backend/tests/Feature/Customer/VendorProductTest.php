<?php
use App\Models\User;
use App\Models\Vendor;
use App\Models\Product;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

it('returns nearby vendors for authenticated customer', function () {
    $customer = User::factory()->create(['role' => 'customer']);
    Vendor::factory()->count(3)->create(['lat' => 12.97, 'lng' => 77.59]);

    $response = $this->actingAs($customer)
        ->getJson('/api/vendors?lat=12.97&lng=77.59');

    $response->assertOk()->assertJsonStructure(['success', 'data' => [['id', 'business_name']]]);
});

it('returns products for a vendor', function () {
    $customer = User::factory()->create(['role' => 'customer']);
    $vendor   = Vendor::factory()->create();
    Product::factory()->count(2)->create(['vendor_id' => $vendor->id]);

    $response = $this->actingAs($customer)
        ->getJson("/api/vendors/{$vendor->id}/products");

    $response->assertOk()->assertJsonCount(2, 'data');
});

it('blocks non-vendor from creating products', function () {
    $customer = User::factory()->create(['role' => 'customer']);

    $response = $this->actingAs($customer)
        ->postJson('/api/products', ['name' => 'Test', 'price' => 50, 'unit' => '20L']);

    $response->assertForbidden();
});

it('allows vendor to create a product', function () {
    $vendorUser = User::factory()->vendor()->create();
    $vendor     = Vendor::factory()->create(['user_id' => $vendorUser->id]);

    $response = $this->actingAs($vendorUser)->postJson('/api/products', [
        'name'      => '20L Bisleri',
        'unit'      => '20L',
        'price'     => 55.00,
        'stock_qty' => 100,
    ]);

    $response->assertCreated()->assertJsonFragment(['name' => '20L Bisleri']);
});
