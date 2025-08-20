import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ReactiveSvgButton extends StatefulWidget {
  final String asset;
  final double size;
  final EdgeInsets padding;
  final VoidCallback onTap;
  final bool rotateOnTap;
  final Color? color;

  const ReactiveSvgButton({
    super.key,
    required this.asset,
    required this.size,
    required this.onTap,
    this.padding = EdgeInsets.zero,
    this.rotateOnTap = false,
    this.color,
  });

  @override
  State<ReactiveSvgButton> createState() => _ReactiveSvgButtonState();
}

class _ReactiveSvgButtonState extends State<ReactiveSvgButton> {
  bool _pressed = false;

  void _down(TapDownDetails _) => setState(() => _pressed = true);
  void _up([_]) => setState(() => _pressed = false);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: GestureDetector(
        onTapDown: _down,
        onTapUp: _up,
        onTapCancel: _up,
        onTap: widget.onTap,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 120),
          scale: _pressed ? 0.9 : 1.0,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 120),
            opacity: _pressed ? 0.75 : 1.0,
            child: AnimatedRotation(
              duration: const Duration(milliseconds: 160),
              turns: widget.rotateOnTap && _pressed ? 0.02 : 0.0,
              child: SvgPicture.asset(
                widget.asset,
                width: widget.size,
                height: widget.size,
                colorFilter: widget.color != null
                    ? ColorFilter.mode(widget.color!, BlendMode.srcIn)
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
