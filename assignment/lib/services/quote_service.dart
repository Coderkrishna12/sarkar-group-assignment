import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service class for fetching motivational quotes from a REST API.
/// Uses GET https://api.quotable.io/random as specified.
class QuoteService {
  static const String _baseUrl = 'https://api.quotable.io/random';

  /// Fetches a random motivational quote from the API.
  /// Returns a map with 'content' and 'author' keys.
  /// Throws an exception if the request fails.
  static Future<Map<String, String>> fetchRandomQuote() async {
    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
      ).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return {
          'content': data['content'] ?? '',
          'author': data['author'] ?? 'Unknown',
        };
      } else {
        throw Exception('Failed to load quote: HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Could not load quote: $e');
    }
  }
}
