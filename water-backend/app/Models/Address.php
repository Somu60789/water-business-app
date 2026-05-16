<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Address extends Model
{
    protected $fillable = ['user_id', 'label', 'address_line', 'lat', 'lng', 'is_default'];
    protected $casts    = ['is_default' => 'boolean', 'lat' => 'float', 'lng' => 'float'];

    public function user(): \Illuminate\Database\Eloquent\Relations\BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
