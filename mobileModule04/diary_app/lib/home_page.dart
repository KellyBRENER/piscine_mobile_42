import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<UserCredential?> signInWithGoogle({BuildContext? context}) async {
    try {
      // Initialise GoogleSignIn avec le client ID Web (serverClientId)
      await GoogleSignIn.instance.initialize(
        serverClientId: '608315824552-glvca16edhpsitmhbne43q582qkb0hg2.apps.googleusercontent.com',
      );
      
      // Déclenche le flux d'authentification
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance.authenticate();

      // Obtient les détails d'authentification de la requête
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      
      // Obtient l'accessToken via l'authorization client
      final authClient = googleUser.authorizationClient;
      final clientAuth = await authClient.authorizationForScopes([
        'email',
        'profile',
      ]);
      
      // Crée un credential Firebase à partir du jeton
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: clientAuth?.accessToken,
        idToken: googleAuth.idToken,
      );

      // Connecte l'utilisateur à Firebase
      return await FirebaseAuth.instance.signInWithCredential(credential);
      
      // Le StreamBuilder fera la redirection automatiquement
    } on FirebaseAuthException catch (e) {
      print('Erreur Google Sign-In : $e');
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur Google Sign-In : ${e.message ?? e.code}')),
        );
      }
      return null;
    }
  }

  Future<void> signInWithGitHub(BuildContext context) async {
    try {
      // Crée le fournisseur d'authentification GitHub
      final GithubAuthProvider githubProvider = GithubAuthProvider();
      
      print('Début de l\'authentification GitHub...');

      try {
        // Essayer de se connecter avec GitHub
        final userCredential = await FirebaseAuth.instance.signInWithProvider(githubProvider);
        print('Authentification GitHub réussie: ${userCredential.user?.email}');
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential' && e.email != null) {
          // Le compte existe déjà avec un autre provider (souvent Google).
          print('Compte existant: demande de connexion Google pour lier les providers');

          // Récupère le credential GitHub en attente pour le lier après connexion Google.
          final pendingCredential = e.credential;

          // Demande une authentification Google
          final googleResult = await signInWithGoogle(context: context);

          if (googleResult != null && pendingCredential != null) {
            try {
              await googleResult.user?.linkWithCredential(pendingCredential);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Compte GitHub lié à votre compte.')),
              );
            } on FirebaseAuthException catch (linkError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Échec de liaison: ${linkError.message ?? linkError.code}')),
              );
            }
          }
        } else {
          rethrow;
        }
      }
    } on FirebaseAuthException catch (e) {
      print('Erreur Firebase GitHub Sign-In : Code=${e.code}, Message=${e.message}');
    } catch (e) {
       print('Erreur générale GitHub : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Accueil")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text("Veuillez vous connecter"),
            const SizedBox(height: 20),
            // Bouton Google
            ElevatedButton.icon(
              onPressed: () => signInWithGoogle(context: context),
              icon: const Icon(Icons.login),
              label: const Text("Se connecter avec Google"),
            ),
            const SizedBox(height: 10),
            // Bouton GitHub
            ElevatedButton.icon(
              onPressed: () => signInWithGitHub(context),
              icon: const Icon(Icons.code),
              label: const Text("Se connecter avec GitHub"),
            ),
          ],
        ),
      ),
    );
  }
}