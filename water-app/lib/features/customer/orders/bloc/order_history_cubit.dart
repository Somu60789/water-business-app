import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:water_app/shared/models/order.dart';
import 'package:water_app/shared/services/api_client.dart';

abstract class OrderHistoryState extends Equatable { const OrderHistoryState(); }
class OrderHistoryInitial extends OrderHistoryState { @override List<Object> get props => []; }
class OrderHistoryLoading extends OrderHistoryState { @override List<Object> get props => []; }
class OrderHistoryLoaded  extends OrderHistoryState {
  final List<Order> orders;
  const OrderHistoryLoaded(this.orders);
  @override List<Object> get props => [orders];
}
class OrderHistoryError   extends OrderHistoryState {
  final String message;
  const OrderHistoryError(this.message);
  @override List<Object> get props => [message];
}

class OrderHistoryCubit extends Cubit<OrderHistoryState> {
  final ApiClient api;
  OrderHistoryCubit({required this.api}) : super(OrderHistoryInitial());

  Future<void> load() async {
    emit(OrderHistoryLoading());
    try {
      final data   = await api.getOrders();
      final orders = data.map(Order.fromJson).toList();
      emit(OrderHistoryLoaded(orders));
    } catch (e) {
      emit(OrderHistoryError(e.toString()));
    }
  }
}
