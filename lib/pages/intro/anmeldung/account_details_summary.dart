import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:studyproject/pages/intro/auth/auth_service.dart';

// UI-Widgets
import 'package:studyproject/pages/intro/widgets/brand_button.dart';
import 'package:studyproject/pages/intro/widgets/profile_avatar_glow.dart';
import 'package:studyproject/pages/intro/widgets/summary_item.dart';
import 'package:studyproject/pages/intro/widgets/aurora_background.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  late Map<String, String> _data;
  Uint8List? _localAvatar;
  bool _submitting = false;
  bool _initialized = false;
  final _picker = ImagePicker();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final args = ModalRoute.of(context)?.settings.arguments as Map? ?? {};
    _data = (args['answers'] as Map?)?.cast<String, String>() ?? {};
    _initialized = true;
  }

  Future<void> _pickLocalAvatar() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() => _localAvatar = bytes);
  }

  Future<void> _createAndGoHome() async {
    if (!mounted) return;

    final email = _data['Wie lautet deine E-Mail?'] ?? '';
    final password = _data['Wähle ein Passwort'] ?? '';
    final name = _data['Wie heißt du?'] ?? '';

    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte Name, E-Mail und Passwort eingeben.')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final res = await AuthMethod().signUpUser(
        email: email,
        password: password,
        name: name,
        extraData: {
          'ageRange': _data['Was ist dein Alter?'] ?? '',
          'occupation': _data['Was machst du beruflich?'] ?? '',
          'gender': _data['Was ist dein Geschlecht?'] ?? '',
          'birthday': _data['Wann hast du Geburtstag?'] ?? '',
        },
      );

      if (!mounted) return;
      if (res == "success") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account erfolgreich erstellt!')),
        );
        Navigator.of(context).pushReplacementNamed('/streak', arguments: {
          'currentStreak': 1,
          'bestStreak': 1,
          'lastCheckIn': DateTime.now(),
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: $res')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final name = _data['Wie heißt du?'] ?? '';
    final email = _data['Wie lautet deine E-Mail?'] ?? '';
    final password = _data['Wähle ein Passwort'] ?? '';
    final maskedPw = '*' * password.length;
    final initials =
    (name.isEmpty ? '🙂' : name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '🙂');

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0, backgroundColor: Colors.transparent,
        title: const Text('Profil prüfen'),
        leading: BackButton(onPressed: () => Navigator.pop(context)),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: AuroraBackground(
              colors: const [
                Color(0xFFF1F8F4),
                Color(0xFFBEE3D3),
                Color(0xFFA7D9CA),
                Color(0xFFFFFFFF),
              ],
              intensity: 0.60,
            ),
          ),

          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    children: [
                      // Header-Card
                      Card(
                        elevation: 12,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                          child: Row(
                            children: [
                              ProfileAvatarGlow(
                                bytes: _localAvatar,
                                initials: initials,
                                onTap: _pickLocalAvatar,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name.isEmpty ? 'Unbenannt' : name,
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -0.2,
                                        color: Colors.black, // mehr Kontrast
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      email.isEmpty ? 'E-Mail fehlt' : email,
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        fontSize: 15.5,
                                        color: Colors.black.withValues(alpha: 0.72),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Scrollbarer Inhalt
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, c) {
                            final kb = MediaQuery.of(context).viewInsets.bottom;
                            return SingleChildScrollView(
                              padding: EdgeInsets.only(bottom: kb + 24),
                              physics: const ClampingScrollPhysics(),
                              child: Column(
                                children: [
                                  _sectionHeader(context, 'Kontodaten'),
                                  SummaryItem(
                                    leading: Icons.password_rounded,
                                    label: 'Passwort',
                                    value: maskedPw,
                                  ),

                                  const SizedBox(height: 12),

                                  _sectionHeader(context, 'Profil'),
                                  SummaryItem(
                                    leading: Icons.cake_outlined,
                                    label: 'Geburtstag',
                                    value: _data['Wann hast du Geburtstag?'] ?? '',
                                  ),
                                  SummaryItem(
                                    leading: Icons.timelapse_rounded,
                                    label: 'Alter',
                                    value: _data['Was ist dein Alter?'] ?? '',
                                  ),
                                  SummaryItem(
                                    leading: Icons.work_outline_rounded,
                                    label: 'Beschäftigung',
                                    value: _data['Was machst du beruflich?'] ?? '',
                                  ),
                                  SummaryItem(
                                    leading: Icons.wc_outlined,
                                    label: 'Geschlecht',
                                    value: _data['Was ist dein Geschlecht?'] ?? '',
                                  ),

                                  const SizedBox(height: 22),

                                  _hintCard(
                                    context,
                                    icon: Icons.info_outline_rounded,
                                    text:
                                    'Bitte prüfe deine Angaben. Du kannst den Avatar antippen, um ein Bild aus deiner Galerie zu wählen.',
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      // CTA
                      BrandButton(
                        label: 'Account erstellen',
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFEDEDED),
                        ),
                        onPressed: _submitting ? null : _createAndGoHome,
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

  // ↑ Überschriften etwas größer & deutlicher
  Widget _sectionHeader(BuildContext context, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 10),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16.5,           // größer
            fontWeight: FontWeight.w900,
            letterSpacing: -0.1,
            color: Colors.black,      // kontrastreich
          ),
        ),
      ),
    );
  }

  // Hinweis-Kachel: Text & Icon schwarz, besser lesbar
  Widget _hintCard(BuildContext context, {required IconData icon, required String text}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF).withValues(alpha: 0.60),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF000000).withValues(alpha: 0.10)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.black,           // ← Text schwarz
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
