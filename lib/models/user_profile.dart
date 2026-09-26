import 'dart:convert';

class UserProfile {
  final String uid;
  final String displayName;
  final String? email;
  final String? photoUrl;
  final bool isGuest;
  final int eloRating;
  final int totalMultiplayerWins;
  final int totalMultiplayerRaces;
  final int trophies;
  final DateTime createdAt;
  final DateTime lastActive;

  const UserProfile({
    required this.uid,
    required this.displayName,
    this.email,
    this.photoUrl,
    this.isGuest = false,
    this.eloRating = 1200,
    this.totalMultiplayerWins = 0,
    this.totalMultiplayerRaces = 0,
    this.trophies = 0,
    required this.createdAt,
    required this.lastActive,
  });

  factory UserProfile.guest({String? customId}) {
    final now = DateTime.now();
    final id = customId ?? 'guest_${now.millisecondsSinceEpoch.toRadixString(16)}';
    return UserProfile(
      uid: id,
      displayName: 'Racer_${id.substring(id.length - 4).toUpperCase()}',
      isGuest: true,
      eloRating: 1000,
      totalMultiplayerWins: 0,
      totalMultiplayerRaces: 0,
      trophies: 0,
      createdAt: now,
      lastActive: now,
    );
  }

  double get winRate => totalMultiplayerRaces > 0
      ? (totalMultiplayerWins / totalMultiplayerRaces) * 100
      : 0.0;

  UserProfile copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? photoUrl,
    bool? isGuest,
    int? eloRating,
    int? totalMultiplayerWins,
    int? totalMultiplayerRaces,
    int? trophies,
    DateTime? createdAt,
    DateTime? lastActive,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      isGuest: isGuest ?? this.isGuest,
      eloRating: eloRating ?? this.eloRating,
      totalMultiplayerWins: totalMultiplayerWins ?? this.totalMultiplayerWins,
      totalMultiplayerRaces: totalMultiplayerRaces ?? this.totalMultiplayerRaces,
      trophies: trophies ?? this.trophies,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'isGuest': isGuest,
      'eloRating': eloRating,
      'totalMultiplayerWins': totalMultiplayerWins,
      'totalMultiplayerRaces': totalMultiplayerRaces,
      'trophies': trophies,
      'createdAt': createdAt.toIso8601String(),
      'lastActive': lastActive.toIso8601String(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] as String? ?? 'unknown',
      displayName: map['displayName'] as String? ?? 'SpeedRacer',
      email: map['email'] as String?,
      photoUrl: map['photoUrl'] as String?,
      isGuest: map['isGuest'] as bool? ?? false,
      eloRating: (map['eloRating'] as num?)?.toInt() ?? 1200,
      totalMultiplayerWins: (map['totalMultiplayerWins'] as num?)?.toInt() ?? 0,
      totalMultiplayerRaces: (map['totalMultiplayerRaces'] as num?)?.toInt() ?? 0,
      trophies: (map['trophies'] as num?)?.toInt() ?? 0,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      lastActive: map['lastActive'] != null
          ? DateTime.tryParse(map['lastActive'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserProfile.fromJson(String source) =>
      UserProfile.fromMap(json.decode(source) as Map<String, dynamic>);
}
