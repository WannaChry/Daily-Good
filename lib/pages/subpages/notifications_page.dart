import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool pushEnabled = true;
  bool emailEnabled = false;
  bool silentMode = false;
  String frequency = 'Sofort';

  final List<String> _freqOptions = ['Sofort', 'Stündlich', 'Täglich'];

  @override
  Widget build(BuildContext context) {
    final h1 = GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800);
    final hint = GoogleFonts.poppins(fontSize: 12.5, color: Colors.grey.shade700);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F3FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Benachrichtigungen',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Allgemein', style: h1),
          const SizedBox(height: 8),

          _Card(
            child: Column(
              children: [
                SwitchListTile(
                  value: pushEnabled,
                  onChanged: (v) => setState(() => pushEnabled = v),
                  title: const Text('App-Benachrichtigungen'),
                  subtitle: Text('Erhalte Push-Benachrichtigungen von der App', style: hint),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  value: emailEnabled,
                  onChanged: (v) => setState(() => emailEnabled = v),
                  title: const Text('E-Mail-Benachrichtigungen'),
                  subtitle: Text('Zusammenfassungen oder wichtige Hinweise per Mail', style: hint),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  value: silentMode,
                  onChanged: (v) => setState(() => silentMode = v),
                  title: const Text('Ruhemodus'),
                  subtitle: Text('Benachrichtigungen stumm schalten', style: hint),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          Text('Häufigkeit', style: h1),
          const SizedBox(height: 8),

          _Card(
            child: ListTile(
              title: const Text('Standard-Häufigkeit'),
              subtitle: Text('Wann sollen Benachrichtigungen gebündelt werden?', style: hint),
              trailing: DropdownButton<String>(
                value: frequency,
                onChanged: (v) => setState(() => frequency = v!),
                items: _freqOptions
                    .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                    .toList(),
              ),
            ),
          ),
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
