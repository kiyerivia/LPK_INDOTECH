import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lpk_indotech/apps/console_app.dart';
import 'package:lpk_indotech/apps/mitra_app.dart';
import 'package:lpk_indotech/apps/user_app.dart';
import 'package:lpk_indotech/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Default LPKIndotechApp launches App 1 (UserApp / Siswa) directly without portal', (tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const LPKIndotechApp());
    await tester.pumpAndSettle();

    expect(find.text('APLIKASI KONSUMEN / SISWA'), findsOneWidget);
    expect(find.text('Pilih Aplikasi Ekosistem Driving Partner'), findsNothing);
  });

  testWidgets('App 1 (UserApp) enforces Siswa-only RBAC and opens consumer dashboard', (tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const UserApp());
    await tester.pumpAndSettle();

    expect(find.text('APLIKASI KONSUMEN / SISWA'), findsOneWidget);

    // Master account MUST be rejected in UserApp (wrong app!)
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'INDOTECH');
    await tester.enterText(fields.at(1), 'Indotech@2026');
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Command Center'), findsOneWidget);

    // Valid Siswa logs in cleanly
    await tester.enterText(fields.at(0), 'siswa');
    await tester.enterText(fields.at(1), 'Siswa@2026');
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();
    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('Cari'), findsOneWidget);
  });

  testWidgets('App 2 (MitraApp) enforces Mitra-only RBAC and opens ON BID driver dashboard', (tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MitraApp());
    await tester.pumpAndSettle();

    expect(find.text('APLIKASI MITRA DRIVER'), findsOneWidget);

    // Siswa account MUST be rejected in MitraApp
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'siswa');
    await tester.enterText(fields.at(1), 'Siswa@2026');
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Aplikasi Konsumen'), findsOneWidget);

    // Valid Mitra logs in cleanly
    await tester.enterText(fields.at(0), 'mitra');
    await tester.enterText(fields.at(1), 'Mitra@2026');
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();
    expect(find.textContaining('ON BID'), findsOneWidget);
  });

  testWidgets('App 3 (ConsoleApp) separates 1. INDOTECH Master and 2. LPK Super Admin', (tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ConsoleApp());
    await tester.pumpAndSettle();

    expect(find.text('INDOTECH MASTER & LPK CONSOLE'), findsOneWidget);
    expect(find.textContaining('Daftar sekarang', findRichText: true), findsNothing);

    // 1. Login as INDOTECH Master -> gets National Overview + Verif LPK tab!
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'INDOTECH');
    await tester.enterText(fields.at(1), 'Indotech@2026');
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();
    expect(find.text('MASTER INDOTECH HQ'), findsOneWidget);
    expect(find.text('Verif LPK'), findsOneWidget);

    await tester.tap(find.text('Verif LPK'));
    await tester.pumpAndSettle();
    expect(find.text('Verifikasi LPK (Otoritas Master)'), findsOneWidget);

    // 2. Logout & login as LPK Super Admin -> gets LPK Operations ONLY (no Verif LPK Master tab!)
    await tester.tap(find.byIcon(Icons.logout_rounded));
    await tester.pumpAndSettle();
    final fields2 = find.byType(TextField);
    await tester.enterText(fields2.at(0), 'superadmin');
    await tester.enterText(fields2.at(1), 'SuperAdmin@CIJ2026');
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();
    expect(find.text('Verif LPK'), findsNothing);
    expect(find.textContaining('Total Omzet'), findsOneWidget);
  });
}
