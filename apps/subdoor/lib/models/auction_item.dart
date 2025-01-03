import 'dart:convert';
import 'dart:typed_data';

import 'package:subdoor/utils/common.dart';

enum AuctionStatus {
  pending,
  active,
  ended,
  cancelled,
}

enum SubscriptionFrequency {
  weekly,
  monthly,
  three_months,
  six_months,
  yearly,
  one_time,
}

enum OfferType {
  auction,
  buy_now,
}

class AuctionItem {
  final String id;
  final String name;
  final Uint8List? logo;
  final String? logoMimeType;
  final double originalPrice;
  final double currentPrice;
  final SubscriptionFrequency subscriptionFrequency;
  final DateTime startsAt;
  final OfferType offerType;
  final bool isPaid;
  final AuctionStatus status;
  final String? lastBidBy;
  final DateTime? lastBidAt;
  final DateTime? endedAt;
  final DateTime? subscribedAt;

  AuctionItem({
    required this.id,
    required this.name,
    required this.originalPrice,
    required this.currentPrice,
    required this.status,
    required this.subscriptionFrequency,
    required this.startsAt,
    required this.offerType,
    this.logo,
    this.logoMimeType,
    this.isPaid = false,
    this.lastBidBy,
    this.lastBidAt,
    this.endedAt,
    this.subscribedAt,
  });

  factory AuctionItem.fromJson(Map<String, dynamic> json) {
    return AuctionItem(
      id: json['_id'],
      name: json['name'],
      logo: json['logo'] != null ? base64Decode(json['logo']) : null,
      logoMimeType: json['logoMimeType'],
      originalPrice: json['originalPrice'],
      currentPrice: json['currentPrice'],
      status: CommonUtils.stringToEnum(json['status'], AuctionStatus.values),
      subscriptionFrequency: CommonUtils.stringToEnum(
        json['subscriptionFrequency'],
        SubscriptionFrequency.values,
      ),
      startsAt: DateTime.parse(json['startsAt']),
      lastBidBy: json['lastBidBy'],
      isPaid: json['isPaid'],
      lastBidAt:
          json['lastBidAt'] != null ? DateTime.parse(json['lastBidAt']) : null,
      endedAt: json['endedAt'] != null ? DateTime.parse(json['endedAt']) : null,
      subscribedAt: json['subscribedAt'] != null
          ? DateTime.parse(json['subscribedAt'])
          : null,
      offerType: CommonUtils.stringToEnum(json['offerType'], OfferType.values),
    );
  }

  AuctionItem copyWith({
    AuctionStatus? status,
    DateTime? endedAt,
    bool? isPaid,
  }) {
    return AuctionItem(
      id: id,
      name: name,
      logo: logo,
      logoMimeType: logoMimeType,
      originalPrice: originalPrice,
      currentPrice: currentPrice,
      status: status ?? this.status,
      subscriptionFrequency: subscriptionFrequency,
      startsAt: startsAt,
      lastBidBy: lastBidBy,
      lastBidAt: lastBidAt,
      endedAt: endedAt ?? this.endedAt,
      offerType: offerType,
      isPaid: isPaid ?? this.isPaid,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'logo': logo != null ? base64Encode(logo!) : null,
      'logoMimeType': logoMimeType,
      'originalPrice': originalPrice,
      'currentPrice': currentPrice,
      'status': status.name,
      'subscriptionFrequency': subscriptionFrequency.name,
      'startsAt': startsAt.toIso8601String(),
      'lastBidBy': lastBidBy,
      'lastBidAt': lastBidAt?.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
      'offerType': offerType.name,
      'isPaid': isPaid,
    };
  }

  static String formatFrequencyShort(SubscriptionFrequency frequency) {
    switch (frequency) {
      case SubscriptionFrequency.weekly:
        return 'w';
      case SubscriptionFrequency.monthly:
        return 'mo';
      case SubscriptionFrequency.three_months:
        return '3mo';
      case SubscriptionFrequency.six_months:
        return '6mo';
      case SubscriptionFrequency.yearly:
        return 'yr';
      case SubscriptionFrequency.one_time:
        return 'one-time';
    }
  }

  static String formatFrequencyLong(SubscriptionFrequency frequency) {
    switch (frequency) {
      case SubscriptionFrequency.weekly:
        return 'weekly';
      case SubscriptionFrequency.monthly:
        return 'monthly';
      case SubscriptionFrequency.three_months:
        return '3 months';
      case SubscriptionFrequency.six_months:
        return '6 months';
      case SubscriptionFrequency.yearly:
        return 'yearly';
      case SubscriptionFrequency.one_time:
        return 'one-time';
    }
  }

  double get discountPercent =>
      (originalPrice - currentPrice) / originalPrice * 100;
}
