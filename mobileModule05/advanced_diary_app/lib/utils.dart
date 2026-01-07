import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'moods.dart';
import 'create_entry_sheet.dart';
import 'entry_read_sheet.dart';

/// Widget réutilisable pour afficher les entrées du journal
/// 
/// Si [filterDate] est null: affiche les 2 dernières entrées
/// Si [filterDate] est fournie: affiche toutes les entrées de ce jour
class DiariesEntries extends StatelessWidget {
  final DateTime? filterDate;
  final bool showAddButton;
  final bool showMoodStats;

  const DiariesEntries({
    super.key,
    this.filterDate,
    this.showAddButton = true,
    this.showMoodStats = true,
  });

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

  /// Filtre les documents selon la date si fournie
  List<QueryDocumentSnapshot> _filterDocsByDate(List<QueryDocumentSnapshot> docs) {
    if (filterDate == null) {
      // Pas de filtre: retourne les 2 premiers (déjà triés desc)
      return docs.length > 2 ? docs.sublist(0, 2) : docs;
    }

    // Filtre par date: garde uniquement les entrées du jour sélectionné
    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['createdAt'] == null) return false;

      final timestamp = data['createdAt'] as Timestamp;
      final entryDate = timestamp.toDate();

      return entryDate.year == filterDate!.year &&
          entryDate.month == filterDate!.month &&
          entryDate.day == filterDate!.day;
    }).toList();
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

            final allDocs = snapshot.data!.docs;
            final filteredDocs = _filterDocsByDate(allDocs);

            // Stats globales (sur toutes les entrées)
            final total = allDocs.length;
            final Map<String, int> counts = {for (final m in moods) m.key: 0};
            for (final d in allDocs) {
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
                        filterDate == null
                            ? '$total entrées'
                            : 'Entrées du ${filterDate!.day.toString().padLeft(2, '0')}/${filterDate!.month.toString().padLeft(2, '0')}/${filterDate!.year}',
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (showAddButton)
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
                if (filteredDocs.isEmpty)
                  Text(
                    filterDate == null
                        ? 'Aucune entrée pour le moment.\nClique sur + pour en créer une.'
                        : 'Aucune entrée pour cette date.',
                    textAlign: TextAlign.center,
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredDocs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final doc = filteredDocs[index];
                      final data = doc.data() as Map<String, dynamic>;

                      final moodKey = data['mood'] ?? 'neutre';
                      final mood = moods.firstWhere(
                        (m) => m.key == moodKey,
                        orElse: () =>
                            moods.firstWhere((m) => m.key == 'neutre'),
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
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
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
                if (showMoodStats && filterDate == null) ...[
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
                            const Text(
                                'Aucune donnée disponible pour l\'instant.')
                          else
                            Column(
                              children: [
                                for (final m in moods)
                                  Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 6),
                                    child: Row(
                                      children: [
                                        Text(m.emoji,
                                            style:
                                                const TextStyle(fontSize: 22)),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            '${(((counts[m.key] ?? 0) / total) * 100).round()} %',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge,
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

Future<bool?> _confirmDelete(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Supprimer l\'entrée'),
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
