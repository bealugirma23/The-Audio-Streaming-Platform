import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryService {
  static const _key = 'search_history';

  Future<List<String>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  Future<void> addSearchTerm(String term) async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_key) ?? [];

    if (history.contains(term)) {
      history.remove(term); // Move to front
    }
    history.insert(0, term);

    // Limit to 10 items
    if (history.length > 10) history.removeLast();

    await prefs.setStringList(_key, history);
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
