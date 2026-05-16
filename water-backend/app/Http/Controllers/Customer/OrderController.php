<?php
namespace App\Http\Controllers\Customer;

use App\Http\Controllers\Controller;
use App\Http\Requests\Order\PlaceOrderRequest;
use App\Models\Order;
use App\Models\Product;
use Illuminate\Http\Request;

class OrderController extends Controller
{
    public function store(PlaceOrderRequest $request): \Illuminate\Http\JsonResponse
    {
        $productIds = collect($request->items)->pluck('product_id');
        $products   = Product::findMany($productIds)->keyBy('id');

        $items = collect($request->items)->map(function ($item) use ($products) {
            $product = $products[$item['product_id']];
            return ['product_id' => $product->id, 'qty' => $item['qty'], 'unit_price' => $product->price];
        });

        $total = $items->sum(fn($i) => $i['qty'] * $i['unit_price']);

        $order = Order::create([
            'customer_id'         => $request->user()->id,
            'vendor_id'           => $request->vendor_id,
            'delivery_address_id' => $request->address_id,
            'delivery_slot'       => $request->delivery_slot,
            'payment_mode'        => $request->payment_mode,
            'total_amount'        => $total,
            'otp'                 => str_pad((string) random_int(0, 999999), 6, '0', STR_PAD_LEFT),
            'notes'               => $request->notes,
        ]);

        $order->items()->createMany($items->toArray());

        return response()->json(['success' => true, 'data' => $order->load(['items.product', 'vendor'])], 201);
    }

    public function index(Request $request): \Illuminate\Http\JsonResponse
    {
        $orders = Order::where('customer_id', $request->user()->id)
            ->with(['vendor', 'items.product'])
            ->latest()
            ->paginate(20);

        return response()->json(['success' => true, 'data' => $orders]);
    }

    public function show(Request $request, Order $order): \Illuminate\Http\JsonResponse
    {
        abort_if($order->customer_id !== $request->user()->id, 403);

        return response()->json(['success' => true, 'data' => $order->load(['items.product', 'vendor', 'deliveryBoy'])]);
    }
}
