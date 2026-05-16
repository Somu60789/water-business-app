<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class DeliveryBoyLocation extends Model
{
    public $timestamps = false;
    protected $fillable = ['user_id', 'lat', 'lng'];
    protected $casts    = ['lat' => 'float', 'lng' => 'float'];
}
