import 'dart:typed_data';
import 'package:flutter/material.dart';

class ProfileAvatarGlow extends StatelessWidget {
  final Uint8List? bytes;
  final String initials;
  final VoidCallback onTap;

  const ProfileAvatarGlow({
    super.key,
    required this.bytes,
    required this.initials,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 84, height: 84,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 36,
                spreadRadius: 8,
              ),
            ],
          ),
        ),
        Positioned.fill(
          child: GestureDetector(
            onTap: onTap,
            child: CircleAvatar(
              radius: 42,
              backgroundColor: Colors.white,
              backgroundImage: bytes != null ? MemoryImage(bytes!) : null,
              child: bytes == null
                  ? Text(
                initials,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              )
                  : null,
            ),
          ),
        ),
        Positioned(
          right: -2, bottom: -2,
          child: Material(
            color: Colors.white,
            shape: const CircleBorder(),
            elevation: 2,
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(Icons.edit, size: 16, color: Colors.black), // ← schwarz
              ),
            ),
          ),
        ),
      ],
    );
  }
}
