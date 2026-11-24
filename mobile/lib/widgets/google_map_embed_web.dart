import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:ui_web' as ui_web;
import 'package:flutter/widgets.dart';

@JS('window')
external JSObject get _window;

@JS('document')
external JSObject get _document;

final Set<String> _registeredViewTypes = <String>{};

/// Renders a live, interactive Google Maps iframe on Flutter Web without requiring a billing API key.
/// Supports dynamic lat/lng centering, radius-based zoom, and Map (`m`) / Satellite (`k`) layers.
Widget? buildGoogleMapEmbed({
  required double lat,
  required double lng,
  required int zoom,
  String mapType = 'm',
}) {
  final latStr = lat.toStringAsFixed(5);
  final lngStr = lng.toStringAsFixed(5);
  final viewType = 'cij-gmaps-$latStr-$lngStr-z$zoom-$mapType';

  if (!_registeredViewTypes.contains(viewType)) {
    _registeredViewTypes.add(viewType);
    final embedUrl =
        'https://maps.google.com/maps?q=$latStr,$lngStr&z=$zoom&t=$mapType&output=embed&hl=id';

    ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final iframe = _document.callMethod<JSObject>('createElement'.toJS, 'iframe'.toJS);
      iframe.setProperty('src'.toJS, embedUrl.toJS);
      iframe.setProperty('loading'.toJS, 'lazy'.toJS);
      iframe.setProperty('referrerPolicy'.toJS, 'no-referrer-when-downgrade'.toJS);
      iframe.setProperty('allowFullScreen'.toJS, true.toJS);

      final style = iframe.getProperty<JSObject>('style'.toJS);
      style.setProperty('border'.toJS, '0'.toJS);
      style.setProperty('width'.toJS, '100%'.toJS);
      style.setProperty('height'.toJS, '100%'.toJS);
      style.setProperty('display'.toJS, 'block'.toJS);

      return iframe;
    });
  }

  return HtmlElementView(
    key: ValueKey(viewType),
    viewType: viewType,
  );
}

/// Requests the user's real live GPS coordinates from browser navigator.geolocation.
Future<({double lat, double lng})?> getBrowserGpsPosition() async {
  try {
    final navigator = _window.getProperty<JSObject?>('navigator'.toJS);
    final geolocation = navigator?.getProperty<JSObject?>('geolocation'.toJS);
    if (geolocation == null) return null;

    final completer = Completer<({double lat, double lng})?>();

    void onSuccess(JSObject pos) {
      try {
        final coords = pos.getProperty<JSObject>('coords'.toJS);
        final lat = coords.getProperty<JSNumber>('latitude'.toJS).toDartDouble;
        final lng = coords.getProperty<JSNumber>('longitude'.toJS).toDartDouble;
        if (!completer.isCompleted) {
          completer.complete((lat: lat, lng: lng));
        }
      } catch (_) {
        if (!completer.isCompleted) completer.complete(null);
      }
    }

    void onError(JSObject _) {
      if (!completer.isCompleted) completer.complete(null);
    }

    final options = JSObject()
      ..setProperty('enableHighAccuracy'.toJS, true.toJS)
      ..setProperty('timeout'.toJS, 8000.toJS);

    geolocation.callMethod<JSAny?>(
      'getCurrentPosition'.toJS,
      onSuccess.toJS,
      onError.toJS,
      options,
    );

    return completer.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () => null,
    );
  } catch (_) {
    return null;
  }
}

/// Opens the coordinates in full Google Maps in a new browser tab.
void openInGoogleMaps(double lat, double lng) {
  try {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    _window.callMethod<JSAny?>('open'.toJS, url.toJS, '_blank'.toJS);
  } catch (_) {}
}
