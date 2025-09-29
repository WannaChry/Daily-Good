import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NGOsPage extends StatefulWidget {
  const NGOsPage({super.key});

  @override
  State<NGOsPage> createState() => _NGOsPageState();
}

class _NGOsPageState extends State<NGOsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  static const _bg = Color(0xFFF8F3FA);
  static const _pastelBlue = Color(0xFF97C4FF);
  static const _cardBorder = Color(0x14000000);
  static const _shadow = Color(0x0A000000);
  static const _textDark = Colors.black;

  static const _tabs = [
    _NGOTab(keyId: 'engagement', label: 'Engagement'),
    _NGOTab(keyId: 'studium', label: 'Studium & Bildung'),
    _NGOTab(keyId: 'nachhaltigkeit', label: 'Nachhaltigkeit'),
    _NGOTab(keyId: 'stadt', label: 'Stadt & Politik'),
    _NGOTab(keyId: 'rettung', label: 'Gesundheit & Rettung'),
    _NGOTab(keyId: 'sozial', label: 'Soziales & Integration'),
    _NGOTab(keyId: 'sport', label: 'Sport & Bewegung'),
    _NGOTab(keyId: 'tiere', label: 'Tiere & Natur'),
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = GoogleFonts.poppins(
      fontWeight: FontWeight.w700,
      fontSize: 22,
      color: _textDark,
    );

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _pastelBlue.withOpacity(0.35),
        iconTheme: const IconThemeData(color: _textDark),
        title: Text('NGOs & Vereine', style: titleStyle),
        bottom: TabBar(
          controller: _tabCtrl,
          isScrollable: true,
          indicatorColor: _textDark,
          labelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          labelColor: _textDark,
          unselectedLabelColor: Colors.black54,
          tabs: _tabs.map((t) => Tab(text: t.label)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children:
        _tabs.map((t) => _NGOCategoryView(categoryId: t.keyId)).toList(),
      ),
    );
  }
}

class _NGOTab {
  final String keyId;
  final String label;
  const _NGOTab({required this.keyId, required this.label});
}

class NGOItem {
  final String name;
  final String description;
  final String contact;
  final List<String> tasks;
  final String? logoUrl;
  final IconData? fallbackIcon;

  NGOItem({
    required this.name,
    required this.description,
    required this.contact,
    required this.tasks,
    this.logoUrl,
    this.fallbackIcon,
  });
}

class _NGOCategoryView extends StatelessWidget {
  const _NGOCategoryView({required this.categoryId});
  final String categoryId;

  @override
  Widget build(BuildContext context) {
    final items = _loadDummy(categoryId);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (_, i) => _NGOCard(item: items[i]),
    );
  }

  static List<NGOItem> _loadDummy(String categoryId) {
    switch (categoryId) {
      case 'engagement':
        return [
          NGOItem(
            name: 'Schulwegshelfer',
            description:
            'Ehrenamt für sichere Schulwege: morgens vor Schulen helfen & Präsenz zeigen.',
            contact: 'schulweg@landshut.de',
            fallbackIcon: Icons.safety_check,
            tasks: [
              'Zebrastreifen sichern (morgens)',
              'Eltern & Kinder sensibilisieren',
              'Infotage mitorganisieren',
            ],
          ),
          NGOItem(
            name: 'Repair Café Landshut',
            description:
            'Gemeinsames Reparieren von Elektronik, Kleidung & Möbeln – Ressourcen sparen.',
            contact: 'repair@landshut.de',
            fallbackIcon: Icons.build,
            tasks: [
              'Reparaturen unterstützen',
              'Werkstatt betreuen',
              'Besucher:innen anleiten',
            ],
          ),
        ];

      case 'studium':
        return [
          NGOItem(
            name: 'Hochschulvereine LA',
            description:
            'Fachschaften, Kultur- & Sportvereine – Campus-Leben aktiv mitgestalten.',
            contact: 'campus@haw-la.de',
            fallbackIcon: Icons.school,
            tasks: [
              'Ersti-Buddy werden',
              'Events organisieren',
              'Lerngruppen & Tutorien',
            ],
          ),
          NGOItem(
            name: 'Buddy-Programm Studierende',
            description:
            'Mentoring & Ankommen in Landshut – lokale Buddys helfen neuen Studis.',
            contact: 'buddy@haw-la.de',
            fallbackIcon: Icons.groups_2,
            tasks: [
              'Mentoring übernehmen',
              'Sprach-/Kultur-Tandems',
              'Wohnungs-/Ämterhilfe',
            ],
          ),
        ];

      case 'nachhaltigkeit':
        return [
          NGOItem(
            name: 'Greenpeace (Regionalgruppe)',
            description:
            'Umwelt- & Klimaschutz. Lokale Aktionen, Aufklärung & Kampagnenarbeit.',
            contact: 'landshut@greenpeace.de',
            fallbackIcon: Icons.eco,
            tasks: [
              'Aktionen & Banner-Workshops',
              'Infostände betreuen',
              'Recherche & Öffentlichkeitsarbeit',
            ],
          ),
          NGOItem(
            name: 'BUND Naturschutz',
            description:
            'Naturschutzprojekte, Biotoppflege, Umweltbildung in der Region.',
            contact: 'bn@landshut.de',
            fallbackIcon: Icons.park,
            tasks: [
              'Pflanz-/Pflegeeinsätze',
              'Exkursionen begleiten',
              'Bildungsangebote unterstützen',
            ],
          ),
        ];

      case 'stadt':
        return [
          NGOItem(
            name: 'Stadtratssitzungen Landshut',
            description:
            'Öffentliche Sitzungen – zuschauen, mitreden, Anträge verstehen.',
            contact: 'rathaus@landshut.de',
            fallbackIcon: Icons.account_balance,
            tasks: [
              'Sitzungen besuchen',
              'Bürgerfragen vorbereiten',
              'Protokolle zusammenfassen',
            ],
          ),
          NGOItem(
            name: 'Bürgerbeteiligung & Stadtteilvereine',
            description:
            'Misch dich ein: Ideen, Projekte & Nachbarschaft stärken.',
            contact: 'beteiligung@landshut.de',
            fallbackIcon: Icons.forum,
            tasks: [
              'Workshops moderieren',
              'Kiez-Projekte starten',
              'Vernetzung & Kommunikation',
            ],
          ),
        ];

      case 'rettung':
        return [
          NGOItem(
            name: 'Rotes Kreuz Landshut',
            description:
            'Sanitätsdienste, Blutspenden, Katastrophenschutz & soziale Unterstützung.',
            contact: 'kontakt@roteskreuz.de',
            fallbackIcon: Icons.health_and_safety,
            tasks: [
              'Sanitätsdienst unterstützen',
              'Blutspendeaktionen betreuen',
              'Katastrophenschutz/Logistik',
            ],
          ),
          NGOItem(
            name: 'Johanniter / Malteser',
            description:
            'Erste-Hilfe-Kurse, Rettungsdienst & soziale Projekte in der Region.',
            contact: 'info@johanniter.de',
            fallbackIcon: Icons.medical_services,
            tasks: [
              'Erste-Hilfe-Kurse begleiten',
              'Sozialarbeit unterstützen',
              'Einsatzplanung & Organisation',
            ],
          ),
        ];

      case 'sozial':
        return [
          NGOItem(
            name: 'Tafel Landshut',
            description:
            'Lebensmittel retten & fair verteilen – Unterstützung für Bedürftige.',
            contact: 'kontakt@tafel-la.de',
            fallbackIcon: Icons.volunteer_activism,
            tasks: [
              'Sortieren & Ausgeben',
              'Abholungen organisieren',
              'Spenden-Logistik',
            ],
          ),
          NGOItem(
            name: 'Flüchtlings- & Integrationshilfe',
            description:
            'Begleitung im Alltag, Sprachcafés, Ämtergänge & Freizeitangebote.',
            contact: 'integration@landshut.de',
            fallbackIcon: Icons.diversity_3,
            tasks: [
              'Sprach-Tandems',
              'Alltagsbegleitung',
              'Freizeit- & Sportangebote',
            ],
          ),
        ];

      case 'sport':
        return [
          NGOItem(
            name: 'Lauftreff Landshut',
            description:
            'Gemeinsames Laufen für alle Levels – Gesundheit & Gemeinschaft.',
            contact: 'lauf@landshut.de',
            fallbackIcon: Icons.directions_run,
            tasks: [
              'Wöchentliche Laufrunden',
              'Events organisieren',
              'Neulinge begleiten',
            ],
          ),
          NGOItem(
            name: 'Sportverein LA e.V.',
            description:
            'Breitensport: Fußball, Volleyball, Turnen, Fitness – für jedes Alter.',
            contact: 'verein@sport-la.de',
            fallbackIcon: Icons.sports_soccer,
            tasks: [
              'Training unterstützen',
              'Jugendbetreuung',
              'Turniere/Spiele organisieren',
            ],
          ),
        ];

      case 'tiere':
        return [
          NGOItem(
            name: 'Tierheim Landshut',
            description:
            'Tierschutz & Vermittlung – Pflege und Betreuung von Tieren.',
            contact: 'info@tierheim-la.de',
            fallbackIcon: Icons.pets,
            tasks: [
              'Tierpflege & Gassi gehen',
              'Vermittlung unterstützen',
              'Spendenaktionen',
            ],
          ),
          NGOItem(
            name: 'Naturschutzgruppe LA',
            description:
            'Biotoppflege, Nistkästen, Arten- und Lebensraumschutz.',
            contact: 'natur@la.de',
            fallbackIcon: Icons.nature,
            tasks: [
              'Pflegeeinsätze draußen',
              'Nistkästen bauen/prüfen',
              'Naturführungen begleiten',
            ],
          ),
        ];

      default:
        return const [];
    }
  }
}

class _NGOCard extends StatelessWidget {
  const _NGOCard({required this.item});
  final NGOItem item;

  static const _pastelBlue = _NGOPageTokens._pastelBlue;
  static const _cardBorder = _NGOPageTokens._cardBorder;
  static const _shadow = _NGOPageTokens._shadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              border: Border.all(color: _cardBorder),
              boxShadow: const [
                BoxShadow(color: _shadow, blurRadius: 8, offset: Offset(0, 2)),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _LogoOrIcon(logoUrl: item.logoUrl, fallbackIcon: item.fallbackIcon),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        item.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(color: _cardBorder),
              boxShadow: const [
                BoxShadow(color: _shadow, blurRadius: 8, offset: Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.description,
                  style:
                  GoogleFonts.poppins(fontSize: 13.5, color: Colors.black87),
                ),
                const SizedBox(height: 14),

                if (item.tasks.isNotEmpty) ...[
                  Text(
                    'Was kann man hier tun?',
                    style: GoogleFonts.poppins(
                        fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: item.tasks.map((t) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(top: 6),
                              decoration: BoxDecoration(
                                color: _pastelBlue.withOpacity(0.9),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                t,
                                style: GoogleFonts.poppins(
                                    fontSize: 13.5, color: Colors.black87),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                ],

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.contact,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _PastelButton(
                      label: 'Mitmachen',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Mit ${item.name} Kontakt aufnehmen')),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoOrIcon extends StatelessWidget {
  const _LogoOrIcon({this.logoUrl, this.fallbackIcon});
  final String? logoUrl;
  final IconData? fallbackIcon;

  @override
  Widget build(BuildContext context) {
    const size = 56.0;
    final radius = BorderRadius.circular(14);

    if (logoUrl != null && logoUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: radius,
        child: Container(
          width: size,
          height: size,
          color: Colors.white,
          child: Image.network(
            logoUrl!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _fallback(),
          ),
        ),
      );
    }
    return _fallback();
  }

  Widget _fallback() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: _NGOPageTokens._pastelBlue.withOpacity(0.25),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _NGOPageTokens._cardBorder),
      ),
      child: Icon(
        fallbackIcon ?? Icons.groups,
        size: 28,
        color: const Color(0xFF2F4C7A),
      ),
    );
  }
}

class _PastelButton extends StatelessWidget {
  const _PastelButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: _NGOPageTokens._pastelBlue.withOpacity(0.35),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _NGOPageTokens._cardBorder),
            boxShadow: const [
              BoxShadow(
                color: _NGOPageTokens._shadow,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w800,
              fontSize: 14.5,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}

// Token-Sammlung
class _NGOPageTokens {
  static const _pastelBlue = Color(0xFF97C4FF);
  static const _cardBorder = Color(0x14000000);
  static const _shadow = Color(0x0A000000);
}
