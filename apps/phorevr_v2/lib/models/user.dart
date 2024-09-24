import 'dart:typed_data';

class User {
  String? username = '';
  String? avatarCid;
  String? id;
  String? wallet;
  Uint8List? avatarToSet;
  String? createdAt;
  String? password;

  User({
    this.username = '',
    this.avatarCid,
    this.avatarToSet,
    this.id,
    this.wallet,
    this.createdAt,
  });

  User.fromJson(Map<String, dynamic> json) {
    username = json['username'];
    avatarCid = json['avatarCid'];
    wallet = json['wallet'];
    id = json['_id'];
    createdAt = json['createdAt'];
  }
}
