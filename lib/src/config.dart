class Config {
  Config({
    this.sessionTimeout = defaultSessionTimeout,
    this.bufferSize = defaultBufferSize,
    this.maxStoredEvents = defaultMaxStoredEvents,
    this.flushPeriod = defaultFlushPeriod,
    this.optOut = false,
    this.getCarrierInfo = false,
  });

  final int sessionTimeout;
  final int bufferSize;
  final int maxStoredEvents;
  final int flushPeriod;
  final bool optOut;
  final bool getCarrierInfo;

  static const defaultSessionTimeout = 300000;
  static const defaultBufferSize = 10;
  static const defaultMaxStoredEvents = 1000;
  static const defaultFlushPeriod = 30;
}
