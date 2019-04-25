import 'package:amplitude_flutter/src/client.dart';

class MockClient implements Client {
  @override
  String apiKey;

  final List<dynamic> postCalls = <dynamic>[];

  @override
  Future<bool> post(dynamic eventData) async {
    postCalls.add(eventData);
    return Future.value(true);
  }

  void reset() => postCalls.clear();

  int get postCallCount => postCalls.length;
}
