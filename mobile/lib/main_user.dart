import 'package:flutter/material.dart';
import 'apps/user_app.dart';
import 'services/bootstrap.dart';

/// Standalone Entry Point — App 1: CIJ Driving (Konsumen / User)
/// Run/Build: flutter run -d chrome -t lib/main_user.dart
Future<void> main() async {
  await initCijPlatform();
  runApp(const UserApp());
}
