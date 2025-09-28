import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:studyproject/pages/state/auth_state.dart';

class LogoutButton extends StatelessWidget {
  final AuthState authState;
  const LogoutButton({super.key, required this.authState});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.red.shade400,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (dCtx) => AlertDialog(
              title: const Text('Logout?'),
              content: const Text('Willst du dich wirklich ausloggen?'),
              actions: [
                TextButton(onPressed: () => Navigator.of(dCtx).pop(false), child: const Text('Abbrechen')),
                TextButton(onPressed: () => Navigator.of(dCtx).pop(true), child: const Text('Ja, ausloggen')),
              ],
            ),
          ) ?? false;

          if (!confirm) return;

          try {
            await authState.signOut();
            if (!context.mounted) return;

            Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);

            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Abgemeldet.')));
          } catch (e) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Logout fehlgeschlagen: $e')));
          }
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          alignment: Alignment.center,
          child: Text(
            'Logout',
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
