## 1.1.5
* Include `language` property when reporting events.

## 1.1.4
* Updated to use androidx for Android.

## 1.1.3
* Fix a problem that dart documentation can't be generated on pub.dev

## 1.1.2
* Made changes to support the new Android plugins API (>= 1.12 Flutter SDK).
* Updated Android example application with v2 Android embedding.

## 1.1.1
* Migrated from AppLifecycleState.suspending to AppLifecycleState.detached. Cause suspending is 
deprecated. Thanks @otopba for fixing it.
* Fixed the possible crash while other permission is requested by other libraries.

## 1.1.0
* add `device_manufacturer` info
* add ability to retrieve carrier info
* add config option to turn on and off retrieving carrier info

## 1.0.1

* Wait for device info to be available before sending events

## 1.0.0

* Send event_id with payloads
* Add application version to events
* Limit stored events

## 0.2.0

* Add setUserId()
* Add a sequence_id sent with events
* Config option to opt out of tracking
* Example app changes

## 0.1.0

* Adds revenue tracking.
* Catch errors from platform channels.

## 0.0.2

* Fixes bug where default session timeout was not set.
* Persist events to sqlite database.
* Refactor to use service provider class to simplify dependency injection in test.
* Add group identify functionality.
* Retry posting events.
* Flush event buffer every 30s.
* Retry posting events when payload is too large.
* Include uuid for events.
* Include library version for events.

## 0.0.1+1

* Fixes serialization bug preventing events from sending.

## 0.0.1

* Implements logEvent and identify functionality.
