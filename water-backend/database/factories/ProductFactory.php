<?php

namespace Database\Factories;

use App\Models\Vendor;
use Illuminate\Database\Eloquent\Factories\Factory;

class ProductFactory extends Factory
{
    public function definition(): array
    {
        return [
            'vendor_id'    => Vendor::factory(),
            'name'         => fake()->randomElement(['Bisleri 20L', 'Kinley 20L', 'Aqua 5L', 'Pure 1L']),
            'unit'         => fake()->randomElement(['20L', '5L', '1L']),
            'price'        => fake()->randomFloat(2, 10, 120),
            'stock_qty'    => fake()->numberBetween(10, 200),
            'is_available' => true,
        ];
    }
}
