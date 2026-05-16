<?php
namespace App\Http\Requests\Order;

use Illuminate\Foundation\Http\FormRequest;

class UpdateStatusRequest extends FormRequest
{
    public function authorize(): bool { return true; }

    public function rules(): array
    {
        $vendorStatuses   = ['accepted', 'cancelled', 'assigned'];
        $deliveryStatuses = ['out_for_delivery', 'delivered'];

        return [
            'status'          => ['required', 'in:' . implode(',', array_merge($vendorStatuses, $deliveryStatuses))],
            'delivery_boy_id' => ['required_if:status,assigned', 'exists:users,id'],
        ];
    }
}
