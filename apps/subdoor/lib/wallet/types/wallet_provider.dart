import 'dart:convert';
import 'dart:typed_data';

class WalletProvider {
  final String name;
  final String icon;
  Uint8List? iconBytes;

  WalletProvider({
    required this.name,
    required this.icon,
  }) {
    final rawIcon = icon.split(',').last;
    iconBytes = base64Decode(rawIcon);
  }
}
