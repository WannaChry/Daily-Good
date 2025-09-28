// lib/profil/state/auth_state.dart
import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studyproject/pages/models/user.dart';

class AuthState extends ChangeNotifier {
  final fa.FirebaseAuth _auth = fa.FirebaseAuth.instance;

  fa.User? get user => _auth.currentUser;

  User? _currentUserData;
  User? get currentUserData => _currentUserData;

  fa.User? get firebaseUser => _auth.currentUser;
  bool get isLoggedIn => firebaseUser != null;

  AuthState() {
    // Hört auf Änderungen am Auth-Status
    _auth.userChanges().listen((_) {
      if (_auth.currentUser != null) {
        loadUserData();
      } else {
        _currentUserData = null;
        notifyListeners();
      }
    });
  }

  /// Lädt die Firestore-Daten des aktuell angemeldeten Users
  Future<void> loadUserData() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      _currentUserData = User.fromJson(doc.data()!);
      notifyListeners();
    }
  }

  /// Login über FirebaseAuth
  Future<String> login(String email, String password) async {
    try {
      if (email.isEmpty || password.isEmpty) return "Bitte E-Mail und Passwort eingeben";
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await loadUserData(); // Firestore-Daten laden
      return "success";
    } on fa.FirebaseAuthException catch (e) {
      return e.message ?? "Login fehlgeschlagen";
    }
  }

  /// Logout
  Future<void> signOut() async {
    await _auth.signOut();
    _currentUserData = null;
    notifyListeners();
  }
}
