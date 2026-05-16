import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:water_app/shared/models/vendor.dart';
import 'package:water_app/shared/services/api_client.dart';

abstract class VendorListState extends Equatable { const VendorListState(); }
class VendorListInitial extends VendorListState { @override List<Object> get props => []; }
class VendorListLoading extends VendorListState { @override List<Object> get props => []; }
class VendorListLoaded  extends VendorListState {
  final List<Vendor> vendors;
  const VendorListLoaded(this.vendors);
  @override List<Object> get props => [vendors];
}
class VendorListError   extends VendorListState {
  final String message;
  const VendorListError(this.message);
  @override List<Object> get props => [message];
}

class VendorListCubit extends Cubit<VendorListState> {
  final ApiClient api;
  VendorListCubit({required this.api}) : super(VendorListInitial());

  Future<void> fetchVendors(double lat, double lng) async {
    emit(VendorListLoading());
    try {
      final data    = await api.getVendors(lat, lng);
      final vendors = data.map(Vendor.fromJson).toList();
      emit(VendorListLoaded(vendors));
    } catch (e) {
      emit(VendorListError(e.toString()));
    }
  }
}
