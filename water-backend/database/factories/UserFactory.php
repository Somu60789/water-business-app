<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

class UserFactory extends Factory
{
    public function definition(): array
    {
        return [
            'name'      => fake()->name(),
            'phone'     => fake()->unique()->numerify('98########'),
            'email'     => fake()->unique()->safeEmail(),
            'role'      => 'customer',
            'is_active' => true,
        ];
    }

    public function vendor(): static
    {
        return $this->state(['role' => 'vendor']);
    }

    public function deliveryBoy(): static
    {
        return $this->state(['role' => 'delivery_boy']);
    }
}
