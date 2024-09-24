class User {
  final String wallet;

  User({required this.wallet});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      wallet: json['wallet'],
    );
  }
}

class UserResponse {
  final User user;

  UserResponse({required this.user});

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      user: User.fromJson(json['user']),
    );
  }
}
