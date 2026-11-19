import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lpk_indotech/main.dart';

void main() {
  testWidgets('LPK Driving Partner 3-role ecosystem smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const LPKIndotechApp());
    await tester.pumpAndSettle();

    // Siswa mode loads by default
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Siswa'), findsOneWidget);
    expect(find.text('Mitra Driver'), findsOneWidget);
    expect(find.text('Admin LPK'), findsOneWidget);

    // Switch to Mitra Driver (Ojol style)
    await tester.tap(find.text('Mitra Driver'));
    await tester.pumpAndSettle();
    expect(find.textContaining('ON BID'), findsOneWidget);

    // Switch to Admin LPK
    await tester.tap(find.text('Admin LPK'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Total Omzet'), findsOneWidget);
  });
}
