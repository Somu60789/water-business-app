<?php
namespace App\Services;

use App\Models\Order;
use App\Models\Subscription;
use Carbon\Carbon;

class SubscriptionSchedulerService
{
    public function generateDueOrders(Carbon $date): int
    {
        $count         = 0;
        $subscriptions = Subscription::with(['product'])
            ->where('is_active', true)
            ->whereDate('next_delivery_date', '<=', $date)
            ->get();

        foreach ($subscriptions as $sub) {
            Order::create([
                'customer_id'         => $sub->customer_id,
                'vendor_id'           => $sub->vendor_id,
                'delivery_address_id' => $sub->address_id,
                'delivery_slot'       => $sub->delivery_slot,
                'payment_mode'        => $sub->payment_mode,
                'total_amount'        => $sub->product->price * $sub->qty,
                'otp'                 => str_pad((string) random_int(0, 999999), 6, '0', STR_PAD_LEFT),
            ])->items()->create([
                'product_id' => $sub->product_id,
                'qty'        => $sub->qty,
                'unit_price' => $sub->product->price,
            ]);

            $next = $this->calculateNextDate($sub->frequency, $sub->day_of_week, $sub->day_of_month, $date);
            $sub->update(['next_delivery_date' => $next]);
            $count++;
        }

        return $count;
    }

    public function calculateNextDate(string $frequency, ?int $dayOfWeek, ?int $dayOfMonth, Carbon $from): Carbon
    {
        return match ($frequency) {
            'daily'   => $from->copy()->addDay(),
            'weekly'  => $this->nextWeekday($from, $dayOfWeek ?? 1),
            'monthly' => $from->copy()->addMonthNoOverflow()->setDay($dayOfMonth ?? 1),
            default   => $from->copy()->addDay(),
        };
    }

    private function nextWeekday(Carbon $from, int $dayOfWeek): Carbon
    {
        $next = $from->copy()->addDay();
        while ($next->dayOfWeek !== $dayOfWeek) {
            $next->addDay();
        }
        return $next;
    }
}
