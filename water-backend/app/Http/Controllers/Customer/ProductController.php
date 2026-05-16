<?php
namespace App\Http\Controllers\Customer;

use App\Http\Controllers\Controller;
use App\Models\Vendor;

class ProductController extends Controller
{
    public function index(Vendor $vendor): \Illuminate\Http\JsonResponse
    {
        $products = $vendor->products()->where('is_available', true)->get();
        return response()->json(['success' => true, 'data' => $products]);
    }
}
