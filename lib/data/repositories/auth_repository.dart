import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<AuthResult> signInWithGoogle() async {
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

      final userCredential = await _auth.signInWithCredential(credential);

      return AuthResult(user: userCredential.user);
    } on FirebaseAuthException catch (e) {
      return AuthResult(errorMessage: e.message ?? e.code);
    } catch (e) {
      return AuthResult(errorMessage: e.toString());
    }
  }

  User? getCurrentUser() => _auth.currentUser;
}
