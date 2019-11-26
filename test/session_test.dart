import 'package:amplitude_flutter/src/session.dart';
import 'package:amplitude_flutter/src/time_utils.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockTimeUtils extends Mock implements TimeUtils {}

void main() {
  Session session;
  final TimeUtils time = MockTimeUtils();

  const int initialSessionId = 1;
  const int timeout = 100;
  const int activeTime = 50;
  const int expiredTime = 200;

  setUp(() {
    when(time.currentTime()).thenAnswer((_) => initialSessionId);

    session = Session.private(time, timeout);
  });

  test('refresh() keeps the current session if within timeout', () async {
    session.start();

    when(time.currentTime()).thenAnswer((_) => activeTime);

    session.refresh();
    expect(session.getSessionId(), initialSessionId.toString());
  });

  test('refresh() keeps the current session if in foreground', () async {
    session.start();

    when(time.currentTime()).thenAnswer((_) => expiredTime);

    expect(session.getSessionId(), initialSessionId.toString());
  });

  test('refresh() keeps the current session if resumed and within timeout',
      () async {
    session.start();

    when(time.currentTime()).thenAnswer((_) => activeTime);

    session.didChangeAppLifecycleState(AppLifecycleState.inactive);
    session.didChangeAppLifecycleState(AppLifecycleState.resumed);

    expect(session.getSessionId(), initialSessionId.toString());
  });

  test('refresh() resets the session if resumed and outside timeout', () async {
    session.start();

    when(time.currentTime()).thenAnswer((_) => expiredTime);

    session.didChangeAppLifecycleState(AppLifecycleState.inactive);
    session.didChangeAppLifecycleState(AppLifecycleState.resumed);

    expect(session.getSessionId(), expiredTime.toString());
  });
}
