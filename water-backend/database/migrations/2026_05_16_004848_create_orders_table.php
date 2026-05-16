<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('orders', function (Blueprint $table) {
            $table->id();
            $table->foreignId('customer_id')->constrained('users');
            $table->foreignId('vendor_id')->constrained('vendors');
            $table->foreignId('delivery_boy_id')->nullable()->constrained('users')->nullOnDelete();
            $table->enum('status', ['pending', 'accepted', 'assigned', 'out_for_delivery', 'delivered', 'cancelled'])->default('pending');
            $table->enum('payment_mode', ['cod', 'online']);
            $table->enum('payment_status', ['pending', 'paid'])->default('pending');
            $table->string('razorpay_order_id')->nullable();
            $table->decimal('total_amount', 10, 2);
            $table->foreignId('delivery_address_id')->constrained('addresses');
            $table->enum('delivery_slot', ['morning', 'afternoon', 'evening']);
            $table->string('otp', 6)->nullable();
            $table->text('notes')->nullable();
            $table->timestamps();
            $table->index(['status', 'vendor_id']);
            $table->index(['customer_id', 'status']);
            $table->index(['delivery_boy_id', 'status']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('orders');
    }
};
