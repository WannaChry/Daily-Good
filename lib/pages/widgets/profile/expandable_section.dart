import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExpandableSection extends StatefulWidget {
  const ExpandableSection({super.key, required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  State<ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<ExpandableSection> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => setState(() => _open = !_open),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Text(
                widget.title,
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          AnimatedCrossFade(
            crossFadeState: _open ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 200),
            firstChild: Column(
              children: [
                const Divider(height: 1),
                ...widget.children
                    .expand<Widget>((w) => [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: w,
                  ),
                  const Divider(height: 1),
                ])
                    .toList()
                  ..removeLast(),
              ],
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
