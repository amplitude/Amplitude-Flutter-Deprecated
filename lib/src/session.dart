import 'package:flutter/widgets.dart';
import './time_utils.dart';

class Session with WidgetsBindingObserver {
  factory Session(int timeout) {
    if (_instance != null) {
      return _instance;
    }
    _instance = Session._internal(timeout);
    return _instance;
  }

  Session._internal(this.timeout) {
    _time = TimeUtils();
    final widgetsBinding = WidgetsBinding.instance;
    if (widgetsBinding != null) {
      widgetsBinding.addObserver(this);
    }
  }

  @visibleForTesting
  Session.private(TimeUtils time, this.timeout) {
    _time = time;
  }

  static Session _instance;
  TimeUtils _time;

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
      case AppLifecycleState.detached:
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
