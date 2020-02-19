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
    } else if ([@"preferredLanguages" isEqualToString:call.method]) {
        result([NSLocale preferredLanguages]);
    } else if ([@"currentLocale" isEqualToString:call.method]){
        NSString *locale = [[NSLocale currentLocale] objectForKey: NSLocaleCountryCode];
        NSString *language = [[NSLocale currentLocale] objectForKey: NSLocaleLanguageCode];
        NSString *formattedStr = [NSString stringWithFormat:@"%@-%@",language, locale];
        result(formattedStr);
    } else if ([@"advertisingId" isEqualToString:call.method]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSString *advId = [self advertisingId];
            dispatch_async(dispatch_get_main_queue(), ^(void){
                result(advId);
            });
        });
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

- (NSString*)advertisingId {
    // TODO: Might be able to remove try/catch later.
    @try {
        Class ASIdentifierManagerClass = NSClassFromString(@"ASIdentifierManager");
        if (ASIdentifierManagerClass) {
            SEL sharedManagerSelector = NSSelectorFromString(@"sharedManager");
            id sharedManager = ((id (*)(id, SEL))[ASIdentifierManagerClass methodForSelector:sharedManagerSelector])(ASIdentifierManagerClass, sharedManagerSelector);
            SEL advertisingTrackingEnabledSelector = NSSelectorFromString(@"isAdvertisingTrackingEnabled");
            BOOL isTrackingEnabled = ((BOOL (*)(id, SEL))[sharedManager methodForSelector:advertisingTrackingEnabledSelector])(sharedManager, advertisingTrackingEnabledSelector);
            if (isTrackingEnabled) {
                SEL advertisingIdentifierSelector = NSSelectorFromString(@"advertisingIdentifier");
                NSUUID *uuid = ((NSUUID* (*)(id, SEL))[sharedManager methodForSelector:advertisingIdentifierSelector])(sharedManager, advertisingIdentifierSelector);
                NSString *uuidString = [uuid UUIDString];
                
                if (uuidString != nil &&
                    // On simulator, it will give you all 0s.
                    ![uuidString isEqualToString:@"00000000-0000-0000-0000-000000000000"]) {
                    return uuidString;
                }
            }
        }
        return nil;
    }
    @catch (NSException *e) {
        return nil;
    }
}

@end
