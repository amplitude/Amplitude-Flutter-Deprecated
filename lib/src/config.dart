class Config {
  Config(
      {this.sessionTimeout = defaultSessionTimeout,
      this.bufferSize = defaultBufferSize,
      this.flushPeriod = defaultFlushPeriod});

  final int sessionTimeout;
  final int bufferSize;
  final int flushPeriod;

  static const defaultSessionTimeout = 300000;
  static const defaultBufferSize = 10;
  static const defaultFlushPeriod = 30;
}
