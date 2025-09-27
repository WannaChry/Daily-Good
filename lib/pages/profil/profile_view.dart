import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:studyproject/pages/intro/widgets/summary_item.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Nicht eingeloggt')));
    }

    final docRef = FirebaseFirestore.instance.collection('users').doc(uid);

    return Scaffold(
      appBar: AppBar(title: const Text('Deine Daten')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: docRef.snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData || !snap.data!.exists) {
            return const Center(child: Text('Keine Profildaten gefunden'));
          }

          final d = snap.data!.data()!;
          final name = (d['name'] ?? '') as String;
          final email = (d['email'] ?? FirebaseAuth.instance.currentUser?.email ?? '') as String;
          final birthday = (d['birthday'] ?? '') as String;
          final ageRange = (d['ageRange'] ?? '') as String;
          final occupation = (d['occupation'] ?? '') as String;
          final gender = (d['gender'] ?? '') as String;
          final level = (d['level'] ?? 1).toString();
          final totalPoints = (d['totalPoints'] ?? d['totalpoints'] ?? d['points'] ?? 0).toString();
          final streak = (d['streak'] ?? 0).toString();

          final age = _calcAge(birthday);
          final ageCalcText = age != null ? '$age Jahre' : '';

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        child: Text(_initials(name), style: const TextStyle(fontWeight: FontWeight.w800)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name.isEmpty ? 'Unbenannt' : name,
                                style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 2),
                            Text(email, style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              _section('Profil'),
              SummaryItem(leading: Icons.cake_outlined, label: 'Geburtstag', value: birthday),
              SummaryItem(leading: Icons.event_available_outlined, label: 'Alter', value: ageCalcText),
              SummaryItem(leading: Icons.timelapse_rounded, label: 'Altersspanne', value: ageRange),
              SummaryItem(leading: Icons.work_outline_rounded, label: 'Beschäftigung', value: occupation),
              SummaryItem(leading: Icons.wc_outlined, label: 'Geschlecht', value: gender),

              const SizedBox(height: 12),
              _section('Account'),
              SummaryItem(leading: Icons.emoji_events_outlined, label: 'Level', value: level),
              SummaryItem(leading: Icons.star_border_rounded, label: 'Punkte', value: totalPoints),
              SummaryItem(leading: Icons.local_fire_department_outlined, label: 'Streak', value: streak),
            ],
          );
        },
      ),
    );
  }

  static String _initials(String name) {
    final t = name.trim();
    if (t.isEmpty) return 'D';
    final parts = t.split(RegExp(r'\s+'));
    String first(String s) => s.isEmpty ? '' : s.substring(0, 1);
    final i1 = first(parts[0]);
    final i2 = parts.length > 1 ? first(parts[1]) : '';
    return (i1 + i2).toUpperCase();
  }


  static int? _calcAge(String s) {
    if (s.isEmpty) return null;
    try {
      DateTime dob;
      if (RegExp(r'^\d{2}\.\d{2}\.\d{4}$').hasMatch(s)) {
        final p = s.split('.');
        dob = DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
      } else if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(s)) {
        final p = s.split('-');
        dob = DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
      } else {
        return null;
      }
      final now = DateTime.now();
      var age = now.year - dob.year;
      if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) age--;
      return age;
    } catch (_) {
      return null;
    }
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 8),
      child: Text(title, style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w900)),
    );
  }
}
