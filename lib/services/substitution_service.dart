import '../models/word_entry.dart';

class SubstitutionService {
  /// Replaces words in [text] based on the [dictionaryMap].
  /// [dictionaryMap] keys should be lowercased words.
  String processText(
    String text,
    Map<String, WordEntry> dictionaryMap, {
    bool showTranslation = true,
    bool showPronunciation = true,
  }) {
    if (dictionaryMap.isEmpty || text.isEmpty) return text;

    // Regex to match words.
    // We use unicode property \p{L} to match any letter in any language (including accents).
    final RegExp wordRegExp = RegExp(
      r"([\p{L}]+)",
      unicode: true,
      caseSensitive: false,
    );

    return text.replaceAllMapped(wordRegExp, (match) {
      final String originalWord = match.group(0)!;
      final String lowerWord = originalWord.toLowerCase();

      if (dictionaryMap.containsKey(lowerWord)) {
        final entry = dictionaryMap[lowerWord]!;

        if (showTranslation && showPronunciation) {
          return "${entry.translation} (${entry.pronunciation})";
        } else if (showTranslation) {
          return entry.translation;
        } else if (showPronunciation) {
          return entry.pronunciation;
        } else {
          // If both are disabled, show the original word?
          // Or maybe show nothing?
          // Usually if you toggle translation ON, you expect *something*.
          // But if you uncheck both sub-toggles, maybe you just want the original text?
          // Let's return original word if both are off, effectively disabling translation for this word.
          return originalWord;
        }
      }

      return originalWord;
    });
  }
}
