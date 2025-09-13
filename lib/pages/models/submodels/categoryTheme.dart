import 'package:flutter/material.dart';
import 'package:studyproject/pages/models/task_category.dart';

class CategoryTheme {
  final Color color;
  final Color border;
  final IconData icon;

  const CategoryTheme({required this.color, required this.border, required this.icon});

  static final Map<Task_category, CategoryTheme> themes = {
    Task_category.Sozial : CategoryTheme(color: Color(0xFFE8F4FF), border: Color(0xFFB3DAFF), icon: Icons.group_rounded),
    Task_category.Nachhaltigkeit: CategoryTheme(color: Color(0xFFEFF7EA), border: Color(0xFFB8E2B0), icon: Icons.eco_rounded),
    Task_category.Gesundheit: CategoryTheme(color: Color(0xFFFFF3E0), border: Color(0xFFFFD59B), icon: Icons.fitness_center_rounded),
    Task_category.Achtsamkeit: CategoryTheme(color: Color(0xFFF4ECFF), border: Color(0xFFD7C7FF), icon: Icons.self_improvement_rounded),
    Task_category.Produktivitaet: CategoryTheme(color: Color(0xFFFFEEF0), border: Color(0xFFF8B8C1), icon: Icons.task_alt_rounded),
    Task_category.Lernen: CategoryTheme(color: Color(0xFFEFF3FF), border: Color(0xFFBECDFE), icon: Icons.menu_book_rounded),
  };
}
