class LeaderboardEntry {
  final int rank;
  final String displayName;
  final String avatarId;
  final int level;
  final int xp;
  final double portfolioReturn;
  final String badge;
  final bool isCurrentUser;

  const LeaderboardEntry({
    required this.rank,
    required this.displayName,
    required this.avatarId,
    required this.level,
    required this.xp,
    required this.portfolioReturn,
    required this.badge,
    this.isCurrentUser = false,
  });

  static List<LeaderboardEntry> getWeeklySample({required int userXp, required double userReturn}) {
    return [
      const LeaderboardEntry(
        rank: 1,
        displayName: 'Aarav Sharma',
        avatarId: 'avatar_3',
        level: 7,
        xp: 4120,
        portfolioReturn: 8.4,
        badge: 'EXPERT',
      ),
      const LeaderboardEntry(
        rank: 2,
        displayName: 'Priya Patel',
        avatarId: 'avatar_2',
        level: 6,
        xp: 3890,
        portfolioReturn: 6.2,
        badge: 'ANALYST',
      ),
      const LeaderboardEntry(
        rank: 3,
        displayName: 'Rohan Mehta',
        avatarId: 'avatar_5',
        level: 5,
        xp: 3240,
        portfolioReturn: 5.7,
        badge: 'TRADER',
      ),
      LeaderboardEntry(
        rank: 4,
        displayName: 'You (Young Investor)',
        avatarId: 'avatar_1',
        level: (userXp ~/ 300) + 1,
        xp: userXp,
        portfolioReturn: userReturn,
        badge: 'LEARNER',
        isCurrentUser: true,
      ),
      const LeaderboardEntry(
        rank: 5,
        displayName: 'Kavita Singh',
        avatarId: 'avatar_4',
        level: 4,
        xp: 2150,
        portfolioReturn: 3.8,
        badge: 'TRADER',
      ),
      const LeaderboardEntry(
        rank: 6,
        displayName: 'Dev Verma',
        avatarId: 'avatar_6',
        level: 3,
        xp: 1820,
        portfolioReturn: 2.1,
        badge: 'INVESTOR',
      ),
      const LeaderboardEntry(
        rank: 7,
        displayName: 'Ananya Rao',
        avatarId: 'avatar_7',
        level: 2,
        xp: 1450,
        portfolioReturn: 1.4,
        badge: 'BEGINNER',
      ),
    ];
  }
}
