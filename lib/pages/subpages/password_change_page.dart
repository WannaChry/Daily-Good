import 'package:flutter/material.dart';
import 'package:studyproject/pages/intro/auth/auth_service.dart';

class PasswordChangePage extends StatefulWidget {
  const PasswordChangePage({super.key});

  @override
  State<PasswordChangePage> createState() => _PasswordChangePageState();
}

class _PasswordChangePageState extends State<PasswordChangePage> {
  final _oldCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _new2Ctrl = TextEditingController();

  bool _obOld = true, _obNew = true, _obNew2 = true;
  bool _busy = false;

  @override
  void dispose() {
    _oldCtrl.dispose();
    _newCtrl.dispose();
    _new2Ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final oldPw = _oldCtrl.text.trim();
    final newPw = _newCtrl.text.trim();
    final newPw2 = _new2Ctrl.text.trim();

    if (newPw.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Neues Passwort muss mind. 6 Zeichen haben.')),
      );
      return;
    }
    if (newPw != newPw2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Neue Passwörter stimmen nicht überein.')),
      );
      return;
    }

    setState(() => _busy = true);
    final res = await AuthMethod().changePassword(
      currentPassword: oldPw,
      newPassword: newPw,
    );
    if (!mounted) return;

    setState(() => _busy = false);
    if (res == "success") {
      _oldCtrl.clear();
      _newCtrl.clear();
      _new2Ctrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwort wurde geändert.')),
      );
      Navigator.pop(context); // zurück zur Sicherheitsseite
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler: $res')),
      );
    }
  }

  InputDecoration _dec(String label, {Widget? suffix}) => InputDecoration(
    labelText: label,
    border: const OutlineInputBorder(),
    suffixIcon: suffix,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Passwort ändern')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _oldCtrl,
            obscureText: _obOld,
            decoration: _dec('Aktuelles Passwort',
                suffix: IconButton(
                  icon: Icon(_obOld ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obOld = !_obOld),
                )),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _newCtrl,
            obscureText: _obNew,
            decoration: _dec('Neues Passwort (min. 6 Zeichen)',
                suffix: IconButton(
                  icon: Icon(_obNew ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obNew = !_obNew),
                )),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _new2Ctrl,
            obscureText: _obNew2,
            decoration: _dec('Neues Passwort wiederholen',
                suffix: IconButton(
                  icon: Icon(_obNew2 ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obNew2 = !_obNew2),
                )),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _busy ? null : _save,
            child: _busy
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Passwort ändern'),
          ),
        ],
      ),
    );
  }
}
