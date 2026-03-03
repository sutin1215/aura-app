import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  AuthStatus _status = AuthStatus.unknown;
  User? _user;
  UserProfile? _userProfile;
  bool _isProfileComplete = false;
  bool _isLoadingProfile = true;

  AuthStatus get status => _status;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isProfileComplete => _isProfileComplete;
  bool get isLoadingProfile => _isLoadingProfile;
  User? get user => _user;
  UserProfile? get userProfile => _userProfile;

  // Role helpers
  bool get isProvider => _userProfile?.role == 'provider';
  bool get isPatient => _userProfile?.role == 'patient';

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) async {
      _isLoadingProfile = true;
      notifyListeners();

      if (user == null) {
        _status = AuthStatus.unauthenticated;
        _user = null;
        _userProfile = null;
        _isProfileComplete = false;
        _isLoadingProfile = false;
        notifyListeners();
      } else {
        _user = user;
        await _checkProfileStatus(user.uid);
      }
    });
  }

  Future<void> _checkProfileStatus(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists && doc.data()!.containsKey('isProfileComplete')) {
        _isProfileComplete = doc.data()!['isProfileComplete'] ?? false;
        if (_isProfileComplete) {
          _userProfile = UserProfile.fromMap(doc.data()!, uid);
        }
      } else {
        _isProfileComplete = false;
      }
    } catch (e) {
      _isProfileComplete = false;
    }
    _status = AuthStatus.authenticated;
    _isLoadingProfile = false;
    notifyListeners();
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    await _db.collection('users').doc(profile.uid).set(
          profile.toMap(),
          SetOptions(merge: true),
        );
    _userProfile = profile;
    _isProfileComplete = true;
    notifyListeners();
  }

  /// Register a healthcare provider — creates the account and immediately
  /// writes a completed profile so they skip the patient setup wizard.
  Future<void> registerAsProvider({
    required String email,
    required String password,
    required String name,
    required String specialty,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    final uid = cred.user!.uid;
    final now = DateTime.now();
    final profile = UserProfile(
      uid: uid,
      username: name,
      email: email,
      role: 'provider',
      gender: 'Not specified',
      dateOfBirth: DateTime(1990),
      height: 0,
      weight: 0,
      healthConditions: const [],
      createdAt: now,
      updatedAt: now,
      specialty: specialty,
    );
    await updateUserProfile(profile);
  }

  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> register(String email, String password) async {
    _isProfileComplete = false;
    await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
