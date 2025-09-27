import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditableAvatar extends StatelessWidget {
  const EditableAvatar({
    super.key,
    required this.radius,
    required this.initials,
    this.photoUrl,
    this.uploading = false,
    this.onTap,
  });

  final double radius;
  final String initials;
  final String? photoUrl;
  final bool uploading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoUrl != null && photoUrl!.isNotEmpty;

    Widget avatarCore = CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey.shade300,
      backgroundImage: hasPhoto ? NetworkImage(photoUrl!) : null,
      child: hasPhoto
          ? null
          : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.add_a_photo_outlined, size: 24, color: Colors.black87),
          const SizedBox(height: 4),
          Text(
            'Profilbild\nhinzufügen',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.15,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );

    // Tip-Zone zum Antippen
    avatarCore = InkWell(
      customBorder: const CircleBorder(),
      onTap: uploading ? null : onTap,
      child: avatarCore,
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatarCore,

        Positioned(
          right: -2,
          bottom: -2,
          child: Material(
            color: Colors.black,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: uploading ? null : onTap,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: uploading
                    ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
                    : const Icon(Icons.edit, color: Colors.white, size: 18),
              ),
            ),
          ),
        ),

        // Ladeoverlay mittig
        if (uploading)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.25),
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}
