import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LevelProgressCard extends StatefulWidget {
  final int totalPoints;
  final int level;
  final double progress;

  const LevelProgressCard({
    super.key,
    required this.totalPoints,
    required this.level,
    required this.progress,
  });

  @override
  State<LevelProgressCard> createState() => _LevelProgressCardState();
}

class _LevelProgressCardState extends State<LevelProgressCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _progressAnimation = Tween<double>(begin: 0, end: widget.progress)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  int _getNextLevelPoints(int points) {
    const levelThresholds = [0, 5, 25, 50, 100, 200];
    for (final threshold in levelThresholds) {
      if (points < threshold) return threshold;
    }
    return levelThresholds.last;
  }

  @override
  void didUpdateWidget(covariant LevelProgressCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _progressAnimation = Tween<double>(begin: _progressAnimation.value, end: widget.progress)
          .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nextLevelPoints = _getNextLevelPoints(widget.totalPoints);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 10, offset: Offset(0, 6))],
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
                  animation: _progressAnimation,
                  builder: (context, child) => CircularProgressIndicator(
                    value: _progressAnimation.value,
                    strokeWidth: 10,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade400),
                  ),
                ),
                Center(child: Icon(Icons.eco, size: 32, color: Colors.green.shade700)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Level ${widget.level}',
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
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
