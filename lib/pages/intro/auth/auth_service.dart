import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthMethod {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> signUpUser({
    required Map<String, Object> extraData,
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty || name.isEmpty) {
        return "Bitte alle Felder ausfüllen";
      }

      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = cred.user!.uid;

      // Profildaten vorbereiten
      final Map<String, Object?> userData = {
        'uid': uid,
        'name': name,
        'email': email,
        'password': password, // nur für Testzwecke
        'createdAt': FieldValue.serverTimestamp(),
        'level': 1,
        'totalPoints': 0,
        'role': 'user',
        'streak': 0,
        ...extraData, // Alter, Geschlecht, Geburtstag, Beruf usw.
      };

      await _firestore.collection('users').doc(uid).set(userData);
      print("User angemeldet: $userData");

      return "success";
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Unbekannter Auth Fehler";
    } catch (e) {
      return e.toString();
    }
  }

  // Login
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        return "Bitte E-Mail und Passwort eingeben";
      }

      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      final uid = cred.user!.uid;

      // --- LOG FIRESTORE-DATEN ---
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        print("Angemeldeter User-Daten: ${doc.data()}");
      } else {
        print("User-Daten nicht gefunden in Firestore.");
      }

      return "success";
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Login fehlgeschlagen";
    } catch (e) {
      return e.toString();
    }
  }


  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Getter
  String? get currentUid => _auth.currentUser?.uid;
  User? get currentUser => _auth.currentUser;
}
