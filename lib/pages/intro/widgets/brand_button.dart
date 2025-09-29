import 'package:flutter/material.dart';

class BrandButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool loading;
  final String label;

  final Color? backgroundColor;
  final Color? foregroundColor;
  final TextStyle? textStyle;
  final BorderSide? borderSide;
  final double height;

  const BrandButton({
    super.key,
    this.onPressed,
    this.loading = false,
    required this.label,
    this.backgroundColor,
    this.foregroundColor,
    this.textStyle,
    this.borderSide,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = backgroundColor ?? theme.colorScheme.primary;
    final fg = foregroundColor ?? theme.colorScheme.onPrimary;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          side: borderSide,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: loading
              ? SizedBox(
            key: const ValueKey('spinner'),
            width: 22, height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.6, color: fg),
          )
              : Text(
            label,
            key: const ValueKey('label'),
            style: textStyle ?? const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
