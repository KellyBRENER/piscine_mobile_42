
import 'package:flutter/material.dart';

class Mood {
  final String key;
  final String label;
  final String emoji;
  final Color color;

  const Mood(this.key, this.label, this.emoji, this.color);
}

const moods = [
  Mood('heureux', 'Heureux', '😊', Color.fromARGB(255, 237, 228, 149)),
  Mood('amoureux', 'Amoureux', '😍', Color.fromARGB(255, 221, 111, 148)),
  Mood('calme', 'Calme', '😌', Color.fromARGB(255, 190, 233, 140)),
  Mood('neutre', 'Neutre', '😐', Color.fromARGB(255, 209, 212, 214)),
  Mood('stressé', 'Stressé', '😰', Color.fromARGB(255, 146, 124, 145)),
  Mood('triste', 'Triste', '😢', Color.fromARGB(255, 93, 141, 204)),
  Mood('énervé', 'Énervé', '😡', Color.fromARGB(255, 214, 91, 91)),
];

Color moodColor(String moodKey) {
  return moods
          .firstWhere(
            (m) => m.key == moodKey,
            orElse: () => moods[3],
          )
          .color;
}



class _MoodSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _MoodSelector({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      children: moods.map((mood) {
        final isSelected = mood.key == selected;
        return ChoiceChip(
          label: Text('${mood.emoji} ${mood.label}'),
          selected: isSelected,
          onSelected: (_) => onChanged(mood.key),
        );
      }).toList(),
    );
  }
}
