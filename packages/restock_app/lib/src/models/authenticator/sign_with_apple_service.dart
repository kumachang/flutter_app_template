import 'dart:io';

import 'package:authenticator/authenticator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../utils/utils.dart';

/// Sign in with Apple を許可するかどうか
/// - iOS 13 and higher
/// - macOS 10.15 and higher
/// - (Android: Not implemented)
Future<bool> get canSignInWithApple async {
  if (!await SignInWithApple.isAvailable()) {
    return false;
  }
  if (!Platform.isIOS && !Platform.isMacOS) {
    return false;
  }
  return true;
}

/// Apple認証のクレデンシャルを要求する
/// [SignInWithAppleException], [SignInWithAppleException]
Future<AuthCredential?> requestAppleAuthCredential() async {
  if (!await canSignInWithApple) {
    throw Exception('Sign in with Apple に未対応の端末、もしくはOSです。');
  }
  // パッケージによる視覚情報のリクエスト実行
  /// Scope: [first name], [last name], [email] を指定可能
  /// Sign in with Apple が使えない場合、 [SignInWithAppleNotSupportedException]
  late AuthorizationCredentialAppleID credential;
  try {
    credential = await SignInWithApple.getAppleIDCredential(scopes: []);
  } on SignInWithAppleAuthorizationException catch (e) {
    logger.warning(e);
    switch (e.code) {
      case AuthorizationErrorCode.canceled:
        // ユーザーによるキャンセル
        return null;
      case AuthorizationErrorCode.failed:
        rethrow;
      case AuthorizationErrorCode.invalidResponse:
        rethrow;
      case AuthorizationErrorCode.notHandled:
        rethrow;
      case AuthorizationErrorCode.unknown:
        rethrow;
      case AuthorizationErrorCode.notInteractive:
        rethrow;
    }
  }
  final credentialState =
      await SignInWithApple.getCredentialState(credential.userIdentifier!);

  switch (credentialState) {
    case CredentialState.authorized:
      logger.fine('Sign in with Apple authorized');
      // 成功！クレデンシャルを返却する
      final oAuthProvider = OAuthProvider(SigningMethod.apple.providerId);
      final oAuthCredential = oAuthProvider.credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );
      return oAuthCredential;

    case CredentialState.revoked:
      throw Exception('Sign in failed: Revoked');

    case CredentialState.notFound:
      throw Exception('Sign in failed: Not Found');
  }
}
