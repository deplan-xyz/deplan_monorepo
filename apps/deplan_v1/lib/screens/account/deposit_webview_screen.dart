import 'package:deplan/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class DepositWebviewScreen extends StatefulWidget {
  final String url;
  final Function() onSuccess;

  const DepositWebviewScreen(this.url, {super.key, required this.onSuccess});

  @override
  State<DepositWebviewScreen> createState() => _DepositWebviewScreenState();
}

class _DepositWebviewScreenState extends State<DepositWebviewScreen> {
  late String urlToDisplay;

  InAppWebViewController? webViewController;

  @override
  void initState() {
    super.initState();
    urlToDisplay = Uri.parse(widget.url).origin;
  }

  buildControls() {
    const textStyle = TextStyle(
      color: COLOR_GRAY2,
    );
    return Container(
      height: 70,
      color: COLOR_ALMOST_BLACK,
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(
                  Icons.close,
                  color: COLOR_GRAY2,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              urlToDisplay,
              style: textStyle,
              textAlign: TextAlign.center,
            ),
          ),
          const Expanded(
            flex: 1,
            child: SizedBox(),
          ),
        ],
      ),
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
                initialUrlRequest: URLRequest(url: WebUri(widget.url)),
                onLoadStart: (controller, url) {
                  if (url != null && url.path.contains('deposit-success')) {
                    widget.onSuccess();
                    return;
                  }
                  setState(() {
                    urlToDisplay = url?.origin ?? urlToDisplay;
                  });
                },
                onWebViewCreated: (controller) {
                  webViewController = controller;
                },
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
