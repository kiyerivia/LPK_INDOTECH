import 'package:flutter/material.dart';
import 'apps/mitra_app.dart';
import 'services/bootstrap.dart';

/// Standalone Entry Point — App 2: CIJ Partner (Mitra Driver)
/// Run/Build: flutter run -d chrome -t lib/main_mitra.dart
Future<void> main() async {
  await initCijPlatform();
  runApp(const MitraApp());
}
