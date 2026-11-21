import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lpk_indotech/main.dart';

void main() {
  testWidgets('Clean Neumorphic Auth, Biometric Security & Super Admin RBAC test', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const LPKIndotechApp());
    await tester.pumpAndSettle();

    // 1. Verify circled top clutter & login role tabs are GONE
    expect(find.text('LPK CITRA INDOTECH JAYA'), findsOneWidget);
    expect(find.text('Dark Mode'), findsNothing);
    expect(find.text('Indonesia'), findsNothing);
    expect(find.text('← Beranda'), findsNothing);
    expect(find.text('Admin'), findsNothing);

    // 2. Biometric tap MUST reject securely when not enrolled yet (no bypass!)
    final fpFinder = find.byIcon(Icons.fingerprint_rounded);
    await tester.ensureVisible(fpFinder);
    await tester.tap(fpFinder);
    await tester.pumpAndSettle();
    expect(find.textContaining('belum terdaftar'), findsOneWidget);

    // 3. Wrong password MUST be rejected
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'superadmin');
    await tester.enterText(fields.at(1), 'wrongpass');
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Kata sandi salah'), findsOneWidget);

    // 4. Valid MASTER INDOTECH credentials unlock Master Verification Console & role switcher
    await tester.enterText(fields.at(0), 'INDOTECH');
    await tester.enterText(fields.at(1), 'Indotech@2026');
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Total Omzet'), findsOneWidget);
    expect(find.text('MASTER INDOTECH'), findsOneWidget);
    expect(find.text('Admin LPK'), findsOneWidget);
    expect(find.text('Mitra Driver'), findsOneWidget);
    expect(find.text('Siswa'), findsWidgets);

    // MASTER INDOTECH can open Atur tab and see Master verification authority + biometric security card
    await tester.tap(find.text('Atur'));
    await tester.pumpAndSettle();
    expect(find.text('Otoritas Verifikasi MASTER INDOTECH'), findsOneWidget);
    expect(find.text('MASTER INDOTECH'), findsWidgets);
    expect(find.text('Keamanan Sidik Jari (Biometrik)'), findsOneWidget);

    // 5. Logout and sign in as regular Siswa -> Admin tab must NOT be visible!
    await tester.tap(find.byIcon(Icons.logout_rounded));
    await tester.pumpAndSettle();
    final loginFields = find.byType(TextField);
    await tester.enterText(loginFields.at(0), 'siswa');
    await tester.enterText(loginFields.at(1), 'Siswa@2026');
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();

    expect(find.text('Admin LPK'), findsNothing);
    expect(find.text('Super Admin'), findsNothing);
    expect(find.text('Beranda'), findsOneWidget);
  });
}
