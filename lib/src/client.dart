import 'dart:convert';
import 'package:crypto/crypto.dart' as crypto;
import 'package:http/http.dart' as http;

class Client {
  factory Client(String apiKey) {
    if (_instance != null) {
      return _instance;
    }
    _instance = Client._internal(apiKey);
    return _instance;
  }

  Client._internal(this.apiKey);

  static const String apiUrl = 'https://api.amplitude.com/';
  static const String apiVersion = '2';
  static Client _instance;

  final String apiKey;

  Future<void> post(List<Map<String, dynamic>> eventData) async {
    final String uploadTime = DateTime.now().millisecondsSinceEpoch.toString();
    final String events = json.encode(eventData);
    final String checksum = apiVersion + apiKey + events + uploadTime;
    final String md5 = crypto.md5.convert(utf8.encode(checksum)).toString();

    await http.post(apiUrl, body: <String, String>{
      'client': apiKey,
      'e': events,
      'v': apiVersion,
      'upload_time': uploadTime,
      'checksum': md5
    });
  }
}
