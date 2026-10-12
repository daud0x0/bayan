/// Arabic text processing utilities for diacritic stripping and normalization.
/// Complies with Section 10 of the Product Plan.
class ArabicUtils {
  ArabicUtils._();

  /// Regular expression matching Arabic Tashkeel (harakat / diacritics).
  /// Includes fathah, dammah, kasrah, sukun, shaddah, tanween, and Quranic recitation marks.
  static final RegExp _tashkeelRegex = RegExp(
    r'[\u064B-\u0652\u0657-\u065F\u0670\u06D6-\u06ED]',
    unicode: true,
  );

  /// Strips Arabic diacritics (harakat) for flexible text search without altering original source text.
  static String stripTashkeel(String input) {
    return input.replaceAll(_tashkeelRegex, '');
  }

  /// Normalizes Arabic characters for tolerant search matching:
  /// - Strips diacritics
  /// - Unifies forms of Alif (أ, إ, آ, ٱ -> ا)
  /// - Normalizes Taa Marbuta (ة -> ه)
  /// - Normalizes Alif Maqsurah (ى -> ي)
  static String normalizeForSearch(String input) {
    var text = stripTashkeel(input);
    text = text.replaceAll(RegExp(r'[أإآٱ]'), 'ا');
    text = text.replaceAll('ة', 'ه');
    text = text.replaceAll('ى', 'ي');
    return text.trim().toLowerCase();
  }

  /// Checks if search query is found in the target Arabic or English string.
  static bool containsNormalized(String source, String query) {
    if (query.trim().isEmpty) return true;
    final normalizedSource = normalizeForSearch(source);
    final normalizedQuery = normalizeForSearch(query);
    return normalizedSource.contains(normalizedQuery);
  }
}
