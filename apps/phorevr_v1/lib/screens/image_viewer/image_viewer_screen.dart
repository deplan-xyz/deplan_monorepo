import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:phorevr_v1/api/auth_api.dart';
import 'package:phorevr_v1/models/file_info.dart';
import 'package:phorevr_v1/theme/app_theme.dart';
import 'package:phorevr_v1/utils/ipfs.dart';
import 'package:phorevr_v1/widgets/view/screen_scaffold.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:url_launcher/url_launcher.dart';

class ImageViewerScreen extends StatefulWidget {
  final FileInfo fileInfo;

  const ImageViewerScreen({
    super.key,
    required this.fileInfo,
  });

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  late Uint8List fullData;

  @override
  void initState() {
    super.initState();
    fullData = widget.fileInfo.data ?? kTransparentImage;
  }

  Future<void> fetchFullData() async {
    Uint8List data = await IpfsUtils.fetch(widget.fileInfo.fullPath);
    try {
      data = await authApi.decrypt(data);
      // ignore: empty_catches
    } catch (e) {}
    setState(() {
      fullData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: '',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              child: Hero(
                tag: widget.fileInfo.txnHash ?? '',
                transitionOnUserGestures: true,
                flightShuttleBuilder: (_, animation, __, ___, toHeroContext) {
                  animation.addStatusListener((status) {
                    if (status == AnimationStatus.completed) {
                      fetchFullData();
                    }
                  });
                  return toHeroContext.widget;
                },
                child: FadeInImage(
                  fadeInDuration: const Duration(milliseconds: 300),
                  placeholder: MemoryImage(fullData),
                  image: MemoryImage(fullData),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () {
              launchUrl(
                Uri.parse(
                  'https://nftstorage.link/ipfs/${widget.fileInfo.cid}',
                ),
              );
            },
            style: ButtonStyle(
              overlayColor: WidgetStateProperty.all(Colors.transparent),
            ),
            child: const Text(
              'Check photo on blockchain »',
              style: TextStyle(
                color: COLOR_GRAY,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
