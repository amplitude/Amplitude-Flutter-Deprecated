class Config {
  Config(
      {this.sessionTimeout = defaultSessionTimeout,
      this.bufferSize = defaultBufferSize,
      this.flushPeriod = defaultFlushPeriod,
      this.optOut = false});

  final int sessionTimeout;
  final int bufferSize;
  final int flushPeriod;
  final bool optOut;

  static const defaultSessionTimeout = 300000;
  static const defaultBufferSize = 10;
  static const defaultFlushPeriod = 30;
}
