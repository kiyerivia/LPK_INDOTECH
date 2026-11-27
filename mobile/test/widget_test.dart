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

  testWidgets('Default LPKIndotechApp launches CIJ Driving cleanly', (tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const LPKIndotechApp());
    await tester.pumpAndSettle();

    expect(find.text('CIJ Driving'), findsOneWidget);
    expect(find.text('Daftar Akun Driving'), findsOneWidget);
    expect(find.text(AppVersions.driving.shortLabel), findsOneWidget);
  });

  testWidgets('App 1 (CIJ Driving): Sequential WA OTP -> Email OTP -> Register, 5x Lockout & Edit Profile', (tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const UserApp());
    await tester.pumpAndSettle();

    // 1. Open Register
    await tester.tap(find.text('Daftar Akun Driving'));
    await tester.pumpAndSettle();
    expect(find.text('Daftar Akun Baru'), findsOneWidget);
    expect(find.text('Pilihan Transmisi Belajar'), findsNothing);
    expect(find.text('Area Jemput Latihan'), findsNothing);

    // Fill Nama + WhatsApp and send WA OTP
    final regFields = find.byType(TextField);
    await tester.enterText(regFields.at(0), 'Rivia Putri');
    await tester.enterText(regFields.at(1), '081234567890');
    await tester.tap(find.text('Kirim OTP').first);
    await tester.pumpAndSettle();

    final waCodeWidget = tester.widget<Text>(find.textContaining('Kode OTP uji coba:'));
    final waCode = RegExp(r'\d{6}').firstMatch(waCodeWidget.data!)!.group(0)!;
    await tester.enterText(find.widgetWithText(TextField, '6 digit kode'), waCode);
    await tester.tap(find.text('Verifikasi'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

    // Fill Email and send Email OTP
    await tester.enterText(find.widgetWithText(TextField, 'nama@email.com'), 'rivia.otp@gmail.com');
    await tester.tap(find.text('Kirim OTP'));
    await tester.pumpAndSettle();

    final emailCodeWidget = tester.widget<Text>(find.textContaining('Kode OTP uji coba:'));
    final emailCode = RegExp(r'\d{6}').firstMatch(emailCodeWidget.data!)!.group(0)!;
    await tester.enterText(find.widgetWithText(TextField, '6 digit kode'), emailCode);
    await tester.tap(find.text('Verifikasi'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check_circle_rounded), findsNWidgets(2));

    // Enter password and create account
    await tester.enterText(find.widgetWithText(TextField, 'Minimal 6 karakter'), 'Rivia@2026');
    await tester.ensureVisible(find.text('Daftar'));
    await tester.tap(find.text('Daftar'));
    await tester.pumpAndSettle();
    expect(find.text('Masuk'), findsOneWidget);

    // 2. Wrong login clears inputs & 5x wrong redirects to Forgot Password
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'INDOTECH');
    await tester.enterText(fields.at(1), 'Indotech@2026');
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(fields.at(0)).controller?.text, isEmpty);
    expect(tester.widget<TextField>(fields.at(1)).controller?.text, isEmpty);

    for (int i = 0; i < 4; i++) {
      await tester.enterText(fields.at(0), 'salah@gmail.com');
      await tester.enterText(fields.at(1), 'wrongpass');
      await tester.tap(find.text('Masuk'));
      await tester.pumpAndSettle();
    }
    expect(find.text('Lupa Kata Sandi'), findsOneWidget);
    await tester.tap(find.text('Kembali ke Halaman Masuk'));
    await tester.pumpAndSettle();

    // 3. Log in with newly verified account
    final loginFields = find.byType(TextField);
    await tester.enterText(loginFields.at(0), 'rivia.otp@gmail.com');
    await tester.enterText(loginFields.at(1), 'Rivia@2026');
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();
    expect(find.text('Belum Ada Mitra Instruktur Aktif'), findsOneWidget);

    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    expect(find.text('Rivia Putri'), findsOneWidget);
    await tester.tap(find.text('Edit Profil Siswa'));
    await tester.pumpAndSettle();
    final editFields = find.byType(TextField);
    await tester.enterText(editFields.at(0), 'Rivia Beta');
    await tester.ensureVisible(find.text('Simpan Perubahan Profil'));
    await tester.tap(find.text('Simpan Perubahan Profil'));
    await tester.pumpAndSettle();
    expect(find.text('Rivia Beta'), findsOneWidget);
  });

  testWidgets('App 2 (CIJ Mitra): Register Gate & Clean Beta State', (tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MitraApp());
    await tester.pumpAndSettle();

    expect(find.text('CIJ Mitra'), findsOneWidget);
    expect(find.text(AppVersions.partner.shortLabel), findsOneWidget);

    await tester.tap(find.text('Daftar Akun Mitra'));
    await tester.pumpAndSettle();
    expect(find.text('Daftar Mitra'), findsOneWidget);

    await tester.ensureVisible(find.textContaining('Masuk', findRichText: true).last);
    await tester.tap(find.textContaining('Masuk', findRichText: true).last);
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'mitra');
    await tester.enterText(fields.at(1), 'Mitra@2026');
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();
    expect(find.text('OFFLINE • ISTIRAHAT'), findsOneWidget);
    expect(find.text('Rp 0'), findsOneWidget);
  });

  testWidgets('App 3 (CIJ Master): Register Gate & Clean Beta State', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ConsoleApp());
    await tester.pumpAndSettle();

    expect(find.text('CIJ Master'), findsOneWidget);
    expect(find.text(AppVersions.console.shortLabel), findsOneWidget);

    await tester.tap(find.text('Daftar Akun Master'));
    await tester.pumpAndSettle();
    expect(find.text('Ajukan Pendaftaran'), findsOneWidget);
    await tester.ensureVisible(find.textContaining('Masuk', findRichText: true).last);
    await tester.tap(find.textContaining('Masuk', findRichText: true).last);
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'INDOTECH');
    await tester.enterText(fields.at(1), 'Indotech@2026');
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();
    expect(find.text('MASTER INDOTECH HQ'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.logout_rounded));
    await tester.pumpAndSettle();
    final fields2 = find.byType(TextField);
    await tester.enterText(fields2.at(0), 'superadmin');
    await tester.enterText(fields2.at(1), 'SuperAdmin@CIJ2026');
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();
    expect(find.text('Verif LPK'), findsNothing);
    expect(find.text('Rp 0'), findsWidgets);
  });
}
