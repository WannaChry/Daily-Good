import 'package:flutter/material.dart';

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
    final avatar = CircleAvatar(
      radius: radius,
      backgroundImage: (photoUrl != null && photoUrl!.isNotEmpty)
          ? NetworkImage(photoUrl!)
          : null,
      child: (photoUrl == null || photoUrl!.isEmpty)
          ? Text(
        initials,
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 22),
      )
          : null,
    );

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        GestureDetector(onTap: onTap, child: avatar),
        if (uploading)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(.35),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                ),
              ),
            ),
          )
        else
          Container(
            decoration: const BoxDecoration(
              color: Colors.white, shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
            ),
            padding: const EdgeInsets.all(6),
            child: const Icon(Icons.edit, size: 16),
          ),
      ],
    );
  }
}
