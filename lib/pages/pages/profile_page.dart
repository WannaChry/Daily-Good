// lib/pages/pages/profile_page.dart
import 'dart:io';
import 'dart:math';
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
import 'package:studyproject/pages/pages/options.dart';
import 'package:studyproject/pages/pages/sign_up_page.dart';

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
    _friendCode = _generateFriendCode(9);
    _aboutCtrl.text = "";
    _aboutCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _aboutCtrl.dispose();
    super.dispose();
  }

  String _generateFriendCode(int length) {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rnd = Random.secure();
    return List.generate(length, (_) => chars[rnd.nextInt(chars.length)]).join();
  }

  ({int level, int current, int needed}) _levelFromPoints(int points) {
    int level = 1;
    int needed = 80;
    int remaining = points;
    while (remaining >= needed) {
      remaining -= needed;
      level += 1;
      needed += 20;
    }
    return (level: level, current: remaining, needed: needed);
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

    final lp = _levelFromPoints(widget.totalPoints);
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
            _LevelCard(
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
            _ExpandableSection(
              title: 'Freunde',
              children: (social.friends.isEmpty
                  ? const [
                'Noch keine Freunde – füge welche auf der Community-Seite hinzu.'
              ]
                  : social.friends.map((f) => '${f.name} • ${f.code}'))
                  .map((label) => _ListTileStub(label: label))
                  .toList(),
            ),

            const SizedBox(height: 16),

            // ---------- Communities ----------
            _ExpandableSection(
              title: 'Communities',
              children: (social.communities.isEmpty
                  ? const [
                'Noch keine Communities – tritt per Code bei oder erstelle eine.'
              ]
                  : social.communities.map((c) => '${c.name} • Code: ${c.code}'))
                  .map((label) => _ListTileStub(label: label))
                  .toList(),
            ),

            const SizedBox(height: 24),

            // ---------- Gruppen: Account ----------
            _SectionGroup(
              header: 'Account',
              items: [
                _GroupItem(
                  label: 'Benachrichtigungen',
                  onTap: () =>
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationsPage())),
                ),
                _GroupItem(
                  label: 'Präferenzen',
                  onTap: () =>
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PreferencesPage())),
                ),
                _GroupItem(
                  label: 'Deine Daten',
                  onTap: () =>
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DeineDatenPage())),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ---------- Gruppen: Support ----------
            _SectionGroup(
              header: 'Support',
              items: [
                _GroupItem(
                  label: 'Datenschutz & Sicherheit',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PrivacySecurityPage()),
                  ),
                ),
                _GroupItem(
                  label: 'Hilfe & Support',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const HelpSupportPage(initialTab: 0)),
                  ),
                ),
                _GroupItem(
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
              _LogoutButton(),
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

// ===== Helper Widgets =====

class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.level,
    required this.current,
    required this.needed,
    required this.totalPoints,
    required this.progress,
  });

  final int level;
  final int current;
  final int needed;
  final int totalPoints;
  final double progress;

  @override
  Widget build(BuildContext conteoverxt) {
    final title = GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w800);
    final label = GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600);

    const barH = 18.0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Level $level', style: title),
            Text('$totalPoints Punkte', style: label.copyWith(color: Colors.grey.shade700)),
          ]),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Stack(
              children: [
                Container(height: barH, color: Colors.white),
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress,
                  child: Container(height: barH, color: Colors.green.shade300),
                ),
                Positioned.fill(
                  child: Center(
                    child: Text(
                      '$current / $needed',
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.black.withOpacity(0.8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpandableSection extends StatefulWidget {
  const _ExpandableSection({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  State<_ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<_ExpandableSection> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => setState(() => _open = !_open),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Text(
                widget.title,
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          AnimatedCrossFade(
            crossFadeState:
            _open ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 200),
            firstChild: Column(
              children: [
                const Divider(height: 1),
                ...widget.children
                    .expand<Widget>((w) => [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    child: w,
                  ),
                  const Divider(height: 1),
                ])
                    .toList()
                  ..removeLast(),
              ],
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _ListTileStub extends StatelessWidget {
  const _ListTileStub({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _SectionGroup extends StatelessWidget {
  const _SectionGroup({required this.header, required this.items});
  final String header;
  final List<_GroupItem> items;

  @override
  Widget build(BuildContext context) {
    final headerStyle =
    GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(header, style: headerStyle),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ],
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: List.generate(items.length, (i) {
              final item = items[i];
              final isLast = i == items.length - 1;
              return Column(
                children: [
                  _GroupRow(label: item.label, onTap: item.onTap),
                  if (!isLast) const Divider(height: 1, thickness: 1),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _GroupItem {
  const _GroupItem({required this.label, this.onTap});
  final String label;
  final VoidCallback? onTap;
}

class _GroupRow extends StatelessWidget {
  const _GroupRow({required this.label, this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '›',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.red.shade400,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          try {
            await AuthState.of(context).signOut();
            if (!context.mounted) return;
            Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Abgemeldet.')),
            );
          } catch (e) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Logout fehlgeschlagen: $e')),
            );
          }
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          alignment: Alignment.center,
          child: Text(
            'Logout',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
