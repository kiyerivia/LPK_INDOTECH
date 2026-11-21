import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:math';
import 'dart:typed_data';

@JS('window')
external JSObject get _window;

@JS('PublicKeyCredential')
external JSObject? get _publicKeyCredential;

Uint8List _randomBytes(int length) {
  final rng = Random.secure();
  return Uint8List.fromList(List.generate(length, (_) => rng.nextInt(256)));
}

String _base64UrlEncodeNoPad(Uint8List bytes) {
  return base64Url.encode(bytes).replaceAll('=', '');
}

Uint8List _base64UrlDecode(String input) {
  var normalized = input.replaceAll('-', '+').replaceAll('_', '/');
  while (normalized.length % 4 != 0) {
    normalized += '=';
  }
  return base64Decode(normalized);
}

/// Checks if the browser supports a real platform biometric authenticator
/// (Windows Hello, Touch ID, Android Fingerprint/Face via WebAuthn).
Future<bool> isWebBiometricAvailable() async {
  try {
    final pkc = _publicKeyCredential;
    if (pkc == null) return false;
    final promise = pkc.callMethod<JSPromise<JSBoolean>>(
      'isUserVerifyingPlatformAuthenticatorAvailable'.toJS,
    );
    final result = await promise.toDart;
    return result.toDart;
  } catch (_) {
    return false;
  }
}

/// Registers a hardware-backed WebAuthn platform credential (Fingerprint / Windows Hello / Touch ID).
/// Returns the base64url credential ID if user verified with hardware biometrics, else null.
Future<String?> enrollWebBiometric({
  required String userId,
  required String username,
  required String displayName,
}) async {
  try {
    final navigator = _window.getProperty<JSObject?>('navigator'.toJS);
    final credentials = navigator?.getProperty<JSObject?>('credentials'.toJS);
    if (credentials == null) return null;

    final location = _window.getProperty<JSObject>('location'.toJS);
    final hostname = location.getProperty<JSString>('hostname'.toJS).toDart;

    final challenge = _randomBytes(32);
    final userIdBytes = Uint8List.fromList(utf8.encode(userId));

    final publicKey = JSObject()
      ..setProperty('challenge'.toJS, challenge.toJS)
      ..setProperty(
        'rp'.toJS,
        JSObject()
          ..setProperty('name'.toJS, 'LPK Citra Indotech Jaya'.toJS)
          ..setProperty('id'.toJS, hostname.toJS),
      )
      ..setProperty(
        'user'.toJS,
        JSObject()
          ..setProperty('id'.toJS, userIdBytes.toJS)
          ..setProperty('name'.toJS, username.toJS)
          ..setProperty('displayName'.toJS, displayName.toJS),
      )
      ..setProperty(
        'pubKeyCredParams'.toJS,
        <JSObject>[
          JSObject()
            ..setProperty('type'.toJS, 'public-key'.toJS)
            ..setProperty('alg'.toJS, (-7).toJS),
          JSObject()
            ..setProperty('type'.toJS, 'public-key'.toJS)
            ..setProperty('alg'.toJS, (-257).toJS),
        ].toJS,
      )
      ..setProperty(
        'authenticatorSelection'.toJS,
        JSObject()
          ..setProperty('authenticatorAttachment'.toJS, 'platform'.toJS)
          ..setProperty('userVerification'.toJS, 'required'.toJS),
      )
      ..setProperty('timeout'.toJS, 60000.toJS);

    final options = JSObject()..setProperty('publicKey'.toJS, publicKey);
    final credPromise = credentials.callMethod<JSPromise<JSObject?>>('create'.toJS, options);
    final cred = await credPromise.toDart;
    if (cred == null) return null;

    final rawId = cred.getProperty<JSArrayBuffer>('rawId'.toJS);
    return _base64UrlEncodeNoPad(rawId.toDart.asUint8List());
  } catch (_) {
    return null;
  }
}

/// Verifies the user with hardware biometrics against the enrolled WebAuthn credential ID.
Future<bool> verifyWebBiometric({required String credentialIdBase64Url}) async {
  try {
    final navigator = _window.getProperty<JSObject?>('navigator'.toJS);
    final credentials = navigator?.getProperty<JSObject?>('credentials'.toJS);
    if (credentials == null) return false;

    final location = _window.getProperty<JSObject>('location'.toJS);
    final hostname = location.getProperty<JSString>('hostname'.toJS).toDart;

    final challenge = _randomBytes(32);
    final credIdBytes = _base64UrlDecode(credentialIdBase64Url);

    final allowCred = JSObject()
      ..setProperty('type'.toJS, 'public-key'.toJS)
      ..setProperty('id'.toJS, credIdBytes.toJS);

    final publicKey = JSObject()
      ..setProperty('challenge'.toJS, challenge.toJS)
      ..setProperty('rpId'.toJS, hostname.toJS)
      ..setProperty('userVerification'.toJS, 'required'.toJS)
      ..setProperty('allowCredentials'.toJS, <JSObject>[allowCred].toJS)
      ..setProperty('timeout'.toJS, 60000.toJS);

    final options = JSObject()..setProperty('publicKey'.toJS, publicKey);
    final assertionPromise = credentials.callMethod<JSPromise<JSObject?>>('get'.toJS, options);
    final assertion = await assertionPromise.toDart;
    return assertion != null;
  } catch (_) {
    return false;
  }
}
