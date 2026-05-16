<?php
namespace App\Http\Controllers\Customer;

use App\Http\Controllers\Controller;
use App\Models\Order;
use Illuminate\Http\Request;

class TrackingController extends Controller
{
    public function show(Request $request, Order $order): \Illuminate\Http\JsonResponse
    {
        abort_if($order->customer_id !== $request->user()->id, 403);

        $location = null;
        if ($order->delivery_boy_id && $order->status === 'out_for_delivery') {
            $order->loadMissing('deliveryBoy.location');
            $location = $order->deliveryBoy?->location
                ? ['lat' => $order->deliveryBoy->location->lat, 'lng' => $order->deliveryBoy->location->lng]
                : null;
        }

        return response()->json([
            'success' => true,
            'data'    => [
                'status'   => $order->status,
                'location' => $location,
            ],
        ]);
    }
}
