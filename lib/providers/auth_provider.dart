import 'package:flutter/foundation.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.unknown;
  bool _isProfileComplete = false;

  AuthStatus get status => _status;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isProfileComplete => _isProfileComplete;

  AuthProvider() {
    // Simulate checking auth state — will be replaced with Firebase listener
    Future.delayed(const Duration(milliseconds: 500), () {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    });
  }
}
