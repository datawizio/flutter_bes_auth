import 'dart:convert';

class BesSession {
  String scope;
  int expiresIn;
  String tokenType;
  String accessToken;
  String refreshToken;

  BesSession({
    this.scope,
    this.expiresIn,
    this.tokenType,
    this.accessToken,
    this.refreshToken,
  });

  Map<String, dynamic> toMap() {
    return {
      'scope': scope,
      'expires_in': expiresIn,
      'token_type': tokenType,
      'access_token': accessToken,
      'refresh_token': refreshToken,
    };
  }

  factory BesSession.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return BesSession(
      scope: map['scope'],
      expiresIn: map['expires_in'],
      tokenType: map['token_type'],
      accessToken: map['access_token'],
      refreshToken: map['refresh_token'],
    );
  }

  factory BesSession.fromJson(String source) {
    return BesSession.fromMap(json.decode(source));
  }

  @override
  String toString() => this.toJson();

  String toJson() => json.encode(toMap());
}
