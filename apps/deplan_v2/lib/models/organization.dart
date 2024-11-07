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
      id: json['_id'] ?? '',
      username: json['username'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      link: json['link'] ?? '',
      logo: json['logo'] ?? '',
      settings: OrganizationSettings.fromJson(json['settings']),
    );
  }
}

class OrganizationSettings {
  final int treasury;
  final bool isContent;
  final bool isApp;
  final double pricePerMonth;
  final String appUrl;

  OrganizationSettings({
    required this.treasury,
    required this.isContent,
    required this.isApp,
    required this.pricePerMonth,
    required this.appUrl,
  });

  factory OrganizationSettings.fromJson(Map<String, dynamic> json) {
    return OrganizationSettings(
      treasury: json['treasury'] ?? 0,
      isContent: json['isContent'] ?? false,
      isApp: json['isApp'] ?? false,
      pricePerMonth: json['pricePerMonth'] ?? 0,
      appUrl: json['appUrl'] ?? '',
    );
  }
}
