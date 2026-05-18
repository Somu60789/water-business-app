---
name: water-delivery-app-design
description: Complete design spec for Multi-Vendor Water Bottle Delivery app — single Flutter app with 3 roles (Customer, Vendor, Delivery Boy), Laravel backend, MySQL, Razorpay + COD, subscription orders, live GPS tracking.
metadata:
  type: project
---

# Water Delivery App — Design Spec
**Date:** 2026-05-16  
**Owner:** Vishnu  
**Status:** Approved for implementation

---

## 1. Project Overview

A multi-vendor water bottle delivery platform for the Indian market, starting at ~500 customers with architecture that can scale. One Flutter app with role-based functionality. Laravel REST API backend. Web admin panel.

### Business Goals
- Let customers order water cans online and track delivery live
- Let vendors manage their products, orders, and delivery team
- Let delivery boys receive and complete deliveries efficiently
- Give the business owner (admin) full visibility and control
- Recurring subscription orders as primary revenue mechanism

---

## 2. Technology Stack

| Layer | Technology | Reason |
|-------|-----------|--------|
| Mobile App | Flutter (Dart) | Single codebase for Android + iOS, great maps/notification support |
| Backend API | Laravel 11 (PHP) | Fast development, rich ecosystem, cheap to host, easy to hire |
| Database | MySQL | Reliable, well-understood, sufficient for 500–50,000 customers |
| Auth | Firebase Phone OTP + Laravel JWT | OTP login preferred in Indian market |
| Push Notifications | Firebase FCM | Free tier covers 500 customers easily |
| Maps & GPS | Google Maps API | Live tracking + directions |
| Payments | Razorpay + COD | UPI/cards/wallets + cash option |
| WhatsApp Alerts | WhatsApp Business API | Order confirmations to vendors |
| Hosting | VPS (DigitalOcean/Hetzner) | ₹1,500–₹2,500/month, sufficient for start |
| Admin Panel | Laravel + Blade (web) | Included in same Laravel project |

### Scale-up path
When business grows beyond 10,000 customers: migrate to separate services, add Redis caching, move to AWS ECS. The Laravel monolith is structured with clear module separation to make this migration clean.

---

## 3. User Roles

Three roles, one app. Login via phone OTP.

| Role | Who | Access | How they join |
|------|-----|--------|---------------|
| Customer | End buyers | Browse products, order, track, history, subscriptions | Self-register via app, default role = customer |
| Vendor | Water can suppliers | Manage products, accept orders, assign delivery boys, earnings | Admin creates vendor account in admin panel |
| Delivery Boy | Field staff | View assigned deliveries, navigate, confirm with OTP | Admin creates account, assigns to a vendor |
| Admin | Business owner (web) | Full platform control via web panel | Seeded in database |

---

## 4. Database Schema

### users
```
id, name, phone, email (nullable), role (customer/vendor/delivery_boy), 
fcm_token, is_active, created_at
```

### vendors
```
id, user_id (FK), business_name, address, lat, lng, 
service_radius_km, is_open, created_at
```

### products
```
id, vendor_id (FK), name, description, image_url, 
unit (20L/5L/1L), price, stock_qty, is_available, created_at
```

### addresses
```
id, user_id (FK), label (Home/Office/Other), address_line, 
lat, lng, is_default
```

### orders
```
id, customer_id (FK), vendor_id (FK), delivery_boy_id (FK nullable),
status (pending/accepted/assigned/out_for_delivery/delivered/cancelled),
payment_mode (cod/online), payment_status (pending/paid),
razorpay_order_id (nullable), total_amount, delivery_address_id (FK),
delivery_slot (morning/afternoon/evening), otp, notes, created_at
```

### order_items
```
id, order_id (FK), product_id (FK), qty, unit_price
```

### subscriptions
```
id, customer_id (FK), vendor_id (FK), product_id (FK), qty,
frequency (daily/weekly/monthly), day_of_week (nullable),
day_of_month (nullable), delivery_slot, address_id (FK),
payment_mode, is_active, next_delivery_date, created_at
```

### vendor_delivery_boys
```
id, vendor_id (FK), user_id (FK), is_active, created_at
```
(Many-to-one: each delivery boy belongs to one vendor)

### delivery_boy_locations
```
id, user_id (FK), lat, lng, updated_at
```

### notifications
```
id, user_id (FK), title, body, type, reference_id, is_read, created_at
```

### reviews
```
id, order_id (FK), customer_id (FK), vendor_id (FK), rating (1-5), comment, created_at
```

---

## 5. API Endpoints

### Auth
```
POST   /api/auth/send-otp          { phone }
POST   /api/auth/verify-otp        { phone, otp } → { token, user }
POST   /api/auth/refresh            { refresh_token }
PUT    /api/auth/profile            { name, email, fcm_token }
```

### Products & Vendors
```
GET    /api/vendors                 ?lat=&lng=  → vendors within radius
GET    /api/vendors/{id}/products
POST   /api/products                (vendor only)
PUT    /api/products/{id}           (vendor only)
DELETE /api/products/{id}           (vendor only)
```

### Orders
```
POST   /api/orders                  (customer) { vendor_id, items[], address_id, slot, payment_mode }
GET    /api/orders                  (customer: own, vendor: incoming, delivery: assigned)
GET    /api/orders/{id}
PUT    /api/orders/{id}/status      (vendor: accept/reject/assign; delivery: picked/delivered)
POST   /api/orders/{id}/verify-otp  (delivery boy confirms OTP from customer)
```

### Tracking
```
POST   /api/location                (delivery boy pushes GPS every 10s while on delivery)
GET    /api/orders/{id}/tracking    (customer polls → delivery boy lat/lng + ETA)
```

### Payments
```
POST   /api/payments/create-order   (Razorpay order creation)
POST   /api/payments/verify         (signature verification on callback)
```

### Subscriptions
```
POST   /api/subscriptions
GET    /api/subscriptions
PUT    /api/subscriptions/{id}
DELETE /api/subscriptions/{id}
```

### Notifications
```
GET    /api/notifications
PUT    /api/notifications/{id}/read
```

### Admin (web panel, separate auth)
```
GET/POST/PUT/DELETE /admin/vendors
GET/POST/PUT/DELETE /admin/users
GET                 /admin/orders
GET                 /admin/reports
POST                /admin/notifications/broadcast
```

---

## 6. Flutter App Structure

```
lib/
  main.dart
  app/
    router.dart           # GoRouter with role-based routing
    theme.dart
  features/
    auth/
      screens/            # splash, phone_input, otp_verify
      bloc/
      repository/
    customer/
      home/               # vendor list, product browse
      cart/
      checkout/           # address, slot, payment
      tracking/           # live map screen
      orders/             # history, reorder
      subscriptions/
      profile/
    vendor/
      dashboard/
      orders/             # incoming, assigned
      products/
      delivery_boys/
      earnings/
    delivery/
      deliveries/         # today's list
      navigate/           # map + OTP confirm
      summary/
    shared/
      widgets/
      models/
      services/           # api_client, firebase, razorpay
      utils/
```

**State management:** Bloc/Cubit  
**Navigation:** GoRouter (role-based initial route)  
**HTTP:** Dio with JWT interceptor  
**Maps:** google_maps_flutter  
**Payments:** razorpay_flutter  
**Notifications:** firebase_messaging  

---

## 7. Laravel Backend Structure

```
app/
  Http/Controllers/
    Auth/OtpController
    Customer/OrderController, ProductController, SubscriptionController
    Vendor/OrderController, ProductController, EarningsController
    Delivery/DeliveryController, LocationController
    Admin/ (all admin controllers)
  Models/
    User, Vendor, Product, Order, OrderItem, Subscription,
    Address, DeliveryBoyLocation, Notification, Review
  Services/
    OtpService, RazorpayService, FirebaseService,
    WhatsAppService, SubscriptionScheduler, TrackingService
  Policies/
    OrderPolicy, ProductPolicy (role enforcement)
routes/
  api.php
  web.php (admin panel)
database/migrations/
```

**Subscription cron:** Laravel scheduler runs daily at midnight to generate next day's subscription orders automatically.

---

## 8. Key Feature Flows

### Customer Orders Flow
1. Customer opens app → sees vendors nearby (based on saved address GPS)
2. Taps vendor → sees product list (20L can, 5L, 1L with prices)
3. Adds to cart → proceeds to checkout
4. Selects delivery address, time slot (morning/afternoon/evening), payment (COD or online)
5. If online: Razorpay sheet opens → UPI/card/wallet → signature verified server-side
6. Order placed → vendor gets push notification + WhatsApp message
7. Vendor accepts → assigns delivery boy → customer notified
8. Delivery boy picks up → marks "Out for Delivery" → live location starts broadcasting
9. Customer sees delivery boy on map with ETA
10. Delivery boy arrives → customer shows OTP → boy enters OTP → order marked Delivered
11. COD: boy marks cash collected. Online: already paid.
12. Customer gets invoice + prompted to rate

### Subscription Flow
1. Customer taps "Set Recurring Order" on any product
2. Sets: qty, frequency (daily/weekly/monthly), day, time slot, address, payment mode
3. Saved → scheduler auto-creates orders every cycle
4. Customer can pause, edit, or cancel anytime

### Vendor Order Management
1. New order arrives → push notification + WhatsApp alert
2. Vendor opens app → sees order details → Accept or Reject (with reason)
3. Accepted → taps "Assign Delivery Boy" → picks from own team list
4. Delivery boy notified on their phone
5. Vendor can see all their delivery boys' live locations on map

---

## 9. Admin Panel Features

Built as Laravel Blade web app (same codebase, separate auth guard):

- **Dashboard:** Today's orders count, revenue, active vendors, registered users
- **Vendors:** Approve/suspend vendors, view their products and order history
- **Users:** View all customers and delivery boys, activate/deactivate
- **Orders:** All orders across all vendors, filter by status/date/vendor
- **Subscriptions:** Active subscriptions, upcoming deliveries
- **Reports:** Vendor-wise sales, daily/monthly revenue, product popularity
- **Push Notifications:** Broadcast to all users, customers, or specific vendor's customers
- **Settings:** Service areas, app banner management

---

## 10. Non-Functional Requirements

| Concern | Approach |
|---------|---------|
| Security | JWT tokens, role-based middleware, OTP expiry 5 min, rate limiting on OTP endpoint |
| GPS Privacy | Delivery boy location only stored/shared during active delivery, deleted after |
| Offline | Flutter shows cached last order status; API handles reconnection gracefully |
| Performance | MySQL indexes on orders(status, vendor_id, customer_id); location table cleaned daily |
| Error handling | All API errors return consistent `{ success, message, errors }` structure |
| Scalability | Laravel structured as modules; can extract to microservices when needed |

---

## 11. What's NOT in V1 (keep it lean)

- iOS App Store listing (Android first, add iOS after validation)
- Multiple languages (English + 1 regional later)
- In-app chat between customer and vendor
- Loyalty/points system
- Vendor subscription/commission model (start free, monetize later)
- Route optimization for delivery boys (add in V2)

---

## 12. Infrastructure (Starting)

| Service | Cost/month |
|---------|-----------|
| VPS (4GB RAM, 2 CPU) | ₹1,500 |
| MySQL on same VPS | Included |
| Firebase (FCM, OTP) | Free |
| Google Maps API | Free up to 28,000 map loads/month |
| Razorpay | 2% per transaction |
| WhatsApp Business API | ₹0.35–₹0.85 per message |
| Domain + SSL | ₹800/year |
| **Total fixed/month** | **~₹2,000–₹2,500** |
