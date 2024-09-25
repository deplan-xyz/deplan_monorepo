import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image_compression_flutter/image_compression_flutter.dart';
import 'package:phorevr/utils/js_image_processor/js_image_processor.dart'
    as js_image;

class ImageUtils {
  static Future<ImageFile> compressImage(PlatformFile file) async {
    ImageFile input = ImageFile(
      filePath: file.name,
      rawBytes: file.bytes!,
    );
    if (kIsWeb) {
      final resizedBase64 = await js_image.resizeImage(
        base64Encode(input.rawBytes),
        input.contentType!,
      );
      return ImageFile(
        filePath: file.name,
        rawBytes: base64Decode(resizedBase64),
      );
    }
    Configuration config = const Configuration(
      outputType: ImageOutputType.webpThenJpg,
      quality: 30,
    );

    final param = ImageFileConfiguration(input: input, config: config);
    return compressor.compress(param);
  }
}
