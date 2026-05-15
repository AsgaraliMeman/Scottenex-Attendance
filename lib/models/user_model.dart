class UserModel {
  final String uid;
  final String email;
  final String role; // 'admin' or 'employee'
  final String name;
  final String? employeeId;
  final String? designation;
  final bool isFirstLogin;
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.role,
    required this.name,
    this.employeeId,
    this.designation,
    required this.isFirstLogin,
    this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      role: data['role'] ?? 'employee',
      name: data['name'] ?? '',
      employeeId: data['employeeId'] as String?,
      designation: data['designation'] as String?,
      isFirstLogin: data['isFirstLogin'] ?? true,
      createdAt: data['createdAt']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'role': role,
      'name': name,
      'employeeId': employeeId,
      'designation': designation,
      'isFirstLogin': isFirstLogin,
      'createdAt': createdAt ?? DateTime.now(),
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? role,
    String? name,
    String? employeeId,
    String? designation,
    bool? isFirstLogin,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      role: role ?? this.role,
      name: name ?? this.name,
      employeeId: employeeId ?? this.employeeId,
      designation: designation ?? this.designation,
      isFirstLogin: isFirstLogin ?? this.isFirstLogin,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
