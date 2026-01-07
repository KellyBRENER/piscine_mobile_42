import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// Importez vos pages
import 'login_page.dart';
import 'profile_page.dart';
import 'theme.dart';

// Widget réutilisable pour le fond avec transparence
class BackgroundScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final double opacity;

  const BackgroundScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.opacity = 0.7,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fond d'écran
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/images/nature.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.white.withValues(alpha: opacity),
                  BlendMode.lighten,
                ),
              ),
            ),
          ),
          // Contenu
          body,
        ],
      ),
    );
  }
}

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
      theme: ZenTheme.theme,
      // C'est ici que la magie opère :
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
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
            return BackgroundScaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Titre stylisé avec fond transparent
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.85),
                          border: Border.all(
                            color: ZenTheme.primaryColor.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '✨',
                              style: const TextStyle(fontSize: 32),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Bienvenue',
                              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                color: ZenTheme.primaryColor,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.5,
                                fontStyle: FontStyle.italic,
                                fontFamily: 'Georgia',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Sous-titre avec fond transparent
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                        child: Text(
                          'Connectez-vous pour accéder à votre journal',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: ZenTheme.textColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 48),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const LoginPage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.login_outlined),
                        label: const Text("Se connecter"),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        }
    );
  }
}