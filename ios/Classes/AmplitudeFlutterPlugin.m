#import "AmplitudeFlutterPlugin.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <sys/utsname.h>

@implementation AmplitudeFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel methodChannelWithName:@"amplitude_flutter"
                                                              binaryMessenger:[registrar messenger]];
  AmplitudeFlutterPlugin* instance = [[AmplitudeFlutterPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"carrierName" isEqualToString:call.method]) {
    NSString *strNative = [self carrierName];
    result(strNative);
  } else if ([@"deviceModel" isEqualToString:call.method]) {
    NSString *strNative = [self deviceName];
    result(strNative);
  } else if ([@"preferredLanguages" isEqualToString:call.method]) {
    result([NSLocale preferredLanguages]);
  } else if ([@"currentLocale" isEqualToString:call.method]){
    NSString *locale = [[NSLocale currentLocale] objectForKey: NSLocaleCountryCode];
    NSString *language = [[NSLocale currentLocale] objectForKey: NSLocaleLanguageCode];
    NSString *formattedStr = [NSString stringWithFormat:@"%@-%@",language, locale];
    result(formattedStr);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (NSString*)carrierName {
  CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
  CTCarrier *carrier = [netinfo subscriberCellularProvider];
  NSString* name = [carrier carrierName];
  if (name != nil) {
    return name;
  } else {
    return @"SIM State not available";
  }
}

- (NSString*)deviceName{
  struct utsname systemInfo;
  uname(&systemInfo);

  return [NSString stringWithCString:systemInfo.machine
          encoding:NSUTF8StringEncoding];
}
@end
