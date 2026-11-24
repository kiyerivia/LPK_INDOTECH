import 'package:flutter/widgets.dart';

/// Non-web stub for Google Maps embed inside RadarDriverMap.
/// Returns null so RadarDriverMap cleanly displays its fallback vector map in tests/desktop.
Widget? buildGoogleMapEmbed({
  required double lat,
  required double lng,
  required int zoom,
  String mapType = 'm',
}) =>
    null;

Future<({double lat, double lng})?> getBrowserGpsPosition() async => null;

void openInGoogleMaps(double lat, double lng) {}
