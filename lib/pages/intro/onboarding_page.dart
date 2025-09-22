// lib/pages/intro/onboarding_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'widgets/cute_landscape.dart';
import 'widgets/gradient_progress.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  static const double _landscapeH = 180;

  final _pc = PageController();
  int _index = 0;

  // Easter Egg Schalter (für Prod ggf. auf false setzen)
  static const bool _devSkipEnabled = true;

  final _slides = const [
    _SlideData(
      emoji: '🌱',
      title: 'Willkommen bei Daily Good',
      text: 'Kleine gute Taten – für Umwelt, Mitmenschen und dich.',
    ),
    _SlideData(
      emoji: '⚡️',
      title: 'So funktioniert’s',
      text: 'Erledige Aufgaben, sammle Punkte & Abzeichen – bleib motiviert.',
    ),
    _SlideData(
      emoji: '🤝',
      title: 'Gemeinsam besser',
      text: 'Tritt Communities bei und wachst zusammen mit Freunden.',
    ),
  ];

  // Pastell-Hintergründe (wie im Questionnaire)
  final List<List<Color>> _pastels = const [
    [Color(0xFFF7FBF5), Color(0xFFEFF7EA)],
    [Color(0xFFF7FAFF), Color(0xFFE8F0FF)],
    [Color(0xFFFFF7F8), Color(0xFFFFEFEF)],
  ];

  void _next() {
    if (_index < _slides.length - 1) {
      _pc.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    } else {
      Navigator.of(context).pushReplacementNamed('/auth_choice');
    }
  }

  void _skipAllToHome() {
    // Easter Egg: direkt zur Home, Onboarding & Questionnaire überspringen
    HapticFeedback.lightImpact();
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
  }

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = _slides.length;
    final progress = (_index + 1) / total;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final pastel = _pastels[_index % _pastels.length];

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Pastell-Gradient
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

            // Landschaft unten (mit weicher Einblendung → keine sichtbare Kante)
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
                      stops: [0.0, 0.22], // Stärke der sanften Einblendung
                    ).createShader(r),
                    blendMode: BlendMode.dstIn,
                    child: CuteLandscape(
                      height: _landscapeH,
                      variant: _index,
                    ),
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
                children: [
                  // Fortschrittsbalken oben – nur EIN Balken
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      height: 24,
                      child: GradientProgressBar(
                        progress: progress,
                        shinePeriod: const Duration(seconds: 6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // PageView mit Parallax + Long-Press Easter Egg auf dem Emoji
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _pc,
                      builder: (context, _) {
                        final page = _pc.hasClients && _pc.page != null
                            ? _pc.page!
                            : _index.toDouble();
                        return PageView.builder(
                          controller: _pc,
                          itemCount: _slides.length,
                          onPageChanged: (i) => setState(() => _index = i),
                          itemBuilder: (_, i) {
                            final delta = (i - page); // -1..1
                            return _ParallaxSlide(
                              data: _slides[i],
                              delta: delta,
                              onEmojiLongPress:
                              _devSkipEnabled ? _skipAllToHome : null,
                            );
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Skip – Dots – Weiter
                  Row(
                    children: [
                      // Skip links
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () => Navigator.of(context)
                                .pushReplacementNamed('/questionnaire'),
                            child: const Text(
                              'Skip',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Dots mittig
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(total, (i) {
                            final active = i == _index;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              height: 10,
                              width: active ? 22 : 10,
                              decoration: BoxDecoration(
                                color: active ? Colors.black87 : Colors.black26,
                                borderRadius: BorderRadius.circular(999),
                              ),
                            );
                          }),
                        ),
                      ),

                      // Weiter rechts
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 12),
                            ),
                            onPressed: _next,
                            child: Text(
                                _index == total - 1 ? 'Los geht’s' : 'Weiter'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParallaxSlide extends StatelessWidget {
  const _ParallaxSlide({
    required this.data,
    required this.delta,
    this.onEmojiLongPress,
  });

  final _SlideData data;
  final double delta; // -1..1
  final VoidCallback? onEmojiLongPress;

  @override
  Widget build(BuildContext context) {
    final fgShift = 18.0 * delta; // Titel/Text
    final emojiShift = 34.0 * delta; // Emoji stärker

    return Stack(
      children: [
        // Emoji (mit Long-Press Easter Egg)
        Transform.translate(
          offset: Offset(emojiShift, 0),
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 24),
              child: GestureDetector(
                onLongPress: onEmojiLongPress, // <- Easter Egg
                behavior: HitTestBehavior.opaque,
                child: Text(
                  data.emoji,
                  style: const TextStyle(fontSize: 64),
                ),
              ),
            ),
          ),
        ),

        // Titel + Text
        Transform.translate(
          offset: Offset(fgShift, 0),
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 112, left: 12, right: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    data.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    data.text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.35,
                      color: Colors.black.withValues(alpha: .75),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SlideData {
  const _SlideData({required this.emoji, required this.title, required this.text});
  final String emoji;
  final String title;
  final String text;
}
