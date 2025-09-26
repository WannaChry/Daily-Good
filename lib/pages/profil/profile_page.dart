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

import 'package:studyproject/pages/state/social_state.dart';
import 'package:studyproject/pages/state/auth_state.dart';

import 'package:studyproject/pages/widgets/profile/level_card.dart';
import 'package:studyproject/pages/widgets/profile/expandable_section.dart';
import 'package:studyproject/pages/widgets/profile/list_tile_stub.dart';
import 'package:studyproject/pages/widgets/profile/section_group.dart';
import 'package:studyproject/pages/widgets/profile/logout_button.dart';

import 'package:studyproject/pages/utils/friend_code.dart';
import 'package:studyproject/pages/utils/profile_level.dart';



class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.totalPoints});
  final int totalPoints;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final String _friendCode;
  final _aboutCtrl = TextEditingController();
  static const _aboutMaxLen = 200;

  bool _uploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    _friendCode = generateFriendCode(9);
    _aboutCtrl.text = "";
    _aboutCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _aboutCtrl.dispose();
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

      // in Firestore speichern (wird von SignIn/Profile angezeigt)
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({'photoUrl': url}, SetOptions(merge: true));

      // optional auch ins Auth-Profil
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

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ---------- Header mit Avatar (ohne "Profilbild ändern"-Link) ----------
            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: uid == null
                  ? null
                  : FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
              builder: (context, snap) {
                final data = snap.data?.data();
                final displayName =
                    (data?['name'] as String?) ?? auth.user?.displayName ?? 'You';
                final photoUrl =
                    (data?['photoUrl'] as String?) ?? auth.user?.photoURL;

                final initial =
                (displayName.isNotEmpty ? displayName.trim()[0] : '?').toUpperCase();

                return Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          radius: 55,
                          backgroundColor: Colors.grey.shade400,
                          backgroundImage:
                          photoUrl != null ? NetworkImage(photoUrl) : null,
                          child: photoUrl == null
                              ? Text(
                            initial,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w800,
                              fontSize: 28,
                            ),
                          )
                              : null,
                        ),
                        Positioned(
                          right: -2,
                          bottom: -2,
                          child: Material(
                            color: Colors.black,
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: _uploadingAvatar ? null : _changeAvatar,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: _uploadingAvatar
                                    ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(Colors.white),
                                  ),
                                )
                                    : const Icon(Icons.edit, color: Colors.white, size: 18),
                              ),
                            ),
                          ),
                        ),
                      ],
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

            // ---------- Level + Punkte ----------
            LevelCard(
              level: level,
              current: lp.current,
              needed: lp.needed,
              totalPoints: widget.totalPoints,
              progress: progress,
            ),

            const SizedBox(height: 26),

            // ---------- Über mich ----------
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Über mich',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                controller: _aboutCtrl,
                maxLines: null,
                minLines: 2,
                maxLength: _aboutMaxLen,
                decoration: InputDecoration(
                  isDense: true,
                  counterText: '${_aboutCtrl.text.characters.length}/$_aboutMaxLen',
                  border: InputBorder.none,
                  hintText: 'Schreib etwas über dich…',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                style: GoogleFonts.poppins(fontSize: 14),
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
                  onTap: () =>
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationsPage())),
                ),
                GroupItem(
                  label: 'Präferenzen',
                  onTap: () =>
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PreferencesPage())),
                ),
                GroupItem(
                  label: 'Deine Daten',
                  onTap: () =>
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DeineDatenPage())),
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
                    MaterialPageRoute(builder: (_) => const HelpSupportPage(initialTab: 0)),
                  ),
                ),
                GroupItem(
                  label: 'Fehler melden',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const HelpSupportPage(initialTab: 3)),
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
    );
  }
}