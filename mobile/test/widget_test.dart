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

  testWidgets('Default LPKIndotechApp launches App 1 (CIJ Driving / UserAuthScreen) directly', (tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const LPKIndotechApp());
    await tester.pumpAndSettle();

    expect(find.text('CIJ DRIVING • APLIKASI KONSUMEN / SISWA'), findsOneWidget);
    expect(find.text('Masuk Siswa'), findsOneWidget);
    expect(find.text('Daftar Siswa'), findsOneWidget);
  });

  testWidgets('App 1 (UserApp) dedicated Login & Register Siswa dashboard + Siswa-only RBAC', (tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const UserApp());
    await tester.pumpAndSettle();

    // Switch to Daftar Siswa tab and verify Siswa-specific fields
    await tester.tap(find.text('Daftar Siswa'));
    await tester.pumpAndSettle();
    expect(find.text('Pilihan Transmisi Belajar'), findsOneWidget);
    expect(find.text('Area Jemput Latihan'), findsOneWidget);

    // Switch back to Masuk Siswa
    await tester.tap(find.text('Masuk Siswa'));
    await tester.pumpAndSettle();

    // Master account MUST be rejected in UserApp (wrong app!)
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'INDOTECH');
    await tester.enterText(fields.at(1), 'Indotech@2026');
    await tester.tap(find.text('Masuk ke CIJ Driving'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Command Center'), findsOneWidget);

    // Valid Siswa logs in cleanly
    await tester.enterText(fields.at(0), 'siswa');
    await tester.enterText(fields.at(1), 'Siswa@2026');
    await tester.tap(find.text('Masuk ke CIJ Driving'));
    await tester.pumpAndSettle();
    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('Cari'), findsOneWidget);
  });

  testWidgets('App 2 (MitraApp) dedicated GoPartner Login & Register KYC dashboard + Mitra-only RBAC', (tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MitraApp());
    await tester.pumpAndSettle();

    expect(find.text('CIJ PARTNER • APLIKASI MITRA DRIVER'), findsOneWidget);
    expect(find.textContaining('60% Mitra'), findsOneWidget);

    // Switch to Daftar Mitra Baru tab and verify Dual-Brake safety & Vehicle fields
    await tester.tap(find.text('Daftar Mitra Baru'));
    await tester.pumpAndSettle();
    expect(find.text('Armada & Plat Nomor'), findsOneWidget);
    expect(find.textContaining('Pedal Rem Ganda'), findsOneWidget);

    // Switch back to Masuk Mitra
    await tester.tap(find.text('Masuk Mitra'));
    await tester.pumpAndSettle();

    // Siswa account MUST be rejected in MitraApp
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'siswa');
    await tester.enterText(fields.at(1), 'Siswa@2026');
    await tester.tap(find.text('Masuk & Mulai ON BID'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Aplikasi Konsumen'), findsOneWidget);

    // Valid Mitra logs in cleanly
    await tester.enterText(fields.at(0), 'mitra');
    await tester.enterText(fields.at(1), 'Mitra@2026');
    await tester.tap(find.text('Masuk & Mulai ON BID'));
    await tester.pumpAndSettle();
    expect(find.textContaining('ON BID'), findsOneWidget);
  });

  testWidgets('App 3 (ConsoleApp) dedicated Executive Login & Register LPK Baru + Master/LPK separation', (tester) async {
    // Test responsive Desktop Split Dashboard layout (1280x900)
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ConsoleApp());
    await tester.pumpAndSettle();

    expect(find.text('INDOTECH MASTER & LPK CONSOLE'), findsOneWidget);
    expect(find.text('CIJ COMMAND CENTER • HOLDING & LPK'), findsOneWidget);

    // Switch to Daftar LPK Baru and verify Kemnaker license + Master verification notice
    await tester.tap(find.text('Daftar LPK Baru'));
    await tester.pumpAndSettle();
    expect(find.text('Nomor Izin LPK Kemnaker / NIB'), findsOneWidget);
    expect(find.textContaining('MASTER INDOTECH'), findsWidgets);

    // Switch back to Masuk Console
    await tester.tap(find.text('Masuk Console'));
    await tester.pumpAndSettle();

    // 1. Login as INDOTECH Master -> gets National Overview + Verif LPK tab!
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'INDOTECH');
    await tester.enterText(fields.at(1), 'Indotech@2026');
    await tester.tap(find.text('Masuk Command Center'));
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
    await tester.tap(find.text('Masuk Command Center'));
    await tester.pumpAndSettle();
    expect(find.text('Verif LPK'), findsNothing);
    expect(find.textContaining('Total Omzet'), findsOneWidget);
  });
}
