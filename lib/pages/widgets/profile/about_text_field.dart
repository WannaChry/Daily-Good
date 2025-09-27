import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutTextField extends StatelessWidget {
  const AboutTextField({
    super.key,
    required this.controller,
    required this.maxLength,
  });

  final TextEditingController controller;
  final int maxLength;

  @override
  Widget build(BuildContext context) {
    final currentLen = controller.text.characters.length;
    final nearLimit = currentLen > (maxLength * 0.8);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
        minLines: 1,
        maxLines: null, // <-- Autowachsen
        maxLength: maxLength,
        decoration: InputDecoration(
          border: InputBorder.none,
          counterText: '$currentLen / $maxLength',
          counterStyle: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: nearLimit ? Colors.red.shade400 : Colors.grey.shade600,
          ),
          hintText:
          'Erzähl etwas über dich: Was motiviert dich? Deine Hobbys? Lieblings-Challenges?',
          hintStyle: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey.shade600,
            height: 1.3,
          ),
          isDense: true,
        ),
        style: GoogleFonts.poppins(
          fontSize: 14,
          height: 1.3,
        ),
      ),
    );
  }
}
