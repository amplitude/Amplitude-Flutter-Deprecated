import 'package:flutter/widgets.dart';
import './time_utils.dart';

class Session with WidgetsBindingObserver {
  factory Session({int timeout = defaultTimeout}) {
    if (_instance != null) {
      return _instance;
    }
    _instance = Session._internal(timeout);
    return _instance;
  }

  Session._internal(this.timeout) {
    _time = TimeUtils();
    WidgetsBinding.instance.addObserver(this);
  }

  @visibleForTesting
  Session.private(TimeUtils time, this.timeout) {
    _time = time;
  }

  static Session _instance;
  TimeUtils _time;

  static const int defaultTimeout = 300000;
  int timeout;
  int sessionStart;
  int lastActivity;
  bool _inForeground = true;

  void start() {
    sessionStart = _time.currentTime();
    lastActivity = sessionStart;
  }

  String getSessionId() {
    return sessionStart.toString();
  }

  void refresh() {
    final int now = _time.currentTime();
    if (!_withinSession(now)) {
      sessionStart = now;
    }
    lastActivity = now;
  }

  void enterBackground() {
    _inForeground = false;
  }

  void exitBackground() {
    _inForeground = true;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.suspending:
        enterBackground();
        break;
      case AppLifecycleState.resumed:
        refresh();
        exitBackground();
        break;
      default:
    }
  }

  bool _withinSession(int timestamp) {
    if (lastActivity != null && !_inForeground) {
      return (timestamp - lastActivity) < timeout;
    }
    return true;
  }
}
