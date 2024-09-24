class TxnHistoryItem {
  String? image;
  String? title;
  String? title2;
  String? subtitle;
  String? subtitle2;
  String? hash;
  int? processedAt;

  TxnHistoryItem.fromJson(Map<String, dynamic> json) {
    image = json['image'];
    title = json['title'];
    title2 = json['title2'];
    subtitle = json['subtitle'];
    subtitle2 = json['subtitle2'];
    hash = json['hash'];
    processedAt = json['processedAt'];
  }
}
