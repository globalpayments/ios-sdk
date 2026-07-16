#import <Foundation/Foundation.h>
#import "HpsDeviceProtocols.h"
#import "HpsDeviceMessage.h"
#import "HpsTerminalEnums.h"
#import "HpaEnums.h"
#import "HpsIngenicoEnums.h"

@interface HpsTerminalUtilities : NSObject
{
     NSString *_version;
}

+ (HpsDeviceMessage*) buildRequest: (NSString*) messageId;
+ (HpsDeviceMessage*) buildRequest: (NSString*) messageId withElements:(NSArray*)elements;
+ (NSData *)trimHpsResponseData:(NSData *)data;
+ (id <IHPSDeviceMessage>) BuildRequest:(NSString *) message withFormat:(MessageFormat)format;

//INGENICO
+ (NSString *)getSubString:(NSString *)dataString range:(NSRange)range;
+ (HpsDeviceMessage *)BuildIngenicoRequest:(NSString *)message;
+ (HpsDeviceMessage *)GenerateKeepAliveResponse:(NSData *)keepAliveData;
+ (NSData *)CalculateHeader:(NSData *)data;
+ (int)HeaderLength:(NSData *)data;
+ (NSData*)dataFromHexString:(NSString*)hexString;
+ (NSString *)stringFromData:(NSData *)data;
+ (NSString *)getString:(NSData *)data;
+ (NSArray *)stringToArray:(NSString *)string;
+ (HpsDeviceMessage *)buildPATMessage:(NSString*)message;

@end
