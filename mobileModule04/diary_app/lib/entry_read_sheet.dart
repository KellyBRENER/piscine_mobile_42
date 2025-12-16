import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'moods.dart';

class EntryReadDialog extends StatelessWidget {
  final String entryId;
  final Map<String, dynamic> entryData;

  const EntryReadDialog({
    super.key,
    required this.entryId,
    required this.entryData,
  });

  @override
  Widget build(BuildContext context) {
    final moodKey = entryData['mood'] ?? 'neutre';
    final mood = moods.firstWhere(
      (m) => m.key == moodKey,
      orElse: () => moods.firstWhere((m) => m.key == 'neutre'),
    );

    final createdAt = entryData['createdAt'] as Timestamp?;
    final title = entryData['title'] ?? '';
    final content = entryData['content'] ?? '';

    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: mood.color,
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Text(mood.emoji, style: const TextStyle(fontSize: 32)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(title,
                          style: Theme.of(context).textTheme.titleLarge),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (createdAt != null)
                  Text(_formatDate(createdAt),
                      style: Theme.of(context).textTheme.bodySmall),

                const SizedBox(height: 24),

                Text(
                  content.isNotEmpty
                      ? content
                      : 'Aucun contenu pour cette entrée.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),

                const SizedBox(height: 32),

                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Fermer'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _formatDate(Timestamp timestamp) {
  final d = timestamp.toDate();
  return '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/${d.year}';
}
