int getLevel(int points) {
  const levelThresholds = [0, 5, 10, 25, 100, 200]; // Punkte für Level 1,2,3...

  int level = 1;
  for (int i = 0; i < levelThresholds.length; i++) {
    if (points >= levelThresholds[i]) {
      level = i + 1;
    } else {
      break;
    }
  }
  return level;
}

double getLevelProgress(int points) {
  const levelThresholds = [0, 5, 25, 50, 100, 200];

  int currentLevel = getLevel(points);
  int prevThreshold = levelThresholds[currentLevel - 1];
  int nextThreshold = currentLevel < levelThresholds.length
      ? levelThresholds[currentLevel]
      : prevThreshold; // Max Level bleibt 100%

  if (nextThreshold == prevThreshold) return 1.0;

  return ((points - prevThreshold) / (nextThreshold - prevThreshold)).clamp(0.0, 1.0);
}
