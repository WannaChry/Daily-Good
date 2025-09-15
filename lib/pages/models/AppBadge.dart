import 'package:flutter/material.dart';

class AppBadge {
  final String title;
  final String description;
  final IconData icon;
  final BadgeRarity rarity;
  final bool unlocked;
  final BadgeProgress? progress;

  const AppBadge({
    required this.title,
    required this.description,
    required this.icon,
    required this.rarity,
    required this.unlocked,
    this.progress,
  });
}

class BadgeProgress {
  final int current;
  final int target;
  const BadgeProgress(this.current, this.target);
}

enum BadgeRarity { common, rare, epic, legendary }
