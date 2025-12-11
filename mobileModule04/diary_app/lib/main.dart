import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// Importez vos pages
import 'home_page.dart';
import 'profile_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mon Appli Auth',
      theme: ThemeData(primarySwatch: Colors.blue),
      // C'est ici que la magie opère :
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // 1. En attente de l'état
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          // 2. Utilisateur connecté (User? est non-null)
          if (snapshot.hasData && snapshot.data != null) {
            // Redirige vers la page de profil
            return const ProfilePage();
          } 
          
          // 3. Utilisateur déconnecté (User? est null)
          else {
            // Affiche la page d'accueil avec les boutons de connexion
            return const HomePage();
          }
        },
      ),
    );
  }
}