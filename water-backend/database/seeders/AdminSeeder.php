<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;

class AdminSeeder extends Seeder
{
    public function run(): void
    {
        User::firstOrCreate(
            ['phone' => '9000000000'],
            ['name' => 'Admin', 'role' => 'admin', 'is_active' => true]
        );
    }
}
