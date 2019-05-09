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
