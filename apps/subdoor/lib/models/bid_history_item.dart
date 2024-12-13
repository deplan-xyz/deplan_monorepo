class BidHistoryItem {
  final BidUser user;
  final double bidAmount;
  final DateTime createdAt;

  BidHistoryItem({
    required this.user,
    required this.bidAmount,
    required this.createdAt,
  });

  factory BidHistoryItem.fromJson(Map<String, dynamic> json) {
    return BidHistoryItem(
      user: BidUser.fromJson(json['user']),
      bidAmount: json['bidAmount'].toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'bidAmount': bidAmount,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class BidUser {
  final String id;
  final String username;

  BidUser({
    required this.id,
    required this.username,
  });

  factory BidUser.fromJson(Map<String, dynamic> json) {
    return BidUser(
      id: json['_id'],
      username: json['username'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
    };
  }
}
