import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:studyproject/pages/models/task.dart';
import 'package:studyproject/pages/models/task_category.dart';
import 'package:studyproject/pages/second_page/subpages/task_row.dart';
import 'package:studyproject/pages/models/submodels/categoryTheme.dart';

class CategorySection extends StatelessWidget {
  const CategorySection({
    required this.name,
    required this.tasks,
    required this.onToggle,
    required this.theme,
    super.key,
  });

  final String name;
  final List<Task> tasks;
  final void Function(Task) onToggle;
  final CategoryTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 12),
          childrenPadding: const EdgeInsets.only(left: 12, right: 12, bottom: 12, top: 0),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          leading: Icon(theme.icon, size: 26),
          title: Text(
            name,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          children: tasks.isEmpty
              ? [Padding(
            padding: const EdgeInsets.all(8),
            child: Text('Keine erledigten Tasks', style: TextStyle(color: Colors.grey)),
          )]
              : tasks.map((t) => TaskRow(task: t, onToggle: onToggle)).toList(),


        ),
      ),
    );
  }
}
