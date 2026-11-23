import 'package:flutter/material.dart';
import 'apps/console_app.dart';
import 'services/bootstrap.dart';

/// Standalone Entry Point — App 3: CIJ Command Center (1. INDOTECH Master & 2. LPK Super Admin)
/// Run/Build: flutter run -d chrome -t lib/main_console.dart
Future<void> main() async {
  await initCijPlatform();
  runApp(const ConsoleApp());
}
