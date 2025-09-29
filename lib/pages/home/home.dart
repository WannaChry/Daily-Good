// lib/profil/profil/home.dart
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// Achte auf snake_case-Dateinamen:
import 'package:studyproject/pages/ButtonsReaktion.dart';
import 'package:studyproject/pages/bottom_nav_only.dart';
import 'package:studyproject/pages/second_page/activity_page.dart';
import 'package:studyproject/pages/profil/community_page.dart';
import 'package:studyproject/pages/profil/profile_page.dart';
import 'package:studyproject/pages/profil/options.dart';
import 'package:studyproject/pages/home/tasks/eco_facts.dart';
import 'package:studyproject/pages/home/mood/mood_dialog.dart';
import 'package:studyproject/pages/models/tipp.dart';
import 'package:studyproject/pages/models/task.dart';
import 'package:studyproject/pages/home/tasks/goals_page.dart';

import 'package:studyproject/pages/models/AppBadge.dart';

import '../models/user.dart';

class HomePage extends StatefulWidget {
  final List<Tipp> tips;
  final List<Task> tasks;

  const HomePage({
    super.key,
    required this.tips,
    required this.tasks,
    });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  int _totalPoints = 0; // Summe aus Seite 1

  late final GoalsPage _goalsPage;

  @override
  void initState() {
    super.initState();
    _goalsPage = GoalsPage(
      onPointsChanged: (p) => setState(() => _totalPoints = p),
      tasks: widget.tasks,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F3FA),

      // ---------- AppBar ----------
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        toolbarHeight: 72,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: ReactiveSvgButton(
          asset: 'assets/icons/menu-svgrepo-com.svg',
          size: 32,
          padding: const EdgeInsets.only(left: 12, top: 8),
          color: Colors.black,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SignInPage()),
            );
          },
        ),
        title: ReactiveSvgButton(
          asset: 'assets/icons/lightbulb-bolt-svgrepo-com.svg',
          size: 40,
          padding: const EdgeInsets.only(top: 8),
          rotateOnTap: true,
          color: Colors.black,
          onTap: () => showEcoFactDialog(context, widget.tips),
        ),
        actions: [
          ReactiveSvgButton(
            asset: 'assets/icons/checkbox-unchecked-svgrepo-com.svg',
            size: 36,
            padding: const EdgeInsets.only(right: 12, top: 8),
            color: Colors.black,
            onTap: () async {
              final result = await showMoodPicker(context);
              if (!context.mounted || result == null) return;

              const labels = ['Sehr schlecht', 'Schlecht', 'Mittel', 'Gut', 'Sehr gut'];
              final mood = labels[result];

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Stimmung: $mood')),
              );
            },

          ),
        ],
      ),

      // ---------- Body ----------
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _goalsPage,                               // Tab 1
          ActivityPage(
              totalPoints: _totalPoints,
            tasks: widget.tasks,),  // Tab 2
          const CommunityPage(),                    // Tab 3
          ProfilePage(totalPoints: _totalPoints),   // Tab 4
        ],
      ),

      // ---------- Bottom Nav ----------
      bottomNavigationBar: NavBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class ProgressCard extends StatelessWidget {
  const ProgressCard({super.key, required this.current, required this.target});
  final int current;
  final int target;

  @override
  Widget build(BuildContext context) {
    final clamped = current > target ? target : current;
    final progress = target == 0 ? 0.0 : (clamped / target).clamp(0.0, 1.0);

    const barH = 22.0;
    const knobR = 8.0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.lightGreen.withOpacity(0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.bolt_rounded, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Erfülle Ziele um Punkte zu sammeln und lasse deine Pflanze wachsen',
                  style: GoogleFonts.poppins(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, c) {
              final w = c.maxWidth;

              return TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: progress),
                duration: const Duration(milliseconds: 650),
                curve: Curves.easeInOutCubic,
                builder: (context, value, _) {
                  final knobX = (w - 2 * knobR) * value;

                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: Container(height: barH, color: Colors.white),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            height: barH,
                            width: w * value,
                            color: Colors.green.shade400,
                          ),
                        ),
                      ),
                      Positioned(
                        left: knobX,
                        top: (barH - 2 * knobR) / 2,
                        child: AnimatedScale(
                          scale: 1.0,
                          duration: const Duration(milliseconds: 180),
                          child: Container(
                            width: 2 * knobR,
                            height: 2 * knobR,
                            decoration: BoxDecoration(
                              color: Colors.lightGreen.shade400,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
                            transitionBuilder: (child, a) =>
                                ScaleTransition(scale: a, child: child),
                            child: Text(
                              '$clamped / $target',
                              key: ValueKey(clamped),
                              style: GoogleFonts.poppins(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.black.withOpacity(0.85),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
