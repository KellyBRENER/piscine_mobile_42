import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'moods.dart';

class CreateEntryDialog extends StatefulWidget {
  const CreateEntryDialog({super.key});

  @override
  State<CreateEntryDialog> createState() => _CreateEntryDialogState();
}

class _CreateEntryDialogState extends State<CreateEntryDialog> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _mood = 'neutre';
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) return;

    setState(() => _isSaving = true);

    final user = FirebaseAuth.instance.currentUser!;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('entries')
        .add({
          'title': _titleController.text.trim(),
          'content': _contentController.text.trim(),
          'mood': _mood,
          'createdAt': FieldValue.serverTimestamp(),
        });

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Nouvelle entrée',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 24),

                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Titre'),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _contentController,
                  maxLines: 6,
                  decoration: const InputDecoration(labelText: 'Contenu'),
                ),
                const SizedBox(height: 16),

                Wrap(
                  spacing: 8,
                  children: moods.map((m) {
                    return ChoiceChip(
                      label: Text('${m.emoji} ${m.label}'),
                      selected: _mood == m.key,
                      onSelected: (_) => setState(() => _mood = m.key),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  child: const Text('Enregistrer'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
