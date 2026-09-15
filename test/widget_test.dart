import 'package:flutter_test/flutter_test.dart';
import 'package:fayzox/fayzox_app.dart';

void main() {
  testWidgets('FayzoxApp tab smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FayzoxApp());
    expect(find.text('FAYZOX SHADE STUDIO'), findsOneWidget);
    expect(find.text('Shade Ramp'), findsOneWidget);
  });
}
