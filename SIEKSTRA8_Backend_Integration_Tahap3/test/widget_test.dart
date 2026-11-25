import 'package:flutter_test/flutter_test.dart';
import 'package:siekstra8/main.dart';

void main() {
  testWidgets('App menampilkan layar Welcome', (tester) async {
    await tester.pumpWidget(const SiekstraApp());
    expect(find.byType(SiekstraApp), findsOneWidget);
  });
}
