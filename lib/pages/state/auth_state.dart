// lib/profil/state/auth_state.dart
import 'dart:typed_data';
import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AuthState extends ChangeNotifier {
  AuthState() {
    _auth.userChanges().listen((_) => notifyListeners());
  }

  final fa.FirebaseAuth _auth = fa.FirebaseAuth.instance;

  fa.User? get user => _auth.currentUser;
  bool get isLoggedIn => user != null;

  static Widget provide({required AuthState state, required Widget child}) =>
      _AuthScope(notifier: state, child: child);

  static AuthState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_AuthScope>()!.notifier!;

  Future<void> refresh() async {
    await user?.reload();
    notifyListeners();
  }

  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }

  Future<void> createAccountFromReview(
      Map<String, String?> data, {
        Uint8List? avatarBytes,
      }) async {
    if (_auth.currentUser == null) {
      await _auth.signInAnonymously();
    }
    final u = _auth.currentUser!;
    final name = (data['name'] ?? '').trim();

    if (name.isNotEmpty && u.displayName != name) {
      await u.updateDisplayName(name);
    }

    String? photoURL = u.photoURL;

    if (avatarBytes != null && avatarBytes.isNotEmpty) {
      photoURL = await _uploadAvatarBytesVersioned(u.uid, avatarBytes);
      await u.updatePhotoURL(photoURL);
    }

    final users = FirebaseFirestore.instance.collection('users').doc(u.uid);
    await users.set({
      'name': name.isNotEmpty ? name : null,
      'email': (data['email'] ?? '').trim().isNotEmpty ? (data['email'] ?? '').trim() : null,
      'ageRange': data['ageRange'],
      'occupation': data['occupation'],
      'gender': data['gender'],
      'birthday': data['birthday'],
      'photoURL': photoURL,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await refresh();
  }

  Future<String> uploadProfilePhoto(Uint8List bytes) async {
    final u = _auth.currentUser;
    if (u == null) throw StateError('Kein eingeloggter Benutzer.');

    final url = await _uploadAvatarBytesVersioned(u.uid, bytes);
    await u.updatePhotoURL(url);

    await FirebaseFirestore.instance.collection('users').doc(u.uid).set({
      'photoURL': url,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await refresh();
    return url;
  }

  // Speichert mit Zeitstempel im Dateinamen -> garantiert neue URL (Cache-Busting)
  Future<String> _uploadAvatarBytesVersioned(String uid, Uint8List bytes) async {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final ref = FirebaseStorage.instance.ref('users/$uid/profile_$ts.jpg');
    await ref.putData(
      bytes,
      SettableMetadata(contentType: 'image/jpeg', cacheControl: 'public, max-age=60'),
    );
    return ref.getDownloadURL();
  }
}

class _AuthScope extends InheritedNotifier<AuthState> {
  const _AuthScope({super.key, required super.notifier, required super.child});
}
