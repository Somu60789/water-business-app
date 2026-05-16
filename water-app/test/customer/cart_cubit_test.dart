import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:water_app/features/customer/cart/bloc/cart_cubit.dart';
import 'package:water_app/shared/models/product.dart';

void main() {
  late CartCubit cubit;

  setUp(() => cubit = CartCubit());
  tearDown(() => cubit.close());

  const product = Product(
    id: 1, vendorId: 1, name: '20L Can', unit: '20L',
    price: 55.0, stockQty: 100, isAvailable: true,
  );

  blocTest<CartCubit, CartState>(
    'addItem emits CartUpdated with qty 1',
    build: () => cubit,
    act: (c) => c.addItem(product),
    expect: () => [
      predicate<CartState>((s) => s is CartUpdated && s.items[product] == 1),
    ],
  );

  blocTest<CartCubit, CartState>(
    'addItem twice emits CartUpdated with qty 2',
    build: () => cubit,
    act: (c) { c.addItem(product); c.addItem(product); },
    expect: () => [
      predicate<CartState>((s) => s is CartUpdated && s.items[product] == 1),
      predicate<CartState>((s) => s is CartUpdated && s.items[product] == 2),
    ],
  );

  blocTest<CartCubit, CartState>(
    'removeItem decrements qty',
    build: () => cubit,
    seed: () => CartUpdated({product: 2}),
    act: (c) => c.removeItem(product),
    expect: () => [
      predicate<CartState>((s) => s is CartUpdated && s.items[product] == 1),
    ],
  );

  blocTest<CartCubit, CartState>(
    'clear empties cart',
    build: () => cubit,
    seed: () => CartUpdated({product: 2}),
    act: (c) => c.clear(),
    expect: () => [predicate<CartState>((s) => s is CartUpdated && s.items.isEmpty)],
  );
}
