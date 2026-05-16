import 'package:flutter_test/flutter_test.dart';
import 'package:water_app/main.dart';

void main() {
  testWidgets('WaterApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const WaterApp());
    expect(find.byType(WaterApp), findsOneWidget);
  });
}
