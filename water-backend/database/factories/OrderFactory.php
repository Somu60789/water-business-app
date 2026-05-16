<?php
namespace Database\Factories;

use App\Models\User;
use App\Models\Vendor;
use App\Models\Address;
use Illuminate\Database\Eloquent\Factories\Factory;

class OrderFactory extends Factory
{
    public function definition(): array
    {
        $customer = User::factory()->create(['role' => 'customer']);
        $vendor   = Vendor::factory()->create();
        $address  = Address::create([
            'user_id' => $customer->id, 'label' => 'Home',
            'address_line' => fake()->address(), 'lat' => 12.97, 'lng' => 77.59,
        ]);

        return [
            'customer_id'         => $customer->id,
            'vendor_id'           => $vendor->id,
            'delivery_boy_id'     => null,
            'status'              => 'pending',
            'payment_mode'        => 'cod',
            'payment_status'      => 'pending',
            'total_amount'        => 100.00,
            'delivery_address_id' => $address->id,
            'delivery_slot'       => 'morning',
            'otp'                 => str_pad((string) random_int(0, 999999), 6, '0', STR_PAD_LEFT),
        ];
    }
}
