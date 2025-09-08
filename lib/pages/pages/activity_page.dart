import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key, required this.totalPoints});
  final int totalPoints;

  @override
  Widget build(BuildContext context) {
    // ... dein bisheriger Inhalt (aus QuestsPage) ...
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('$totalPoints',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  )),
              const SizedBox(width: 8),
              SvgPicture.asset(
                'assets/icons/thunder2-svgrepo-com.svg',
                width: 26,
                height: 26,
                colorFilter:
                const ColorFilter.mode(Colors.black, BlendMode.srcIn),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Placeholder Diagramm
          Container(
            height: 160,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text('Diagramm (später)',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 16),
          // 3 Cards (untereinander)
          Expanded(
            child: ListView(
              children: const [
                _QuestBucketCard(
                  icon: 'assets/icons/target-svgrepo-com.svg',
                  title: 'Erreiche ein Ziel',
                  subtitle: '0 / 1',
                ),
                SizedBox(height: 12),
                _QuestBucketCard(
                  icon: 'assets/icons/edit-pen-svgrepo-com.svg',
                  title: 'Schreibe eine Reflexion',
                  subtitle: '0 / 1',
                ),
                SizedBox(height: 12),
                _QuestBucketCard(
                  icon: 'assets/icons/leaf-svgrepo-com.svg',
                  title: 'Mache eine Atemübung',
                  subtitle: '0 / 1',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestBucketCard extends StatelessWidget {
  const _QuestBucketCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final String icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFA8D5A2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            icon,
            width: 32,
            height: 32,
            colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right, size: 22),
        ],
      ),
    );
  }
}
