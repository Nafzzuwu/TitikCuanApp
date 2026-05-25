// This is a basic Flutter widget test for TitikCuan app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:titikcuan/main.dart';

void main() {
  testWidgets('SplashScreen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TitikCuanApp());

    // Verify that the SplashScreen shows the app title.
    expect(find.text('TitikCuan'), findsOneWidget);

    // Verify that the tagline is displayed.
    expect(find.text('Cuan di setiap titik jualanmu'), findsOneWidget);

    // Verify the logo icon is present.
    expect(find.byIcon(Icons.location_on_outlined), findsOneWidget);
  });
}
