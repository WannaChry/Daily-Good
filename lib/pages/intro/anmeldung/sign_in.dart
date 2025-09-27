import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studyproject/pages/intro/auth/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _answerController = TextEditingController();

  late int _a, _b; // Zahlen für Matheaufgabe
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _generateQuestion();
  }

  void _generateQuestion() {
    final rnd = Random();
    _a = rnd.nextInt(10) + 1;
    _b = rnd.nextInt(10) + 1;
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final answer = int.tryParse(_answerController.text.trim());

    print('Versuche Login für: $email');

    if (answer != _a + _b) {
      print('Sicherheitsfrage falsch: $_a + $_b != $answer');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Falsche Antwort auf die Sicherheitsfrage.')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      // 1) Firebase Auth Login
      final res = await AuthMethod().loginUser(
        email: email,
        password: password,
      );

      if (res == "success") {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login erfolgreich!")),
        );

        // 2) Profil unter users/{uid} sicherstellen und korrekt routen
        await _ensureUserProfileAndRoute();

      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login fehlgeschlagen: $res')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Profil sicherstellen und abhängig vom Onboarding-Status navigieren
  Future<void> _ensureUserProfileAndRoute() async {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) return;

    final users = FirebaseFirestore.instance.collection('users');
    final uidRef = users.doc(u.uid);
    final uidSnap = await uidRef.get();

    if (!uidSnap.exists) {
      // Optional: altes Profil per E-Mail übernehmen
      final q = await users.where('email', isEqualTo: u.email ?? '').limit(1).get();

      Map<String, dynamic> base = {
        'uid': u.uid,
        'email': u.email ?? '',
        'name': u.displayName ?? '',
        'username': '',
        'photoUrl': u.photoURL ?? '',
        'about': '',
        'ageRange': '',
        'occupation': '',
        'gender': '',
        'birthday': '',
        'friendCode': _generateFriendCode(),
        'createdAt': FieldValue.serverTimestamp(),
        'onboardingCompleted': false,
      };

      if (q.docs.isNotEmpty) {
        final old = q.docs.first.data();
        base = {
          ...old,
          'uid': u.uid,
          'email': u.email ?? old['email'] ?? '',
        };
      }

      await uidRef.set(base, SetOptions(merge: true));
    }

    // updatedAt pflegen
    await uidRef.set({'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));

    final data = (await uidRef.get()).data();
    final completed = data?['onboardingCompleted'] == true;

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, completed ? '/home' : '/onboarding');
  }

  String _generateFriendCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final r = Random();
    return List.generate(9, (_) => chars[r.nextInt(chars.length)]).join();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/auth_choice');
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'E-Mail'),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Passwort'),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                Text(
                  'Was ist $_a + $_b ?',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: _answerController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'Antwort eingeben'),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _loading ? null : _login,
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Einloggen'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
