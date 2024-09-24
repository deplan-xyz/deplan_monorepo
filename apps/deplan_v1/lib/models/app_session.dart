import 'dart:convert';

class AppSession {
  String? wallet;
  String? startedAt;
  String? stoppedAt;

  AppSession({
    this.wallet,
    this.startedAt,
    this.stoppedAt,
  });

  AppSession.fromJson(String json) {
    final decoded = const JsonDecoder().convert(json);
    wallet = decoded['wallet'];
    startedAt = decoded['startedAt'];
    stoppedAt = decoded['stoppedAt'];
  }

  toMap() {
    return {
      'wallet': wallet,
      'startedAt': startedAt,
      'stoppedAt': stoppedAt,
    };
  }

  toJson() {
    return const JsonEncoder().convert(toMap());
  }
}
