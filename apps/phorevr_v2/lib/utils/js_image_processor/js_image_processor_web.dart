@JS()
library image_processor;

import 'package:js/js.dart';
import 'package:js/js_util.dart';

@JS('resizeImage')
external Object _resizeImage(
  String base64Data,
  String format,
);

Future<String> resizeImage(
  String base64Data,
  String contentType,
) {
  return promiseToFuture(
    _resizeImage(base64Data, contentType),
  );
}
