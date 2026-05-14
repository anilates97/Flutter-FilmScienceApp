class TmdbConfig {
  static const apiKey = String.fromEnvironment('TMDB_API_KEY');

  static bool get hasApiKey => apiKey.trim().isNotEmpty;

  static void validate() {
    if (!hasApiKey) {
      throw StateError(
        'Missing TMDB API key. Run with --dart-define=TMDB_API_KEY=your_key.',
      );
    }
  }
}
