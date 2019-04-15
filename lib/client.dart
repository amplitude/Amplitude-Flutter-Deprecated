import 'dart:convert';
import 'package:crypto/crypto.dart' as crypto;
import 'package:http/http.dart' as http;

class Client {
  static const String apiUrl = 'https://api.amplitude.com/';
  static const String apiVersion = '2';
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
    String uploadTime = DateTime.now().millisecondsSinceEpoch.toString();
    String events = json.encode(data);
    String checksum = apiVersion + apiKey + events + uploadTime;
    String md5 = crypto.md5.convert(utf8.encode(checksum)).toString();

    await http.post(apiUrl, body: {
      'client': apiKey,
      'e': events,
      'v': apiVersion,
      'upload_time': uploadTime,
      'checksum': md5
    });
  }
}