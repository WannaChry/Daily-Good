// lib/profil/profil/profile_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:studyproject/pages/subpages/notifications_page.dart';
import 'package:studyproject/pages/subpages/preferences_page.dart';
import 'package:studyproject/pages/subpages/deine_daten_page.dart';
import 'package:studyproject/pages/subpages/privacy_security_page.dart';
import 'package:studyproject/pages/subpages/help_support_page.dart';
import 'package:studyproject/pages/intro/widgets/summary_item.dart';

import 'package:studyproject/pages/state/social_state.dart';
import 'package:studyproject/pages/state/auth_state.dart';

// Abzeichen (Kachel + Seite + Demo-Daten)
import 'package:studyproject/pages/home/badge_dex_page.dart';

import 'package:studyproject/pages/widgets/profile/expandable_section.dart';
import 'package:studyproject/pages/widgets/profile/list_tile_stub.dart';
import 'package:studyproject/pages/widgets/profile/section_group.dart';
import 'package:studyproject/pages/widgets/profile/logout_button.dart';
import 'package:studyproject/pages/widgets/profile/about_text_field.dart';
import 'package:studyproject/pages/widgets/profile/editable_avatar.dart';

import 'package:studyproject/pages/utils/friend_code.dart';
import 'package:studyproject/pages/utils/profile_level.dart';
import 'dart:async';

// Pastell-Hintergrund (neuer, ruhiger)
import 'package:studyproject/pages/intro/widgets/dailygood_profile_background.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.totalPoints});
  final int totalPoints;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _Debouncer {
  _Debouncer({required this.ms});
  final int ms;
  Timer? _t;

  void call(VoidCallback action) {
    _t?.cancel();
    _t = Timer(Duration(milliseconds: ms), action);
  }

  void dispose() => _t?.cancel();
}

class _ProfilePageState extends State<ProfilePage> {
  late final String _friendCode;
  final _aboutCtrl = TextEditingController();
  final _aboutFocus = FocusNode();
  final _debounce = _Debouncer(ms: 400);

  late final DocumentReference<Map<String, dynamic>> _userDoc;
  static const _aboutMaxLen = 200;

  bool _uploadingAvatar = false;

  @override
  void initState() {
    super.initState();

    _friendCode = generateFriendCode(9);

    final uid = FirebaseAuth.instance.currentUser!.uid;
    _userDoc = FirebaseFirestore.instance.collection('users').doc(uid);

    _aboutCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _aboutCtrl.dispose();
    _aboutFocus.dispose();
    _debounce.dispose();
    super.dispose();
  }

  Future<void> _changeAvatar() async {
    final auth = AuthState.of(context);
    final uid = auth.user?.uid;
    if (uid == null) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 88,
    );
    if (picked == null) return;

    setState(() => _uploadingAvatar = true);
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('users')
          .child(uid)
          .child('avatar.jpg');

      await ref.putFile(
        File(picked.path),
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final url = await ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({'photoUrl': url}, SetOptions(merge: true));

      await FirebaseAuth.instance.currentUser?.updatePhotoURL(url);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profilbild aktualisiert.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload fehlgeschlagen: $e')),
      );
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final social = SocialState.of(context);
    final auth = AuthState.of(context);

    final title = GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700);
    final subtitle = GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade700);

    final lp = levelFromPoints(widget.totalPoints);
    final level = lp.level;
    final progress = lp.needed == 0 ? 0.0 : (lp.current / lp.needed).clamp(0.0, 1.0);

    final uid = auth.user?.uid;

    // ---- Abzeichen-Zähler aus Demo-Liste ----
    final int _badgesUnlocked = demoBadges.where((b) => b.unlocked).length;
    final int _badgesTotal = demoBadges.length;

    return DailyGoodProfileBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ---------- Header ----------
              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: uid == null
                    ? null
                    : FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
                builder: (context, snap) {
                  final data = snap.data?.data();
                  final String remoteBio = (snap.data?.data()?['bio'] as String?) ?? '';
                  if (!_aboutFocus.hasFocus && _aboutCtrl.text != remoteBio) {
                    _aboutCtrl.text = remoteBio;
                  }

                  final displayName =
                      (data?['name'] as String?) ?? auth.user?.displayName ?? 'You';
                  final photoUrl =
                      (data?['photoUrl'] as String?) ?? auth.user?.photoURL;
                  final initial =
                  (displayName.isNotEmpty ? displayName.trim()[0] : '?').toUpperCase();

                  return Column(
                    children: [
                      EditableAvatar(
                        radius: 55,
                        initials: initial,
                        photoUrl: photoUrl,
                        uploading: _uploadingAvatar,
                        onTap: _changeAvatar,
                      ),
                      const SizedBox(height: 12),
                      Text(displayName, style: title),
                      const SizedBox(height: 4),
                      Text(
                        _friendCode,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          letterSpacing: 0.8,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 20),

              // ---------- Punkte-Card (OHNE Level, OHNE 0/80) ----------
              Card(
                elevation: 8,
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Punkte',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.2,
                            ),
                          ),
                          Text(
                            '${widget.totalPoints} Punkte',
                            style: GoogleFonts.poppins(
                              fontSize: 13.5,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 14,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.blueAccent.shade200,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // ---------- Abzeichen-Kachel (zwischen Punkte und Über mich) ----------
              BadgeEntryTile(
                unlockedCount: _badgesUnlocked,
                totalCount: _badgesTotal,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const BadgeDexPage()),
                  );
                },
              ),

              const SizedBox(height: 26),

              // ---------- Über mich (weiße Card + gefülltes Textfeld) ----------
              Card(
                elevation: 8,
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Über mich',
                          style: GoogleFonts.poppins(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _aboutCtrl,
                        focusNode: _aboutFocus,
                        minLines: 3,
                        maxLines: 5,
                        maxLength: _aboutMaxLen,
                        decoration: InputDecoration(
                          hintText: 'Erzähl etwas über dich…',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                            BorderSide(color: Colors.blue.shade300, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (v) => _debounce(() {
                          _userDoc.set({'bio': v.trim()}, SetOptions(merge: true));
                        }),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ---------- Freunde ----------
              ExpandableSection(
                title: 'Freunde',
                children: (social.friends.isEmpty
                    ? const [
                  'Noch keine Freunde – füge welche auf der Community-Seite hinzu.'
                ]
                    : social.friends.map((f) => '${f.name} • ${f.code}'))
                    .map((label) => ListTileStub(label: label))
                    .toList(),
              ),

              const SizedBox(height: 16),

              // ---------- Communities ----------
              ExpandableSection(
                title: 'Communities',
                children: (social.communities.isEmpty
                    ? const [
                  'Noch keine Communities – tritt per Code bei oder erstelle eine.'
                ]
                    : social.communities.map((c) => '${c.name} • Code: ${c.code}'))
                    .map((label) => ListTileStub(label: label))
                    .toList(),
              ),

              const SizedBox(height: 24),

              // ---------- Gruppen: Account ----------
              SectionGroup(
                header: 'Account',
                items: [
                  GroupItem(
                    label: 'Benachrichtigungen',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const NotificationsPage()),
                    ),
                  ),
                  GroupItem(
                    label: 'Präferenzen',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PreferencesPage()),
                    ),
                  ),
                  GroupItem(
                    label: 'Deine Daten',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const DeineDatenPage()),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ---------- Gruppen: Support ----------
              SectionGroup(
                header: 'Support',
                items: [
                  GroupItem(
                    label: 'Datenschutz & Sicherheit',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PrivacySecurityPage()),
                    ),
                  ),
                  GroupItem(
                    label: 'Hilfe & Support',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const HelpSupportPage(initialTab: 0)),
                    ),
                  ),
                  GroupItem(
                    label: 'Fehler melden',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const HelpSupportPage(initialTab: 3)),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ---------- Login/Logout ----------
              if (auth.isLoggedIn) ...[
                LogoutButton(),
              ] else ...[
                const SizedBox.shrink(),
              ],
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Read-only Datenblatt (unverändert)
// -----------------------------------------------------------------------------

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
          final email =
          (d['email'] ?? FirebaseAuth.instance.currentUser?.email ?? '') as String;
          final birthday = (d['birthday'] ?? '') as String;
          final ageRange = (d['ageRange'] ?? '') as String;
          final occupation = (d['occupation'] ?? '') as String;
          final gender = (d['gender'] ?? '') as String;
          final level = (d['level'] ?? 1).toString();
          final totalPoints =
          (d['totalPoints'] ?? d['totalpoints'] ?? d['points'] ?? 0).toString();
          final streak = (d['streak'] ?? 0).toString();

          final age = _calcAge(birthday);
          final ageCalcText = age != null ? '$age Jahre' : '';

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                elevation: 8,
                shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        child: Text(_initials(name),
                            style: const TextStyle(fontWeight: FontWeight.w800)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name.isEmpty ? 'Unbenannt' : name,
                                style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 2),
                            Text(email,
                                style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              _section('Profil'),
              SummaryItem(
                  leading: Icons.cake_outlined,
                  label: 'Geburtstag',
                  value: birthday),
              SummaryItem(
                  leading: Icons.event_available_outlined,
                  label: 'Alter',
                  value: ageCalcText),
              SummaryItem(
                  leading: Icons.timelapse_rounded,
                  label: 'Altersspanne',
                  value: ageRange),
              SummaryItem(
                  leading: Icons.work_outline_rounded,
                  label: 'Beschäftigung',
                  value: occupation),
              SummaryItem(
                  leading: Icons.wc_outlined,
                  label: 'Geschlecht',
                  value: gender),

              const SizedBox(height: 12),
              _section('Account'),
              SummaryItem(
                  leading: Icons.emoji_events_outlined,
                  label: 'Level',
                  value: level),
              SummaryItem(
                  leading: Icons.star_border_rounded,
                  label: 'Punkte',
                  value: totalPoints),
              SummaryItem(
                  leading: Icons.local_fire_department_outlined,
                  label: 'Streak',
                  value: streak),
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
      if (now.month < dob.month ||
          (now.month == dob.month && now.day < dob.day)) age--;
      return age;
    } catch (_) {
      return null;
    }
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 8),
      child: Text(title,
          style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w900)),
    );
  }
}
