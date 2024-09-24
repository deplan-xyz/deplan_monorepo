import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class IpfsImage extends StatelessWidget {
  final String path;
  final String? placeholderPath;
  final gatewayUrl = 'https://nftstorage.link/ipfs';

  const IpfsImage({super.key, required this.path, this.placeholderPath});

  @override
  Widget build(BuildContext context) {
    final placeholder = placeholderPath != null
        ? NetworkImage('$gatewayUrl/$placeholderPath')
        : MemoryImage(kTransparentImage);
    return FadeInImage(
      fadeInDuration: const Duration(milliseconds: 300),
      placeholder: placeholder as ImageProvider,
      image: NetworkImage('$gatewayUrl/$path'),
    );
  }
}
