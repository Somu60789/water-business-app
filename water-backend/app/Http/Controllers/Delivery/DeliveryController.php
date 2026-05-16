<?php
namespace App\Http\Controllers\Delivery;

use App\Http\Controllers\Controller;
use App\Models\Order;
use Illuminate\Http\Request;

class DeliveryController extends Controller
{
    public function index(Request $request): \Illuminate\Http\JsonResponse
    {
        $orders = Order::where('delivery_boy_id', $request->user()->id)
            ->whereIn('status', ['assigned', 'out_for_delivery'])
            ->with(['customer:id,name,phone', 'deliveryAddress', 'items.product'])
            ->get();

        return response()->json(['success' => true, 'data' => $orders]);
    }

    public function updateStatus(Request $request, Order $order): \Illuminate\Http\JsonResponse
    {
        abort_if($order->delivery_boy_id !== $request->user()->id, 403);

        $data = $request->validate([
            'status' => ['required', 'in:out_for_delivery,delivered'],
        ]);

        $order->update(['status' => $data['status']]);
        return response()->json(['success' => true, 'data' => $order->fresh()]);
    }

    public function verifyOtp(Request $request, Order $order): \Illuminate\Http\JsonResponse
    {
        $request->validate(['otp' => ['required', 'string', 'size:6']]);

        abort_if($order->delivery_boy_id !== $request->user()->id, 403);

        if (! hash_equals($order->otp, $request->otp)) {
            return response()->json(['success' => false, 'message' => 'Invalid OTP'], 422);
        }

        $order->update([
            'status'         => 'delivered',
            'payment_status' => $order->payment_mode === 'cod' ? 'paid' : $order->payment_status,
        ]);
        return response()->json(['success' => true, 'data' => $order->fresh()]);
    }
}
