class User {
  final String id;
  final String username;
  final String wallet;

  User({
    required this.id,
    required this.username,
    required this.wallet,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      username: json['username'],
      wallet: json['wallet'],
    );
  }
}
