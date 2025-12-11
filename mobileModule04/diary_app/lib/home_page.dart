import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> signInWithGoogle() async {
    try {
      // Déclenche le flux d'authentification
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance.authenticate();

      // Obtient les détails d'authentification de la requête
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      
      // Obtient l'accessToken via l'authorization client
      final authClient = googleUser.authorizationClient;
      final clientAuth = await authClient.authorizationForScopes([]);
      
      // Crée un credential Firebase à partir du jeton
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: clientAuth?.accessToken,
        idToken: googleAuth.idToken,
      );

      // Connecte l'utilisateur à Firebase
      await FirebaseAuth.instance.signInWithCredential(credential);
      
      // Le StreamBuilder fera la redirection automatiquement
    } on FirebaseAuthException catch (e) {
      print('Erreur Google Sign-In : $e');
      // Afficher un Snackbar à l'utilisateur ici
    }
  }

  Future<void> signInWithGitHub() async {
    try {
      // Crée le fournisseur d'authentification GitHub
      final GithubAuthProvider githubProvider = GithubAuthProvider();

      // signInWithProvider gère l'ouverture de la fenêtre de navigateur/web view.
      // Cela nécessite que le package 'firebase_auth' gère correctement les liens
      // profonds et les redirections sur mobile.
      await FirebaseAuth.instance.signInWithProvider(githubProvider);
      
    } on FirebaseAuthException catch (e) {
      print('Erreur GitHub Sign-In : $e');
      // Gérer l'erreur
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
              onPressed: signInWithGoogle,
              icon: const Icon(Icons.login),
              label: const Text("Se connecter avec Google"),
            ),
            const SizedBox(height: 10),
            // Bouton GitHub
            ElevatedButton.icon(
              onPressed: signInWithGitHub,
              icon: const Icon(Icons.code),
              label: const Text("Se connecter avec GitHub"),
            ),
          ],
        ),
      ),
    );
  }
}