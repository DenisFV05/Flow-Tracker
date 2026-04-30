class User {
  final String id;
  final String name;
  final String email;
  final String? username;
  final String? avatar;
  final String? createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.username,
    this.avatar,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      username: json['username'],
      avatar: json['avatar'],
      createdAt: json['createdAt'],
    );
  }
}
