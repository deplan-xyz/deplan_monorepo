import 'dart:typed_data';

import 'package:iw_app/models/organization_member_model.dart';
import 'package:iw_app/utils/numbers.dart';

class Organization {
  String? id;
  String? username;
  String? name;
  String? link;
  String? description;
  String? logo;
  String? wallet;
  String? mint;
  String? mintStatus;
  String? mintError;
  Uint8List? logoToSet;
  OrganizationSettings? settings = OrganizationSettings();
  double? lamportsMinted;

  Organization({
    this.username,
    this.name,
    this.link,
    this.description,
    this.logo,
    this.wallet,
    this.lamportsMinted,
  });

  Organization.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    username = json['username'];
    name = json['name'];
    link = json['link'];
    description = json['description'];
    logo = json['logo'];
    wallet = json['wallet'];
    mint = json['mint'];
    mintStatus = json['mintStatus'];
    mintError = json['mintError'];
    lamportsMinted = intToDouble(json['lamportsMinted']);
    settings = json['settings'] is Map
        ? OrganizationSettings.fromJson(json['settings'])
        : null;
  }

  Organization.fromOrg(Organization organization)
      : id = organization.id,
        username = organization.username,
        name = organization.name,
        link = organization.link,
        description = organization.description,
        logo = organization.logo,
        wallet = organization.wallet,
        mint = organization.mint,
        mintStatus = organization.mintStatus,
        mintError = organization.mintError,
        lamportsMinted = intToDouble(organization.lamportsMinted),
        settings = organization.settings != null
            ? OrganizationSettings.fromOrgSettings(organization.settings!)
            : null;

  @override
  String toString() {
    return '''
${super.toString()}
username: $username
name: $name
link: $link
wallet: $wallet
description: $description
settings:
$settings
''';
  }

  Map<String, dynamic> toMap(OrganizationMember? member) {
    final orgMap = {
      'username': username,
      'name': name,
      'link': link,
      'description': description,
      'settings[treasury]': settings?.treasury,
      'settings[isContent]': settings?.isContent,
      'settings[isApp]': settings?.isApp,
      'settings[pricePerMonth]': settings?.pricePerMonth,
      'lamportsMinted': lamportsMinted,
    };
    if (member != null) {
      orgMap['member[occupation]'] = member.occupation;
      orgMap['member[role]'] = member.role?.name;
      orgMap['member[impactRatio]'] = member.impactRatio;
      orgMap['member[isAutoContributing]'] = member.isAutoContributing;
      orgMap['member[hoursPerWeek]'] = member.hoursPerWeek;
      if (member.compensation != null) {
        orgMap['member[compensation][amount]'] = member.compensation!.amount;
        orgMap['member[compensation][type]'] = member.compensation!.type?.name;
        orgMap['member[compensation][period][value]'] =
            member.compensation!.period?.value;
        orgMap['member[compensation][period][timeframe]'] =
            member.compensation!.period?.timeframe?.name;
      }
    }
    return orgMap;
  }
}

class OrganizationSettings {
  int treasury = 0;
  String? successUrl;
  String? cancelUrl;
  bool? isContent;
  bool? isApp;
  double? pricePerMonth;
  String? appUrl;

  OrganizationSettings({
    this.treasury = 0,
    this.isContent = false,
    this.isApp = false,
  });

  OrganizationSettings.fromJson(Map<String, dynamic> json) {
    treasury = json['treasury'];
    successUrl = json['successUrl'];
    cancelUrl = json['cancelUrl'];
    isContent = json['isContent'];
    isApp = json['isApp'];
    pricePerMonth = json['pricePerMonth'];
    appUrl = json['appUrl'];
  }

  OrganizationSettings.fromOrgSettings(OrganizationSettings settings)
      : treasury = settings.treasury,
        successUrl = settings.successUrl,
        cancelUrl = settings.cancelUrl,
        isContent = settings.isContent,
        isApp = settings.isApp,
        pricePerMonth = settings.pricePerMonth,
        appUrl = settings.appUrl;

  @override
  String toString() {
    return '''
  ${super.toString()}
  treasury: $treasury
''';
  }
}
