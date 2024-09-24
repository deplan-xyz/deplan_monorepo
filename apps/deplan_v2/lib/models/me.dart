class _User {
  final String wallet;

  _User({required this.wallet});

  factory _User.fromJson(Map<String, dynamic> json) {
    return _User(
      wallet: json['wallet'],
    );
  }
}

class UserResponse {
  final _User user;

  UserResponse({required this.user});

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      user: _User.fromJson(json['user']),
    );
  }
}
