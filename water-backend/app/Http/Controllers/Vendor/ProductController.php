<?php
namespace App\Http\Controllers\Vendor;

use App\Http\Controllers\Controller;
use App\Models\Product;
use Illuminate\Http\Request;

class ProductController extends Controller
{
    public function store(Request $request): \Illuminate\Http\JsonResponse
    {
        $data = $request->validate([
            'name'        => ['required', 'string', 'max:100'],
            'description' => ['nullable', 'string'],
            'unit'        => ['required', 'in:20L,5L,1L'],
            'price'       => ['required', 'numeric', 'min:1'],
            'stock_qty'   => ['nullable', 'integer', 'min:0'],
            'image_url'   => ['nullable', 'url'],
        ]);

        $vendor = $request->user()->vendor;
        abort_if($vendor === null, 403, 'Vendor profile not found');
        $product = $vendor->products()->create($data);

        return response()->json(['success' => true, 'data' => $product], 201);
    }

    public function update(Request $request, Product $product): \Illuminate\Http\JsonResponse
    {
        abort_if($request->user()->vendor === null, 403, 'Vendor profile not found');
        if ($product->vendor_id !== $request->user()->vendor->id) {
            return response()->json(['success' => false, 'message' => 'Forbidden'], 403);
        }

        $data = $request->validate([
            'name'         => ['sometimes', 'string', 'max:100'],
            'description'  => ['nullable', 'string'],
            'unit'         => ['sometimes', 'in:20L,5L,1L'],
            'price'        => ['sometimes', 'numeric', 'min:1'],
            'stock_qty'    => ['sometimes', 'integer', 'min:0'],
            'is_available' => ['sometimes', 'boolean'],
        ]);

        $product->update($data);
        return response()->json(['success' => true, 'data' => $product]);
    }

    public function destroy(Request $request, Product $product): \Illuminate\Http\JsonResponse
    {
        abort_if($request->user()->vendor === null, 403, 'Vendor profile not found');
        if ($product->vendor_id !== $request->user()->vendor->id) {
            return response()->json(['success' => false, 'message' => 'Forbidden'], 403);
        }

        $product->delete();
        return response()->json(['success' => true, 'message' => 'Product deleted']);
    }
}
