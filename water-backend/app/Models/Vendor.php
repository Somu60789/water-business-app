<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Vendor extends Model
{
    use HasFactory;

    protected $fillable = ['user_id', 'business_name', 'address', 'lat', 'lng', 'service_radius_km', 'is_open'];
    protected $casts    = ['is_open' => 'boolean', 'lat' => 'float', 'lng' => 'float', 'service_radius_km' => 'float'];

    public function user(): \Illuminate\Database\Eloquent\Relations\BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function products(): \Illuminate\Database\Eloquent\Relations\HasMany
    {
        return $this->hasMany(Product::class);
    }

    public function orders(): \Illuminate\Database\Eloquent\Relations\HasMany
    {
        return $this->hasMany(Order::class);
    }

    public function deliveryBoys(): \Illuminate\Database\Eloquent\Relations\HasMany
    {
        return $this->hasMany(VendorDeliveryBoy::class);
    }

    public function reviews(): \Illuminate\Database\Eloquent\Relations\HasMany
    {
        return $this->hasMany(Review::class);
    }
}
