<?php
namespace App\Http\Controllers\Vendor;

use App\Http\Controllers\Controller;
use App\Http\Requests\Order\UpdateStatusRequest;
use App\Models\Order;
use Illuminate\Http\Request;

class OrderController extends Controller
{
    public function index(Request $request): \Illuminate\Http\JsonResponse
    {
        $vendorId = $request->user()->vendor->id;
        $orders   = Order::where('vendor_id', $vendorId)
            ->with(['customer:id,name,phone', 'items.product', 'deliveryAddress'])
            ->latest()
            ->paginate(20);

        return response()->json(['success' => true, 'data' => $orders]);
    }

    public function updateStatus(UpdateStatusRequest $request, Order $order): \Illuminate\Http\JsonResponse
    {
        $vendorId = $request->user()->vendor->id;
        if ($order->vendor_id !== $vendorId) {
            return response()->json(['success' => false, 'message' => 'Forbidden'], 403);
        }

        $updates = ['status' => $request->status];
        if ($request->status === 'assigned') {
            $updates['delivery_boy_id'] = $request->delivery_boy_id;
        }

        $order->update($updates);
        return response()->json(['success' => true, 'data' => $order->fresh()]);
    }
}
