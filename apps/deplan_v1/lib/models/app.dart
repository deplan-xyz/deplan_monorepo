import 'dart:typed_data';

class App {
  String? id;
  String? wallet;
  String? link;
  String? logo;
  String? name;
  String? description;
  Uint8List? logoToSet;
  bool? isPerContent = false;
  AppSettings? settings;

  App();

  App.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    wallet = json['wallet'];
    link = json['link'];
    logo = json['logo'];
    name = json['name'];
    description = json['description'];
    isPerContent = json['isPerContent'];
    settings = AppSettings.fromJson(json['settings']);
  }

  toMap() {
    return {
      'wallet': wallet,
      'link': link,
      'isPerContent': isPerContent,
    };
  }
}

class AppSettings {
  double? pricePerHour;

  AppSettings.fromJson(Map<String, dynamic> json) {
    pricePerHour = double.tryParse(json['pricePerHour']);
  }
}
