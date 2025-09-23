//Enthält alle Methoden zur Anmeldung ->signIn, signUp, Signout
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthMethod {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // signup
  Future<String> signUpUser({
    required Map<String, Object> extraData,
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      //final email = answers['Wie lautet deine E-Mail?']?.trim() ?? '';
      //final password = answers['Wähle ein Passwort']?.trim() ?? '';
      //final name = answers['Wie heißt du?']?.trim() ?? '';

      if (email.isEmpty || password.isEmpty || name.isEmpty) {
        return "Please enter all fields";
      }
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // store created user
      final uid = cred.user!.uid;

      // Firestore Daten speichern
      final userData = {
        'uid': uid,
        'name': name,
        'email': email,
        'password': password,
        'createdAt': FieldValue.serverTimestamp(),
        'level': 1,
        'points': 0,
        'role': 'user',
        'streak': 0,
      };

      if (extraData != null) {
        userData.addAll(extraData); // füge Alter, Geschlecht, Geburtstag, Beruf etc. hinzu
      }

      await _firestore.collection('users').doc(uid).set(userData);

      return "success";
    } catch (e) {
      return e.toString();
    }
  }

  // login
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        return "Please enter all fields";
      }
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return "success";
    } catch (e) {
      return e.toString();
    }
  }

  //logout
Future<void> signOut()async{
    await _auth.signOut();
}
}
