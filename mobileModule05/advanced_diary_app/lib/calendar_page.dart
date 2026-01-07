import 'package:flutter/material.dart';
import 'main.dart';
import 'theme.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      appBar: AppBar(
        title: const Text('Calendrier'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Vue calendrier',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  border: Border.all(
                    color: ZenTheme.primaryColor.withValues(alpha: 0.2),
                  ),
                ),
                child: const Text(
                  'Contenu du calendrier à venir (planning, entrées par jour, etc.).',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
