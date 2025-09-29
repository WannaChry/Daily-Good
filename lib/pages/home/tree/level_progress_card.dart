import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LevelProgressCard extends StatefulWidget {
  final int totalPoints;

  const LevelProgressCard({
    super.key,
    required this.totalPoints,
  });

  @override
  State<LevelProgressCard> createState() => _LevelProgressCardState();
}

class _LevelProgressCardState extends State<LevelProgressCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  late Animation<Color?> _colorAnimation;

  final List<int> _levelThresholds = [0, 5, 25, 50, 100, 200];

  int _getLevel(int points) {
    int level = 1;
    for (int i = 0; i < _levelThresholds.length; i++) {
      if (points >= _levelThresholds[i]) {
        level = i + 1;
      }
    }
    return level;
  }

  int _getNextLevelPoints(int points) {
    for (final threshold in _levelThresholds) {
      if (points < threshold) return threshold;
    }
    return _levelThresholds.last;
  }

  double _getProgress(int points) {
    int currentLevel = _getLevel(points);
    int prevThreshold = _levelThresholds[currentLevel - 1];
    int nextThreshold = _getNextLevelPoints(points);

    int gained = points - prevThreshold;
    int needed = nextThreshold - prevThreshold;

    return needed == 0 ? 1.0 : gained / needed;
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _progressAnimation = Tween<double>(
      begin: 0,
      end: _getProgress(widget.totalPoints),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _colorAnimation = ColorTween(
      begin: Colors.green.shade300,
      end: Colors.green.shade600,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant LevelProgressCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    final newProgress = _getProgress(widget.totalPoints);

    _progressAnimation = Tween<double>(
      begin: _progressAnimation.value,
      end: newProgress,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _colorAnimation = ColorTween(
      begin: Colors.green.shade300,
      end: Colors.green.shade600,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller
      ..reset()
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final level = _getLevel(widget.totalPoints);
    final nextLevelPoints = _getNextLevelPoints(widget.totalPoints);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 10, offset: Offset(0, 6))
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 84,
            height: 84,
            child: Stack(
              fit: StackFit.expand,
              children: [
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) => CircularProgressIndicator(
                    value: _progressAnimation.value,
                    strokeWidth: 10,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _colorAnimation.value ?? Colors.green,
                    ),
                  ),
                ),
                Center(
                  child: Icon(Icons.eco, size: 32, color: Colors.green.shade700),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Level $level',
                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.totalPoints} / $nextLevelPoints Punkte',
                  style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Text(
                  'Fortschritt zum nächsten Level',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
