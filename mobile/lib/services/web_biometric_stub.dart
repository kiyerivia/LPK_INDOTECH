/// Non-web stub for WebAuthn helper
Future<bool> isWebBiometricAvailable() async => false;

Future<String?> enrollWebBiometric({
  required String userId,
  required String username,
  required String displayName,
}) async =>
    null;

Future<bool> verifyWebBiometric({required String credentialIdBase64Url}) async => false;
