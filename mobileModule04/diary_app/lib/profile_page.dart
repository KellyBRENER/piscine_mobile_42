import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    // Le StreamBuilder dans MyApp va détecter la déconnexion et rediriger vers HomePage
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Mon Profil")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Bonjour, ${user?.displayName ?? user?.email ?? 'Utilisateur'}!"),
            if (user?.photoURL != null) 
              CircleAvatar(
                backgroundImage: NetworkImage(user!.photoURL!),
                radius: 50,
              ),
            const SizedBox(height: 20),
            Text("UID: ${user?.uid}"),
            Text("Provider: ${user?.providerData.first.providerId}"),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: signOut,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Déconnexion"),
            ),
          ],
        ),
      ),
    );
  }
}