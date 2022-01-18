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
  late WebAuth _webAuth;

  BesAuth({
    required this.clientId,
    required this.serviceUrl,
    required this.redirectPath,
    required this.clientSecret,
  }) {
    _webAuth = WebAuth(
      redirectUri: redirectUri,
    );
  }

  String get redirectUri => "$CAllBACK_URL_SCHEMA://$redirectPath";

  Future<BesSession?> authenticate(BuildContext context) async {
    String code = await _openWebLogin(context);
    return await _getTokensWithCode(code);
  }

  ///Return null if refresh was failed elese return new BesSession
  Future<BesSession?> refreshToken(String token) async {
    return await http.post(Uri.https(this.serviceUrl, GET_TOKENS_PATH), body: {
      "client_id": clientId,
      'refresh_token': token,
      "redirect_uri": redirectUri,
      "client_secret": clientSecret,
      "grant_type": "refresh_token",
    }).then((response) {
      if (response.statusCode == 200)
        return BesSession.fromJson(response.body);
      else
        return null;
    });
  }

  Future<void> logout(BesSession session) async {
    await http.post(Uri.https(this.serviceUrl, REVOKE_TOKEN_PATH), body: {
      "client_id": clientId,
      "token": session.accessToken,
      "client_secret": clientSecret,
    });
  }

  Future<String> _openWebLogin(BuildContext context) async {
    String url = Uri.https(serviceUrl, AUTHORIZE_PATH, {
      "response_type": "code",
      "client_id": clientId,
      "redirect_uri": redirectUri,
    }).toString();
    return await _webAuth.open(context, url).then((response) {
      if (response == '') return response;
      return Uri.parse(response).queryParameters["code"] ?? '';
    });
  }

  Future<BesSession> _getTokensWithCode(String code) async {
    return await http.post(Uri.https(this.serviceUrl, GET_TOKENS_PATH), body: {
      "code": code,
      "client_id": clientId,
      "redirect_uri": redirectUri,
      "client_secret": clientSecret,
      "grant_type": "authorization_code",
    }).then((response) => BesSession.fromJson(response.body));
  }
}
