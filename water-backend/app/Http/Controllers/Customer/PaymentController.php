<?php
namespace App\Http\Controllers\Customer;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Services\RazorpayService;
use Illuminate\Http\Request;

class PaymentController extends Controller
{
    public function __construct(private RazorpayService $razorpay) {}

    public function createOrder(Request $request): \Illuminate\Http\JsonResponse
    {
        $data = $request->validate([
            'order_id' => ['required', 'exists:orders,id'],
        ]);

        $order = Order::findOrFail($data['order_id']);
        abort_if($order->customer_id !== $request->user()->id, 403);

        $rzpOrder = $this->razorpay->createOrder(
            (int) ($order->total_amount * 100),
            "order_{$order->id}"
        );

        $order->update(['razorpay_order_id' => $rzpOrder['razorpay_order_id']]);

        return response()->json(['success' => true, 'data' => $rzpOrder]);
    }

    public function verify(Request $request): \Illuminate\Http\JsonResponse
    {
        $data = $request->validate([
            'razorpay_order_id'   => ['required', 'string'],
            'razorpay_payment_id' => ['required', 'string'],
            'razorpay_signature'  => ['required', 'string'],
        ]);

        if (! $this->razorpay->verifySignature($data['razorpay_order_id'], $data['razorpay_payment_id'], $data['razorpay_signature'])) {
            return response()->json(['success' => false, 'message' => 'Payment verification failed'], 422);
        }

        $order = Order::where('razorpay_order_id', $data['razorpay_order_id'])->firstOrFail();
        $order->update(['payment_status' => 'paid']);

        return response()->json(['success' => true, 'message' => 'Payment verified']);
    }
}
