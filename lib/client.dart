import 'dart:convert';
import 'package:http/http.dart' as http;

class Client {
  static const String apiUrl = 'https://api.amplitude.com/httpapi';
  static Client _instance;

  final String apiKey;

  factory Client(String apiKey) {
    if(_instance != null) {
      return _instance;
    }
    _instance = Client._internal(apiKey);
    return _instance;
  }

  Client._internal(this.apiKey);

  Future<void> post(data) async {
    await http.post(apiUrl, body: {
      'api_key': apiKey,
      'event': json.encode(data)
    });
  }
}