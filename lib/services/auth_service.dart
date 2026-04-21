import 'package:flutter/foundation.dart';

/// Authentication service with optional Google Sign-In.
/// Core app functionality works without authentication.
class AuthService extends ChangeNotifier {
  bool _isSignedIn = false;
  String? _userId;
  String? _userEmail;
  String? _displayName;
  bool _isLoading = false;

  bool get isSignedIn => _isSignedIn;
  String? get userId => _userId;
  String? get userEmail => _userEmail;
  String? get displayName => _displayName;
  bool get isLoading => _isLoading;

  /// Signs in with Google.
  /// Returns true if successful, false otherwise.
  ///
  /// NOTE: Firebase must be initialized before calling this.
  /// If Firebase is not configured, this will silently fail.
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Firebase Auth implementation
      // Uncomment when Firebase is configured:
      //
      // final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      // if (googleUser == null) {
      //   _isLoading = false;
      //   notifyListeners();
      //   return false;
      // }
      //
      // final GoogleSignInAuthentication googleAuth =
      //     await googleUser.authentication;
      //
      // final credential = GoogleAuthProvider.credential(
      //   accessToken: googleAuth.accessToken,
      //   idToken: googleAuth.idToken,
      // );
      //
      // final userCredential =
      //     await FirebaseAuth.instance.signInWithCredential(credential);
      //
      // _userId = userCredential.user?.uid;
      // _userEmail = userCredential.user?.email;
      // _displayName = userCredential.user?.displayName;
      // _isSignedIn = true;

      // Placeholder: simulate not configured
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('Sign-in error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Uncomment when Firebase is configured:
      // await FirebaseAuth.instance.signOut();
      // await GoogleSignIn().signOut();

      _isSignedIn = false;
      _userId = null;
      _userEmail = null;
      _displayName = null;
    } catch (e) {
      debugPrint('Sign-out error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}
