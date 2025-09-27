import 'dart:math'; // für Friend-Code
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:studyproject/pages/intro/auth/auth_service.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  late Map<String, String> _data;
  Uint8List? _localAvatar;
  bool _submitting = false;
  bool _initialized = false;
  final _picker = ImagePicker();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;

    final args = ModalRoute.of(context)?.settings.arguments as Map? ?? {};
    _data = (args['answers'] as Map?)?.cast<String, String>() ?? {};
    _initialized = true;
  }

  Future<void> _pickLocalAvatar() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() => _localAvatar = bytes);
  }

  Future<void> _createAndGoHome() async {
    if (!mounted) return;

    final email = (_data['Wie lautet deine E-Mail?'] ?? '').trim();
    final password = _data['Wähle ein Passwort'] ?? '';
    final name = (_data['Wie heißt du?'] ?? '').trim();

    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte Name, E-Mail und Passwort eingeben.')),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      // 1) Account anlegen
      final res = await AuthMethod().signUpUser(
        email: email,
        password: password,
        name: name,
        extraData: {
          'ageRange': _data['Was ist dein Alter?'] ?? '',
          'occupation': _data['Was machst du beruflich?'] ?? '',
          'gender': _data['Was ist dein Geschlecht?'] ?? '',
          'birthday': _data['Wann hast du Geburtstag?'] ?? '',
        },
      );

      if (res != "success") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: $res')),
        );
        return;
      }

      // ab hier ist der Nutzer eingeloggt
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kein eingeloggter Nutzer nach Signup.')),
        );
        return;
      }

      // 2) Optional Avatar in Storage hochladen und URL holen
      String avatarUrl = '';
      if (_localAvatar != null) {
        final ref = FirebaseStorage.instance.ref().child('avatars/${user.uid}.jpg');
        await ref.putData(_localAvatar!, SettableMetadata(contentType: 'image/jpeg'));
        avatarUrl = await ref.getDownloadURL();
      }

      // 3) Firestore Profil users/{uid} anlegen oder mergen
      final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      await docRef.set({
        'uid': user.uid,
        'email': email,
        'name': name,
        'username': (_data['Benutzername'] ?? '').trim(),
        'ageRange': (_data['Was ist dein Alter?'] ?? '').trim(),
        'occupation': (_data['Was machst du beruflich?'] ?? '').trim(),
        'gender': (_data['Was ist dein Geschlecht?'] ?? '').trim(),
        'birthday': (_data['Wann hast du Geburtstag?'] ?? '').trim(),
        'about': '',
        'photoUrl': avatarUrl,
        'friendCode': _generateFriendCode(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'onboardingCompleted': true,
      }, SetOptions(merge: true));

      // 4) Auth Profil synchron halten
      await user.updateDisplayName(name);
      if (avatarUrl.isNotEmpty) await user.updatePhotoURL(avatarUrl);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account erfolgreich erstellt!')),
      );

      // 5) Weiterleiten
      Navigator.of(context).pushReplacementNamed(
        '/streak',
        arguments: {
          'currentStreak': 1,
          'bestStreak': 1,
          'lastCheckIn': DateTime.now(),
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String _generateFriendCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final r = Random();
    return List.generate(9, (_) => chars[r.nextInt(chars.length)]).join();
  }

  @override
  Widget build(BuildContext context) {
    final name = _data['Wie heißt du?'] ?? '';
    final email = _data['Wie lautet deine E-Mail?'] ?? '';
    final password = _data['Wähle ein Passwort'] ?? '';
    final maskedPw = '*' * password.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil prüfen'),
        leading: BackButton(onPressed: () => Navigator.pop(context)),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _pickLocalAvatar,
                        child: CircleAvatar(
                          radius: 32,
                          backgroundImage: _localAvatar != null ? MemoryImage(_localAvatar!) : null,
                          child: _localAvatar == null ? Text(name.isEmpty ? '🙂' : name[0]) : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name.isEmpty ? 'Unbenannt' : name,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text(email, style: const TextStyle(color: Colors.black54)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _infoTile('Passwort', maskedPw),
                  _infoTile('Alter', _data['Was ist dein Alter?']),
                  _infoTile('Beschäftigung', _data['Was machst du beruflich?']),
                  _infoTile('Geschlecht', _data['Was ist dein Geschlecht?']),
                  _infoTile('Geburtstag', _data['Wann hast du Geburtstag?']),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _createAndGoHome,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                      child: _submitting
                          ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                      )
                          : const Text('Account erstellen',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoTile(String label, String? value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          const Spacer(),
          Text(value?.isNotEmpty == true ? value! : '—'),
        ],
      ),
    );
  }
}
