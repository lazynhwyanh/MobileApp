import 'package:flutter/material.dart';
import 'exercise_menu_page.dart';

class ExerciseLevelSelector extends StatelessWidget {
  final List<String> levels = ['N5', 'N4', 'N3', 'N2', 'N1'];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: levels.length,
      itemBuilder: (context, index) {
        final level = levels[index];
        return Card(
          child: ListTile(
            title: Text('Trình độ $level'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ExerciseMenuPage(level: level),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
