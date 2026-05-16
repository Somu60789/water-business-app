<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        $this->app->bind(\App\Services\RazorpayService::class, function () {
            return new \App\Services\RazorpayService(
                keyId:     config('services.razorpay.key_id'),
                keySecret: config('services.razorpay.key_secret'),
            );
        });
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        //
    }
}
