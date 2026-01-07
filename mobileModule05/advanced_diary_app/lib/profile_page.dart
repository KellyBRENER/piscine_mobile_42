import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'theme.dart';
import 'main.dart';
import 'utils.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _photoUrlWithCacheBuster;

  @override
  void initState() {
    super.initState();
    // Force le rafraîchissement des données utilisateur au montage
    _refreshUserData();
  }

  Future<void> _refreshUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.reload();
      // Récupère à nouveau l'utilisateur après reload
      final freshUser = FirebaseAuth.instance.currentUser;
      
      // Vide le cache de l'image en ajoutant un paramètre timestamp
      if (freshUser?.photoURL != null) {
        final photoUrl = freshUser!.photoURL!;
        // Ajoute un cache buster pour forcer le rechargement de l'image
        _photoUrlWithCacheBuster = '$photoUrl?t=${DateTime.now().millisecondsSinceEpoch}';
        
        // Évict l'ancienne image du cache
        if (photoUrl.isNotEmpty) {
          await Future.microtask(() {
            final imageProvider = NetworkImage(photoUrl);
            imageProvider.evict();
          });
        }
      }
      
      // Déclenche un rebuild pour afficher les nouvelles données
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return BackgroundScaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        elevation: 0,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshUserData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                /// Avatar + infos
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: ZenTheme.secondaryColor,
                        backgroundImage: _photoUrlWithCacheBuster != null
                            ? NetworkImage(_photoUrlWithCacheBuster!)
                            : (user?.photoURL != null ? NetworkImage(user!.photoURL!) : null),
                        child: user?.photoURL == null
                            ? Icon(Icons.person_outline,
                                size: 40, color: ZenTheme.primaryColor)
                            : null,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Bienvenue !',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user?.displayName ?? user?.email ?? 'Utilisateur',
                        style: Theme.of(context)
                            .textTheme
                            .displayLarge
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                /// Infos compte
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Informations de compte',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 16),
                        _infoTile(context, 'Email', user?.email ?? '—'),
                        const SizedBox(height: 12),
                        /*_infoTile(context, 'UID',
                            user?.uid.substring(0, 12) ?? '—'),*/
                      ],
                    ),
                  ),
                ),
                const DiariesEntries(),

                const SizedBox(height: 32),

                /// Déconnexion
                ElevatedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text('Déconnexion'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ZenTheme.errorColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () async {
                    await signOut();
                    if (context.mounted) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                  },
                ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoTile(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: ZenTheme.textLightColor)),
        const SizedBox(height: 4),
        Text(value,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: ZenTheme.primaryColor)),
      ],
    );
  }
}
