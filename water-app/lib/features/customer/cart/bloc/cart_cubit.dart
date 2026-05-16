import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:water_app/shared/models/product.dart';

abstract class CartState extends Equatable { const CartState(); }
class CartUpdated extends CartState {
  final Map<Product, int> items;
  const CartUpdated(this.items);

  double get total => items.entries.fold(0, (sum, e) => sum + e.key.price * e.value);
  int    get count => items.values.fold(0, (sum, v) => sum + v);

  @override List<Object> get props => [items];
}

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(const CartUpdated({}));

  Map<Product, int> get _items => state is CartUpdated ? Map.of((state as CartUpdated).items) : {};

  void addItem(Product product) {
    final items = _items;
    items[product] = (items[product] ?? 0) + 1;
    emit(CartUpdated(items));
  }

  void removeItem(Product product) {
    final items = _items;
    if ((items[product] ?? 0) <= 1) {
      items.remove(product);
    } else {
      items[product] = items[product]! - 1;
    }
    emit(CartUpdated(items));
  }

  void clear() => emit(const CartUpdated({}));
}
