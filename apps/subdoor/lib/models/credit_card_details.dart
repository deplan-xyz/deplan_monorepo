import 'package:subdoor/utils/common.dart';

enum CreditCardStatus { active, inactive }

class CreditCardDetails {
  final String id;
  final String cardNumber;
  final String expiryDate;
  final String cvv;
  final String address;
  final String city;
  final String state;
  final String zip;
  final CreditCardStatus status;

  CreditCardDetails({
    required this.id,
    required this.cardNumber,
    required this.expiryDate,
    required this.cvv,
    required this.address,
    required this.city,
    required this.state,
    required this.zip,
    required this.status,
  });

  factory CreditCardDetails.fromJson(Map<String, dynamic> json) {
    return CreditCardDetails(
      id: json['_id'],
      cardNumber: json['cardNumber'],
      expiryDate: json['expiryDate'],
      cvv: json['cvv'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      zip: json['zip'],
      status: CommonUtils.stringToEnum(json['status'], CreditCardStatus.values),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'cardNumber': cardNumber,
      'expiryDate': expiryDate,
      'cvv': cvv,
      'address': address,
      'city': city,
      'state': state,
      'zip': zip,
      'status': status.name,
    };
  }
}
