import 'package:flutter_test/flutter_test.dart';

import 'package:amplitude_flutter/src/event.dart';
import 'package:amplitude_flutter/src/event_buffer.dart';

import 'matchers.dart';
import 'mock_client.dart';

void main() {
  group('EventBuffer', () {
    EventBuffer subject;
    MockClient client;

    setUp(() {
      client = MockClient();
      subject = EventBuffer(client);
    });

    group('.length', () {
      test('returns the length of events in the store', () {
        expect(subject.length, equals(0));

        subject.add(Event('event 1'));
        expect(subject.length, equals(1));

        subject.add(Event('event 2'));
        expect(subject.length, equals(2));
      });
    });

    group('.add', () {
      test('adds an event to the store, and adds a timestamp property', () {
        subject.add(Event('event 1'));
        expect(subject.length, equals(1));

        final List<Event> events = subject.dequeue(1);
        final Event event = events[0];

        expect(event.timestamp, isInstanceOf<int>());
      });

      test('flushes the buffer when the buffer size is reached', () {
        subject = EventBuffer(client, size: 2);

        subject.add(Event('flush test'));
        expect(client.postCallCount, equals(0));

        subject.add(Event('event 2'));
        expect(client.postCallCount, equals(1));
        expect(subject.length, equals(0));

        expect(
            client.postCalls.single.first,
            ContainsSubMap(<String, dynamic>{
              'event_type': 'flush test',
              'timestamp': isInstanceOf<int>()
            }));
        expect(client.postCalls.single, isList);
      });
    });

    group('.dequeue', () {
      test('removes a specified number of the oldest events in the store', () {
        expect(subject.length, equals(0));

        subject.add(Event('event 1'));
        subject.add(Event('event 2'));
        subject.add(Event('event 3'));
        expect(subject.length, equals(3));

        final List<Event> firstTwoEvents = subject.dequeue(2);
        expect(firstTwoEvents.length, equals(2));
        expect(firstTwoEvents[0].name, equals('event 1'));
        expect(firstTwoEvents[1].name, equals('event 2'));

        final List<Event> lastEvent = subject.dequeue(1);
        expect(lastEvent.length, equals(1));
        expect(lastEvent[0].name, equals('event 3'));

        expect(subject.length, equals(0));
      });

      test('works with numbers greater than the event count', () {
        subject.add(Event('event 1'));
        subject.add(Event('event 2'));
        expect(subject.length, equals(2));

        final List<Event> poppedEvents = subject.dequeue(100);
        expect(poppedEvents.length, equals(2));
      });
    });
  });
}
