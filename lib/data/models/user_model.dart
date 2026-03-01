enum UserRole { RUNNER, REQUESTER, BOTH }

class UserModel {
  final String userId;
  final String email;
  final String displayName;
  final String phoneNumber;
  final String? photoUrl;
  final String campusId;
  final String campusName;
  final UserRole role;
  final double rating;
  final int totalRatings;
  final int completedTasks;
  final DateTime joinedAt;
  final bool isVerified;
  final bool isActive;
  final String? fcmToken;

  UserModel({
    required this.userId,
    required this.email,
    required this.displayName,
    required this.phoneNumber,
    this.photoUrl,
    required this.campusId,
    required this.campusName,
    required this.role,
    this.rating = 0.0,
    this.totalRatings = 0,
    this.completedTasks = 0,
    required this.joinedAt,
    this.isVerified = false,
    this.isActive = true,
    this.fcmToken,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String docId) {
    return UserModel(
      userId: docId,
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      photoUrl: map['photoUrl'],
      campusId: map['campusId'] ?? 'unknown',
      campusName: map['campusName'] ?? 'Unknown Campus',
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => UserRole.BOTH,
      ),
      rating: (map['rating'] ?? 0.0).toDouble(),
      totalRatings: map['totalRatings'] ?? 0,
      completedTasks: map['completedTasks'] ?? 0,
      joinedAt: DateTime.fromMillisecondsSinceEpoch(
        map['joinedAt'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
      isVerified: map['isVerified'] ?? false,
      isActive: map['isActive'] ?? true,
      fcmToken: map['fcmToken'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      if (photoUrl != null) 'photoUrl': photoUrl,
      'campusId': campusId,
      'campusName': campusName,
      'role': role.name,
      'rating': rating,
      'totalRatings': totalRatings,
      'completedTasks': completedTasks,
      'joinedAt': joinedAt.millisecondsSinceEpoch,
      'isVerified': isVerified,
      'isActive': isActive,
      if (fcmToken != null) 'fcmToken': fcmToken,
    };
  }

  UserModel copyWith({
    String? userId,
    String? email,
    String? displayName,
    String? phoneNumber,
    String? photoUrl,
    String? campusId,
    String? campusName,
    UserRole? role,
    double? rating,
    int? totalRatings,
    int? completedTasks,
    DateTime? joinedAt,
    bool? isVerified,
    bool? isActive,
    String? fcmToken,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      campusId: campusId ?? this.campusId,
      campusName: campusName ?? this.campusName,
      role: role ?? this.role,
      rating: rating ?? this.rating,
      totalRatings: totalRatings ?? this.totalRatings,
      completedTasks: completedTasks ?? this.completedTasks,
      joinedAt: joinedAt ?? this.joinedAt,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }
}
