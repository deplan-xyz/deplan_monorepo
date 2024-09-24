class Organization {
  final String id;
  final String username;
  final String name;
  final String description;
  final String link;
  final String logo;
  final OrganizationSettings settings;

  Organization({
    required this.id,
    required this.username,
    required this.name,
    required this.description,
    required this.link,
    required this.logo,
    required this.settings,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['_id'],
      username: json['username'],
      name: json['name'],
      description: json['description'],
      link: json['link'],
      logo: json['logo'],
      settings: OrganizationSettings.fromJson(json['settings']),
    );
  }
}

class OrganizationSettings {
  final int treasury;
  final bool isContent;
  final bool isApp;
  final double pricePerMonth;

  OrganizationSettings({
    required this.treasury,
    required this.isContent,
    required this.isApp,
    required this.pricePerMonth,
  });

  factory OrganizationSettings.fromJson(Map<String, dynamic> json) {
    return OrganizationSettings(
      treasury: json['treasury'],
      isContent: json['isContent'],
      isApp: json['isApp'],
      pricePerMonth: json['pricePerMonth'],
    );
  }
}
