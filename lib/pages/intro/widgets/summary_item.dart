import 'package:flutter/material.dart';

class SummaryItem extends StatelessWidget {
  final IconData leading;
  final String label;
  final String value;
  final Color iconColor;

  const SummaryItem({
    super.key,
    required this.leading,
    required this.label,
    required this.value,
    this.iconColor = const Color(0xFF111111),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final border = BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.35));

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.fromBorderSide(border),
      ),
      child: Row(
        children: [
          Icon(leading, size: 20, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              value.isEmpty ? '—' : value,
              textAlign: TextAlign.right,
              style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.80)),
            ),
          ),
        ],
      ),
    );
  }
}
