#import "AmplitudeFlutterPlugin.h"

@implementation AmplitudeFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"amplitude_flutter"
            binaryMessenger:[registrar messenger]];
  AmplitudeFlutterPlugin* instance = [[AmplitudeFlutterPlugin alloc] init];

  [[Amplitude instance] initializeApiKey:@"API_KEY"];

  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"logEvent" isEqualToString:call.method]) {
    NSString *eventName = call.arguments[@"name"];
    [[Amplitude instance] logEvent:eventName];
    result(nil);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
