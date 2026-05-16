<?php
namespace App\Http\Controllers\Delivery;

use App\Http\Controllers\Controller;
use App\Models\DeliveryBoyLocation;
use Illuminate\Http\Request;

class LocationController extends Controller
{
    public function update(Request $request): \Illuminate\Http\JsonResponse
    {
        $data = $request->validate([
            'lat' => ['required', 'numeric', 'between:-90,90'],
            'lng' => ['required', 'numeric', 'between:-180,180'],
        ]);

        DeliveryBoyLocation::updateOrCreate(
            ['user_id' => $request->user()->id],
            ['lat' => $data['lat'], 'lng' => $data['lng']]
        );

        return response()->json(['success' => true]);
    }
}
