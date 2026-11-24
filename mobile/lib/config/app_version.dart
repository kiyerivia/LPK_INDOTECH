import '../models/app_models.dart';

/// Centralized release version registry for each standalone CIJ application.
/// Bump these version numbers before each maintenance deploy so every Vercel
/// deployment clearly displays its active release build.
class AppVersionInfo {
  final String appName;
  final String version;
  final String buildNumber;
  final String channel;
  final String releaseDate;

  const AppVersionInfo({
    required this.appName,
    required this.version,
    required this.buildNumber,
    required this.channel,
    required this.releaseDate,
  });

  String get fullLabel => '$appName v$version ($channel • Build #$buildNumber)';
  String get shortLabel => 'v$version-$channel • #$buildNumber';
}

class AppVersions {
  static const AppVersionInfo driving = AppVersionInfo(
    appName: 'CIJ Driving',
    version: '1.1.0',
    buildNumber: '2',
    channel: 'beta',
    releaseDate: '24 Nov 2026',
  );

  static const AppVersionInfo partner = AppVersionInfo(
    appName: 'CIJ Mitra',
    version: '1.1.0',
    buildNumber: '2',
    channel: 'beta',
    releaseDate: '24 Nov 2026',
  );

  static const AppVersionInfo console = AppVersionInfo(
    appName: 'CIJ Master',
    version: '1.1.0',
    buildNumber: '2',
    channel: 'beta',
    releaseDate: '24 Nov 2026',
  );

  static AppVersionInfo forFlavor(AppFlavor flavor) {
    switch (flavor) {
      case AppFlavor.user:
      case AppFlavor.portal:
        return driving;
      case AppFlavor.mitra:
        return partner;
      case AppFlavor.console:
        return console;
    }
  }
}
