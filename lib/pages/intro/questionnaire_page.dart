import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'widgets/cute_landscape.dart';
import 'widgets/gradient_progress.dart';

class QuestionnairePage extends StatefulWidget {
  const QuestionnairePage({super.key});

  @override
  State<QuestionnairePage> createState() => _QuestionnairePageState();
}

class _QuestionnairePageState extends State<QuestionnairePage> {
  static const double _landscapeH = 180;

  int step = 0;
  final Map<int, String> answers = {};

  final List<_Q> questions = const [
    _Q('Wie heißt du?', type: _QType.text, hint: 'Antwort eingeben'),
    _Q('Was ist dein Alter?', options: ['Unter 18', '18–22', '23–27', '28–35', '35–50', '50+']),
    _Q('Was machst du beruflich?', options: ['Schüler/Student', 'Auszubildende/-r', 'Arbeitnehmer', 'Sonstiges']),
    _Q('Was ist dein Geschlecht?', options: ['Männlich', 'Weiblich', 'Divers']),
    _Q('Wann hast du Geburtstag?', type: _QType.text, hint: 'z. B. 12.08.2000'),
  ];

  final List<List<Color>> _pastels = const [
    [Color(0xFFF7FBF5), Color(0xFFEFF7EA)],
    [Color(0xFFF7FAFF), Color(0xFFE8F0FF)],
    [Color(0xFFFFF7F8), Color(0xFFFFEFEF)],
    [Color(0xFFFAF6FF), Color(0xFFF4ECFF)],
    [Color(0xFFF7FBF5), Color(0xFFEFF7EA)],
  ];

  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  bool _validTextAnswer(_Q q) {
    final v = _textController.text.trim();
    if (q.title.startsWith('Wie heißt du')) {
      return RegExp(r"^[A-Za-zÄÖÜäöüß\- ]{2,}$").hasMatch(v);
    }
    if (q.title.startsWith('Wann hast du Geburtstag')) {
      final okChars = RegExp(r"^[0-9.]+$").hasMatch(v);
      final okFormat = RegExp(r"^([0-2]?\d|3[01])\.(0?\d|1[0-2])\.(19|20)\d{2}$").hasMatch(v);
      return okChars && okFormat;
    }
    return v.isNotEmpty;
  }

  void _next() {
    final q = questions[step];
    if (q.type == _QType.text) answers[step] = _textController.text.trim();
    if (step < questions.length - 1) {
      setState(() {
        step++;
        _textController.text = answers[step] ?? '';
      });
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
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

    List<TextInputFormatter>? inputFormatters;
    TextInputType? keyboardType;
    if (q.title.startsWith('Wie heißt du')) {
      inputFormatters = [
        FilteringTextInputFormatter.allow(RegExp(r"[A-Za-zÄÖÜäöüß\- ]")),
        LengthLimitingTextInputFormatter(40),
      ];
      keyboardType = TextInputType.name;
    } else if (q.title.startsWith('Wann hast du Geburtstag')) {
      inputFormatters = [
        FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
        LengthLimitingTextInputFormatter(10),
      ];
      keyboardType = TextInputType.datetime;
    }

    final bool canContinue = q.type == _QType.text
        ? _validTextAnswer(q)
        : (answers[step]?.isNotEmpty ?? false);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Pastell
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
            ),

            // Landschaft unten (mehrlagig optional)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: CuteLandscape(height: _landscapeH, variant: step),
            ),

            // Inhalt
            Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + _landscapeH + bottomInset),
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
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        hintText: q.hint ?? 'Antwort eingeben',
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
                          final sel = answers[step] == opt;
                          return InkWell(
                            onTap: () => setState(() => answers[step] = opt),
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
