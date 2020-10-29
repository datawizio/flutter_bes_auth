import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'web_auth.dart';
import 'constants.dart';
import 'bes_session.dart';

class BesAuth {
  String clientId;
  String serviceUrl;
  String clientSecret;
  String redirectPath;
  WebAuth _webAuth;

  BesAuth({
    this.clientId,
    this.serviceUrl,
    this.redirectPath,
    this.clientSecret,
  }) {
    this._webAuth = WebAuth(
      redirectUri: this.redirectUri,
    );
  }

  String get redirectUri => "$CAllBACK_URL_SCHEMA://$redirectPath";

  Future<BesSession> authenticate(BuildContext context) async {
    String code = await this._openWebLogin(context);
    if (code != null) return await this._getTokensWithCode(code);
    return null;
  }

  Future<void> logout(BesSession session) async {
    if (session != null) {
      await http.post(Uri.https(this.serviceUrl, REVOKE_TOKEN_PATH), body: {
        "client_id": this.clientId,
        "token": session.accessToken,
        "client_secret": this.clientSecret,
      });
    }
  }

  Future<String> _openWebLogin(BuildContext context) {
    String url = Uri.https(this.serviceUrl, AUTHORIZE_PATH, {
      "response_type": "code",
      "client_id": this.clientId,
      "redirect_uri": this.redirectUri,
    }).toString();

    return this._webAuth.open(context, url).then((response) {
      if (response != null) return Uri.parse(response).queryParameters["code"];
      return response;
    });
  }

  Future<BesSession> _getTokensWithCode(String code) {
    return http.post(Uri.https(this.serviceUrl, GET_TOKENS_PATH), body: {
      "code": code,
      "client_id": this.clientId,
      "redirect_uri": this.redirectUri,
      "client_secret": this.clientSecret,
      "grant_type": "authorization_code",
    }).then((response) => BesSession.fromJson(response.body));
  }
}
