import 'package:amplitude_flutter/src/event_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EventStore', () {
    EventStore subject;

    setUp(() {
      subject = EventStore();
    });

    group('.length', () {
      test('returns the length of events in the store', () {
        expect(subject.length, equals(0));

        subject.enqueue(<String, dynamic>{'name': 'event 1'});
        expect(subject.length, equals(1));

        subject.enqueue(<String, dynamic>{'name': 'event 2'});
        expect(subject.length, equals(2));
      });
    });

    group('.enqueue', () {
      test('adds an event to the store, and adds a timestamp property', () {
        subject.enqueue(<String, dynamic>{'name': 'event 1'});
        expect(subject.length, equals(1));

        final List<Map<String, dynamic>> events = subject.dequeue(1);
        final Map<String, dynamic> event = events[0];

        expect(event['timestamp'], isInstanceOf<int>());
      });
    });

    group('.pop', () {
      test('removes a specified number of the oldest events in the store', () {
        expect(subject.length, equals(0));

        subject.enqueue(<String, dynamic>{'name': 'event 1'});
        subject.enqueue(<String, dynamic>{'name': 'event 2'});
        subject.enqueue(<String, dynamic>{'name': 'event 3'});
        expect(subject.length, equals(3));

        final List<Map<String, dynamic>> firstTwoEvents = subject.dequeue(2);
        expect(firstTwoEvents.length, equals(2));
        expect(firstTwoEvents[0]['name'], equals('event 1'));
        expect(firstTwoEvents[1]['name'], equals('event 2'));

        final List<Map<String, dynamic>> lastEvent = subject.dequeue(1);
        expect(lastEvent.length, equals(1));
        expect(lastEvent[0]['name'], equals('event 3'));

        expect(subject.length, equals(0));
      });

      test('works with numbers greater than the event count', () {
        subject.enqueue(<String, dynamic>{'name': 'event 1'});
        subject.enqueue(<String, dynamic>{'name': 'event 2'});
        expect(subject.length, equals(2));

        final List<Map<String, dynamic>> poppedEvents = subject.dequeue(100);
        expect(poppedEvents.length, equals(2));
      });
    });
  });
}
