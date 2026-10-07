class UserModel {
  final String userId;
  final String displayName;
  final String email;
  final bool ageVerified;
  final DateTime createdAt;
  final int xp;
  final int coins;
  final int level;
  final String rank;
  final int streak;
  final DateTime lastLogin;
  final String avatarId;
  final bool isGuest;

  const UserModel({
    required this.userId,
    required this.displayName,
    required this.email,
    required this.ageVerified,
    required this.createdAt,
    this.xp = 0,
    this.coins = 100,
    this.level = 1,
    this.rank = 'BEGINNER',
    this.streak = 1,
    required this.lastLogin,
    this.avatarId = 'avatar_1',
    this.isGuest = false,
  });

  UserModel copyWith({
    String? userId,
    String? displayName,
    String? email,
    bool? ageVerified,
    DateTime? createdAt,
    int? xp,
    int? coins,
    int? level,
    String? rank,
    int? streak,
    DateTime? lastLogin,
    String? avatarId,
    bool? isGuest,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      ageVerified: ageVerified ?? this.ageVerified,
      createdAt: createdAt ?? this.createdAt,
      xp: xp ?? this.xp,
      coins: coins ?? this.coins,
      level: level ?? this.level,
      rank: rank ?? this.rank,
      streak: streak ?? this.streak,
      lastLogin: lastLogin ?? this.lastLogin,
      avatarId: avatarId ?? this.avatarId,
      isGuest: isGuest ?? this.isGuest,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'displayName': displayName,
      'email': email,
      'ageVerified': ageVerified,
      'createdAt': createdAt.toIso8601String(),
      'xp': xp,
      'coins': coins,
      'level': level,
      'rank': rank,
      'streak': streak,
      'lastLogin': lastLogin.toIso8601String(),
      'avatarId': avatarId,
      'isGuest': isGuest,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] as String? ?? 'user_${DateTime.now().millisecondsSinceEpoch}',
      displayName: json['displayName'] as String? ?? 'Trader',
      email: json['email'] as String? ?? '',
      ageVerified: json['ageVerified'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      xp: json['xp'] as int? ?? 0,
      coins: json['coins'] as int? ?? 100,
      level: json['level'] as int? ?? 1,
      rank: json['rank'] as String? ?? 'BEGINNER',
      streak: json['streak'] as int? ?? 1,
      lastLogin: json['lastLogin'] != null
          ? DateTime.tryParse(json['lastLogin'] as String) ?? DateTime.now()
          : DateTime.now(),
      avatarId: json['avatarId'] as String? ?? 'avatar_1',
      isGuest: json['isGuest'] as bool? ?? false,
    );
  }

  static UserModel createDefault({String name = 'Young Investor', String email = 'investor@marketminds.app', bool isGuest = true}) {
    final now = DateTime.now();
    return UserModel(
      userId: 'user_${now.millisecondsSinceEpoch}',
      displayName: name,
      email: email,
      ageVerified: true,
      createdAt: now,
      xp: 150,
      coins: 250,
      level: 1,
      rank: 'BEGINNER',
      streak: 3,
      lastLogin: now,
      avatarId: 'avatar_1',
      isGuest: isGuest,
    );
  }
}
