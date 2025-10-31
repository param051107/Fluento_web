import 'dart:math';
import 'suggestion_database.dart';

List<String> getOfflineSuggestions(String message) {
  // Clean text (lowercase, remove punctuation)
  message = message.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');

  List<String> matchedSuggestions = [];

  for (var entry in suggestionDatabase) {
    for (var keyword in entry["keywords"]) {
      String cleanKeyword = keyword.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');
      if (message.contains(cleanKeyword)) {
        matchedSuggestions.addAll(List<String>.from(entry["suggestions"]));
        break; // stop checking more keywords in this group
      }
    }
  }

  // If no match found → return default suggestions
  if (matchedSuggestions.isEmpty) {
    matchedSuggestions = ["yes", "no", "good", "not now"];
  }

  matchedSuggestions.shuffle(Random());
  return matchedSuggestions.take(4).toList();
}
