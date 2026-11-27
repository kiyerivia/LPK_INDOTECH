import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lpk_indotech/apps/console_app.dart';
import 'package:lpk_indotech/apps/mitra_app.dart';
import 'package:lpk_indotech/apps/user_app.dart';
import 'package:lpk_indotech/models/app_models.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Demo Login shortcut works on CIJ Driving, CIJ Mitra, and CIJ Master', (tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    // 1. CIJ Driving demo login
    await tester.pumpWidget(const UserApp());
    await tester.pumpAndSettle();
    expect(find.text('Gunakan akun demo untuk login'), findsOneWidget);
    await tester.tap(find.text('Gunakan akun demo untuk login'));
    await tester.pumpAndSettle();
    expect(find.text('Halo, Demo'), findsOneWidget);

    // 2. CIJ Mitra demo login
    await tester.pumpWidget(const MitraApp());
    await tester.pumpAndSettle();
    expect(find.text('Gunakan akun demo untuk login'), findsOneWidget);
    await tester.tap(find.text('Gunakan akun demo untuk login'));
    await tester.pumpAndSettle();
    expect(find.text('Demo Mitra CIJ'), findsOneWidget);

    // 3. CIJ Master demo login
    await tester.pumpWidget(const ConsoleApp());
    await tester.pumpAndSettle();
    expect(find.text('Gunakan akun demo untuk login'), findsOneWidget);
    await tester.tap(find.text('Gunakan akun demo untuk login'));
    await tester.pumpAndSettle();
    expect(find.text('MASTER INDOTECH HQ'), findsOneWidget);
  });

  testWidgets(
    'Full Simulation: Register Driver -> Approve -> Register Siswa -> Book & Pay -> Escrow Lock -> Finish Course -> Bank Withdrawal',
    (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final sharedState = AppState();

      // =========================================================================
      // STEP 1: Mitra Driver mendaftar akun baru di CIJ Mitra (WA OTP + Email OTP)
      // =========================================================================
      await tester.pumpWidget(MitraApp(sharedState: sharedState));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Daftar Akun Mitra'));
      await tester.pumpAndSettle();

      final mitraFields = find.byType(TextField);
      await tester.enterText(mitraFields.at(0), 'Andi Pratama');
      await tester.enterText(mitraFields.at(1), '081234567801');
      await tester.tap(find.text('Kirim OTP').first);
      await tester.pumpAndSettle();

      final driverWaText = tester.widget<Text>(find.textContaining('Kode OTP uji coba:')).data!;
      final driverWaOtp = RegExp(r'\d{6}').firstMatch(driverWaText)!.group(0)!;
      await tester.enterText(find.widgetWithText(TextField, '6 digit kode'), driverWaOtp);
      await tester.tap(find.text('Verifikasi'));
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextField, 'nama@email.com'), 'andi.driver@cij.id');
      await tester.tap(find.text('Kirim OTP'));
      await tester.pumpAndSettle();

      final driverEmailText = tester.widget<Text>(find.textContaining('Kode OTP uji coba:')).data!;
      final driverEmailOtp = RegExp(r'\d{6}').firstMatch(driverEmailText)!.group(0)!;
      await tester.enterText(find.widgetWithText(TextField, '6 digit kode'), driverEmailOtp);
      await tester.tap(find.text('Verifikasi'));
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextField, 'Toyota Avanza - R 1842 BS'), 'Honda Brio - R 4512 CD');
      await tester.enterText(find.widgetWithText(TextField, 'SIM A Aktif'), 'SIM A Aktif');
      await tester.enterText(find.widgetWithText(TextField, 'Minimal 6 karakter'), 'Driver@2026');
      await tester.ensureVisible(find.text('Daftar Mitra'));
      await tester.tap(find.text('Daftar Mitra'));
      await tester.pumpAndSettle();

      expect(sharedState.pendingMitras.length, 1);
      expect(sharedState.pendingMitras.first.name, 'Andi Pratama');

      // =========================================================================
      // STEP 2: Admin / Master menyetujui KYC & Rem Ganda driver di CIJ Master
      // =========================================================================
      await tester.pumpWidget(ConsoleApp(sharedState: sharedState));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Gunakan akun demo untuk login'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Audit'));
      await tester.pumpAndSettle();
      expect(find.text('Andi Pratama'), findsOneWidget);

      await tester.ensureVisible(find.text('Setujui & Aktifkan ke Radar Siswa'));
      await tester.tap(find.text('Setujui & Aktifkan ke Radar Siswa'));
      await tester.pumpAndSettle();

      expect(sharedState.instructors.length, 1);
      expect(sharedState.instructors.first.name, 'Andi Pratama');

      // Logout dari Master sebelum lanjut ke CIJ Driving
      sharedState.logout();

      // =========================================================================
      // STEP 3: Siswa mendaftar akun baru & booking driver di CIJ Driving
      // =========================================================================
      await tester.pumpWidget(UserApp(sharedState: sharedState));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Daftar Akun Driving'));
      await tester.pumpAndSettle();

      final siswaRegFields = find.byType(TextField);
      await tester.enterText(siswaRegFields.at(0), 'Siti Rahma');
      await tester.enterText(siswaRegFields.at(1), '081345678902');
      await tester.tap(find.text('Kirim OTP').first);
      await tester.pumpAndSettle();

      final siswaWaText = tester.widget<Text>(find.textContaining('Kode OTP uji coba:')).data!;
      final siswaWaOtp = RegExp(r'\d{6}').firstMatch(siswaWaText)!.group(0)!;
      await tester.enterText(find.widgetWithText(TextField, '6 digit kode'), siswaWaOtp);
      await tester.tap(find.text('Verifikasi'));
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextField, 'nama@email.com'), 'siti.rahma@cij.id');
      await tester.tap(find.text('Kirim OTP'));
      await tester.pumpAndSettle();

      final siswaEmailText = tester.widget<Text>(find.textContaining('Kode OTP uji coba:')).data!;
      final siswaEmailOtp = RegExp(r'\d{6}').firstMatch(siswaEmailText)!.group(0)!;
      await tester.enterText(find.widgetWithText(TextField, '6 digit kode'), siswaEmailOtp);
      await tester.tap(find.text('Verifikasi'));
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextField, 'Minimal 6 karakter'), 'Siswa@2026');
      await tester.ensureVisible(find.text('Daftar'));
      await tester.tap(find.text('Daftar'));
      await tester.pumpAndSettle();

      // Login sebagai siswa baru
      final siswaLoginFields = find.byType(TextField);
      await tester.enterText(siswaLoginFields.at(0), 'siti.rahma@cij.id');
      await tester.enterText(siswaLoginFields.at(1), 'Siswa@2026');
      await tester.tap(find.text('Masuk'));
      await tester.pumpAndSettle();

      expect(find.text('Halo, Siti'), findsOneWidget);
      expect(find.text('Andi Pratama'), findsOneWidget);

      // Buka tab Cari (Radar) dan booking Andi Pratama (Paket Standar SIM A: Rp 1.500.000 -> Mitra 60% = Rp 900.000)
      await tester.tap(find.text('Cari'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Andi Pratama'), findsWidgets);

      await tester.ensureVisible(find.textContaining('Pilih & Booking'));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.textContaining('Pilih & Booking'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Step 0 -> Step 1 (Pilih Jadwal)
      await tester.ensureVisible(find.text('Pilih Jadwal'));
      await tester.tap(find.text('Pilih Jadwal'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Step 1 -> Step 2 (Review & Bayar)
      await tester.ensureVisible(find.text('Review & Bayar'));
      await tester.tap(find.text('Review & Bayar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Step 2 -> Step 3 (Bayar & Order Mitra)
      await tester.ensureVisible(find.text('Bayar & Order Mitra'));
      await tester.tap(find.text('Bayar & Order Mitra'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Order Terkirim'), findsOneWidget);
      await tester.tap(find.text('Lihat di Jadwal Saya'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(sharedState.orders.length, 1);
      expect(sharedState.orders.first.studentName, 'Siti Rahma');
      expect(sharedState.orders.first.instructorName, 'Andi Pratama');
      expect(sharedState.orders.first.totalPrice, 1500000);
      expect(sharedState.orders.first.mitraEarning, 900000);

      // Logout dari Siswa untuk masuk ke aplikasi Mitra Driver
      sharedState.logout();

      // =========================================================================
      // STEP 4: Driver login di CIJ Mitra, verifikasi dana DITAHAN sebelum selesai
      // =========================================================================
      await tester.pumpWidget(MitraApp(sharedState: sharedState));
      await tester.pumpAndSettle();

      final driverLoginFields = find.byType(TextField);
      await tester.enterText(driverLoginFields.at(0), 'andi.driver@cij.id');
      await tester.enterText(driverLoginFields.at(1), 'Driver@2026');
      await tester.tap(find.text('Masuk'));
      await tester.pumpAndSettle();

      expect(find.text('Andi Pratama'), findsOneWidget);

      // Cek Dompet SEBELUM kursus selesai: Rp 0 siap cair, Rp 900.000 ditahan, pencairan TERKUNCI!
      await tester.tap(find.text('Dompet'));
      await tester.pumpAndSettle();

      expect(sharedState.mitraWalletBalance, 0);
      expect(sharedState.mitraEscrowBalance, 900000);
      expect(sharedState.canWithdrawMitraWallet, isFalse);
      expect(sharedState.withdrawWallet(900000, 'Bank BCA ****4821'), isFalse);
      expect(find.text('Dana Ditahan (Kursus Berjalan)'), findsOneWidget);
      expect(find.text('Selesaikan Kursus untuk Cairkan'), findsOneWidget);

      // =========================================================================
      // STEP 5: Driver aktifkan Online, terima order, jalankan kursus sampai SELESAI
      // =========================================================================
      await tester.tap(find.text('Order'));
      await tester.pumpAndSettle();

      // Aktifkan status Online
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(find.text('Online - Siap Terima Order'), findsOneWidget);
      expect(find.text('Siti Rahma'), findsOneWidget);

      // 5a. Terima Order (pending -> accepted) — dana masih ditahan!
      await tester.ensureVisible(find.text('Terima Order'));
      await tester.tap(find.text('Terima Order'));
      await tester.pumpAndSettle();
      expect(sharedState.orders.first.stage, TripStage.accepted);
      expect(sharedState.mitraWalletBalance, 0);
      expect(sharedState.mitraEscrowBalance, 900000);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      // 5b. Berangkat ke Lokasi Siswa (accepted -> onTheWay) — dana masih ditahan!
      await tester.ensureVisible(find.text('Berangkat ke Lokasi Siswa'));
      await tester.tap(find.text('Berangkat ke Lokasi Siswa'));
      await tester.pumpAndSettle();
      expect(sharedState.orders.first.stage, TripStage.onTheWay);
      expect(sharedState.mitraWalletBalance, 0);

      // 5c. Tiba di Lokasi (onTheWay -> arrived) — dana masih ditahan!
      await tester.ensureVisible(find.text('Saya Sudah Tiba di Lokasi'));
      await tester.tap(find.text('Saya Sudah Tiba di Lokasi'));
      await tester.pumpAndSettle();
      expect(sharedState.orders.first.stage, TripStage.arrived);
      expect(sharedState.mitraWalletBalance, 0);

      // 5d. Mulai Sesi Pelatihan (arrived -> training) — dana masih ditahan!
      await tester.ensureVisible(find.text('Mulai Sesi Pelatihan (2 Jam)'));
      await tester.tap(find.text('Mulai Sesi Pelatihan (2 Jam)'));
      await tester.pumpAndSettle();
      expect(sharedState.orders.first.stage, TripStage.training);
      expect(sharedState.mitraWalletBalance, 0);
      expect(sharedState.canWithdrawMitraWallet, isFalse);

      // 5e. Selesai Latihan & Isi Nilai (training -> completed) — DANA CAIR!
      await tester.ensureVisible(find.text('Selesai Latihan & Isi Nilai'));
      await tester.tap(find.text('Selesai Latihan & Isi Nilai'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      expect(sharedState.orders.first.stage, TripStage.completed);
      expect(sharedState.mitraEscrowBalance, 0);
      expect(sharedState.mitraWalletBalance, 900000);
      expect(sharedState.canWithdrawMitraWallet, isTrue);

      // =========================================================================
      // STEP 6: Setelah kursus kelar, driver cairkan Rp 900.000 ke rekening bank!
      // =========================================================================
      await tester.tap(find.text('Dompet'));
      await tester.pumpAndSettle();

      expect(find.text('Rp 900.000'), findsOneWidget);
      expect(find.text('Cairkan ke Rekening Bank'), findsOneWidget);

      await tester.tap(find.text('Cairkan ke Rekening Bank'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Bank BCA ****4821'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cairkan Rp 900.000'));
      await tester.pumpAndSettle();

      // Verifikasi saldo sudah dicairkan & tercatat di riwayat transaksi!
      expect(sharedState.mitraWalletBalance, 0);
      expect(sharedState.walletTransactions.first.title, 'Pencairan ke Bank BCA ****4821');
      expect(sharedState.walletTransactions.first.amount, 900000);
      expect(sharedState.walletTransactions.first.isCredit, isFalse);
      expect(find.text('Pencairan ke Bank BCA ****4821'), findsOneWidget);
    },
  );
}
