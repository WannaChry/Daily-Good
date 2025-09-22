// lib/pages/intro/review_confirm_page.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'widgets/interactive_clouds.dart';
import 'widgets/wind_lines.dart';
import '../state/auth_state.dart';
import 'package:studyproject/pages/models/user.dart';

class ReviewConfirmPage extends StatefulWidget {
  const ReviewConfirmPage({super.key});
  @override
  State<ReviewConfirmPage> createState() => _ReviewConfirmPageState();
}

class _ReviewConfirmPageState extends State<ReviewConfirmPage> {
  final List<Color> _bg = const [Color(0xFFEFF6FF), Color(0xFFDBEAFF)];

  late Map<int, String> _answers;
  late Map<String, String?> _data; // name, email, ageRange, occupation, gender, birthday
  bool _submitting = false;
  bool _initialized = false;

  // NEU: lokales Avatar-Bild (noch kein User -> später beim Erstellen hochladen)
  Uint8List? _localAvatar;

  Map<String, String?> _mapAnswers(Map<int, String> a) => {
    'name': a[0],
    'email': a[1],
    'ageRange': a[2],
    'occupation': a[3],
    'gender': a[4],
    'birthday': a[5],
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final args = ModalRoute.of(context)?.settings.arguments as Map? ?? {};
    _answers = (args['answers'] as Map?)?.cast<int, String>() ?? {};
    _data = _mapAnswers(_answers);
    _initialized = true;
  }

  bool _isValidEmail(String v) {
    final s = v.trim();
    if (s.isEmpty) return false;
    return RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]{2,}$').hasMatch(s);
  }

  Future<void> _createAndGoHome() async {
    if (!mounted) return;
    final mail = _data['email'];
    if (mail == null || !_isValidEmail(mail)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte eine gültige E-Mail angeben.')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final auth = AuthState.of(context);
      await auth.createAccountFromReview(_data, avatarBytes: _localAvatar);
      await auth.refresh();
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(
        '/streak',
        arguments: {
          'currentStreak': 1,
          'bestStreak': 1,
          'lastCheckIn': DateTime.now(),
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erstellen fehlgeschlagen: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _pickLocalAvatar() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (x == null) return;
    final bytes = await x.readAsBytes();
    setState(() => _localAvatar = bytes);
  }

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _bg,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          const Positioned.fill(child: WindLines(opacity: .12, layers: 4)),
          const Positioned.fill(child: IgnorePointer(ignoring: false, child: InteractiveClouds())),

          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 4),
                          const Text('Profil prüfen', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                        ],
                      ),
                      const SizedBox(height: 8),

                      _summaryCard(context),
                      const SizedBox(height: 12),

                      _editableField(
                        label: 'Alter',
                        value: _data['ageRange'],
                        onEdit: () async {
                          final v = await _pickOption(
                            title: 'Alter wählen',
                            initial: _data['ageRange'],
                            options: const ['Unter 18', '18–22', '23–27', '28–35', '35–50', '50+'],
                          );
                          if (v != null) {
                            setState(() {
                              _data['ageRange'] = v;
                              _answers[2] = v;
                            });
                          }
                        },
                      ),
                      _editableField(
                        label: 'Beschäftigung',
                        value: _data['occupation'],
                        onEdit: () async {
                          final v = await _pickOption(
                            title: 'Beschäftigung wählen',
                            initial: _data['occupation'],
                            options: const ['Schüler/Student', 'Auszubildende/-r', 'Arbeitnehmer', 'Sonstiges'],
                          );
                          if (v != null) {
                            setState(() {
                              _data['occupation'] = v;
                              _answers[3] = v;
                            });
                          }
                        },
                      ),
                      _editableField(
                        label: 'Geschlecht',
                        value: _data['gender'],
                        onEdit: () async {
                          final v = await _pickOption(
                            title: 'Geschlecht wählen',
                            initial: _data['gender'],
                            options: const ['Männlich', 'Weiblich', 'Divers'],
                          );
                          if (v != null) {
                            setState(() {
                              _data['gender'] = v;
                              _answers[4] = v;
                            });
                          }
                        },
                      ),
                      _editableField(
                        label: 'Geburtstag',
                        value: _data['birthday'],
                        onEdit: () async {
                          final v = await _pickText(
                            title: 'Geburtstag ändern',
                            initial: _data['birthday'] ?? '',
                            hint: 'z. B. 12.08.2000',
                            keyboardType: TextInputType.datetime,
                            capitalization: TextCapitalization.none,
                            validator: (v) {
                              final okChars = RegExp(r'^[0-9.]+$').hasMatch(v);
                              final okFormat = RegExp(r'^([0-2]?\d|3[01])\.(0?\d|1[0-2])\.(19|20)\d{2}$').hasMatch(v);
                              if (!okChars || !okFormat) return 'Bitte im Format TT.MM.JJJJ angeben.';
                              return null;
                            },
                          );
                          if (v != null) {
                            final trimmed = v.trim();
                            setState(() {
                              _data['birthday'] = trimmed.isEmpty ? null : trimmed;
                              if (trimmed.isNotEmpty) _answers[5] = trimmed;
                            });
                          }
                        },
                      ),

                      const Spacer(),

                      Padding(
                        padding: EdgeInsets.only(bottom: 16 + bottomSafe, top: 8),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 340),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _submitting ? null : _createAndGoHome,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              ),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                transitionBuilder: (c, a) => FadeTransition(opacity: a, child: c),
                                child: _submitting
                                    ? const SizedBox(
                                  key: ValueKey('loading'),
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                                    : const Text(
                                  'Account erstellen',
                                  key: ValueKey('text'),
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ======= Picker =======
  Future<String?> _pickText({
    required String title,
    required String initial,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String value)? validator,
    TextCapitalization capitalization = TextCapitalization.sentences,
  }) async {
    final controller = TextEditingController(text: initial);
    String? error;

    String? _validate() {
      final v = controller.text.trim();
      final err = validator?.call(v);
      if (err != null) return err;
      return null;
    }

    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetCtx) {
        final bottomInset = MediaQuery.of(sheetCtx).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
          child: StatefulBuilder(
            builder: (ctx, setSheet) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                const SizedBox(height: 10),
                TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  textCapitalization: capitalization,
                  decoration: InputDecoration(
                    hintText: hint ?? '',
                    errorText: error,
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  ),
                  onSubmitted: (_) {
                    final err = _validate();
                    if (err != null) {
                      setSheet(() => error = err);
                      return;
                    }
                    Navigator.pop(sheetCtx, controller.text.trim());
                  },
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final err = _validate();
                      if (err != null) {
                        setSheet(() => error = err);
                        return;
                      }
                      Navigator.pop(sheetCtx, controller.text.trim());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Übernehmen', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<String?> _pickOption({
    required String title,
    required String? initial,
    required List<String> options,
  }) async {
    final current = initial;

    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetCtx) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: options.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final o = options[i];
                      final selected = o == current;
                      return ListTile(
                        title: Text(o, style: const TextStyle(fontWeight: FontWeight.w600)),
                        trailing: Icon(
                          selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                          color: selected ? Colors.green : Colors.black26,
                        ),
                        onTap: () => Navigator.pop(sheetCtx, o),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------- UI-Bausteine ----------
  Widget _summaryCard(BuildContext context) {
    final name = (_data['name'] ?? '').trim();
    final email = _data['email'];
    final emailValid = email != null && _isValidEmail(email);

    final avatar = _localAvatar;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.65),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar + Edit
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.black.withOpacity(.08),
                    backgroundImage: avatar != null ? MemoryImage(avatar) : null,
                    child: avatar == null
                        ? Text(
                      name.isNotEmpty ? String.fromCharCode(name.runes.first) : '🙂',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                    )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: -2,
                    child: Material(
                      color: Colors.black,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: _pickLocalAvatar,
                        child: const Padding(
                          padding: EdgeInsets.all(6.0),
                          child: Icon(Icons.edit, size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),

              // Name + Email
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name.isEmpty ? 'Unbenannt' : name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.mail_outline, size: 16, color: Colors.black54),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            email ?? 'E-Mail hinzufügen',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: emailValid ? Colors.black87 : Colors.redAccent),
                          ),
                        ),
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: () async {
                            final v = await _pickText(
                              title: 'E-Mail bearbeiten',
                              initial: _data['email'] ?? '',
                              hint: 'name@example.com',
                              keyboardType: TextInputType.emailAddress,
                              capitalization: TextCapitalization.none,
                              validator: (v) => _isValidEmail(v) ? null : 'Ungültige E-Mail.',
                            );
                            if (v != null) {
                              final trimmed = v.trim();
                              setState(() {
                                _data['email'] = trimmed.isEmpty ? null : trimmed;
                                if (trimmed.isNotEmpty) _answers[1] = trimmed;
                              });
                            }
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6.0),
                            child: Icon(Icons.edit, size: 18),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Verifizierungs-Hinweis
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.7),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.black12),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_user_outlined, size: 18, color: Colors.black54),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    emailValid ? 'Verifizierung ausstehend' : 'Bitte gültige E-Mail angeben (für Verifizierung)',
                    style: TextStyle(fontWeight: FontWeight.w600, color: emailValid ? Colors.black87 : Colors.redAccent),
                  ),
                ),
                const SizedBox(width: 6),
                TextButton(
                  onPressed: emailValid ? () => Navigator.of(context).pushNamed('/verify', arguments: {'email': _data['email']}) : null,
                  child: const Text('2-Faktor aktivieren'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _editableField({required String label, required String? value, required VoidCallback onEdit}) {
    return Container(
      key: ValueKey('$label::$value'),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(value ?? '—', style: const TextStyle(color: Colors.black87)),
            ]),
          ),
          InkWell(
            onTap: onEdit,
            borderRadius: BorderRadius.circular(10),
            child: const Padding(padding: EdgeInsets.all(8.0), child: Icon(Icons.edit, size: 18)),
          )
        ],
      ),
    );
  }
}

