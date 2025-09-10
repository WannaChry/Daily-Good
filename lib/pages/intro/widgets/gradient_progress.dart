import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Smoother Gradient-Progressbar mit nahtlosem Shine.
/// - Füllt weich von *aktuell sichtbarem* Wert zu [progress] (0..1)
/// - Shine-Tempo via [shinePeriod] einstellbar (langsamer = größere Duration)
class GradientProgressBar extends StatefulWidget {
  const GradientProgressBar({
    super.key,
    required this.progress, // 0..1
    this.height = 22,
    this.backgroundColor,
    this.gradientColors = const [
      Color(0xFFB5E48C),
      Color(0xFF52B788),
      Color(0xFF2D6A4F),
    ],
    this.animationDuration = const Duration(milliseconds: 520),
    this.curve = Curves.easeOutCubic,
    this.shinePeriod = const Duration(seconds: 6), // <- langsameres Standardtempo
  });

  final double progress;
  final double height;
  final Color? backgroundColor;
  final List<Color> gradientColors;
  final Duration animationDuration;
  final Curve curve;

  /// Wie lange ein Shine-Durchlauf dauert (je größer, desto langsamer).
  final Duration shinePeriod;

  @override
  State<GradientProgressBar> createState() => _GradientProgressBarState();
}

class _GradientProgressBarState extends State<GradientProgressBar>
    with TickerProviderStateMixin {
  late AnimationController _loop;      // Shine/Gradient Loop
  late AnimationController _progressAC; // Progress Tween
  late Animation<double> _progressAnim;
  double _current = 0.0;

  @override
  void initState() {
    super.initState();

    _current = _clamp(widget.progress);

    _loop = AnimationController(
      vsync: this,
      duration: widget.shinePeriod, // <- hier genutzt
    )..repeat();

    _progressAC = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _progressAnim = AlwaysStoppedAnimation<double>(_current);
  }

  @override
  void didUpdateWidget(covariant GradientProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Shine-Tempo zur Laufzeit anpassbar
    if (oldWidget.shinePeriod != widget.shinePeriod) {
      _loop
        ..duration = widget.shinePeriod
        ..repeat();
    }

    // Progress weich von sichtbarem Wert zum Ziel tweenen
    final target = _clamp(widget.progress);
    final from = _progressAnim.value;

    if ((target - from).abs() > 0.0005) {
      _progressAC
        ..duration = widget.animationDuration
        ..reset();

      _progressAnim = Tween<double>(begin: from, end: target).animate(
        CurvedAnimation(parent: _progressAC, curve: widget.curve),
      )..addStatusListener((s) {
        if (s == AnimationStatus.completed) _current = target;
      });

      _progressAC.forward();
    }
  }

  double _clamp(double v) => v.clamp(0.0, 1.0);

  @override
  void dispose() {
    _loop.dispose();
    _progressAC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: Listenable.merge([_loop, _progressAC]),
        builder: (_, __) => CustomPaint(
          painter: _ProgressPainter(
            t: _loop.value,
            progress: _progressAnim.value,
            height: widget.height,
            backgroundColor: widget.backgroundColor ?? Colors.black12,
            colors: widget.gradientColors,
          ),
          size: Size(double.infinity, widget.height),
        ),
      ),
    );
  }
}

class _ProgressPainter extends CustomPainter {
  _ProgressPainter({
    required this.t,
    required this.progress,
    required this.height,
    required this.backgroundColor,
    required this.colors,
  });

  final double t; // 0..1 loop
  final double progress;
  final double height;
  final Color backgroundColor;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = height;

    // Track
    final trackRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, (size.height - h) / 2, w, h),
      const Radius.circular(999),
    );
    final trackPaint = Paint()..color = backgroundColor;
    canvas.drawRRect(trackRRect, trackPaint);

    // Fill
    final fillW = w * progress;
    if (fillW <= 0) return;

    final fillRect = Rect.fromLTWH(0, (size.height - h) / 2, fillW, h);
    final fillRRect =
    RRect.fromRectAndRadius(fillRect, const Radius.circular(999));

    // Sanft oszillierender Gradient (kein Reset)
    final osc = math.sin(t * 2 * math.pi) * 0.25; // -0.25..0.25
    final shader = LinearGradient(
      colors: colors,
      begin: Alignment(-1 + osc, 0),
      end: Alignment(1 + osc, 0),
    ).createShader(fillRect);

    final fillPaint = Paint()..shader = shader;
    canvas.drawRRect(fillRRect, fillPaint);

    // Shine: zwei Strahlen, phasenversetzt -> nahtlos
    final stripeW = math.max(24.0, h * 1.25);
    final total = w + stripeW * 2;
    final x1 = -stripeW + total * t;
    final x2 = -stripeW + total * ((t + 0.5) % 1.0);

    final shineShader = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Colors.white.withValues(alpha: 0.0),
        Colors.white.withValues(alpha: 0.18),
        Colors.white.withValues(alpha: 0.0),
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    final r1 = Rect.fromLTWH(x1, (size.height - h) / 2, stripeW, h);
    final r2 = Rect.fromLTWH(x2, (size.height - h) / 2, stripeW, h);

    canvas.save();
    canvas.clipRRect(fillRRect);
    canvas.drawRect(r1, Paint()..shader = shineShader.createShader(r1));
    canvas.drawRect(r2, Paint()..shader = shineShader.createShader(r2));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ProgressPainter old) =>
      old.t != t ||
          old.progress != progress ||
          old.height != height ||
          old.colors != colors ||
          old.backgroundColor != backgroundColor;
}
