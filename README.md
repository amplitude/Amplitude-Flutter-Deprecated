# amplitude_flutter

The Official Amplitude Flutter plugin.  Used to track events with [Amplitude](https://www.amplitude.com).

## Getting Started

To use this plugin, add `amplitude_flutter` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

Find the [API key](https://amplitude.zendesk.com/hc/en-us/articles/235649848-Settings#project-general-settings) for your Amplitude project under your project settings.

Import `package:amplitude_flutter/amplitude_flutter.dart`, and instantiate `AmplitudeFlutter` with your API key.

In addition, a [`Config`](https://github.com/amplitude/Amplitude-Flutter/blob/master/lib/src/config.dart) object can be passed as a constructor argument for additional options.

NOTE: This plugin's methods should only be called from the main isolate.

### Example

```dart
import 'package:amplitude_flutter/amplitude_flutter.dart';

Future<void> example() async {
  final AmplitudeFlutter analytics =  AmplitudeFlutter('API KEY');

  // set this user's id
  analytics.setUserId('abc123');

  // log an event
  analytics.logEvent(name: 'add_friend');

  // Log events with properties
  analytics.logEvent(name: 'add_friend', properties: { 'key': 'value' });

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
