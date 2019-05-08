import 'package:amplitude_flutter/src/client.dart';

class MockClient implements Client {
  MockClient({this.httpStatus: 200});

  @override
  String apiKey;
  int httpStatus;

  final List<dynamic> postCalls = <dynamic>[];

  @override
  Future<int> post(dynamic eventData) async {
    postCalls.add(eventData);
    return Future.value(httpStatus);
  }

  void reset() => postCalls.clear();

  int get postCallCount => postCalls.length;
}
