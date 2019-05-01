# amplitude_flutter

A Flutter plugin for tracking events to [Amplitude](https://www.amplitude.com).

## Usage

To use this plugin, add `amplitude_flutter` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

Import package:amplitude_flutter/amplitude_flutter.dart, and instantiate AmplitudeFlutter with your `API_KEY`.

### Example

```dart
import 'package:amplitude_flutter/amplitude_flutter.dart';

Future<void> example() async {
  final AmplitudeFlutter analytics =  AmplitudeFlutter('API KEY');

  // set this user's id
  analytics.setUserId('abc123');

  // log an event
  analytics.logEvent(name: 'Dart Click');

  // Log events with properties
  analytics.logEvent(name: 'Dart Click', properties: { 'key': 'value' });

  // identify a user
  final Identify identify = Identify()
    ..set('cohort', 'Test A')
    ..setOnce('completed_onboarding', 'true')
    ..add('login_count', 1)
    ..append('tags', 'new tag')
    ..unset('demo_user');

  analytics.identify(identify);

  // Amplitude Accounts [https://amplitude.zendesk.com/hc/en-us/articles/115001765532-Accounts] methods:
  // add a user to a group
  analytics.setGroup('orgId', 15);

  // change properties of a group
  analytics.groupIdentify('orgId', 15, Identify()..set('account_manager', 456));

  // emit an event associated with a group
  analytics.logEvent('Demo Released', properties: { 'groups': { 'orgId': 15 } });

  // Log revenue
  final Revenue revenue = Revenue()
    ..setPrice(23.23)
    ..setQuantity(3)
    ..setProductId('widget1')

  analytics.logRevenue(revenue);
}
```

## Getting Started

For help getting started with Flutter, view our online
[documentation](http://flutter.io/).

For help on editing plugin code, view the [documentation](https://flutter.io/platform-plugins/#edit-code).
