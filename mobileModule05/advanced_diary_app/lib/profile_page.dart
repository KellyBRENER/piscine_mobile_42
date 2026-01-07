import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'theme.dart';
import 'create_entry_sheet.dart';
import 'entry_read_sheet.dart';
import 'moods.dart';
import 'main.dart';

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

/// ----------------------
/// ENTRIES
/// ----------------------

class DiariesEntries extends StatelessWidget {
  const DiariesEntries({super.key});

  Future<void> _ensureUserEmailStored(User user) async {
    if (user.email != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
            'email': user.email,
          }, SetOptions(merge: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    // Stocker l'email de l'utilisateur s'il n'est pas déjà présent
    _ensureUserEmailStored(user);

    final entriesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('entries')
        .orderBy('createdAt', descending: true);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StreamBuilder<QuerySnapshot>(
          stream: entriesRef.snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs;

            // Prépare les stats d'utilisation des humeurs
            final total = docs.length;
            final Map<String, int> counts = { for (final m in moods) m.key: 0 };
            for (final d in docs) {
              final data = d.data() as Map<String, dynamic>;
              final key = (data['mood'] as String?) ?? 'neutre';
              if (counts.containsKey(key)) {
                counts[key] = (counts[key] ?? 0) + 1;
              }
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        '${docs.length} entrées',
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => const CreateEntryDialog(),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (docs.isEmpty)
                  const Text(
                    'Aucune entrée pour le moment.\nClique sur + pour en créer une.',
                    textAlign: TextAlign.center,
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: docs.length > 2 ? 2 : docs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                final doc = docs[index];
                final data = doc.data() as Map<String, dynamic>;

                final moodKey = data['mood'] ?? 'neutre';
                final mood = moods.firstWhere(
                  (m) => m.key == moodKey,
                  orElse: () => moods.firstWhere((m) => m.key == 'neutre'),
                );

                return Card(
                  color: mood.color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: Text(mood.emoji,
                        style: const TextStyle(fontSize: 28)),
                    title: Text(data['title'] ?? 'Sans titre',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: data['createdAt'] != null
                        ? Text(_formatDate(data['createdAt']))
                        : null,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () async {
                        final confirm = await _confirmDelete(context);
                        if (confirm == true) {
                          await doc.reference.delete();
                        }
                      },
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => EntryReadDialog(
                          entryId: doc.id,
                          entryData: data,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Répartition des humeurs',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        if (total == 0)
                          const Text('Aucune donnée disponible pour l’instant.')
                        else
                          Column(
                            children: [
                              for (final m in moods)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  child: Row(
                                    children: [
                                      Text(m.emoji, style: const TextStyle(fontSize: 22)),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          '${(((counts[m.key] ?? 0) / total) * 100).round()} %',
                                          style: Theme.of(context).textTheme.bodyLarge,
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// ----------------------
/// HELPERS
/// ----------------------

String _formatDate(Timestamp timestamp) {
  final d = timestamp.toDate();
  return '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/${d.year}';
}

// Removed standalone MoodUsageCard; integrated stats inside DiariesEntries

Future<bool?> _confirmDelete(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Supprimer l’entrée'),
      content: const Text('Cette action est définitive.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Supprimer'),
        ),
      ],
    ),
  );
}
