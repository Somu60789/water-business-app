<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('subscriptions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('customer_id')->constrained('users');
            $table->foreignId('vendor_id')->constrained('vendors');
            $table->foreignId('product_id')->constrained('products');
            $table->integer('qty');
            $table->enum('frequency', ['daily', 'weekly', 'monthly']);
            $table->tinyInteger('day_of_week')->nullable()->comment('0=Sun,6=Sat');
            $table->tinyInteger('day_of_month')->nullable();
            $table->enum('delivery_slot', ['morning', 'afternoon', 'evening']);
            $table->foreignId('address_id')->constrained('addresses');
            $table->enum('payment_mode', ['cod', 'online']);
            $table->boolean('is_active')->default(true);
            $table->date('next_delivery_date');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('subscriptions');
    }
};
