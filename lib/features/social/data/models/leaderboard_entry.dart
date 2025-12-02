class LeaderboardEntry {
  final String userId;
  final String username;
  final String avatarUrl; // Optional, can use Initials
  final double weeklyHours;
  final int streak;
  final int rank;
  final int score;

  LeaderboardEntry({
    required this.userId,
    required this.username,
    this.avatarUrl = '',
    required this.weeklyHours,
    required this.streak,
    required this.rank,
    this.score = 0,
  });
}
