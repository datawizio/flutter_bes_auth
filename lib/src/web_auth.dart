import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebAuth {
  String redirectUri;

  WebAuth({required this.redirectUri});

  Future<String> open(BuildContext context, String authUrl) async {
    Completer completer = Completer<String>();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.90,
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(15.0),
            topRight: Radius.circular(15.0),
          ),
          child: Center(
            child: WebView(
              initialUrl: authUrl,
              javascriptMode: JavascriptMode.unrestricted,
              navigationDelegate: (action) {
                String actionOrigin = _getOriginUri(action.url);
                String redirectOrigin = _getOriginUri(redirectUri);

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
    ).then((val) {
      if (!completer.isCompleted) {
        completer.complete('');
      }
    });
    return await completer.future;
  }

  String _getOriginUri(String uri) {
    Uri fUri = Uri.parse(uri);
    return "${fUri.scheme}://${fUri.host}${fUri.path.isEmpty ? "/" : fUri.path}";
  }
}
