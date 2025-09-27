class LevelCalc {
  final int totalPoints;

  LevelCalc(this.totalPoints);

  // Punkte-Schwellen für die Level
  static const List<int> levelThresholds = [
    0,    // Level 1
    10,   // Level 2
    40,   // Level 3
    100,  // Level 4
    200,  // Level 5
    350,  // Level 6
    550,  // Level 7
    800,  // Level 8
    1100, // Level 9
    1450, // Level 10
    1850, // Level 11
    2300, // Level 12
    2800, // Level 13
    3350, // Level 14
    3950, // Level 15
    4600, // Level 16
    5300, // Level 17
    6050, // Level 18
    6850, // Level 19
    7700, // Level 20
  ];

  // Gesamtanzahl der Level
  static int get maxLevel => levelThresholds.length;

  int get level {
    for (int i = levelThresholds.length - 1; i >= 0; i--) {
      if (totalPoints >= levelThresholds[i]) return i + 1;
    }
    return 1;
  }

  int get pointsInCurrentLevel {
    final lvlIndex = level - 1;
    return totalPoints - levelThresholds[lvlIndex];
  }

  int get pointsToNextLevel {
    final lvlIndex = level - 1;
    if (level >= maxLevel) return 0;
    return levelThresholds[lvlIndex + 1] - totalPoints;
  }

  double get progressInLevel {
    final lvlIndex = level - 1;
    if (level >= maxLevel) return 1.0;
    final currentLevelPoints = totalPoints - levelThresholds[lvlIndex];
    final nextLevelPoints = levelThresholds[lvlIndex + 1] - levelThresholds[lvlIndex];
    return (currentLevelPoints / nextLevelPoints).clamp(0.0, 1.0);
  }

  // Baum-Stufe: 0..5 (kannst du anpassen)
  int get treeStage {
    return (progressInLevel * 5).floor().clamp(0, 5);
  }

  String get treeEmoji {
    switch (treeStage) {
      case 0: return '🌱';
      case 1: return '🌿';
      case 2: return '🌿';
      case 3: return '🌳';
      case 4: return '🌳';
      case 5: return '🌳🌟';
      default: return '🌱';
    }
  }
}
