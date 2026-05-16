<?php
namespace App\Http\Controllers\Customer;

use App\Http\Controllers\Controller;
use App\Models\Vendor;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class VendorController extends Controller
{
    public function index(Request $request): \Illuminate\Http\JsonResponse
    {
        $lat = (float) $request->query('lat', 0);
        $lng = (float) $request->query('lng', 0);

        $vendors = Vendor::where('is_open', true)
            ->selectRaw("*, (
                6371 * acos(
                    cos(radians(?)) * cos(radians(lat)) *
                    cos(radians(lng) - radians(?)) +
                    sin(radians(?)) * sin(radians(lat))
                )
            ) AS distance", [$lat, $lng, $lat])
            ->having('distance', '<', DB::raw('service_radius_km'))
            ->orderBy('distance')
            ->with('user:id,name')
            ->get();

        return response()->json(['success' => true, 'data' => $vendors]);
    }
}
