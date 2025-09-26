({int level, int current, int needed}) levelFromPoints(int points) {
  int level = 1;
  int needed = 80;
  int remaining = points;
  while (remaining >= needed) {
    remaining -= needed;
    level += 1;
    needed += 20;
  }
  return (level: level, current: remaining, needed: needed);
}
