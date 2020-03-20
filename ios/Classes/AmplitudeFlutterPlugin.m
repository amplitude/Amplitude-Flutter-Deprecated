#import "AmplitudeFlutterPlugin.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <sys/utsname.h>
#import <sys/sysctl.h>
#import <sys/types.h>

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
        NSString *advId = [self advertisingId];
        result(advId);
    } else if ([@"deviceModel" isEqualToString:call.method]) {
        NSString *deviceModel = [self deviceModel];
        result(deviceModel);
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

- (NSString*)getPlatformString {
    const char *sysctl_name = "hw.machine";
    size_t size;
    sysctlbyname(sysctl_name, NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname(sysctl_name, machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    return platform;
}

- (NSString*)deviceModel {
    NSString *platform = [self getPlatformString];
    // == iPhone ==
    // iPhone 1
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1";
    // iPhone 3
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    // iPhone 4
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    // iPhone 5
    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,3"])    return @"iPhone 5c";
    if ([platform isEqualToString:@"iPhone5,4"])    return @"iPhone 5c";
    if ([platform isEqualToString:@"iPhone6,1"])    return @"iPhone 5s";
    if ([platform isEqualToString:@"iPhone6,2"])    return @"iPhone 5s";
    // iPhone 6
    if ([platform isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([platform isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([platform isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([platform isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([platform isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
    // iPhone 7
    if ([platform isEqualToString:@"iPhone9,1"])    return @"iPhone 7";
    if ([platform isEqualToString:@"iPhone9,2"])    return @"iPhone 7 Plus";
    if ([platform isEqualToString:@"iPhone9,3"])    return @"iPhone 7";
    if ([platform isEqualToString:@"iPhone9,4"])    return @"iPhone 7 Plus";
    // iPhone 8
    if ([platform isEqualToString:@"iPhone10,1"])    return @"iPhone 8";
    if ([platform isEqualToString:@"iPhone10,4"])    return @"iPhone 8";
    if ([platform isEqualToString:@"iPhone10,2"])    return @"iPhone 8 Plus";
    if ([platform isEqualToString:@"iPhone10,5"])    return @"iPhone 8 Plus";
    
    // iPhone X
    if ([platform isEqualToString:@"iPhone10,3"])    return @"iPhone X";
    if ([platform isEqualToString:@"iPhone10,6"])    return @"iPhone X";
    
    // iPhone XS
    if ([platform isEqualToString:@"iPhone11,2"])    return @"iPhone XS";
    if ([platform isEqualToString:@"iPhone11,6"])    return @"iPhone XS Max";
    
    // iPhone XR
    if ([platform isEqualToString:@"iPhone11,8"])    return @"iPhone XR";
    
    // iPhone 11
    if ([platform isEqualToString:@"iPhone12,1"])    return @"iPhone 11";
    if ([platform isEqualToString:@"iPhone12,3"])    return @"iPhone 11 Pro";
    if ([platform isEqualToString:@"iPhone12,5"])    return @"iPhone 11 Pro Max";
    
    // == iPod ==
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"])      return @"iPod Touch 5G";
    if ([platform isEqualToString:@"iPod7,1"])      return @"iPod Touch 6G";
    if ([platform isEqualToString:@"iPod9,1"])      return @"iPod Touch 7G";
    
    // == iPad ==
    // iPad 1
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad 1";
    // iPad 2
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2";
    // iPad 3
    if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3";
    // iPad 4
    if ([platform isEqualToString:@"iPad3,4"])      return @"iPad 4";
    if ([platform isEqualToString:@"iPad3,5"])      return @"iPad 4";
    if ([platform isEqualToString:@"iPad3,6"])      return @"iPad 4";
    // iPad Air
    if ([platform isEqualToString:@"iPad4,1"])      return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,2"])      return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,3"])      return @"iPad Air";
    // iPad Air 2
    if ([platform isEqualToString:@"iPad5,3"])      return @"iPad Air 2";
    if ([platform isEqualToString:@"iPad5,4"])      return @"iPad Air 2";
    // iPad 5
    if ([platform isEqualToString:@"iPad6,11"])      return @"iPad 5";
    if ([platform isEqualToString:@"iPad6,12"])      return @"iPad 5";
    // iPad 6
    if ([platform isEqualToString:@"iPad7,5"])      return @"iPad 6";
    if ([platform isEqualToString:@"iPad7,6"])      return @"iPad 6";
    // iPad Air 3
    if ([platform isEqualToString:@"iPad11,3"])      return @"iPad Air 3";
    if ([platform isEqualToString:@"iPad11,4"])      return @"iPad Air 3";
    // iPad 7
    if ([platform isEqualToString:@"iPad7,11"])      return @"iPad 6";
    if ([platform isEqualToString:@"iPad7,12"])      return @"iPad 6";
    
    // iPad Pro
    if ([platform isEqualToString:@"iPad6,7"])      return @"iPad Pro";
    if ([platform isEqualToString:@"iPad6,8"])      return @"iPad Pro";
    if ([platform isEqualToString:@"iPad6,3"])      return @"iPad Pro";
    if ([platform isEqualToString:@"iPad6,4"])      return @"iPad Pro";
    if ([platform isEqualToString:@"iPad7,1"])      return @"iPad Pro";
    if ([platform isEqualToString:@"iPad7,2"])      return @"iPad Pro";
    if ([platform isEqualToString:@"iPad7,3"])      return @"iPad Pro";
    if ([platform isEqualToString:@"iPad7,4"])      return @"iPad Pro";
    if ([platform isEqualToString:@"iPad8,1"])      return @"iPad Pro";
    if ([platform isEqualToString:@"iPad8,2"])      return @"iPad Pro";
    if ([platform isEqualToString:@"iPad8,3"])      return @"iPad Pro";
    if ([platform isEqualToString:@"iPad8,4"])      return @"iPad Pro";
    if ([platform isEqualToString:@"iPad8,5"])      return @"iPad Pro";
    if ([platform isEqualToString:@"iPad8,6"])      return @"iPad Pro";
    if ([platform isEqualToString:@"iPad8,7"])      return @"iPad Pro";
    if ([platform isEqualToString:@"iPad8,8"])      return @"iPad Pro";
    
    // iPad Mini
    if ([platform isEqualToString:@"iPad2,5"])      return @"iPad Mini";
    if ([platform isEqualToString:@"iPad2,6"])      return @"iPad Mini";
    if ([platform isEqualToString:@"iPad2,7"])      return @"iPad Mini";
    // iPad Mini 2
    if ([platform isEqualToString:@"iPad4,4"])      return @"iPad Mini 2";
    if ([platform isEqualToString:@"iPad4,5"])      return @"iPad Mini 2";
    if ([platform isEqualToString:@"iPad4,6"])      return @"iPad Mini 2";
    // iPad Mini 3
    if ([platform isEqualToString:@"iPad4,7"])      return @"iPad Mini 3";
    if ([platform isEqualToString:@"iPad4,8"])      return @"iPad Mini 3";
    if ([platform isEqualToString:@"iPad4,9"])      return @"iPad Mini 3";
    // iPad Mini 4
    if ([platform isEqualToString:@"iPad5,1"])      return @"iPad Mini 4";
    if ([platform isEqualToString:@"iPad5,2"])      return @"iPad Mini 4";
    // iPad Mini 5
    if ([platform isEqualToString:@"iPad11,1"])      return @"iPad Mini 5";
    if ([platform isEqualToString:@"iPad11,2"])      return @"iPad Mini 5";
    
    // == Others ==
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
    if ([platform hasPrefix:@"MacBookAir"])         return @"MacBook Air";
    if ([platform hasPrefix:@"MacBookPro"])         return @"MacBook Pro";
    if ([platform hasPrefix:@"MacBook"])            return @"MacBook";
    if ([platform hasPrefix:@"MacPro"])             return @"Mac Pro";
    if ([platform hasPrefix:@"Macmini"])            return @"Mac Mini";
    if ([platform hasPrefix:@"iMac"])               return @"iMac";
    if ([platform hasPrefix:@"Xserve"])             return @"Xserve";
    return platform;
}


@end
