import 'dart:convert';

import 'package:deplan_v1/models/web3_message.dart';
import 'package:deplan_v1/theme/app_theme.dart';
import 'package:dio/dio.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:mime/mime.dart';
import 'package:open_filex/open_filex.dart';

class AppIframeScreen extends StatefulWidget {
  final String url;
  final Future<Web3Message> Function(Web3Message)? onWalletRequest;

  const AppIframeScreen(
    this.url, {
    super.key,
    this.onWalletRequest,
  });

  @override
  State<AppIframeScreen> createState() => _AppIframeScreenState();
}

class _AppIframeScreenState extends State<AppIframeScreen> {
  final GlobalKey webViewKey = GlobalKey();
  late String urlToDisplay;

  bool isDownloading = false;
  String downloadedPath = '';

  InAppWebViewController? webViewController;

  @override
  initState() {
    super.initState();
    urlToDisplay = Uri.parse(widget.url).origin;
  }

  buildControls() {
    const textStyle = TextStyle(
      color: COLOR_GRAY2,
    );
    return Container(
      color: COLOR_ALMOST_BLACK,
      child: Column(
        children: [
          if (isDownloading)
            const Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  SizedBox(
                    width: 15,
                    height: 15,
                    child: CircularProgressIndicator(
                      color: COLOR_GRAY2,
                      strokeWidth: 1,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Downloading...',
                    style: textStyle,
                  ),
                ],
              ),
            ),
          if (downloadedPath.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  const Text(
                    'File downloaded',
                    style: textStyle,
                  ),
                  const SizedBox(width: 20),
                  const Expanded(child: SizedBox()),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: COLOR_WHITE,
                    ),
                    onPressed: () {
                      OpenFilex.open(downloadedPath);
                    },
                    child: const Text('Open file'),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: COLOR_WHITE,
                    ),
                    onPressed: () {
                      setState(() {
                        downloadedPath = '';
                      });
                    },
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(3.0),
                          child: Icon(
                            Icons.close,
                            color: COLOR_GRAY2,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          webViewController?.goBack();
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(3.0),
                          child: Icon(
                            Icons.chevron_left,
                            color: COLOR_GRAY2,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          webViewController?.goForward();
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(3.0),
                          child: Icon(
                            Icons.chevron_right,
                            color: COLOR_GRAY2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Text(
                    urlToDisplay,
                    style: textStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: InkWell(
                    onTap: () {
                      webViewController?.reload();
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(3.0),
                      child: Icon(
                        Icons.refresh,
                        color: COLOR_GRAY2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  handleDownload(controller, DownloadStartRequest downloadStartRequest) async {
    if (downloadStartRequest.url.toString().startsWith('blob')) {
      final jsContent =
          await rootBundle.loadString('assets/js/blobToBase64.js');
      await controller.evaluateJavascript(
        source: jsContent.replaceAll(
          'blobUrlPlaceholder',
          downloadStartRequest.url.toString(),
        ),
      );
    } else {
      setState(() {
        isDownloading = true;
      });
      try {
        final res = await Dio().get(
          downloadStartRequest.url.toString(),
          options: Options(responseType: ResponseType.bytes),
        );
        final r = await FileSaver.instance.saveFile(
          name: downloadStartRequest.suggestedFilename ??
              DateTime.now().millisecondsSinceEpoch.toString(),
          bytes: res.data,
        );
        setState(() {
          downloadedPath = r;
        });
      } finally {
        setState(() {
          isDownloading = false;
        });
      }
    }
  }

  injectScripts(InAppWebViewController controller) {
    controller.injectJavascriptFileFromAsset(
      assetFilePath: 'assets/js/injected.js',
    );
  }

  String _lookupMimetype(Uint8List bytes) {
    final mimetype = lookupMimeType('', headerBytes: bytes);
    return mimetype ?? '';
  }

  String _mapMimeTypeToExtension(String mimetype) {
    final mimetypeToExt = {
      'text/xml': 'xml',
      'application/xml': 'xml',
      'video/mp4': 'mp4',
    };
    return mimetypeToExt[mimetype] ?? '';
  }

  _saveFileFromBase64(
    String base64content,
    String fileName,
  ) async {
    final bytes = base64Decode(base64content.replaceAll('\n', ''));
    String extension = _mapMimeTypeToExtension(_lookupMimetype(bytes));
    final r = await FileSaver.instance.saveFile(
      name: fileName,
      bytes: bytes,
      ext: extension,
    );
    setState(() {
      downloadedPath = r;
    });
  }

  addJSHandlers(InAppWebViewController controller) {
    controller.addJavaScriptHandler(
      handlerName: 'request',
      callback: (arguments) {
        final message = Web3Message.fromJson(arguments.first);
        if (message.channel != Web3MessageChannelRequest) {
          return null;
        }
        return widget.onWalletRequest?.call(message);
      },
    );
    controller.addJavaScriptHandler(
      handlerName: 'blobToBase64Handler',
      callback: (data) {
        if (data.isNotEmpty) {
          final String receivedFileInBase64 = data[0];

          _saveFileFromBase64(
            receivedFileInBase64,
            DateTime.now().millisecondsSinceEpoch.toString(),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: SafeArea(
              bottom: false,
              child: InAppWebView(
                key: webViewKey,
                initialSettings: InAppWebViewSettings(
                  isInspectable: true,
                  clearCache: true,
                ),
                initialUrlRequest: URLRequest(url: WebUri(widget.url)),
                onLoadStart: (controller, url) {
                  setState(() {
                    urlToDisplay = url?.origin ?? urlToDisplay;
                  });
                },
                onLoadStop: (controller, url) {
                  injectScripts(controller);
                  addJSHandlers(controller);
                },
                onWebViewCreated: (controller) {
                  webViewController = controller;
                  controller.clearCache();
                },
                onDownloadStartRequest: handleDownload,
              ),
            ),
          ),
          Container(
            color: COLOR_ALMOST_BLACK,
            child: SafeArea(
              top: false,
              child: buildControls(),
            ),
          ),
        ],
      ),
    );
  }
}
