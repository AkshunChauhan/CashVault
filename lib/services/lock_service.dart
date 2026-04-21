import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:local_auth/local_auth.dart';

class LockService extends ChangeNotifier {
  static const _settingsBox = 'settings';
  static const _appLockKey = 'app_lock_enabled';

  final LocalAuthentication _auth = LocalAuthentication();
  bool _isLocked = false;

  Box get _box => Hive.box(_settingsBox);

  bool get isAppLockEnabled => _box.get(_appLockKey, defaultValue: false);
  bool get isLocked => _isLocked;

  LockService() {
    _checkLockStatus();
  }

  void _checkLockStatus() {
    if (isAppLockEnabled) {
      _isLocked = true;
      notifyListeners();
    }
  }

  Future<bool> authenticate() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();

      if (!canAuthenticate) return true; // If device doesn't support it, allow access

      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: 'Unlock CashVault',
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );

      if (didAuthenticate) {
        _isLocked = false;
        notifyListeners();
      }
      return didAuthenticate;
    } catch (e) {
      debugPrint('Auth error: $e');
      return false;
    }
  }

  Future<void> toggleAppLock(bool enable) async {
    if (enable) {
      final authenticated = await authenticate();
      if (authenticated) {
        await _box.put(_appLockKey, true);
        notifyListeners();
      }
    } else {
      final authenticated = await authenticate();
      if (authenticated) {
        await _box.put(_appLockKey, false);
        notifyListeners();
      }
    }
  }
}
