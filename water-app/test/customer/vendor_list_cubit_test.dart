import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:water_app/features/customer/home/bloc/vendor_list_cubit.dart';
import 'package:water_app/shared/services/api_client.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late VendorListCubit cubit;
  late MockApiClient mockApi;

  setUp(() {
    mockApi = MockApiClient();
    cubit   = VendorListCubit(api: mockApi);
  });
  tearDown(() => cubit.close());

  blocTest<VendorListCubit, VendorListState>(
    'emits [loading, loaded] on successful fetch',
    build: () {
      when(() => mockApi.getVendors(any(), any())).thenAnswer((_) async => [
        {'id': 1, 'user_id': 2, 'business_name': 'Bisleri Co', 'address': '1 MG Road', 'lat': 12.97, 'lng': 77.59, 'service_radius_km': 10, 'is_open': true}
      ]);
      return cubit;
    },
    act: (c) => c.fetchVendors(12.97, 77.59),
    expect: () => [isA<VendorListLoading>(), isA<VendorListLoaded>()],
  );
}
