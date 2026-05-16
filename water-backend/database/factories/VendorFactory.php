<?php

namespace Database\Factories;

use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

class VendorFactory extends Factory
{
    public function definition(): array
    {
        return [
            'user_id'           => User::factory()->vendor(),
            'business_name'     => fake()->company() . ' Water',
            'address'           => fake()->address(),
            'lat'               => fake()->latitude(12.8, 13.1),
            'lng'               => fake()->longitude(77.4, 77.8),
            'service_radius_km' => 10,
            'is_open'           => true,
        ];
    }
}
