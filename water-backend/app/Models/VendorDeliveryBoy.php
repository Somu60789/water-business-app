<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class VendorDeliveryBoy extends Model
{
    protected $fillable = ['vendor_id', 'user_id', 'is_active'];
    protected $casts    = ['is_active' => 'boolean'];

    public function user(): \Illuminate\Database\Eloquent\Relations\BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function vendor(): \Illuminate\Database\Eloquent\Relations\BelongsTo
    {
        return $this->belongsTo(Vendor::class);
    }
}
