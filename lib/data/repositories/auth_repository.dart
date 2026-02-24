import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/config/app_mode.dart';

class AuthResult {
  final User? user;
  final String? errorMessage;

  const AuthResult({this.user, this.errorMessage});
}

class AuthRepository {
  static const String allowedDomain = 'vitbhopal.ac.in';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    hostedDomain: allowedDomain,
  );

  Future<AuthResult> signInWithGoogle() async {
    if (!AppMode.backendEnabled) {
      return const AuthResult(
        errorMessage: 'Login is disabled in demo mode.',
      );
    }

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return const AuthResult(errorMessage: 'Sign-in cancelled.');
      }

      final email = googleUser.email.toLowerCase();
      if (!email.endsWith('@$allowedDomain')) {
        await _googleSignIn.signOut();
        return const AuthResult(
          errorMessage: 'Please use your @vitbhopal.ac.in email ID.',
        );
      }

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      return AuthResult(user: userCredential.user);
    } on FirebaseAuthException catch (e) {
      return AuthResult(errorMessage: e.message ?? e.code);
    } catch (e) {
      return AuthResult(errorMessage: e.toString());
    }
  }

  User? getCurrentUser() =>
      AppMode.backendEnabled ? FirebaseAuth.instance.currentUser : null;

  Future<void> signOut() async {
    if (!AppMode.backendEnabled) return;

    await _googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();
  }
}
