import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:studyproject/pages/models/user.dart';

class UserService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = auth.FirebaseAuth.instance;

  /// Signup
  Future<String> signUpUser({
    Map<String, Object>? extraData,
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty || name.isEmpty) {
        return "Please enter all fields";
      }

      final auth.UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final String uid = cred.user!.uid;

      final Map<String, Object> userData = {
        'id': uid,
        'username': name,
        'email': email,
        'password': password,
        'joinDate': FieldValue.serverTimestamp(),
        'level': 1,
        'points': 0,
        'role': 'user',
        'streak': 0,
      };

      if (extraData != null) {
        userData.addAll(extraData);
      }

      await _firestore.collection('users').doc(uid).set(userData);

      return "success";
    } catch (e) {
      return e.toString();
    }
  }

  /// Login
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty) return "Please enter all fields";

      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return "success";
    } catch (e) {
      return e.toString();
    }
  }

  /// Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Aktuellen User aus Firestore holen
  Future<User?> fetchCurrentUser() async {
    final fbUser = _auth.currentUser;
    if (fbUser == null) return null;

    final doc = await _firestore.collection('users').doc(fbUser.uid).get();
    if (!doc.exists) return null;

    return User.fromJson(doc.data()!);
  }

  /// User updaten
  Future<void> updateUser(User user) async {
    await _firestore.collection('users').doc(user.id).set(user.toJson());
  }
}
