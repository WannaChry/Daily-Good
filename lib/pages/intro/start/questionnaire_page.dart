// lib/profil/intro/questionnaire_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/cute_landscape.dart';
import '../widgets/gradient_progress.dart';
// Die beiden Imports sind hier unnötig; kannst du entfernen wenn du magst
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studyproject/pages/models/user.dart';

class QuestionnairePage extends StatefulWidget {
  const QuestionnairePage({super.key});

  @override
  State<QuestionnairePage> createState() => _QuestionnairePageState();
}

class _QuestionnairePageState extends State<QuestionnairePage> {
  static const double _landscapeH = 180;

  int step = 0;
  final Map<String, String> answers = {};

  // Neue Frage 2: E-Mail
  final List<_Q> questions = const [
    _Q('Wie heißt du?', type: _QType.text, hint: 'Antwort eingeben'),
    _Q('Was ist dein Alter?', options: ['Unter 18', '18–22', '23–27', '28–35', '35–50', '50+']),
    _Q('Was machst du beruflich?', options: ['Schüler/Student', 'Auszubildende/-r', 'Arbeitnehmer', 'Sonstiges']),
    _Q('Was ist dein Geschlecht?', options: ['Männlich', 'Weiblich', 'Divers']),
    _Q('Wie lautet deine E-Mail?', type: _QType.text, hint: 'name@example.com'),
    _Q('Wähle ein Passwort', type: _QType.text, hint: '••••••••'),
    _Q('Wann hast du Geburtstag?', type: _QType.text, hint: 'z. B. 12.08.2000'),
  ];

  final List<List<Color>> _pastels = const [
    [Color(0xFFF7FBF5), Color(0xFFEFF7EA)], // 0: Name
    [Color(0xFFF7FAFF), Color(0xFFE8F0FF)], // 1: E-Mail
    [Color(0xFFFFF7F8), Color(0xFFFFEFEF)], // 2: Alter
    [Color(0xFFFAF6FF), Color(0xFFF4ECFF)], // 3: Beschäftigung
    [Color(0xFFF7FBF5), Color(0xFFEFF7EA)], // 4: Geschlecht
    [Color(0xFFF0F6FF), Color(0xFFE4EEFF)], // 5: Geburtstag → HELLBLAU
  ];

  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String v) {
    final s = v.trim();
    if (s.isEmpty) return false;
    return RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]{2,}$').hasMatch(s);
  }

  bool _validTextAnswer(_Q q) {
    final v = _textController.text.trim();
    if (q.title.startsWith('Wie heißt du')) {
      return RegExp(r'^[A-Za-zÄÖÜäöüß\- ]{2,}$').hasMatch(v);
    }
    if (q.title.startsWith('Wie lautet deine E')) {
      return _isValidEmail(v);
    }
    if (q.title.startsWith('Wann hast du Geburtstag')) {
      final okChars = RegExp(r'^[0-9.]+$').hasMatch(v);
      final okFormat = RegExp(r'^([0-2]?\d|3[01])\.(0?\d|1[0-2])\.(19|20)\d{2}$').hasMatch(v);
      return okChars && okFormat;
    }
    if (q.title.startsWith('Wähle ein Passwort')) {
      return v.length >= 6; // Mindestlänge
    }

    return v.isNotEmpty;
  }

  void _next() {
    final q = questions[step];
    if (q.type == _QType.text) {
      answers[q.title] = _textController.text.trim();
    }
    if (step < questions.length - 1) {
      setState(() {
        step++;
        _textController.text = answers[step] ?? '';
      });
    } else {
      // am Ende → Review & Confirm
      Navigator.of(context).pushNamed(
        '/intro/review',
        arguments: {
          'answers': Map<String, String>.from(answers),
        },
      );
    }
  }

  void _back() {
    if (step == 0) {
      Navigator.of(context).maybePop();
      return;
    }
    setState(() {
      step--;
      _textController.text = answers[step] ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final q = questions[step];
    final progress = (step + 1) / questions.length;
    final pastel = _pastels[step % _pastels.length];
    final bottomInset = MediaQuery.of(context).padding.bottom;

    // Input-Setup je nach Frage
    List<TextInputFormatter>? inputFormatters;
    TextInputType? keyboardType;
    TextCapitalization capitalization = TextCapitalization.words;

    if (q.title.startsWith('Wie heißt du')) {
      inputFormatters = [
        FilteringTextInputFormatter.allow(RegExp(r'[A-Za-zÄÖÜäöüß\- ]')),
        LengthLimitingTextInputFormatter(40),
      ];
      keyboardType = TextInputType.name;
    } else if (q.title.startsWith('Wie lautet deine E')) {
      inputFormatters = [
        FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9@\.\_\-\+]+')),
        LengthLimitingTextInputFormatter(80),
      ];
      keyboardType = TextInputType.emailAddress;
      capitalization = TextCapitalization.none;
    } else if (q.title.startsWith('Wann hast du Geburtstag')) {
      inputFormatters = [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
        LengthLimitingTextInputFormatter(10),
      ];
      keyboardType = TextInputType.datetime;
      capitalization = TextCapitalization.none;
    }
    else if (q.title.startsWith('Wähle ein Passwort')) {
      inputFormatters = [
        LengthLimitingTextInputFormatter(30),
      ];
      keyboardType = TextInputType.visiblePassword;
      capitalization = TextCapitalization.none;
    }

    final bool canContinue = q.type == _QType.text
        ? _validTextAnswer(q)
        : (answers[q.title]?.isNotEmpty ?? false);


    // Spezielle Optik für die E-Mail-Frage
    final isEmailStep = q.title.startsWith('Wie lautet deine E');

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Hintergrund
            if (!isEmailStep)
            // Standard-Gradient
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: pastel,
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: const SizedBox.expand(),
              )
            else
            // Alternativer Look – radial + „Bubbles“ + großes @
              _EmailBackdrop(colors: pastel),

            // Landscape (JETZT IMMER sichtbar) mit weichem Übergang
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: IgnorePointer(
                child: SizedBox(
                  height: _landscapeH,
                  child: ShaderMask(
                    shaderCallback: (Rect r) => const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black],
                      stops: [0.0, 0.22], // weiche Einblendung
                    ).createShader(r),
                    blendMode: BlendMode.dstIn,
                    child: CuteLandscape(height: _landscapeH, variant: step),
                  ),
                ),
              ),
            ),

            // Inhalt
            Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                12,
                16,
                16 + _landscapeH + bottomInset,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back + Progress
                  Row(
                    children: [
                      IconButton(
                        onPressed: _back,
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            height: 24,
                            child: GradientProgressBar(progress: progress),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  Text(q.title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 14),

                  if (q.type == _QType.text) ...[
                    TextField(
                      controller: _textController,
                      inputFormatters: inputFormatters,
                      keyboardType: keyboardType,
                      textCapitalization: capitalization,
                      obscureText: q.title.startsWith('Wähle ein Passwort'),
                      decoration: InputDecoration(
                        hintText: q.hint ?? 'Antwort eingeben',
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        suffixIcon: q.title.startsWith('Wie lautet deine E')
                            ? (_validTextAnswer(q)
                            ? const Icon(Icons.check_circle, color: Colors.green)
                            : const Icon(Icons.alternate_email_rounded, color: Colors.black45))
                            : null,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    _ContinueButton(enabled: canContinue, onPressed: _next),
                  ] else ...[
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.only(bottom: 12),
                        itemCount: q.options!.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) {
                          final opt = q.options![i];
                          final sel = answers[q.title] == opt;
                          return InkWell(
                            onTap: () => setState(() => answers[q.title] = opt),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: sel ? Colors.lightGreen.withValues(alpha: .35) : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: sel ? Colors.green : Colors.black12,
                                  width: sel ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(opt, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                                  ),
                                  Icon(
                                    sel ? Icons.check_circle_rounded : Icons.circle_outlined,
                                    color: sel ? Colors.green : Colors.black38,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ContinueButton(enabled: canContinue, onPressed: _next),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmailBackdrop extends StatelessWidget {
  const _EmailBackdrop({required this.colors});
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Radialer Verlauf
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.2),
                radius: 1.2,
                colors: [
                  colors.first.withValues(alpha: .9),
                  colors.last.withValues(alpha: 1),
                ],
              ),
            ),
          ),
        ),
        // „Bubbles“
        Positioned(top: 80, left: -30, child: _bubble(120)),
        Positioned(top: 10, right: -24, child: _bubble(90)),
        Positioned(bottom: 100, right: 40, child: _bubble(70)),
        // großes Mail-Icon sehr dezent
        Positioned.fill(
          child: IgnorePointer(
            child: Center(
              child: Icon(
                Icons.alternate_email_rounded,
                size: 140,
                color: Colors.black.withValues(alpha: .05),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _bubble(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .25),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .06),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }
}

class _ContinueButton extends StatelessWidget {
  const _ContinueButton({required this.enabled, required this.onPressed});
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          disabledBackgroundColor: Colors.black26,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: const Text('Weiter', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
      ),
    );
  }
}

enum _QType { options, text }

class _Q {
  const _Q(this.title, {this.options, this.type = _QType.options, this.hint});
  final String title;
  final List<String>? options;
  final _QType type;
  final String? hint;
}
