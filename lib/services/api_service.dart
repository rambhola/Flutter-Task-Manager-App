import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'https://dummyjson.com/quotes/random';

  Future<Map<String, dynamic>> fetchQuote() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'content': data['quote'],
          'author': data['author'],
        };
      } else {
        debugPrint('Status Code: ${response.statusCode}');
        throw Exception('Failed to load quote');
      }

    } catch (e) {
      debugPrint('Error fetching quote: $e');
      throw Exception('Error fetching quote: $e');
    }
  }
}
