import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebAuth {
  String redirectUri;

  WebAuth({this.redirectUri});

  Future<String> open(BuildContext context, String authUrl) {
    Completer completer = Completer<String>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.90,
        child: ClipRRect(
          borderRadius: new BorderRadius.only(
            topLeft: const Radius.circular(15.0),
            topRight: const Radius.circular(15.0),
          ),
          child: Container(
            child: Center(
              child: WebView(
                initialUrl: authUrl,
                javascriptMode: JavascriptMode.unrestricted,
                navigationDelegate: (action) {
                  String actionOrigin = this._getOriginUri(action.url);
                  String redirectOrigin = this._getOriginUri(this.redirectUri);

                  if (actionOrigin == redirectOrigin) {
                    Navigator.pop(context);
                    completer.complete(action.url);
                    return NavigationDecision.prevent;
                  }

                  return NavigationDecision.navigate;
                },
                onWebViewCreated: (WebViewController controller) {
                  CookieManager().clearCookies();
                  controller.clearCache();
                },
              ),
            ),
          ),
        ),
      ),
    ).then((val) {
      if (!completer.isCompleted) {
        completer.complete(null);
      }
    });

    return completer.future;
  }

  String _getOriginUri(String uri) {
    Uri fUri = Uri.parse(uri);
    return "${fUri.scheme}://${fUri.host}${fUri.path.isEmpty ? "/" : fUri.path}";
  }
}
