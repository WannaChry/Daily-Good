import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:studyproject/pages/state/social_state.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final social = SocialState.of(context); // gemeinsamer State
    final h1 = GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800);
    final hint = GoogleFonts.poppins(fontSize: 12.5, color: Colors.grey.shade700);

    final topFriends = social.friends.take(4).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F3FA),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // --- Freunde-Avatare oben (max 4) ---
            if (topFriends.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: topFriends
                      .map((f) => GestureDetector(
                    onLongPress: () => _confirmRemoveFriend(f),
                    child: _AvatarWithName(name: f.name),
                  ))
                      .toList(),
                ),
              ),

            // --- Freunde: Aktionen ---
            Text('Freunde', style: h1),
            const SizedBox(height: 8),
            _Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    _ActionButton(
                      label: 'Freund hinzufügen',
                      color: const Color(0xFFA8D5A2),
                      onTap: _openAddFriendSheet,
                    ),
                    const SizedBox(height: 10),
                    _ActionButton(
                      label: 'Freundschaftsanfragen',
                      color: const Color(0xFFA8D5A2),
                      onTap: _openRequestsSheet,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // --- Alle Freunde (Liste + Entfernen) ---
            if (social.friends.isNotEmpty) ...[
              _Card(
                child: Column(
                  children: social.friends
                      .map((f) => Column(
                    children: [
                      ListTile(
                        title: Text(f.name,
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700)),
                        subtitle: Text('Code: ${f.code}', style: hint),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _confirmRemoveFriend(f),
                        ),
                      ),
                      if (f != social.friends.last) const Divider(height: 1),
                    ],
                  ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // --- Communities: Aktionen ---
            Text('Communities', style: h1),
            const SizedBox(height: 8),
            _Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    _ActionButton(
                      label: 'Community beitreten',
                      color: const Color(0xFFA8D5A2),
                      onTap: _openJoinCommunitySheet,
                    ),
                    const SizedBox(height: 10),
                    _ActionButton(
                      label: 'Community erstellen',
                      color: const Color(0xFFA8D5A2),
                      onTap: _openCreateCommunitySheet,
                    ),
                    const SizedBox(height: 10),
                    _ActionButton(
                      label: 'Community-Einladungen',
                      color: const Color(0xFFA8D5A2),
                      onTap: _openInvitesSheet,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // --- Meine Communities ---
            if (social.communities.isNotEmpty) ...[
              _Card(
                child: Column(
                  children: social.communities
                      .map((c) => Column(
                    children: [
                      ListTile(
                        title: Text(c.name,
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700)),
                        subtitle: Text('Code: ${c.code}', style: hint),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _toast('Community "${c.name}" (Demo).'),
                      ),
                      if (c != social.communities.last) const Divider(height: 1),
                    ],
                  ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }

  // ===== Bottom Sheets / Logik =====

  // Freund hinzufügen (Name oder Code)
  void _openAddFriendSheet() {
    final social = SocialState.of(context, listen: false);
    final nameCtrl = TextEditingController();
    final codeCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16, right: 16, top: 16,
            bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SheetHandle(),
              const SizedBox(height: 8),
              Text('Freund hinzufügen',
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              _TextField(label: 'Nach Name suchen', controller: nameCtrl),
              const SizedBox(height: 10),
              _TextField(label: 'Freundschaftscode (z. B. QH93-FCV)', controller: codeCtrl),
              const SizedBox(height: 12),
              _PrimaryButton(
                label: 'Senden',
                onTap: () {
                  Navigator.pop(context);
                  final name = nameCtrl.text.trim();
                  final code = codeCtrl.text.trim().toUpperCase();

                  if (code.isNotEmpty) {
                    social.addFriendByCode(code, fallbackName: name.isEmpty ? 'Freund' : name);
                    _toast('Freund per Code hinzugefügt (Demo).');
                  } else if (name.isNotEmpty) {
                    social.sendFriendRequestByName(name);
                    _toast('Anfrage an "$name" gesendet (Demo).');
                  } else {
                    _toast('Bitte Name oder Code eingeben.');
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Freundschaftsanfragen (eingehend + ausgehend)
  void _openRequestsSheet() {
    final social = SocialState.of(context, listen: false);
    final incoming = social.incomingFriendRequests;
    final outgoing = social.outgoingFriendRequests;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16, right: 16, top: 12,
            bottom: 12 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SheetHandle(),
              const SizedBox(height: 8),
              Text('Ausstehende Anfragen',
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),

              Align(
                alignment: Alignment.centerLeft,
                child: Text('Eingehend', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14)),
              ),
              const SizedBox(height: 4),
              if (incoming.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text('Keine eingehenden Anfragen',
                      style: GoogleFonts.poppins(color: Colors.grey.shade700)),
                )
              else
                ...incoming.map((r) => _RequestRow(
                  title: '${r.name}  •  ${r.code}',
                  onAccept: () {
                    Navigator.pop(context);
                    social.acceptIncoming(r);
                    _toast('Du bist jetzt mit ${r.name} befreundet.');
                  },
                  onDecline: () {
                    Navigator.pop(context);
                    social.declineIncoming(r);
                    _toast('Anfrage von ${r.name} abgelehnt.');
                  },
                )),

              const SizedBox(height: 12),

              Align(
                alignment: Alignment.centerLeft,
                child: Text('Ausgehend', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14)),
              ),
              const SizedBox(height: 4),
              if (outgoing.isEmpty)
                Text('Keine ausgehenden Anfragen',
                    style: GoogleFonts.poppins(color: Colors.grey.shade700))
              else
                ...outgoing.map((r) => _RequestRow(
                  title: '${r.name}  •  ${r.code}',
                  onAccept: () {
                    Navigator.pop(context);
                    social.cancelOutgoing(r);
                    _toast('Ausgehende Anfrage zurückgezogen.');
                  },
                  onDecline: () {
                    Navigator.pop(context);
                    social.cancelOutgoing(r);
                    _toast('Ausgehende Anfrage zurückgezogen.');
                  },
                )),
            ],
          ),
        );
      },
    );
  }

  // Community-Einladungen
  void _openInvitesSheet() {
    final social = SocialState.of(context, listen: false);
    final invites = social.communityInvites;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SheetHandle(),
              const SizedBox(height: 8),
              Text('Community-Einladungen',
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              if (invites.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Keine Einladungen',
                      style: GoogleFonts.poppins(color: Colors.grey.shade700)),
                )
              else
                ...invites.map((i) => _RequestRow(
                  title: '${i.name}  •  ${i.code}',
                  onAccept: () {
                    Navigator.pop(context);
                    social.acceptCommunityInvite(i);
                    _toast('Community beigetreten.');
                  },
                  onDecline: () {
                    Navigator.pop(context);
                    social.declineCommunityInvite(i);
                    _toast('Einladung abgelehnt.');
                  },
                )),
            ],
          ),
        );
      },
    );
  }

  // Community beitreten (Code)
  void _openJoinCommunitySheet() {
    final social = SocialState.of(context, listen: false);
    final codeCtrl = TextEditingController();
    final nameCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SheetHandle(),
              const SizedBox(height: 8),
              Text(
                'Community beitreten',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),

              // Eingabe: Code
              _TextField(label: 'Community-Code', controller: codeCtrl),
              const SizedBox(height: 12),

              // Eingabe: Name
              _TextField(label: 'Community-Name', controller: nameCtrl),
              const SizedBox(height: 16),

              // Button
              _PrimaryButton(
                label: 'Beitreten',
                onTap: () {
                  Navigator.pop(context);

                  final code = codeCtrl.text.trim().toUpperCase();
                  final name = nameCtrl.text.trim();

                  if (code.isEmpty && name.isEmpty) {
                    return _toast('Bitte Code oder Name eingeben.');
                  }

                  if (code.isNotEmpty) {
                    if (social.communities.any((c) => c.code == code)) {
                      return _toast('Schon Mitglied.');
                    }
                    social.joinCommunityByCode(code);
                    _toast('Community per Code beigetreten (Demo).');
                  } else {
                    if (social.communities.any((c) =>
                    c.name.toLowerCase() == name.toLowerCase())) {
                      return _toast('Schon Mitglied.');
                    }
                    social.joinCommunityByName(name);
                    _toast('Community per Name beigetreten (Demo).');
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Community erstellen
  void _openCreateCommunitySheet() {
    final social = SocialState.of(context, listen: false);
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController(); // aktuell noch ungenutzt

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        // Wir erstellen die Community erst beim Tap, damit der Code danach angezeigt wird
        return Padding(
          padding: EdgeInsets.only(
            left: 16, right: 16, top: 16,
            bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SheetHandle(),
              const SizedBox(height: 8),
              Text('Community erstellen',
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              _TextField(label: 'Name', controller: nameCtrl),
              const SizedBox(height: 10),
              _TextField(label: 'Beschreibung (optional)', controller: descCtrl, maxLines: 3),
              const SizedBox(height: 12),
              _PrimaryButton(
                label: 'Erstellen',
                onTap: () {
                  final created = social.createCommunity(nameCtrl.text.trim());
                  Navigator.pop(context);
                  _toast('Community "${created.name}" erstellt: ${created.code}');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Freund entfernen
  Future<void> _confirmRemoveFriend(Friend f) async {
    final social = SocialState.of(context, listen: false);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Freund entfernen?', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Text('„${f.name}“ wird aus deiner Liste entfernt.',
            style: GoogleFonts.poppins()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Abbrechen')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Entfernen')),
        ],
      ),
    );
    if (ok == true) {
      social.removeFriend(f);
      _toast('„${f.name}“ entfernt.');
    }
  }
}

// ===== UI Helper =====

class _AvatarWithName extends StatelessWidget {
  const _AvatarWithName({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const SizedBox(height: 6),
        Text(name, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label, required this.onTap, required this.color});

  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          height: 52,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            label,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w800, fontSize: 15.5, color: Colors.black),
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: child,
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({required this.label, required this.controller, this.maxLines = 1});
  final String label;
  final TextEditingController controller;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: '',
      ).copyWith(labelText: label),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFA8D5A2),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          child: Text(label,
              style: GoogleFonts.poppins(fontSize: 15.5, fontWeight: FontWeight.w800, color: Colors.black)),
        ),
      ),
    );
  }
}

class _RequestRow extends StatelessWidget {
  const _RequestRow({required this.title, required this.onAccept, required this.onDecline});
  final String title;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
      trailing: Wrap(
        spacing: 6,
        children: [
          OutlinedButton(onPressed: onDecline, child: const Text('Ablehnen')),
          ElevatedButton(
            onPressed: onAccept,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFA8D5A2),
              foregroundColor: Colors.black,
            ),
            child: const Text('Annehmen'),
          ),
        ],
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 44,
        height: 5,
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}
