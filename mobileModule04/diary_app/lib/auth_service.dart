import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // Instance du sign-in Google.
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
    ],
  );

  Future<UserCredential> signInWithGoogle() async {
    // Ouvre la fenêtre de sélection de compte Google.
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
      throw Exception("Connexion annulée par l'utilisateur");
    }

    // Récupère les tokens d'authentification Google.
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Crée un credential compatible Firebase Auth.
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
      accessToken: googleAuth.accessToken,
    );

    // Connexion à Firebase.
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();
  }
}
