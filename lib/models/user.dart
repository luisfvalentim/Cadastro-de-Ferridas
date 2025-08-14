class AppUser {
  final int id;
  final String username;
  final String name;
  final String role;
  final String? token; // ← agora opcional
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isUserActive;

  AppUser({
    required this.id,
    required this.username,
    required this.name,
    required this.role,
    this.token, // ← também aqui
    required this.isUserActive,
    this.createdAt,
    this.updatedAt,
  });

  factory AppUser.fromJson(Map<String, dynamic> json, [String? token]) {
    return AppUser(
      id: json['id'],
      username: json['username'],
      name: json['name'],
      role: json['role'] ?? 'usuario',
      token: token, // ← pode ser null
      isUserActive: true, // ajustar se tiver campo real
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
    );
  }

  bool get isAdmin => role == 'admin';
}
