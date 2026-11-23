import 'package:flutter/material.dart';
import 'apps/user_app.dart';
import 'services/bootstrap.dart';

/// Default Entry Point — CIJ Driving (App 1: Konsumen / Siswa)
/// Standalone entrypoints for the 3-app Gojek ecosystem:
/// - App 1 (Siswa / Konsumen):   `flutter run -t lib/main_user.dart` (or default `lib/main.dart`)
/// - App 2 (Mitra Driver):       `flutter run -t lib/main_mitra.dart`
/// - App 3 (Master & LPK Admin): `flutter run -t lib/main_console.dart`
Future<void> main() async {
  await initCijPlatform();
  runApp(const LPKIndotechApp());
}

class LPKIndotechApp extends StatelessWidget {
  const LPKIndotechApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const UserApp();
  }
}
