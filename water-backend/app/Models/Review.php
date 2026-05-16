<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Review extends Model
{
    protected $fillable = ['order_id', 'customer_id', 'vendor_id', 'rating', 'comment'];
}
