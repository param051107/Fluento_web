import 'package:flutter/material.dart';

class SuggestionChips extends StatelessWidget {
  final ValueNotifier<List<String>> suggestionsNotifier;
  final Function(String) onSuggestionSelected;

  const SuggestionChips({
    super.key,
    required this.suggestionsNotifier,
    required this.onSuggestionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<String>>(
      valueListenable: suggestionsNotifier,
      builder: (context, suggestions, child) {
        if (suggestions.isEmpty) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: const Color(0xFF1C1C1E),
          child: Wrap(
            spacing: 8,
            children: suggestions.map((suggestion) {
              return ActionChip(
                label: Text(
                  suggestion,
                  style: const TextStyle(color: Color(0xFFFFFFFF)),
                ),
                backgroundColor: const Color(0xFF2C2C2E),
                onPressed: () => onSuggestionSelected(suggestion),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
