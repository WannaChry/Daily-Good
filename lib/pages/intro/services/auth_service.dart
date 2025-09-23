

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> signUpUser({
    required String email,
    required String password,
    required String name,
    required String birthday,
  }) async {
    String res = "Some error occurred";
    try {
      if (email.isNotEmpty && password.isNotEmpty && name.isNotEmpty && birthday.isNotEmpty) {
        // User in Auth anlegen
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Firestore-Eintrag
        await _firestore.collection("users").doc(cred.user!.uid).set({
          "uid": cred.user!.uid,
          "email": email,
          "name": name,
          "birthday": birthday,
          "level": 1,
          "joinDate": DateTime.now(),
        });

        res = "success";
      } else {
        res = "Please fill all fields";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }
}
