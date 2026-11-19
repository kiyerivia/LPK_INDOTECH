import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lpk_indotech/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const LPKIndotechApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
