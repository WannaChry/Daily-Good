// lib/pages/home/badge_dex_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:studyproject/pages/models/AppBadge.dart' show AppBadge, BadgeRarity, BadgeProgress;

// ---------- Badge-Entry-Tile (weiß wie die anderen Cards) ----------
class BadgeEntryTile extends StatelessWidget {
  const BadgeEntryTile({
    super.key,
    required this.unlockedCount,
    required this.totalCount,
    required this.onTap,
  });

  final int unlockedCount;
  final int totalCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black12.withOpacity(0.08)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon in umrandetem Kreis
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF7F3FF), // sehr zartes Lila
                  border: Border.all(color: const Color(0xFFD7C7FF), width: 1.4),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  size: 20,
                  color: Color(0xFF6E49CF),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Abzeichen',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF111827),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.black.withOpacity(0.06)),
                ),
                child: Text(
                  '$unlockedCount / $totalCount',
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF111827),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right, size: 22, color: Color(0xFF6B7280)),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== „BadgeDex“-Seite (Vollbild) ====================
class BadgeDexPage extends StatelessWidget {
  const BadgeDexPage({super.key});

  @override
  Widget build(BuildContext context) {
    final unlockedCount = demoBadges.where((b) => b.unlocked).length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: Text(
          'Abzeichen  •  $unlockedCount / ${demoBadges.length}',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF8F3FA),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: GridView.builder(
          itemCount: demoBadges.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.82,
          ),
          itemBuilder: (_, i) => BadgeCell(badge: demoBadges[i]),
        ),
      ),
    );
  }
}

class BadgeCell extends StatelessWidget {
  const BadgeCell({super.key, required this.badge});
  final AppBadge badge;

  Color _rarityBorder() {
    switch (badge.rarity) {
      case BadgeRarity.common:
        return Colors.black.withOpacity(0.10);
      case BadgeRarity.rare:
        return Colors.blueAccent.withOpacity(0.45);
      case BadgeRarity.epic:
        return Colors.purple.withOpacity(0.45);
      case BadgeRarity.legendary:
        return Colors.orange.withOpacity(0.55);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locked = !badge.unlocked;

    return InkWell(
      onTap: () => showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        ),
        builder: (_) => BadgeDetailSheet(badge: badge),
      ),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _rarityBorder()),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 10,
              offset: Offset(0, 6),
            )
          ],
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            // Icon-Kreis
            Container(
              height: 58,
              width: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFF7FBF5), Color(0xFFEFF7EA)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                border: Border.all(color: Colors.black12),
              ),
              alignment: Alignment.center,
              child: Icon(
                badge.icon,
                size: 28,
                color: locked ? Colors.black26 : Colors.green.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              badge.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: locked ? Colors.black38 : Colors.black87,
              ),
            ),
            const Spacer(),
            // Lock / Unlocked Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  locked ? Icons.lock_outline_rounded : Icons.check_circle_rounded,
                  size: 16,
                  color: locked ? Colors.black26 : Colors.green,
                ),
                const SizedBox(width: 4),
                Text(
                  locked ? 'Gesperrt' : 'Freigeschaltet',
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: locked ? Colors.black38 : Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class BadgeDetailSheet extends StatelessWidget {
  const BadgeDetailSheet({super.key, required this.badge});
  final AppBadge badge;

  String _rarityText(BadgeRarity rarity) {
    switch (rarity) {
      case BadgeRarity.common:
        return 'Gewöhnlich';
      case BadgeRarity.rare:
        return 'Selten';
      case BadgeRarity.epic:
        return 'Episch';
      case BadgeRarity.legendary:
        return 'Legendär';
    }
  }

  @override
  Widget build(BuildContext context) {
    final locked = !badge.unlocked;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 5,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          Text(
            badge.title,
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                badge.icon,
                size: 28,
                color: locked ? Colors.black26 : Colors.green.shade700,
              ),
              const SizedBox(width: 8),
              Text(
                _rarityText(badge.rarity),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  color: Colors.black.withOpacity(0.7),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: locked ? Colors.black.withOpacity(0.06) : Colors.green.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  locked ? 'Gesperrt' : 'Freigeschaltet',
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: locked ? Colors.black54 : Colors.green.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              badge.description,
              style: GoogleFonts.poppins(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (badge.progress != null)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Fortschritt: ${badge.progress!.current} / ${badge.progress!.target}',
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

// Demo-Badges – später dann mit Firebase verknüpfen
final List<AppBadge> demoBadges = [
  AppBadge(
    title: 'Erster Schritt',
    description: 'Erledige deine erste Aufgabe.',
    icon: Icons.check_circle_rounded,
    rarity: BadgeRarity.common,
    unlocked: true,
    progress: BadgeProgress(1, 1),
  ),
  AppBadge(
    title: 'Umweltfreundlich',
    description: 'Spare 5 kg CO₂ in einem Monat.',
    icon: Icons.eco_rounded,
    rarity: BadgeRarity.rare,
    unlocked: false,
    progress: BadgeProgress(2, 5),
  ),
  AppBadge(
    title: 'Sozial aktiv',
    description: 'Erledige 10 soziale Aufgaben.',
    icon: Icons.group_rounded,
    rarity: BadgeRarity.common,
    unlocked: true,
    progress: BadgeProgress(10, 10),
  ),
  AppBadge(
    title: 'Konzentrationsmeister',
    description: '3× Deep-Work in einer Woche.',
    icon: Icons.bolt_rounded,
    rarity: BadgeRarity.rare,
    unlocked: false,
    progress: BadgeProgress(1, 3),
  ),
  AppBadge(
    title: 'Achtsamkeits-Profi',
    description: 'Meditiere an 7 Tagen in Folge.',
    icon: Icons.self_improvement_rounded,
    rarity: BadgeRarity.epic,
    unlocked: false,
    progress: BadgeProgress(3, 7),
  ),
  AppBadge(
    title: 'Pendlerheld',
    description: 'Fahre 5× mit dem Rad statt Auto.',
    icon: Icons.directions_bike_rounded,
    rarity: BadgeRarity.common,
    unlocked: true,
    progress: BadgeProgress(5, 5),
  ),
  AppBadge(
    title: 'Wasser statt Plastik',
    description: '10× Leitungswasser statt Plastikflasche.',
    icon: Icons.local_drink_rounded,
    rarity: BadgeRarity.common,
    unlocked: false,
    progress: BadgeProgress(6, 10),
  ),
  AppBadge(
    title: 'Bücherwurm',
    description: 'Lies 5× 30 Minuten in einer Woche.',
    icon: Icons.menu_book_rounded,
    rarity: BadgeRarity.rare,
    unlocked: false,
    progress: BadgeProgress(2, 5),
  ),
  AppBadge(
    title: 'Gewohnheits-Champion',
    description: '10 Tage in Folge mindestens 3 Tasks.',
    icon: Icons.stars_rounded,
    rarity: BadgeRarity.legendary,
    unlocked: false,
    progress: BadgeProgress(4, 10),
  ),
  AppBadge(
    title: 'Hydro-Hero',
    description: 'Trinke 2 Liter Wasser an 7 Tagen.',
    icon: Icons.opacity_rounded,
    rarity: BadgeRarity.common,
    unlocked: false,
    progress: BadgeProgress(3, 7),
  ),
  AppBadge(
    title: 'Reflexions-Master',
    description: 'Schreibe 5 Reflexionen.',
    icon: Icons.edit_note_rounded,
    rarity: BadgeRarity.rare,
    unlocked: false,
    progress: BadgeProgress(1, 5),
  ),
  AppBadge(
    title: 'Community-Star',
    description: 'Tritt einer Community bei und poste.',
    icon: Icons.forum_rounded,
    rarity: BadgeRarity.epic,
    unlocked: false,
  ),
];
