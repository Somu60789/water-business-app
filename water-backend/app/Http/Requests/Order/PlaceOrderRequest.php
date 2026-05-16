<?php
namespace App\Http\Requests\Order;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class PlaceOrderRequest extends FormRequest
{
    public function authorize(): bool { return true; }

    public function rules(): array
    {
        return [
            'vendor_id'          => ['required', 'exists:vendors,id'],
            'address_id'         => ['required', Rule::exists('addresses', 'id')->where('user_id', $this->user()->id)],
            'delivery_slot'      => ['required', 'in:morning,afternoon,evening'],
            'payment_mode'       => ['required', 'in:cod,online'],
            'items'              => ['required', 'array', 'min:1'],
            'items.*.product_id' => ['required', 'exists:products,id'],
            'items.*.qty'        => ['required', 'integer', 'min:1'],
            'notes'              => ['nullable', 'string'],
        ];
    }
}
