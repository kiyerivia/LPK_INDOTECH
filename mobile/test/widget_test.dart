import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lpk_indotech/apps/console_app.dart';
import 'package:lpk_indotech/apps/mitra_app.dart';
import 'package:lpk_indotech/apps/user_app.dart';
import 'package:lpk_indotech/config/app_version.dart';
import 'package:lpk_indotech/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
    'Default LPKIndotechApp launches CIJ Driving with clean title & version badge',
    (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const LPKIndotechApp());
      await tester.pumpAndSettle();

      expect(find.text('CIJ Driving'), findsOneWidget);
      expect(find.text('Daftar Akun Driving'), findsOneWidget);
      expect(find.text(AppVersions.driving.fullLabel), findsOneWidget);
    },
  );

  testWidgets(
    'App 1 (CIJ Driving): Email Verification, Clean Beta State & Edit Profil Siswa',
    (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const UserApp());
      await tester.pumpAndSettle();

      // 1. Tap text link "Daftar Akun Driving" -> Email Verification screen
      await tester.tap(find.text('Daftar Akun Driving'));
      await tester.pumpAndSettle();
      final regFields = find.byType(TextField);
      await tester.enterText(regFields.at(0), 'Rivia Putri');
      await tester.enterText(regFields.at(1), '08123456789');
      await tester.enterText(regFields.at(2), 'rivia@gmail.com');
      await tester.enterText(regFields.at(3), 'Rivia@2026');
      await tester.ensureVisible(find.text('Daftar Akun Siswa'));
      await tester.tap(find.text('Daftar Akun Siswa'));
      await tester.pumpAndSettle();
      expect(find.text('Verifikasi Email Siswa'), findsOneWidget);
      expect(find.text('Kirim Ulang Email Verifikasi'), findsOneWidget);

      await tester.ensureVisible(
        find.text('Sudah Verifikasi — Masuk Sekarang'),
      );
      await tester.tap(find.text('Sudah Verifikasi — Masuk Sekarang'));
      await tester.pumpAndSettle();

      // 2. Wrong-app RBAC rejects INDOTECH Master in UserApp & auto-clears both inputs
      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'INDOTECH');
      await tester.enterText(fields.at(1), 'Indotech@2026');
      await tester.tap(find.text('Masuk ke CIJ Driving'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Command Center'), findsOneWidget);
      expect(tester.widget<TextField>(fields.at(0)).controller?.text, isEmpty);
      expect(tester.widget<TextField>(fields.at(1)).controller?.text, isEmpty);

      // 4 more failed attempts (total 5x) -> auto-redirects to Pemulihan Kata Sandi Siswa!
      for (int i = 0; i < 4; i++) {
        await tester.enterText(fields.at(0), 'salah@gmail.com');
        await tester.enterText(fields.at(1), 'wrongpass');
        await tester.tap(find.text('Masuk ke CIJ Driving'));
        await tester.pumpAndSettle();
      }
      expect(find.text('Pemulihan Kata Sandi Siswa'), findsOneWidget);
      expect(find.textContaining('5x salah'), findsOneWidget);

      await tester.tap(find.text('← Kembali ke Masuk Siswa'));
      await tester.pumpAndSettle();

      // 3. Valid Siswa login -> Clean Beta State (0 bookings, 0 completed modules, 0 dummy drivers)
      final loginFields = find.byType(TextField);
      await tester.enterText(loginFields.at(0), 'siswa');
      await tester.enterText(loginFields.at(1), 'Siswa@2026');
      await tester.tap(find.text('Masuk ke CIJ Driving'));
      await tester.pumpAndSettle();
      expect(find.text('Belum Ada Mitra Instruktur Aktif'), findsOneWidget);

      // Check Rapor tab starts completely clean
      await tester.tap(find.text('Rapor'));
      await tester.pumpAndSettle();
      expect(find.text('0 dari 5 modul selesai'), findsOneWidget);
      expect(find.text('BELUM ADA NILAI • MULAI LATIHAN'), findsOneWidget);

      // Check Jadwal tab starts completely clean
      await tester.tap(find.text('Jadwal'));
      await tester.pumpAndSettle();
      expect(find.text('Belum Ada Sesi Aktif'), findsOneWidget);

      // 4. Test Edit Profil Siswa on Profil tab
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      expect(find.text('Edit Profil Siswa'), findsOneWidget);
      await tester.tap(find.text('Edit Profil Siswa'));
      await tester.pumpAndSettle();

      final editFields = find.byType(TextField);
      await tester.enterText(editFields.at(0), 'Rivia Beta');
      await tester.enterText(editFields.at(1), '0812-9999-8888');
      await tester.ensureVisible(find.text('Simpan Perubahan Profil'));
      await tester.tap(find.text('Simpan Perubahan Profil'));
      await tester.pumpAndSettle();

      expect(find.text('Rivia Beta'), findsOneWidget);
      expect(find.text('0812-9999-8888'), findsOneWidget);
    },
  );

  testWidgets(
    'App 2 (CIJ Mitra): Clean Beta State, KYC Register & Version Badge',
    (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const MitraApp());
      await tester.pumpAndSettle();

      expect(find.text('CIJ Mitra'), findsOneWidget);
      expect(find.text('Daftar Akun Mitra'), findsOneWidget);
      expect(find.text(AppVersions.partner.fullLabel), findsOneWidget);

      await tester.tap(find.text('Daftar Akun Mitra'));
      await tester.pumpAndSettle();
      expect(find.text('Armada & Plat Nomor'), findsOneWidget);
      expect(find.textContaining('Pedal Rem Ganda'), findsOneWidget);

      await tester.ensureVisible(
        find.textContaining('Masuk ke CIJ Mitra', findRichText: true),
      );
      await tester.tap(
        find.textContaining('Masuk ke CIJ Mitra', findRichText: true),
      );
      await tester.pumpAndSettle();

      // Reject Siswa on MitraApp
      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'siswa');
      await tester.enterText(fields.at(1), 'Siswa@2026');
      await tester.tap(find.text('Masuk ke CIJ Mitra'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Aplikasi Konsumen'), findsOneWidget);

      // Valid Mitra login -> Clean Beta State (OFFLINE, Rp 0 saldo, 0 orders)
      await tester.enterText(fields.at(0), 'mitra');
      await tester.enterText(fields.at(1), 'Mitra@2026');
      await tester.tap(find.text('Masuk ke CIJ Mitra'));
      await tester.pumpAndSettle();
      expect(find.text('OFFLINE • ISTIRAHAT'), findsOneWidget);
      expect(find.text('Rp 0'), findsOneWidget);
    },
  );

  testWidgets(
    'App 3 (CIJ Master): Clean Beta State, LPK Registration & Version Badge',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const ConsoleApp());
      await tester.pumpAndSettle();

      expect(find.text('CIJ Master'), findsOneWidget);
      expect(find.text('Daftar Akun Master'), findsOneWidget);
      expect(find.text(AppVersions.console.fullLabel), findsOneWidget);

      // Open LPK Registration via text link and return
      await tester.tap(find.text('Daftar Akun Master'));
      await tester.pumpAndSettle();
      expect(find.text('Nomor Izin LPK Kemnaker / NIB'), findsOneWidget);
      await tester.ensureVisible(
        find.textContaining('Masuk ke CIJ Master', findRichText: true),
      );
      await tester.tap(
        find.textContaining('Masuk ke CIJ Master', findRichText: true),
      );
      await tester.pumpAndSettle();

      // 1. Login as INDOTECH Master
      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'INDOTECH');
      await tester.enterText(fields.at(1), 'Indotech@2026');
      await tester.tap(find.text('Masuk ke CIJ Master'));
      await tester.pumpAndSettle();
      expect(find.text('MASTER INDOTECH HQ'), findsOneWidget);
      expect(find.text('Verif LPK'), findsOneWidget);

      // 2. Logout & login as LPK Super Admin -> Rp 0 clean beta omzet
      await tester.tap(find.byIcon(Icons.logout_rounded));
      await tester.pumpAndSettle();
      final fields2 = find.byType(TextField);
      await tester.enterText(fields2.at(0), 'superadmin');
      await tester.enterText(fields2.at(1), 'SuperAdmin@CIJ2026');
      await tester.tap(find.text('Masuk ke CIJ Master'));
      await tester.pumpAndSettle();
      expect(find.text('Verif LPK'), findsNothing);
      expect(find.text('Rp 0'), findsWidgets);
    },
  );
}
