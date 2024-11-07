import 'package:firebase_auth/firebase_auth.dart';

class ExceptionHandler {
  static String getFirebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This user has been disabled';
      case 'user-not-found':
        return 'User not found. Please check your email address.';
      case 'wrong-password':
        return 'Invalid password';
      case 'email-already-in-use':
        return 'The email address is already in use by another account';
      case 'invalid-credential':
        return 'Invalid credential provided';
      case 'operation-not-allowed':
        return 'This operation is not allowed';
      case 'weak-password':
        return 'The password is too weak. Choose a stronger password';
      case 'missing-verification-code':
        return 'The verification code is missing';
      case 'missing-verification-id':
        return 'The verification ID is missing';
      case 'invalid-verification-code':
        return 'Invalid verification code';
      case 'invalid-verification-id':
        return 'Invalid verification ID';
      case 'session-expired':
        return 'The session has expired. Please try again';
      case 'quota-exceeded':
        return 'Quota exceeded. Please try again later';
      case 'captcha-check-failed':
        return 'Captcha check failed. Please try again';
      case 'app-not-authorized':
        return 'The app is not authorized to use Firebase Authentication';
      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email address but different sign-in credentials. Try signing in with a different provider or link your existing account with this provider.';
      case 'requires-recent-login':
        return 'This operation is sensitive and requires recent authentication. Please log in again and try again.';
      case 'provider-already-linked':
        return 'This account is already linked with another account of the same provider.';
      case 'credential-already-in-use':
        return 'This credential is already associated with a different user account.';
      case 'web-internal-error':
        return 'An internal error has occurred on the web platform. Please try again later.';
      case 'invalid-continue-uri':
        return 'The continue URL provided in the request is invalid.';
      case 'invalid-dynamic-link-domain':
        return 'The provided dynamic link domain is not configured or authorized for the current project.';
      case 'dynamic-link-not-activated':
        return 'The provided dynamic link domain has not been activated for the current project.';
      case 'invalid-action-code':
        return 'The action code is invalid. This can happen if the code is malformed, expired, or has already been used.';
      case 'invalid-email-verified':
        return 'The email address is not verified. Please verify your email before signing in.';
      case 'invalid-id-token':
        return 'The ID token provided is invalid.';
      case 'invalid-message-payload':
        return 'The email template does not contain a valid message payload.';
      case 'invalid-oauth-provider':
        return 'The specified OAuth provider is not supported.';
      case 'invalid-oauth-client-id':
        return 'The OAuth client ID is not valid.';
      case 'email-change-needs-verification':
        return 'The new email address must be verified before changing it.';
      case 'missing-multi-factor-info':
        return 'The request is missing multi-factor authentication information.';
      case 'missing-session-info':
        return 'The request is missing session information.';
      case 'password-reset-required':
        return 'This user must reset their password before signing in.';
      case 'user-mismatch':
        return 'The supplied credentials do not correspond to the previously signed in user.';
      case 'web-storage-unsupported':
        return 'Web storage is not supported or is disabled for this app. Enable web storage in your app settings.';
      case 'invalid-recipient-email':
        return 'The email address is not recognized as a valid recipient.';
      case 'tenant-id-mismatch':
        return 'The provided tenant ID does not match the Auth instance\'s tenant ID.';
      case 'missing-android-pkg-name':
        return 'The Android package name is missing when setting up the Android OAuth custom scheme.';
      case 'auth-domain-config-required':
        return 'Auth domain configuration is required for web clients.';
      case 'missing-app-credential':
        return 'The app credential is missing. This may occur if the app is not yet configured for Firebase.';
      case 'invalid-user-token':
        return 'The user\'s credential is no longer valid. Please sign in again.';
      case 'credential-backoff':
        return 'Credential creation failed due to a backend service throttle. Please try again later.';
      case 'change-email-already-in-use':
        return 'The new email address is already in use by another account.';
      case 'insufficient-permission':
        return 'Insufficient permissions to perform the requested operation.';
      case 'internal-error':
        return 'An internal error has occurred. Please try again later.';
      case 'invalid-api-key':
        return 'The provided API key is invalid. Check your Firebase Console settings.';
      case 'operation-not-supported-in-this-environment':
        return 'This operation is not supported in the current environment.';
      case 'timeout':
        return 'The operation has timed out. Please try again.';
      default:
        return 'An unexpected error occurred. Please try again later.';
    }
  }
}
