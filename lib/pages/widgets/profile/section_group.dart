import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SectionGroup extends StatelessWidget {
  const SectionGroup({super.key, required this.header, required this.items});
  final String header;
  final List<GroupItem> items;

  @override
  Widget build(BuildContext context) {
    final headerStyle = GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(header, style: headerStyle),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ],
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: List.generate(items.length, (i) {
              final item = items[i];
              final isLast = i == items.length - 1;
              return Column(
                children: [
                  GroupRow(label: item.label, onTap: item.onTap),
                  if (!isLast) const Divider(height: 1, thickness: 1),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class GroupItem {
  const GroupItem({required this.label, this.onTap});
  final String label;
  final VoidCallback? onTap;
}

class GroupRow extends StatelessWidget {
  const GroupRow({super.key, required this.label, this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
              Text('›', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}
