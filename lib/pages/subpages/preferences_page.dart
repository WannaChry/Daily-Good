import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({super.key});

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  // Darstellung
  bool darkMode = false;
  double fontScale = 1.0; // 0.85 .. 1.4
  final List<Color> accentChoices = [
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.orange,
    Colors.teal,
  ];
  int accentIndex = 0;

  // Sprache & Region
  String language = 'Deutsch';
  final langs = ['Deutsch', 'English', 'Türkçe', 'Français', 'Español'];
  String region = 'Deutschland';
  final regions = ['Deutschland', 'Österreich', 'Schweiz', 'Andere'];

  // Inhalte
  final allCategories = [
    'Nachhaltigkeit',
    'Soziales',
    'Achtsamkeit',
    'Fitness',
    'Ernährung',
    'Haushalt',
  ];
  final Set<String> selectedCategories = {'Nachhaltigkeit', 'Achtsamkeit'};

  // Erinnerungen
  TimeOfDay reminderTime = const TimeOfDay(hour: 9, minute: 0);
  final List<String> weekdays = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
  final Set<String> reminderDays = {'Mo', 'Mi', 'Fr'};
  String frequency = 'Täglich'; // Sofort / Stündlich / Täglich
  final freqOptions = ['Sofort', 'Stündlich', 'Täglich'];

  // Einheiten & Format
  String distanceUnit = 'km'; // km / mi
  String dateFormat = 'dd.MM.yyyy'; // dd.MM.yyyy / MM/dd/yyyy / yyyy-MM-dd

  // Barrierefreiheit
  bool largerTapTargets = true;
  bool reduceMotion = false;

  @override
  Widget build(BuildContext context) {
    final h1 = GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800);
    final hint = GoogleFonts.poppins(fontSize: 12.5, color: Colors.grey.shade700);

    final accent = accentChoices[accentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F3FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text('Präferenzen', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Darstellung
          Text('Darstellung', style: h1),
          const SizedBox(height: 8),
          _Card(child: Column(children: [
            SwitchListTile(
              value: darkMode,
              onChanged: (v) => setState(() => darkMode = v),
              title: const Text('Dunkles Design'),
              subtitle: Text('Schont die Augen und spart Akku', style: hint),
            ),
            const Divider(height: 1),
            ListTile(
              title: const Text('Akzentfarbe'),
              subtitle: Text('Farbe für Highlights & Buttons', style: hint),
              trailing: Wrap(
                spacing: 8,
                children: List.generate(accentChoices.length, (i) {
                  final c = accentChoices[i];
                  final sel = accentIndex == i;
                  return GestureDetector(
                    onTap: () => setState(() => accentIndex = i),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: sel ? Colors.black : Colors.black12,
                          width: sel ? 2 : 1,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Schriftgröße'),
                  Slider(
                    value: fontScale,
                    min: 0.85,
                    max: 1.4,
                    divisions: 11,
                    label: '${(fontScale * 100).round()}%',
                    onChanged: (v) => setState(() => fontScale = v),
                  ),
                ],
              ),
            ),
          ])),

          const SizedBox(height: 20),

          // Sprache & Region
          Text('Sprache & Region', style: h1),
          const SizedBox(height: 8),
          _Card(child: Column(children: [
            ListTile(
              title: const Text('Sprache'),
              subtitle: Text('Ausgabe-Sprache der App', style: hint),
              trailing: DropdownButton<String>(
                value: language,
                onChanged: (v) => setState(() => language = v!),
                items: langs.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              title: const Text('Region'),
              subtitle: Text('Formate & Empfehlungen anpassen', style: hint),
              trailing: DropdownButton<String>(
                value: region,
                onChanged: (v) => setState(() => region = v!),
                items: regions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              ),
            ),
          ])),

          const SizedBox(height: 20),

          // Inhalte
          Text('Inhalte', style: h1),
          const SizedBox(height: 8),
          _Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: allCategories.map((cat) {
                  final sel = selectedCategories.contains(cat);
                  return ChoiceChip(
                    label: Text(cat),
                    selected: sel,
                    onSelected: (v) => setState(() {
                      if (v) {
                        selectedCategories.add(cat);
                      } else {
                        selectedCategories.remove(cat);
                      }
                    }),
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Erinnerungen
          Text('Erinnerungen', style: h1),
          const SizedBox(height: 8),
          _Card(child: Column(children: [
            ListTile(
              title: const Text('Häufigkeit'),
              subtitle: Text('Wie oft Benachrichtigungen gebündelt werden', style: hint),
              trailing: DropdownButton<String>(
                value: frequency,
                onChanged: (v) => setState(() => frequency = v!),
                items: freqOptions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              title: const Text('Tageszeit'),
              subtitle: Text('Standardzeitpunkt für tägliche Erinnerungen', style: hint),
              trailing: TextButton(
                onPressed: () async {
                  final t = await showTimePicker(context: context, initialTime: reminderTime);
                  if (t != null) setState(() => reminderTime = t);
                },
                child: Text('${reminderTime.hour.toString().padLeft(2, '0')}:${reminderTime.minute.toString().padLeft(2, '0')}'),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Wrap(
                spacing: 8,
                children: weekdays.map((d) {
                  final sel = reminderDays.contains(d);
                  return FilterChip(
                    label: Text(d),
                    selected: sel,
                    onSelected: (v) => setState(() {
                      if (v) {
                        reminderDays.add(d);
                      } else {
                        reminderDays.remove(d);
                      }
                    }),
                  );
                }).toList(),
              ),
            ),
          ])),

          const SizedBox(height: 20),

          // Einheiten & Format
          Text('Einheiten & Format', style: h1),
          const SizedBox(height: 8),
          _Card(child: Column(children: [
            ListTile(
              title: const Text('Distanzen'),
              subtitle: Text('km oder mi', style: hint),
              trailing: DropdownButton<String>(
                value: distanceUnit,
                onChanged: (v) => setState(() => distanceUnit = v!),
                items: ['km', 'mi'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              title: const Text('Datumsformat'),
              subtitle: Text('Anzeigeformat für Daten', style: hint),
              trailing: DropdownButton<String>(
                value: dateFormat,
                onChanged: (v) => setState(() => dateFormat = v!),
                items: ['dd.MM.yyyy', 'MM/dd/yyyy', 'yyyy-MM-dd']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
              ),
            ),
          ])),

          const SizedBox(height: 20),

          // Barrierefreiheit
          Text('Barrierefreiheit', style: h1),
          const SizedBox(height: 8),
          _Card(child: Column(children: [
            SwitchListTile(
              value: largerTapTargets,
              onChanged: (v) => setState(() => largerTapTargets = v),
              title: const Text('Größere Schaltflächen'),
              subtitle: Text('Erhöht die Berührungsfläche für Buttons', style: hint),
            ),
            const Divider(height: 1),
            SwitchListTile(
              value: reduceMotion,
              onChanged: (v) => setState(() => reduceMotion = v),
              title: const Text('Weniger Animationen'),
              subtitle: Text('Reduziert Bewegungen für mehr Ruhe', style: hint),
            ),
          ])),
          const SizedBox(height: 32),
        ],
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: child,
    );
  }
}
