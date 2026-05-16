<?php
namespace App\Http\Requests\Order;

use Illuminate\Foundation\Http\FormRequest;

class UpdateStatusRequest extends FormRequest
{
    public function authorize(): bool { return true; }

    public function rules(): array
    {
        $user = $this->user();

        if ($user && $user->role === 'delivery_boy') {
            $allowed = ['out_for_delivery', 'delivered'];
        } else {
            // vendor (and admin fallback)
            $allowed = ['accepted', 'cancelled', 'assigned'];
        }

        return [
            'status'          => ['required', 'in:' . implode(',', $allowed)],
            'delivery_boy_id' => ['required_if:status,assigned', 'nullable', 'exists:users,id'],
        ];
    }
}
