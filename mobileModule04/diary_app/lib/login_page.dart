import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'theme.dart';
import 'main.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  Future<UserCredential?> signInWithGoogle({BuildContext? context}) async {
    try {
      // Initialise GoogleSignIn avec le client ID Web (serverClientId)
      await GoogleSignIn.instance.initialize(
        serverClientId: '608315824552-glvca16edhpsitmhbne43q582qkb0hg2.apps.googleusercontent.com',
      );
      
      // Déclenche le flux d'authentification
      final GoogleSignInAccount? googleUser = await GoogleSignIn.instance.authenticate();

      // Si l'utilisateur annule, googleUser sera null
      if (googleUser == null) {
        print('Authentification Google annulée par l\'utilisateur');
        if (context != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Authentification Google annulée')),
          );
        }
        return null;
      }

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
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      
      // Force le rafraîchissement des données utilisateur (photo de profil, etc.)
      await userCredential.user?.reload();
      
      // Le StreamBuilder fera la redirection automatiquement
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('Erreur Google Sign-In : $e');
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur Google Sign-In : ${e.message ?? e.code}')),
        );
      }
      return null;
    } catch (e) {
      print('Erreur générale Google Sign-In : $e');
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : ${e.toString()}')),
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
        // Retour à la racine pour rafraîchir via le StreamBuilder
        if (context.mounted) {
          //Navigator.pushReplacementNamed(context, '/home');
          Navigator.of(context).popUntil((route) => route.isFirst);
          print('Redirection vers la page principale après connexion GitHub.');
        }
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
              // Retour à la racine après la liaison réussie
              if (context.mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
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
    return BackgroundScaffold(
      appBar: AppBar(
        title: const Text("Connexion"),
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Titre avec fond transparent
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                  child: Text(
                    'Se connecter',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: ZenTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Sous-titre avec fond transparent
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                  child: Text(
                    'Choisissez votre méthode de connexion',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: ZenTheme.textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 48),
                
                // Bouton Google avec design amélioré
                ElevatedButton.icon(
                  onPressed: () async {
                  final cred = await signInWithGoogle(context: context);
                  if (cred != null && context.mounted) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                },
                icon: Image.asset(
                  'assets/logos/google_logo.png',
                  height: 24,
                ),
                label: const Text("Google"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ZenTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              const SizedBox(height: 16),
              
              // Bouton GitHub avec design amélioré
              ElevatedButton.icon(
                onPressed: () => signInWithGitHub(context),
                icon: Image.asset(
                  'assets/logos/github_logo.png',
                  height: 24,
                ),
                label: const Text("GitHub"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ZenTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Texte informatif zen
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Vos données de connexion sont sécurisées par Firebase Authentication',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}