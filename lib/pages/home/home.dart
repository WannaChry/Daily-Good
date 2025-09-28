// Flutter & Dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Fonts
import 'package:google_fonts/google_fonts.dart';

// Widgets / UI-Komponenten
import 'package:studyproject/pages/ButtonsReaktion.dart';
import 'package:studyproject/pages/bottom_nav_only.dart';
import 'package:studyproject/pages/home/tasks/progress_card.dart';

// Pages
import 'package:studyproject/pages/second_page/activity_page.dart';
import 'package:studyproject/pages/profil/community_page.dart';
import 'package:studyproject/pages/profil/profile_page.dart';
import 'package:studyproject/pages/profil/options.dart';
import 'package:studyproject/pages/home/tasks/eco_facts.dart';
import 'package:studyproject/pages/home/mood/mood_dialog.dart';
import 'package:studyproject/pages/home/tasks/goals_page.dart';

// Models
import 'package:studyproject/pages/models/tipp.dart';
import 'package:studyproject/pages/models/task.dart';
import 'package:studyproject/pages/models/AppBadge.dart';
import '../models/user.dart';

// States
import 'package:studyproject/pages/state/social_state.dart';
import '../state/auth_state.dart';


class HomePage extends StatefulWidget {
  final List<Tipp> tips;
  final List<Task> tasks;
  final AuthState authState;
  final SocialState socialState;


  const HomePage({
    super.key,
    required this.tips,
    required this.tasks,
    required this.authState,
    required this.socialState,
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
    _loadUserData(); //optional
  }

  Future<void> _loadUserData() async {
    final user = widget.authState.user;
    final userData = widget.authState.currentUserData; // Firestore User-Daten

    if (user != null) {
      // Hier könntest du zusätzliche Firestore-Daten laden, falls nötig
      print("Angemeldeter User: ${user.email}");
      print("UID: ${user.uid}");
      print("Email: ${user.email}");
      print("DisplayName: ${user.displayName}");
    }
    if (userData != null) {
      print("=== Firestore User-Daten ===");
      print("Name: ${userData.username}");
      print("Email: ${userData.email}");
      print("Level: ${userData.level}");
      //print("TotalPoints: ${userData.totalPoints}");
      print("Streak: ${userData.streak}");
    } else {
      print("Firestore-Daten sind noch nicht geladen.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = widget.authState.user;

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
              MaterialPageRoute(builder: (_) => SignInPage(authState: widget.authState)),
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
            tasks: widget.tasks,),
          CommunityPage(socialState: widget.socialState), // Tab 2
          ProfilePage(totalPoints: _totalPoints,
            authState: widget.authState,
            socialState: widget.socialState,),   // Tab 4
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

  String rarityText(BadgeRarity r) {
    switch (r) {
      case BadgeRarity.common:
        return 'Gewöhnlich';
      case BadgeRarity.rare:
        return 'Selten';
      case BadgeRarity.epic:
        return 'Episch';
      case BadgeRarity.legendary:
        return 'Legendär';
    }
  }


