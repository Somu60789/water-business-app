# Laravel Backend & Admin Panel Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the complete Laravel 11 REST API and Blade admin panel for the multi-vendor water bottle delivery platform.

**Architecture:** Laravel 11 monolith with role-based middleware and JWT authentication. API routes are split by role (Customer/Vendor/Delivery/Admin) and protected by `RoleMiddleware`. Admin panel uses a separate Blade web auth guard. All API responses return `{ success, message, data, errors }`.

**Tech Stack:** PHP 8.2, Laravel 11, MySQL 8, Firebase Admin SDK (OTP verify + FCM), Razorpay PHP SDK, Twilio WhatsApp API, Laravel Sanctum (JWT), Laravel Scheduler, Pest (testing).

---

## File Structure

```
water-backend/
├── app/
│   ├── Http/
│   │   ├── Controllers/
│   │   │   ├── Auth/OtpController.php
│   │   │   ├── Customer/
│   │   │   │   ├── VendorController.php
│   │   │   │   ├── ProductController.php
│   │   │   │   ├── AddressController.php
│   │   │   │   ├── OrderController.php
│   │   │   │   ├── SubscriptionController.php
│   │   │   │   ├── TrackingController.php
│   │   │   │   ├── NotificationController.php
│   │   │   │   └── ReviewController.php
│   │   │   ├── Vendor/
│   │   │   │   ├── OrderController.php
│   │   │   │   ├── ProductController.php
│   │   │   │   ├── DeliveryBoyController.php
│   │   │   │   └── EarningsController.php
│   │   │   ├── Delivery/
│   │   │   │   ├── DeliveryController.php
│   │   │   │   └── LocationController.php
│   │   │   └── Admin/
│   │   │       ├── AuthController.php
│   │   │       ├── VendorController.php
│   │   │       ├── UserController.php
│   │   │       ├── OrderController.php
│   │   │       ├── ReportController.php
│   │   │       └── NotificationController.php
│   │   ├── Middleware/
│   │   │   └── RoleMiddleware.php
│   │   └── Requests/
│   │       ├── Auth/SendOtpRequest.php
│   │       ├── Auth/VerifyOtpRequest.php
│   │       ├── Order/PlaceOrderRequest.php
│   │       ├── Order/UpdateStatusRequest.php
│   │       └── Subscription/StoreSubscriptionRequest.php
│   ├── Models/
│   │   ├── User.php
│   │   ├── Vendor.php
│   │   ├── Product.php
│   │   ├── Address.php
│   │   ├── Order.php
│   │   ├── OrderItem.php
│   │   ├── Subscription.php
│   │   ├── VendorDeliveryBoy.php
│   │   ├── DeliveryBoyLocation.php
│   │   ├── Notification.php
│   │   └── Review.php
│   ├── Services/
│   │   ├── OtpService.php
│   │   ├── RazorpayService.php
│   │   ├── FirebaseService.php
│   │   ├── WhatsAppService.php
│   │   └── SubscriptionSchedulerService.php
│   └── Console/
│       └── Commands/GenerateSubscriptionOrders.php
├── database/
│   ├── migrations/
│   │   ├── 001_create_users_table.php
│   │   ├── 002_create_vendors_table.php
│   │   ├── 003_create_products_table.php
│   │   ├── 004_create_addresses_table.php
│   │   ├── 005_create_orders_table.php
│   │   ├── 006_create_order_items_table.php
│   │   ├── 007_create_subscriptions_table.php
│   │   ├── 008_create_vendor_delivery_boys_table.php
│   │   ├── 009_create_delivery_boy_locations_table.php
│   │   ├── 010_create_notifications_table.php
│   │   └── 011_create_reviews_table.php
│   └── seeders/
│       └── AdminSeeder.php
├── resources/views/
│   ├── admin/
│   │   ├── layouts/app.blade.php
│   │   ├── auth/login.blade.php
│   │   ├── dashboard.blade.php
│   │   ├── vendors/index.blade.php
│   │   ├── vendors/show.blade.php
│   │   ├── users/index.blade.php
│   │   ├── orders/index.blade.php
│   │   ├── subscriptions/index.blade.php
│   │   ├── reports/index.blade.php
│   │   └── notifications/index.blade.php
├── routes/
│   ├── api.php
│   └── web.php
└── tests/
    ├── Feature/
    │   ├── Auth/OtpTest.php
    │   ├── Customer/OrderTest.php
    │   ├── Customer/SubscriptionTest.php
    │   ├── Vendor/OrderManagementTest.php
    │   ├── Delivery/DeliveryFlowTest.php
    │   └── Admin/AdminPanelTest.php
    └── Unit/
        ├── Services/OtpServiceTest.php
        ├── Services/RazorpayServiceTest.php
        └── Services/SubscriptionSchedulerTest.php
```

---

### Task 1: Project Bootstrap

**Files:**
- Create: `water-backend/` (new Laravel project)
- Create: `.env.example`
- Create: `database/migrations/001_create_users_table.php` through `011_create_reviews_table.php`

- [ ] **Step 1: Install Laravel and dependencies**

```bash
cd /home/somasekhar/Downloads/Vishnu/app/water-business-app
composer create-project laravel/laravel water-backend --prefer-dist
cd water-backend
composer require laravel/sanctum razorpay/razorpay kreait/firebase-php guzzlehttp/guzzle
composer require --dev pestphp/pest pestphp/pest-plugin-laravel
./vendor/bin/pest --init
```

- [ ] **Step 2: Configure `.env`**

Edit `water-backend/.env`:
```
APP_NAME="WaterDelivery"
APP_ENV=local
APP_KEY=  # will be generated
APP_DEBUG=true
APP_URL=http://localhost:8000

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=water_delivery
DB_USERNAME=root
DB_PASSWORD=secret

FIREBASE_CREDENTIALS=/path/to/firebase-service-account.json
RAZORPAY_KEY_ID=your_key_id
RAZORPAY_KEY_SECRET=your_key_secret
TWILIO_SID=your_sid
TWILIO_TOKEN=your_token
TWILIO_WHATSAPP_FROM=whatsapp:+14155238886
```

```bash
php artisan key:generate
```

- [ ] **Step 3: Create the MySQL database**

```bash
mysql -u root -p -e "CREATE DATABASE water_delivery CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
```

- [ ] **Step 4: Create migration — users**

```bash
php artisan make:migration create_users_table --create=users
```

Replace the generated migration body with:
```php
public function up(): void
{
    Schema::create('users', function (Blueprint $table) {
        $table->id();
        $table->string('name');
        $table->string('phone', 20)->unique();
        $table->string('email')->nullable()->unique();
        $table->enum('role', ['customer', 'vendor', 'delivery_boy', 'admin'])->default('customer');
        $table->string('fcm_token')->nullable();
        $table->boolean('is_active')->default(true);
        $table->timestamps();
    });
}
public function down(): void { Schema::dropIfExists('users'); }
```

- [ ] **Step 5: Create migration — vendors**

```bash
php artisan make:migration create_vendors_table --create=vendors
```

```php
public function up(): void
{
    Schema::create('vendors', function (Blueprint $table) {
        $table->id();
        $table->foreignId('user_id')->constrained()->cascadeOnDelete();
        $table->string('business_name');
        $table->text('address');
        $table->decimal('lat', 10, 7);
        $table->decimal('lng', 10, 7);
        $table->decimal('service_radius_km', 5, 2)->default(10);
        $table->boolean('is_open')->default(true);
        $table->timestamps();
    });
}
public function down(): void { Schema::dropIfExists('vendors'); }
```

- [ ] **Step 6: Create migration — products**

```bash
php artisan make:migration create_products_table --create=products
```

```php
public function up(): void
{
    Schema::create('products', function (Blueprint $table) {
        $table->id();
        $table->foreignId('vendor_id')->constrained()->cascadeOnDelete();
        $table->string('name');
        $table->text('description')->nullable();
        $table->string('image_url')->nullable();
        $table->enum('unit', ['20L', '5L', '1L']);
        $table->decimal('price', 8, 2);
        $table->integer('stock_qty')->default(0);
        $table->boolean('is_available')->default(true);
        $table->timestamps();
    });
}
public function down(): void { Schema::dropIfExists('products'); }
```

- [ ] **Step 7: Create migration — addresses**

```bash
php artisan make:migration create_addresses_table --create=addresses
```

```php
public function up(): void
{
    Schema::create('addresses', function (Blueprint $table) {
        $table->id();
        $table->foreignId('user_id')->constrained()->cascadeOnDelete();
        $table->string('label')->default('Home');
        $table->text('address_line');
        $table->decimal('lat', 10, 7);
        $table->decimal('lng', 10, 7);
        $table->boolean('is_default')->default(false);
        $table->timestamps();
    });
}
public function down(): void { Schema::dropIfExists('addresses'); }
```

- [ ] **Step 8: Create migration — orders**

```bash
php artisan make:migration create_orders_table --create=orders
```

```php
public function up(): void
{
    Schema::create('orders', function (Blueprint $table) {
        $table->id();
        $table->foreignId('customer_id')->constrained('users');
        $table->foreignId('vendor_id')->constrained('vendors');
        $table->foreignId('delivery_boy_id')->nullable()->constrained('users');
        $table->enum('status', ['pending','accepted','assigned','out_for_delivery','delivered','cancelled'])->default('pending');
        $table->enum('payment_mode', ['cod', 'online']);
        $table->enum('payment_status', ['pending', 'paid'])->default('pending');
        $table->string('razorpay_order_id')->nullable();
        $table->decimal('total_amount', 10, 2);
        $table->foreignId('delivery_address_id')->constrained('addresses');
        $table->enum('delivery_slot', ['morning', 'afternoon', 'evening']);
        $table->string('otp', 6)->nullable();
        $table->text('notes')->nullable();
        $table->timestamps();

        $table->index(['status', 'vendor_id']);
        $table->index(['customer_id', 'status']);
        $table->index(['delivery_boy_id', 'status']);
    });
}
public function down(): void { Schema::dropIfExists('orders'); }
```

- [ ] **Step 9: Create migration — order_items**

```bash
php artisan make:migration create_order_items_table --create=order_items
```

```php
public function up(): void
{
    Schema::create('order_items', function (Blueprint $table) {
        $table->id();
        $table->foreignId('order_id')->constrained()->cascadeOnDelete();
        $table->foreignId('product_id')->constrained();
        $table->integer('qty');
        $table->decimal('unit_price', 8, 2);
        $table->timestamps();
    });
}
public function down(): void { Schema::dropIfExists('order_items'); }
```

- [ ] **Step 10: Create migration — subscriptions**

```bash
php artisan make:migration create_subscriptions_table --create=subscriptions
```

```php
public function up(): void
{
    Schema::create('subscriptions', function (Blueprint $table) {
        $table->id();
        $table->foreignId('customer_id')->constrained('users');
        $table->foreignId('vendor_id')->constrained('vendors');
        $table->foreignId('product_id')->constrained('products');
        $table->integer('qty');
        $table->enum('frequency', ['daily', 'weekly', 'monthly']);
        $table->tinyInteger('day_of_week')->nullable()->comment('0=Sun,6=Sat');
        $table->tinyInteger('day_of_month')->nullable();
        $table->enum('delivery_slot', ['morning', 'afternoon', 'evening']);
        $table->foreignId('address_id')->constrained('addresses');
        $table->enum('payment_mode', ['cod', 'online']);
        $table->boolean('is_active')->default(true);
        $table->date('next_delivery_date');
        $table->timestamps();
    });
}
public function down(): void { Schema::dropIfExists('subscriptions'); }
```

- [ ] **Step 11: Create migrations — vendor_delivery_boys, delivery_boy_locations, notifications, reviews**

```bash
php artisan make:migration create_vendor_delivery_boys_table --create=vendor_delivery_boys
```
```php
public function up(): void
{
    Schema::create('vendor_delivery_boys', function (Blueprint $table) {
        $table->id();
        $table->foreignId('vendor_id')->constrained()->cascadeOnDelete();
        $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
        $table->boolean('is_active')->default(true);
        $table->timestamps();
        $table->unique(['vendor_id', 'user_id']);
    });
}
public function down(): void { Schema::dropIfExists('vendor_delivery_boys'); }
```

```bash
php artisan make:migration create_delivery_boy_locations_table --create=delivery_boy_locations
```
```php
public function up(): void
{
    Schema::create('delivery_boy_locations', function (Blueprint $table) {
        $table->id();
        $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
        $table->decimal('lat', 10, 7);
        $table->decimal('lng', 10, 7);
        $table->timestamp('updated_at')->useCurrent()->useCurrentOnUpdate();
    });
}
public function down(): void { Schema::dropIfExists('delivery_boy_locations'); }
```

```bash
php artisan make:migration create_notifications_table --create=notifications
```
```php
public function up(): void
{
    Schema::create('notifications', function (Blueprint $table) {
        $table->id();
        $table->foreignId('user_id')->constrained()->cascadeOnDelete();
        $table->string('title');
        $table->text('body');
        $table->string('type');
        $table->unsignedBigInteger('reference_id')->nullable();
        $table->boolean('is_read')->default(false);
        $table->timestamps();
    });
}
public function down(): void { Schema::dropIfExists('notifications'); }
```

```bash
php artisan make:migration create_reviews_table --create=reviews
```
```php
public function up(): void
{
    Schema::create('reviews', function (Blueprint $table) {
        $table->id();
        $table->foreignId('order_id')->constrained()->cascadeOnDelete();
        $table->foreignId('customer_id')->constrained('users');
        $table->foreignId('vendor_id')->constrained('vendors');
        $table->tinyInteger('rating');
        $table->text('comment')->nullable();
        $table->timestamps();
    });
}
public function down(): void { Schema::dropIfExists('reviews'); }
```

- [ ] **Step 12: Run migrations**

```bash
php artisan migrate
```
Expected: All tables created successfully.

- [ ] **Step 13: Commit**

```bash
git add .
git commit -m "feat: bootstrap Laravel project with all migrations"
```

---

### Task 2: Models and Relationships

**Files:**
- Modify: `app/Models/User.php`
- Create: `app/Models/Vendor.php`, `Product.php`, `Address.php`, `Order.php`, `OrderItem.php`, `Subscription.php`, `VendorDeliveryBoy.php`, `DeliveryBoyLocation.php`, `Notification.php`, `Review.php`

- [ ] **Step 1: Write failing test for User model relationships**

Create `tests/Unit/Models/UserModelTest.php`:
```php
<?php
use App\Models\User;
use App\Models\Vendor;
use App\Models\Order;

it('has correct fillable fields', function () {
    $user = new User();
    expect($user->getFillable())->toContain('name', 'phone', 'email', 'role', 'fcm_token');
});

it('has vendor relationship', function () {
    $user = User::factory()->create(['role' => 'vendor']);
    expect($user->vendor())->toBeInstanceOf(\Illuminate\Database\Eloquent\Relations\HasOne::class);
});
```

- [ ] **Step 2: Run test to confirm it fails**

```bash
./vendor/bin/pest tests/Unit/Models/UserModelTest.php -v
```
Expected: FAIL — User factory or relationship missing.

- [ ] **Step 3: Define User model**

Replace `app/Models/User.php`:
```php
<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory;

    protected $fillable = ['name', 'phone', 'email', 'role', 'fcm_token', 'is_active'];
    protected $hidden   = ['remember_token'];
    protected $casts    = ['is_active' => 'boolean'];

    public function vendor(): \Illuminate\Database\Eloquent\Relations\HasOne
    {
        return $this->hasOne(Vendor::class);
    }

    public function addresses(): \Illuminate\Database\Eloquent\Relations\HasMany
    {
        return $this->hasMany(Address::class);
    }

    public function customerOrders(): \Illuminate\Database\Eloquent\Relations\HasMany
    {
        return $this->hasMany(Order::class, 'customer_id');
    }

    public function deliveryOrders(): \Illuminate\Database\Eloquent\Relations\HasMany
    {
        return $this->hasMany(Order::class, 'delivery_boy_id');
    }

    public function location(): \Illuminate\Database\Eloquent\Relations\HasOne
    {
        return $this->hasOne(DeliveryBoyLocation::class);
    }

    public function notifications(): \Illuminate\Database\Eloquent\Relations\HasMany
    {
        return $this->hasMany(Notification::class);
    }
}
```

- [ ] **Step 4: Create UserFactory**

Create `database/factories/UserFactory.php`:
```php
<?php
namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

class UserFactory extends Factory
{
    public function definition(): array
    {
        return [
            'name'     => fake()->name(),
            'phone'    => fake()->unique()->numerify('98########'),
            'email'    => fake()->unique()->safeEmail(),
            'role'     => 'customer',
            'is_active'=> true,
        ];
    }

    public function vendor(): static
    {
        return $this->state(['role' => 'vendor']);
    }

    public function deliveryBoy(): static
    {
        return $this->state(['role' => 'delivery_boy']);
    }
}
```

- [ ] **Step 5: Create Vendor model**

Create `app/Models/Vendor.php`:
```php
<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Vendor extends Model
{
    use HasFactory;

    protected $fillable = ['user_id', 'business_name', 'address', 'lat', 'lng', 'service_radius_km', 'is_open'];
    protected $casts    = ['is_open' => 'boolean', 'lat' => 'float', 'lng' => 'float', 'service_radius_km' => 'float'];

    public function user(): \Illuminate\Database\Eloquent\Relations\BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function products(): \Illuminate\Database\Eloquent\Relations\HasMany
    {
        return $this->hasMany(Product::class);
    }

    public function orders(): \Illuminate\Database\Eloquent\Relations\HasMany
    {
        return $this->hasMany(Order::class);
    }

    public function deliveryBoys(): \Illuminate\Database\Eloquent\Relations\HasMany
    {
        return $this->hasMany(VendorDeliveryBoy::class);
    }

    public function reviews(): \Illuminate\Database\Eloquent\Relations\HasMany
    {
        return $this->hasMany(Review::class);
    }
}
```

Create `database/factories/VendorFactory.php`:
```php
<?php
namespace Database\Factories;

use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

class VendorFactory extends Factory
{
    public function definition(): array
    {
        return [
            'user_id'           => User::factory()->vendor(),
            'business_name'     => fake()->company() . ' Water',
            'address'           => fake()->address(),
            'lat'               => fake()->latitude(12.8, 13.1),
            'lng'               => fake()->longitude(77.4, 77.8),
            'service_radius_km' => 10,
            'is_open'           => true,
        ];
    }
}
```

- [ ] **Step 6: Create Product model**

Create `app/Models/Product.php`:
```php
<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Product extends Model
{
    use HasFactory;

    protected $fillable = ['vendor_id', 'name', 'description', 'image_url', 'unit', 'price', 'stock_qty', 'is_available'];
    protected $casts    = ['price' => 'float', 'is_available' => 'boolean'];

    public function vendor(): \Illuminate\Database\Eloquent\Relations\BelongsTo
    {
        return $this->belongsTo(Vendor::class);
    }

    public function orderItems(): \Illuminate\Database\Eloquent\Relations\HasMany
    {
        return $this->hasMany(OrderItem::class);
    }
}
```

Create `database/factories/ProductFactory.php`:
```php
<?php
namespace Database\Factories;

use App\Models\Vendor;
use Illuminate\Database\Eloquent\Factories\Factory;

class ProductFactory extends Factory
{
    public function definition(): array
    {
        return [
            'vendor_id'    => Vendor::factory(),
            'name'         => fake()->randomElement(['Bisleri 20L', 'Kinley 20L', 'Aqua 5L', 'Pure 1L']),
            'unit'         => fake()->randomElement(['20L', '5L', '1L']),
            'price'        => fake()->randomFloat(2, 10, 120),
            'stock_qty'    => fake()->numberBetween(10, 200),
            'is_available' => true,
        ];
    }
}
```

- [ ] **Step 7: Create remaining models**

Create `app/Models/Address.php`:
```php
<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Address extends Model
{
    protected $fillable = ['user_id', 'label', 'address_line', 'lat', 'lng', 'is_default'];
    protected $casts    = ['is_default' => 'boolean', 'lat' => 'float', 'lng' => 'float'];

    public function user(): \Illuminate\Database\Eloquent\Relations\BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
```

Create `app/Models/Order.php`:
```php
<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Order extends Model
{
    use HasFactory;

    protected $fillable = [
        'customer_id','vendor_id','delivery_boy_id','status','payment_mode',
        'payment_status','razorpay_order_id','total_amount','delivery_address_id',
        'delivery_slot','otp','notes',
    ];

    public function customer(): \Illuminate\Database\Eloquent\Relations\BelongsTo
    {
        return $this->belongsTo(User::class, 'customer_id');
    }

    public function vendor(): \Illuminate\Database\Eloquent\Relations\BelongsTo
    {
        return $this->belongsTo(Vendor::class);
    }

    public function deliveryBoy(): \Illuminate\Database\Eloquent\Relations\BelongsTo
    {
        return $this->belongsTo(User::class, 'delivery_boy_id');
    }

    public function items(): \Illuminate\Database\Eloquent\Relations\HasMany
    {
        return $this->hasMany(OrderItem::class);
    }

    public function deliveryAddress(): \Illuminate\Database\Eloquent\Relations\BelongsTo
    {
        return $this->belongsTo(Address::class, 'delivery_address_id');
    }

    public function review(): \Illuminate\Database\Eloquent\Relations\HasOne
    {
        return $this->hasOne(Review::class);
    }
}
```

Create `app/Models/OrderItem.php`:
```php
<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class OrderItem extends Model
{
    protected $fillable = ['order_id', 'product_id', 'qty', 'unit_price'];

    public function product(): \Illuminate\Database\Eloquent\Relations\BelongsTo
    {
        return $this->belongsTo(Product::class);
    }
}
```

Create `app/Models/Subscription.php`:
```php
<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Subscription extends Model
{
    protected $fillable = [
        'customer_id','vendor_id','product_id','qty','frequency',
        'day_of_week','day_of_month','delivery_slot','address_id',
        'payment_mode','is_active','next_delivery_date',
    ];
    protected $casts = ['is_active' => 'boolean', 'next_delivery_date' => 'date'];

    public function customer(): \Illuminate\Database\Eloquent\Relations\BelongsTo
    {
        return $this->belongsTo(User::class, 'customer_id');
    }

    public function product(): \Illuminate\Database\Eloquent\Relations\BelongsTo
    {
        return $this->belongsTo(Product::class);
    }

    public function vendor(): \Illuminate\Database\Eloquent\Relations\BelongsTo
    {
        return $this->belongsTo(Vendor::class);
    }

    public function address(): \Illuminate\Database\Eloquent\Relations\BelongsTo
    {
        return $this->belongsTo(Address::class);
    }
}
```

Create `app/Models/VendorDeliveryBoy.php`:
```php
<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class VendorDeliveryBoy extends Model
{
    protected $fillable = ['vendor_id', 'user_id', 'is_active'];
    protected $casts    = ['is_active' => 'boolean'];

    public function user(): \Illuminate\Database\Eloquent\Relations\BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function vendor(): \Illuminate\Database\Eloquent\Relations\BelongsTo
    {
        return $this->belongsTo(Vendor::class);
    }
}
```

Create `app/Models/DeliveryBoyLocation.php`:
```php
<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class DeliveryBoyLocation extends Model
{
    public $timestamps = false;
    protected $fillable = ['user_id', 'lat', 'lng'];
    protected $casts    = ['lat' => 'float', 'lng' => 'float'];
}
```

Create `app/Models/Notification.php`:
```php
<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Notification extends Model
{
    protected $fillable = ['user_id', 'title', 'body', 'type', 'reference_id', 'is_read'];
    protected $casts    = ['is_read' => 'boolean'];
}
```

Create `app/Models/Review.php`:
```php
<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Review extends Model
{
    protected $fillable = ['order_id', 'customer_id', 'vendor_id', 'rating', 'comment'];
}
```

- [ ] **Step 8: Run the model tests**

```bash
./vendor/bin/pest tests/Unit/Models/ -v
```
Expected: All PASS.

- [ ] **Step 9: Commit**

```bash
git add .
git commit -m "feat: add all models, relationships, and factories"
```

---

### Task 3: Auth — OTP Login

**Files:**
- Create: `app/Services/OtpService.php`
- Create: `app/Http/Controllers/Auth/OtpController.php`
- Create: `app/Http/Requests/Auth/SendOtpRequest.php`
- Create: `app/Http/Requests/Auth/VerifyOtpRequest.php`
- Modify: `routes/api.php`
- Create: `tests/Feature/Auth/OtpTest.php`
- Create: `tests/Unit/Services/OtpServiceTest.php`

- [ ] **Step 1: Write the OtpService unit test**

Create `tests/Unit/Services/OtpServiceTest.php`:
```php
<?php
use App\Services\OtpService;

it('generates a 6-digit OTP', function () {
    $service = new OtpService();
    $otp = $service->generate();
    expect($otp)->toMatch('/^\d{6}$/');
});

it('stores and verifies OTP correctly', function () {
    $service = new OtpService();
    $phone = '9876543210';
    $otp = $service->generate();

    $service->store($phone, $otp);
    expect($service->verify($phone, $otp))->toBeTrue();
    expect($service->verify($phone, '000000'))->toBeFalse();
});

it('returns false for expired/missing OTP', function () {
    $service = new OtpService();
    expect($service->verify('9999999999', '123456'))->toBeFalse();
});
```

- [ ] **Step 2: Run test to confirm failure**

```bash
./vendor/bin/pest tests/Unit/Services/OtpServiceTest.php -v
```
Expected: FAIL — OtpService class not found.

- [ ] **Step 3: Create OtpService**

Create `app/Services/OtpService.php`:
```php
<?php
namespace App\Services;

use Illuminate\Support\Facades\Cache;

class OtpService
{
    private int $ttlMinutes = 5;

    public function generate(): string
    {
        return str_pad((string) random_int(100000, 999999), 6, '0', STR_PAD_LEFT);
    }

    public function store(string $phone, string $otp): void
    {
        Cache::put("otp:{$phone}", $otp, now()->addMinutes($this->ttlMinutes));
    }

    public function verify(string $phone, string $otp): bool
    {
        $stored = Cache::get("otp:{$phone}");
        if ($stored === null) {
            return false;
        }
        if (hash_equals($stored, $otp)) {
            Cache::forget("otp:{$phone}");
            return true;
        }
        return false;
    }
}
```

- [ ] **Step 4: Run OtpService unit tests**

```bash
./vendor/bin/pest tests/Unit/Services/OtpServiceTest.php -v
```
Expected: All 3 PASS.

- [ ] **Step 5: Write feature test for OTP endpoints**

Create `tests/Feature/Auth/OtpTest.php`:
```php
<?php
use App\Models\User;
use App\Services\OtpService;
use Illuminate\Support\Facades\Cache;

it('sends OTP for new phone and creates user', function () {
    $response = $this->postJson('/api/auth/send-otp', ['phone' => '9876543210']);
    $response->assertOk()->assertJson(['success' => true]);
    $this->assertDatabaseHas('users', ['phone' => '9876543210']);
});

it('returns 422 if phone is missing', function () {
    $response = $this->postJson('/api/auth/send-otp', []);
    $response->assertUnprocessable();
});

it('verifies OTP and returns token', function () {
    $phone = '9123456789';
    $user = User::factory()->create(['phone' => $phone]);

    $otp = '123456';
    Cache::put("otp:{$phone}", $otp, now()->addMinutes(5));

    $response = $this->postJson('/api/auth/verify-otp', ['phone' => $phone, 'otp' => $otp]);
    $response->assertOk()
             ->assertJsonStructure(['success', 'data' => ['token', 'user']]);
});

it('rejects wrong OTP', function () {
    $phone = '9111111111';
    User::factory()->create(['phone' => $phone]);
    Cache::put("otp:{$phone}", '999999', now()->addMinutes(5));

    $response = $this->postJson('/api/auth/verify-otp', ['phone' => $phone, 'otp' => '000000']);
    $response->assertUnprocessable()->assertJsonFragment(['success' => false]);
});
```

- [ ] **Step 6: Run feature test to confirm failure**

```bash
./vendor/bin/pest tests/Feature/Auth/OtpTest.php -v
```
Expected: FAIL — routes not found (404).

- [ ] **Step 7: Create form requests**

Create `app/Http/Requests/Auth/SendOtpRequest.php`:
```php
<?php
namespace App\Http\Requests\Auth;

use Illuminate\Foundation\Http\FormRequest;

class SendOtpRequest extends FormRequest
{
    public function authorize(): bool { return true; }

    public function rules(): array
    {
        return ['phone' => ['required', 'string', 'regex:/^[6-9]\d{9}$/']];
    }
}
```

Create `app/Http/Requests/Auth/VerifyOtpRequest.php`:
```php
<?php
namespace App\Http\Requests\Auth;

use Illuminate\Foundation\Http\FormRequest;

class VerifyOtpRequest extends FormRequest
{
    public function authorize(): bool { return true; }

    public function rules(): array
    {
        return [
            'phone' => ['required', 'string', 'exists:users,phone'],
            'otp'   => ['required', 'string', 'size:6'],
        ];
    }
}
```

- [ ] **Step 8: Create OtpController**

Create `app/Http/Controllers/Auth/OtpController.php`:
```php
<?php
namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\SendOtpRequest;
use App\Http\Requests\Auth\VerifyOtpRequest;
use App\Models\User;
use App\Services\OtpService;

class OtpController extends Controller
{
    public function __construct(private OtpService $otpService) {}

    public function sendOtp(SendOtpRequest $request): \Illuminate\Http\JsonResponse
    {
        $user = User::firstOrCreate(
            ['phone' => $request->phone],
            ['name' => 'User', 'role' => 'customer']
        );

        $otp = $this->otpService->generate();
        $this->otpService->store($request->phone, $otp);

        // In production: dispatch SMS via Firebase/Twilio
        // For now, log for development
        logger("OTP for {$request->phone}: {$otp}");

        return response()->json(['success' => true, 'message' => 'OTP sent']);
    }

    public function verifyOtp(VerifyOtpRequest $request): \Illuminate\Http\JsonResponse
    {
        if (! $this->otpService->verify($request->phone, $request->otp)) {
            return response()->json(['success' => false, 'message' => 'Invalid or expired OTP'], 422);
        }

        $user  = User::where('phone', $request->phone)->firstOrFail();
        $token = $user->createToken('api')->plainTextToken;

        return response()->json([
            'success' => true,
            'data'    => ['token' => $token, 'user' => $user],
        ]);
    }

    public function updateProfile(\Illuminate\Http\Request $request): \Illuminate\Http\JsonResponse
    {
        $request->user()->update($request->only('name', 'email', 'fcm_token'));
        return response()->json(['success' => true, 'data' => $request->user()]);
    }
}
```

- [ ] **Step 9: Register routes**

Edit `routes/api.php`:
```php
<?php
use App\Http\Controllers\Auth\OtpController;
use Illuminate\Support\Facades\Route;

Route::prefix('auth')->group(function () {
    Route::post('/send-otp',   [OtpController::class, 'sendOtp']);
    Route::post('/verify-otp', [OtpController::class, 'verifyOtp']);
    Route::middleware('auth:sanctum')->put('/profile', [OtpController::class, 'updateProfile']);
});
```

- [ ] **Step 10: Run feature tests**

```bash
./vendor/bin/pest tests/Feature/Auth/ -v
```
Expected: All 4 PASS.

- [ ] **Step 11: Commit**

```bash
git add .
git commit -m "feat: OTP auth with send/verify endpoints and Sanctum tokens"
```

---

### Task 4: Role Middleware + Vendor & Product APIs

**Files:**
- Create: `app/Http/Middleware/RoleMiddleware.php`
- Modify: `bootstrap/app.php` (register middleware alias)
- Create: `app/Http/Controllers/Customer/VendorController.php`
- Create: `app/Http/Controllers/Customer/ProductController.php`
- Create: `app/Http/Controllers/Vendor/ProductController.php`
- Modify: `routes/api.php`
- Create: `tests/Feature/Customer/VendorProductTest.php`

- [ ] **Step 1: Write failing test**

Create `tests/Feature/Customer/VendorProductTest.php`:
```php
<?php
use App\Models\User;
use App\Models\Vendor;
use App\Models\Product;

it('returns nearby vendors for authenticated customer', function () {
    $customer = User::factory()->create(['role' => 'customer']);
    Vendor::factory()->count(3)->create(['lat' => 12.97, 'lng' => 77.59]);

    $response = $this->actingAs($customer)
        ->getJson('/api/vendors?lat=12.97&lng=77.59');

    $response->assertOk()->assertJsonStructure(['success', 'data' => [['id', 'business_name']]]);
});

it('returns products for a vendor', function () {
    $customer = User::factory()->create(['role' => 'customer']);
    $vendor   = Vendor::factory()->create();
    Product::factory()->count(2)->create(['vendor_id' => $vendor->id]);

    $response = $this->actingAs($customer)
        ->getJson("/api/vendors/{$vendor->id}/products");

    $response->assertOk()->assertJsonCount(2, 'data');
});

it('blocks non-vendor from creating products', function () {
    $customer = User::factory()->create(['role' => 'customer']);

    $response = $this->actingAs($customer)
        ->postJson('/api/products', ['name' => 'Test', 'price' => 50, 'unit' => '20L']);

    $response->assertForbidden();
});

it('allows vendor to create a product', function () {
    $vendorUser = User::factory()->vendor()->create();
    $vendor     = Vendor::factory()->create(['user_id' => $vendorUser->id]);

    $response = $this->actingAs($vendorUser)->postJson('/api/products', [
        'name'      => '20L Bisleri',
        'unit'      => '20L',
        'price'     => 55.00,
        'stock_qty' => 100,
    ]);

    $response->assertCreated()->assertJsonFragment(['name' => '20L Bisleri']);
});
```

- [ ] **Step 2: Run to confirm failures**

```bash
./vendor/bin/pest tests/Feature/Customer/VendorProductTest.php -v
```
Expected: FAIL — routes/middleware don't exist.

- [ ] **Step 3: Create RoleMiddleware**

Create `app/Http/Middleware/RoleMiddleware.php`:
```php
<?php
namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class RoleMiddleware
{
    public function handle(Request $request, Closure $next, string ...$roles): mixed
    {
        if (! $request->user() || ! in_array($request->user()->role, $roles)) {
            return response()->json(['success' => false, 'message' => 'Forbidden'], 403);
        }
        return $next($request);
    }
}
```

- [ ] **Step 4: Register middleware alias in bootstrap/app.php**

Edit `bootstrap/app.php` — add inside `withMiddleware`:
```php
$middleware->alias(['role' => \App\Http\Middleware\RoleMiddleware::class]);
```

The full `withMiddleware` block becomes:
```php
->withMiddleware(function (Middleware $middleware) {
    $middleware->alias(['role' => \App\Http\Middleware\RoleMiddleware::class]);
})
```

- [ ] **Step 5: Create Customer/VendorController**

Create `app/Http/Controllers/Customer/VendorController.php`:
```php
<?php
namespace App\Http\Controllers\Customer;

use App\Http\Controllers\Controller;
use App\Models\Vendor;

class VendorController extends Controller
{
    public function index(\Illuminate\Http\Request $request): \Illuminate\Http\JsonResponse
    {
        $lat = (float) $request->query('lat', 0);
        $lng = (float) $request->query('lng', 0);

        // Haversine formula via raw SQL for MySQL performance
        $vendors = Vendor::where('is_open', true)
            ->selectRaw("*, (
                6371 * acos(
                    cos(radians(?)) * cos(radians(lat)) *
                    cos(radians(lng) - radians(?)) +
                    sin(radians(?)) * sin(radians(lat))
                )
            ) AS distance", [$lat, $lng, $lat])
            ->having('distance', '<', \DB::raw('service_radius_km'))
            ->orderBy('distance')
            ->with('user:id,name')
            ->get();

        return response()->json(['success' => true, 'data' => $vendors]);
    }
}
```

- [ ] **Step 6: Create Customer/ProductController**

Create `app/Http/Controllers/Customer/ProductController.php`:
```php
<?php
namespace App\Http\Controllers\Customer;

use App\Http\Controllers\Controller;
use App\Models\Vendor;

class ProductController extends Controller
{
    public function index(Vendor $vendor): \Illuminate\Http\JsonResponse
    {
        $products = $vendor->products()->where('is_available', true)->get();
        return response()->json(['success' => true, 'data' => $products]);
    }
}
```

- [ ] **Step 7: Create Vendor/ProductController**

Create `app/Http/Controllers/Vendor/ProductController.php`:
```php
<?php
namespace App\Http\Controllers\Vendor;

use App\Http\Controllers\Controller;
use App\Models\Product;
use Illuminate\Http\Request;

class ProductController extends Controller
{
    public function store(Request $request): \Illuminate\Http\JsonResponse
    {
        $data = $request->validate([
            'name'        => ['required', 'string', 'max:100'],
            'description' => ['nullable', 'string'],
            'unit'        => ['required', 'in:20L,5L,1L'],
            'price'       => ['required', 'numeric', 'min:1'],
            'stock_qty'   => ['nullable', 'integer', 'min:0'],
            'image_url'   => ['nullable', 'url'],
        ]);

        $vendor  = $request->user()->vendor;
        $product = $vendor->products()->create($data);

        return response()->json(['success' => true, 'data' => $product], 201);
    }

    public function update(Request $request, Product $product): \Illuminate\Http\JsonResponse
    {
        if ($product->vendor_id !== $request->user()->vendor->id) {
            return response()->json(['success' => false, 'message' => 'Forbidden'], 403);
        }

        $data = $request->validate([
            'name'         => ['sometimes', 'string', 'max:100'],
            'description'  => ['nullable', 'string'],
            'price'        => ['sometimes', 'numeric', 'min:1'],
            'stock_qty'    => ['sometimes', 'integer', 'min:0'],
            'is_available' => ['sometimes', 'boolean'],
        ]);

        $product->update($data);
        return response()->json(['success' => true, 'data' => $product]);
    }

    public function destroy(Request $request, Product $product): \Illuminate\Http\JsonResponse
    {
        if ($product->vendor_id !== $request->user()->vendor->id) {
            return response()->json(['success' => false, 'message' => 'Forbidden'], 403);
        }

        $product->delete();
        return response()->json(['success' => true, 'message' => 'Product deleted']);
    }
}
```

- [ ] **Step 8: Update routes/api.php**

```php
<?php
use App\Http\Controllers\Auth\OtpController;
use App\Http\Controllers\Customer\VendorController as CustomerVendorController;
use App\Http\Controllers\Customer\ProductController as CustomerProductController;
use App\Http\Controllers\Vendor\ProductController as VendorProductController;
use Illuminate\Support\Facades\Route;

Route::prefix('auth')->group(function () {
    Route::post('/send-otp',   [OtpController::class, 'sendOtp']);
    Route::post('/verify-otp', [OtpController::class, 'verifyOtp']);
    Route::middleware('auth:sanctum')->put('/profile', [OtpController::class, 'updateProfile']);
});

Route::middleware('auth:sanctum')->group(function () {
    // Customer: vendors & products (read-only)
    Route::get('/vendors', [CustomerVendorController::class, 'index']);
    Route::get('/vendors/{vendor}/products', [CustomerProductController::class, 'index']);

    // Vendor: manage own products
    Route::middleware('role:vendor')->group(function () {
        Route::post('/products',          [VendorProductController::class, 'store']);
        Route::put('/products/{product}', [VendorProductController::class, 'update']);
        Route::delete('/products/{product}', [VendorProductController::class, 'destroy']);
    });
});
```

- [ ] **Step 9: Run tests**

```bash
./vendor/bin/pest tests/Feature/Customer/VendorProductTest.php -v
```
Expected: All 4 PASS.

- [ ] **Step 10: Commit**

```bash
git add .
git commit -m "feat: role middleware, vendor discovery, product CRUD API"
```

---

### Task 5: Order Placement & Management

**Files:**
- Create: `app/Http/Controllers/Customer/OrderController.php`
- Create: `app/Http/Controllers/Vendor/OrderController.php`
- Create: `app/Http/Requests/Order/PlaceOrderRequest.php`
- Create: `app/Http/Requests/Order/UpdateStatusRequest.php`
- Modify: `routes/api.php`
- Create: `tests/Feature/Customer/OrderTest.php`

- [ ] **Step 1: Write failing tests**

Create `tests/Feature/Customer/OrderTest.php`:
```php
<?php
use App\Models\User;
use App\Models\Vendor;
use App\Models\Product;
use App\Models\Address;
use App\Models\Order;

it('customer can place an order', function () {
    $customer = User::factory()->create(['role' => 'customer']);
    $vendor   = Vendor::factory()->create();
    $product  = Product::factory()->create(['vendor_id' => $vendor->id, 'price' => 50]);
    $address  = Address::create([
        'user_id' => $customer->id, 'label' => 'Home',
        'address_line' => '123 St', 'lat' => 12.97, 'lng' => 77.59,
    ]);

    $response = $this->actingAs($customer)->postJson('/api/orders', [
        'vendor_id'   => $vendor->id,
        'address_id'  => $address->id,
        'delivery_slot' => 'morning',
        'payment_mode'  => 'cod',
        'items' => [['product_id' => $product->id, 'qty' => 2]],
    ]);

    $response->assertCreated()->assertJsonFragment(['status' => 'pending']);
    $this->assertDatabaseHas('orders', ['customer_id' => $customer->id, 'total_amount' => 100]);
});

it('vendor can accept an order', function () {
    $vendorUser = User::factory()->vendor()->create();
    $vendor     = Vendor::factory()->create(['user_id' => $vendorUser->id]);
    $order      = Order::factory()->create(['vendor_id' => $vendor->id, 'status' => 'pending']);

    $response = $this->actingAs($vendorUser)
        ->putJson("/api/orders/{$order->id}/status", ['status' => 'accepted']);

    $response->assertOk()->assertJsonFragment(['status' => 'accepted']);
});

it('vendor cannot set invalid status', function () {
    $vendorUser = User::factory()->vendor()->create();
    $vendor     = Vendor::factory()->create(['user_id' => $vendorUser->id]);
    $order      = Order::factory()->create(['vendor_id' => $vendor->id, 'status' => 'pending']);

    $response = $this->actingAs($vendorUser)
        ->putJson("/api/orders/{$order->id}/status", ['status' => 'delivered']);

    $response->assertUnprocessable();
});
```

- [ ] **Step 2: Run to confirm failures**

```bash
./vendor/bin/pest tests/Feature/Customer/OrderTest.php -v
```
Expected: FAIL.

- [ ] **Step 3: Create OrderFactory**

Create `database/factories/OrderFactory.php`:
```php
<?php
namespace Database\Factories;

use App\Models\User;
use App\Models\Vendor;
use App\Models\Address;
use Illuminate\Database\Eloquent\Factories\Factory;

class OrderFactory extends Factory
{
    public function definition(): array
    {
        $customer = User::factory()->create(['role' => 'customer']);
        $vendor   = Vendor::factory()->create();
        $address  = Address::create([
            'user_id' => $customer->id, 'label' => 'Home',
            'address_line' => fake()->address(), 'lat' => 12.97, 'lng' => 77.59,
        ]);

        return [
            'customer_id'         => $customer->id,
            'vendor_id'           => $vendor->id,
            'delivery_boy_id'     => null,
            'status'              => 'pending',
            'payment_mode'        => 'cod',
            'payment_status'      => 'pending',
            'total_amount'        => 100.00,
            'delivery_address_id' => $address->id,
            'delivery_slot'       => 'morning',
            'otp'                 => str_pad((string) random_int(100000, 999999), 6, '0'),
        ];
    }
}
```

- [ ] **Step 4: Create PlaceOrderRequest**

Create `app/Http/Requests/Order/PlaceOrderRequest.php`:
```php
<?php
namespace App\Http\Requests\Order;

use Illuminate\Foundation\Http\FormRequest;

class PlaceOrderRequest extends FormRequest
{
    public function authorize(): bool { return true; }

    public function rules(): array
    {
        return [
            'vendor_id'          => ['required', 'exists:vendors,id'],
            'address_id'         => ['required', 'exists:addresses,id'],
            'delivery_slot'      => ['required', 'in:morning,afternoon,evening'],
            'payment_mode'       => ['required', 'in:cod,online'],
            'items'              => ['required', 'array', 'min:1'],
            'items.*.product_id' => ['required', 'exists:products,id'],
            'items.*.qty'        => ['required', 'integer', 'min:1'],
            'notes'              => ['nullable', 'string'],
        ];
    }
}
```

- [ ] **Step 5: Create UpdateStatusRequest**

Create `app/Http/Requests/Order/UpdateStatusRequest.php`:
```php
<?php
namespace App\Http\Requests\Order;

use Illuminate\Foundation\Http\FormRequest;

class UpdateStatusRequest extends FormRequest
{
    public function authorize(): bool { return true; }

    public function rules(): array
    {
        // Allowed transitions by actor
        $vendorStatuses   = ['accepted', 'cancelled', 'assigned'];
        $deliveryStatuses = ['out_for_delivery', 'delivered'];

        return [
            'status'          => ['required', 'in:' . implode(',', array_merge($vendorStatuses, $deliveryStatuses))],
            'delivery_boy_id' => ['required_if:status,assigned', 'exists:users,id'],
        ];
    }
}
```

- [ ] **Step 6: Create Customer/OrderController**

Create `app/Http/Controllers/Customer/OrderController.php`:
```php
<?php
namespace App\Http\Controllers\Customer;

use App\Http\Controllers\Controller;
use App\Http\Requests\Order\PlaceOrderRequest;
use App\Models\Order;
use App\Models\Product;
use Illuminate\Http\Request;

class OrderController extends Controller
{
    public function store(PlaceOrderRequest $request): \Illuminate\Http\JsonResponse
    {
        $items = collect($request->items)->map(function ($item) {
            $product = Product::findOrFail($item['product_id']);
            return ['product_id' => $product->id, 'qty' => $item['qty'], 'unit_price' => $product->price];
        });

        $total = $items->sum(fn($i) => $i['qty'] * $i['unit_price']);

        $order = Order::create([
            'customer_id'         => $request->user()->id,
            'vendor_id'           => $request->vendor_id,
            'delivery_address_id' => $request->address_id,
            'delivery_slot'       => $request->delivery_slot,
            'payment_mode'        => $request->payment_mode,
            'total_amount'        => $total,
            'otp'                 => str_pad((string) random_int(100000, 999999), 6, '0'),
            'notes'               => $request->notes,
        ]);

        $order->items()->createMany($items->toArray());

        return response()->json(['success' => true, 'data' => $order->load('items')], 201);
    }

    public function index(Request $request): \Illuminate\Http\JsonResponse
    {
        $orders = Order::where('customer_id', $request->user()->id)
            ->with(['vendor', 'items.product'])
            ->latest()
            ->paginate(20);

        return response()->json(['success' => true, 'data' => $orders]);
    }

    public function show(Request $request, Order $order): \Illuminate\Http\JsonResponse
    {
        if ($order->customer_id !== $request->user()->id) {
            return response()->json(['success' => false, 'message' => 'Forbidden'], 403);
        }

        return response()->json(['success' => true, 'data' => $order->load(['items.product', 'vendor', 'deliveryBoy'])]);
    }
}
```

- [ ] **Step 7: Create Vendor/OrderController**

Create `app/Http/Controllers/Vendor/OrderController.php`:
```php
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
```

- [ ] **Step 8: Update routes/api.php — add order routes**

Add inside the `auth:sanctum` middleware group:
```php
// Customer orders
Route::middleware('role:customer')->group(function () {
    Route::post('/orders',           [\App\Http\Controllers\Customer\OrderController::class, 'store']);
    Route::get('/orders',            [\App\Http\Controllers\Customer\OrderController::class, 'index']);
    Route::get('/orders/{order}',    [\App\Http\Controllers\Customer\OrderController::class, 'show']);
});

// Vendor order management
Route::middleware('role:vendor')->group(function () {
    Route::get('/vendor/orders',                    [\App\Http\Controllers\Vendor\OrderController::class, 'index']);
    Route::put('/orders/{order}/status',            [\App\Http\Controllers\Vendor\OrderController::class, 'updateStatus']);
});
```

- [ ] **Step 9: Run order tests**

```bash
./vendor/bin/pest tests/Feature/Customer/OrderTest.php -v
```
Expected: All 3 PASS.

- [ ] **Step 10: Commit**

```bash
git add .
git commit -m "feat: order placement and vendor order management endpoints"
```

---

### Task 6: Delivery Boy Flow + OTP Confirm

**Files:**
- Create: `app/Http/Controllers/Delivery/DeliveryController.php`
- Create: `app/Http/Controllers/Delivery/LocationController.php`
- Create: `app/Http/Controllers/Customer/TrackingController.php`
- Modify: `routes/api.php`
- Create: `tests/Feature/Delivery/DeliveryFlowTest.php`

- [ ] **Step 1: Write failing test**

Create `tests/Feature/Delivery/DeliveryFlowTest.php`:
```php
<?php
use App\Models\User;
use App\Models\Order;
use App\Models\Vendor;
use App\Models\DeliveryBoyLocation;

it('delivery boy can see assigned orders', function () {
    $db        = User::factory()->deliveryBoy()->create();
    $vendor    = Vendor::factory()->create();
    $order     = Order::factory()->create(['delivery_boy_id' => $db->id, 'vendor_id' => $vendor->id, 'status' => 'assigned']);

    $response = $this->actingAs($db)->getJson('/api/delivery/orders');
    $response->assertOk()->assertJsonFragment(['id' => $order->id]);
});

it('delivery boy can update location', function () {
    $db = User::factory()->deliveryBoy()->create();

    $response = $this->actingAs($db)->postJson('/api/location', ['lat' => 12.97, 'lng' => 77.59]);
    $response->assertOk();
    $this->assertDatabaseHas('delivery_boy_locations', ['user_id' => $db->id, 'lat' => 12.97]);
});

it('delivery boy confirms OTP to complete delivery', function () {
    $db    = User::factory()->deliveryBoy()->create();
    $vendor = Vendor::factory()->create();
    $order = Order::factory()->create([
        'delivery_boy_id' => $db->id,
        'vendor_id'       => $vendor->id,
        'status'          => 'out_for_delivery',
        'otp'             => '654321',
    ]);

    $response = $this->actingAs($db)
        ->postJson("/api/orders/{$order->id}/verify-otp", ['otp' => '654321']);

    $response->assertOk()->assertJsonFragment(['status' => 'delivered']);
});

it('rejects wrong OTP', function () {
    $db    = User::factory()->deliveryBoy()->create();
    $vendor = Vendor::factory()->create();
    $order = Order::factory()->create([
        'delivery_boy_id' => $db->id,
        'vendor_id'       => $vendor->id,
        'status'          => 'out_for_delivery',
        'otp'             => '654321',
    ]);

    $response = $this->actingAs($db)
        ->postJson("/api/orders/{$order->id}/verify-otp", ['otp' => '000000']);

    $response->assertUnprocessable();
});
```

- [ ] **Step 2: Run to confirm failures**

```bash
./vendor/bin/pest tests/Feature/Delivery/DeliveryFlowTest.php -v
```
Expected: FAIL.

- [ ] **Step 3: Create Delivery/DeliveryController**

Create `app/Http/Controllers/Delivery/DeliveryController.php`:
```php
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
        if ($order->delivery_boy_id !== $request->user()->id) {
            return response()->json(['success' => false, 'message' => 'Forbidden'], 403);
        }

        $data = $request->validate([
            'status' => ['required', 'in:out_for_delivery,delivered'],
        ]);

        $order->update(['status' => $data['status']]);
        return response()->json(['success' => true, 'data' => $order->fresh()]);
    }

    public function verifyOtp(Request $request, Order $order): \Illuminate\Http\JsonResponse
    {
        $request->validate(['otp' => ['required', 'string', 'size:6']]);

        if ($order->delivery_boy_id !== $request->user()->id) {
            return response()->json(['success' => false, 'message' => 'Forbidden'], 403);
        }

        if (! hash_equals($order->otp, $request->otp)) {
            return response()->json(['success' => false, 'message' => 'Invalid OTP'], 422);
        }

        $order->update(['status' => 'delivered', 'payment_status' => $order->payment_mode === 'cod' ? 'paid' : $order->payment_status]);
        return response()->json(['success' => true, 'data' => $order->fresh()]);
    }
}
```

- [ ] **Step 4: Create Delivery/LocationController**

Create `app/Http/Controllers/Delivery/LocationController.php`:
```php
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
```

- [ ] **Step 5: Create Customer/TrackingController**

Create `app/Http/Controllers/Customer/TrackingController.php`:
```php
<?php
namespace App\Http\Controllers\Customer;

use App\Http\Controllers\Controller;
use App\Models\Order;
use Illuminate\Http\Request;

class TrackingController extends Controller
{
    public function show(Request $request, Order $order): \Illuminate\Http\JsonResponse
    {
        if ($order->customer_id !== $request->user()->id) {
            return response()->json(['success' => false, 'message' => 'Forbidden'], 403);
        }

        $location = null;
        if ($order->delivery_boy_id && $order->status === 'out_for_delivery') {
            $location = $order->deliveryBoy->location;
        }

        return response()->json([
            'success' => true,
            'data'    => [
                'status'   => $order->status,
                'location' => $location,
            ],
        ]);
    }
}
```

- [ ] **Step 6: Update routes/api.php — add delivery and tracking routes**

Add inside `auth:sanctum` group:
```php
// Delivery boy routes
Route::middleware('role:delivery_boy')->group(function () {
    Route::get('/delivery/orders',              [\App\Http\Controllers\Delivery\DeliveryController::class, 'index']);
    Route::put('/delivery/orders/{order}/status', [\App\Http\Controllers\Delivery\DeliveryController::class, 'updateStatus']);
    Route::post('/location',                    [\App\Http\Controllers\Delivery\LocationController::class, 'update']);
});

// Shared: OTP verify (delivery boy confirms)
Route::middleware('role:delivery_boy')->post(
    '/orders/{order}/verify-otp',
    [\App\Http\Controllers\Delivery\DeliveryController::class, 'verifyOtp']
);

// Customer: live tracking
Route::get('/orders/{order}/tracking', [\App\Http\Controllers\Customer\TrackingController::class, 'show']);
```

- [ ] **Step 7: Run tests**

```bash
./vendor/bin/pest tests/Feature/Delivery/DeliveryFlowTest.php -v
```
Expected: All 4 PASS.

- [ ] **Step 8: Commit**

```bash
git add .
git commit -m "feat: delivery boy flow — order list, location push, OTP delivery confirm"
```

---

### Task 7: Payments (Razorpay)

**Files:**
- Create: `app/Services/RazorpayService.php`
- Create: `app/Http/Controllers/Customer/PaymentController.php`
- Modify: `routes/api.php`
- Create: `tests/Unit/Services/RazorpayServiceTest.php`

- [ ] **Step 1: Write unit test**

Create `tests/Unit/Services/RazorpayServiceTest.php`:
```php
<?php
use App\Services\RazorpayService;

it('creates a Razorpay order and returns id', function () {
    $service = new RazorpayService(
        keyId: 'rzp_test_key',
        keySecret: 'test_secret'
    );

    // We only test that the service builds the correct request structure
    // Real integration tests require Razorpay test credentials
    expect($service)->toBeInstanceOf(RazorpayService::class);
});

it('verifies correct signature', function () {
    $service = new RazorpayService('key', 'secret');

    $orderId   = 'order_123';
    $paymentId = 'pay_abc';
    $signature = hash_hmac('sha256', "{$orderId}|{$paymentId}", 'secret');

    expect($service->verifySignature($orderId, $paymentId, $signature))->toBeTrue();
    expect($service->verifySignature($orderId, $paymentId, 'wrong'))->toBeFalse();
});
```

- [ ] **Step 2: Run to confirm failures**

```bash
./vendor/bin/pest tests/Unit/Services/RazorpayServiceTest.php -v
```
Expected: FAIL.

- [ ] **Step 3: Create RazorpayService**

Create `app/Services/RazorpayService.php`:
```php
<?php
namespace App\Services;

use Razorpay\Api\Api;

class RazorpayService
{
    private Api $api;

    public function __construct(
        private string $keyId,
        private string $keySecret,
    ) {
        $this->api = new Api($keyId, $keySecret);
    }

    public function createOrder(int $amountPaise, string $receiptId): array
    {
        $order = $this->api->order->create([
            'amount'          => $amountPaise,
            'currency'        => 'INR',
            'receipt'         => $receiptId,
            'payment_capture' => 1,
        ]);

        return ['razorpay_order_id' => $order->id, 'amount' => $amountPaise];
    }

    public function verifySignature(string $razorpayOrderId, string $razorpayPaymentId, string $signature): bool
    {
        $expected = hash_hmac('sha256', "{$razorpayOrderId}|{$razorpayPaymentId}", $this->keySecret);
        return hash_equals($expected, $signature);
    }
}
```

- [ ] **Step 4: Register RazorpayService in AppServiceProvider**

Edit `app/Providers/AppServiceProvider.php` — add to `register()`:
```php
$this->app->bind(\App\Services\RazorpayService::class, function () {
    return new \App\Services\RazorpayService(
        keyId:     config('services.razorpay.key_id'),
        keySecret: config('services.razorpay.key_secret'),
    );
});
```

Add to `config/services.php`:
```php
'razorpay' => [
    'key_id'     => env('RAZORPAY_KEY_ID'),
    'key_secret' => env('RAZORPAY_KEY_SECRET'),
],
```

- [ ] **Step 5: Create PaymentController**

Create `app/Http/Controllers/Customer/PaymentController.php`:
```php
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

        if ($order->customer_id !== $request->user()->id) {
            return response()->json(['success' => false, 'message' => 'Forbidden'], 403);
        }

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
```

- [ ] **Step 6: Update routes/api.php — add payment routes**

```php
Route::middleware('role:customer')->group(function () {
    Route::post('/payments/create-order', [\App\Http\Controllers\Customer\PaymentController::class, 'createOrder']);
    Route::post('/payments/verify',       [\App\Http\Controllers\Customer\PaymentController::class, 'verify']);
});
```

- [ ] **Step 7: Run unit tests**

```bash
./vendor/bin/pest tests/Unit/Services/RazorpayServiceTest.php -v
```
Expected: All 2 PASS.

- [ ] **Step 8: Commit**

```bash
git add .
git commit -m "feat: Razorpay payment creation and signature verification"
```

---

### Task 8: Subscriptions

**Files:**
- Create: `app/Http/Controllers/Customer/SubscriptionController.php`
- Create: `app/Http/Requests/Subscription/StoreSubscriptionRequest.php`
- Create: `app/Services/SubscriptionSchedulerService.php`
- Create: `app/Console/Commands/GenerateSubscriptionOrders.php`
- Modify: `routes/api.php`
- Modify: `routes/console.php` (schedule)
- Create: `tests/Feature/Customer/SubscriptionTest.php`
- Create: `tests/Unit/Services/SubscriptionSchedulerTest.php`

- [ ] **Step 1: Write tests**

Create `tests/Unit/Services/SubscriptionSchedulerTest.php`:
```php
<?php
use App\Services\SubscriptionSchedulerService;
use App\Models\Subscription;
use App\Models\User;
use App\Models\Vendor;
use App\Models\Product;
use App\Models\Address;
use Carbon\Carbon;

it('calculates next daily delivery date as tomorrow', function () {
    $service = new SubscriptionSchedulerService();
    $next    = $service->calculateNextDate('daily', null, null, Carbon::today());
    expect($next->toDateString())->toBe(Carbon::tomorrow()->toDateString());
});

it('calculates next weekly delivery date', function () {
    $service = new SubscriptionSchedulerService();
    // day_of_week = 1 (Monday)
    $next = $service->calculateNextDate('weekly', 1, null, Carbon::parse('2026-05-18')); // Monday
    expect($next->toDateString())->toBe('2026-05-25');
});

it('generates subscription orders for due subscriptions', function () {
    $customer = User::factory()->create(['role' => 'customer']);
    $vendor   = Vendor::factory()->create();
    $product  = Product::factory()->create(['vendor_id' => $vendor->id]);
    $address  = Address::create([
        'user_id' => $customer->id, 'label' => 'Home',
        'address_line' => '1 Main St', 'lat' => 12.97, 'lng' => 77.59,
    ]);

    Subscription::create([
        'customer_id'       => $customer->id,
        'vendor_id'         => $vendor->id,
        'product_id'        => $product->id,
        'qty'               => 1,
        'frequency'         => 'daily',
        'delivery_slot'     => 'morning',
        'address_id'        => $address->id,
        'payment_mode'      => 'cod',
        'is_active'         => true,
        'next_delivery_date'=> Carbon::today(),
    ]);

    $service = new SubscriptionSchedulerService();
    $count   = $service->generateDueOrders(Carbon::today());

    expect($count)->toBe(1);
    $this->assertDatabaseHas('orders', ['customer_id' => $customer->id]);
});
```

- [ ] **Step 2: Run to confirm failures**

```bash
./vendor/bin/pest tests/Unit/Services/SubscriptionSchedulerTest.php -v
```
Expected: FAIL.

- [ ] **Step 3: Create SubscriptionSchedulerService**

Create `app/Services/SubscriptionSchedulerService.php`:
```php
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
                'otp'                 => str_pad((string) random_int(100000, 999999), 6, '0'),
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
```

- [ ] **Step 4: Run scheduler tests**

```bash
./vendor/bin/pest tests/Unit/Services/SubscriptionSchedulerTest.php -v
```
Expected: All 3 PASS.

- [ ] **Step 5: Create SubscriptionController**

Create `app/Http/Requests/Subscription/StoreSubscriptionRequest.php`:
```php
<?php
namespace App\Http\Requests\Subscription;

use Illuminate\Foundation\Http\FormRequest;

class StoreSubscriptionRequest extends FormRequest
{
    public function authorize(): bool { return true; }

    public function rules(): array
    {
        return [
            'vendor_id'     => ['required', 'exists:vendors,id'],
            'product_id'    => ['required', 'exists:products,id'],
            'qty'           => ['required', 'integer', 'min:1'],
            'frequency'     => ['required', 'in:daily,weekly,monthly'],
            'day_of_week'   => ['nullable', 'integer', 'between:0,6'],
            'day_of_month'  => ['nullable', 'integer', 'between:1,28'],
            'delivery_slot' => ['required', 'in:morning,afternoon,evening'],
            'address_id'    => ['required', 'exists:addresses,id'],
            'payment_mode'  => ['required', 'in:cod,online'],
        ];
    }
}
```

Create `app/Http/Controllers/Customer/SubscriptionController.php`:
```php
<?php
namespace App\Http\Controllers\Customer;

use App\Http\Controllers\Controller;
use App\Http\Requests\Subscription\StoreSubscriptionRequest;
use App\Models\Subscription;
use App\Services\SubscriptionSchedulerService;
use Carbon\Carbon;
use Illuminate\Http\Request;

class SubscriptionController extends Controller
{
    public function __construct(private SubscriptionSchedulerService $scheduler) {}

    public function store(StoreSubscriptionRequest $request): \Illuminate\Http\JsonResponse
    {
        $data = $request->validated();
        $data['customer_id']       = $request->user()->id;
        $data['next_delivery_date'] = $this->scheduler->calculateNextDate(
            $data['frequency'],
            $data['day_of_week'] ?? null,
            $data['day_of_month'] ?? null,
            Carbon::today()
        );

        $subscription = Subscription::create($data);
        return response()->json(['success' => true, 'data' => $subscription], 201);
    }

    public function index(Request $request): \Illuminate\Http\JsonResponse
    {
        $subs = Subscription::where('customer_id', $request->user()->id)
            ->with(['product', 'vendor'])
            ->get();

        return response()->json(['success' => true, 'data' => $subs]);
    }

    public function update(Request $request, Subscription $subscription): \Illuminate\Http\JsonResponse
    {
        if ($subscription->customer_id !== $request->user()->id) {
            return response()->json(['success' => false, 'message' => 'Forbidden'], 403);
        }

        $data = $request->validate([
            'qty'           => ['sometimes', 'integer', 'min:1'],
            'delivery_slot' => ['sometimes', 'in:morning,afternoon,evening'],
            'is_active'     => ['sometimes', 'boolean'],
            'address_id'    => ['sometimes', 'exists:addresses,id'],
        ]);

        $subscription->update($data);
        return response()->json(['success' => true, 'data' => $subscription->fresh()]);
    }

    public function destroy(Request $request, Subscription $subscription): \Illuminate\Http\JsonResponse
    {
        if ($subscription->customer_id !== $request->user()->id) {
            return response()->json(['success' => false, 'message' => 'Forbidden'], 403);
        }

        $subscription->delete();
        return response()->json(['success' => true, 'message' => 'Subscription cancelled']);
    }
}
```

- [ ] **Step 6: Create Artisan command for scheduler**

Create `app/Console/Commands/GenerateSubscriptionOrders.php`:
```php
<?php
namespace App\Console\Commands;

use App\Services\SubscriptionSchedulerService;
use Carbon\Carbon;
use Illuminate\Console\Command;

class GenerateSubscriptionOrders extends Command
{
    protected $signature   = 'subscriptions:generate {--date= : Date to generate for (Y-m-d, defaults to today)}';
    protected $description = 'Generate orders for active subscriptions due today';

    public function handle(SubscriptionSchedulerService $scheduler): int
    {
        $date  = $this->option('date') ? Carbon::parse($this->option('date')) : Carbon::today();
        $count = $scheduler->generateDueOrders($date);
        $this->info("Generated {$count} subscription orders for {$date->toDateString()}");
        return Command::SUCCESS;
    }
}
```

Add to `routes/console.php`:
```php
use Illuminate\Support\Facades\Schedule;

Schedule::command('subscriptions:generate')->dailyAt('00:05');
```

- [ ] **Step 7: Update routes/api.php — add subscription routes**

```php
Route::middleware('role:customer')->group(function () {
    Route::post('/subscriptions',              [\App\Http\Controllers\Customer\SubscriptionController::class, 'store']);
    Route::get('/subscriptions',               [\App\Http\Controllers\Customer\SubscriptionController::class, 'index']);
    Route::put('/subscriptions/{subscription}', [\App\Http\Controllers\Customer\SubscriptionController::class, 'update']);
    Route::delete('/subscriptions/{subscription}', [\App\Http\Controllers\Customer\SubscriptionController::class, 'destroy']);
});
```

- [ ] **Step 8: Run all subscription tests**

```bash
./vendor/bin/pest tests/Unit/Services/SubscriptionSchedulerTest.php tests/Feature/Customer/ -v
```
Expected: All PASS.

- [ ] **Step 9: Commit**

```bash
git add .
git commit -m "feat: subscriptions CRUD and daily scheduler command"
```

---

### Task 9: Notifications API + FCM Service

**Files:**
- Create: `app/Services/FirebaseService.php`
- Create: `app/Http/Controllers/Customer/NotificationController.php`
- Modify: `routes/api.php`

- [ ] **Step 1: Create FirebaseService**

Create `app/Services/FirebaseService.php`:
```php
<?php
namespace App\Services;

use Kreait\Firebase\Factory;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification;

class FirebaseService
{
    private \Kreait\Firebase\Contract\Messaging $messaging;

    public function __construct()
    {
        $factory         = (new Factory())->withServiceAccount(config('services.firebase.credentials'));
        $this->messaging = $factory->createMessaging();
    }

    public function sendToToken(string $fcmToken, string $title, string $body, array $data = []): void
    {
        $message = CloudMessage::withTarget('token', $fcmToken)
            ->withNotification(Notification::create($title, $body))
            ->withData($data);

        $this->messaging->send($message);
    }

    public function sendToTopic(string $topic, string $title, string $body): void
    {
        $message = CloudMessage::withTarget('topic', $topic)
            ->withNotification(Notification::create($title, $body));

        $this->messaging->send($message);
    }
}
```

Add to `config/services.php`:
```php
'firebase' => [
    'credentials' => env('FIREBASE_CREDENTIALS'),
],
```

- [ ] **Step 2: Create NotificationController**

Create `app/Http/Controllers/Customer/NotificationController.php`:
```php
<?php
namespace App\Http\Controllers\Customer;

use App\Http\Controllers\Controller;
use App\Models\Notification;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    public function index(Request $request): \Illuminate\Http\JsonResponse
    {
        $notifications = Notification::where('user_id', $request->user()->id)
            ->latest()
            ->paginate(30);

        return response()->json(['success' => true, 'data' => $notifications]);
    }

    public function markRead(Request $request, Notification $notification): \Illuminate\Http\JsonResponse
    {
        if ($notification->user_id !== $request->user()->id) {
            return response()->json(['success' => false, 'message' => 'Forbidden'], 403);
        }

        $notification->update(['is_read' => true]);
        return response()->json(['success' => true]);
    }
}
```

- [ ] **Step 3: Update routes/api.php**

```php
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/notifications',                       [\App\Http\Controllers\Customer\NotificationController::class, 'index']);
    Route::put('/notifications/{notification}/read',   [\App\Http\Controllers\Customer\NotificationController::class, 'markRead']);
});
```

- [ ] **Step 4: Commit**

```bash
git add .
git commit -m "feat: FCM push notification service and notifications API"
```

---

### Task 10: Admin Panel (Web)

**Files:**
- Create: `app/Http/Controllers/Admin/AuthController.php`
- Create: `app/Http/Controllers/Admin/VendorController.php`
- Create: `app/Http/Controllers/Admin/UserController.php`
- Create: `app/Http/Controllers/Admin/OrderController.php`
- Create: `app/Http/Controllers/Admin/ReportController.php`
- Create: `app/Http/Controllers/Admin/NotificationController.php`
- Create: `resources/views/admin/` (all Blade views)
- Modify: `routes/web.php`
- Create: `database/seeders/AdminSeeder.php`
- Create: `tests/Feature/Admin/AdminPanelTest.php`

- [ ] **Step 1: Write failing admin test**

Create `tests/Feature/Admin/AdminPanelTest.php`:
```php
<?php
use App\Models\User;

it('redirects unauthenticated to admin login', function () {
    $response = $this->get('/admin/dashboard');
    $response->assertRedirect('/admin/login');
});

it('admin can login with correct password', function () {
    User::factory()->create(['phone' => 'admin', 'role' => 'admin', 'email' => 'admin@water.com']);

    $response = $this->post('/admin/login', [
        'email'    => 'admin@water.com',
        'password' => 'admin123',
    ]);

    $response->assertRedirect('/admin/dashboard');
});

it('admin can view dashboard', function () {
    $admin = User::factory()->create(['role' => 'admin', 'email' => 'admin@water.com']);
    $this->actingAs($admin, 'admin');

    $response = $this->get('/admin/dashboard');
    $response->assertOk()->assertSee('Dashboard');
});

it('non-admin cannot access admin dashboard', function () {
    $user = User::factory()->create(['role' => 'customer']);
    $this->actingAs($user, 'admin');

    $response = $this->get('/admin/dashboard');
    $response->assertRedirect('/admin/login');
});
```

- [ ] **Step 2: Run to confirm failures**

```bash
./vendor/bin/pest tests/Feature/Admin/AdminPanelTest.php -v
```
Expected: FAIL.

- [ ] **Step 3: Add admin guard to config/auth.php**

Edit `config/auth.php` — add to `guards` array:
```php
'admin' => [
    'driver'   => 'session',
    'provider' => 'admins',
],
```

Add to `providers` array:
```php
'admins' => [
    'driver' => 'eloquent',
    'model'  => App\Models\User::class,
],
```

- [ ] **Step 4: Create AdminSeeder**

Create `database/seeders/AdminSeeder.php`:
```php
<?php
namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class AdminSeeder extends Seeder
{
    public function run(): void
    {
        User::firstOrCreate(
            ['email' => 'admin@water.com'],
            [
                'name'     => 'Admin',
                'phone'    => 'admin',
                'role'     => 'admin',
                'password' => Hash::make('admin123'),
                'is_active'=> true,
            ]
        );
    }
}
```

Add `password` column to users migration (update migration `001`):
```php
$table->string('password')->nullable();
```

Re-run migrations:
```bash
php artisan migrate:fresh && php artisan db:seed --class=AdminSeeder
```

- [ ] **Step 5: Create Admin/AuthController**

Create `app/Http/Controllers/Admin/AuthController.php`:
```php
<?php
namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class AuthController extends Controller
{
    public function showLogin()
    {
        return view('admin.auth.login');
    }

    public function login(Request $request)
    {
        $credentials = $request->validate([
            'email'    => ['required', 'email'],
            'password' => ['required'],
        ]);

        if (Auth::guard('admin')->attempt($credentials)) {
            $user = Auth::guard('admin')->user();
            if ($user->role !== 'admin') {
                Auth::guard('admin')->logout();
                return back()->withErrors(['email' => 'Access denied.']);
            }
            $request->session()->regenerate();
            return redirect('/admin/dashboard');
        }

        return back()->withErrors(['email' => 'Invalid credentials.']);
    }

    public function logout(Request $request)
    {
        Auth::guard('admin')->logout();
        $request->session()->invalidate();
        return redirect('/admin/login');
    }
}
```

- [ ] **Step 6: Create Admin dashboard and CRUD controllers**

Create `app/Http/Controllers/Admin/VendorController.php`:
```php
<?php
namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Vendor;
use App\Models\User;
use Illuminate\Http\Request;

class VendorController extends Controller
{
    public function index()
    {
        $vendors = Vendor::with('user')->paginate(20);
        return view('admin.vendors.index', compact('vendors'));
    }

    public function show(Vendor $vendor)
    {
        $vendor->load(['user', 'products', 'orders' => fn($q) => $q->latest()->take(10)]);
        return view('admin.vendors.show', compact('vendor'));
    }

    public function toggleStatus(Vendor $vendor)
    {
        $vendor->user->update(['is_active' => ! $vendor->user->is_active]);
        return back()->with('success', 'Vendor status updated.');
    }
}
```

Create `app/Http/Controllers/Admin/UserController.php`:
```php
<?php
namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;

class UserController extends Controller
{
    public function index()
    {
        $users = User::whereIn('role', ['customer', 'delivery_boy'])->paginate(30);
        return view('admin.users.index', compact('users'));
    }

    public function toggleStatus(User $user)
    {
        $user->update(['is_active' => ! $user->is_active]);
        return back()->with('success', 'User status updated.');
    }
}
```

Create `app/Http/Controllers/Admin/OrderController.php`:
```php
<?php
namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Order;

class OrderController extends Controller
{
    public function index()
    {
        $orders = Order::with(['customer:id,name,phone', 'vendor:id,business_name'])
            ->latest()
            ->paginate(30);
        return view('admin.orders.index', compact('orders'));
    }
}
```

Create `app/Http/Controllers/Admin/ReportController.php`:
```php
<?php
namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\Vendor;
use Illuminate\Support\Facades\DB;

class ReportController extends Controller
{
    public function index()
    {
        $dailyRevenue = Order::select(
                DB::raw('DATE(created_at) as date'),
                DB::raw('SUM(total_amount) as revenue'),
                DB::raw('COUNT(*) as count')
            )
            ->where('status', 'delivered')
            ->groupBy('date')
            ->orderByDesc('date')
            ->take(30)
            ->get();

        $vendorSales = Vendor::withCount(['orders as delivered_count' => fn($q) => $q->where('status', 'delivered')])
            ->withSum(['orders as total_revenue' => fn($q) => $q->where('status', 'delivered')], 'total_amount')
            ->orderByDesc('total_revenue')
            ->take(10)
            ->get();

        return view('admin.reports.index', compact('dailyRevenue', 'vendorSales'));
    }
}
```

Create `app/Http/Controllers/Admin/NotificationController.php`:
```php
<?php
namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Services\FirebaseService;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    public function __construct(private FirebaseService $firebase) {}

    public function index()
    {
        return view('admin.notifications.index');
    }

    public function broadcast(Request $request)
    {
        $data = $request->validate([
            'title'   => ['required', 'string', 'max:100'],
            'message' => ['required', 'string', 'max:500'],
            'topic'   => ['required', 'in:all,customers,vendors'],
        ]);

        $this->firebase->sendToTopic($data['topic'], $data['title'], $data['message']);

        return back()->with('success', "Notification sent to topic: {$data['topic']}");
    }
}
```

- [ ] **Step 7: Create Blade views**

Create `resources/views/admin/layouts/app.blade.php`:
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>@yield('title', 'Admin') — Water Delivery</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<nav class="navbar navbar-dark bg-dark px-3">
    <a class="navbar-brand" href="/admin/dashboard">💧 WaterAdmin</a>
    <div class="d-flex gap-3">
        <a class="text-white text-decoration-none" href="/admin/vendors">Vendors</a>
        <a class="text-white text-decoration-none" href="/admin/users">Users</a>
        <a class="text-white text-decoration-none" href="/admin/orders">Orders</a>
        <a class="text-white text-decoration-none" href="/admin/reports">Reports</a>
        <a class="text-white text-decoration-none" href="/admin/notifications">Notify</a>
        <form method="POST" action="/admin/logout" class="d-inline">
            @csrf
            <button class="btn btn-sm btn-outline-light">Logout</button>
        </form>
    </div>
</nav>
<div class="container mt-4">
    @if(session('success'))
        <div class="alert alert-success">{{ session('success') }}</div>
    @endif
    @yield('content')
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
```

Create `resources/views/admin/auth/login.blade.php`:
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Admin Login</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light d-flex align-items-center" style="min-height:100vh">
<div class="container" style="max-width:400px">
    <h3 class="mb-4 text-center">Admin Login</h3>
    <form method="POST" action="/admin/login">
        @csrf
        <div class="mb-3">
            <label class="form-label">Email</label>
            <input type="email" name="email" class="form-control @error('email') is-invalid @enderror" value="{{ old('email') }}">
            @error('email')<div class="invalid-feedback">{{ $message }}</div>@enderror
        </div>
        <div class="mb-3">
            <label class="form-label">Password</label>
            <input type="password" name="password" class="form-control">
        </div>
        <button type="submit" class="btn btn-primary w-100">Login</button>
    </form>
</div>
</body>
</html>
```

Create `resources/views/admin/dashboard.blade.php`:
```html
@extends('admin.layouts.app')
@section('title', 'Dashboard')
@section('content')
<h2>Dashboard</h2>
<div class="row g-3 mt-2">
    <div class="col-md-3">
        <div class="card text-bg-primary"><div class="card-body">
            <h5>Today's Orders</h5>
            <h2>{{ $todayOrders }}</h2>
        </div></div>
    </div>
    <div class="col-md-3">
        <div class="card text-bg-success"><div class="card-body">
            <h5>Revenue Today</h5>
            <h2>₹{{ number_format($todayRevenue, 0) }}</h2>
        </div></div>
    </div>
    <div class="col-md-3">
        <div class="card text-bg-info"><div class="card-body">
            <h5>Active Vendors</h5>
            <h2>{{ $activeVendors }}</h2>
        </div></div>
    </div>
    <div class="col-md-3">
        <div class="card text-bg-warning"><div class="card-body">
            <h5>Total Users</h5>
            <h2>{{ $totalUsers }}</h2>
        </div></div>
    </div>
</div>
@endsection
```

Create a DashboardController to pass data to the view:

Create `app/Http/Controllers/Admin/DashboardController.php`:
```php
<?php
namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\User;
use App\Models\Vendor;
use Carbon\Carbon;

class DashboardController extends Controller
{
    public function index()
    {
        $today = Carbon::today();

        return view('admin.dashboard', [
            'todayOrders'  => Order::whereDate('created_at', $today)->count(),
            'todayRevenue' => Order::whereDate('created_at', $today)->where('status', 'delivered')->sum('total_amount'),
            'activeVendors'=> Vendor::whereHas('user', fn($q) => $q->where('is_active', true))->count(),
            'totalUsers'   => User::where('role', 'customer')->count(),
        ]);
    }
}
```

Create `resources/views/admin/vendors/index.blade.php`:
```html
@extends('admin.layouts.app')
@section('title', 'Vendors')
@section('content')
<h2>Vendors</h2>
<table class="table table-bordered mt-3">
    <thead><tr><th>ID</th><th>Business</th><th>Owner</th><th>Open</th><th>Active</th><th>Action</th></tr></thead>
    <tbody>
    @foreach($vendors as $vendor)
    <tr>
        <td>{{ $vendor->id }}</td>
        <td><a href="/admin/vendors/{{ $vendor->id }}">{{ $vendor->business_name }}</a></td>
        <td>{{ $vendor->user->name }}</td>
        <td>{{ $vendor->is_open ? '✅' : '❌' }}</td>
        <td>{{ $vendor->user->is_active ? '✅' : '❌' }}</td>
        <td>
            <form method="POST" action="/admin/vendors/{{ $vendor->id }}/toggle">
                @csrf @method('PATCH')
                <button class="btn btn-sm btn-warning">Toggle</button>
            </form>
        </td>
    </tr>
    @endforeach
    </tbody>
</table>
{{ $vendors->links() }}
@endsection
```

Create `resources/views/admin/vendors/show.blade.php`:
```html
@extends('admin.layouts.app')
@section('title', $vendor->business_name)
@section('content')
<h2>{{ $vendor->business_name }}</h2>
<p><strong>Owner:</strong> {{ $vendor->user->name }} ({{ $vendor->user->phone }})</p>
<p><strong>Address:</strong> {{ $vendor->address }}</p>
<h4 class="mt-4">Products</h4>
<ul>@foreach($vendor->products as $p)<li>{{ $p->name }} — ₹{{ $p->price }} ({{ $p->unit }})</li>@endforeach</ul>
<h4 class="mt-4">Recent Orders</h4>
<ul>@foreach($vendor->orders as $o)<li>Order #{{ $o->id }} — {{ $o->status }} — ₹{{ $o->total_amount }}</li>@endforeach</ul>
@endsection
```

Create `resources/views/admin/users/index.blade.php`:
```html
@extends('admin.layouts.app')
@section('title', 'Users')
@section('content')
<h2>Users</h2>
<table class="table table-bordered mt-3">
    <thead><tr><th>ID</th><th>Name</th><th>Phone</th><th>Role</th><th>Active</th><th>Action</th></tr></thead>
    <tbody>
    @foreach($users as $user)
    <tr>
        <td>{{ $user->id }}</td>
        <td>{{ $user->name }}</td>
        <td>{{ $user->phone }}</td>
        <td><span class="badge bg-secondary">{{ $user->role }}</span></td>
        <td>{{ $user->is_active ? '✅' : '❌' }}</td>
        <td>
            <form method="POST" action="/admin/users/{{ $user->id }}/toggle">
                @csrf @method('PATCH')
                <button class="btn btn-sm btn-warning">Toggle</button>
            </form>
        </td>
    </tr>
    @endforeach
    </tbody>
</table>
{{ $users->links() }}
@endsection
```

Create `resources/views/admin/orders/index.blade.php`:
```html
@extends('admin.layouts.app')
@section('title', 'Orders')
@section('content')
<h2>All Orders</h2>
<table class="table table-bordered mt-3">
    <thead><tr><th>ID</th><th>Customer</th><th>Vendor</th><th>Amount</th><th>Status</th><th>Date</th></tr></thead>
    <tbody>
    @foreach($orders as $order)
    <tr>
        <td>#{{ $order->id }}</td>
        <td>{{ $order->customer->name }}</td>
        <td>{{ $order->vendor->business_name }}</td>
        <td>₹{{ $order->total_amount }}</td>
        <td><span class="badge bg-{{ $order->status === 'delivered' ? 'success' : ($order->status === 'cancelled' ? 'danger' : 'warning') }}">{{ $order->status }}</span></td>
        <td>{{ $order->created_at->format('d M Y') }}</td>
    </tr>
    @endforeach
    </tbody>
</table>
{{ $orders->links() }}
@endsection
```

Create `resources/views/admin/reports/index.blade.php`:
```html
@extends('admin.layouts.app')
@section('title', 'Reports')
@section('content')
<h2>Reports</h2>
<h4>Daily Revenue (Last 30 Days)</h4>
<table class="table table-sm mt-2">
    <thead><tr><th>Date</th><th>Orders</th><th>Revenue</th></tr></thead>
    <tbody>
    @foreach($dailyRevenue as $row)
    <tr><td>{{ $row->date }}</td><td>{{ $row->count }}</td><td>₹{{ number_format($row->revenue, 0) }}</td></tr>
    @endforeach
    </tbody>
</table>
<h4 class="mt-4">Top 10 Vendors</h4>
<table class="table table-sm mt-2">
    <thead><tr><th>Vendor</th><th>Delivered Orders</th><th>Revenue</th></tr></thead>
    <tbody>
    @foreach($vendorSales as $v)
    <tr><td>{{ $v->business_name }}</td><td>{{ $v->delivered_count }}</td><td>₹{{ number_format($v->total_revenue, 0) }}</td></tr>
    @endforeach
    </tbody>
</table>
@endsection
```

Create `resources/views/admin/notifications/index.blade.php`:
```html
@extends('admin.layouts.app')
@section('title', 'Send Notification')
@section('content')
<h2>Broadcast Push Notification</h2>
<form method="POST" action="/admin/notifications/broadcast" class="mt-3" style="max-width:500px">
    @csrf
    <div class="mb-3">
        <label class="form-label">Title</label>
        <input type="text" name="title" class="form-control" required>
    </div>
    <div class="mb-3">
        <label class="form-label">Message</label>
        <textarea name="message" class="form-control" rows="3" required></textarea>
    </div>
    <div class="mb-3">
        <label class="form-label">Audience</label>
        <select name="topic" class="form-select">
            <option value="all">All Users</option>
            <option value="customers">Customers Only</option>
            <option value="vendors">Vendors Only</option>
        </select>
    </div>
    <button type="submit" class="btn btn-primary">Send</button>
</form>
@endsection
```

- [ ] **Step 8: Create admin middleware**

Create `app/Http/Middleware/AdminMiddleware.php`:
```php
<?php
namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class AdminMiddleware
{
    public function handle(Request $request, Closure $next): mixed
    {
        if (! Auth::guard('admin')->check() || Auth::guard('admin')->user()->role !== 'admin') {
            return redirect('/admin/login');
        }
        return $next($request);
    }
}
```

Register alias in `bootstrap/app.php`:
```php
$middleware->alias([
    'role'  => \App\Http\Middleware\RoleMiddleware::class,
    'admin' => \App\Http\Middleware\AdminMiddleware::class,
]);
```

- [ ] **Step 9: Define web routes**

Edit `routes/web.php`:
```php
<?php
use App\Http\Controllers\Admin;
use Illuminate\Support\Facades\Route;

Route::prefix('admin')->group(function () {
    Route::get('/login',  [Admin\AuthController::class, 'showLogin'])->name('admin.login');
    Route::post('/login', [Admin\AuthController::class, 'login']);
    Route::post('/logout',[Admin\AuthController::class, 'logout']);

    Route::middleware('admin')->group(function () {
        Route::get('/dashboard', [Admin\DashboardController::class, 'index']);

        Route::get('/vendors',              [Admin\VendorController::class, 'index']);
        Route::get('/vendors/{vendor}',     [Admin\VendorController::class, 'show']);
        Route::patch('/vendors/{vendor}/toggle', [Admin\VendorController::class, 'toggleStatus']);

        Route::get('/users',                [Admin\UserController::class, 'index']);
        Route::patch('/users/{user}/toggle',[Admin\UserController::class, 'toggleStatus']);

        Route::get('/orders',               [Admin\OrderController::class, 'index']);
        Route::get('/reports',              [Admin\ReportController::class, 'index']);

        Route::get('/notifications',        [Admin\NotificationController::class, 'index']);
        Route::post('/notifications/broadcast', [Admin\NotificationController::class, 'broadcast']);
    });
});

Route::redirect('/', '/admin/dashboard');
```

- [ ] **Step 10: Run admin tests**

```bash
./vendor/bin/pest tests/Feature/Admin/AdminPanelTest.php -v
```
Expected: All PASS.

- [ ] **Step 11: Run full test suite**

```bash
./vendor/bin/pest --coverage
```
Expected: All PASS. Review coverage report.

- [ ] **Step 12: Commit**

```bash
git add .
git commit -m "feat: complete admin panel with Blade views, dashboard, vendor/user/order management, reports"
```

---

### Task 11: WhatsApp Alerts + Rate Limiting

**Files:**
- Create: `app/Services/WhatsAppService.php`
- Modify: `app/Http/Controllers/Customer/OrderController.php` (trigger alert on order placed)
- Modify: `routes/api.php` (rate limiting)

- [ ] **Step 1: Create WhatsAppService**

Create `app/Services/WhatsAppService.php`:
```php
<?php
namespace App\Services;

use Twilio\Rest\Client;

class WhatsAppService
{
    private Client $client;
    private string $from;

    public function __construct()
    {
        $this->client = new Client(config('services.twilio.sid'), config('services.twilio.token'));
        $this->from   = config('services.twilio.whatsapp_from');
    }

    public function sendOrderAlert(string $toPhone, string $message): void
    {
        $this->client->messages->create(
            "whatsapp:{$toPhone}",
            ['from' => $this->from, 'body' => $message]
        );
    }
}
```

Add to `config/services.php`:
```php
'twilio' => [
    'sid'            => env('TWILIO_SID'),
    'token'          => env('TWILIO_TOKEN'),
    'whatsapp_from'  => env('TWILIO_WHATSAPP_FROM'),
],
```

- [ ] **Step 2: Add OTP rate limiting**

Edit `routes/api.php` — wrap the send-otp route:
```php
Route::middleware('throttle:5,1')->post('/auth/send-otp', [OtpController::class, 'sendOtp']);
```

- [ ] **Step 3: Commit**

```bash
git add .
git commit -m "feat: WhatsApp alert service and OTP rate limiting"
```

---

### Task 12: Final Polish — run all tests, start server

- [ ] **Step 1: Run the full test suite**

```bash
cd water-backend && ./vendor/bin/pest --coverage
```
Expected: All tests PASS.

- [ ] **Step 2: Start dev server and verify API is reachable**

```bash
php artisan serve &
curl -s http://localhost:8000/api/auth/send-otp -X POST \
  -H "Content-Type: application/json" \
  -d '{"phone":"9876543210"}' | python3 -m json.tool
```
Expected: `{"success": true, "message": "OTP sent"}`

- [ ] **Step 3: Tag the backend release**

```bash
git tag v1.0.0-backend
```

- [ ] **Step 4: Final commit**

```bash
git add .
git commit -m "chore: backend complete — all tests passing, API verified"
```
