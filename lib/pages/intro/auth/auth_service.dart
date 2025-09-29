import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthMethod {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return "Kein User angemeldet.";
      final email = user.email;
      if (email == null) return "E-Mail des Users fehlt.";

      final cred = EmailAuthProvider.credential(email: email, password: currentPassword);
      await user.reauthenticateWithCredential(cred);

      await user.updatePassword(newPassword);

      await _firestore.collection('users').doc(user.uid).update({
        'password': newPassword,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return "success";
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Fehler beim Passwort ändern";
    } catch (e) {
      return e.toString();
    }
  }

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

      final Map<String, Object?> userData = {
        'uid': uid,
        'name': name,
        'email': email,
        'password': password,
        'createdAt': FieldValue.serverTimestamp(),
        'level': 1,
        'totalPoints': 0,
        'role': 'user',
        'streak': 0,
        ...extraData,
      };

      await _firestore.collection('users').doc(uid).set(userData);

      return "success";
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Unbekannter Auth Fehler";
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        return "Bitte E Mail und Passwort eingeben";
      }
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return "success";
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Login fehlgeschlagen";
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  String? get currentUid => _auth.currentUser?.uid;
  User? get currentUser => _auth.currentUser;
}
