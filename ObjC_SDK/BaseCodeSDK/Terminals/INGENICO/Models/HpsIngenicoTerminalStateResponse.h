//
//  HpsIngenicoTerminalStateResponse.h
//  ObjC_SDK
//
//  Created by ADL on 10/22/20.
//  Copyright © 2020 iGen Payment Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HpsIngenicoTerminalResponse.h"
#import "HpsTerminalUtilities.h"
#import "HpsIngenicoEnums.h"
#import "HpsTypeLengthValue.h"


NS_ASSUME_NONNULL_BEGIN

@interface HpsIngenicoTerminalStateResponse : HpsIngenicoTerminalResponse

@property (nonatomic,strong) NSString* terminalStatus;
@property (nonatomic,strong) NSString* salesMode;
@property (nonatomic,strong) NSString* terminalCapabilities;
@property (nonatomic,strong) NSString* additionalTerminalCap;
@property (nonatomic,strong) NSString* appVersion;
@property (nonatomic,strong) NSString* handsetNumber;
@property (nonatomic,strong) NSString* terminalId;

-(id)initWithBuffer:(NSData *)data;

@end


NS_ASSUME_NONNULL_END
