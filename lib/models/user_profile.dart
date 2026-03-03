class UserProfile {
  final String uid;
  final String username;
  final String email;
  final String role; // 'patient' | 'provider'
  final String gender;
  final DateTime dateOfBirth;
  final double height; // in cm
  final double weight; // in kg
  final double? targetWeight; // in kg
  final List<String> healthConditions;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  // Provider-only
  final String? specialty;
  final List<String> assignedPatientIds;
  // Patient-only
  final String? assignedProviderId;

  UserProfile({
    required this.uid,
    required this.username,
    required this.email,
    this.role = 'patient',
    required this.gender,
    required this.dateOfBirth,
    required this.height,
    required this.weight,
    this.targetWeight,
    required this.healthConditions,
    this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
    this.specialty,
    this.assignedPatientIds = const [],
    this.assignedProviderId,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'role': role,
      'gender': gender,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'height': height,
      'weight': weight,
      'targetWeight': targetWeight,
      'healthConditions': healthConditions,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isProfileComplete': true,
      if (specialty != null) 'specialty': specialty,
      'assignedPatientIds': assignedPatientIds,
      if (assignedProviderId != null) 'assignedProviderId': assignedProviderId,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map, String uid) {
    return UserProfile(
      uid: uid,
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'patient',
      gender: map['gender'] ?? 'Not specified',
      dateOfBirth: map['dateOfBirth'] != null ? DateTime.parse(map['dateOfBirth']) : DateTime.now(),
      height: (map['height'] ?? 0).toDouble(),
      weight: (map['weight'] ?? 0).toDouble(),
      targetWeight: map['targetWeight']?.toDouble(),
      healthConditions: List<String>.from(map['healthConditions'] ?? []),
      avatarUrl: map['avatarUrl'],
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : DateTime.now(),
      specialty: map['specialty'],
      assignedPatientIds: List<String>.from(map['assignedPatientIds'] ?? []),
      assignedProviderId: map['assignedProviderId'],
    );
  }
}
