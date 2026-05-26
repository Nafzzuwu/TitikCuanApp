import 'package:flutter_test/flutter_test.dart';
import 'package:titikcuan/main.dart';

void main() {
  testWidgets('TitikCuan smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TitikCuanApp());
    expect(find.byType(TitikCuanApp), findsOneWidget);
  });
}
