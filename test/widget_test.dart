import 'package:flutter_test/flutter_test.dart';
import 'package:fayzox/presentation/fayzox_app.dart';

void main() {
  testWidgets('FayzoxStudioApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FayzoxStudioApp());
    expect(find.byType(FayzoxStudioApp), findsOneWidget);
  });
}